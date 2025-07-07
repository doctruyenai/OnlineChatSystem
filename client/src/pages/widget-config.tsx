import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { Switch } from "@/components/ui/switch";
import { Copy, Eye, Settings, Code } from "lucide-react";
import { useToast } from "@/hooks/use-toast";

const widgetConfigSchema = z.object({
  domain: z.string().min(1, "Domain is required"),
  title: z.string().min(1, "Title is required"),
  subtitle: z.string().optional(),
  primaryColor: z.string().min(1, "Primary color is required"),
  position: z.enum(["bottom-right", "bottom-left", "top-right", "top-left"]),
  welcomeMessage: z.string().optional(),
  offlineMessage: z.string().optional(),
  showAgentPhotos: z.boolean(),
  allowFileUpload: z.boolean(),
  collectUserInfo: z.boolean(),
  requiredFields: z.array(z.string()).optional(),
});

type WidgetConfig = z.infer<typeof widgetConfigSchema>;

export default function WidgetConfig() {
  const { toast } = useToast();
  const [previewMode, setPreviewMode] = useState(false);
  
  const form = useForm<WidgetConfig>({
    resolver: zodResolver(widgetConfigSchema),
    defaultValues: {
      domain: "",
      title: "Chat Support",
      subtitle: "We're here to help",
      primaryColor: "#3b82f6",
      position: "bottom-right",
      welcomeMessage: "Xin chào! Chúng tôi có thể giúp gì cho bạn?",
      offlineMessage: "Hiện tại chúng tôi đang offline. Vui lòng để lại tin nhắn.",
      showAgentPhotos: true,
      allowFileUpload: true,
      collectUserInfo: true,
      requiredFields: ["name", "email"],
    },
  });

  const watchedValues = form.watch();

  const generateEmbedCode = () => {
    const config = form.getValues();
    const embedCode = `<!-- Chat Widget by Live Chat System -->
<script>
  window.LiveChatConfig = {
    domain: "${config.domain}",
    title: "${config.title}",
    subtitle: "${config.subtitle}",
    primaryColor: "${config.primaryColor}",
    position: "${config.position}",
    welcomeMessage: "${config.welcomeMessage}",
    offlineMessage: "${config.offlineMessage}",
    showAgentPhotos: ${config.showAgentPhotos},
    allowFileUpload: ${config.allowFileUpload},
    collectUserInfo: ${config.collectUserInfo},
    requiredFields: ${JSON.stringify(config.requiredFields)}
  };
</script>
<script src="${window.location.origin}/widget.js"></script>
<link rel="stylesheet" href="${window.location.origin}/widget.css">`;
    
    return embedCode;
  };

  const copyEmbedCode = () => {
    navigator.clipboard.writeText(generateEmbedCode());
    toast({
      title: "Đã sao chép!",
      description: "Mã nhúng đã được sao chép vào clipboard.",
    });
  };

  const onSubmit = (data: WidgetConfig) => {
    console.log("Widget config:", data);
    toast({
      title: "Đã lưu cấu hình!",
      description: "Cấu hình widget đã được lưu thành công.",
    });
  };

  return (
    <div className="container mx-auto p-6 max-w-6xl">
      <div className="mb-8">
        <h1 className="text-3xl font-bold mb-2">Cấu hình Chat Widget</h1>
        <p className="text-gray-600">Tùy chỉnh widget chat để tích hợp vào website của bạn</p>
      </div>

      <Tabs defaultValue="config" className="w-full">
        <TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="config" className="flex items-center gap-2">
            <Settings className="h-4 w-4" />
            Cấu hình
          </TabsTrigger>
          <TabsTrigger value="preview" className="flex items-center gap-2">
            <Eye className="h-4 w-4" />
            Xem trước
          </TabsTrigger>
          <TabsTrigger value="embed" className="flex items-center gap-2">
            <Code className="h-4 w-4" />
            Mã nhúng
          </TabsTrigger>
        </TabsList>

        <TabsContent value="config">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <Card>
              <CardHeader>
                <CardTitle>Thông tin cơ bản</CardTitle>
                <CardDescription>Cấu hình thông tin hiển thị của widget</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="domain">Domain website</Label>
                  <Input
                    id="domain"
                    placeholder="example.com"
                    {...form.register("domain")}
                  />
                  {form.formState.errors.domain && (
                    <p className="text-sm text-red-600">{form.formState.errors.domain.message}</p>
                  )}
                </div>

                <div className="space-y-2">
                  <Label htmlFor="title">Tiêu đề</Label>
                  <Input
                    id="title"
                    placeholder="Chat Support"
                    {...form.register("title")}
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="subtitle">Phụ đề</Label>
                  <Input
                    id="subtitle"
                    placeholder="We're here to help"
                    {...form.register("subtitle")}
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="primaryColor">Màu chủ đạo</Label>
                  <div className="flex gap-2">
                    <Input
                      id="primaryColor"
                      type="color"
                      className="w-16 h-10"
                      {...form.register("primaryColor")}
                    />
                    <Input
                      placeholder="#3b82f6"
                      {...form.register("primaryColor")}
                    />
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Vị trí và tin nhắn</CardTitle>
                <CardDescription>Tùy chỉnh vị trí hiển thị và tin nhắn</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="position">Vị trí hiển thị</Label>
                  <Select value={watchedValues.position} onValueChange={(value) => form.setValue("position", value as any)}>
                    <SelectTrigger>
                      <SelectValue placeholder="Chọn vị trí" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="bottom-right">Góc dưới phải</SelectItem>
                      <SelectItem value="bottom-left">Góc dưới trái</SelectItem>
                      <SelectItem value="top-right">Góc trên phải</SelectItem>
                      <SelectItem value="top-left">Góc trên trái</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="welcomeMessage">Tin nhắn chào mừng</Label>
                  <Textarea
                    id="welcomeMessage"
                    placeholder="Xin chào! Chúng tôi có thể giúp gì cho bạn?"
                    {...form.register("welcomeMessage")}
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="offlineMessage">Tin nhắn khi offline</Label>
                  <Textarea
                    id="offlineMessage"
                    placeholder="Hiện tại chúng tôi đang offline..."
                    {...form.register("offlineMessage")}
                  />
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Tùy chọn nâng cao</CardTitle>
                <CardDescription>Các tính năng bổ sung cho widget</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex items-center justify-between">
                  <div className="space-y-0.5">
                    <Label>Hiển thị ảnh đại diện agent</Label>
                    <p className="text-sm text-gray-600">Cho phép khách hàng thấy ảnh đại diện của agent</p>
                  </div>
                  <Switch
                    checked={watchedValues.showAgentPhotos}
                    onCheckedChange={(checked) => form.setValue("showAgentPhotos", checked)}
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div className="space-y-0.5">
                    <Label>Cho phép tải file</Label>
                    <p className="text-sm text-gray-600">Khách hàng có thể gửi file đính kèm</p>
                  </div>
                  <Switch
                    checked={watchedValues.allowFileUpload}
                    onCheckedChange={(checked) => form.setValue("allowFileUpload", checked)}
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div className="space-y-0.5">
                    <Label>Thu thập thông tin khách hàng</Label>
                    <p className="text-sm text-gray-600">Yêu cầu khách hàng cung cấp thông tin trước khi chat</p>
                  </div>
                  <Switch
                    checked={watchedValues.collectUserInfo}
                    onCheckedChange={(checked) => form.setValue("collectUserInfo", checked)}
                  />
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Lưu cấu hình</CardTitle>
                <CardDescription>Áp dụng cấu hình cho widget</CardDescription>
              </CardHeader>
              <CardContent>
                <Button onClick={form.handleSubmit(onSubmit)} className="w-full">
                  Lưu cấu hình
                </Button>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="preview">
          <Card>
            <CardHeader>
              <CardTitle>Xem trước Widget</CardTitle>
              <CardDescription>Xem trước giao diện widget với cấu hình hiện tại</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="relative bg-gray-100 rounded-lg p-8 min-h-96">
                <div className="text-center text-gray-500 mb-4">
                  Website của bạn
                </div>
                
                {/* Widget Preview */}
                <div 
                  className={`fixed z-50 ${
                    watchedValues.position === "bottom-right" ? "bottom-4 right-4" :
                    watchedValues.position === "bottom-left" ? "bottom-4 left-4" :
                    watchedValues.position === "top-right" ? "top-4 right-4" :
                    "top-4 left-4"
                  }`}
                >
                  <div className="bg-white rounded-lg shadow-lg border w-80 h-96">
                    <div 
                      className="p-4 rounded-t-lg text-white"
                      style={{ backgroundColor: watchedValues.primaryColor }}
                    >
                      <h3 className="font-semibold">{watchedValues.title}</h3>
                      <p className="text-sm opacity-90">{watchedValues.subtitle}</p>
                    </div>
                    <div className="p-4 flex-1">
                      <div className="bg-gray-50 rounded-lg p-3 mb-3">
                        <p className="text-sm">{watchedValues.welcomeMessage}</p>
                      </div>
                      <div className="text-center text-gray-500 text-sm">
                        Widget preview
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="embed">
          <Card>
            <CardHeader>
              <CardTitle>Mã nhúng Widget</CardTitle>
              <CardDescription>Sao chép mã này và dán vào website của bạn</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="relative">
                  <pre className="bg-gray-100 p-4 rounded-lg text-sm overflow-x-auto">
                    <code>{generateEmbedCode()}</code>
                  </pre>
                  <Button
                    size="sm"
                    className="absolute top-2 right-2"
                    onClick={copyEmbedCode}
                  >
                    <Copy className="h-4 w-4" />
                  </Button>
                </div>
                
                <div className="bg-blue-50 p-4 rounded-lg">
                  <h4 className="font-semibold mb-2">Hướng dẫn tích hợp:</h4>
                  <ol className="list-decimal list-inside space-y-1 text-sm">
                    <li>Sao chép mã nhúng ở trên</li>
                    <li>Dán mã vào trước thẻ <code>&lt;/body&gt;</code> trong HTML của website</li>
                    <li>Widget sẽ tự động hiển thị theo cấu hình đã thiết lập</li>
                    <li>Khách hàng có thể bắt đầu chat ngay lập tức</li>
                  </ol>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}