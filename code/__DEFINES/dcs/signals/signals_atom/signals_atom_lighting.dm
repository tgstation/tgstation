// Atom lighting signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// Lighting:
///from base of [atom/proc/set_light]: (l_range, l_power, l_color, l_on)
#define COMSIG_ATOM_SET_LIGHT "atom_set_light"
	/// Blocks [/atom/proc/set_light], [/atom/proc/set_light_power], [/atom/proc/set_light_range], [/atom/proc/set_light_color], [/atom/proc/set_light_on], and [/atom/proc/set_light_flags].
	#define COMPONENT_BLOCK_LIGHT_UPDATE (1<<0)
///Called right before the atom changes the value of light_power to a different one, from base [atom/proc/set_light_power]: (new_power)
#define COMSIG_ATOM_SET_LIGHT_POWER "atom_set_light_power"
///Called right after the atom changes the value of light_power to a different one, from base of [/atom/proc/set_light_power]: (old_power)
#define COMSIG_ATOM_UPDATE_LIGHT_POWER "atom_update_light_power"
///Called right before the atom changes the value of light_range to a different one, from base [atom/proc/set_light_range]: (new_range)
#define COMSIG_ATOM_SET_LIGHT_RANGE "atom_set_light_range"
///Called right after the atom changes the value of light_range to a different one, from base of [/atom/proc/set_light_range]: (old_range)
#define COMSIG_ATOM_UPDATE_LIGHT_RANGE "atom_update_light_range"
///Called right before the atom changes the value of light_color to a different one, from base [atom/proc/set_light_color]: (new_color)
#define COMSIG_ATOM_SET_LIGHT_COLOR "atom_set_light_color"
///Called right after the atom changes the value of light_color to a different one, from base of [/atom/proc/set_light_color]: (old_color)
#define COMSIG_ATOM_UPDATE_LIGHT_COLOR "atom_update_light_color"
///Called right before the atom changes the value of light_angle to a different one, from base [atom/proc/set_light_angle]: (new_angle)
#define COMSIG_ATOM_SET_LIGHT_ANGLE "atom_set_light_angle"
///Called right after the atom changes the value of light_angle to a different one, from base of [/atom/proc/set_light_angle]: (old_angle)
#define COMSIG_ATOM_UPDATE_LIGHT_ANGLE "atom_update_light_angle"
///Called right before the atom changes the value of light_dir to a different one, from base [atom/proc/set_light_dir]: (new_dir)
#define COMSIG_ATOM_SET_LIGHT_DIR "atom_set_light_dir"
///Called right after the atom changes the value of light_dir to a different one, from base of [/atom/proc/set_light_dir]: (old_dir)
#define COMSIG_ATOM_UPDATE_LIGHT_DIR "atom_update_light_dir"
///Called right before the atom changes the value of light_on to a different one, from base [atom/proc/set_light_on]: (new_value)
#define COMSIG_ATOM_SET_LIGHT_ON "atom_set_light_on"
///Called right after the atom changes the value of light_on to a different one, from base of [/atom/proc/set_light_on]: (old_value)
#define COMSIG_ATOM_UPDATE_LIGHT_ON "atom_update_light_on"
///Called right before the atom changes the value of light_height to a different one, from base [atom/proc/set_light_height]: (new_value)
#define COMSIG_ATOM_SET_LIGHT_HEIGHT "atom_set_light_height"
///Called right after the atom changes the value of light_height to a different one, from base of [/atom/proc/set_light_height]: (old_value)
#define COMSIG_ATOM_UPDATE_LIGHT_HEIGHT "atom_update_light_height"
///Called right before the atom changes the value of light_flags to a different one, from base [atom/proc/set_light_flags]: (new_flags)
#define COMSIG_ATOM_SET_LIGHT_FLAGS "atom_set_light_flags"
///Called right after the atom changes the value of light_flags to a different one, from base of [/atom/proc/set_light_flags]: (old_flags)
#define COMSIG_ATOM_UPDATE_LIGHT_FLAGS "atom_update_light_flags"
///Called right before the atom changes the value of light_render_source to a different one, from base [atom/proc/set_light_render_source]: (new_render_source)
#define COMSIG_ATOM_SET_LIGHT_RENDER_SOURCE "atom_set_light_render_source"
///Called right after the atom changes the value of light_render_source to a different one, from base of [/atom/proc/set_light_render_source]: (old_render_source)
#define COMSIG_ATOM_UPDATE_LIGHT_RENDER_SOURCE "atom_update_light_render_source"

///Called when an atom has a light template applied to it. Frombase of [/datum/light_template/proc/mirror_onto]: ()
#define COMSIG_ATOM_LIGHT_TEMPLATE_MIRRORED "atom_light_template_mirrored"

///Called when an atom's overlay component modifies its visuals, from base of [/datum/component/overlay_lighting/proc/show_to_holder]: (image/visible_mask, image/cone)
#define COMSIG_ATOM_OVERLAY_LIGHT_APPLIED "atom_overlay_light_applied"
