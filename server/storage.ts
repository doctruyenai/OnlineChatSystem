import { 
  users, 
  customers, 
  conversations, 
  messages, 
  widgetConfigs,
  type User, 
  type InsertUser,
  type Customer,
  type InsertCustomer,
  type Conversation,
  type InsertConversation,
  type Message,
  type InsertMessage,
  type WidgetConfig,
  type InsertWidgetConfig,
  type ConversationWithDetails
} from "@shared/schema";
import { db } from "./db";
import { eq, desc, and, or, isNull } from "drizzle-orm";
import session from "express-session";
import connectPg from "connect-pg-simple";
import { pool } from "./db";

const PostgresSessionStore = connectPg(session);

export interface IStorage {
  // Users
  getUser(id: number): Promise<User | undefined>;
  getUserByUsername(username: string): Promise<User | undefined>;
  getUserByEmail(email: string): Promise<User | undefined>;
  createUser(user: InsertUser): Promise<User>;
  updateUserOnlineStatus(id: number, isOnline: boolean): Promise<void>;
  getOnlineAgents(): Promise<User[]>;

  // Customers
  getCustomer(id: number): Promise<Customer | undefined>;
  getCustomerBySessionId(sessionId: string): Promise<Customer | undefined>;
  createCustomer(customer: InsertCustomer): Promise<Customer>;

  // Conversations
  getConversation(id: number): Promise<ConversationWithDetails | undefined>;
  getConversationsByAgent(agentId: number): Promise<ConversationWithDetails[]>;
  getActiveConversations(): Promise<ConversationWithDetails[]>;
  createConversation(conversation: InsertConversation): Promise<Conversation>;
  updateConversation(id: number, updates: Partial<Conversation>): Promise<void>;
  assignConversationToAgent(conversationId: number, agentId: number): Promise<void>;

  // Messages
  getMessage(id: number): Promise<Message | undefined>;
  getMessagesByConversation(conversationId: number): Promise<Message[]>;
  createMessage(message: InsertMessage): Promise<Message>;

  // Widget configs
  getWidgetConfig(domain: string): Promise<WidgetConfig | undefined>;
  createWidgetConfig(config: InsertWidgetConfig): Promise<WidgetConfig>;

  // Session store
  sessionStore: any;
}

export class DatabaseStorage implements IStorage {
  sessionStore: any;

  constructor() {
    this.sessionStore = new PostgresSessionStore({ 
      pool, 
      createTableIfMissing: true 
    });
  }

  // Users
  async getUser(id: number): Promise<User | undefined> {
    const [user] = await db.select().from(users).where(eq(users.id, id));
    return user || undefined;
  }

  async getUserByUsername(username: string): Promise<User | undefined> {
    const [user] = await db.select().from(users).where(eq(users.username, username));
    return user || undefined;
  }

  async getUserByEmail(email: string): Promise<User | undefined> {
    const [user] = await db.select().from(users).where(eq(users.email, email));
    return user || undefined;
  }

  async createUser(insertUser: InsertUser): Promise<User> {
    const [user] = await db
      .insert(users)
      .values(insertUser)
      .returning();
    return user;
  }

  async updateUserOnlineStatus(id: number, isOnline: boolean): Promise<void> {
    await db
      .update(users)
      .set({ 
        isOnline,
        lastSeen: new Date()
      })
      .where(eq(users.id, id));
  }

  async getOnlineAgents(): Promise<User[]> {
    return await db
      .select()
      .from(users)
      .where(and(eq(users.role, "agent"), eq(users.isOnline, true)));
  }

  // Customers
  async getCustomer(id: number): Promise<Customer | undefined> {
    const [customer] = await db.select().from(customers).where(eq(customers.id, id));
    return customer || undefined;
  }

  async getCustomerBySessionId(sessionId: string): Promise<Customer | undefined> {
    const [customer] = await db.select().from(customers).where(eq(customers.sessionId, sessionId));
    return customer || undefined;
  }

  async createCustomer(insertCustomer: InsertCustomer): Promise<Customer> {
    const [customer] = await db
      .insert(customers)
      .values(insertCustomer)
      .returning();
    return customer;
  }

