import { useState } from "react";
import { useAuth } from "@/hooks/use-auth";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Switch } from "@/components/ui/switch";
import { User } from "@shared/schema";
import { Link, useLocation } from "wouter";
import { MessageCircle, Settings, LogOut, BarChart3 } from "lucide-react";

interface SidebarProps {
  user: User;
  isConnected: boolean;
}

function NavigationMenu({ user }: { user: User }) {
  const [location] = useLocation();

  const menuItems = [
    { 
      path: "/", 
      label: "Conversations", 
      icon: MessageCircle, 
      count: 3 
    },
    { 
      path: "/widget-config", 
      label: "Widget Config", 
      icon: Settings 
    },
    { 
      path: "/analytics", 
      label: "Analytics", 
      icon: BarChart3 
    },
  ];

  return (
    <ul className="space-y-2">
      {menuItems.map((item) => {
        const isActive = location === item.path;
        const IconComponent = item.icon;
        
        return (
          <li key={item.path}>
            <Link 
              href={item.path}
              className={`flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-colors ${
                isActive 
                  ? 'bg-primary-50 text-primary-700' 
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`}
            >
              <IconComponent className="mr-3 h-4 w-4" />
              {item.label}
              {item.count && (
                <span className="ml-auto bg-primary-100 text-primary-800 text-xs px-2 py-1 rounded-full">
                  {item.count}
                </span>
              )}
            </Link>
          </li>
        );
      })}
    </ul>
  );
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
        <NavigationMenu user={user} />
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
