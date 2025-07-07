import { useState } from "react";
import { useAuth } from "@/hooks/use-auth";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Switch } from "@/components/ui/switch";
import { User } from "@shared/schema";

interface SidebarProps {
  user: User;
  isConnected: boolean;
}

export default function Sidebar({ user, isConnected }: SidebarProps) {
  const { logoutMutation } = useAuth();
  const [isOnline, setIsOnline] = useState(user.isOnline);

  const handleStatusToggle = (checked: boolean) => {
    setIsOnline(checked);
    // TODO: Update agent status via WebSocket
  };

  const handleLogout = () => {
    logoutMutation.mutate();
  };

  return (
    <div className="w-64 bg-white shadow-lg border-r border-gray-200 flex flex-col">
      {/* Agent Info */}
      <div className="p-4 border-b border-gray-200">
        <div className="flex items-center space-x-3">
          <div className="relative">
            <div className="w-10 h-10 bg-primary-500 rounded-full flex items-center justify-center text-white font-medium">
              {user.firstName[0]}{user.lastName[0]}
            </div>
            <div className={`absolute -bottom-1 -right-1 w-3 h-3 rounded-full border-2 border-white ${
              isConnected && isOnline ? 'bg-green-500' : 'bg-gray-400'
            }`}></div>
          </div>
          <div>
            <p className="font-medium text-gray-900">{user.firstName} {user.lastName}</p>
            <p className={`text-sm flex items-center ${
              isConnected && isOnline ? 'text-green-600' : 'text-gray-500'
            }`}>
              <span className={`w-2 h-2 rounded-full mr-2 ${
                isConnected && isOnline ? 'bg-green-500 animate-pulse' : 'bg-gray-400'
              }`}></span>
              {isConnected && isOnline ? 'Online' : 'Offline'}
            </p>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="p-4 flex-1">
        <ul className="space-y-2">
          <li>
            <a href="#" className="flex items-center px-3 py-2 text-sm font-medium bg-primary-50 text-primary-700 rounded-lg">
              <i className="fas fa-comments mr-3"></i>
              Conversations
              <span className="ml-auto bg-primary-100 text-primary-800 text-xs px-2 py-1 rounded-full">
                3
              </span>
            </a>
          </li>
          <li>
            <a href="#" className="flex items-center px-3 py-2 text-sm font-medium text-gray-600 hover:bg-gray-50 hover:text-gray-900 rounded-lg">
              <i className="fas fa-chart-bar mr-3"></i>
              Analytics
            </a>
          </li>
          <li>
            <a href="#" className="flex items-center px-3 py-2 text-sm font-medium text-gray-600 hover:bg-gray-50 hover:text-gray-900 rounded-lg">
              <i className="fas fa-cog mr-3"></i>
              Settings
            </a>
          </li>
        </ul>
      </nav>

      {/* Status Toggle & Logout */}
      <div className="p-4 space-y-4 border-t border-gray-200">
        <Card>
          <CardContent className="p-3">
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium text-gray-700">Status</span>
              <Switch
                checked={isOnline}
                onCheckedChange={handleStatusToggle}
                disabled={!isConnected}
              />
            </div>
          </CardContent>
        </Card>

        <Button
          onClick={handleLogout}
          variant="outline"
          className="w-full"
          disabled={logoutMutation.isPending}
        >
          <i className="fas fa-sign-out-alt mr-2"></i>
          {logoutMutation.isPending ? "Signing out..." : "Sign Out"}
        </Button>
      </div>
    </div>
  );
}
