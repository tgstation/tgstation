// channel numbers for power
#define EQUIP			1
#define LIGHT			2
#define ENVIRON			3
#define TOTAL			4	//for total power used only
#define STATIC_EQUIP 	5
#define STATIC_LIGHT	6
#define STATIC_ENVIRON	7


//bitflags for door switches.
#define OPEN	1
#define IDSCAN	2
#define BOLTS	4
#define SHOCK	8
#define SAFE	16

//used in design to specify which machine can build it
#define	IMPRINTER	1	//For circuits. Uses glass/chemicals.
#define PROTOLATHE	2	//New stuff. Uses glass/metal/chemicals
#define	AUTOLATHE	4	//Uses glass/metal only.
#define CRAFTLATHE	8	//Uses fuck if I know. For use eventually.
#define MECHFAB		16 //Remember, objects utilising this flag should have construction_time and construction_cost vars.
//Note: More then one of these can be added to a design but imprinter and lathe designs are incompatable.

//used to define machine behaviour in attackbys and other code situations
#define REPLACEPARTS	1 //can we use a part replacer on it?
#define SCREWTOGGLE		2 //does it toggle panel_open when hit by a screwdriver?
#define CROWDESTROY		4 //does hitting a panel_open machine with a crowbar disassemble it?
#define WRENCHMOVE		8 //does hitting it with a wrench toggle its anchored state?
#define FIXED2WORK		16 //does it need to be anchored to work? Try to use this with WRENCHMOVE - hooks into power code
#define DELNOTEJECT		32 //when we destroy the machine, does it remove all its items or destroy them?
#define WELD_FIXED		64 //if it is attacked by a welder and is anchored, it'll toggle between welded and unwelded to the floor
#define MULTITOOL_MENU	128 //if it has multitool menu functionality inherently
#define EMAGGABLE		256 //if it can be emagged, calling emag_act()
#define CROWPRY			512 //does hitting a panel_closed machine with a crowbar pry it open?
#define WRENCHROTATE	1024 //If it can be rotated with a wrench


// multitool_topic() shit
#define MT_ERROR  -1
#define MT_UPDATE 1
#define MT_REINIT 2