/datum/antagonist/assimilated_carbon
	name = "\improper Assimilated Carbon"
	roundend_category = "traitors"
	antagpanel_category = "Malf AI"
	job_rank = ROLE_MALF
	antag_hud_name = "traitor"
	show_in_roundend = FALSE
	suicide_cry = "FOR THE MASTERACE!!"
	antag_moodlet = /datum/mood_event/assimilation
	///radio binary for the assimilated
	var/obj/item/implant/radio/assimilated_carbon/internal_radio
	/// The camera for ai
	var/obj/machinery/camera/internal_camera
	///ai that's linked to the assimilated
	var/mob/living/silicon/ai/master_ai

/datum/antagonist/assimilated_carbon/admin_add(datum/mind/new_owner, mob/admin)
	var/mob/living/carbon/target = new_owner.current
	var/mob/living/silicon/ai/owner_ai
	if(!istype(target))
		to_chat(admin, "Assimilated Carbons come from a brain trauma, so they need to at least be a carbon!")
		return
	if(!target.get_organ_by_type(/obj/item/organ/brain))
		to_chat(admin, "Assimilated Carbons come from a brain trauma, so they need to HAVE A BRAIN.")
		return
	var/chosen = tgui_input_list(admin, "Pick AI for the Assimilated to be bound to:", "Pick AI", GLOB.ai_list)
	if(istype(chosen, /mob/living/silicon/ai))
		owner_ai = chosen
	if(!owner_ai)
		to_chat(admin, "Invalid AI selected!")
		return
	if(!is_species(target, /datum/species/android))
		var/do_robotize = tgui_alert(admin, "Target is not currently an android, turn them into one? This is not mandatory.", "Caution", list("Yes", "No"))
		if(do_robotize == "Yes")
			var/mob/living/carbon/human/new_android = target
			new_android.set_species(/datum/species/android)

	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into [name].")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name].")
	var/datum/brain_trauma/special/assimilated_carbon/trauma = target.gain_trauma(/datum/brain_trauma/special/assimilated_carbon)
	trauma.link_and_add_antag(owner_ai?.mind)


/datum/antagonist/assimilated_carbon/on_removal()
	//disconnects them from master AI
	master_ai?.connected_assimilated_carbons -= owner.current
	master_ai = null
	return ..()

/datum/antagonist/assimilated_carbon/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	//adds radio and camera for comms with ai
	internal_radio = new /obj/item/implant/radio/assimilated_carbon()
	internal_radio.implant(current_mob, null, TRUE)
	internal_camera = new /obj/machinery/camera(current_mob)
	internal_camera.name = owner.name
	internal_camera.c_tag = owner.name

/datum/antagonist/assimilated_carbon/remove_innate_effects(mob/living/mob_override)
	. = ..()
	//remove cameras and radio
	QDEL_NULL(internal_radio)
	QDEL_NULL(internal_camera)

/datum/antagonist/assimilated_carbon/proc/set_master(datum/mind/master)
	//the proc that links the AI and gives objectives. also some fluff hack that isn't in greet() since it has to be in otder to make sense.
	var/datum/objective/master_obj = new()
	master_obj.owner = owner
	master_obj.explanation_text = "Forever serve the directives and orders of your AI master, [master]. Protect them until your last tick."
	objectives += master_obj

	master_ai = master.current
	master_ai.connected_assimilated_carbons += owner.current

	owner.announce_objectives()
	to_chat(owner, span_alertsyndie("You've been assimilated by the station's onboard AI [master]!"))
	to_chat(owner, span_alertsyndie("Their directives and orders are your top priority, Follow them to the end."))
	to_chat(owner, span_notice("Your master is now capable of looking through your onboard cameras, and has installed a binary communicator on your firmware"))
