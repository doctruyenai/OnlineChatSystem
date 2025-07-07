import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ConversationWithDetails } from "@shared/schema";
import { formatDistanceToNow } from "date-fns";

interface CustomerInfoPanelProps {
  conversation: ConversationWithDetails;
}

export default function CustomerInfoPanel({ conversation }: CustomerInfoPanelProps) {
  const customer = conversation.customer;
  const metadata = conversation.metadata as Record<string, any> || {};

  return (
    <div className="w-80 bg-white border-l border-gray-200 p-6 overflow-y-auto">
      <h3 className="text-lg font-semibold text-gray-900 mb-4">Customer Information</h3>
      
      {/* Customer Details */}
      <Card className="mb-6">
        <CardContent className="pt-6">
          <div className="text-center pb-4 border-b border-gray-200">
            <div className="w-16 h-16 bg-gray-300 rounded-full mx-auto mb-3 flex items-center justify-center text-lg font-medium text-gray-700">
              {customer.name.split(' ').map(n => n[0]).join('').toUpperCase()}
            </div>
            <h4 className="font-medium text-gray-900">{customer.name}</h4>
            <p className="text-sm text-gray-500">Customer</p>
          </div>

          <div className="space-y-3 mt-4">
            {customer.email && (
              <div>
                <label className="text-sm font-medium text-gray-700">Email</label>
                <p className="text-sm text-gray-900">{customer.email}</p>
              </div>
            )}
            
            {customer.phone && (
              <div>
                <label className="text-sm font-medium text-gray-700">Phone</label>
                <p className="text-sm text-gray-900">{customer.phone}</p>
              </div>
            )}
            
            <div>
              <label className="text-sm font-medium text-gray-700">Session ID</label>
              <p className="text-sm text-gray-900 font-mono break-all">{customer.sessionId}</p>
            </div>
            
            <div>
              <label className="text-sm font-medium text-gray-700">First Contact</label>
              <p className="text-sm text-gray-900">
                {formatDistanceToNow(new Date(customer.createdAt), { addSuffix: true })}
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Conversation Details */}
      <Card className="mb-6">
        <CardHeader>
          <CardTitle className="text-base">Conversation Details</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            <div>
              <label className="text-sm font-medium text-gray-700">Subject</label>
              <p className="text-sm text-gray-900">{conversation.subject || "No subject"}</p>
            </div>
            
            <div>
              <label className="text-sm font-medium text-gray-700">Status</label>
              <p className="text-sm text-gray-900 capitalize">{conversation.status}</p>
            </div>
            
            <div>
              <label className="text-sm font-medium text-gray-700">Priority</label>
              <p className="text-sm text-gray-900 capitalize">{conversation.priority}</p>
            </div>
            
            <div>
              <label className="text-sm font-medium text-gray-700">Started</label>
              <p className="text-sm text-gray-900">
                {formatDistanceToNow(new Date(conversation.createdAt), { addSuffix: true })}
              </p>
            </div>
            
            <div>
              <label className="text-sm font-medium text-gray-700">Last Update</label>
              <p className="text-sm text-gray-900">
                {formatDistanceToNow(new Date(conversation.updatedAt), { addSuffix: true })}
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Additional Information */}
      {Object.keys(metadata).length > 0 && (
        <Card className="mb-6">
          <CardHeader>
            <CardTitle className="text-base">Additional Information</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {Object.entries(metadata).map(([key, value]) => (
                <div key={key}>
                  <label className="text-sm font-medium text-gray-700 capitalize">
                    {key.replace(/([A-Z])/g, ' $1').toLowerCase()}
                  </label>
                  <p className="text-sm text-gray-900">{String(value)}</p>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Quick Actions */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">Quick Actions</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-2">
            <Button variant="outline" className="w-full justify-start">
              <i className="fas fa-history mr-2 text-gray-400"></i>
              View Chat History
            </Button>
            <Button variant="outline" className="w-full justify-start">
              <i className="fas fa-sticky-note mr-2 text-gray-400"></i>
              Add Note
            </Button>
            <Button variant="outline" className="w-full justify-start">
              <i className="fas fa-share mr-2 text-gray-400"></i>
              Transfer Chat
            </Button>
            <Button variant="outline" className="w-full justify-start">
              <i className="fas fa-ban mr-2 text-gray-400"></i>
              Block Customer
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
