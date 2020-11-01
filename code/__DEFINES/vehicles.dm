//Vehicle control flags

#define VEHICLE_CONTROL_PERMISSION 1
#define VEHICLE_CONTROL_DRIVE 2
#define VEHICLE_CONTROL_KIDNAPPED 4 //Can't leave vehicle voluntarily, has to resist.

//Ridden vehicle flags

#define REQUIRES_ARMS   (1<<0)    //Does our vehicle require hands to drive?
#define REQUIRES_LEGS   (1<<1)    //Does our vehicle require legs to drive?
#define UNBUCKLE_DISABLED_RIDER (1<<2)   //If our rider is disabled, does he fall off?

//Car trait flags
#define CAN_KIDNAP 1


// riding datum defines

/// The carried person is incapacitated or was otherwise prone, carrier needs 1 free hand
#define RIDDEN_HOLDING_RIDER	(1<<0)
/// The carried person is holding onto the carrier, carried person needs 2 free hands
#define RIDER_HOLDING_ON		(1<<1)
