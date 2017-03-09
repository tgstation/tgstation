// Where we got the name of the identity from for voiceprints and faceprints
// IDENTITY_STATES
#define IDENTITY_MANUAL		1 // Manually set name
#define IDENTITY_INTERACT	2 // Examined or otherwise interacted with the mob
#define IDENTITY_SEEN		3 // Saw the mob
#define IDENTITY_HEARD		4 // Heard the mob without seeing them

// Timestamp expiry times
#define IDENTITY_EXPIRE_TIME 500
#define TEMP_IDENTITY_EXPIRE 50

// Magic string used for messages
#define IDENTITY_SUBJECT(id) "<@Iden[id]/@"

#define CATEGORY_VOICEPRINTS	1
#define CATEGORY_FACEPRINTS		2

// List lengths
#define VOICEPRINTS_LIST_LENGTH	6
#define FACEPRINTS_LIST_LENGTH	4
#define IDENTITY_CACHE_LENGTH	6
#define IDENTITY_TAGS_LENGTH	2

// List structure for mind.voiceprints and mind.faceprints, IDENTITY_PRINT defines are shared between them
#define IDENTITY_PRINT_STATE		1 // This is one of the four IDENTITY_STATES
#define IDENTITY_PRINT_TIMESTAMP	2 // Timestamp when the entry was updated
#define IDENTITY_PRINT_NAME			3 // The name itself
#define IDENTITY_PRINT_LINKED		4 // The print of the other type it is linked to, if any 
// ||||||||||||||||||||||||||||||||||
#define IDENTITY_VOICEPRINT_MSG		5 // Last message heard, voiceprints only
#define IDENTITY_VOICEPRINT_EDIT	6 // Edit ref for clicking and editing in chat, voiceprints only

// This is for the identity cache which stores the voiceprints or faceprints recently used by a person, as well as a 5 second temporary identity if there are none
#define IDENTITY_CACHE_VOICEPRINT		1
#define IDENTITY_CACHE_VOICEPRINT_TIME	2
#define IDENTITY_CACHE_FACEPRINT		3
#define IDENTITY_CACHE_FACEPRINT_TIME	4
#define IDENTITY_CACHE_TEMP				5
#define IDENTITY_CACHE_TEMP_TIME		6

// This is for the edit tag refs so that way we never send the actual voiceprint to clients
#define IDENTITY_EDIT_TAG_PRINT		1 // The voiceprint itself
#define IDENTITY_EDIT_TAG_TIMESTAMP	2 // The time it was last updated, expires in IDENTITY_EXPIRE_TIME

// Identity manager modes
#define IDMAN_MODE_EDIT 1
#define IDMAN_MODE_LINK 2
