// mouse signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of client/Click(): (atom/target, atom/location, control, params, mob/user)
#define COMSIG_CLIENT_CLICK "atom_client_click"
///from base of atom/Click(): (atom/location, control, params, mob/user)
#define COMSIG_CLICK "atom_click"
///from base of atom/ShiftClick(): (/mob)
#define COMSIG_CLICK_SHIFT "shift_click"
	#define COMPONENT_ALLOW_EXAMINATE (1<<0) //! Allows the user to examinate regardless of client.eye.
///from base of atom/ShiftClick()
#define COMSIG_SHIFT_CLICKED_ON "shift_clicked_on"
///from base of atom/CtrlClickOn(): (/mob)
#define COMSIG_CLICK_CTRL "ctrl_click"
///from base of atom/AltClick(): (/mob)
#define COMSIG_CLICK_ALT "alt_click"
///from base of atom/base_click_alt_secondary(): (/mob)
#define COMSIG_CLICK_ALT_SECONDARY "click_alt_secondary"
	#define COMPONENT_CANCEL_CLICK_ALT_SECONDARY (1<<0)
///from base of atom/CtrlShiftClick(/mob)
#define COMSIG_CLICK_CTRL_SHIFT "ctrl_shift_click"
///from base of atom/MouseDrop(): (/atom/over, /mob/user)
#define COMSIG_MOUSEDROP_ONTO "mousedrop_onto"
	#define COMPONENT_CANCEL_MOUSEDROP_ONTO (1<<0)
///from base of atom/handle_mouse_drop_receive: (/atom/from, /mob/user)
#define COMSIG_MOUSEDROPPED_ONTO "mousedropped_onto"
	#define COMPONENT_CANCEL_MOUSEDROPPED_ONTO (1<<0)
///from base of mob/MouseWheelOn(): (/atom, delta_x, delta_y, params)
#define COMSIG_MOUSE_SCROLL_ON "mousescroll_on"
/// From /atom/movable/screen/click(): (atom/target, atom/location, control, params, mob/user)
#define COMSIG_SCREEN_ELEMENT_CLICK "screen_element_click"
