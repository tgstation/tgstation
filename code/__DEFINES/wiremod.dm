// Port types. Determines what the port can connect to

/// Can accept any datatype. Only works for inputs, output types will runtime.
#define PORT_TYPE_ANY null

// Fundamental datatypes
/// String datatype
#define PORT_TYPE_STRING "string"
#define MAX_STRING_LENGTH 500
/// Number datatype
#define PORT_TYPE_NUMBER "number"
/// List datatype
#define PORT_TYPE_LIST "list"

// Other datatypes
/// Mob datatype
#define PORT_TYPE_MOB "mob"

/// The minimum position of the x and y co-ordinates of the component in the UI
#define COMPONENT_MIN_RANDOM_POS 200
/// The maximum position of the x and y co-ordinates of the component in the UI
#define COMPONENT_MAX_RANDOM_POS 400

/// The maximum position in both directions that a component can be in.
/// Prevents someone from positioning a component at an absurdly high value.
#define COMPONENT_MAX_POS 2000

// Components

// Comparison defines
#define COMPARISON_EQUAL "="
#define COMPARISON_NOT_EQUAL "!="
#define COMPARISON_GREATER_THAN ">"
#define COMPARISON_LESS_THAN "<"
#define COMPARISON_GREATER_THAN_OR_EQUAL ">="
#define COMPARISON_LESS_THAN_OR_EQUAL "<="
