import type { Express } from "express";
import { createServer, type Server } from "http";
import { WebSocketServer, WebSocket } from "ws";
import path from "path";
import { setupAuth } from "./auth";
import { storage } from "./storage";
import { setupSocketHandlers } from "./socket";
import { insertCustomerSchema, insertConversationSchema, insertMessageSchema } from "@shared/schema";
import { z } from "zod";

export async function registerRoutes(app: Express): Promise<Server> {
  // Setup authentication routes
  setupAuth(app);

  // Chat API routes
  
  // Get active conversations for agent
  app.get("/api/conversations", async (req, res) => {
    if (!req.isAuthenticated()) return res.sendStatus(401);
    
    try {
      // Get all active conversations (not just assigned to this agent)
      const conversations = await storage.getActiveConversations();
      res.json(conversations);
    } catch (error) {
      console.error("Error fetching conversations:", error);
      res.status(500).json({ message: "Failed to fetch conversations" });
    }
  });

  // Get specific conversation
  app.get("/api/conversations/:id", async (req, res) => {
    if (!req.isAuthenticated()) return res.sendStatus(401);
    
    try {
      const conversationId = parseInt(req.params.id);
      const conversation = await storage.getConversation(conversationId);
      
      if (!conversation) {
        return res.status(404).json({ message: "Conversation not found" });
      }
      
      res.json(conversation);
    } catch (error) {
      console.error("Error fetching conversation:", error);
      res.status(500).json({ message: "Failed to fetch conversation" });
    }
  });

  // Assign conversation to agent
  app.post("/api/conversations/:id/assign", async (req, res) => {
    if (!req.isAuthenticated()) return res.sendStatus(401);
    
    try {
      const conversationId = parseInt(req.params.id);
      await storage.assignConversationToAgent(conversationId, req.user!.id);
      res.json({ success: true });
    } catch (error) {
      console.error("Error assigning conversation:", error);
      res.status(500).json({ message: "Failed to assign conversation" });
    }
  });

  // Update conversation status
  app.patch("/api/conversations/:id", async (req, res) => {
    if (!req.isAuthenticated()) return res.sendStatus(401);
    
    try {
      const conversationId = parseInt(req.params.id);
      const { status, priority } = req.body;
      
      await storage.updateConversation(conversationId, { status, priority });
      res.json({ success: true });
    } catch (error) {
      console.error("Error updating conversation:", error);
      res.status(500).json({ message: "Failed to update conversation" });
    }
  });

  // Widget static files
  app.get("/widget.js", (req, res) => {
    res.setHeader("Content-Type", "application/javascript");
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.sendFile(path.join(process.cwd(), "public", "widget.js"));
  });

  app.get("/widget.css", (req, res) => {
    res.setHeader("Content-Type", "text/css");
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.sendFile(path.join(process.cwd(), "public", "widget.css"));
  });

  // Widget API routes

  // Initialize chat widget
  app.post("/api/widget/init", async (req, res) => {
    try {
      const customerData = insertCustomerSchema.parse(req.body);
      
      // Check if customer already exists by session ID
      let customer = await storage.getCustomerBySessionId(customerData.sessionId);
      
      if (!customer) {
        customer = await storage.createCustomer(customerData);
      }

      res.json({ customer });
    } catch (error) {
      console.error("Error initializing widget:", error);
      res.status(500).json({ message: "Failed to initialize widget" });
    }
  });

  // Start new conversation
  app.post("/api/widget/conversation", async (req, res) => {
    try {
      const { customerId, subject, metadata } = req.body;
      
      const conversationData = {
        customerId,
        subject: subject || "New chat conversation",
        metadata: metadata || {},
        priority: "normal" as const,
        status: "waiting" as const,
      };

      const conversation = await storage.createConversation(conversationData);
      
      // Create initial system message
      await storage.createMessage({
        conversationId: conversation.id,
        senderType: "system",
        content: "Conversation started",
        messageType: "system",
      });

      res.json({ conversation });
    } catch (error) {
      console.error("Error creating conversation:", error);
      res.status(500).json({ message: "Failed to create conversation" });
    }
  });

  // Send message from widget
  app.post("/api/widget/message", async (req, res) => {
    try {
      const messageData = insertMessageSchema.parse(req.body);
      const message = await storage.createMessage(messageData);
      
      // Update conversation timestamp
      await storage.updateConversation(messageData.conversationId, {});
      
      res.json({ message });
    } catch (error) {
      console.error("Error sending message:", error);
      res.status(500).json({ message: "Failed to send message" });
    }
  });

  // Get online agents count
  app.get("/api/agents/online", async (req, res) => {
    try {
      const onlineAgents = await storage.getOnlineAgents();
      res.json({ count: onlineAgents.length, agents: onlineAgents });
    } catch (error) {
      console.error("Error fetching online agents:", error);
      res.status(500).json({ message: "Failed to fetch online agents" });
    }
  });

  // Widget script serving
  app.get("/widget/chat-widget.js", (req, res) => {
    res.setHeader("Content-Type", "application/javascript");
    res.setHeader("Access-Control-Allow-Origin", "*");
    
    const widgetScript = `
(function() {
  'use strict';
  
  // Widget configuration
  const config = window.ChatWidgetConfig || {};
  const serverUrl = config.serverUrl || window.location.origin;
  const position = config.position || 'bottom-right';
  const theme = config.theme || {};
  const welcomeMessage = config.welcomeMessage || 'Hi! How can we help you?';
  const fields = config.fields || [
    { name: 'name', label: 'Name', type: 'text', required: true },
    { name: 'email', label: 'Email', type: 'email', required: true },
    { name: 'message', label: 'Message', type: 'textarea', required: true }
  ];

  // Generate unique session ID
  function generateSessionId() {
    return 'widget_' + Math.random().toString(36).substr(2, 9) + '_' + Date.now();
  }

  // Create widget HTML
  function createWidget() {
    const widgetId = 'livechat-widget-' + Math.random().toString(36).substr(2, 9);
    
    const widgetHTML = \`
      <div id="\${widgetId}" style="position: fixed; z-index: 999999; \${getPositionStyles()}">
        <!-- Widget button -->
        <div class="widget-button" style="
          width: 60px; 
          height: 60px; 
          background: \${theme.primaryColor || '#3B82F6'}; 
          border-radius: 50%; 
          display: flex; 
          align-items: center; 
          justify-content: center; 
          cursor: pointer; 
          box-shadow: 0 4px 12px rgba(0,0,0,0.15);
          transition: all 0.3s ease;
        ">
          <svg width="24" height="24" fill="white" viewBox="0 0 24 24">
            <path d="M20 2H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h4l4 4 4-4h4c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z"/>
          </svg>
        </div>
        
        <!-- Widget window -->
        <div class="widget-window" style="
          display: none;
          position: absolute;
          bottom: 70px;
          right: 0;
          width: 350px;
          height: 500px;
          background: white;
          border-radius: 12px;
          box-shadow: 0 8px 32px rgba(0,0,0,0.15);
          overflow: hidden;
          border: 1px solid #e5e7eb;
        ">
          <!-- Header -->
          <div style="
            background: \${theme.primaryColor || '#3B82F6'};
            color: white;
            padding: 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
          ">
            <div>
              <h4 style="margin: 0; font-size: 16px; font-weight: 600;">Customer Support</h4>
              <p style="margin: 0; font-size: 12px; opacity: 0.9;">We're here to help!</p>
            </div>
            <button class="close-btn" style="
              background: none;
              border: none;
              color: white;
              cursor: pointer;
              font-size: 18px;
              opacity: 0.8;
            ">×</button>
          </div>
          
          <!-- Content -->
          <div class="widget-content" style="height: calc(100% - 64px); display: flex; flex-direction: column;">
            <!-- Welcome form -->
            <div class="welcome-form" style="padding: 20px; flex: 1; display: flex; flex-direction: column;">
              <h5 style="margin: 0 0 12px 0; font-size: 16px; color: #374151;">Start a conversation</h5>
              <p style="margin: 0 0 20px 0; font-size: 14px; color: #6b7280;">Please provide your information to get started.</p>
              
              <form style="flex: 1; display: flex; flex-direction: column; gap: 12px;">
                \${fields.map(field => \`
                  <div>
                    <input
                      type="\${field.type === 'textarea' ? 'text' : field.type}"
                      placeholder="\${field.label}\${field.required ? ' *' : ''}"
                      name="\${field.name}"
                      \${field.required ? 'required' : ''}
                      style="
                        width: 100%;
                        padding: 10px 12px;
                        border: 1px solid #d1d5db;
                        border-radius: 8px;
                        font-size: 14px;
                        box-sizing: border-box;
                      "
                    />
                  </div>
                \`).join('')}
                
                <button type="submit" style="
                  background: \${theme.primaryColor || '#3B82F6'};
                  color: white;
                  border: none;
                  padding: 12px;
                  border-radius: 8px;
                  font-size: 14px;
                  font-weight: 600;
                  cursor: pointer;
                  margin-top: auto;
                ">Start Chat</button>
              </form>
            </div>
            
            <!-- Chat interface (hidden initially) -->
            <div class="chat-interface" style="display: none; flex: 1; flex-direction: column;">
              <div class="messages" style="
                flex: 1;
                padding: 16px;
                overflow-y: auto;
                display: flex;
                flex-direction: column;
                gap: 12px;
              "></div>
              
              <div style="
                border-top: 1px solid #e5e7eb;
                padding: 12px;
                display: flex;
                gap: 8px;
              ">
                <input
                  type="text"
                  placeholder="Type a message..."
                  class="message-input"
                  style="
                    flex: 1;
                    padding: 8px 12px;
                    border: 1px solid #d1d5db;
                    border-radius: 20px;
                    font-size: 14px;
                  "
                />
                <button class="send-btn" style="
                  background: \${theme.primaryColor || '#3B82F6'};
                  color: white;
                  border: none;
                  padding: 8px 16px;
                  border-radius: 20px;
                  cursor: pointer;
                ">Send</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    \`;

    return { widgetId, widgetHTML };
  }

  function getPositionStyles() {
    const positions = {
      'bottom-right': 'bottom: 20px; right: 20px;',
      'bottom-left': 'bottom: 20px; left: 20px;',
      'top-right': 'top: 20px; right: 20px;',
      'top-left': 'top: 20px; left: 20px;'
    };
    return positions[position] || positions['bottom-right'];
  }

  // Initialize widget
  function initWidget() {
    const { widgetId, widgetHTML } = createWidget();
    
    // Insert widget into DOM
    document.body.insertAdjacentHTML('beforeend', widgetHTML);
    
    const widget = document.getElementById(widgetId);
    const button = widget.querySelector('.widget-button');
    const window = widget.querySelector('.widget-window');
    const closeBtn = widget.querySelector('.close-btn');
    const welcomeForm = widget.querySelector('.welcome-form form');
    const chatInterface = widget.querySelector('.chat-interface');
    const messageInput = widget.querySelector('.message-input');
    const sendBtn = widget.querySelector('.send-btn');
    
    let isOpen = false;
    let sessionId = null;
    let conversationId = null;
    let socket = null;

    // Toggle widget
    function toggleWidget() {
      isOpen = !isOpen;
      window.style.display = isOpen ? 'block' : 'none';
    }

    // Start chat session
    async function startChat(formData) {
      sessionId = generateSessionId();
      
      try {
        // Initialize customer
        const initResponse = await fetch(\`\${serverUrl}/api/widget/init\`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            sessionId,
            name: formData.get('name'),
            email: formData.get('email'),
            phone: formData.get('phone')
          })
        });
        
        const initData = await initResponse.json();
        
        // Create conversation
        const convResponse = await fetch(\`\${serverUrl}/api/widget/conversation\`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            customerId: initData.customer.id,
            subject: 'Website chat',
            metadata: Object.fromEntries(formData.entries())
          })
        });
        
        const convData = await convResponse.json();
        conversationId = convData.conversation.id;
        
        // Switch to chat interface
        widget.querySelector('.welcome-form').style.display = 'none';
        chatInterface.style.display = 'flex';
        
        // Connect WebSocket
        connectWebSocket();
        
        // Send initial message
        if (formData.get('message') || formData.get('content')) {
          sendMessage(formData.get('message') || formData.get('content'));
        }
        
      } catch (error) {
        console.error('Error starting chat:', error);
        alert('Failed to start chat. Please try again.');
      }
    }

    // Connect WebSocket
    function connectWebSocket() {
      const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
      const wsUrl = \`\${protocol}//\${window.location.host}/ws\`;
      
      socket = new WebSocket(wsUrl);
      
      socket.onopen = () => {
        socket.send(JSON.stringify({
          type: 'join_conversation',
          conversationId,
          sessionId
        }));
      };
      
      socket.onmessage = (event) => {
        const data = JSON.parse(event.data);
        if (data.type === 'new_message' && data.conversationId === conversationId) {
          addMessage(data.message, false);
        }
      };
    }

    // Send message
    async function sendMessage(content) {
      if (!content.trim() || !conversationId) return;
      
      try {
        const response = await fetch(\`\${serverUrl}/api/widget/message\`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            conversationId,
            senderType: 'customer',
            content: content.trim(),
            messageType: 'text'
          })
        });
        
        const data = await response.json();
        addMessage(data.message, true);
        
        // Clear input
        messageInput.value = '';
        
      } catch (error) {
        console.error('Error sending message:', error);
      }
    }

    // Add message to chat
    function addMessage(message, isOwn) {
      const messagesContainer = widget.querySelector('.messages');
      const messageEl = document.createElement('div');
      
      messageEl.style.cssText = \`
        max-width: 80%;
        padding: 8px 12px;
        border-radius: 12px;
        font-size: 14px;
        word-wrap: break-word;
        \${isOwn ? \`
          background: \${theme.primaryColor || '#3B82F6'};
          color: white;
          margin-left: auto;
          align-self: flex-end;
        \` : \`
          background: #f3f4f6;
          color: #374151;
          margin-right: auto;
          align-self: flex-start;
        \`}
      \`;
      
      messageEl.textContent = message.content;
      messagesContainer.appendChild(messageEl);
      messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }

    // Event listeners
    button.addEventListener('click', toggleWidget);
    closeBtn.addEventListener('click', toggleWidget);
    
    welcomeForm.addEventListener('submit', (e) => {
      e.preventDefault();
      startChat(new FormData(e.target));
    });
    
    sendBtn.addEventListener('click', () => {
      sendMessage(messageInput.value);
    });
    
    messageInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') {
        sendMessage(messageInput.value);
      }
    });
  }

  // Initialize when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initWidget);
  } else {
    initWidget();
  }
})();
    `;
    
    res.send(widgetScript);
  });

  // Widget demo page
  app.get("/widget/demo.html", (req, res) => {
    res.setHeader("Content-Type", "text/html");
    
    const demoHTML = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chat Widget Demo</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 40px; border-radius: 8px; }
        h1 { color: #333; }
        .demo-content { margin: 40px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Chat Widget Demo</h1>
        <div class="demo-content">
            <p>This is a demo page showing how the chat widget appears on your website.</p>
            <p>The chat widget is positioned in the bottom right corner. Click on it to start a conversation with our support team.</p>
            <h2>Features:</h2>
            <ul>
                <li>Real-time messaging</li>
                <li>Agent assignment</li>
                <li>File uploads</li>
                <li>Chat history</li>
                <li>Mobile responsive</li>
            </ul>
        </div>
    </div>

    <!-- Chat Widget -->
    <script>
        window.ChatWidgetConfig = {
            serverUrl: window.location.origin,
            position: 'bottom-right',
            welcomeMessage: 'Hi! How can we help you today?',
            theme: {
                primaryColor: '#3B82F6',
                textColor: '#374151',
                backgroundColor: '#FFFFFF'
            },
            fields: [
                { name: 'name', label: 'Full Name', type: 'text', required: true },
                { name: 'phone', label: 'Phone Number', type: 'tel', required: true },
                { name: 'email', label: 'Email Address', type: 'email', required: false },
                { name: 'content', label: 'How can we help you?', type: 'textarea', required: true }
            ]
        };
    </script>
    <script src="/widget/chat-widget.js"></script>
</body>
</html>
    `;
    
    res.send(demoHTML);
  });

  const httpServer = createServer(app);

  // Setup WebSocket server
  const wss = new WebSocketServer({ server: httpServer, path: '/ws' });
  setupSocketHandlers(wss);

  return httpServer;
}
