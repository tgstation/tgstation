#define SEND_TRANSPORT_SIGNAL(sigtype, arguments...) ( SEND_SIGNAL(SStransport, sigtype, ##arguments) )

// Transport directions
#define INBOUND -1
#define OUTBOUND 1

// Status response codes
#define REQUEST_FAIL "!FAIL"
#define REQUEST_SUCCESS "!ACK"
#define NOT_IN_SERVICE "!NIS"
#define TRANSPORT_IN_USE "!BUSY"
#define INVALID_PLATFORM "!NDEST"
#define NO_CALL_REQUIRED "!NCR"
#define INTERNAL_ERROR "!ERR"
#define BROKEN_BEYOND_REPAIR "!DEAD"

// Tram lines
#define TRAMSTATION_LINE_1 "tram_1"
#define HILBERT_LINE_1 "hilb_1"
#define BIRDSHOT_LINE_1 "bird_1"
#define BIRDSHOT_LINE_2 "bird_2"

// Destinations/platforms
#define TRAMSTATION_WEST 1
#define TRAMSTATION_CENTRAL 2
#define TRAMSTATION_EAST 3

#define HILBERT_PORT 1
#define HILBERT_CENTRAL 2
#define HILBERT_STARBOARD 3

#define BIRDSHOT_PRISON_WING 1
#define BIRDSHOT_SECURITY_WING 2

#define BIRDSHOT_MAINTENANCE_LEFT 1
#define BRIDSHOT_MAINTENANCE_RIGHT 2

// Tram Navigation aids
#define TRAM_NAV_BEACONS "tram_nav"
#define IMMOVABLE_ROD_DESTINATIONS "immovable_rod"

// The lift's controls are currently locked from user input
#define LIFT_PLATFORM_LOCKED 1
// The lift's controls are currently unlocked so user's can direct it
#define LIFT_PLATFORM_UNLOCKED 0

// Flags for the Tram VOBC (vehicle on-board computer)
#define SYSTEM_FAULT (1<<0)
#define COMM_ERROR (1<<1)
#define EMERGENCY_STOP (1<<2)
#define PRE_DEPARTURE (1<<3)
#define DOORS_READY (1<<4)
#define CONTROLS_LOCKED (1<<5)
#define BYPASS_SENSORS (1<<6)
#define RAPID_MODE (1<<7)

DEFINE_BITFIELD(controller_status, list(
	"SYSTEM_FAULT" = SYSTEM_FAULT,
	"COMM_ERROR" = COMM_ERROR,
	"EMERGENCY_STOP" = EMERGENCY_STOP,
	"PRE_DEPARTURE" = PRE_DEPARTURE,
	"DOORS_READY" = DOORS_READY,
	"CONTROLS_LOCKED" = CONTROLS_LOCKED,
	"BYPASS_SENSORS" = BYPASS_SENSORS,
))

#define TRANSPORT_FLAGS list( \
	"SYSTEM_FAULT", \
	"COMM_ERROR", \
	"EMERGENCY_STOP", \
	"PRE_DEPARTURE", \
	"DOORS_READY", \
	"CONTROLS_LOCKED", \
	"BYPASS_SENSORS", \
)

DEFINE_BITFIELD(request_flags, list(
	"RAPID_MODE" = RAPID_MODE,
	"BYPASS_SENSORS" = BYPASS_SENSORS,
))

// Logging
#define SUB_TS_STATUS "TS-[english_list(bitfield_to_list(transport_controller.controller_status, TRANSPORT_FLAGS))]"
#define TC_TS_STATUS "TS-[english_list(bitfield_to_list(controller_status, TRANSPORT_FLAGS))]"
#define TC_TA_INFO "TA-[transport_controller.controller_active ? "PROCESSING" : "READY"]"

// Landmarks
#define TRANSPORT_TYPE_ELEVATOR "icts_elev"
#define TRANSPORT_TYPE_TRAM "icts_tram"
#define TRANSPORT_TYPE_DEBUG "icts_debug"

// Tram door cycles
#define CYCLE_OPEN "open"
#define CYCLE_CLOSED "close"

// Crossing signals
#define XING_STATE_GREEN 0
#define XING_STATE_AMBER 1
#define XING_STATE_RED 2
#define XING_STATE_MALF 3

#define XING_THRESHOLD_AMBER 45
#define XING_THRESHOLD_RED 27

#define DEFAULT_TRAM_LENGTH 10
#define DEFAULT_TRAM_MIDPOINT 5

// Tram machinery subtype
#define TRANSPORT_SYSTEM_NORMAL 0
#define TRANSPORT_REMOTE_WARNING 1
#define TRANSPORT_LOCAL_WARNING 2
#define TRANSPORT_REMOTE_FAULT 3
#define TRANSPORT_LOCAL_FAULT 4
#define TRANSPORT_BREAKDOWN_RATE 0.0175
