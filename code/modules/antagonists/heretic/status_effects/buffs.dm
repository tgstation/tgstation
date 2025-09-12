// POTIONS

// CRUCIBLE SOUL
/datum/status_effect/crucible_soul
	id = "Blessing of Crucible Soul"
	status_type = STATUS_EFFECT_REFRESH
	duration = 40 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/crucible_soul
	show_duration = TRUE
	///Stores the location where the mob drank the potion, used to teleport the drinker back to the spot after expiration
	var/turf/location

/datum/status_effect/crucible_soul/on_apply()
	to_chat(owner,span_notice("You phase through reality, nothing is out of bounds!"))
	owner.alpha = 180
	owner.pass_flags |= PASSCLOSEDTURF | PASSGLASS | PASSGRILLE | PASSMACHINE | PASSSTRUCTURE | PASSTABLE | PASSMOB | PASSDOORS | PASSVEHICLE
	location = get_turf(owner)
	var/datum/action/cancel_crucible_soul/cancel_button = new(src)
	cancel_button.Grant(owner)
	return TRUE

/datum/status_effect/crucible_soul/on_remove()
	to_chat(owner,span_notice("You regain your physicality, returning you to your original location..."))
	owner.alpha = initial(owner.alpha)
	owner.pass_flags &= ~(PASSCLOSEDTURF | PASSGLASS | PASSGRILLE | PASSMACHINE | PASSSTRUCTURE | PASSTABLE | PASSMOB | PASSDOORS | PASSVEHICLE)
	owner.forceMove(location)
	location = null

/datum/status_effect/crucible_soul/get_examine_text()
	return span_notice("[owner.p_They()] [owner.p_do()]n't seem to be all here.")

/datum/action/cancel_crucible_soul
	name = "Recall"
	desc = "Use to end the blessing early"
	button_icon = 'icons/obj/antags/eldritch.dmi'
	button_icon_state = "crucible_soul"

/datum/action/cancel_crucible_soul/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	var/datum/status_effect/active_effect = owner.has_status_effect(/datum/status_effect/crucible_soul)
	target = active_effect
	qdel(target)

// DUSK AND DAWN
/datum/status_effect/duskndawn
	id = "Blessing of Dusk and Dawn"
	status_type = STATUS_EFFECT_REFRESH
	duration = 90 SECONDS
	show_duration = TRUE
	alert_type =/atom/movable/screen/alert/status_effect/duskndawn

/datum/status_effect/duskndawn/on_apply()
	ADD_TRAIT(owner, TRAIT_XRAY_VISION, TRAIT_STATUS_EFFECT(id))
	owner.update_sight()
	return TRUE

/datum/status_effect/duskndawn/on_remove()
	REMOVE_TRAIT(owner, TRAIT_XRAY_VISION, TRAIT_STATUS_EFFECT(id))
	owner.update_sight()

// WOUNDED SOLDIER
/datum/status_effect/marshal
	id = "Blessing of Wounded Soldier"
	status_type = STATUS_EFFECT_REFRESH
	duration = 60 SECONDS
	tick_interval = 1 SECONDS
	show_duration = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/marshal

/datum/status_effect/marshal/on_apply()
	owner.add_movespeed_mod_immunities(id, /datum/movespeed_modifier/damage_slowdown)
	return TRUE

/datum/status_effect/marshal/on_remove()
	owner.remove_movespeed_mod_immunities(id, /datum/movespeed_modifier/damage_slowdown)
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/drinker = owner
	for(var/obj/item/bodypart/potentially_wounded as anything in drinker.bodyparts)
		for(var/datum/wound/found_wound as anything in potentially_wounded.wounds)
			found_wound.remove_wound()
	if(length(drinker.get_missing_limbs()))
		drinker.regenerate_limbs()
		to_chat(drinker, span_hypnophrase("The mansus has given you new limbs."))
	playsound(drinker, 'sound/effects/chemistry/ahaha.ogg', 50, TRUE, -1, extrarange = SILENCED_SOUND_EXTRARANGE, frequency = 0.5)

