import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import ChatWidget from "@/components/widget/chat-widget";

export default function WidgetDemo() {
  const [widgetConfig, setWidgetConfig] = useState({
    position: "bottom-right",
    primaryColor: "#3B82F6",
    size: "medium",
  });

  const updateConfig = (key: string, value: string) => {
    setWidgetConfig(prev => ({ ...prev, [key]: value }));
  };

  const integrationCode = `<script>
  window.ChatWidgetConfig = {
    serverUrl: '${window.location.origin}',
    position: '${widgetConfig.position}',
    welcomeMessage: 'Hi! How can we help you today?',
    theme: {
      primaryColor: '${widgetConfig.primaryColor}',
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
<script src="${window.location.origin}/widget/chat-widget.js"></script>`;

  return (
    <div className="min-h-screen bg-gray-100 p-8">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Chat Widget Demo</h1>
          <p className="text-gray-600">
            Preview how the chat widget will appear on your website and customize its appearance.
          </p>
        </div>

        {/* Demo Website Container */}
        <Card className="mb-8">
          <CardContent className="p-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-4">Sample Website</h2>
            <p className="text-gray-600 mb-6">
              This demonstrates how the chat widget appears on any website. The widget is positioned 
              based on your configuration and can be customized to match your brand colors.
            </p>
            
            <div className="grid md:grid-cols-2 gap-8">
              <div>
                <h3 className="text-xl font-semibold text-gray-800 mb-3">Our Services</h3>
                <ul className="space-y-2 text-gray-600">
                  <li className="flex items-center">
                    <i className="fas fa-check text-green-500 mr-2"></i>
                    24/7 Customer Support
                  </li>
                  <li className="flex items-center">
                    <i className="fas fa-check text-green-500 mr-2"></i>
                    Real-time Chat Assistance
                  </li>
                  <li className="flex items-center">
                    <i className="fas fa-check text-green-500 mr-2"></i>
                    Technical Support
                  </li>
                  <li className="flex items-center">
                    <i className="fas fa-check text-green-500 mr-2"></i>
                    Product Consultation
                  </li>
                </ul>
              </div>
              <div>
                <img 
                  src="https://images.unsplash.com/photo-1560472354-b33ff0c44a43?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=800&h=400" 
                  alt="Modern office workspace" 
                  className="rounded-lg shadow-md w-full h-48 object-cover"
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Configuration Panel */}
        <Card className="mb-8">
          <CardHeader>
            <CardTitle>Widget Configuration</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid md:grid-cols-3 gap-6">
              <div>
                <Label htmlFor="position">Position</Label>
                <Select value={widgetConfig.position} onValueChange={(value) => updateConfig('position', value)}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="bottom-right">Bottom Right</SelectItem>
                    <SelectItem value="bottom-left">Bottom Left</SelectItem>
                    <SelectItem value="top-right">Top Right</SelectItem>
                    <SelectItem value="top-left">Top Left</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              
              <div>
                <Label htmlFor="primaryColor">Primary Color</Label>
                <div className="flex items-center space-x-2">
                  <Input
                    type="color"
                    value={widgetConfig.primaryColor}
                    onChange={(e) => updateConfig('primaryColor', e.target.value)}
                    className="w-16 h-10 p-1 border rounded"
                  />
                  <Input
                    type="text"
                    value={widgetConfig.primaryColor}
                    onChange={(e) => updateConfig('primaryColor', e.target.value)}
                    className="flex-1"
                  />
                </div>
              </div>
              
              <div>
                <Label htmlFor="size">Widget Size</Label>
                <Select value={widgetConfig.size} onValueChange={(value) => updateConfig('size', value)}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="small">Small</SelectItem>
                    <SelectItem value="medium">Medium</SelectItem>
                    <SelectItem value="large">Large</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Integration Code */}
        <Card>
          <CardHeader>
            <CardTitle>Integration Code</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="bg-gray-900 rounded-lg p-4 text-white overflow-x-auto">
              <pre className="text-sm">
                <code>{integrationCode}</code>
              </pre>
            </div>
            <div className="mt-4 flex justify-end">
              <Button 
                onClick={() => navigator.clipboard.writeText(integrationCode)}
                variant="outline"
              >
                <i className="fas fa-copy mr-2"></i>
                Copy Code
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* Chat Widget */}
        <ChatWidget config={widgetConfig} />
      </div>
    </div>
  );
}
