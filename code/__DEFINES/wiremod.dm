/// Helper define that can only be used in /obj/item/circuit_component/input_received()
#define COMPONENT_TRIGGERED_BY(trigger, port) (trigger.input_value && trigger == port)

/// Define to automatically handle calling the output port. Will not call the output port if the input_received proc returns TRUE.
#define TRIGGER_CIRCUIT_COMPONENT(component, port) if(!component.input_received(port) && (component.circuit_flags & CIRCUIT_FLAG_OUTPUT_SIGNAL)) component.trigger_output.set_output(COMPONENT_SIGNAL)

// Port types. Determines what the port can connect to

/// Can accept any datatype. Only works for inputs, output types will runtime.
#define PORT_TYPE_ANY null

// Fundamental datatypes
/// String datatype
#define PORT_TYPE_STRING "string"
#define PORT_MAX_STRING_LENGTH 500
/// Number datatype
#define PORT_TYPE_NUMBER "number"
/// Signal datatype
#define PORT_TYPE_SIGNAL "signal"
/// List datatype
#define PORT_TYPE_LIST "list"
/// Table datatype. Derivative of list, contains other lists with matching columns.
#define PORT_TYPE_TABLE "table"

// Other datatypes
/// Atom datatype
#define PORT_TYPE_ATOM "entity"
/// Any datatype (USED ONLY FOR DISPLAY, DO NOT USE)
#define COMP_TYPE_ANY "any"


/// The maximum range between a port and an atom
#define PORT_ATOM_MAX_RANGE 7

#define COMPONENT_DEFAULT_NAME "component"

/// The minimum position of the x and y co-ordinates of the component in the UI
#define COMPONENT_MIN_RANDOM_POS 200
/// The maximum position of the x and y co-ordinates of the component in the UI
#define COMPONENT_MAX_RANDOM_POS 400

/// The maximum position in both directions that a component can be in.
/// Prevents someone from positioning a component at an absurdly high value.
#define COMPONENT_MAX_POS 10000

// Components

/// The value that is sent whenever a component is simply sending a signal. This can be anything.
#define COMPONENT_SIGNAL 1

// Comparison defines
#define COMP_COMPARISON_EQUAL "="
#define COMP_COMPARISON_NOT_EQUAL "!="
#define COMP_COMPARISON_GREATER_THAN ">"
#define COMP_COMPARISON_LESS_THAN "<"
#define COMP_COMPARISON_GREATER_THAN_OR_EQUAL ">="
#define COMP_COMPARISON_LESS_THAN_OR_EQUAL "<="

// Delay defines
/// The minimum delay value that the delay component can have.
#define COMP_DELAY_MIN_VALUE 0.1

// Logic defines
#define COMP_LOGIC_AND "AND"
#define COMP_LOGIC_OR "OR"
#define COMP_LOGIC_XOR "XOR"

// Arithmetic defines
#define COMP_ARITHMETIC_ADD "Add"
#define COMP_ARITHMETIC_SUBTRACT "Subtract"
#define COMP_ARITHMETIC_MULTIPLY "Multiply"
#define COMP_ARITHMETIC_DIVIDE "Divide"
#define COMP_ARITHMETIC_MIN "Minimum"
#define COMP_ARITHMETIC_MAX "Maximum"

// Text defines
#define COMP_TEXT_LOWER "To Lower"
#define COMP_TEXT_UPPER "To Upper"

// Typecheck component
#define COMP_TYPECHECK_MOB "organism"
#define COMP_TYPECHECK_HUMAN "humanoid"

// Clock component
#define COMP_CLOCK_DELAY 0.9 SECONDS

// Radio component
#define COMP_RADIO_PUBLIC "public"
#define COMP_RADIO_PRIVATE "private"

// Sound component
#define COMP_SOUND_BUZZ "Buzz"
#define COMP_SOUND_BUZZ_TWO "Buzz Twice"
#define COMP_SOUND_CHIME "Chime"
#define COMP_SOUND_HONK "Honk"
#define COMP_SOUND_PING "Ping"
#define COMP_SOUND_SAD "Sad Trombone"
#define COMP_SOUND_WARN "Warn"
#define COMP_SOUND_SLOWCLAP "Slow Clap"

// Security Arrest Console
#define COMP_STATE_ARREST "*Arrest*"
#define COMP_STATE_PRISONER "Incarcerated"
#define COMP_STATE_PAROL "Paroled"
#define COMP_STATE_DISCHARGED "Discharged"
#define COMP_STATE_NONE "None"

#define COMP_SECURITY_ARREST_AMOUNT_TO_FLAG 10

// Shells

/// Whether a circuit is stuck on a shell and cannot be removed (by a user)
#define SHELL_FLAG_CIRCUIT_FIXED (1<<0)

/// Whether the shell needs to be anchored for the circuit to be on.
#define SHELL_FLAG_REQUIRE_ANCHOR (1<<1)

/// Whether or not the shell has a USB port.
#define SHELL_FLAG_USB_PORT (1<<2)

/// Whether the shell allows actions to be peformed on a shell if the action fails. This will additionally block the messages from being displayed.
#define SHELL_FLAG_ALLOW_FAILURE_ACTION (1<<3)

// Shell capacities. These can be converted to configs very easily later
#define SHELL_CAPACITY_SMALL 10
#define SHELL_CAPACITY_MEDIUM 25
#define SHELL_CAPACITY_LARGE 50
#define SHELL_CAPACITY_VERY_LARGE 500

/// The maximum range a USB cable can be apart from a source
#define USB_CABLE_MAX_RANGE 2

// Circuit flags
/// Creates an input trigger that means the component won't be triggered unless the trigger is pulsed.
#define CIRCUIT_FLAG_INPUT_SIGNAL (1<<0)
/// Creates an output trigger that sends a pulse whenever the component is successfully triggered
#define CIRCUIT_FLAG_OUTPUT_SIGNAL (1<<1)
