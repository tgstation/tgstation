#define PORT_INPUT_RECEIVE_DELAY 0.2 SECONDS

/// Helper define that can only be used in /obj/item/circuit_component/input_received()
#define COMPONENT_TRIGGERED_BY(trigger, port) (trigger.input_value && trigger == port)

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

// Other datatypes
/// Atom datatype
#define PORT_TYPE_ATOM "entity"

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

// Shells

/// Whether a circuit is stuck on a shell and cannot be removed (by a user)
#define SHELL_FLAG_CIRCUIT_FIXED (1<<0)

/// Whether the shell needs to be anchored for the circuit to be on.
#define SHELL_FLAG_REQUIRE_ANCHOR (1<<1)

// Shell capacities. These can be converted to configs very easily later
#define SHELL_CAPACITY_SMALL 10
#define SHELL_CAPACITY_MEDIUM 25
#define SHELL_CAPACITY_LARGE 50
#define SHELL_CAPACITY_VERY_LARGE 500
