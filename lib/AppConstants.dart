/*class PlatformChannelNames {
  static const String APP_USAGE_CHANNEL = "com.quarantinegames.pictionary/app_usage_channel";
  static const String COMMON_CHANNEL = "com.quarantinegames.pictionary/common_channel";
}*/
const String APP_VERSION = "1.0";
const String BASE_IP = "quarantinegames.in";//"quarantinegames.in";//"192.168.18.17";
const String PORT = "80";//"3000";
const String BASE_URL = "http://$BASE_IP:$PORT"; //For Http
const String WS_BASE_URL = "ws://$BASE_IP:$PORT"; //For websockets

class Routes {
  static const String LOGIN = "/";
  static const String DASHBOARD = "/dashboard";
}