/datum/status_effect/marshal/tick(seconds_between_ticks)
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/carbie = owner

	carbie.adjustBruteLoss(-0.5 * seconds_between_ticks, updating_health = FALSE)
	carbie.adjustFireLoss(-0.5 * seconds_between_ticks, updating_health = FALSE)
	for(var/BP in carbie.bodyparts)
		var/obj/item/bodypart/part = BP
		for(var/W in part.wounds)
			var/datum/wound/wound = W
			var/heal_amt = 0

			switch(wound.severity)
				if(WOUND_SEVERITY_MODERATE)
					heal_amt = 1
				if(WOUND_SEVERITY_SEVERE)
					heal_amt = 3
				if(WOUND_SEVERITY_CRITICAL)
					heal_amt = 6
			var/datum/wound_pregen_data/pregen_data = GLOB.all_wound_pregen_data[wound.type]
			if (pregen_data.wounding_types_valid(list(WOUND_BURN)))
				carbie.adjustFireLoss(-heal_amt)
			else
				carbie.adjustBruteLoss(-heal_amt)
				carbie.blood_volume += carbie.blood_volume >= BLOOD_VOLUME_NORMAL ? 0 : heal_amt*3


/atom/movable/screen/alert/status_effect/crucible_soul
	name = "Blessing of Crucible Soul"
	desc = "You phased through reality. You are halfway to your final destination..."
	icon_state = "crucible"

/atom/movable/screen/alert/status_effect/duskndawn
	name = "Blessing of Dusk and Dawn"
	desc = "Many things hide beyond the horizon. With Owl's help I managed to slip past Sun's guard and Moon's watch."
	icon_state = "duskndawn"

/atom/movable/screen/alert/status_effect/marshal
	name = "Blessing of Wounded Soldier"
	desc = "Some people seek power through redemption. One thing many people don't know is that battle \
		is the ultimate redemption, and wounds let you bask in eternal glory."
	icon_state = "wounded_soldier"

// BLADES

/// Summons multiple foating knives around the owner.
/// Each knife will block an attack straight up.
/datum/status_effect/protective_blades
	id = "Silver Knives"
	alert_type = null
	status_type = STATUS_EFFECT_MULTIPLE
	tick_interval = STATUS_EFFECT_NO_TICK
	/// The number of blades we summon up to.
	var/max_num_blades = 4
	/// The radius of the blade's orbit.
	var/blade_orbit_radius = 20
	/// The time between spawning blades.
	var/time_between_initial_blades = 0.25 SECONDS
	/// If TRUE, we self-delete our status effect after all the blades are deleted.
	var/delete_on_blades_gone = TRUE
	/// What blade type to create
	var/obj/effect/floating_blade/blade_type
	/// A list of blade effects orbiting / protecting our owner
	var/list/obj/effect/floating_blade/blades = list()

/datum/status_effect/protective_blades/on_creation(
	mob/living/new_owner,
	new_duration = STATUS_EFFECT_PERMANENT,
	max_num_blades = 4,
	blade_orbit_radius = 20,
	time_between_initial_blades = 0.25 SECONDS,
	blade_type = /obj/effect/floating_blade,
)

	src.duration = new_duration
	src.max_num_blades = max_num_blades
	src.blade_orbit_radius = blade_orbit_radius
	src.time_between_initial_blades = time_between_initial_blades
	src.blade_type = blade_type
	return ..()

/datum/status_effect/protective_blades/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(on_shield_reaction))
	for(var/blade_num in 1 to max_num_blades)
		var/time_until_created = (blade_num - 1) * time_between_initial_blades
		if(time_until_created <= 0)
			create_blade()
		else
			addtimer(CALLBACK(src, PROC_REF(create_blade)), time_until_created)

	return TRUE

/datum/status_effect/protective_blades/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_CHECK_BLOCK)
	QDEL_LIST(blades)

	return ..()

