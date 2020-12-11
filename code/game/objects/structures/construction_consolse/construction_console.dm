//Aux base construction console
/mob/camera/ai_eye/remote/base_construction
	name = "construction holo-drone"
	move_on_shuttle = 1 //Allows any curious crew to watch the base after it leaves. (This is safe as the base cannot be modified once it leaves)
	icon = 'icons/obj/mining.dmi'
	icon_state = "construction_drone"
	var/obj/machinery/computer/camera_advanced/base_construction/linked_console

/mob/camera/ai_eye/remote/base_construction/Initialize(mapload, var/linked_cam_console)
	. = ..()
	linked_console = linked_cam_console

/mob/camera/ai_eye/remote/base_construction/setLoc(t)
	var/area/curr_area = get_area(t)
	if(!linked_console.allowed_area || istype(curr_area, linked_console.allowed_area))
		return ..()

/mob/camera/ai_eye/remote/base_construction/relaymove(mob/living/user, direction)
	dir = direction //This camera eye is visible as a drone, and needs to keep the dir updated
	return ..()

/obj/item/construction/rcd/internal //Base console's internal RCD. Roundstart consoles are filled, rebuilt cosoles start empty.
	name = "internal RCD"
	max_matter = 600
	no_ammo_message = "<span class='warning'>Internal matter exhausted. Please add additional materials.</span>"
	delay_mod = 0.5 //Bigger container and faster speeds due to being specialized and stationary.

/obj/machinery/computer/camera_advanced/base_construction
	name = "generic base construction console"
	desc = "An industrial computer integrated with a camera-assisted rapid construction drone."
	networks = list("ss13")
	var/obj/item/construction/rcd/internal/RCD //Internal RCD. The computer passes user commands to this in order to avoid massive copypaste.
	circuit = /obj/item/circuitboard/computer/base_construction
	off_action = new/datum/action/innate/camera_off/base_construction
	jump_action = null
	var/list/datum/action/innate/construction_actions
	//Number of different special structures that are in stock
	var/list/structures = list()
	var/obj/machinery/computer/auxiliary_base/found_aux_console //Tracker for the Aux base console, so the eye can always find it.
	icon_screen = "mining"
	icon_keyboard = "rd_key"
	light_color = LIGHT_COLOR_PINK
	var/area/allowed_area

/obj/machinery/computer/camera_advanced/base_construction/Initialize()
	. = ..()
	populate_actions_list()
	RCD = new(src)

/obj/machinery/computer/camera_advanced/base_construction/proc/populate_actions_list()
	construction_actions = list()

/obj/machinery/computer/camera_advanced/base_construction/proc/refill_special_structures()
	return

/obj/machinery/computer/camera_advanced/base_construction/Initialize(mapload)
	. = ..()
	if(mapload) //Map spawned consoles have a filled RCD and stocked special structures
		refill_special_structures()

/obj/machinery/computer/camera_advanced/base_construction/proc/find_spawn_spot()
	return get_turf(src)

/obj/machinery/computer/camera_advanced/base_construction/CreateEye()
	var/turf/spawn_spot = find_spawn_spot()
	if (!spawn_spot)
		return
	eyeobj = new /mob/camera/ai_eye/remote/base_construction(spawn_spot, src)
	eyeobj.origin = src

/obj/machinery/computer/camera_advanced/base_construction/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/rcd_ammo) || istype(W, /obj/item/stack/sheet))
		RCD.attackby(W, user, params) //If trying to feed the console more materials, pass it along to the RCD.
	else
		return ..()

/obj/machinery/computer/camera_advanced/base_construction/Destroy()
	qdel(RCD)
	return ..()

/obj/machinery/computer/camera_advanced/base_construction/GrantActions(mob/living/user)
	..()
	for (var/datum/action/innate/construction_action in construction_actions)
		if(construction_action)
			construction_action.target = src
			construction_action.Grant(user)
			actions += construction_action
	eyeobj.invisibility = 0 //When the eye is in use, make it visible to players so they know when someone is building.

/obj/machinery/computer/camera_advanced/base_construction/remove_eye_control(mob/living/user)
	..()
	eyeobj.invisibility = INVISIBILITY_MAXIMUM //Hide the eye when not in use.

/datum/action/innate/construction //Parent aux base action
	icon_icon = 'icons/mob/actions/actions_construction.dmi'
	var/mob/living/C //Mob using the action
	var/mob/camera/ai_eye/remote/base_construction/remote_eye //Console's eye mob
	var/obj/machinery/computer/camera_advanced/base_construction/B //Console itself
	var/shuttlebuilder = TRUE //Is this used to build shuttles only on the station z level?

/datum/action/innate/construction/Activate()
	if(!target)
		return TRUE
	C = owner
	remote_eye = C.remote_control
	B = target
	if(!B.RCD) //The console must always have an RCD.
		B.RCD = new /obj/item/construction/rcd/internal(src) //If the RCD is lost somehow, make a new (empty) one!

/datum/action/innate/construction/proc/check_spot()
//Check a loction to see if it is inside the aux base at the station. Camera visbility checks omitted so as to not hinder construction.
	var/turf/build_target = get_turf(remote_eye)
	var/area/build_area = get_area(build_target)
	var/area/area_constraint = B.allowed_area
	if (!area_constraint)
		return TRUE
	if(!istype(build_area, area_constraint))
		to_chat(owner, "<span class='warning'>You can only build within [area_constraint]!</span>")
		return FALSE
	if(shuttlebuilder && !is_station_level(build_target.z))
		to_chat(owner, "<span class='warning'>[area_constraint] has launched and can no longer be modified.</span>")
		return FALSE
	return TRUE

/datum/action/innate/camera_off/base_construction
	name = "Log out"
