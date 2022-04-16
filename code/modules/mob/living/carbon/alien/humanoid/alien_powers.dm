/*NOTES:
These are general powers. Specific powers are stored under the appropriate alien creature type.
*/

/*Alien spit now works like a taser shot. It won't home in on the target but will act the same once it does hit.
Doesn't work on other aliens/AI.*/


/datum/action/cooldown/alien
	name = "Alien Power"
	panel = "Alien"
	background_icon_state = "bg_alien"
	icon_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "spell_default"
	check_flags = AB_CHECK_CONSCIOUS
	/// How much plasma this action uses.
	var/plasma_cost = 0

/datum/action/cooldown/alien/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	if(carbon_owner.getPlasma() < plasma_cost)
		return FALSE

	return TRUE

/datum/action/cooldown/alien/PreActivate(atom/target)
	// Parent calls Activate(), so if parent returns TRUE,
	// it means the activation happened successfuly by this point
	. = ..()
	if(!.)
		return FALSE
	// Xeno actions like "evolve" may result in our action being deleted
	// In that case, we can just exit now as a "success"
	if(QDELETED(src))
		return TRUE

	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.adjustPlasma(-plasma_cost)
	return TRUE

/datum/action/cooldown/alien/set_statpanel_format()
	. = ..()
	.[PANEL_DISPLAY_COOLDOWN] = "[plasma_cost]"

/datum/action/cooldown/alien/make_structure
	/// The type of structure the action makes on use
	var/obj/structure/made_structure_type

/datum/action/cooldown/alien/make_structure/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	if(!isturf(owner.loc) || isspaceturf(owner.loc))
		return FALSE

	return TRUE

/datum/action/cooldown/alien/make_structure/PreActivate(atom/target)
	if(!check_for_duplicate())
		return FALSE

	if(!check_for_vents())
		return FALSE

	return ..()

/datum/action/cooldown/alien/make_structure/Activate(atom/target)
	new made_structure_type(owner.loc)
	return TRUE

/// Checks if there's a duplicate structure in the owner's turf
/datum/action/cooldown/alien/make_structure/proc/check_for_duplicate()
	var/obj/structure/existing_thing = locate(made_structure_type) in owner.loc
	if(existing_thing)
		to_chat(owner, span_warning("There is already \a [existing_thing] here!"))
		return FALSE

	return TRUE

/// Checks if there's an atmos machine (vent) in the owner's turf
/datum/action/cooldown/alien/make_structure/proc/check_for_vents()
	var/obj/machinery/atmospherics/components/unary/atmos_thing = locate() in owner.loc
	if(atmos_thing)
		var/are_you_sure = tgui_alert(owner, "Laying eggs and shaping resin here would block access to [atmos_thing]. Do you want to continue?", "Blocking Atmospheric Component", list("Yes", "No"))
		if(are_you_sure != "Yes")
			return FALSE
		if(QDELETED(src) || QDELETED(owner) || !check_for_duplicate())
			return FALSE

	return TRUE

/datum/action/cooldown/alien/make_structure/plant_weeds
	name = "Plant Weeds"
	desc = "Plants some alien weeds."
	button_icon_state = "alien_plant"
	plasma_cost = 50
	made_structure_type = /obj/structure/alien/weeds/node

/datum/action/cooldown/alien/make_structure/plant_weeds/Activate(atom/target)
	owner.visible_message(span_alertalien("[owner] plants some alien weeds!"))
	return ..()

/datum/action/cooldown/alien/whisper
	name = "Whisper"
	desc = "Whisper to someone."
	button_icon_state = "alien_whisper"
	plasma_cost = 10

/datum/action/cooldown/alien/whisper/Activate(atom/target)
	var/list/possible_recipients = list()
	for(var/mob/living/recipient in oview(owner))
		possible_recipients += recipient

	if(!length(possible_recipients))
		to_chat(owner, span_noticealien("There's no one around to whisper to."))
		return FALSE

	var/mob/living/chosen_recipient = tgui_input_list(owner, "Select whisper recipient", "Whisper", sort_names(possible_recipients))
	if(QDELETED(chosen_recipient) || QDELETED(src) || QDELETED(owner)|| !IsAvailable())
		return FALSE
	if(chosen_recipient.can_block_magic(MAGIC_RESISTANCE_MIND, charge_cost = 0))
		to_chat(owner, span_warning("As you reach into [chosen_recipient]'s mind, you are stopped by a mental blockage. It seems you've been foiled."))
		return FALSE

	var/to_whisper = tgui_input_text(owner, title = "Alien Whisper")
	if(QDELETED(chosen_recipient) || QDELETED(src) || QDELETED(owner) || !IsAvailable() || !to_whisper)
		return FALSE
	if(chosen_recipient.can_block_magic(MAGIC_RESISTANCE_MIND, charge_cost = 0))
		to_chat(owner, span_warning("As you reach into [chosen_recipient]'s mind, you are stopped by a mental blockage. It seems you've been foiled."))
		return FALSE

	log_directed_talk(owner, chosen_recipient, to_whisper, LOG_SAY, tag = "alien whisper")
	to_chat(chosen_recipient, "[span_noticealien("You hear a strange, alien voice in your head...")][to_whisper]")
	to_chat(owner, span_noticealien("You said: \"[to_whisper]\" to [chosen_recipient]"))
	for(var/mob/dead_mob as anything in GLOB.dead_mob_list)
		if(!isobserver(dead_mob))
			continue
		var/follow_link_user = FOLLOW_LINK(dead_mob, owner)
		var/follow_link_whispee = FOLLOW_LINK(dead_mob, chosen_recipient)
		to_chat(dead_mob, "[follow_link_user] [span_name("[owner]")] [span_alertalien("Alien Whisper --> ")] [follow_link_whispee] [span_name("[chosen_recipient]")] [span_noticealien("[to_whisper]")]")

	return TRUE

