//Vehicle control flags

#define VEHICLE_CONTROL_PERMISSION 1
#define VEHICLE_CONTROL_DRIVE 2
#define VEHICLE_CONTROL_KIDNAPPED 4 //Can't leave vehicle voluntarily, has to resist.

//Ridden vehcile flags

#define REQUIRES_ARMS 1    //Does our vehicle require hands to drive?
#define REQUIRES_LEGS  2    //Does our vehicle require legs to drive?
#define DISABLED_RIDER_UNBUCKLE 3   //If our rider is disabled, does he fall off?

//Car trait flags
#define CAN_KIDNAP 1
