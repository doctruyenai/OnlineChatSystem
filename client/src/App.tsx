import { Switch, Route } from "wouter";
import { queryClient } from "./lib/queryClient";
import { QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import { AuthProvider } from "./hooks/use-auth";
import { SocketProvider } from "./hooks/use-socket";
import { ProtectedRoute } from "./lib/protected-route";
import Dashboard from "@/pages/dashboard";
import AuthPage from "@/pages/auth-page";
import WidgetDemo from "@/pages/widget-demo";
import WidgetConfig from "@/pages/widget-config";
import NotFound from "@/pages/not-found";

function Router() {
  return (
    <Switch>
      <ProtectedRoute path="/" component={() => <Dashboard />} />
      <Route path="/auth" component={() => <AuthPage />} />
      <Route path="/widget-demo" component={() => <WidgetDemo />} />
      <ProtectedRoute path="/widget-config" component={() => <WidgetConfig />} />
      <Route component={() => <NotFound />} />
    </Switch>
  );
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <SocketProvider>
          <TooltipProvider>
            <Toaster />
            <Router />
          </TooltipProvider>
        </SocketProvider>
      </AuthProvider>
    </QueryClientProvider>
  );
}

export default App;