/// Creates a floating blade, adds it to our blade list, and makes it orbit our owner.
/datum/status_effect/protective_blades/proc/create_blade()
	if(QDELETED(src) || QDELETED(owner))
		return

	var/obj/effect/floating_blade/blade = new blade_type(get_turf(owner))
	blades += blade
	blade.orbit(owner, blade_orbit_radius)
	RegisterSignal(blade, COMSIG_QDELETING, PROC_REF(remove_blade))
	playsound(get_turf(owner), 'sound/items/unsheath.ogg', 33, TRUE)

/// Signal proc for [COMSIG_LIVING_CHECK_BLOCK].
/// If we have a blade in our list, consume it and block the incoming attack (shield it)
/datum/status_effect/protective_blades/proc/on_shield_reaction(
	mob/living/carbon/human/source,
	atom/movable/hitby,
	damage = 0,
	attack_text = "the attack",
	attack_type = MELEE_ATTACK,
	armour_penetration = 0,
	damage_type = BRUTE,
)
	SIGNAL_HANDLER

	if(!length(blades))
		return

	if(HAS_TRAIT(source, TRAIT_BEING_BLADE_SHIELDED))
		return

	SEND_SIGNAL(src, COMSIG_BLADE_BARRIER_TRIGGERED)
	ADD_TRAIT(source, TRAIT_BEING_BLADE_SHIELDED, TRAIT_STATUS_EFFECT(id))
	addtimer(TRAIT_CALLBACK_REMOVE(source, TRAIT_BEING_BLADE_SHIELDED, TRAIT_STATUS_EFFECT(id)), 0.1 SECONDS)

	var/obj/effect/floating_blade/to_remove = blades[1]

	playsound(get_turf(source), 'sound/items/weapons/parry.ogg', 100, TRUE)
	source.visible_message(
		span_warning("[to_remove] orbiting [source] snaps in front of [attack_text], blocking it before vanishing!"),
		span_warning("[to_remove] orbiting you snaps in front of [attack_text], blocking it before vanishing!"),
		span_hear("You hear a clink."),
	)

	qdel(to_remove)

	return SUCCESSFUL_BLOCK

/// Remove deleted blades from our blades list properly.
/datum/status_effect/protective_blades/proc/remove_blade(obj/effect/floating_blade/to_remove)
	SIGNAL_HANDLER

	if(!(to_remove in blades))
		CRASH("[type] called remove_blade() with a blade that was not in its blades list.")

	to_remove.stop_orbit(owner.orbiters)
	blades -= to_remove

	if(!length(blades) && !QDELETED(src) && delete_on_blades_gone)
		qdel(src)

	return TRUE

/// A subtype that doesn't self-delete / disappear when all blades are gone
/// It instead regenerates over time back to the max after blades are consumed
/datum/status_effect/protective_blades/recharging
	delete_on_blades_gone = FALSE
	/// The amount of time it takes for a blade to recharge
	var/blade_recharge_time = 1 MINUTES

/datum/status_effect/protective_blades/recharging/on_creation(
	mob/living/new_owner,
	new_duration = STATUS_EFFECT_PERMANENT,
	max_num_blades = 4,
	blade_orbit_radius = 20,
	time_between_initial_blades = 0.25 SECONDS,
	blade_type = /obj/projectile/floating_blade,
	blade_recharge_time = 1 MINUTES,
)

	src.blade_recharge_time = blade_recharge_time
	return ..()

/datum/status_effect/protective_blades/recharging/remove_blade(obj/effect/floating_blade/to_remove)
	. = ..()
	if(!.)
		return

	addtimer(CALLBACK(src, PROC_REF(create_blade)), blade_recharge_time)


/datum/status_effect/caretaker_refuge
	id = "Caretaker’s Last Refuge"
	status_type = STATUS_EFFECT_REFRESH
	duration = STATUS_EFFECT_PERMANENT
	alert_type = null
	var/static/list/caretaking_traits = list(TRAIT_GODMODE, TRAIT_HANDS_BLOCKED, TRAIT_IGNORESLOWDOWN, TRAIT_SECLUDED_LOCATION)

