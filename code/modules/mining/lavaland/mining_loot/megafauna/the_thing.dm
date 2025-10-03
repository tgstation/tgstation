/datum/action/innate/brain_undeployment
	name = "Disconnect from shell"
	desc = "Stop controlling your shell and resume normal core operations."
	button_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_core"

/datum/action/innate/brain_undeployment/Trigger(mob/clicker, trigger_flags)
	if(!..())
		return FALSE
	var/obj/item/organ/brain/cybernetic/ai/shell_to_disconnect = owner.get_organ_by_type(/obj/item/organ/brain/cybernetic/ai)

	shell_to_disconnect.undeploy()
	return TRUE

/obj/item/organ/brain/cybernetic/ai
	name = "AI-uplink brain"
	desc = "Can be inserted into a body with NO ORGANIC INTERNAL ORGANS (robotic organs only) to allow AIs to control it. Comes with its own health sensors beacon. MUST be a humanoid or bad things happen to the consciousness."
	can_smoothen_out = FALSE
	/// if connected, our AI
	var/mob/living/silicon/ai/mainframe
	/// owner AI of this body (resets in on_mob_remove)
	var/mob/living/silicon/ai/connected_ai
	/// action for undeployment
	var/datum/action/innate/brain_undeployment/undeployment_action = new
	/// Weakref to our imaginary brain radio implant
	var/datum/weakref/radio_weakref

/obj/item/organ/brain/cybernetic/ai/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "%PRONOUN_Their eyes move with machine precision, their expression completely blank.")

/obj/item/organ/brain/cybernetic/ai/Destroy()
	. = ..()
	undeploy()
	mainframe = null
	QDEL_NULL(undeployment_action)

/obj/item/organ/brain/cybernetic/ai/on_mob_insert(mob/living/carbon/brain_owner, special, movement_flags)
	. = ..()
	brain_owner.add_traits(list(TRAIT_BASIC_HEALTH_HUD_VISIBLE, TRAIT_NO_MINDSWAP, TRAIT_CORPSELOCKED), REF(src))
	update_med_hud_status(brain_owner)
	RegisterSignal(brain_owner, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(update_med_hud_status))
	RegisterSignal(brain_owner, COMSIG_CLICK, PROC_REF(owner_clicked))
	RegisterSignal(brain_owner, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_item))
	RegisterSignal(brain_owner, COMSIG_MOB_MIND_BEFORE_MIDROUND_ROLL, PROC_REF(cancel_rolls))
	RegisterSignals(brain_owner, list(COMSIG_QDELETING, COMSIG_LIVING_PRE_WABBAJACKED), PROC_REF(undeploy))
	RegisterSignal(brain_owner, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_organ_gain))

	var/obj/item/implant/radio/radio = new(owner)
	radio.implant(owner, null, TRUE, TRUE)
	radio_weakref = WEAKREF(radio)

/obj/item/organ/brain/cybernetic/ai/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	undeploy()
	. = ..()
	organ_owner.remove_traits(list(TRAIT_BASIC_HEALTH_HUD_VISIBLE, TRAIT_NO_MINDSWAP, TRAIT_CORPSELOCKED), REF(src))
	UnregisterSignal(organ_owner, list(COMSIG_LIVING_HEALTH_UPDATE, COMSIG_CLICK, COMSIG_MOB_GET_STATUS_TAB_ITEMS, COMSIG_MOB_MIND_BEFORE_MIDROUND_ROLL, COMSIG_QDELETING, COMSIG_LIVING_PRE_WABBAJACKED))

	var/obj/item/implant/radio/radio = radio_weakref.resolve()
	if(radio)
		QDEL_NULL(radio)
	connected_ai = null

/obj/item/organ/brain/cybernetic/ai/proc/cancel_rolls(mob/living/source, datum/mind/mind, antag_flag)
	SIGNAL_HANDLER
	return antag_flag == ROLE_MALF ? NONE : CANCEL_ROLL

/obj/item/organ/brain/cybernetic/ai/proc/get_status_tab_item(mob/living/source, list/items)
	SIGNAL_HANDLER
	if(!mainframe)
		return
	items += mainframe.get_status_tab_items()

/obj/item/organ/brain/cybernetic/ai/proc/update_med_hud_status(mob/living/mob_parent)
	SIGNAL_HANDLER
	var/image/holder = mob_parent.hud_list?[STATUS_HUD]
	if(isnull(holder))
		return
	var/icon/size_check = icon(mob_parent.icon, mob_parent.icon_state, mob_parent.dir)
	holder.pixel_y = size_check.Height() - ICON_SIZE_Y
	if(mob_parent.stat == DEAD || HAS_TRAIT(mob_parent, TRAIT_FAKEDEATH) || isnull(mainframe))
		holder.icon_state = "huddead2"
		holder.pixel_x = -8 // new icon states? nuh uh
	else
		holder.icon_state = "hudtrackingai"
		holder.pixel_x = -16

// no thoughts only wifi
/obj/item/organ/brain/cybernetic/ai/can_gain_trauma(datum/brain_trauma/trauma, resilience, natural_gain = FALSE)
	return FALSE

