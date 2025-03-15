#define WAND_OPEN "open"
#define WAND_BOLT "bolt"
#define WAND_EMERGENCY "emergency"
#define WAND_HANDLE_REQUESTS "requests"
#define WAND_SHOCK "shock door"
#define WAND_HANDLE_CONFIG "config"

// For responses to remote requests
#define REMOTE_RESPONSE_APPROVE "Open requested doors"
#define REMOTE_RESPONSE_DENY "Deny selected requests"
#define REMOTE_RESPONSE_BOLT "Bolt doors, Block requesting IDs"
#define REMOTE_RESPONSE_BLOCK "Block requesting IDs"
#define REMOTE_RESPONSE_EA "Set emergency access on requested"
#define REMOTE_RESPONSE_SHOCK "##ERROR## CAUTION: SERVICE REMOT##ERROR##"

/* Snowflake antipattern define so we can have a static set of images for remote responses
 * instead of regenerating them every time someone handles requests
*/
#define REQUEST_RESPONSES "handle requests"
#define EXPIRED_REQUEST "expired request"
