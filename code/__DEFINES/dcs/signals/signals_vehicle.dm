/// Called on a mob when they start riding a vehicle (obj/vehicle)
#define COMSIG_VEHICLE_RIDDEN "vehicle-ridden"
	/// Return this to signal that the mob should be removed from the vehicle
	#define EJECT_FROM_VEHICLE (1<<0)

/// called on the vehicle when an occupant is added, (occupant, driver_flags)
#define COMSIG_VEHICLE_OCCUPANT_ADDED "vehicleoccupantadd"
/// called on the vehicle when an occupant is removed, (former_occupant, former_flags)
#define COMSIG_VEHICLE_OCCUPANT_REMOVED "vehicleoccupantremoved"
