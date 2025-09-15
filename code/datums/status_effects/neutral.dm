//entirely neutral or internal status effects go here

/datum/status_effect/crusher_damage
	id = "crusher_damage"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	/// How much damage?
	var/total_damage = 0

/datum/status_effect/crusher_damage/on_apply()
	RegisterSignal(owner, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(damage_taken))
	return TRUE

/datum/status_effect/crusher_damage/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_AFTER_APPLY_DAMAGE)

/datum/status_effect/crusher_damage/proc/damage_taken(
	datum/source,
	damage_dealt,
	damagetype,
	def_zone,
	blocked,
	wound_bonus,
	exposed_wound_bonus,
	sharpness,
	attack_direction,
	attacking_item,
)
	SIGNAL_HANDLER

	if(istype(attacking_item, /obj/item/kinetic_crusher))
		total_damage += damage_dealt

/datum/status_effect/syphon_mark
	id = "syphon_mark"
	duration = 50
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	on_remove_on_mob_delete = TRUE
	var/obj/item/borg/upgrade/modkit/bounty/reward_target

/datum/status_effect/syphon_mark/on_creation(mob/living/new_owner, obj/item/borg/upgrade/modkit/bounty/new_reward_target)
	. = ..()
	if(.)
		reward_target = new_reward_target

/datum/status_effect/syphon_mark/on_apply()
	if(owner.stat == DEAD)
		return FALSE
	return ..()

/datum/status_effect/syphon_mark/proc/get_kill()
	if(!QDELETED(reward_target))
		reward_target.get_kill(owner)

/datum/status_effect/syphon_mark/tick(seconds_between_ticks)
	if(owner.stat == DEAD)
		get_kill()
		qdel(src)

/datum/status_effect/syphon_mark/on_remove()
	get_kill()
	. = ..()

/atom/movable/screen/alert/status_effect/in_love
	name = "In Love"
	desc = "You feel so wonderfully in love!"
	icon_state = "in_love"

/datum/status_effect/in_love
	id = "in_love"
	duration = STATUS_EFFECT_PERMANENT
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/in_love
	var/hearts

/datum/status_effect/in_love/on_creation(mob/living/new_owner, mob/living/date)
	. = ..()
	if(!.)
		return

	linked_alert.desc = "You're in love with [date.real_name]! How lovely."
	hearts = WEAKREF(date.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/one_person,
		"in_love",
		image(icon = 'icons/effects/effects.dmi', icon_state = "love_hearts", loc = date),
		null,
		new_owner,
	))

/datum/status_effect/in_love/on_remove()
	QDEL_NULL(hearts)

/datum/status_effect/throat_soothed
	id = "throat_soothed"
	duration = 60 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/throat_soothed/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_SOOTHED_THROAT, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/throat_soothed/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_SOOTHED_THROAT, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/headache_soothed
	id = "headache_soothed"
	duration = 60 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/headache_soothed/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_SOOTHED_HEADACHE, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/headache_soothed/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_SOOTHED_HEADACHE, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/bounty
	id = "bounty"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/mob/living/rewarded

/datum/status_effect/bounty/on_creation(mob/living/new_owner, mob/living/caster)
	. = ..()
	if(.)
		rewarded = caster

/datum/status_effect/bounty/on_apply()
	to_chat(owner, span_boldnotice("You hear something behind you talking... \"You have been marked for death by [rewarded]. If you die, they will be rewarded.\""))
	playsound(owner, 'sound/items/weapons/gun/shotgun/rack.ogg', 75, FALSE)
	return ..()

/datum/status_effect/bounty/tick(seconds_between_ticks)
	if(owner.stat == DEAD)
		rewards()
		qdel(src)

