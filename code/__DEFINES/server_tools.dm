#define REBOOT_MODE_NORMAL 0
#define REBOOT_MODE_HARD 1
#define REBOOT_MODE_SHUTDOWN 2

#define IRC_STATUS_THROTTLE 50

#define SERVICE_TRANSACTION_TIMEOUT 100 //10s

//keep these in sync with TGS3
#define SERVICE_WORLD_PARAM "server_service"
#define SERVICE_PR_TEST_JSON "..\\..\\prtestjob.json"

#define SERVICE_CMD_HARD_REBOOT "hard_reboot"
#define SERVICE_CMD_GRACEFUL_SHUTDOWN "graceful_shutdown"
#define SERVICE_CMD_WORLD_ANNOUNCE "world_announce"
#define SERVICE_CMD_IRC_CHECK "irc_check"
#define SERVICE_CMD_IRC_STATUS "irc_status"
#define SERVICE_CMD_ADMIN_MSG "adminmsg"
#define SERVICE_CMD_NAME_CHECK "namecheck"
#define SERVICE_CMD_ADMIN_WHO "adminwho"
#define SERVICE_CMD_TRANSACTION_CALLBACK "transactioncallback"

//#define SERVICE_CMD_PARAM_KEY //defined in __compile_options.dm
#define SERVICE_CMD_PARAM_COMMAND "command"
#define SERVICE_CMD_PARAM_MESSAGE "message"
#define SERVICE_CMD_PARAM_TARGET "target"
#define SERVICE_CMD_PARAM_SENDER "sender"
#define SERVICE_CMD_PARAM_TRANSACTION_ID "transaction_id"

#define SERVICE_REQUEST_KILL_PROCESS "killme"
#define SERVICE_REQUEST_IRC_BROADCAST "irc"
#define SERVICE_REQUEST_IRC_ADMIN_CHANNEL_MESSAGE "send2irc"
#define SERVICE_REQUEST_GITHUB_CREATE_ISSUE "issuecreate"
#define SERVICE_REQUEST_GITHUB_CREATE_COMMENT "issuepost"

#define SERVICE_TRANSACTION_PARAM_GHI_REPOID "repoid"
#define SERVICE_TRANSACTION_PARAM_GHI_TITLE "issuetitle"
#define SERVICE_TRANSACTION_PARAM_GHI_ID "issuenumber"
#define SERVICE_TRANSACTION_PARAM_GHI_BODY "issuebody"
#define SERVICE_TRANSACTION_PARAM_GHI_URL "issueurl"