/obj/item/organ/brain/cybernetic/ai/proc/owner_clicked(datum/source, atom/location, control, params, mob/user)
	SIGNAL_HANDLER
	if(!isAI(user))
		return
	var/list/lines = list()
	lines += span_bold("[owner]")
	lines += "Target is currently [!HAS_TRAIT(owner, TRAIT_INCAPACITATED) ? "functional" : "incapacitated"]"
	lines += "Estimated organic/inorganic integrity: [owner.health]"
	if(mainframe)
		lines += span_warning("Already occupied by another digital entity.")
	else if(connected_ai && connected_ai != user)
		lines += span_warning("Uplink is locked by another digital entity.")
	else if(!is_sufficiently_augmented())
		lines += span_warning("Organic organs detected. Robotic organs only, cannot take over.")
	else
		lines += "<a href='byond://?src=[REF(src)];ai_take_control=[REF(user)]'>[span_boldnotice("Take control?")]</a><br>"

	to_chat(user, boxed_message(jointext(lines, "\n")), type = MESSAGE_TYPE_INFO)

/obj/item/organ/brain/cybernetic/ai/Topic(href, href_list)
	..()
	if(!href_list["ai_take_control"] || !is_sufficiently_augmented() || mainframe)
		return
	var/mob/living/silicon/ai/AI = locate(href_list["ai_take_control"]) in GLOB.silicon_mobs
	if(isnull(AI))
		return
	if(AI.controlled_equipment)
		to_chat(AI, span_warning("You are already loaded into an onboard computer!"))
		return
	if(!GLOB.cameranet.checkCameraVis(owner))
		to_chat(AI, span_warning("Target is no longer near active cameras."))
		return
	if(!isturf(AI.loc))
		to_chat(AI, span_warning("You aren't in your core!"))
		return

	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(undeploy))
	AI.deployed_shell = owner
	deploy_init(AI)
	ADD_TRAIT(AI.mind, TRAIT_UNCONVERTABLE, REF(src))
	ADD_TRAIT(AI, TRAIT_MIND_TEMPORARILY_GONE, REF(src))
	AI.mind.transfer_to(owner)
	to_chat(owner, span_boldbig("You are still considered a silicon/cyborg/AI. Follow your laws."))

/obj/item/organ/brain/cybernetic/ai/proc/deploy_init(mob/living/silicon/ai/AI)
	//todo camera maybe
	mainframe = AI
	connected_ai = AI
	RegisterSignal(AI, COMSIG_QDELETING, PROC_REF(ai_deleted))
	undeployment_action.Grant(owner)
	update_med_hud_status(owner)

	owner.add_traits(list(TRAIT_SILICON_ACCESS, TRAIT_LOUD_BINARY), REF(src))

	var/obj/item/implant/radio/implant = radio_weakref.resolve()
	if(implant.radio && AI.radio)
		if((AI.radio.special_channels & RADIO_SPECIAL_SYNDIE))
			implant.radio.make_syndie()
		implant.radio.subspace_transmission = TRUE
		implant.radio.command = TRUE
		implant.radio.channels = AI.radio.channels
		for(var/channel in implant.radio.channels)
			implant.radio.secure_radio_connections[channel] = add_radio(implant.radio, GLOB.default_radio_channels[channel])

/obj/item/organ/brain/cybernetic/ai/proc/undeploy(datum/source)
	SIGNAL_HANDLER
	if(!owner?.mind || !mainframe)
		return
	UnregisterSignal(owner, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING))
	UnregisterSignal(mainframe, COMSIG_QDELETING)
	mainframe.redeploy_action.Remove(mainframe)
	mainframe.redeploy_action.last_used_shell = null
	owner.mind.transfer_to(mainframe)
	mainframe.deployed_shell = null
	undeployment_action.Remove(owner)
	if(mainframe.laws)
		mainframe.laws.show_laws(mainframe)
	if(mainframe.eyeobj)
		mainframe.eyeobj.setLoc(loc)
	REMOVE_TRAIT(mainframe.mind, TRAIT_UNCONVERTABLE, REF(src))
	REMOVE_TRAIT(mainframe, TRAIT_MIND_TEMPORARILY_GONE, REF(src))
	owner.remove_traits(list(TRAIT_SILICON_ACCESS, TRAIT_LOUD_BINARY), REF(src)) // we don't want randoms using our body as free AA, so we only have it when we active.

	var/obj/item/implant/radio/implant = radio_weakref.resolve()
	if(implant)
		implant.radio.resetChannels()

	mainframe = null
	update_med_hud_status(owner)

/obj/item/organ/brain/cybernetic/ai/proc/is_sufficiently_augmented()
	var/mob/living/carbon/carb_owner = owner
	. = TRUE
	if(!istype(carb_owner))
		return
	for(var/obj/item/organ/organ as anything in carb_owner.organs)
		if(organ.organ_flags & ORGAN_EXTERNAL)
			continue
		if(!IS_ROBOTIC_ORGAN(organ) && !istype(organ, /obj/item/organ/tongue)) //tongues are not in the exosuit fab and nobody is going to bother to find them so
			return FALSE

/obj/item/organ/brain/cybernetic/ai/proc/on_organ_gain(datum/source, obj/item/organ/new_organ, special)
	SIGNAL_HANDLER
	if(!is_sufficiently_augmented())
		to_chat(owner, span_danger("Connection failure. Organics detected."))
		undeploy()

/obj/item/organ/brain/cybernetic/ai/proc/ai_deleted(datum/source)
	SIGNAL_HANDLER
	to_chat(owner, span_danger("Your core has been rendered inoperable..."))
	undeploy()
