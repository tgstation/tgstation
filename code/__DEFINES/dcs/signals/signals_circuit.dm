// Circuit signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// Component signals
/// Sent when the value of a port is set.
#define COMSIG_PORT_SET_VALUE "port_set_value"
/// Sent when the type of a port is set.
#define COMSIG_PORT_SET_TYPE "port_set_type"
/// Sent when a port disconnects from everything.
#define COMSIG_PORT_DISCONNECT "port_disconnect"

/// Sent when a [/obj/item/circuit_component] is added to a circuit.
#define COMSIG_CIRCUIT_ADD_COMPONENT "circuit_add_component"
	/// Cancels adding the component to the circuit.
	#define COMPONENT_CANCEL_ADD_COMPONENT (1<<0)

/// Sent when a [/obj/item/circuit_component] is added to a circuit manually, by putting the item inside directly.
/// Accepts COMPONENT_CANCEL_ADD_COMPONENT.
#define COMSIG_CIRCUIT_ADD_COMPONENT_MANUALLY "circuit_add_component_manually"

/// Sent when a circuit is removed from its shell
#define COMSIG_CIRCUIT_SHELL_REMOVED "circuit_shell_removed"

/// Send to [/obj/item/circuit_component] when it is added to a circuit. (/obj/item/integrated_circuit)
#define COMSIG_CIRCUIT_COMPONENT_ADDED "circuit_component_added"

/// Sent to [/obj/item/circuit_component] when it is removed from a circuit. (/obj/item/integrated_circuit)
#define COMSIG_CIRCUIT_COMPONENT_REMOVED "circuit_component_removed"

/// Called when the integrated circuit's cell is set.
#define COMSIG_CIRCUIT_SET_CELL "circuit_set_cell"

/// Called when the integrated circuit is turned on or off.
#define COMSIG_CIRCUIT_SET_ON "circuit_set_on"

/// Called when the integrated circuit's shell is set.
#define COMSIG_CIRCUIT_SET_SHELL "circuit_set_shell"

/// Called when the integrated circuit is locked.
#define COMSIG_CIRCUIT_SET_LOCKED "circuit_set_locked"

/// Called before power is used in an integrated circuit (power_to_use)
#define COMSIG_CIRCUIT_PRE_POWER_USAGE "circuit_pre_power_usage"
	#define COMPONENT_OVERRIDE_POWER_USAGE (1<<0)

/// Called right before the integrated circuit data is converted to json. Allows modification to the data right before it is returned.
#define COMSIG_CIRCUIT_PRE_SAVE_TO_JSON "circuit_pre_save_to_json"

/// Called when the integrated circuit is loaded.
#define COMSIG_CIRCUIT_POST_LOAD "circuit_post_load"

/// Sent to an atom when a [/obj/item/usb_cable] attempts to connect to something. (/obj/item/usb_cable/usb_cable, /mob/user)
#define COMSIG_ATOM_USB_CABLE_TRY_ATTACH "usb_cable_try_attach"
	/// Attaches the USB cable to the atom. If the USB cables moves away, it will disconnect.
	#define COMSIG_USB_CABLE_ATTACHED (1<<0)

	/// Attaches the USB cable to a circuit. Producers of this are expected to set the usb_cable's
	/// `attached_circuit` variable.
	#define COMSIG_USB_CABLE_CONNECTED_TO_CIRCUIT (1<<1)

	/// Cancels the attack chain, but without performing any other action.
	#define COMSIG_CANCEL_USB_CABLE_ATTACK (1<<2)

/// Called when the circuit component is saved.
#define COMSIG_CIRCUIT_COMPONENT_SAVE "circuit_component_save"

/// Called when circuit component data should be saved
#define COMSIG_CIRCUIT_COMPONENT_SAVE_DATA "circuit_component_save_data"
/// Called when circuit component data should be loaded
#define COMSIG_CIRCUIT_COMPONENT_LOAD_DATA "circuit_component_load_data"

/// Called when an external object is loaded.
#define COMSIG_MOVABLE_CIRCUIT_LOADED "movable_circuit_loaded"

/// Called when a ui action is sent for the circuit component
#define COMSIG_CIRCUIT_COMPONENT_PERFORM_ACTION "circuit_component_perform_action"

///Called when an Ntnet sender is sending Ntnet data
#define COMSIG_GLOB_CIRCUIT_NTNET_DATA_SENT "!circuit_ntnet_data_sent"

/// Called when an equipment action component is added to a shell (/obj/item/circuit_component/equipment_action/action_comp)
#define COMSIG_CIRCUIT_ACTION_COMPONENT_REGISTERED "circuit_action_component_registered"

/// Called when an equipment action component is removed from a shell (/obj/item/circuit_component/equipment_action/action_comp)
#define COMSIG_CIRCUIT_ACTION_COMPONENT_UNREGISTERED "circuit_action_component_unregistered"

/// Called when an NFC sender sends data to this circuit
#define COMSIG_CIRCUIT_NFC_DATA_SENT "circuit_nfc_data_receive"

///Sent to the shell component when a circuit is attached.
#define COMSIG_SHELL_CIRCUIT_ATTACHED "shell_circuit_attached"
///Sent to the shell component when a circuit is removed.
#define COMSIG_SHELL_CIRCUIT_REMOVED "shell_circuit_removed"
