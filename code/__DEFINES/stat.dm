/*
	Used with the various stat variables (mob, machines)
*/

//mob/var/stat things
#define CONSCIOUS	0
#define SOFT_CRIT	1	
#define UNCONSCIOUS	2
#define DEAD		3

//mob disabilities stat

#define BLIND 		1
#define MUTE		2
#define DEAF		4
#define NEARSIGHT	8
#define FAT			32
#define HUSK		64
#define NOCLONE		128
#define CLUMSY		256

// bitflags for machine stat variable
#define BROKEN		1
#define NOPOWER		2
#define MAINT		4			// under maintaince
#define EMPED		8		// temporary broken by EMP pulse

//ai power requirement defines
#define POWER_REQ_NONE 0
#define POWER_REQ_ALL 1
#define POWER_REQ_CLOCKCULT 2
