/*class PlatformChannelNames {
  static const String APP_USAGE_CHANNEL = "com.quarantinegames.pictionary/app_usage_channel";
  static const String COMMON_CHANNEL = "com.quarantinegames.pictionary/common_channel";
}*/
const String APP_VERSION = "1.0";
const String BASE_IP = "192.168.18.17";
const String BASE_URL = "http://$BASE_IP:3000"; //For Http
const String WS_BASE_URL = "ws://$BASE_IP:3000"; //For websockets

class Routes {
  static const String LOGIN = "/";
  static const String DASHBOARD = "/dashboard";
}