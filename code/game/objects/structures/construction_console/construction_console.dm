/**
 * Camera console used to control a base building drone
 *
 * Using this console will put the user in control of a [base building drone][/mob/camera/ai_eye/remote/base_construction].
 * The drone will appear somewhere within the allowed_area var, or if no area is specified, at the location of the console.area
 * Upon interacting, the user will be granted a set of base building actions that will generally be carried out at the drone's location.
 * To create a new base builder system, this class should be the only thing that needs to be subtyped.
 *
 */
/obj/machinery/computer/camera_advanced/base_construction
	name = "generic base construction console"
	desc = "An industrial computer integrated with a camera-assisted rapid construction drone."
	networks = list("ss13")
	circuit = /obj/item/circuitboard/computer/base_construction
	off_action = new/datum/action/innate/camera_off/base_construction
	jump_action = null
	icon_screen = "mining"
	icon_keyboard = "rd_key"
	light_color = LIGHT_COLOR_PINK
	///Area that the eyeobj will be constrained to. If null, eyeobj will be able to build and move anywhere.
	var/area/allowed_area
	///Assoc. list ("structure_name" : count) that keeps track of the number of special structures that can't be built with an RCD, for example, tiny fans or turrets.
	var/list/structures = list()
	///Internal RCD. Some construction actions rely on having this.
	var/obj/item/construction/rcd/internal/internal_rcd
	///Actions given to the console user to help with base building. Actions are generally carried out at the location of the eyeobj
	var/list/datum/action/innate/construction_actions

/obj/machinery/computer/camera_advanced/base_construction/Initialize(mapload)
	. = ..()
	//Populate the actions list with the different action objects that will be granted to console users
	populate_actions_list()
	//Map spawned consoles will automatically restock their materials
	if(mapload)
		restock_materials()

/**
 * Fill the construction_actios list with actions
 *
 * Instantiate each action object that we'll be giving to users of
 * this console, and put it in the construction actions list.
 */
/obj/machinery/computer/camera_advanced/base_construction/proc/populate_actions_list()
	construction_actions = list()

/**
 * Reload materials used by the console
 *
 * Restocks any materials used by the base construction console.
 * This might mean refilling the internal RCD (should it be initialized), or
 * giving the structures list default values.
 */
/obj/machinery/computer/camera_advanced/base_construction/proc/restock_materials()
	return

///Find a spawn location for the eyeobj. If no allowed_area is defined, spawn ontop of the console.
/obj/machinery/computer/camera_advanced/base_construction/proc/find_spawn_spot()
	if (allowed_area)
		return pick(get_area_turfs(allowed_area))
	return get_turf(src)

/obj/machinery/computer/camera_advanced/base_construction/CreateEye()
	var/turf/spawn_spot = find_spawn_spot()
	if (!spawn_spot)
		return FALSE
	eyeobj = new /mob/camera/ai_eye/remote/base_construction(spawn_spot, src)
	eyeobj.origin = src
	return TRUE

/obj/machinery/computer/camera_advanced/base_construction/attackby(obj/item/W, mob/user, params)
	//If we have an internal RCD, we can refill it by slapping the console with some materials
	if(internal_rcd && (istype(W, /obj/item/rcd_ammo) || istype(W, /obj/item/stack/sheet)))
		internal_rcd.attackby(W, user, params)
	else
		return ..()

/obj/machinery/computer/camera_advanced/base_construction/Destroy()
	qdel(internal_rcd)
	return ..()

///Go through every action object in the construction_action list (which should be fully initialized by now) and grant it to the user.
/obj/machinery/computer/camera_advanced/base_construction/GrantActions(mob/living/user)
	..()
	for (var/datum/action/innate/construction_action in construction_actions)
		if(construction_action)
			construction_action.target = src
			construction_action.Grant(user)
			actions += construction_action
	//When the eye is in use, make it visible to players so they know when someone is building.
	eyeobj.invisibility = 0

/obj/machinery/computer/camera_advanced/base_construction/remove_eye_control(mob/living/user)
	..()
	//Hide the eye when not in use.
	eyeobj.invisibility = INVISIBILITY_MAXIMUM

/**
 * A mob used by [/obj/machinery/computer/camera_advanced/base_construction] for building in specific areas.
 *
 * Controlled by a user who is using a base construction console.
 * The user will be granted a set of building actions by the console, and the actions will be carried out by this mob.
 * The mob is constrained to a given area defined by the base construction console.
 *
 */
/mob/camera/ai_eye/remote/base_construction
	name = "construction holo-drone"
	//Allows any curious crew to watch the base after it leaves. (This is safe as the base cannot be modified once it leaves)
	move_on_shuttle = TRUE
	icon = 'icons/obj/mining.dmi'
	icon_state = "construction_drone"
	///Reference to the camera console controlling this drone
	var/obj/machinery/computer/camera_advanced/base_construction/linked_console

/mob/camera/ai_eye/remote/base_construction/Initialize(mapload, obj/machinery/computer/camera_advanced/console_link)
	linked_console = console_link
	return ..()

/mob/camera/ai_eye/remote/base_construction/setLoc(t)
	var/area/curr_area = get_area(t)
	//Only move if we're in the allowed area. If no allowed area is defined, then we're free to move wherever.
	if(!linked_console.allowed_area || istype(curr_area, linked_console.allowed_area))
		return ..()

/mob/camera/ai_eye/remote/base_construction/relaymove(mob/living/user, direction)
	//This camera eye is visible, and as such needs to keep it's dir updated
	dir = direction
	return ..()

///[Base console's][/obj/machinery/computer/camera_advanced/base_construction] internal RCD. Has a large material capacity and a fast buildspeed.
/obj/item/construction/rcd/internal
	name = "internal RCD"
	max_matter = 600
	no_ammo_message = "<span class='warning'>Internal matter exhausted. Please add additional materials.</span>"
	delay_mod = 0.5
