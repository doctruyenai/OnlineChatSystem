import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent } from "@/components/ui/card";

interface WidgetConfig {
  position: string;
  primaryColor: string;
  size: string;
}

interface ChatWidgetProps {
  config: WidgetConfig;
}

export default function ChatWidget({ config }: ChatWidgetProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [showChat, setShowChat] = useState(false);
  const [formData, setFormData] = useState({
    name: "",
    phone: "",
    email: "",
    content: "",
  });
  const [messages, setMessages] = useState<Array<{ content: string; isOwn: boolean; time: string }>>([]);
  const [messageInput, setMessageInput] = useState("");

  const getPositionClasses = () => {
    const positions: Record<string, string> = {
      "bottom-right": "bottom-6 right-6",
      "bottom-left": "bottom-6 left-6",
      "top-right": "top-6 right-6",
      "top-left": "top-6 left-6",
    };
    return positions[config.position] || positions["bottom-right"];
  };

  const getSizeClasses = () => {
    const sizes: Record<string, { button: string; window: string }> = {
      small: { button: "w-12 h-12", window: "w-72 h-80" },
      medium: { button: "w-14 h-14", window: "w-80 h-96" },
      large: { button: "w-16 h-16", window: "w-96 h-[500px]" },
    };
    return sizes[config.size] || sizes.medium;
  };

  const handleFormSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Start chat with initial message
    if (formData.content) {
      setMessages([{
        content: formData.content,
        isOwn: true,
        time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
      }]);
      
      // Simulate agent response
      setTimeout(() => {
        setMessages(prev => [...prev, {
          content: "Hello! Thank you for contacting us. I'll be happy to help you with your inquiry.",
          isOwn: false,
          time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
        }]);
      }, 1000);
    }
    setShowChat(true);
  };

  const handleSendMessage = () => {
    if (!messageInput.trim()) return;
    
    setMessages(prev => [...prev, {
      content: messageInput,
      isOwn: true,
      time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    }]);
    
    setMessageInput("");
    
    // Simulate agent response
    setTimeout(() => {
      setMessages(prev => [...prev, {
        content: "Thank you for your message. Our team is reviewing your request and will respond shortly.",
        isOwn: false,
        time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
      }]);
    }, 1000);
  };

  const sizeClasses = getSizeClasses();

  return (
    <div className={`fixed z-50 ${getPositionClasses()}`}>
      {/* Widget Button */}
      {!isOpen && (
        <Button
          onClick={() => setIsOpen(true)}
          className={`${sizeClasses.button} rounded-full shadow-lg hover:scale-105 transition-all duration-200`}
          style={{ backgroundColor: config.primaryColor }}
        >
          <i className="fas fa-comments text-xl text-white"></i>
          {/* Notification badge */}
          <div className="absolute -top-2 -right-2 bg-red-500 text-white text-xs rounded-full w-6 h-6 flex items-center justify-center font-medium">
            1
          </div>
        </Button>
      )}

      {/* Widget Window */}
      {isOpen && (
        <Card className={`${sizeClasses.window} shadow-2xl border-0 overflow-hidden absolute ${
          config.position.includes('top') ? 'top-0' : 'bottom-16'
        } ${config.position.includes('left') ? 'left-0' : 'right-0'}`}>
          {/* Header */}
          <div 
            className="text-white p-4 flex items-center justify-between"
            style={{ backgroundColor: config.primaryColor }}
          >
            <div className="flex items-center space-x-3">
              <div className="w-8 h-8 bg-white bg-opacity-20 rounded-full flex items-center justify-center">
                <i className="fas fa-headset text-sm"></i>
              </div>
              <div>
                <h4 className="font-medium text-white">Customer Support</h4>
                <p className="text-xs text-white opacity-90">We're here to help!</p>
              </div>
            </div>
            <Button
              onClick={() => {
                setIsOpen(false);
                setShowChat(false);
                setMessages([]);
                setFormData({ name: "", phone: "", email: "", content: "" });
              }}
              variant="ghost"
              size="sm"
              className="text-white hover:bg-white hover:bg-opacity-20"
            >
              <i className="fas fa-times"></i>
            </Button>
          </div>

          <CardContent className="p-0 h-full flex flex-col">
            {!showChat ? (
              /* Welcome Form */
              <div className="p-4 flex flex-col h-full">
                <div className="mb-4">
                  <h5 className="font-medium text-gray-900 mb-2">Start a conversation</h5>
                  <p className="text-sm text-gray-600">
                    Please provide your information to get started.
                  </p>
                </div>

                <form onSubmit={handleFormSubmit} className="flex-1 flex flex-col space-y-3">
                  <Input
                    type="text"
                    placeholder="Full Name *"
                    required
                    value={formData.name}
                    onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                  />
                  <Input
                    type="tel"
                    placeholder="Phone Number *"
                    required
                    value={formData.phone}
                    onChange={(e) => setFormData(prev => ({ ...prev, phone: e.target.value }))}
                  />
                  <Input
                    type="email"
                    placeholder="Email Address"
                    value={formData.email}
                    onChange={(e) => setFormData(prev => ({ ...prev, email: e.target.value }))}
                  />
                  <Textarea
                    placeholder="How can we help you? *"
                    required
                    rows={3}
                    value={formData.content}
                    onChange={(e) => setFormData(prev => ({ ...prev, content: e.target.value }))}
                    className="resize-none"
                  />
                  
                  <Button
                    type="submit"
                    className="mt-auto"
                    style={{ backgroundColor: config.primaryColor }}
                  >
                    Start Chat
                  </Button>
                </form>

                <div className="mt-4 text-xs text-gray-500 text-center">
                  Powered by LiveChat System
                </div>
              </div>
            ) : (
              /* Chat Interface */
              <div className="flex flex-col h-full">
                {/* Messages */}
                <div className="flex-1 p-4 overflow-y-auto space-y-3">
                  {messages.map((message, index) => (
                    <div
                      key={index}
                      className={`flex ${message.isOwn ? 'justify-end' : 'items-start space-x-2'}`}
                    >
                      {!message.isOwn && (
                        <div className="w-6 h-6 bg-gray-300 rounded-full flex items-center justify-center text-xs">
                          A
                        </div>
                      )}
                      <div className={`max-w-xs ${message.isOwn ? '' : 'flex-1'}`}>
                        <div
                          className={`rounded-lg px-3 py-2 text-sm ${
                            message.isOwn
                              ? 'text-white'
                              : 'bg-gray-100 text-gray-900'
                          }`}
                          style={message.isOwn ? { backgroundColor: config.primaryColor } : {}}
                        >
                          {message.content}
                        </div>
                        <p className={`text-xs text-gray-500 mt-1 ${message.isOwn ? 'text-right' : ''}`}>
                          {message.time}
                        </p>
                      </div>
                    </div>
                  ))}
                </div>

                {/* Message Input */}
                <div className="border-t border-gray-200 p-3">
                  <div className="flex items-center space-x-2">
                    <Input
                      type="text"
                      placeholder="Type a message..."
                      value={messageInput}
                      onChange={(e) => setMessageInput(e.target.value)}
                      onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
                      className="flex-1"
                    />
                    <Button
                      onClick={handleSendMessage}
                      size="sm"
                      style={{ backgroundColor: config.primaryColor }}
                    >
                      <i className="fas fa-paper-plane text-sm"></i>
                    </Button>
                  </div>
                </div>
              </div>
            )}
          </CardContent>
        </Card>
      )}
    </div>
  );
}
