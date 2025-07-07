import { WebSocketServer, WebSocket } from "ws";
import { storage } from "./storage";

interface SocketConnection {
  ws: WebSocket;
  userId?: number;
  userType?: 'agent' | 'customer';
  conversationId?: number;
  sessionId?: string;
}

const connections = new Map<WebSocket, SocketConnection>();
const conversationConnections = new Map<number, Set<WebSocket>>();

export function setupSocketHandlers(wss: WebSocketServer) {
  wss.on('connection', (ws: WebSocket) => {
    console.log('New WebSocket connection');
    
    connections.set(ws, { ws });

    ws.on('message', async (data: Buffer) => {
      try {
        const message = JSON.parse(data.toString());
        await handleMessage(ws, message);
      } catch (error) {
        console.error('Error parsing WebSocket message:', error);
      }
    });

    ws.on('close', async () => {
      console.log('WebSocket connection closed');
      
      const connection = connections.get(ws);
      if (connection) {
        // Remove from conversation connections
        if (connection.conversationId) {
          const convConnections = conversationConnections.get(connection.conversationId);
          if (convConnections) {
            convConnections.delete(ws);
            if (convConnections.size === 0) {
              conversationConnections.delete(connection.conversationId);
            }
          }
        }

        // Update agent online status
        if (connection.userType === 'agent' && connection.userId) {
          await storage.updateUserOnlineStatus(connection.userId, false);
          broadcastAgentStatusUpdate();
        }
      }

      connections.delete(ws);
    });

    ws.on('error', (error) => {
      console.error('WebSocket error:', error);
    });
  });
}

async function handleMessage(ws: WebSocket, message: any) {
  const connection = connections.get(ws);
  if (!connection) return;

  switch (message.type) {
    case 'agent_auth':
      await handleAgentAuth(ws, message);
      break;

    case 'join_conversation':
      await handleJoinConversation(ws, message);
      break;

    case 'send_message':
      await handleSendMessage(ws, message);
      break;

    case 'typing_start':
    case 'typing_stop':
      await handleTypingStatus(ws, message);
      break;

    case 'agent_status_update':
      await handleAgentStatusUpdate(ws, message);
      break;

    default:
      console.log('Unknown message type:', message.type);
  }
}

async function handleAgentAuth(ws: WebSocket, message: any) {
  const { userId } = message;
  
  try {
    const user = await storage.getUser(userId);
    if (!user || user.role !== 'agent') {
      sendMessage(ws, { type: 'auth_error', message: 'Invalid agent' });
      return;
    }

    const connection = connections.get(ws);
    if (connection) {
      connection.userId = userId;
      connection.userType = 'agent';
    }

    // Update agent online status
    await storage.updateUserOnlineStatus(userId, true);
    
    sendMessage(ws, { type: 'auth_success', user });
    broadcastAgentStatusUpdate();
    
    console.log(`Agent ${user.email} connected`);
  } catch (error) {
    console.error('Error in agent auth:', error);
    sendMessage(ws, { type: 'auth_error', message: 'Authentication failed' });
  }
}

async function handleJoinConversation(ws: WebSocket, message: any) {
  const { conversationId, sessionId } = message;
  
  try {
    const connection = connections.get(ws);
    if (!connection) return;

    connection.conversationId = conversationId;
    
    if (sessionId) {
      connection.sessionId = sessionId;
      connection.userType = 'customer';
    }

    // Add to conversation connections
    if (!conversationConnections.has(conversationId)) {
      conversationConnections.set(conversationId, new Set());
    }
    conversationConnections.get(conversationId)!.add(ws);

    sendMessage(ws, { 
      type: 'joined_conversation', 
      conversationId,
      userType: connection.userType 
    });

    console.log(`${connection.userType || 'User'} joined conversation ${conversationId}`);
  } catch (error) {
    console.error('Error joining conversation:', error);
  }
}

async function handleSendMessage(ws: WebSocket, message: any) {
  const { conversationId, content, senderType } = message;
  
  try {
    const connection = connections.get(ws);
    if (!connection || !conversationId) return;

    // Create message in database
    const newMessage = await storage.createMessage({
      conversationId,
      senderId: connection.userId,
      senderType,
      content,
      messageType: 'text',
    });

    // Update conversation timestamp
    await storage.updateConversation(conversationId, {});

    // Broadcast to all connections in this conversation
    const convConnections = conversationConnections.get(conversationId);
    if (convConnections) {
      convConnections.forEach(clientWs => {
        if (clientWs.readyState === WebSocket.OPEN) {
          sendMessage(clientWs, {
            type: 'new_message',
            conversationId,
            message: newMessage
          });
        }
      });
    }

    // Notify all agents about the new message
    broadcastToAgents({
      type: 'conversation_update',
      conversationId,
      lastMessage: newMessage
    });

  } catch (error) {
    console.error('Error sending message:', error);
  }
}

async function handleTypingStatus(ws: WebSocket, message: any) {
  const { conversationId, isTyping } = message;
  
  const connection = connections.get(ws);
  if (!connection || !conversationId) return;

  // Broadcast typing status to other participants
  const convConnections = conversationConnections.get(conversationId);
  if (convConnections) {
    convConnections.forEach(clientWs => {
      if (clientWs !== ws && clientWs.readyState === WebSocket.OPEN) {
        sendMessage(clientWs, {
          type: message.type,
          conversationId,
          userId: connection.userId,
          userType: connection.userType,
          isTyping
        });
      }
    });
  }
}

async function handleAgentStatusUpdate(ws: WebSocket, message: any) {
  const { isOnline } = message;
  
  const connection = connections.get(ws);
  if (!connection || !connection.userId || connection.userType !== 'agent') return;

  try {
    await storage.updateUserOnlineStatus(connection.userId, isOnline);
    broadcastAgentStatusUpdate();
  } catch (error) {
    console.error('Error updating agent status:', error);
  }
}

function sendMessage(ws: WebSocket, message: any) {
  if (ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify(message));
  }
}

function broadcastToAgents(message: any) {
  connections.forEach((connection, ws) => {
    if (connection.userType === 'agent' && ws.readyState === WebSocket.OPEN) {
      sendMessage(ws, message);
    }
  });
}

async function broadcastAgentStatusUpdate() {
  try {
    const onlineAgents = await storage.getOnlineAgents();
    
    broadcastToAgents({
      type: 'agents_status_update',
      onlineAgents: onlineAgents.map(agent => ({
        id: agent.id,
        name: `${agent.firstName} ${agent.lastName}`,
        email: agent.email,
        isOnline: agent.isOnline
      }))
    });
  } catch (error) {
    console.error('Error broadcasting agent status:', error);
  }
}