/datum/status_effect/bounty/proc/rewards()
	if(rewarded && rewarded.mind && rewarded.stat != DEAD)
		to_chat(owner, span_boldnotice("You hear something behind you talking... \"Bounty claimed.\""))
		playsound(owner, 'sound/items/weapons/gun/shotgun/shot.ogg', 75, FALSE)
		to_chat(rewarded, span_greentext("You feel a surge of mana flow into you!"))
		for(var/datum/action/cooldown/spell/spell in rewarded.actions)
			spell.reset_spell_cooldown()

		var/need_mob_update = FALSE
		need_mob_update += rewarded.adjustBruteLoss(-25, updating_health = FALSE)
		need_mob_update += rewarded.adjustFireLoss(-25, updating_health = FALSE)
		need_mob_update += rewarded.adjustToxLoss(-25, updating_health = FALSE)
		need_mob_update += rewarded.adjustOxyLoss(-25, updating_health = FALSE)
		if(need_mob_update)
			rewarded.updatehealth()

// heldup is for the person being aimed at
/datum/status_effect/grouped/heldup
	id = "heldup"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = /atom/movable/screen/alert/status_effect/heldup

/atom/movable/screen/alert/status_effect/heldup
	name = "Held Up"
	desc = "Making any sudden moves would probably be a bad idea!"
	icon_state = "aimed"

/datum/status_effect/grouped/heldup/on_apply()
	owner.apply_status_effect(/datum/status_effect/grouped/surrender, REF(src))
	return ..()

/datum/status_effect/grouped/heldup/on_remove()
	owner.remove_status_effect(/datum/status_effect/grouped/surrender, REF(src))
	return ..()

// holdup is for the person aiming
/datum/status_effect/holdup
	id = "holdup"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/holdup

/atom/movable/screen/alert/status_effect/holdup
	name = "Holding Up"
	desc = "You're currently pointing a gun at someone. Click to cancel."
	icon_state = "aimed"
	clickable_glow = TRUE

/atom/movable/screen/alert/status_effect/holdup/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/datum/component/gunpoint/gunpoint = owner.GetComponent(/datum/component/gunpoint)
	gunpoint?.cancel()

// this status effect is used to negotiate the high-fiving capabilities of all concerned parties
/datum/status_effect/offering
	id = "offering"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	/// The people who were offered this item at the start
	var/list/possible_takers
	/// The actual item being offered
	var/obj/item/offered_item
	/// The type of alert given to people when offered, in case you need to override some behavior (like for high-fives)
	var/give_alert_type = /atom/movable/screen/alert/give

/datum/status_effect/offering/on_creation(mob/living/new_owner, obj/item/offer, give_alert_override, mob/living/offered)
	. = ..()
	if(!.)
		return
	offered_item = offer
	if(give_alert_override)
		give_alert_type = give_alert_override

	if(offered && is_taker_elligible(offered))
		register_candidate(offered)
	else
		for(var/mob/living/possible_taker in orange(1, owner))
			if(!is_taker_elligible(possible_taker))
				continue

			register_candidate(possible_taker)

	if(!possible_takers) // no one around
		qdel(src)
		return

	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(check_owner_in_range))
	RegisterSignals(offered_item, list(COMSIG_QDELETING, COMSIG_ITEM_DROPPED), PROC_REF(dropped_item))

/datum/status_effect/offering/Destroy()
	for(var/mob/living/removed_taker as anything in possible_takers)
		remove_candidate(removed_taker)
	LAZYCLEARLIST(possible_takers)
	offered_item = null
	return ..()

/// Hook up the specified living mob to be offered the item in question, give them the alert and signals and all
/datum/status_effect/offering/proc/register_candidate(mob/living/possible_candidate)
	var/atom/movable/screen/alert/give/G = possible_candidate.throw_alert("[owner]", give_alert_type)
	if(!G)
		return
	LAZYADD(possible_takers, possible_candidate)
	RegisterSignal(possible_candidate, COMSIG_MOVABLE_MOVED, PROC_REF(check_taker_in_range))
	G.setup(possible_candidate, src)

