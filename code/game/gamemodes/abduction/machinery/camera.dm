/obj/machinery/computer/camera_advanced/abductor
	name = "Human Observation Console"
	var/team = 0
	networks = list("SS13","Abductor")
	off_action = new/datum/action/camera_off/abductor //specific datum
	var/datum/action/teleport_in/tele_in_action = new
	var/datum/action/teleport_out/tele_out_action = new
	var/datum/action/teleport_self/tele_self_action = new
	var/datum/action/vest_mode_swap/vest_mode_action = new
	var/datum/action/vest_disguise_swap/vest_disguise_action = new
	var/obj/machinery/abductor/console/console

	icon = 'icons/obj/abductor.dmi'
	icon_state = "camera"

/obj/machinery/computer/camera_advanced/abductor/CreateEye()
	..()
	eyeobj.visible_icon = 1
	eyeobj.icon = 'icons/obj/abductor.dmi'
	eyeobj.icon_state = "camera_target"

/obj/machinery/computer/camera_advanced/abductor/GrantActions(var/mob/living/carbon/user)
	off_action.target = user
	off_action.Grant(user)

	jump_action.target = user
	jump_action.Grant(user)
	//TODO : add null checks
	tele_in_action.target = console.pad
	tele_in_action.Grant(user)

	tele_out_action.target = console
	tele_out_action.Grant(user)

	tele_self_action.target = console.pad
	tele_self_action.Grant(user)

	vest_mode_action.target = console
	vest_mode_action.Grant(user)

	vest_disguise_action.target = console
	vest_disguise_action.Grant(user)

/obj/machinery/computer/camera_advanced/abductor/proc/IsAbductor(var/mob/living/carbon/human/H)
	return H.dna.species.id == "abductor"

/obj/machinery/computer/camera_advanced/abductor/proc/IsScientist(var/mob/living/carbon/human/H)
	var/datum/species/abductor/S = H.dna.species
	return S.scientist

/obj/machinery/computer/camera_advanced/abductor/attack_hand(var/mob/user as mob)
	if(!iscarbon(user) || !IsAbductor(user))
		return
	return ..()

/datum/action/camera_off/abductor/Activate()
	if(!target || !iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/abductor/origin = remote_eye.origin
	C.remote_view = 0
	origin.current_user = null
	origin.jump_action.Remove(C)
	origin.tele_in_action.Remove(C)
	origin.tele_out_action.Remove(C)
	origin.tele_self_action.Remove(C)
	origin.vest_mode_action.Remove(C)
	origin.vest_disguise_action.Remove(C)
	if(C.client)
		C.client.perspective = MOB_PERSPECTIVE
		C.client.eye = src
		C.client.images -= remote_eye.user_image
	C.remote_control = null
	C.unset_machine()
	src.Remove(C)


/datum/action/teleport_in
	name = "Send To"
	action_type = AB_INNATE
	button_icon_state = "beam_down"

/datum/action/teleport_in/Activate()
	if(!target || !iscarbon(owner))
		return
	var/mob/living/carbon/human/C = owner
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/abductor/pad/P = target

	if(cameranet.checkTurfVis(remote_eye.loc))
		P.PadToLoc(remote_eye.loc)

/datum/action/teleport_out
	name = "Retrieve"
	action_type = AB_INNATE
	button_icon_state = "beam_up"

/datum/action/teleport_out/Activate()
	if(!target || !iscarbon(owner))
		return
	var/obj/machinery/abductor/console/console = target

	console.TeleporterRetrieve()

/datum/action/teleport_self
	name = "Send Self"
	action_type = AB_INNATE
	button_icon_state = "beam_down"

/datum/action/teleport_self/Activate()
	if(!target || !iscarbon(owner))
		return
	var/mob/living/carbon/human/C = owner
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/abductor/pad/P = target

	if(cameranet.checkTurfVis(remote_eye.loc))
		P.MobToLoc(remote_eye.loc,C)

/datum/action/vest_mode_swap
	name = "Switch Vest Mode"
	action_type = AB_INNATE
	button_icon_state = "vest_mode"

/datum/action/vest_mode_swap/Activate()
	if(!target || !iscarbon(owner))
		return
	var/obj/machinery/abductor/console/console = target
	console.FlipVest()


/datum/action/vest_disguise_swap
	name = "Switch Vest Disguise"
	action_type = AB_INNATE
	button_icon_state = "vest_disguise"

/datum/action/vest_disguise_swap/Activate()
	if(!target || !iscarbon(owner))
		return
	var/obj/machinery/abductor/console/console = target
	console.SelectDisguise(remote=1)