/datum/action/cooldown/alien/transfer
	name = "Transfer Plasma"
	desc = "Transfer Plasma to another alien."
	plasma_cost = 0
	button_icon_state = "alien_transfer"

/datum/action/cooldown/alien/transfer/Activate(atom/target)
	var/mob/living/carbon/carbon_owner = owner
	var/list/mob/living/carbon/aliens_around = list()
	for(var/mob/living/carbon/alien in view(owner))
		if(alien.getPlasma() == -1 || alien == owner)
			continue
		aliens_around += alien

	if(!length(aliens_around))
		to_chat(owner, span_noticealien("There are no other aliens around."))
		return FALSE

	var/mob/living/carbon/donation_target = tgui_input_list(owner, "Target to transfer to", "Plasma Donation", sort_names(aliens_around))
	if(QDELETED(donation_target) || QDELETED(src) || QDELETED(owner) || !IsAvailable())
		return FALSE

	var/amount = tgui_input_number(owner, "Amount", "Transfer Plasma to [donation_target]", max_value = carbon_owner.getPlasma())
	if(QDELETED(donation_target) || QDELETED(src) || QDELETED(owner) || !IsAvailable() || isnull(amount) || amount <= 0)
		return FALSE

	if (get_dist(owner, donation_target) > 1)
		to_chat(owner, span_noticealien("You need to be closer!"))
		return FALSE

	donation_target.adjustPlasma(amount)
	carbon_owner.adjustPlasma(-amount)

	to_chat(donation_target, span_noticealien("[owner] has transferred [amount] plasma to you."))
	to_chat(owner, span_noticealien("You transfer [amount] plasma to [donation_target]."))
	return TRUE


/datum/action/cooldown/alien/acid
	name = "Corrosive Acid"
	desc = "Drench an object in acid, destroying it over time."
	button_icon_state = "alien_acid"
	click_to_activate = TRUE // MELBERT TODO cl
	unset_after_click = FALSE
	plasma_cost = 200

/datum/action/cooldown/alien/acid/set_click_ability(mob/on_who)
	. = ..()
	if(!.)
		return

	to_chat(on_who, span_noticealien("You prepare to vomit acid. <b>Click a target to acid it!</b>"))

	if(isalienadult(on_who))
		var/mob/living/carbon/alien/humanoid/alien = on_who
		alien.drooling = TRUE
		alien.update_icons()

/datum/action/cooldown/alien/acid/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(!.)
		return

	if(refund_cooldown)
		to_chat(on_who, span_noticealien("You empty your corrosive acid glands."))

	if(isalienadult(on_who))
		var/mob/living/carbon/alien/humanoid/alien = on_who // MELBERT TODO cl
		alien.drooling = FALSE
		alien.update_icons()

/datum/action/cooldown/alien/acid/PreActivate(atom/target)
	if(get_dist(owner, target) > 1)
		return FALSE

	return ..()

/datum/action/cooldown/alien/acid/Activate(atom/target)
	if(!target.acid_act(200, 1000))
		to_chat(owner, span_noticealien("You cannot dissolve this object."))
		return FALSE

	owner.visible_message(
		span_alertalien("[owner] vomits globs of vile stuff all over [target]. It begins to sizzle and melt under the bubbling mess of acid!"),
		span_noticealien("You vomit globs of acid over [target]. It begins to sizzle and melt."),
	)
	return TRUE

/datum/action/cooldown/alien/neurotoxin
	name = "Spit Neurotoxin"
	desc = "Spits neurotoxin at someone, paralyzing them for a short time."
	button_icon_state = "alien_neurotoxin_0"
	click_to_activate = TRUE
	unset_after_click = FALSE
	plasma_cost = 50

/datum/action/cooldown/alien/neurotoxin/IsAvailable()
	return ..() && isturf(owner.loc)

/datum/action/cooldown/alien/neurotoxin/set_click_ability(mob/on_who)
	. = ..()
	if(!.)
		return

	to_chat(on_who, span_notice("You prepare your neurotoxin gland. <B>Left-click to fire at a target!</B>"))

	button_icon_state = "alien_neurotoxin_1"
	UpdateButtons()

	if(isalienadult(on_who))
		var/mob/living/carbon/alien/humanoid/alien = on_who
		alien.drooling = TRUE
		alien.update_icons()