/datum/status_effect/caretaker_refuge/on_apply()
	animate(owner, alpha = 45, time = 0.5 SECONDS)
	owner.set_density(FALSE)
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING), PROC_REF(on_focus_lost))
	RegisterSignal(owner, COMSIG_MOB_BEFORE_SPELL_CAST, PROC_REF(prevent_spell_usage))
	RegisterSignal(owner, COMSIG_ATOM_HOLYATTACK, PROC_REF(nullrod_handler))
	RegisterSignal(owner, COMSIG_CARBON_CUFF_ATTEMPTED, PROC_REF(prevent_cuff))
	RegisterSignal(owner, COMSIG_BEING_STRIPPED, PROC_REF(no_strip))
	owner.add_traits(caretaking_traits, TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/caretaker_refuge/on_remove()
	owner.remove_traits(caretaking_traits, TRAIT_STATUS_EFFECT(id))
	owner.alpha = initial(owner.alpha)
	owner.density = initial(owner.density)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING))
	UnregisterSignal(owner, COMSIG_MOB_BEFORE_SPELL_CAST)
	UnregisterSignal(owner, COMSIG_ATOM_HOLYATTACK)
	UnregisterSignal(owner, COMSIG_CARBON_CUFF_ATTEMPTED)
	UnregisterSignal(owner, COMSIG_BEING_STRIPPED)
	owner.visible_message(
		span_warning("The haze around [owner] disappears, leaving them materialized!"),
		span_notice("You exit the refuge."),
	)

/datum/status_effect/caretaker_refuge/get_examine_text()
	return span_warning("[owner.p_Theyre()] enveloped in an unholy haze!")

/datum/status_effect/caretaker_refuge/proc/nullrod_handler(datum/source, obj/item/weapon)
	SIGNAL_HANDLER
	playsound(get_turf(owner), 'sound/effects/curse/curse1.ogg', 80, TRUE)
	owner.visible_message(span_warning("[weapon] repels the haze around [owner]!"))
	owner.remove_status_effect(type)

/datum/status_effect/caretaker_refuge/proc/on_focus_lost()
	SIGNAL_HANDLER
	to_chat(owner, span_danger("Without a focus, your refuge weakens and dissipates!"))
	qdel(src)

/datum/status_effect/caretaker_refuge/proc/no_strip(atom/source, mob/user, obj/item/equipping)
	SIGNAL_HANDLER
	to_chat(user, span_warning("You fail to put anything on [source] as they are incorporeal!"))
	return COMPONENT_CANT_STRIP

/datum/status_effect/caretaker_refuge/proc/prevent_spell_usage(datum/source, datum/spell)
	SIGNAL_HANDLER
	if(!istype(spell, /datum/action/cooldown/spell/caretaker))
		owner.balloon_alert(owner, "may not cast spells in refuge!")
		return SPELL_CANCEL_CAST

/datum/status_effect/caretaker_refuge/proc/prevent_cuff(datum/source, mob/attemptee)
	SIGNAL_HANDLER
	return COMSIG_CARBON_CUFF_PREVENT

// Path Of Moon status effect which hides the identity of the heretic
/datum/status_effect/moon_grasp_hide
	id = "Moon Grasp Hide Identity"
	status_type = STATUS_EFFECT_REFRESH
	duration = 15 SECONDS
	show_duration = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/moon_grasp_hide

/datum/status_effect/moon_grasp_hide/on_apply()
	owner.add_traits(list(TRAIT_UNKNOWN_APPEARANCE, TRAIT_UNKNOWN_VOICE, TRAIT_SILENT_FOOTSTEPS), TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/moon_grasp_hide/on_remove()
	owner.remove_traits(list(TRAIT_UNKNOWN_APPEARANCE, TRAIT_UNKNOWN_VOICE, TRAIT_SILENT_FOOTSTEPS), TRAIT_STATUS_EFFECT(id))

/atom/movable/screen/alert/status_effect/moon_grasp_hide
	name = "Blessing of The Moon"
	desc = "The Moon clouds their vision, as the sun always has yours."
	icon_state = "moon_hide"
