#define MIDNIGHT_ROLLOVER		864000	//number of deciseconds in a day

//Security levels
#define SEC_LEVEL_GREEN	0
#define SEC_LEVEL_BLUE	1
#define SEC_LEVEL_RED	2
#define SEC_LEVEL_DELTA	3

//some arbitrary defines to be used by self-pruning global lists. (see master_controller)
#define PROCESS_KILL 26	//Used to trigger removal from a processing list

#define MANIFEST_ERROR_NAME		1
#define MANIFEST_ERROR_COUNT	2
#define MANIFEST_ERROR_ITEM		4

#define TRANSITIONEDGE			7 //Distance from edge to move to another z-level
