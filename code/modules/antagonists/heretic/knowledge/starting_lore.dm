// Heretic starting knowledge.

/// Global list of all heretic knowledge that have is_starting_knowledge = TRUE. List of PATHS.
GLOBAL_LIST_INIT(heretic_start_knowledge, initialize_starting_knowledge())

/**
 * Returns a list of all heretic knowledge TYPEPATHS
 * that have route set to PATH_START.
 */
/proc/initialize_starting_knowledge()
	. = list()
	for(var/datum/heretic_knowledge/knowledge as anything in subtypesof(/datum/heretic_knowledge))
		if(initial(knowledge.is_starting_knowledge) == TRUE)
			. += knowledge

/*
 * The base heretic knowledge. Grants the Mansus Grasp spell.
 */
/datum/heretic_knowledge/spell/basic
	name = "Break of Dawn"
	desc = "Starts your journey into the Mansus.<br>\
		Grants you the Mansus Grasp, a powerful and upgradable disabling spell."
	action_to_add = /datum/action/cooldown/spell/touch/mansus_grasp
	cost = 0
	is_starting_knowledge = TRUE
	max_charges = 8
	focus_recharge_amount = 0.25
	holywater_drain_amount = 0.125
	transmute_text = "Tapping influences and completing sacrifices will recharge the spell."

// Heretics can enhance their fishing rods to fish better - fishing content.
// Lasts until successfully fishing something up.
/datum/heretic_knowledge/spell/basic/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	RegisterSignal(user, COMSIG_TOUCH_HANDLESS_CAST, PROC_REF(on_grasp_cast))
	RegisterSignal(our_heretic, COMSIG_HERETIC_INFLUENCE_DRAINED, PROC_REF(on_influence_tap))
	RegisterSignal(our_heretic, COMSIG_HERETIC_SACRIFICE, PROC_REF(on_sacrifice))

/datum/heretic_knowledge/spell/basic/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	UnregisterSignal(user, COMSIG_TOUCH_HANDLESS_CAST)
	UnregisterSignal(our_heretic, COMSIG_HERETIC_INFLUENCE_DRAINED)
	UnregisterSignal(our_heretic, COMSIG_HERETIC_SACRIFICE)

/datum/heretic_knowledge/spell/basic/proc/on_grasp_cast(mob/living/carbon/cast_on, datum/action/cooldown/spell/touch/touch_spell)
	SIGNAL_HANDLER

	// Not a grasp, we dont want this to activate with say star or mending touch.
	if(!istype(touch_spell, action_to_add))
		return NONE

	var/obj/item/fishing_rod/held_rod = cast_on.get_active_held_item()
	if(!istype(held_rod, /obj/item/fishing_rod) || HAS_TRAIT(held_rod, TRAIT_ROD_MANSUS_INFUSED))
		return NONE

	INVOKE_ASYNC(cast_on, TYPE_PROC_REF(/atom/movable, say), message = "R'CH T'H F'SH!", forced = "fishing rod infusion invocation")
	playsound(cast_on, /datum/action/cooldown/spell/touch/mansus_grasp::sound, 15)
	cast_on.visible_message(span_notice("[cast_on] snaps [cast_on.p_their()] fingers next to [held_rod], covering it in a burst of purple flames!"))

	ADD_TRAIT(held_rod, TRAIT_ROD_MANSUS_INFUSED, REF(held_rod))
	held_rod.difficulty_modifier -= 20
	RegisterSignal(held_rod, COMSIG_FISHING_ROD_CAUGHT_FISH, PROC_REF(unfuse))
	held_rod.add_filter("mansus_infusion", 2, list("type" = "outline", "color" = COLOR_VOID_PURPLE, "size" = 1))
	return COMPONENT_CAST_HANDLESS

/datum/heretic_knowledge/spell/basic/proc/unfuse(obj/item/fishing_rod/item, reward, mob/user)
	if(reward == FISHING_INFLUENCE || prob(35))
		item.remove_filter("mansus_infusion")
		REMOVE_TRAIT(item, TRAIT_ROD_MANSUS_INFUSED, REF(item))
		item.difficulty_modifier += 20

/datum/heretic_knowledge/spell/basic/proc/on_influence_tap(...)
	SIGNAL_HANDLER
	add_charges(max_charges)

/datum/heretic_knowledge/spell/basic/proc/on_sacrifice(...)
	SIGNAL_HANDLER
	add_charges(max_charges)

