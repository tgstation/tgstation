#define SEND_TRANSPORT_SIGNAL(sigtype, arguments...) ( SEND_SIGNAL(SStransport, sigtype, ##arguments) )

// Transport Directions
#define INBOUND -1
#define OUTBOUND 1

// Transport Signals
#define COMSIG_TRANSPORT_REQUEST "!REQ"
#define COMSIG_TRANSPORT_RESPONSE "!RESP"
#define REQUEST_FAIL "!FAIL"
#define REQUEST_SUCCESS "!ACK"
#define COMSIG_TRANSPORT_ACTIVE "!ACTV"
#define COMSIG_TRANSPORT_DESTINATION "!DEST"
#define COMSIG_TRANSPORT_LIGHTS "!LITE"
#define COMSIG_COMMS_STATUS "!COMM"

// Codes
#define NOT_IN_SERVICE "!NIS"
#define TRANSPORT_IN_USE "!BUSY"
#define INVALID_PLATFORM "!NDEST"
#define PLATFORM_DISABLED "!DIS"
#define NO_CALL_REQUIRED "!NCR"
#define INTERNAL_ERROR "!ERR"

/// Tram Lines
#define TRAMSTATION_LINE_1 "tram_1"
#define HILBERT_LINE_1 "hilb_1"
#define BIRDSHOT_LINE_1 "bird_1"
#define BIRDSHOT_LINE_2 "bird_2"

/// Navigation Aids
#define TRAM_NAV_BEACONS "tram_nav"
#define IMMOVABLE_ROD_DESTINATIONS "immovable_rod"

/// Elevator IDs
#define ELEVATOR_1 "elev_1"
#define ELEVATOR_2 "elev_2"
#define ELEVATOR_3 "elev_3"
#define ELEVATOR_4 "elev_4"
#define ELEVATOR_5 "elev_5"
#define ELEVATOR_6 "elev_6"
#define ELEVATOR_7 "elev_7"
#define ELEVATOR_8 "elev_8"

#define PLATFORM_ACTIVE 1

// Flags for the Tram VOBC (vehicle on-board computer)

#define SYSTEM_FAULT (1<<0)
#define COMM_ERROR (1<<1)
#define EMERGENCY_STOP (1<<2)
#define PRE_DEPARTURE (1<<3)
#define DOORS_OPEN (1<<4)
#define CONTROLS_LOCKED (1<<5)
#define BYPASS_SENSORS (1<<6)
#define RAPID_MODE (1<<7)
#define MANUAL_MODE (1<<8)

DEFINE_BITFIELD(controller_status, list(
	"SYSTEM_FAULT" = SYSTEM_FAULT,
	"COMM_ERROR" = COMM_ERROR,
	"EMERGENCY_STOP" = EMERGENCY_STOP,
	"PRE_DEPARTURE" = PRE_DEPARTURE,
	"DOORS_OPEN" = DOORS_OPEN,
	"CONTROLS_LOCKED" = CONTROLS_LOCKED,
	"BYPASS_SENSORS" = BYPASS_SENSORS,
	"MANUAL_MODE" = MANUAL_MODE,
))

#define TRANSPORT_FLAGS list( \
	"SYSTEM_FAULT", \
	"COMM_ERROR", \
	"EMERGENCY_STOP", \
	"PRE_DEPARTURE", \
	"DOORS_OPEN", \
	"CONTROLS_LOCKED", \
	"BYPASS_SENSORS", \
	"MANUAL_MODE", \
)

/// Logging
#define SUB_TS_STATUS "TS-[english_list(bitfield_to_list(transport_controller.controller_status, TRANSPORT_FLAGS))]"
#define TC_TS_STATUS "TS-[english_list(bitfield_to_list(controller_status, TRANSPORT_FLAGS))]"
#define TC_TA_INFO "TA-[transport_controller.controller_active ? "PROCESSING" : "READY"]"

DEFINE_BITFIELD(request_flags, list(
	"RAPID_MODE" = RAPID_MODE,
	"BYPASS_SENSORS" = BYPASS_SENSORS,
))

#define TRANSPORT_TYPE_ELEVATOR "icts_elev"
#define TRANSPORT_TYPE_TRAM "icts_tram"

/// Tram crossing light logic
#define XING_STATE_GREEN 0
#define XING_STATE_AMBER 1
#define XING_STATE_RED 2
#define XING_STATE_MALF 3

// Defines for door cycles
#define CYCLE_OPEN "open"
#define CYCLE_CLOSED "close"

#define AMBER_THRESHOLD_NORMAL 70
#define RED_THRESHOLD_NORMAL 40
#define AMBER_THRESHOLD_DEGRADED 40
#define RED_THRESHOLD_DEGRADED 20

#define DEFAULT_TRAM_LENGTH 10

#define TRANSPORT_SYSTEM_NORMAL 0
#define TRANSPORT_REMOTE_WARNING 1
#define TRANSPORT_LOCAL_WARNING 2
#define TRANSPORT_REMOTE_FAULT 3
#define TRANSPORT_LOCAL_FAULT 4
#define TRANSPORT_BREAKDOWN_RATE 0.0175

/// Tram destinations/platforms
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
