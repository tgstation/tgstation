#define SEND_ICTS_SIGNAL(sigtype, arguments...) ( SEND_SIGNAL(SSicts_transport, sigtype, ##arguments) )

// ICTS Signals
#define COMSIG_ICTS_REQUEST "!REQ"

#define COMSIG_ICTS_RESPONSE "!RESP"
#define REQUEST_FAIL "!FAIL"
#define REQUEST_SUCCESS "!ACK"
#define COMSIG_ICTS_TRANSPORT_ACTIVE "!ACTV"
#define COMSIG_ICTS_DESTINATION "!DEST"

// ICTS Codes
#define NOT_IN_SERVICE "!NIS"
#define TRANSPORT_IN_USE "!BUSY"
#define INVALID_PLATFORM "!NDEST"
#define PLATFORM_DISABLED "!DIS"
#define NO_CALL_REQUIRED "!NCR"
#define INTERNAL_ERROR "!ERR"

/// ICTS Tram lines
#define TRAMSTATION_LINE_1 "tram_1"
#define HILBERT_LINE_1 "hilb_1"
#define BIRDSHOT_LINE_1 "bird_1"
#define BIRDSHOT_LINE_2 "bird_2"

#define PLATFORM_ACTIVE 1

// Flags for the ICTS Tram VOBC (vehicle on-board computer)

#define SYSTEM_FAULT (1<<0)
#define COMM_ERROR (1<<1)
#define EMERGENCY_STOP (1<<2)
#define PRE_DEPARTURE (1<<3)
#define DOORS_OPEN (1<<4)
#define CONTROLS_LOCKED (1<<5)

DEFINE_BITFIELD(controller_status, list(
	"SYSTEM_FAULT" = SYSTEM_FAULT,
	"COMM_ERROR" = COMM_ERROR,
	"EMERGENCY_STOP" = EMERGENCY_STOP,
	"PRE_DEPARTURE" = PRE_DEPARTURE,
	"DOORS_OPEN" = DOORS_OPEN,
	"CONTROLS_LOCKED" = CONTROLS_LOCKED,
))

#define RAPID_MODE (1<<0)
#define BYPASS_SENSORS (1<<1)
DEFINE_BITFIELD(request_flags, list(
	"RAPID_MODE" = RAPID_MODE,
	"BYPASS_SENSORS" = BYPASS_SENSORS,
))

#define ICTS_TYPE_ELEVATOR "icts_elev"
#define ICTS_TYPE_TRAM "icts_tram"