/// Remove the alert and signals for the specified living mob. Automatically removes the status effect when we lost the last taker
/datum/status_effect/offering/proc/remove_candidate(mob/living/removed_candidate)
	removed_candidate.clear_alert("[owner]")
	LAZYREMOVE(possible_takers, removed_candidate)
	UnregisterSignal(removed_candidate, COMSIG_MOVABLE_MOVED)
	if(!possible_takers && !QDELING(src))
		qdel(src)

/// One of our possible takers moved, see if they left us hanging
/datum/status_effect/offering/proc/check_taker_in_range(mob/living/taker)
	SIGNAL_HANDLER
	if(owner.CanReach(taker) && !IS_DEAD_OR_INCAP(taker))
		return

	to_chat(taker, span_warning("You moved out of range of [owner]!"))
	remove_candidate(taker)

/// The offerer moved, see if anyone is out of range now
/datum/status_effect/offering/proc/check_owner_in_range(mob/living/source)
	SIGNAL_HANDLER

	for(var/mob/living/checking_taker as anything in possible_takers)
		if(!istype(checking_taker) || !owner.CanReach(checking_taker) || IS_DEAD_OR_INCAP(checking_taker))
			remove_candidate(checking_taker)

/// We lost the item, give it up
/datum/status_effect/offering/proc/dropped_item(obj/item/source)
	SIGNAL_HANDLER
	qdel(src)

/**
 * Is our taker valid as a target for the offering? Meant to be used when registering
 * takers in `on_creation()`. You should override `additional_taker_check()` instead of this.
 *
 * Returns `TRUE` if the taker is valid as a target for the offering.
 */
/datum/status_effect/offering/proc/is_taker_elligible(mob/living/taker)
	return owner.CanReach(taker) && !IS_DEAD_OR_INCAP(taker) && additional_taker_check(taker)

/**
 * Additional checks added to `CanReach()` and `IS_DEAD_OR_INCAP()` in `is_taker_elligible()`.
 * Should be what you override instead of `is_taker_elligible()`. By default, checks if the
 * taker can hold items.
 *
 * Returns `TRUE` if the taker is valid as a target for the offering based on these
 * additional checks.
 */
/datum/status_effect/offering/proc/additional_taker_check(mob/living/taker)
	return taker.can_hold_items()

/**
 * This status effect is meant only for items that you don't actually receive
 * when offered, mostly useful for `/obj/item/hand_item` subtypes.
 */
/datum/status_effect/offering/no_item_received

/datum/status_effect/offering/no_item_received/additional_taker_check(mob/living/taker)
	return taker.usable_hands > 0

/**
 * This status effect is meant only to be used for offerings that require the target to
 * be resting (like when you're trying to give them a hand to help them up).
 * Also doesn't require them to have their hands free (since you're not giving them
 * anything).
 */
/datum/status_effect/offering/no_item_received/needs_resting

/datum/status_effect/offering/no_item_received/needs_resting/additional_taker_check(mob/living/taker)
	return taker.body_position == LYING_DOWN

/datum/status_effect/offering/no_item_received/needs_resting/on_creation(mob/living/new_owner, obj/item/offer, give_alert_override, mob/living/offered)
	. = ..()
	RegisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(check_owner_standing))

/datum/status_effect/offering/no_item_received/needs_resting/register_candidate(mob/living/possible_candidate)
	. = ..()
	RegisterSignal(possible_candidate, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(check_candidate_resting))

/datum/status_effect/offering/no_item_received/needs_resting/remove_candidate(mob/living/removed_candidate)
	UnregisterSignal(removed_candidate, COMSIG_LIVING_SET_BODY_POSITION)
	return ..()

/// Simple signal handler that ensures that, if the owner stops standing, the offer no longer stands either!
/datum/status_effect/offering/no_item_received/needs_resting/proc/check_owner_standing(mob/living/owner)
	if(src.owner.body_position == STANDING_UP)
		return

	// This doesn't work anymore if the owner is no longer standing up, sorry!
	qdel(src)