/**
 * The Living Heart heretic knowledge.
 *
 * Gives the heretic a living heart.
 * Also includes a ritual to turn their heart into a living heart.
 */
/datum/heretic_knowledge/living_heart
	name = "The Living Heart"
	desc = "Grants you a Living Heart, allowing you to track sacrifice targets."
	transmute_text = "Should you lose your heart, you can transmute a poppy and a pool of blood \
		to awaken your heart into a Living Heart."
	required_atoms = list(
		/obj/effect/decal/cleanable/blood = 1,
		/obj/item/food/grown/poppy = 1,
	)
	cost = 0
	priority = MAX_KNOWLEDGE_PRIORITY - 1 // Knowing how to remake your heart is important
	is_starting_knowledge = TRUE
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "living_heart"
	research_tree_icon_frame = 1
	notice = "If your heart is Cybernetic, you will be unable to reawaken it."

/datum/heretic_knowledge/living_heart/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()

	var/obj/item/organ/where_to_put_our_heart = user.get_organ_slot(our_heretic.living_heart_organ_slot)
	// Our heart slot is not valid to put a heart
	if(!is_valid_heart(where_to_put_our_heart))
		where_to_put_our_heart = null

	// If a heretic is made from a species without a heart, we need to find a backup.
	if(!where_to_put_our_heart)
		var/static/list/backup_organs = list(
			ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
			ORGAN_SLOT_LIVER = /obj/item/organ/liver,
			ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		)

		for(var/backup_slot in backup_organs)
			var/obj/item/organ/look_for_backup = user.get_organ_slot(backup_slot)
			// This backup slot is not a valid slot to put a heart
			if(!is_valid_heart(look_for_backup))
				continue

			// We found a replacement place to put our heart
			where_to_put_our_heart = look_for_backup
			our_heretic.living_heart_organ_slot = backup_slot
			to_chat(user, span_boldnotice("As your species does not have a heart, your Living Heart is located in your [look_for_backup.name]."))
			break

	if(where_to_put_our_heart)
		where_to_put_our_heart.AddComponent(/datum/component/living_heart)
		desc = "Grants you a Living Heart, tied to your [where_to_put_our_heart.name], allowing you to track sacrifice targets."
		transmute_text = "Should you lose your [where_to_put_our_heart.name], you can transmute a poppy and a pool of blood \
			to awaken your [where_to_put_our_heart.name] into a Living Heart. \
			Cybernetic [where_to_put_our_heart.name]\s will block the ritual!"

	else
		to_chat(user, span_boldnotice("You don't have a heart, or any chest organs for that matter. You didn't get a Living Heart because of it."))

/datum/heretic_knowledge/living_heart/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	var/obj/item/organ/our_living_heart = user.get_organ_slot(our_heretic.living_heart_organ_slot)
	if(our_living_heart)
		qdel(our_living_heart.GetComponent(/datum/component/living_heart))

// Don't bother letting them invoke this ritual if they have a Living Heart already in their chest
/datum/heretic_knowledge/living_heart/can_be_invoked(datum/antagonist/heretic/invoker)
	if(invoker.has_living_heart() == HERETIC_HAS_LIVING_HEART)
		return FALSE
	return TRUE

/datum/heretic_knowledge/living_heart/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/our_heretic = GET_HERETIC(user)
	var/obj/item/organ/our_living_heart = user.get_organ_slot(our_heretic.living_heart_organ_slot)
	// No heart, nothing to give living heart to
	if(QDELETED(our_living_heart))
		loc.balloon_alert(user, "ritual failed, no [our_heretic.living_heart_organ_slot]!")
		return FALSE

	// For sanity's sake, check if they've got a living heart -
	// even though it's not invokable if you already have one,
	// they may have gained one unexpectantly in between now and then
	if(HAS_TRAIT(our_living_heart, TRAIT_LIVING_HEART))
		loc.balloon_alert(user, "ritual failed, already have a living heart!")
		return FALSE

	// By this point they are making a new heart
	// If their current heart is organic / not synthetic, we can continue the ritual as normal
	if(is_valid_heart(our_living_heart))
		return TRUE

	loc.balloon_alert(user, "ritual failed, [our_heretic.living_heart_organ_slot] can't be awakened!") // "heart can't be awakened!"
	return FALSE

