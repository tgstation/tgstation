/obj/machinery/computer/camera_advanced/abductor
	name = "Human Observation Console"
	var/team_number = 0
	networks = list(CAMERANET_NETWORK_SS13, CAMERANET_NETWORK_ABDUCTOR)
	var/obj/machinery/abductor/console/console
	/// We can't create our actions until after LateInitialize
	/// So we instead do it on the first call to GrantActions
	var/abduct_created = FALSE
	lock_override = TRUE

	icon = 'icons/obj/antags/abductor.dmi'
	icon_state = "camera"
	icon_keyboard = null
	icon_screen = null
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/machinery/computer/camera_advanced/abductor/Destroy()
	if(console)
		console.camera = null
		console = null
	return ..()

/obj/machinery/computer/camera_advanced/abductor/CreateEye()
	..()
	eyeobj.visible_icon = TRUE
	eyeobj.icon = 'icons/mob/silicon/cameramob.dmi'
	eyeobj.icon_state = "abductor_camera"
	eyeobj.SetInvisibility(INVISIBILITY_OBSERVER)

/obj/machinery/computer/camera_advanced/abductor/GrantActions(mob/living/carbon/user)
	if(!abduct_created)
		abduct_created = TRUE
		actions += new /datum/action/innate/teleport_in(console.pad)
		actions += new /datum/action/innate/teleport_out(console)
		actions += new /datum/action/innate/teleport_self(console.pad)
		actions += new /datum/action/innate/vest_mode_swap(console)
		actions += new /datum/action/innate/vest_disguise_swap(console)
		actions += new /datum/action/innate/set_droppoint(console)
	..()

/obj/machinery/computer/camera_advanced/abductor/proc/IsScientist(mob/living/carbon/human/H)
	return HAS_TRAIT(H, TRAIT_ABDUCTOR_SCIENTIST_TRAINING)

/datum/action/innate/teleport_in
///Is the amount of time required between uses
	var/abductor_pad_cooldown = 8 SECONDS
///Is used to compare to world.time in order to determine if the action should early return
	var/use_delay
	name = "Send To"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "beam_down"

/datum/action/innate/teleport_in/Activate()
	if(!target || !iscarbon(owner))
		return
	if(world.time < use_delay)
		to_chat(owner, span_warning("You must wait [DisplayTimeText(use_delay - world.time)] to use the [target] again!"))
		return
	var/mob/living/carbon/human/C = owner
	var/mob/camera/ai_eye/remote/remote_eye = C.remote_control
	var/obj/machinery/abductor/pad/P = target

	var/area/target_area = get_area(remote_eye)
	if((target_area.area_flags & NOTELEPORT) && !istype(target_area, /area/centcom/abductor_ship))
		to_chat(owner, span_warning("This area is too heavily shielded to safely transport to."))
		return

	if(istype(target_area, /area/station/ai_monitored))
		to_chat(owner, span_warning("This area is too heavily shielded to safely transport to."))
		return

	use_delay = (world.time + abductor_pad_cooldown)

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		P.PadToLoc(remote_eye.loc)

/datum/action/innate/teleport_out
	name = "Retrieve"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "beam_up"

/datum/action/innate/teleport_out/Activate()
	if(!target || !iscarbon(owner))
		return
	var/obj/machinery/abductor/console/console = target

	console.TeleporterRetrieve()

/datum/action/innate/teleport_self
///Is the amount of time required between uses
	var/teleport_self_cooldown = 9 SECONDS
	var/use_delay
	name = "Send Self"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "beam_down"

/datum/action/innate/teleport_self/Activate()
	if(!target || !iscarbon(owner))
		return
	if(world.time < use_delay)
		to_chat(owner, span_warning("You can only teleport to one place at a time!"))
		return
	var/mob/living/carbon/human/C = owner
	var/mob/camera/ai_eye/remote/remote_eye = C.remote_control
	var/obj/machinery/abductor/pad/P = target

	var/area/target_area = get_area(remote_eye)
	if((target_area.area_flags & NOTELEPORT) && !istype(target_area, /area/centcom/abductor_ship))
		to_chat(owner, span_warning("This area is too heavily shielded to safely transport to."))
		return

	if(istype(target_area, /area/station/ai_monitored))
		to_chat(owner, span_warning("This area is too heavily shielded to safely transport to."))
		return

	use_delay = (world.time + teleport_self_cooldown)

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		P.MobToLoc(remote_eye.loc,C)

/datum/action/innate/vest_mode_swap
	name = "Switch Vest Mode"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "vest_mode"

/datum/action/innate/vest_mode_swap/Activate()
	if(!target || !iscarbon(owner))
		return
	var/obj/machinery/abductor/console/console = target
	console.FlipVest()


/datum/action/innate/vest_disguise_swap
	name = "Switch Vest Disguise"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "vest_disguise"

/datum/action/innate/vest_disguise_swap/Activate()
	if(!target || !iscarbon(owner))
		return
	var/obj/machinery/abductor/console/console = target
	console.SelectDisguise(remote=1)

/datum/action/innate/set_droppoint
	name = "Set Experiment Release Point"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "set_drop"

/datum/action/innate/set_droppoint/Activate()
	if(!target || !iscarbon(owner))
		return

	var/mob/living/carbon/human/C = owner
	var/mob/camera/ai_eye/remote/remote_eye = C.remote_control

	var/obj/machinery/abductor/console/console = target
	console.SetDroppoint(remote_eye.loc,owner)
