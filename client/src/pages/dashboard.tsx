import { useState } from "react";
import { useAuth } from "@/hooks/use-auth";
import { useSocket } from "@/hooks/use-socket";
import Sidebar from "@/components/chat/sidebar";
import ConversationList from "@/components/chat/conversation-list";
import ChatInterface from "@/components/chat/chat-interface";
import CustomerInfoPanel from "@/components/chat/customer-info-panel";
import { ConversationWithDetails } from "@shared/schema";

export default function Dashboard() {
  const { user } = useAuth();
  const { isConnected } = useSocket();
  const [selectedConversation, setSelectedConversation] = useState<ConversationWithDetails | null>(null);
  const [showCustomerInfo, setShowCustomerInfo] = useState(true);

  if (!user) {
    return null; // Will be handled by ProtectedRoute
  }

  return (
    <div className="flex h-screen bg-gray-100">
      {/* Sidebar */}
      <Sidebar user={user} isConnected={isConnected} />

      {/* Main Content */}
      <div className="flex-1 flex">
        {/* Conversation List */}
        <ConversationList 
          selectedConversation={selectedConversation}
          onSelectConversation={setSelectedConversation}
        />

        {/* Chat Interface */}
        <div className="flex-1 flex flex-col">
          {selectedConversation ? (
            <ChatInterface 
              conversation={selectedConversation}
              onToggleCustomerInfo={() => setShowCustomerInfo(!showCustomerInfo)}
              showCustomerInfo={showCustomerInfo}
            />
          ) : (
            <div className="flex-1 flex items-center justify-center bg-gray-50">
              <div className="text-center">
                <div className="w-24 h-24 mx-auto mb-4 bg-gray-200 rounded-full flex items-center justify-center">
                  <i className="fas fa-comments text-2xl text-gray-400"></i>
                </div>
                <h3 className="text-lg font-medium text-gray-900 mb-2">No conversation selected</h3>
                <p className="text-gray-500">Choose a conversation from the list to start chatting</p>
              </div>
            </div>
          )}
        </div>

        {/* Customer Info Panel */}
        {selectedConversation && showCustomerInfo && (
          <CustomerInfoPanel conversation={selectedConversation} />
        )}
      </div>
    </div>
  );
}
