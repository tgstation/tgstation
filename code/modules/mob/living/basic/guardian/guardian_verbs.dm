/// Pop out into the realm of the living.
/mob/living/basic/guardian/proc/manifest(forced)
	if (is_deployed() || isnull(summoner?.loc) || istype(summoner?.loc, /obj/effect) || (!COOLDOWN_FINISHED(src, manifest_cooldown) && !forced) || locked)
		return FALSE
	forceMove(summoner.loc)
	new /obj/effect/temp_visual/guardian/phase(loc)
	COOLDOWN_START(src, manifest_cooldown, 1 SECONDS)
	reset_perspective()
	manifest_effects()
	return TRUE

/// Go and hide inside your boss.
/mob/living/basic/guardian/proc/recall(forced)
	if (!is_deployed() || isnull(summoner) || (!COOLDOWN_FINISHED(src, manifest_cooldown) && !forced) || locked)
		return FALSE
	new /obj/effect/temp_visual/guardian/phase/out(loc)
	recall_effects()
	forceMove(summoner)
	COOLDOWN_START(src, manifest_cooldown, 1 SECONDS)
	return TRUE

/// Do something when we appear.
/mob/living/basic/guardian/proc/manifest_effects()
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_GUARDIAN_MANIFESTED)

/// Do something when we vanish.
/mob/living/basic/guardian/proc/recall_effects()
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_GUARDIAN_RECALLED)

/// Swap to a different mode... if we have one
/mob/living/basic/guardian/proc/toggle_modes()
	to_chat(src, span_bolddanger("You don't have another mode!"))


/// Turn an internal light on or off.
/mob/living/basic/guardian/proc/toggle_light()
	if (!light_on)
		to_chat(src, span_notice("You activate your light."))
		set_light_on(TRUE)
	else
		to_chat(src, span_notice("You deactivate your light."))
		set_light_on(FALSE)


/// Prints what type of guardian we are and what we can do.
/mob/living/basic/guardian/verb/check_type()
	set name = "Check Guardian Type"
	set category = "Guardian"
	set desc = "Check what type you are."
	to_chat(src, playstyle_string)


/// Speak with our boss at a distance
/mob/living/basic/guardian/proc/communicate()
	if (isnull(summoner))
		return
	var/sender_key = key
	var/input = tgui_input_text(src, "Enter a message to tell your summoner", "Guardian")
	if (sender_key != key || !input) //guardian got reset, or did not enter anything
		return

	var/preliminary_message = span_boldholoparasite("[input]") //apply basic color/bolding
	var/my_message = "<font color=\"[guardian_colour]\"><b><i>[src]:</i></b></font> [preliminary_message]" //add source, color source with the guardian's color

	to_chat(summoner, "<span class='say'>[my_message]</span>")
	var/list/guardians = summoner.get_all_linked_holoparasites()
	for(var/guardian in guardians)
		to_chat(guardian, "<span class='say'>[my_message]</span>")
	for(var/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, src)
		to_chat(dead_mob, "<span class='say'>[link] [my_message]</span>")

	src.log_talk(input, LOG_SAY, tag="guardian")

/// Speak with your guardian(s) at a distance.
/mob/living/proc/guardian_comm()
	set name = "Communicate"
	set category = "Guardian"
	set desc = "Communicate telepathically with your guardian."
	var/input = tgui_input_text(src, "Enter a message to tell your guardian", "Message")
	if (!input)
		return

	var/preliminary_message = span_boldholoparasite("[input]") //apply basic color/bolding
	var/my_message = span_boldholoparasite("<i>[src]:</i> [preliminary_message]") //add source, color source with default grey...

	to_chat(src, "<span class='say'>[my_message]</span>")
	var/list/guardians = get_all_linked_holoparasites()
	for(var/mob/living/basic/guardian/guardian as anything in guardians)
		to_chat(guardian, "<span class='say'><font color=\"[guardian.guardian_colour]\"><b><i>[src]:</i></b></font> [preliminary_message]</span>" )
	for(var/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, src)
		to_chat(dead_mob, "<span class='say'>[link] [my_message]</span>")

	src.log_talk(input, LOG_SAY, tag="guardian")


/// Tell your slacking or distracted guardian to come home.
/mob/living/proc/guardian_recall()
	set name = "Recall Guardian"
	set category = "Guardian"
	set desc = "Forcibly recall your guardian."
	var/list/guardians = get_all_linked_holoparasites()
	for(var/mob/living/basic/guardian/guardian in guardians)
		guardian.recall()


/// Replace an annoying griefer you were paired up to with a different but probably no less annoying player.
/mob/living/proc/guardian_reset()
	set name = "Reset Guardian Player (5 Minute Cooldown)"
	set category = "Guardian"
	set desc = "Re-rolls which ghost will control your Guardian. Can be used once per 5 minutes."

	var/list/guardians = get_all_linked_holoparasites()
	for(var/mob/living/basic/guardian/resetting_guardian as anything in guardians)
		if (!COOLDOWN_FINISHED(resetting_guardian, resetting_cooldown))
			guardians -= resetting_guardian //clear out guardians that are already reset

	var/mob/living/basic/guardian/chosen_guardian = tgui_input_list(src, "Pick the guardian you wish to reset", "Guardian Reset", sort_names(guardians))
	if (isnull(chosen_guardian))
		to_chat(src, span_holoparasite("You decide not to reset [length(guardians) > 1 ? "any of your guardians":"your guardian"]."))
		return

	to_chat(src, span_holoparasite("You attempt to reset <font color=\"[chosen_guardian.guardian_colour]\"><b>[chosen_guardian.real_name]</b></font>'s personality..."))
	var/list/mob/dead/observer/ghost_candidates = poll_ghost_candidates("Do you want to play as [src.real_name]'s Guardian Spirit?", ROLE_PAI, FALSE, 100)
	if (!LAZYLEN(ghost_candidates))
		to_chat(src, span_holoparasite("There were no ghosts willing to take control of <font color=\"[chosen_guardian.guardian_colour]\"><b>[chosen_guardian.real_name]</b></font>. Looks like you're stuck with it for now."))
		return

	var/mob/dead/observer/candidate = pick(ghost_candidates)
	to_chat(chosen_guardian, span_holoparasite("Your user reset you, and your body was taken over by a ghost. Looks like they weren't happy with your performance."))
	to_chat(src, span_boldholoparasite("Your <font color=\"[chosen_guardian.guardian_colour]\">[chosen_guardian.real_name]</font> has been successfully reset."))
	message_admins("[key_name_admin(candidate)] has taken control of ([ADMIN_LOOKUPFLW(chosen_guardian)])")
	chosen_guardian.ghostize(FALSE)
	chosen_guardian.key = candidate.key
	COOLDOWN_START(chosen_guardian, resetting_cooldown, 5 MINUTES)
	chosen_guardian.guardian_rename() //give it a new color and name, to show it's a new person
	chosen_guardian.guardian_recolour()
