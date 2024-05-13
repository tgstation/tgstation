/**
 * # The path of Rust.
 *
 * Goes as follows:
 *
 * Blacksmith's Tale
 * Grasp of Rust
 * Leeching Walk
 * > Sidepaths:
 *   Priest's Ritual
 *   Armorer's Ritual
 *
 * Mark of Rust
 * Ritual of Knowledge
 * Rust Construction
 * > Sidepaths:
 *   Lionhunter Rifle
 *
 * Aggressive Spread
 * > Sidepaths:
 *   Curse of Corrosion
 *   Mawed Crucible
 *
 * Toxic Blade
 * Entropic Plume
 * > Sidepaths:
 *   Rusted Ritual
 *   Rust Charge
 *
 * Rustbringer's Oath
 */
/datum/heretic_knowledge/limited_amount/starting/base_rust
	name = "Blacksmith's Tale"
	desc = "Opens up the Path of Rust to you. \
		Allows you to transmute a knife with any trash item into a Rusty Blade. \
		You can only create two at a time."
	gain_text = "\"Let me tell you a story\", said the Blacksmith, as he gazed deep into his rusty blade."
	next_knowledge = list(/datum/heretic_knowledge/rust_fist)
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/trash = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/rust)
	route = PATH_RUST

/datum/heretic_knowledge/rust_fist
	name = "Grasp of Rust"
	desc = "Your Mansus Grasp will deal 500 damage to non-living matter and rust any surface it touches. \
		Already rusted surfaces are destroyed. Surfaces and structures can only be rusted by using Right-Click. \
		Allows you to rust basic iron walls and floors."
	gain_text = "On the ceiling of the Mansus, rust grows as moss does on a stone."
	next_knowledge = list(/datum/heretic_knowledge/rust_regen)
	cost = 1
	route = PATH_RUST

/datum/heretic_knowledge/rust_fist/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, PROC_REF(on_secondary_mansus_grasp))
	our_heretic.increase_rust_strength()

/datum/heretic_knowledge/rust_fist/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, list(COMSIG_HERETIC_MANSUS_GRASP_ATTACK, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY))

/datum/heretic_knowledge/rust_fist/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!issilicon(target) && !(target.mob_biotypes & MOB_ROBOTIC))
		return

	source.do_rust_heretic_act(target)

/datum/heretic_knowledge/rust_fist/proc/on_secondary_mansus_grasp(mob/living/source, atom/target)
	SIGNAL_HANDLER

	// Rusting an airlock causes it to lose power, mostly to prevent the airlock from shocking you.
	// This is a bit of a hack, but fixing this would require the enture wire cut/pulse system to be reworked.
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock = target
		airlock.loseMainPower()

	source.do_rust_heretic_act(target)
	return COMPONENT_USE_HAND

/datum/heretic_knowledge/rust_regen
	name = "Leeching Walk"
	desc = "Grants you passive healing and resistance to batons while standing over rust."
	gain_text = "The speed was unparalleled, the strength unnatural. The Blacksmith was smiling."
	next_knowledge = list(
		/datum/heretic_knowledge/mark/rust_mark,
		/datum/heretic_knowledge/armor,
		/datum/heretic_knowledge/essence,
		/datum/heretic_knowledge/entropy_pulse,
	)
	cost = 1
	route = PATH_RUST

/datum/heretic_knowledge/rust_regen/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/heretic_knowledge/rust_regen/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_LIFE))

/*
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Checks if we should have baton resistance on the new turf.
 */
/datum/heretic_knowledge/rust_regen/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/turf/mover_turf = get_turf(source)
	if(HAS_TRAIT(mover_turf, TRAIT_RUSTY))
		ADD_TRAIT(source, TRAIT_BATON_RESISTANCE, type)
		return

	REMOVE_TRAIT(source, TRAIT_BATON_RESISTANCE, type)

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Gradually heals the heretic ([source]) on rust,
 * including baton knockdown and stamina damage.
 */
