/**
 *Increase the rat king's domain
 */

/datum/action/cooldown/mob_cooldown/domain
	name = "Rat King's Domain"
	desc = "While enabled, continuously corrupt the surrounding area to be more suitable for your rat army."
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	click_to_activate = FALSE
	cooldown_time = 1 SECONDS
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_clock"
	overlay_icon_state = "bg_clock_border"
	button_icon_state = "coffer_off"
	shared_cooldown = NONE
	/// Are we currently ticking?
	var/is_active = FALSE
	/// How often do we make a mess?
	var/mess_interval = 6 SECONDS
	/// Don't do anything if we're on this cooldown
	COOLDOWN_DECLARE(mess_cooldown)

/datum/action/cooldown/mob_cooldown/domain/IsAvailable(feedback = FALSE)
	. = ..()
	if (!.)
		return FALSE
	if (owner.movement_type & VENTCRAWLING)
		if (feedback)
			owner.balloon_alert(owner, "can't use while ventcrawling!")
		return FALSE

/datum/action/cooldown/mob_cooldown/domain/Activate(atom/target)
	StartCooldown(10 SECONDS)
	set_domain_active(!is_active)
	StartCooldown()

/datum/action/cooldown/mob_cooldown/domain/Remove(mob/removed_from)
	set_domain_active(FALSE)
	return ..()

/datum/action/cooldown/mob_cooldown/domain/update_status_on_signal(datum/source, new_stat, old_stat)
	. = ..()
	if (!IsAvailable())
		set_domain_active(FALSE)

/// Enable or disable the ability
/datum/action/cooldown/mob_cooldown/domain/proc/set_domain_active(should_active)
	if (is_active == should_active || isnull(owner))
		return
	is_active = should_active

	if (is_active)
		RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_MOVE_VENTCRAWLING), PROC_REF(cancel_on_signal))
		button_icon_state = "coffer"
		spread_domain()
	else
		UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_MOVE_VENTCRAWLING))
		button_icon_state = "coffer_off"

	build_all_button_icons(update_flags = UPDATE_BUTTON_ICON)

/// Stop spreading shit when one of these events happens
/datum/action/cooldown/mob_cooldown/domain/proc/cancel_on_signal()
	SIGNAL_HANDLER
	set_domain_active(FALSE)

/// Create gas and spawn mess
/datum/action/cooldown/mob_cooldown/domain/proc/spread_domain()
	if (!is_active || !COOLDOWN_FINISHED(src, mess_cooldown) || !owner)
		return

	var/turf/our_location = get_turf(owner)
	our_location.atmos_spawn_air("[GAS_MIASMA]=4;[TURF_TEMPERATURE(T20C)]")

	var/list/available_spots = list(our_location) + get_adjacent_open_turfs(owner)
	var/turf/mess_location = pick(available_spots)

	switch (rand(1,10))
		if (8)
			new /obj/effect/decal/cleanable/vomit(mess_location)
		if (9)
			new /obj/effect/decal/cleanable/vomit/old(mess_location)
		if (10)
			new /obj/effect/decal/cleanable/blood/oil/slippery(mess_location)
		else
			new /obj/effect/decal/cleanable/dirt(mess_location)

	COOLDOWN_START(src, mess_cooldown, mess_interval) // We use a cooldown AND timer because of the toggle
	addtimer(CALLBACK(src, PROC_REF(spread_domain)), mess_interval, TIMER_DELETE_ME)

/**
 * This action checks some nearby maintenance animals and makes them your minions.
 * If none are nearby, creates a new mouse.
 */
/datum/action/cooldown/mob_cooldown/riot
	name = "Raise Army"
	desc = "Raise an army out of the hordes of mice and pests crawling around the maintenance shafts."
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	click_to_activate = FALSE
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "riot"
	background_icon_state = "bg_clock"
	overlay_icon_state = "bg_clock_border"
	cooldown_time = 8 SECONDS
	shared_cooldown = NONE
	/// How close does something need to be for us to recruit it?
	var/range = 5

