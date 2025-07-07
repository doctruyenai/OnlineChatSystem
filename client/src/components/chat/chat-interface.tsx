import { useState, useRef, useEffect } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { useSocket } from "@/hooks/use-socket";
import { useAuth } from "@/hooks/use-auth";
import { apiRequest } from "@/lib/queryClient";
import { ConversationWithDetails, Message } from "@shared/schema";
import { formatDistanceToNow } from "date-fns";

interface ChatInterfaceProps {
  conversation: ConversationWithDetails;
  onToggleCustomerInfo: () => void;
  showCustomerInfo: boolean;
}

export default function ChatInterface({ 
  conversation, 
  onToggleCustomerInfo, 
  showCustomerInfo 
}: ChatInterfaceProps) {
  const { user } = useAuth();
  const { sendMessage: sendSocketMessage } = useSocket();
  const [messageContent, setMessageContent] = useState("");
  const [isTyping, setIsTyping] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const queryClient = useQueryClient();

  const sendMessageMutation = useMutation({
    mutationFn: async (content: string) => {
      const res = await apiRequest("POST", "/api/widget/message", {
        conversationId: conversation.id,
        senderType: "agent",
        content,
        messageType: "text",
      });
      return await res.json();
    },
    onSuccess: (data) => {
      // Send via WebSocket for real-time updates
      sendSocketMessage({
        type: "send_message",
        conversationId: conversation.id,
        content: messageContent,
        senderType: "agent",
      });
      
      setMessageContent("");
      
      // Invalidate conversations to refresh the list
      queryClient.invalidateQueries({ queryKey: ["/api/conversations"] });
    },
  });

  const assignConversationMutation = useMutation({
    mutationFn: async () => {
      const res = await apiRequest("POST", `/api/conversations/${conversation.id}/assign`);
      return await res.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/conversations"] });
    },
  });

  const updateStatusMutation = useMutation({
    mutationFn: async (status: string) => {
      const res = await apiRequest("PATCH", `/api/conversations/${conversation.id}`, { status });
      return await res.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/conversations"] });
    },
  });

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [conversation.messages]);

  const handleSendMessage = () => {
    if (!messageContent.trim()) return;
    sendMessageMutation.mutate(messageContent);
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && e.ctrlKey) {
      e.preventDefault();
      handleSendMessage();
    }
  };

  const handleAssignToMe = () => {
    assignConversationMutation.mutate();
  };

  const handleStatusChange = (status: string) => {
    updateStatusMutation.mutate(status);
  };

  const isAssignedToMe = conversation.agentId === user?.id;
  const canSendMessage = isAssignedToMe || conversation.status === "waiting";

  return (
    <div className="flex-1 flex flex-col">
      {/* Chat Header */}
      <div className="bg-white border-b border-gray-200 px-6 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gray-300 rounded-full flex items-center justify-center text-sm font-medium text-gray-700">
                {conversation.customer.name.split(' ').map(n => n[0]).join('').toUpperCase()}
              </div>
              <div>
                <h3 className="text-lg font-semibold text-gray-900">
                  {conversation.customer.name}
                </h3>
                <div className="flex items-center space-x-3">
                  <p className="text-sm text-gray-500">
                    {conversation.customer.email || conversation.customer.phone}
                  </p>
                  {conversation.agent && (
                    <span className="text-xs bg-green-100 text-green-800 px-2 py-1 rounded-full">
                      Assigned to {conversation.agent.firstName} {conversation.agent.lastName}
                    </span>
                  )}
                </div>
              </div>
            </div>
          </div>
          
          <div className="flex items-center space-x-3">
            {!isAssignedToMe && conversation.status === "waiting" && (
              <Button 
                onClick={handleAssignToMe}
                disabled={assignConversationMutation.isPending}
                size="sm"
              >
                <i className="fas fa-user-plus mr-2"></i>
                Assign to Me
              </Button>
            )}
            
            {isAssignedToMe && (
              <div className="flex items-center space-x-2">
                <Button
                  onClick={() => handleStatusChange("resolved")}
                  disabled={updateStatusMutation.isPending}
                  variant="outline"
                  size="sm"
                >
                  <i className="fas fa-check mr-2"></i>
                  Resolve
                </Button>
                <Button
                  onClick={() => handleStatusChange("closed")}
                  disabled={updateStatusMutation.isPending}
                  variant="outline"
                  size="sm"
                >
                  <i className="fas fa-times mr-2"></i>
                  Close
                </Button>
              </div>
            )}
            
            <Button
              onClick={onToggleCustomerInfo}
              variant="ghost"
              size="sm"
            >
              <i className={`fas ${showCustomerInfo ? 'fa-eye-slash' : 'fa-info-circle'}`}></i>
            </Button>
          </div>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-6 space-y-4 bg-gray-50">
        {conversation.messages.length === 0 ? (
          <div className="text-center py-8">
            <i className="fas fa-comments text-3xl text-gray-300 mb-3"></i>
            <p className="text-gray-500">No messages yet. Start the conversation!</p>
          </div>
        ) : (
          <>
            {conversation.messages.map((message) => {
              const isAgent = message.senderType === "agent";
              const isSystem = message.senderType === "system";
              
              if (isSystem) {
                return (
                  <div key={message.id} className="flex justify-center">
                    <span className="inline-flex items-center px-3 py-1 rounded-full text-xs bg-gray-200 text-gray-600">
                      {message.content} • {formatDistanceToNow(new Date(message.createdAt), { addSuffix: true })}
                    </span>
                  </div>
                );
              }

              return (
                <div
                  key={message.id}
                  className={`flex items-start space-x-3 ${isAgent ? 'justify-end' : ''}`}
                >
                  {!isAgent && (
                    <div className="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center text-xs font-medium text-gray-700">
                      {conversation.customer.name.split(' ').map(n => n[0]).join('').toUpperCase()}
                    </div>
                  )}
                  
                  <div className={`flex-1 max-w-md ${isAgent ? 'order-first' : ''}`}>
                    <div className={`rounded-lg px-4 py-2 shadow-sm ${
                      isAgent 
                        ? 'bg-primary-500 text-white' 
                        : 'bg-white border border-gray-200'
                    }`}>
                      <p className={isAgent ? 'text-white' : 'text-gray-900'}>
                        {message.content}
                      </p>
                    </div>
                    <p className={`text-xs text-gray-500 mt-1 ${isAgent ? 'text-right' : ''}`}>
                      {formatDistanceToNow(new Date(message.createdAt), { addSuffix: true })}
                    </p>
                  </div>
                  
                  {isAgent && (
                    <div className="w-8 h-8 bg-primary-500 rounded-full flex items-center justify-center text-xs font-medium text-white">
                      {user?.firstName[0]}{user?.lastName[0]}
                    </div>
                  )}
                </div>
              );
            })}
            <div ref={messagesEndRef} />
          </>
        )}
      </div>

      {/* Message Input */}
      {canSendMessage ? (
        <div className="bg-white border-t border-gray-200 p-4">
          <div className="flex items-end space-x-4">
            <div className="flex-1">
              <div className="flex items-center space-x-2 mb-2">
                <Button variant="ghost" size="sm">
                  <i className="fas fa-paperclip"></i>
                </Button>
                <Button variant="ghost" size="sm">
                  <i className="fas fa-list"></i>
                </Button>
                <Button variant="ghost" size="sm">
                  <i className="fas fa-smile"></i>
                </Button>
              </div>
              <Textarea
                placeholder="Type your message... (Ctrl+Enter to send)"
                value={messageContent}
                onChange={(e) => setMessageContent(e.target.value)}
                onKeyDown={handleKeyDown}
                rows={2}
                className="resize-none"
              />
            </div>
            <Button
              onClick={handleSendMessage}
              disabled={!messageContent.trim() || sendMessageMutation.isPending}
            >
              <i className="fas fa-paper-plane mr-2"></i>
              Send
            </Button>
          </div>
        </div>
      ) : (
        <div className="bg-yellow-50 border-t border-yellow-200 p-4">
          <div className="flex items-center justify-center text-yellow-800">
            <i className="fas fa-lock mr-2"></i>
            <span>
              {conversation.status === "closed" 
                ? "This conversation is closed" 
                : "This conversation is not assigned to you"
              }
            </span>
          </div>
        </div>
      )}
    </div>
  );
}