/datum/action/cooldown/alien/neurotoxin/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(!.)
		return

	if(refund_cooldown)
		to_chat(on_who, span_notice("You empty your neurotoxin gland."))

	button_icon_state = "alien_neurotoxin_0"
	UpdateButtons()

	if(isalienadult(on_who))
		var/mob/living/carbon/alien/humanoid/alien = on_who
		alien.drooling = FALSE
		alien.update_icons()

/datum/action/cooldown/alien/neurotoxin/InterceptClickOn(mob/living/caller, params, atom/target)
	. = ..()
	if(!.)
		unset_click_ability(caller, refund_cooldown = FALSE)
		return FALSE

	// We do this in InterceptClickOn() instead of Activate()
	// because we use the click parameters for aiming the projectile
	// (or something like that)
	var/turf/user_turf = caller.loc
	var/turf/target_turf = get_step(caller, target.dir) // Get the tile infront of the move, based on their direction
	if(!isturf(target_turf))
		return FALSE

	var/modifiers = params2list(params)
	caller.visible_message(
		span_danger("[caller] spits neurotoxin!"),
		span_alertalien("You spit neurotoxin."),
	)
	var/obj/projectile/neurotoxin/neurotoxin = new /obj/projectile/neurotoxin(caller.loc)
	neurotoxin.preparePixelProjectile(target, caller, modifiers)
	neurotoxin.firer = caller
	neurotoxin.fire()
	caller.newtonian_move(get_dir(target_turf, user_turf))
	return TRUE

// Has to return TRUE, otherwise is skipped.
/datum/action/cooldown/alien/neurotoxin/Activate(atom/target)
	return TRUE

/datum/action/cooldown/alien/make_structure/resin
	name = "Secrete Resin"
	desc = "Secrete tough malleable resin."
	button_icon_state = "alien_resin"
	plasma_cost = 55
	/// A list of all structures we can make.
	var/static/list/structures = list(
		"resin wall" = /obj/structure/alien/resin/wall,
		"resin membrane" = /obj/structure/alien/resin/membrane,
		"resin nest" = /obj/structure/bed/nest,
	)

// Snowflake to check for multiple types of alien resin structures
/datum/action/cooldown/alien/make_structure/resin/check_for_duplicate()
	for(var/obj/structure/blocker_type as anything in structures)
		if(locate(blocker_type) in owner.loc)
			to_chat(owner, span_warning("There is already a resin structure there!"))
			return FALSE

	return TRUE

/datum/action/cooldown/alien/make_structure/resin/Activate(atom/target)
	var/choice = tgui_input_list(owner, "Select a shape to build", "Resin building", structures)
	if(isnull(choice) || QDELETED(src) || QDELETED(owner) || !check_for_duplicate() || !IsAvailable())
		return FALSE
	var/obj/structure/choice_path = structures[choice]
	if(!ispath(choice_path))
		return FALSE

	owner.visible_message(
		span_notice("[owner] vomits up a thick purple substance and begins to shape it."),
		span_notice("You shape a [choice] out of resin."),
	)

	new choice_path(owner.loc)
	return TRUE

/datum/action/cooldown/alien/sneak
	name = "Sneak"
	desc = "Blend into the shadows to stalk your prey."
	button_icon_state = "alien_sneak"
	/// Whether we're currently sneaking or not
	var/sneaking = FALSE

/datum/action/cooldown/alien/sneak/Activate(atom/target)
	if(sneaking)
		sneaking = FALSE
		owner.alpha = initial(owner.alpha)
		if(isalien(owner))
			var/mob/living/carbon/alien/humanoid/alien = owner
			alien.sneaking = FALSE
		to_chat(owner, span_noticealien("You reveal yourself!"))

	else
		sneaking = TRUE
		// Still easy to see in lit areas with bright tiles, almost invisible on resin.
		owner.alpha = 75
		if(isalien(owner))
			var/mob/living/carbon/alien/humanoid/alien = owner
			alien.sneaking = TRUE
		to_chat(owner, span_noticealien("You blend into the shadows..."))


/// Gets the plasma level of this carbon's plasma vessel, or -1 if they don't have one
/mob/living/carbon/proc/getPlasma()
	var/obj/item/organ/alien/plasmavessel/vessel = getorgan(/obj/item/organ/alien/plasmavessel)
	if(!vessel)
		return -1
	return vessel.stored_plasma

/// Adjusts the plasma level of the carbon's plasma vessel if they have one
/mob/living/carbon/proc/adjustPlasma(amount)
	var/obj/item/organ/alien/plasmavessel/vessel = getorgan(/obj/item/organ/alien/plasmavessel)
	if(!vessel)
		return FALSE
	vessel.stored_plasma = max(vessel.stored_plasma + amount,0)
	vessel.stored_plasma = min(vessel.stored_plasma, vessel.max_plasma) //upper limit of max_plasma, lower limit of 0
	for(var/datum/action/cooldown/alien/ability in actions)
		ability.UpdateButtons()
	return TRUE

/mob/living/carbon/alien/adjustPlasma(amount)
	. = ..()
	updatePlasmaDisplay()