/datum/action/cooldown/mob_cooldown/riot/IsAvailable(feedback = FALSE)
	. = ..()
	if (!.)
		return FALSE
	if (owner.movement_type & VENTCRAWLING)
		if (feedback)
			owner.balloon_alert(owner, "can't use while ventcrawling!")
		return FALSE

/datum/action/cooldown/mob_cooldown/riot/Activate(atom/target)
	StartCooldown(10 SECONDS)
	riot()
	StartCooldown()

/**
 * Attempts to, in order and ending at any successful step:
 * * Convert nearby mice into aggressive rats.
 * * Convert nearby roaches into aggressive roaches.
 * * Convert nearby frogs into aggressive frogs.
 * * Spawn a single mouse if below the mouse cap.
 */
/datum/action/cooldown/mob_cooldown/riot/proc/riot()
	playsound(owner, 'sound/mobs/non-humanoids/mouse/mousesqueek.ogg', vol = 150, frequency = 10000)

	new /obj/effect/temp_visual/circle_wave/brown(get_turf(owner))
	for (var/mob/living/possible_minion in oview(owner, range))
		SEND_SIGNAL(possible_minion, COMSIG_REGAL_RAT_RIOTED, owner)

/obj/effect/temp_visual/circle_wave/brown
	color = COLOR_BROWN
	amount_to_scale = 4

// Command you can give to a mouse to make it kill someone
/datum/pet_command/attack/mouse
	speech_commands = list("attack", "sic", "kill", "cheese em")
	command_feedback = "squeak!" // Frogs and roaches can squeak too it's fine
	pointed_reaction = "and squeaks aggressively"
	refuse_reaction = "quivers"
	attack_behaviour = /datum/ai_behavior/basic_melee_attack

// Command you can give to a mouse to make it kill someone
/datum/pet_command/attack/glockroach
	speech_commands = list("attack", "sic", "kill", "cheese em")
	command_feedback = "squeak!"
	pointed_reaction = "and cocks its gun"
	refuse_reaction = "quivers"
	attack_behaviour = /datum/ai_behavior/basic_ranged_attack/glockroach

/**
 *Spittle; harmless reagent that is added by rat king, and makes you disgusted.
 */

/datum/reagent/rat_spit
	name = "Rat Spit"
	description = "Something coming from a rat. Dear god! Who knows where it's been!"
	color = "#C8C8C8"
	metabolization_rate = 0.03 * REAGENTS_METABOLISM
	taste_description = "something funny"
	overdose_threshold = 20

/datum/reagent/rat_spit/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	if(HAS_TRAIT(affected_mob, TRAIT_AGEUSIA))
		return
	to_chat(affected_mob, span_notice("This food has a funny taste!"))

/datum/reagent/rat_spit/overdose_start(mob/living/affected_mob)
	. = ..()
	var/mob/living/carbon/victim = affected_mob
	if (istype(victim) && !(FACTION_RAT in victim.faction))
		to_chat(victim, span_userdanger("With this last sip, you feel your body convulsing horribly from the contents you've ingested. As you contemplate your actions, you sense an awakened kinship with rat-kind and their newly risen leader!"))
		victim.faction |= FACTION_RAT
		victim.vomit(VOMIT_CATEGORY_DEFAULT)
	metabolization_rate = 10 * REAGENTS_METABOLISM

/datum/reagent/rat_spit/on_mob_life(mob/living/carbon/affected_mob)
	. = ..()
	if(prob(15))
		to_chat(affected_mob, span_notice("You feel queasy!"))
		affected_mob.adjust_disgust(3)
	else if(prob(10))
		to_chat(affected_mob, span_warning("That food does not sit up well!"))
		affected_mob.adjust_disgust(5)
	else if(prob(5))
		affected_mob.vomit(VOMIT_CATEGORY_DEFAULT)

/datum/pet_command/protect_owner/glockroach
	protect_behavior = /datum/ai_behavior/basic_ranged_attack/glockroach
