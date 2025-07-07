import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { ConversationWithDetails } from "@shared/schema";
import { formatDistanceToNow } from "date-fns";

interface ConversationListProps {
  selectedConversation: ConversationWithDetails | null;
  onSelectConversation: (conversation: ConversationWithDetails) => void;
}

export default function ConversationList({ selectedConversation, onSelectConversation }: ConversationListProps) {
  const [searchTerm, setSearchTerm] = useState("");

  const { data: conversations = [], isLoading } = useQuery<ConversationWithDetails[]>({
    queryKey: ["/api/conversations"],
    refetchInterval: 5000, // Refetch every 5 seconds
  });

  const filteredConversations = conversations.filter(conv =>
    conv.customer.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    conv.subject?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    conv.customer.email?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const getStatusBadge = (status: string, priority: string) => {
    const statusConfig = {
      waiting: { label: "Waiting", variant: "destructive" as const },
      active: { label: "Active", variant: "default" as const },
      resolved: { label: "Resolved", variant: "secondary" as const },
      closed: { label: "Closed", variant: "outline" as const },
    };

    const priorityConfig = {
      urgent: { label: "Urgent", variant: "destructive" as const },
      high: { label: "High", variant: "default" as const },
      normal: { label: "Normal", variant: "secondary" as const },
      low: { label: "Low", variant: "outline" as const },
    };

    return {
      status: statusConfig[status as keyof typeof statusConfig] || statusConfig.waiting,
      priority: priorityConfig[priority as keyof typeof priorityConfig] || priorityConfig.normal,
    };
  };

  const getLastMessage = (conversation: ConversationWithDetails) => {
    const messages = conversation.messages;
    if (messages.length === 0) return null;
    return messages[messages.length - 1];
  };

  if (isLoading) {
    return (
      <div className="w-80 bg-white border-r border-gray-200 flex items-center justify-center">
        <div className="text-center">
          <i className="fas fa-spinner fa-spin text-2xl text-gray-400 mb-2"></i>
          <p className="text-gray-500">Loading conversations...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="w-80 bg-white border-r border-gray-200 flex flex-col">
      {/* Header */}
      <div className="p-4 border-b border-gray-200">
        <h2 className="text-lg font-semibold text-gray-900 mb-3">Active Conversations</h2>
        <div className="relative">
          <Input
            type="text"
            placeholder="Search conversations..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="pl-10"
          />
          <i className="fas fa-search absolute left-3 top-3 text-gray-400"></i>
        </div>
      </div>

      {/* Conversation List */}
      <div className="flex-1 overflow-y-auto">
        {filteredConversations.length === 0 ? (
          <div className="p-8 text-center">
            <i className="fas fa-inbox text-3xl text-gray-300 mb-3"></i>
            <p className="text-gray-500">
              {searchTerm ? "No conversations match your search" : "No active conversations"}
            </p>
          </div>
        ) : (
          filteredConversations.map((conversation) => {
            const lastMessage = getLastMessage(conversation);
            const badges = getStatusBadge(conversation.status, conversation.priority);
            const isSelected = selectedConversation?.id === conversation.id;
            
            return (
              <div
                key={conversation.id}
                className={`p-4 border-b border-gray-100 cursor-pointer transition-colors ${
                  isSelected ? "bg-primary-50 border-primary-200" : "hover:bg-gray-50"
                }`}
                onClick={() => onSelectConversation(conversation)}
              >
                <div className="flex items-start space-x-3">
                  <div className="relative">
                    <div className="w-10 h-10 bg-gray-300 rounded-full flex items-center justify-center text-sm font-medium text-gray-700">
                      {conversation.customer.name.split(' ').map(n => n[0]).join('').toUpperCase()}
                    </div>
                    {conversation.status === "waiting" && (
                      <div className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full border-2 border-white"></div>
                    )}
                  </div>
                  
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between mb-1">
                      <p className="text-sm font-medium text-gray-900 truncate">
                        {conversation.customer.name}
                      </p>
                      <span className="text-xs text-gray-500">
                        {lastMessage ? formatDistanceToNow(new Date(lastMessage.createdAt), { addSuffix: true }) : ''}
                      </span>
                    </div>
                    
                    <p className="text-sm text-gray-600 truncate mb-2">
                      {lastMessage?.content || conversation.subject || "No messages yet"}
                    </p>
                    
                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-2">
                        <Badge variant={badges.status.variant} className="text-xs">
                          {badges.status.label}
                        </Badge>
                        {conversation.priority !== "normal" && (
                          <Badge variant={badges.priority.variant} className="text-xs">
                            {badges.priority.label}
                          </Badge>
                        )}
                      </div>
                      
                      {conversation.customer.phone && (
                        <span className="text-xs text-gray-500">
                          <i className="fas fa-phone mr-1"></i>
                          {conversation.customer.phone}
                        </span>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
}