/// Simple signal handler that ensures that, should a candidate now be standing up, the offer won't be standing for them anymore!
/datum/status_effect/offering/no_item_received/needs_resting/proc/check_candidate_resting(mob/living/candidate)
	SIGNAL_HANDLER

	if(candidate.body_position == LYING_DOWN)
		return

	// No longer lying down? You're no longer eligible to take the offer, sorry!
	remove_candidate(candidate)

/// Subtype for high fives, so we can fake out people
/datum/status_effect/offering/no_item_received/high_five
	id = "offer_high_five"

/datum/status_effect/offering/no_item_received/high_five/dropped_item(obj/item/source)
	// Lets us "too slow" people, instead of qdeling we just handle the ref
	offered_item = null

//this effect gives the user an alert they can use to surrender quickly
/datum/status_effect/grouped/surrender
	id = "surrender"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/surrender

/atom/movable/screen/alert/status_effect/surrender
	name = "Surrender"
	desc = "Looks like you're in trouble now, bud. Click here to surrender. (Warning: You will be incapacitated.)"
	icon_state = "surrender"
	clickable_glow = TRUE

/atom/movable/screen/alert/status_effect/surrender/Click(location, control, params)
	. = ..()
	if(!.)
		return

	owner.emote("surrender")

///For when you need to make someone be prompted for surrender, but not forever
/datum/status_effect/surrender_timed
	id = "surrender_timed"
	duration = 30 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null

/datum/status_effect/surrender_timed/on_apply()
	owner.apply_status_effect(/datum/status_effect/grouped/surrender, REF(src))
	return ..()

/datum/status_effect/surrender_timed/on_remove()
	owner.remove_status_effect(/datum/status_effect/grouped/surrender, REF(src))
	return ..()


/*
 * A status effect used for preventing caltrop message spam
 *
 * While a mob has this status effect, they won't receive any messages about
 * stepping on caltrops. But they will be stunned and damaged regardless.
 *
 * The status effect itself has no effect, other than to disappear after
 * a second.
 */
/datum/status_effect/caltropped
	id = "caltropped"
	duration = 1 SECONDS
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

#define EIGENSTASIUM_MAX_BUFFER -251
#define EIGENSTASIUM_STABILISATION_RATE 5
#define EIGENSTASIUM_PHASE_1_END 50
#define EIGENSTASIUM_PHASE_2_END 80
#define EIGENSTASIUM_PHASE_3_START 100
#define EIGENSTASIUM_PHASE_3_END 150

/datum/status_effect/eigenstasium
	id = "eigenstasium"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	///So we know what cycle we're in during the status
	var/current_cycle = EIGENSTASIUM_MAX_BUFFER //Consider it your stability
	///The addiction looper for addiction stage 3
	var/phase_3_cycle = -0 //start off delayed
	///Your clone from another reality
	var/mob/living/carbon/alt_clone = null
	///If we display the stabilised message or not
	var/stable_message = FALSE

/datum/status_effect/eigenstasium/Destroy()
	if(alt_clone)
		UnregisterSignal(alt_clone, COMSIG_QDELETING)
		QDEL_NULL(alt_clone)
	return ..()

