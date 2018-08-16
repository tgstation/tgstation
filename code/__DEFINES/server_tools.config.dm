#define SERVER_TOOLS_EXTERNAL_CONFIGURATION
#define SERVER_TOOLS_DEFINE_AND_SET_GLOBAL(Name, Value) GLOBAL_VAR_INIT(##Name, ##Value); GLOBAL_PROTECT(##Name)
#define SERVER_TOOLS_READ_GLOBAL(Name) GLOB.##Name
#define SERVER_TOOLS_WRITE_GLOBAL(Name, Value) GLOB.##Name = ##Value
#define SERVER_TOOLS_WORLD_ANNOUNCE(message) to_chat(world, "<span class='boldannounce'>[html_encode(##message)]</span>")
#define SERVER_TOOLS_LOG(message) log_world("SERVICE: [##message]")
#define SERVER_TOOLS_NOTIFY_ADMINS(event) message_admins(##event)
#define SERVER_TOOLS_CLIENT_COUNT GLOB.clients.len
