(function() {
  'use strict';

  // Widget configuration
  const config = window.LiveChatConfig || {};
  const serverUrl = window.location.origin;
  
  // Default configuration
  const defaultConfig = {
    title: 'Chat Support',
    subtitle: 'We\'re here to help',
    primaryColor: '#3b82f6',
    position: 'bottom-right',
    welcomeMessage: 'Hi! How can we help you?',
    offlineMessage: 'We are currently offline. Please leave a message.',
    showAgentPhotos: true,
    allowFileUpload: true,
    collectUserInfo: true,
    requiredFields: ['name', 'email']
  };

  // Merge configurations
  const widgetConfig = { ...defaultConfig, ...config };

  let widget = null;
  let isOpen = false;
  let socket = null;
  let sessionId = null;
  let conversationId = null;

  // Generate session ID
  function generateSessionId() {
    return 'widget_' + Math.random().toString(36).substring(2) + '_' + Date.now();
  }

  // Create widget HTML
  function createWidgetHTML() {
    return `
      <div id="live-chat-widget" style="
        position: fixed;
        ${getPositionStyles()}
        z-index: 10000;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      ">
        <!-- Chat Button -->
        <div id="chat-button" style="
          width: 60px;
          height: 60px;
          background-color: ${widgetConfig.primaryColor};
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          cursor: pointer;
          box-shadow: 0 4px 12px rgba(0,0,0,0.15);
          transition: all 0.3s ease;
        ">
          <svg width="24" height="24" fill="white" viewBox="0 0 24 24">
            <path d="M12 2C6.48 2 2 6.48 2 12c0 1.54.36 3.04 1.05 4.35L2 22l5.65-1.05C9.96 21.64 11.46 22 13 22h7c1.1 0 2-.9 2-2V12c0-5.52-4.48-10-10-10zm0 18c-1.4 0-2.76-.35-4-.99L5 20l1.01-3C5.35 15.76 5 14.4 5 13c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7z"/>
          </svg>
        </div>

        <!-- Chat Window -->
        <div id="chat-window" style="
          position: absolute;
          ${getWindowPosition()}
          width: 350px;
          height: 500px;
          background: white;
          border-radius: 12px;
          box-shadow: 0 8px 32px rgba(0,0,0,0.12);
          display: none;
          flex-direction: column;
          overflow: hidden;
        ">
          <!-- Header -->
          <div style="
            background-color: ${widgetConfig.primaryColor};
            color: white;
            padding: 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
          ">
            <div>
              <div style="font-weight: 600; font-size: 16px;">${widgetConfig.title}</div>
              <div style="font-size: 14px; opacity: 0.9;">${widgetConfig.subtitle}</div>
            </div>
            <button id="close-chat" style="
              background: none;
              border: none;
              color: white;
              cursor: pointer;
              padding: 4px;
              border-radius: 4px;
            ">
              <svg width="20" height="20" fill="currentColor" viewBox="0 0 24 24">
                <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
              </svg>
            </button>
          </div>

          <!-- Messages -->
          <div id="messages-container" style="
            flex: 1;
            padding: 16px;
            overflow-y: auto;
            background-color: #f9fafb;
          ">
            <!-- Welcome message -->
            <div style="
              background: white;
              padding: 12px;
              border-radius: 8px;
              margin-bottom: 12px;
              box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            ">
              ${widgetConfig.welcomeMessage}
            </div>
          </div>

          <!-- Input -->
          <div style="
            padding: 16px;
            border-top: 1px solid #e5e7eb;
            background: white;
          ">
            <div style="display: flex; gap: 8px;">
              <input id="message-input" type="text" placeholder="Type your message..." style="
                flex: 1;
                padding: 12px;
                border: 1px solid #d1d5db;
                border-radius: 8px;
                outline: none;
                font-size: 14px;
              ">
              <button id="send-button" style="
                background-color: ${widgetConfig.primaryColor};
                color: white;
                border: none;
                padding: 12px;
                border-radius: 8px;
                cursor: pointer;
                min-width: 44px;
                display: flex;
                align-items: center;
                justify-content: center;
              ">
                <svg width="16" height="16" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>
    `;
  }

  function getPositionStyles() {
    const positions = {
      'bottom-right': 'bottom: 20px; right: 20px;',
      'bottom-left': 'bottom: 20px; left: 20px;',
      'top-right': 'top: 20px; right: 20px;',
      'top-left': 'top: 20px; left: 20px;'
    };
    return positions[widgetConfig.position] || positions['bottom-right'];
  }

  function getWindowPosition() {
    const positions = {
      'bottom-right': 'bottom: 80px; right: 0;',
      'bottom-left': 'bottom: 80px; left: 0;',
      'top-right': 'top: 80px; right: 0;',
      'top-left': 'top: 80px; left: 0;'
    };
    return positions[widgetConfig.position] || positions['bottom-right'];
  }

  // Initialize WebSocket connection
  function initializeSocket() {
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const wsUrl = `${protocol}//${window.location.host}/ws`;
    
    socket = new WebSocket(wsUrl);
    
    socket.onopen = function() {
      console.log('Widget WebSocket connected');
      // Initialize customer session
      socket.send(JSON.stringify({
        type: 'customer_init',
        sessionId: sessionId
      }));
    };
    
    socket.onmessage = function(event) {
      const message = JSON.parse(event.data);
      handleSocketMessage(message);
    };
    
    socket.onclose = function() {
      console.log('Widget WebSocket disconnected');
      // Attempt to reconnect after 3 seconds
      setTimeout(initializeSocket, 3000);
    };
    
    socket.onerror = function(error) {
      console.error('Widget WebSocket error:', error);
    };
  }

  function handleSocketMessage(message) {
    switch (message.type) {
      case 'customer_init_success':
        conversationId = message.conversationId;
        break;
      case 'new_message':
        if (message.conversationId === conversationId) {
          displayMessage(message.message);
        }
        break;
      case 'agent_typing':
        showTypingIndicator(message.agentName);
        break;
      case 'agent_stop_typing':
        hideTypingIndicator();
        break;
    }
  }

  function displayMessage(message) {
    const messagesContainer = document.getElementById('messages-container');
    const messageElement = document.createElement('div');
    
    const isAgent = message.senderType === 'agent';
    
    messageElement.style.cssText = `
      margin-bottom: 12px;
      display: flex;
      ${isAgent ? 'justify-content: flex-start;' : 'justify-content: flex-end;'}
    `;
    
    messageElement.innerHTML = `
      <div style="
        background-color: ${isAgent ? 'white' : widgetConfig.primaryColor};
        color: ${isAgent ? '#374151' : 'white'};
        padding: 12px;
        border-radius: 8px;
        max-width: 80%;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        word-wrap: break-word;
      ">
        ${message.content}
      </div>
    `;
    
    messagesContainer.appendChild(messageElement);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
  }

  function sendMessage(content) {
    if (!content.trim() || !socket || socket.readyState !== WebSocket.OPEN) {
      return;
    }

    // Send via WebSocket
    socket.send(JSON.stringify({
      type: 'send_message',
      conversationId: conversationId,
      content: content,
      sessionId: sessionId
    }));

    // Display message immediately
    displayMessage({
      content: content,
      senderType: 'customer',
      createdAt: new Date().toISOString()
    });

    // Clear input
    document.getElementById('message-input').value = '';
  }

  function showTypingIndicator(agentName) {
    const existingIndicator = document.getElementById('typing-indicator');
    if (existingIndicator) return;

    const messagesContainer = document.getElementById('messages-container');
    const indicator = document.createElement('div');
    indicator.id = 'typing-indicator';
    indicator.style.cssText = 'margin-bottom: 12px; display: flex; justify-content: flex-start;';
    
    indicator.innerHTML = `
      <div style="
        background-color: white;
        color: #6b7280;
        padding: 12px;
        border-radius: 8px;
        font-style: italic;
        font-size: 14px;
      ">
        ${agentName} is typing...
      </div>
    `;
    
    messagesContainer.appendChild(indicator);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
  }

  function hideTypingIndicator() {
    const indicator = document.getElementById('typing-indicator');
    if (indicator) {
      indicator.remove();
    }
  }

  function toggleChat() {
    const chatWindow = document.getElementById('chat-window');
    const chatButton = document.getElementById('chat-button');
    
    if (isOpen) {
      chatWindow.style.display = 'none';
      chatButton.style.transform = 'scale(1)';
      isOpen = false;
    } else {
      chatWindow.style.display = 'flex';
      chatButton.style.transform = 'scale(0.9)';
      isOpen = true;
      
      // Focus input
      setTimeout(() => {
        document.getElementById('message-input').focus();
      }, 100);
    }
  }

  // Initialize widget
  function initWidget() {
    // Generate session ID
    sessionId = generateSessionId();
    
    // Create widget HTML
    document.body.insertAdjacentHTML('beforeend', createWidgetHTML());
    widget = document.getElementById('live-chat-widget');
    
    // Add event listeners
    document.getElementById('chat-button').addEventListener('click', toggleChat);
    document.getElementById('close-chat').addEventListener('click', toggleChat);
    
    const messageInput = document.getElementById('message-input');
    const sendButton = document.getElementById('send-button');
    
    sendButton.addEventListener('click', () => {
      sendMessage(messageInput.value);
    });
    
    messageInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') {
        sendMessage(messageInput.value);
      }
    });
    
    // Initialize WebSocket
    initializeSocket();
  }

  // Initialize when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initWidget);
  } else {
    initWidget();
  }

})();