/datum/heretic_knowledge/rust_regen/proc/on_life(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	var/turf/our_turf = get_turf(source)
	if(!HAS_TRAIT(our_turf, TRAIT_RUSTY))
		return

	// Heals all damage + Stamina
	var/need_mob_update = FALSE
	need_mob_update += source.adjustBruteLoss(-3, updating_health = FALSE)
	need_mob_update += source.adjustFireLoss(-3, updating_health = FALSE)
	need_mob_update += source.adjustToxLoss(-3, updating_health = FALSE, forced = TRUE) // Slimes are people too
	need_mob_update += source.adjustOxyLoss(-1.5, updating_health = FALSE)
	need_mob_update += source.adjustStaminaLoss(-10, updating_stamina = FALSE)
	if(need_mob_update)
		source.updatehealth()
	// Reduces duration of stuns/etc
	source.AdjustAllImmobility(-0.5 SECONDS)
	// Heals blood loss
	if(source.blood_volume < BLOOD_VOLUME_NORMAL)
		source.blood_volume += 2.5 * seconds_per_tick
	// Slowly regulates your body temp
	source.adjust_bodytemperature((source.get_body_temp_normal() - source.bodytemperature)/5)

/datum/heretic_knowledge/mark/rust_mark
	name = "Mark of Rust"
	desc = "Your Mansus Grasp now applies the Mark of Rust. The mark is triggered from an attack with your Rusty Blade. \
		When triggered, your victim will suffer heavy disgust and confusion. \
		Allows you to rust reinforced walls and floors as well as plasteel."
	gain_text = "The Blacksmith looks away. To a place lost long ago. \"Rusted Hills help those in dire need... at a cost.\""
	next_knowledge = list(/datum/heretic_knowledge/knowledge_ritual/rust)
	route = PATH_RUST
	mark_type = /datum/status_effect/eldritch/rust

/datum/heretic_knowledge/mark/rust_mark/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	our_heretic.increase_rust_strength()

/datum/heretic_knowledge/knowledge_ritual/rust
	next_knowledge = list(/datum/heretic_knowledge/spell/rust_construction)
	route = PATH_RUST

/datum/heretic_knowledge/spell/rust_construction
	name = "Rust Construction"
	desc = "Grants you Rust Construction, a spell that allows you to raise a wall out of a rusted floor. \
		Anyone overtop the wall will be throw aside (or upwards) and sustain damage."
	gain_text = "Images of foreign and ominous structures began to dance in my mind. Covered head to toe in thick rust, \
		they no longer looked man made. Or perhaps they never were in the first place."
	next_knowledge = list(/datum/heretic_knowledge/spell/area_conversion)
	spell_to_add = /datum/action/cooldown/spell/pointed/rust_construction
	cost = 1
	route = PATH_RUST

/datum/heretic_knowledge/spell/area_conversion
	name = "Aggressive Spread"
	desc = "Grants you Aggressive Spread, a spell that spreads rust to nearby surfaces. \
		Already rusted surfaces are destroyed \ Also improves the rusting abilities of non rust-heretics."
	gain_text = "All wise men know well not to visit the Rusted Hills... Yet the Blacksmith's tale was inspiring."
	next_knowledge = list(
		/datum/heretic_knowledge/blade_upgrade/rust,
		/datum/heretic_knowledge/reroll_targets,
		/datum/heretic_knowledge/curse/corrosion,
		/datum/heretic_knowledge/summon/rusty,
		/datum/heretic_knowledge/crucible,
		/datum/heretic_knowledge/rifle,
	)
	spell_to_add = /datum/action/cooldown/spell/aoe/rust_conversion
	cost = 1
	route = PATH_RUST

/datum/heretic_knowledge/spell/area_conversion/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	our_heretic.increase_rust_strength(TRUE)

/datum/heretic_knowledge/blade_upgrade/rust
	name = "Toxic Blade"
	desc = "Your Rusty Blade now disgusts enemies on attack \ Allows you to rust Titanium and Plastitanium.."
	gain_text = "The Blacksmith hands you their blade. \"The Blade will guide you through the flesh, should you let it.\" \
		The heavy rust weights it down. You stare deeply into it. The Rusted Hills call for you, now."
	next_knowledge = list(/datum/heretic_knowledge/spell/entropic_plume)
	route = PATH_RUST

/datum/heretic_knowledge/blade_upgrade/rust/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	our_heretic.increase_rust_strength()

/datum/heretic_knowledge/blade_upgrade/rust/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	target.adjust_disgust(50)

/datum/heretic_knowledge/spell/area_conversion/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
/datum/heretic_knowledge/spell/entropic_plume
	name = "Entropic Plume"
	desc = "Grants you Entropic Plume, a spell that releases a vexing wave of Rust. \
		Blinds, poisons, and inflicts Amok on any heathen it hits, causing them to strike \
		at friend or foe wildly. Also rusts and destroys and surfaces it hits and improves the rusting abilities of non-rust heretics."
	gain_text = "The corrosion was unstoppable. The rust was unpleasable. \
		The Blacksmith was gone, and you hold their blade. Champions of hope, the Rustbringer is nigh!"
	next_knowledge = list(
		/datum/heretic_knowledge/ultimate/rust_final,
		/datum/heretic_knowledge/spell/rust_charge,
	)
	spell_to_add = /datum/action/cooldown/spell/cone/staggered/entropic_plume
	cost = 1
	route = PATH_RUST

/datum/heretic_knowledge/spell/entropic_plume/on_gain(mob/user)
	. = ..()
	var/datum/antagonist/heretic/our_heretic = IS_HERETIC(user)
	our_heretic.increase_rust_strength(TRUE)

/datum/heretic_knowledge/ultimate/rust_final
	name = "Rustbringer's Oath"
	desc = "The ascension ritual of the Path of Rust. \
		Bring 3 corpses to a transmutation rune on the bridge of the station to complete the ritual. \
		When completed, the ritual site will endlessly spread rust onto any surface, stopping for nothing. \
		Additionally, you will become extremely resilient on rust, healing at triple the rate \
		and becoming immune to many effects and dangers \ You will be able to rust almost anything upon ascending."
	gain_text = "Champion of rust. Corruptor of steel. Fear the dark, for the RUSTBRINGER has come! \
		The Blacksmith forges ahead! Rusted Hills, CALL MY NAME! WITNESS MY ASCENSION!"
	route = PATH_RUST
	/// If TRUE, then immunities are currently active.
	var/immunities_active = FALSE
	/// A typepath to an area that we must finish the ritual in.
	var/area/ritual_location = /area/station/command/bridge
	/// A static list of traits we give to the heretic when on rust.
	var/static/list/conditional_immunities = list(
		TRAIT_BOMBIMMUNE,
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_IGNORESLOWDOWN,
		TRAIT_NO_SLIP_ALL,
		TRAIT_NOBREATH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_SHOCKIMMUNE,
		TRAIT_SLEEPIMMUNE,
		TRAIT_STUNIMMUNE,
	)

/datum/heretic_knowledge/ultimate/rust_final/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	// This map doesn't have a Bridge, for some reason??
	// Let them complete the ritual anywhere
	if(!GLOB.areas_by_type[ritual_location])
		ritual_location = null

/datum/heretic_knowledge/ultimate/rust_final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(ritual_location)
		var/area/our_area = get_area(loc)
		if(!istype(our_area, ritual_location))
			loc.balloon_alert(user, "ritual failed, must be in [initial(ritual_location.name)]!") // "must be in bridge"
			return FALSE

	return ..()

/datum/heretic_knowledge/ultimate/rust_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	priority_announce(
		text = "[generate_heretic_text()] Fear the decay, for the Rustbringer, [user.real_name] has ascended! None shall escape the corrosion! [generate_heretic_text()]",
		title = "[generate_heretic_text()]",
		sound = 'sound/ambience/antag/heretic/ascend_rust.ogg',
		color_override = "pink",
	)
	trigger(loc)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	user.client?.give_award(/datum/award/achievement/misc/rust_ascension, user)
	var/datum/action/cooldown/spell/aoe/rust_conversion/rust_spread_spell = locate() in user.actions
	rust_spread_spell?.cooldown_time /= 2

// I sure hope this doesn't have performance implications
/datum/heretic_knowledge/ultimate/rust_final/proc/trigger(turf/center)
	var/greatest_dist = 0
	var/list/turfs_to_transform = list()
	for (var/turf/transform_turf as anything in GLOB.station_turfs)
		if (transform_turf.turf_flags & NO_RUST)
			continue
		var/dist = get_dist(center, transform_turf)
		if (dist > greatest_dist)
			greatest_dist = dist
		if (!turfs_to_transform["[dist]"])
			turfs_to_transform["[dist]"] = list()
		turfs_to_transform["[dist]"] += transform_turf

	for (var/iterator in 1 to greatest_dist)
		if(!turfs_to_transform["[iterator]"])
			continue
		addtimer(CALLBACK(src, PROC_REF(transform_area), turfs_to_transform["[iterator]"]), (5 SECONDS) * iterator)

/datum/heretic_knowledge/ultimate/rust_final/proc/transform_area(list/turfs)
	turfs = shuffle(turfs)
	var/numturfs = length(turfs)
	var/first_third = turfs.Copy(1, round(numturfs * 0.33))
	var/second_third = turfs.Copy(round(numturfs * 0.33), round(numturfs * 0.66))
	var/third_third = turfs.Copy(round(numturfs * 0.66), numturfs)
	addtimer(CALLBACK(src, PROC_REF(delay_transform_turfs), first_third), 5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(delay_transform_turfs), second_third), 5 SECONDS * 0.33)
	addtimer(CALLBACK(src, PROC_REF(delay_transform_turfs), third_third), 5 SECONDS * 0.66)

