//Vehicle control flags

#define VEHICLE_CONTROL_PERMISSION (1<<0)
///controls the vehicles movement
#define VEHICLE_CONTROL_DRIVE (1<<1)
///Can't leave vehicle voluntarily, has to resist.
#define VEHICLE_CONTROL_KIDNAPPED (1<<2)

//vehicle control flags for operating a mecha

///melee attacks/shoves
#define VEHICLE_CONTROL_MECHAPUNCH (1<<3)
///using equipment/weapons
#define VEHICLE_CONTROL_EQUIPMENT (1<<4)
///using most of the mecha operation buttons like air supply, internal stats, etc.
#define VEHICLE_CONTROL_INTERNALS (1<<5)

///ez define for giving a single pilot mech all the flags it needs.
#define FULL_MECHA_CONTROL VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_PERMISSION|VEHICLE_CONTROL_INTERNALS|VEHICLE_CONTROL_MECHAPUNCH|VEHICLE_CONTROL_EQUIPMENT

//Ridden vehicle flags

/// Does our vehicle require arms to operate? Also used for piggybacking on humans to reserve arms on the rider
#define RIDER_NEEDS_ARMS   (1<<0)
// As above but only used for riding cyborgs, and only reserves 1 arm instead of 2
#define RIDER_NEEDS_ARM (1<<1)
/// Do we need legs to ride this (checks against TRAIT_FLOORED)
#define RIDER_NEEDS_LEGS   (1<<2)
/// If the rider is disabled or loses their needed limbs, do they fall off?
#define UNBUCKLE_DISABLED_RIDER (1<<3)
// For fireman carries, the carrying human needs an arm
#define CARRIER_NEEDS_ARM (1<<4)

//car_traits flags
///Will this car kidnap people by ramming into them?
#define CAN_KIDNAP (1<<0)

#define CLOWN_CANNON_INACTIVE 0
#define CLOWN_CANNON_BUSY 1
#define CLOWN_CANNON_READY 2