/datum/status_effect/eigenstasium/tick(seconds_between_ticks)
	. = ..()
	//This stuff runs every cycle
	if(prob(5))
		do_sparks(5, FALSE, owner)

	//If we have a reagent that blocks the effects
	var/block_effects = FALSE
	if(owner.has_reagent(/datum/reagent/bluespace))
		current_cycle = max(EIGENSTASIUM_MAX_BUFFER, (current_cycle - (EIGENSTASIUM_STABILISATION_RATE * 1.5))) //cap to -250
		block_effects = TRUE
	if(owner.has_reagent(/datum/reagent/stabilizing_agent))
		current_cycle = max(EIGENSTASIUM_MAX_BUFFER, (current_cycle - EIGENSTASIUM_STABILISATION_RATE))
		block_effects = TRUE
	var/datum/reagent/eigen = owner.has_reagent(/datum/reagent/eigenstate)
	if(eigen)
		if(eigen.overdosed)
			block_effects = FALSE
		else
			current_cycle = max(EIGENSTASIUM_MAX_BUFFER, (current_cycle - (EIGENSTASIUM_STABILISATION_RATE * 2)))
			block_effects = TRUE

	if(!QDELETED(alt_clone)) //catch any stragglers
		do_sparks(5, FALSE, alt_clone)
		owner.visible_message("[owner] is snapped across to a different alternative reality!")
		QDEL_NULL(alt_clone)

	if(block_effects)
		if(!stable_message)
			owner.visible_message("You feel stable...for now.")
			stable_message = TRUE
		return
	stable_message = FALSE


	//Increment cycle
	current_cycle++ //needs to be done here because phase 2 can early return

	//These run on specific cycles
	switch(current_cycle)
		if(0)
			to_chat(owner, span_userdanger("You feel like you're being pulled across to somewhere else. You feel empty inside."))

		//phase 1
		if(1 to EIGENSTASIUM_PHASE_1_END)
			owner.set_jitter_if_lower(4 SECONDS)
			owner.adjust_nutrition(-4)

		//phase 2
		if(EIGENSTASIUM_PHASE_1_END to EIGENSTASIUM_PHASE_2_END)
			if(current_cycle == 51)
				to_chat(owner, span_userdanger("You start to convlse violently as you feel your consciousness merges across realities, your possessions flying wildy off your body!"))
				owner.set_jitter_if_lower(400 SECONDS)
				owner.Knockdown(10)

			var/list/items = list()
			var/max_loop
			if (length(owner.get_contents()) >= 10)
				max_loop = 10
			else
				max_loop = length(owner.get_contents())
			for (var/i in 1 to max_loop)
				var/obj/item/item = owner.get_contents()[i]
				if ((item.item_flags & DROPDEL) || HAS_TRAIT(item, TRAIT_NODROP)) // can't teleport these kinds of items
					continue
				items.Add(item)

			if(!LAZYLEN(items))
				return ..()
			var/obj/item/item = pick(items)
			owner.dropItemToGround(item, TRUE)
			do_sparks(5,FALSE,item)
			do_teleport(item, get_turf(item), 3, no_effects=TRUE);
			do_sparks(5,FALSE,item)

		//phase 3 - little break to get your items
		if(EIGENSTASIUM_PHASE_3_START to EIGENSTASIUM_PHASE_3_END)
			//Clone function - spawns a clone then deletes it - simulates multiple copies of the player teleporting in
			switch(phase_3_cycle) //Loops 0 -> 1 -> 2 -> 1 -> 2 -> 1 ...ect.
				if(0)
					owner.set_jitter_if_lower(200 SECONDS)
					to_chat(owner, span_userdanger("Your eigenstate starts to rip apart, drawing in alternative reality versions of yourself!"))
				if(1)
					var/typepath = owner.type
					alt_clone = new typepath(owner.loc)
					alt_clone.appearance = owner.appearance
					alt_clone.real_name = owner.real_name
					RegisterSignal(alt_clone, COMSIG_QDELETING, PROC_REF(remove_clone_from_var))
					owner.visible_message("[owner] splits into seemingly two versions of themselves!")
					do_teleport(alt_clone, get_turf(alt_clone), 2, no_effects=TRUE) //teleports clone so it's hard to find the real one!
					do_sparks(5,FALSE,alt_clone)
					alt_clone.emote("spin")
					owner.emote("spin")
					var/list/say_phrases = strings(EIGENSTASIUM_FILE, "lines")
					alt_clone.say(pick(say_phrases))
				if(2)
					phase_3_cycle = 0 //counter
			phase_3_cycle++
			do_teleport(owner, get_turf(owner), 2, no_effects=TRUE) //Teleports player randomly
			do_sparks(5, FALSE, owner)

		//phase 4
		if(EIGENSTASIUM_PHASE_3_END to INFINITY)
			//clean up and remove status
			SSblackbox.record_feedback("tally", "chemical_reaction", 1, "Eigenstasium wild rides ridden")
			do_sparks(5, FALSE, owner)
			do_teleport(owner, get_turf(owner), 2, no_effects=TRUE) //teleports clone so it's hard to find the real one!
			do_sparks(5, FALSE, owner)
			owner.Sleeping(100)
			owner.set_jitter_if_lower(100 SECONDS)
			to_chat(owner, span_userdanger("You feel your eigenstate settle, as \"you\" become an alternative version of yourself!"))
			owner.emote("me",1,"flashes into reality suddenly, gasping as they gaze around in a bewildered and highly confused fashion!",TRUE)
			owner.log_message("has become an alternative universe version of themselves via EIGENSTASIUM.", LOG_GAME)
			//new you new stuff
			SSquirks.randomise_quirks(owner)
			owner.reagents.remove_all(1000)
			owner.mob_mood.remove_temp_moods() //New you, new moods.
			var/mob/living/carbon/human/human_mob = owner
			owner.add_mood_event("Eigentrip", /datum/mood_event/eigentrip)
			if(QDELETED(human_mob))
				return
			if(prob(1))//low chance of the alternative reality returning to monkey
				var/obj/item/organ/tail/monkey/monkey_tail = new ()
				monkey_tail.Insert(human_mob, movement_flags = DELETE_IF_REPLACED)
			var/datum/species/human_species = human_mob.dna?.species
			if(human_species)
				human_species.randomize_active_features(human_mob)
				human_species.randomize_active_underwear(human_mob)

			owner.remove_status_effect(/datum/status_effect/eigenstasium)