/datum/heretic_knowledge/ultimate/rust_final/proc/delay_transform_turfs(list/turfs)
	for(var/turf/turf as anything in turfs)
		turf.rust_heretic_act(5)
		CHECK_TICK

/**
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Gives our heretic ([source]) buffs if they stand on rust.
 */
/datum/heretic_knowledge/ultimate/rust_final/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	// If we're on a rusty turf, and haven't given out our traits, buff our guy
	var/turf/our_turf = get_turf(source)
	if(HAS_TRAIT(our_turf, TRAIT_RUSTY))
		if(!immunities_active)
			source.add_traits(conditional_immunities, type)
			immunities_active = TRUE

	// If we're not on a rust turf, and we have given out our traits, nerf our guy
	else
		if(immunities_active)
			source.remove_traits(conditional_immunities, type)
			immunities_active = FALSE

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Gradually heals the heretic ([source]) on rust.
 */
/datum/heretic_knowledge/ultimate/rust_final/proc/on_life(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	var/turf/our_turf = get_turf(source)
	if(!HAS_TRAIT(our_turf, TRAIT_RUSTY))
		return

	var/need_mob_update = FALSE
	need_mob_update += source.adjustBruteLoss(-5, updating_health = FALSE)
	need_mob_update += source.adjustFireLoss(-5, updating_health = FALSE)
	need_mob_update += source.adjustToxLoss(-5, updating_health = FALSE, forced = TRUE)
	need_mob_update += source.adjustOxyLoss(-5, updating_health = FALSE)
	need_mob_update += source.adjustStaminaLoss(-20, updating_stamina = FALSE)
	if(source.blood_volume < BLOOD_VOLUME_NORMAL)
		source.blood_volume += 5 * seconds_per_tick
	if(need_mob_update)
		source.updatehealth()