  // Conversations
  async getConversation(id: number): Promise<ConversationWithDetails | undefined> {
    const result = await db
      .select()
      .from(conversations)
      .leftJoin(customers, eq(conversations.customerId, customers.id))
      .leftJoin(users, eq(conversations.agentId, users.id))
      .where(eq(conversations.id, id));

    if (!result[0]) return undefined;

    const conversation = result[0].conversations;
    const customer = result[0].customers!;
    const agent = result[0].users || undefined;

    const conversationMessages = await this.getMessagesByConversation(id);

    return {
      ...conversation,
      customer,
      agent,
      messages: conversationMessages,
    };
  }

  async getConversationsByAgent(agentId: number): Promise<ConversationWithDetails[]> {
    const result = await db
      .select()
      .from(conversations)
      .leftJoin(customers, eq(conversations.customerId, customers.id))
      .leftJoin(users, eq(conversations.agentId, users.id))
      .where(eq(conversations.agentId, agentId))
      .orderBy(desc(conversations.updatedAt));

    const conversationsWithDetails: ConversationWithDetails[] = [];

    for (const row of result) {
      const conversation = row.conversations;
      const customer = row.customers!;
      const agent = row.users || undefined;

      const conversationMessages = await this.getMessagesByConversation(conversation.id);

      conversationsWithDetails.push({
        ...conversation,
        customer,
        agent,
        messages: conversationMessages,
      });
    }

    return conversationsWithDetails;
  }

  async getActiveConversations(): Promise<ConversationWithDetails[]> {
    const result = await db
      .select()
      .from(conversations)
      .leftJoin(customers, eq(conversations.customerId, customers.id))
      .leftJoin(users, eq(conversations.agentId, users.id))
      .where(or(
        eq(conversations.status, "waiting"),
        eq(conversations.status, "active")
      ))
      .orderBy(desc(conversations.updatedAt));

    const conversationsWithDetails: ConversationWithDetails[] = [];

    for (const row of result) {
      const conversation = row.conversations;
      const customer = row.customers!;
      const agent = row.users || undefined;

      const conversationMessages = await this.getMessagesByConversation(conversation.id);

      conversationsWithDetails.push({
        ...conversation,
        customer,
        agent,
        messages: conversationMessages,
      });
    }

    return conversationsWithDetails;
  }

  async createConversation(insertConversation: InsertConversation): Promise<Conversation> {
    const [conversation] = await db
      .insert(conversations)
      .values(insertConversation)
      .returning();
    return conversation;
  }

  async updateConversation(id: number, updates: Partial<Conversation>): Promise<void> {
    await db
      .update(conversations)
      .set({ ...updates, updatedAt: new Date() })
      .where(eq(conversations.id, id));
  }

  async assignConversationToAgent(conversationId: number, agentId: number): Promise<void> {
    await db
      .update(conversations)
      .set({ 
        agentId, 
        status: "active",
        updatedAt: new Date()
      })
      .where(eq(conversations.id, conversationId));
  }

  // Messages
  async getMessage(id: number): Promise<Message | undefined> {
    const [message] = await db.select().from(messages).where(eq(messages.id, id));
    return message || undefined;
  }

  async getMessagesByConversation(conversationId: number): Promise<Message[]> {
    return await db
      .select()
      .from(messages)
      .where(eq(messages.conversationId, conversationId))
      .orderBy(messages.createdAt);
  }

  async createMessage(insertMessage: InsertMessage): Promise<Message> {
    const [message] = await db
      .insert(messages)
      .values(insertMessage)
      .returning();
    return message;
  }

  // Widget configs
  async getWidgetConfig(domain: string): Promise<WidgetConfig | undefined> {
    const [config] = await db
      .select()
      .from(widgetConfigs)
      .where(eq(widgetConfigs.domain, domain));
    return config || undefined;
  }

  async createWidgetConfig(insertConfig: InsertWidgetConfig): Promise<WidgetConfig> {
    const [config] = await db
      .insert(widgetConfigs)
      .values(insertConfig)
      .returning();
    return config;
  }
}

export const storage = new DatabaseStorage();
