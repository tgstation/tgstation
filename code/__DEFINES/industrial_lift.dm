//Booleans in arguments are confusing, so I made them defines.
///the lift's controls are currently locked from user input
#define LIFT_PLATFORM_LOCKED 1
///the lift's controls are currently unlocked so user's can direct it
#define LIFT_PLATFORM_UNLOCKED 0

//lift_id's
///basic lift_id, goes up and down
#define BASIC_LIFT_ID "base"
///tram lift_id, goes left and right or north and south. maybe one day be able to turn and go up/down as well
#define TRAM_LIFT_ID "tram"
///debug lift_id
#define DEBUG_LIFT_ID "debug"


//specific_lift_id's
///the specific_lift_id of the main station tram landmark for tramstation that spawns roundstart.
#define MAIN_STATION_TRAM "main station tram"
///the specific_lift_id of the tram on the hilbert research station
#define HILBERT_TRAM "tram_hilbert"

// Defines for update_lift_doors
#define OPEN_DOORS "open"
#define CLOSE_DOORS "close"
#define LOCK_DOORS "lock"
#define UNLOCK_DOORS "unlock"

// Defines for the state of tram destination signs
#define DESTINATION_WEST_ACTIVE "west_active"
#define DESTINATION_WEST_IDLE "west_idle"
#define DESTINATION_CENTRAL_EASTBOUND_ACTIVE "central_eb_active"
#define DESTINATION_CENTRAL_WESTBOUND_ACTIVE "central_wb_active"
#define DESTINATION_CENTRAL_IDLE "central_idle"
#define DESTINATION_EAST_ACTIVE "east_active"
#define DESTINATION_EAST_IDLE "east_idle"
#define DESTINATION_NOT_IN_SERVICE "NIS"