/datum/heretic_knowledge/living_heart/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/our_heretic = GET_HERETIC(user)
	var/obj/item/organ/our_new_heart = user.get_organ_slot(our_heretic.living_heart_organ_slot)
	// Don't delete our shiny new heart
	selected_atoms -= our_new_heart
	// Make it the living heart
	our_new_heart.AddComponent(/datum/component/living_heart)
	to_chat(user, span_warning("You feel your [our_new_heart.name] begin pulse faster and faster as it awakens!"))
	playsound(user, 'sound/effects/magic/demon_consume.ogg', 50, TRUE)
	return TRUE

/// Checks if the passed heart is a valid heart to become a living heart
/datum/heretic_knowledge/living_heart/proc/is_valid_heart(obj/item/organ/new_heart)
	if(QDELETED(new_heart))
		return FALSE
	if(new_heart.organ_flags & (ORGAN_UNUSABLE|ORGAN_ROBOTIC|ORGAN_FAILING))
		return FALSE

	return TRUE

/datum/heretic_knowledge/spell/cloak_of_shadows
	name = "Cloak of Shadow"
	desc = "Grants you the spell Cloak of Shadow.<br>\
		This spell will completely conceal your identity in a purple smoke for three minutes, assisting you in keeping secrecy."
	action_to_add = /datum/action/cooldown/spell/shadow_cloak
	cost = 0
	is_starting_knowledge = TRUE
	max_charges = 6
	focus_recharge_amount = 0.16
	holywater_drain_amount = 0.16
	transmute_text = "Charges will return every three minutes. Using the spell again will reset the timer."
	/// Cooldown for when we can give a charge back
	COOLDOWN_DECLARE(charge_time)

/datum/heretic_knowledge/spell/cloak_of_shadows/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/heretic_knowledge/spell/cloak_of_shadows/process(seconds_per_tick)
	if(charges >= max_charges)
		STOP_PROCESSING(SSobj, src)
	else if(COOLDOWN_FINISHED(src, charge_time))
		add_charges(1)
		COOLDOWN_START(src, charge_time, 3 MINUTES)

/datum/heretic_knowledge/spell/cloak_of_shadows/deduct_charge(mob/living/source, datum/action/the_spell)
	. = ..()
	if(charges >= max_charges)
		return
	START_PROCESSING(SSobj, src)
	COOLDOWN_START(src, charge_time, 2 MINUTES)

/datum/heretic_knowledge/feast_of_owls
	name = "Feast of Owls"
	desc = "Allows you to undergo a ritual that grants you five knowledge points, but locks you out of ascension."
	gain_text = "Under the soft glow of unreason there is a beast that stalks the night. I shall bring it forth and let it enter my presence. It will feast upon my amibitions and leave knowledge in its wake."
	is_starting_knowledge = TRUE
	required_atoms = list()
	research_tree_icon_path = 'icons/mob/actions/actions_animal.dmi'
	research_tree_icon_state = "god_transmit"
	notice = "This can only be done once and cannot be reverted."
	/// amount of research points granted
	var/reward = 5

/datum/heretic_knowledge/feast_of_owls/can_be_invoked(datum/antagonist/heretic/invoker)
	return !invoker.feast_of_owls

/datum/heretic_knowledge/feast_of_owls/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/alert = tgui_alert(user,"Do you really want to forsake your ascension? This action cannot be reverted.", "Feast of Owls", list("Yes I'm sure", "No"), 30 SECONDS)
	if(alert != "Yes I'm sure" || QDELETED(user) || QDELETED(src) || get_dist(user, loc) > 2)
		return FALSE
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	if(QDELETED(heretic_datum) || heretic_datum.feast_of_owls)
		return FALSE

	. = TRUE

	heretic_datum.feast_of_owls = TRUE
	heretic_datum.update_heretic_aura()
	user.set_temp_blindness(reward * 1 SECONDS)
	user.AdjustParalyzed(reward * 1 SECONDS)
	user.playsound_local(get_turf(user), 'sound/music/antag/heretic/heretic_gain_intense.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	for(var/i in 1 to reward)
		user.emote("scream")
		playsound(loc, 'sound/items/eatfood.ogg', 100, TRUE)
		heretic_datum.adjust_knowledge_points(1)

		to_chat(user, span_danger("You feel something invisible tearing away at your very essence!"))
		user.do_jitter_animation()
		sleep(1 SECONDS)
		if(QDELETED(user) || QDELETED(heretic_datum))
			return FALSE

	to_chat(user, span_danger(span_big("Your ambition is ravaged, but something powerful remains in its wake...")))
	var/drain_message = pick_list(HERETIC_INFLUENCE_FILE, "drain_message")
	to_chat(user, span_hypnophrase(span_big("[drain_message]")))
	return .
