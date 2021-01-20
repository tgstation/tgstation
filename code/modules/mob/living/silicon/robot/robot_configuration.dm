/***************************************************************************************
 * # robot_configuration
 *
 * Definition of /obj/item/robot_config, which defines behavior for each configuration.
 * Further expanded on in [robot_modules.dm][/obj/item/robot_config/Initialize()].
 *
 ***************************************************************************************/
/obj/item/robot_config
	name = "Default"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	w_class = WEIGHT_CLASS_GIGANTIC
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1

	///Host of this configuration
	var/mob/living/silicon/robot/robot

	var/configselect_icon = "nomod"

	///Produces the icon for the borg and, if no special_light_key is set, the lights
	var/cyborg_base_icon = "robot"
	///If we want specific lights, use this instead of copying lights in the dmi
	var/special_light_key

// ------------------------------------------ Modules (tools)
	///Holds all the usable modules (tools)
	var/list/modules = list()

	var/list/basic_modules = list() //a list of paths, converted to a list of instances on New()
	var/list/emag_modules = list() //ditto

	///Modules not inherent to the robot configuration
	var/list/added_modules = list() //kept when the configuration changes
	var/list/storages = list()

// ------------------------------------------ Traits
	///List of traits that will be applied to the mob if this module is used.
	var/list/module_traits = null

	var/list/radio_channels = list()

	var/magpulsing = FALSE
	var/clean_on_move = FALSE
	///Whether the borg loses tool slots with damage.
	var/breakable_modules = TRUE
	///Whether swapping to this configuration should lockcharge the borg
	var/locked_transform = TRUE

	var/allow_riding = TRUE
	///Whether the borg can stuff itself into disposals
	var/canDispose = FALSE

	var/did_feedback = FALSE

// ------------------------------------------ Offsets
	var/hat_offset = -3

	var/list/ride_offset_x = list("north" = 0, "south" = 0, "east" = -6, "west" = 6)
	var/list/ride_offset_y = list("north" = 4, "south" = 4, "east" = 3, "west" = 3)
