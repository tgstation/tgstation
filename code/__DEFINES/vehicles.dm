//Vehicle control flags

#define VEHICLE_CONTROL_PERMISSION 1
#define VEHICLE_CONTROL_DRIVE 2
#define VEHICLE_CONTROL_KIDNAPPED 4 //Can't leave vehicle voluntarily, has to resist.

//Mech flags
#define ADDING_ACCESS_POSSIBLE	(1<<0)
#define ADDING_MAINT_ACCESS_POSSIBLE	(1<<1)
#define CANSTRAFE	(1<<2)
#define LIGHTS_ON	(1<<3)
#define SILICON_PILOT	(1<<4)
#define IS_ENCLOSED	(1<<5)
#define HAS_LIGHTS	(1<<6)


//Car trait flags
#define CAN_KIDNAP 1
