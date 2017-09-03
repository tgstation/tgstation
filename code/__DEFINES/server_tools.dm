// /tg/station 13 server tools API v3.0

//Required interfaces:

//#error /tg/station server tools interface defines missing
#define SERVER_TOOLS_INSTALLATION_PATH "code/modules/server_tools"	//path from the .dmb of your project to the `server_tools` folder. No leading `/`
#define SERVER_TOOLS_DEFINE_AND_SET_GLOBAL(Name, Value) GLOBAL_VAR_INIT(##Name, ##Value); GLOBAL_PROTECT(##Name) //create a global variable named `Name` and set it to `Value`
#define SERVER_TOOLS_READ_GLOBAL(Name) GLOB.##Name //Read the value in the global variable `Name`
#define SERVER_TOOLS_WRITE_GLOBAL(Name, Value) GLOB.##Name = ##Value //Set the value in the global variable `Name` to `Value`
#define SERVER_TOOLS_WORLD_ANNOUNCE(message) to_chat(world, "<span class='boldannounce'>[html_encode(##message)]</span>")	//display an announcement `message` from the server to all players
#define SERVER_TOOLS_LOG(message) log_world("SERVICE: [##message]")	//Write a `message` to a server log
#define SERVER_TOOLS_NOTIFY_ADMINS(event) message_admins(##event)	//Notify current in-game administrators of an `event`

//Required hooks:

//Put this somewhere in /world/New() that is always run
#define SERVER_TOOLS_ON_NEW ListServiceCustomCommands(TRUE)
//Put this somewhere in /world/Topic(T, Addr, Master, Keys) that is always run before T is modified
#define SERVER_TOOLS_ON_TOPIC var/service_topic_return = ServiceCommand(params2list(T)); if(service_topic_return) return service_topic_return
//Put at the beginning of world/Reboot(reason)
#define SERVER_TOOLS_ON_REBOOT ServiceReboot()


//Optional functions:

//Returns TRUE if the world was launched under the server tools, FALSE otherwise
//No other function in this list will suceed if this is FALSE
#define SERVER_TOOLS_PRESENT (world.RunningService() != null)
//Gets the current version of the server tools, only supported in versions >= 3.0.91.0
#define SERVER_TOOLS_VERSION world.ServiceVersion()
//Forces a hard reboot of BYOND by ending the process
#define SERVER_TOOLS_REBOOT_BYOND world.ServiceEndProcess()
/*
	Gets the list of any testmerged github pull requests

	"[PR Number]" => list(
		"title" -> PR title
		"commit" -> Full hash of commit merged
		"author" -> Github username of the author of the PR
	)
*/
#define SERVER_TOOLS_PR_LIST GetTestMerges()
//Sends a message to connected game chats
#define SERVER_TOOLS_CHAT_BROADCAST(message) world.ChatBroadcast(message)
//Sends a message to connected admin chats
#define SERVER_TOOLS_RELAY_BROADCAST(message) world.AdminBroadcast(message)


//Implementation defines

#define REBOOT_MODE_NORMAL 0
#define REBOOT_MODE_HARD 1
#define REBOOT_MODE_SHUTDOWN 2

//keep these in sync with TGS3
#define SERVICE_WORLD_PARAM "server_service"
#define SERVICE_VERSION_PARAM "server_service_version"
#define SERVICE_PR_TEST_JSON "prtestjob.json"
#define SERVICE_PR_TEST_JSON_OLD "..\\..\\[SERVICE_PR_TEST_JSON]"

#define SERVICE_CMD_HARD_REBOOT "hard_reboot"
#define SERVICE_CMD_GRACEFUL_SHUTDOWN "graceful_shutdown"
#define SERVICE_CMD_WORLD_ANNOUNCE "world_announce"
#define SERVICE_CMD_LIST_CUSTOM "list_custom_commands"

#define SERVICE_CMD_PARAM_KEY "serviceCommsKey"
#define SERVICE_CMD_PARAM_COMMAND "command"
#define SERVICE_CMD_PARAM_SENDER "sender"
#define SERVICE_CMD_PARAM_CUSTOM "custom"

#define SERVICE_JSON_PARAM_HELPTEXT "help_text"
#define SERVICE_JSON_PARAM_ADMINONLY "admin_only"
#define SERVICE_JSON_PARAM_REQUIREDPARAMETERS "required_parameters"

#define SERVICE_REQUEST_KILL_PROCESS "killme"
#define SERVICE_REQUEST_IRC_BROADCAST "irc"
#define SERVICE_REQUEST_IRC_ADMIN_CHANNEL_MESSAGE "send2irc"
#define SERVICE_REQUEST_WORLD_REBOOT "worldreboot"