/datum/status_effect/eigenstasium/proc/remove_clone_from_var()
	SIGNAL_HANDLER
	UnregisterSignal(alt_clone, COMSIG_QDELETING)

/datum/status_effect/eigenstasium/on_remove()
	if(!QDELETED(alt_clone))//catch any stragilers
		do_sparks(5, FALSE, alt_clone)
		owner.visible_message("One of the [owner]s suddenly phases out of reality in front of you!")
		QDEL_NULL(alt_clone)
	return ..()

#undef EIGENSTASIUM_MAX_BUFFER
#undef EIGENSTASIUM_STABILISATION_RATE
#undef EIGENSTASIUM_PHASE_1_END
#undef EIGENSTASIUM_PHASE_2_END
#undef EIGENSTASIUM_PHASE_3_START
#undef EIGENSTASIUM_PHASE_3_END

///Makes the mob luminescent for the duration of the effect.
/datum/status_effect/tinlux_light
	id = "tinea_luxor_light"
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	remove_on_fullheal = TRUE
	alert_type = null
	var/obj/effect/dummy/lighting_obj/moblight/mob_light_obj

/datum/status_effect/tinlux_light/on_creation(mob/living/new_owner, duration)
	if(duration)
		src.duration = duration
	return ..()

/datum/status_effect/tinlux_light/on_apply()
	mob_light_obj = owner.mob_light(2, 1.5, "#ccff33")
	return TRUE

/datum/status_effect/tinlux_light/on_remove()
	QDEL_NULL(mob_light_obj)

/datum/status_effect/gutted
	id = "gutted"
	alert_type = null
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK

/datum/status_effect/gutted/on_apply()
	RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(stop_gutting))
	return TRUE

/datum/status_effect/gutted/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_STATCHANGE)

/datum/status_effect/gutted/proc/stop_gutting()
	SIGNAL_HANDLER
	qdel(src)

/datum/status_effect/washing_regen
	id = "shower_regen"
	duration = STATUS_EFFECT_PERMANENT
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/washing_regen
	/// How much stamina we regain from washing
	var/stamina_heal_per_tick = -4
	/// How much brute, tox and fie damage we heal from this
	var/heal_per_tick = 0
	/// The main reagent used for the shower (if no reagent is at least 70% of volume then it's null)
	var/datum/reagent/shower_reagent

