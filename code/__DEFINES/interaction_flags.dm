
#define INTERACT_ATOM_REQUIRES_ANCHORED 1		//whether can_interact() checks for anchored. only works on movables.
#define INTERACT_ATOM_ATTACK_HAND 2				//calls try_interact() on attack_hand() and returns that.
#define INTERACT_ATOM_UI_INTERACT 4				//automatically calls and returns ui_interact() on interact().
#define INTERACT_ATOM_REQUIRES_DEXTERITY 8		//user must be dextrous
#define INTERACT_ATOM_IGNORE_INCAPACITATED 16	//ignores incapacitated check
#define INTERACT_ATOM_IGNORE_RESTRAINED 32		//incapacitated check ignores restrained
#define INTERACT_ATOM_CHECK_GRAB 64				//incapacitated check checks grab
#define INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND 128//prevents leaving fingerprints automatically on attack_hand
#define INTERACT_ATOM_NO_FINGERPRINT_INTERACT 256	//adds hiddenprints instead of fingerprints on interact

#define INTERACT_ITEM_ATTACK_HAND_PICKUP 1		//attempt pickup on attack_hand for items

#define INTERACT_MACHINE_OPEN 1					//can_interact() while open
#define INTERACT_MACHINE_OFFLINE 2				//can_interact() while offline
#define INTERACT_MACHINE_WIRES_IF_OPEN 4		//try to interact with wires if open
#define INTERACT_MACHINE_ALLOW_SILICON 8		//let silicons interact
#define INTERACT_MACHINE_OPEN_SILICON 16		//let silicons interact while open
#define INTERACT_MACHINE_REQUIRES_SILICON 32		//must be silicon to interact
#define INTERACT_MACHINE_SET_MACHINE 64			//MACHINES HAVE THIS BY DEFAULT, SOMEONE SHOULD RUN THROUGH MACHINES AND REMOVE IT FROM THINGS LIKE LIGHT SWITCHES WHEN POSSIBLE!!--------------------------
												//This flag determines if a machine set_machine's the user when the user uses it, making updateUsrDialog make the user re-call interact() on it.
												//THIS FLAG IS ON ALL MACHINES BY DEFAULT, NEEDS TO BE RE-EVALUATED LATER!!