/datum/status_effect/washing_regen/on_creation(mob/living/new_owner, shower_reagent)
	if(!src.shower_reagent)
		src.shower_reagent = shower_reagent
	return ..()

/datum/status_effect/washing_regen/on_apply()
	. = ..()
	if(istype(shower_reagent, /datum/reagent/blood))
		if(HAS_TRAIT(owner, TRAIT_MORBID) || HAS_TRAIT(owner, TRAIT_EVIL) || (owner.mob_biotypes & MOB_UNDEAD))
			alert_type = /atom/movable/screen/alert/status_effect/washing_regen/bloody_like
		else
			alert_type  = /atom/movable/screen/alert/status_effect/washing_regen/bloody_dislike
	else if(istype(shower_reagent, /datum/reagent/water))
		if(HAS_TRAIT(owner, TRAIT_WATER_HATER) && !HAS_TRAIT(owner, TRAIT_WATER_ADAPTATION))
			alert_type = /atom/movable/screen/alert/status_effect/washing_regen/hater
		else
			alert_type = /atom/movable/screen/alert/status_effect/washing_regen
	else if(!shower_reagent) // dirty shower
		alert_type  = /atom/movable/screen/alert/status_effect/washing_regen/dislike

/datum/status_effect/washing_regen/tick(seconds_between_ticks)
	. = ..()

	var/is_disgusted = FALSE

	if(istype(shower_reagent, /datum/reagent/water))
		var/water_adaptation = HAS_TRAIT(owner, TRAIT_WATER_ADAPTATION)
		var/water_hater = HAS_TRAIT(owner, TRAIT_WATER_HATER)
		var/stam_recovery = (water_hater && !water_adaptation ? -stamina_heal_per_tick : stamina_heal_per_tick) * seconds_between_ticks
		var/recovery = heal_per_tick
		if(water_adaptation)
			recovery -= 1
			stam_recovery *= 1.5
		else if(water_hater)
			recovery *= 0
		recovery *= seconds_between_ticks

		var/healed = 0
		if(recovery) //very mild healing for those with the water adaptation trait (fish infusion)
			healed += owner.adjustOxyLoss(recovery * (water_adaptation ? 1.5 : 1), updating_health = FALSE, required_biotype = MOB_ORGANIC)
			healed += owner.adjustFireLoss(recovery, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
			healed += owner.adjustToxLoss(recovery, updating_health = FALSE, required_biotype = MOB_ORGANIC)
			healed += owner.adjustBruteLoss(recovery, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
		healed += owner.adjustStaminaLoss(stam_recovery, updating_stamina = FALSE)
		if(healed)
			owner.updatehealth()
	else if(istype(shower_reagent, /datum/reagent/blood))
		var/enjoy_bloody_showers = HAS_TRAIT(owner, TRAIT_MORBID) || HAS_TRAIT(owner, TRAIT_EVIL) || (owner.mob_biotypes & MOB_UNDEAD)
		is_disgusted = !enjoy_bloody_showers
	else if(!shower_reagent) // dirty shower
		is_disgusted = TRUE

	if(is_disgusted)
		owner.adjust_disgust(2)

/atom/movable/screen/alert/status_effect/washing_regen
	name = "Washing"
	desc = "A good wash fills me with energy!"
	icon_state = "shower_regen"

/atom/movable/screen/alert/status_effect/washing_regen/hater
	desc = "Waaater... Fuck this WATER!!"
	icon_state = "shower_regen_catgirl"

/atom/movable/screen/alert/status_effect/washing_regen/dislike
	desc = "This water feels dirty..."
	icon_state = "shower_regen_dirty"

/atom/movable/screen/alert/status_effect/washing_regen/bloody_like
	desc = "Mhhhmmmm... the crimson red drops of life. How delightful."
	icon_state = "shower_regen_blood_happy"

/atom/movable/screen/alert/status_effect/washing_regen/bloody_dislike
	desc = "Is that... blood? What the fuck!"
	icon_state = "shower_regen_blood_bad"

/datum/status_effect/washing_regen/hot_spring
	alert_type = /atom/movable/screen/alert/status_effect/washing_regen/hotspring
	stamina_heal_per_tick = -4.5
	heal_per_tick = -0.4
	shower_reagent = /datum/reagent/water

/datum/status_effect/washing_regen/hot_spring/on_apply()
	. = ..()
	if(HAS_TRAIT(owner, TRAIT_WATER_HATER) && !HAS_TRAIT(owner, TRAIT_WATER_ADAPTATION))
		alert_type = /atom/movable/screen/alert/status_effect/washing_regen/hotspring/hater

/datum/status_effect/washing_regen/hot_spring/tick(seconds_between_ticks)
	. = ..()
	owner.adjust_bodytemperature(10 * seconds_between_ticks, 0, T0C + 45)

/atom/movable/screen/alert/status_effect/washing_regen/hotspring
	name = "Hotspring"
	desc = "Hot Springs are so relaxing..."
	icon_state = "hotspring_regen"

/atom/movable/screen/alert/status_effect/washing_regen/hotspring/hater
	name = "Hotspring"
	desc = "Waaater... FUCK THIS HOT WATER!!"
	icon_state = "hotspring_regen_catgirl"

#define BEAM_ALPHA 62

///Makes the mob luminescent for the duration of the effect, and project a large spotlight overtop them.
/datum/status_effect/spotlight_light
	id = "spotlight_light"
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	alert_type = null
	/// Color of the light
	var/spotlight_color = "#e2e2ca"
	/// Dummy lighting object to simulate the spotlight highlighting the mob.
	var/obj/effect/dummy/lighting_obj/moblight/mob_light_obj
	/// First visual overlay, this one sits on the back of the mob.
	var/obj/effect/overlay/spotlight/beam_from_above_a
	/// Second visual overlay, this one sits on the front of the mob.
	var/obj/effect/overlay/spotlight/beam_from_above_b
	/// An additional overlay to supply with the spotlight
	var/image/additional_overlay

/datum/status_effect/spotlight_light/on_creation(mob/living/new_owner, duration, additional_overlay)
	if(duration)
		src.duration = duration
	if(additional_overlay)
		src.additional_overlay = additional_overlay
	return ..()

/datum/status_effect/spotlight_light/on_apply()
	mob_light_obj = owner.mob_light(2, 1.5, spotlight_color)

	beam_from_above_a = new /obj/effect/overlay/spotlight
	beam_from_above_a.color = spotlight_color
	beam_from_above_a.alpha = BEAM_ALPHA
	owner.vis_contents += beam_from_above_a
	beam_from_above_a.layer = BELOW_MOB_LAYER

	beam_from_above_b = new /obj/effect/overlay/spotlight
	beam_from_above_b.color = spotlight_color
	beam_from_above_b.alpha = BEAM_ALPHA
	beam_from_above_b.layer = ABOVE_MOB_LAYER
	beam_from_above_b.pixel_y = -2 //Slight vertical offset for an illusion of volume
	owner.vis_contents += beam_from_above_b

	if(additional_overlay)
		owner.add_overlay(additional_overlay)

	return TRUE

/datum/status_effect/spotlight_light/on_remove()
	owner.vis_contents -= beam_from_above_a
	owner.vis_contents -= beam_from_above_b
	QDEL_NULL(beam_from_above_a)
	QDEL_NULL(beam_from_above_b)
	QDEL_NULL(mob_light_obj)

	if(additional_overlay)
		owner.cut_overlay(additional_overlay)

/datum/status_effect/spotlight_light/divine
	id = "divine_spotlight"

#undef BEAM_ALPHA
