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
		Already rusted surfaces are destroyed. Surfaces and structures can only be rusted by using Right-Click."
	gain_text = "On the ceiling of the Mansus, rust grows as moss does on a stone."
	next_knowledge = list(/datum/heretic_knowledge/rust_regen)
	cost = 1
	route = PATH_RUST

/datum/heretic_knowledge/rust_fist/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, PROC_REF(on_secondary_mansus_grasp))

/datum/heretic_knowledge/rust_fist/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, list(COMSIG_HERETIC_MANSUS_GRASP_ATTACK, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY))

/datum/heretic_knowledge/rust_fist/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!issilicon(target) && !(target.mob_biotypes & MOB_ROBOTIC))
		return

	target.rust_heretic_act()

/datum/heretic_knowledge/rust_fist/proc/on_secondary_mansus_grasp(mob/living/source, atom/target)
	SIGNAL_HANDLER

	// Rusting an airlock causes it to lose power, mostly to prevent the airlock from shocking you.
	// This is a bit of a hack, but fixing this would require the enture wire cut/pulse system to be reworked.
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock = target
		airlock.loseMainPower()

	target.rust_heretic_act()
	return COMPONENT_USE_HAND

/datum/heretic_knowledge/rust_regen
	name = "Leeching Walk"
	desc = "Grants you passive healing and resistance to batons while standing over rust."
	gain_text = "The speed was unparalleled, the strength unnatural. The Blacksmith was smiling."
	adds_sidepath_points = 1
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
	need_mob_update += source.adjustBruteLoss(-2, updating_health = FALSE)
	need_mob_update += source.adjustFireLoss(-2, updating_health = FALSE)
	need_mob_update += source.adjustToxLoss(-2, updating_health = FALSE, forced = TRUE) // Slimes are people too
	need_mob_update += source.adjustOxyLoss(-0.5, updating_health = FALSE)
	need_mob_update += source.adjustStaminaLoss(-2, updating_stamina = FALSE)
	if(need_mob_update)
		source.updatehealth()
	// Reduces duration of stuns/etc
	source.AdjustAllImmobility(-0.5 SECONDS)
	// Heals blood loss
	if(source.blood_volume < BLOOD_VOLUME_NORMAL)
		source.blood_volume += 2.5 * seconds_per_tick

/datum/heretic_knowledge/mark/rust_mark
	name = "Mark of Rust"
	desc = "Your Mansus Grasp now applies the Mark of Rust. The mark is triggered from an attack with your Rusty Blade. \
		When triggered, the victim's organs and equipment will have a 75% chance to sustain damage and may be destroyed."
	gain_text = "The Blacksmith looks away. To a place lost long ago. \"Rusted Hills help those in dire need... at a cost.\""
	next_knowledge = list(/datum/heretic_knowledge/knowledge_ritual/rust)
	route = PATH_RUST
	mark_type = /datum/status_effect/eldritch/rust

/datum/heretic_knowledge/knowledge_ritual/rust
	next_knowledge = list(/datum/heretic_knowledge/spell/rust_construction)
	route = PATH_RUST

/datum/heretic_knowledge/spell/rust_construction
	name = "Rust Construction"
	desc = "Grants you Rust Construction, a spell that allows you to raise a wall out of a rusted floor. \
		Anyone overtop the wall will be throw aside (or upwards) and sustain damage."
	gain_text = "Images of foreign and ominous structures began to dance in my mind. Covered head to toe in thick rust, \
		they no longer looked man made. Or perhaps they never were in the first place."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/area_conversion,
		/datum/heretic_knowledge/rifle,
	)
	spell_to_add = /datum/action/cooldown/spell/pointed/rust_construction
	cost = 1
	route = PATH_RUST

/datum/heretic_knowledge/spell/area_conversion
	name = "Aggressive Spread"
	desc = "Grants you Aggressive Spread, a spell that spreads rust to nearby surfaces. \
		Already rusted surfaces are destroyed."
	gain_text = "All wise men know well not to visit the Rusted Hills... Yet the Blacksmith's tale was inspiring."
	adds_sidepath_points = 1
	next_knowledge = list(
		/datum/heretic_knowledge/blade_upgrade/rust,
		/datum/heretic_knowledge/reroll_targets,
		/datum/heretic_knowledge/curse/corrosion,
		/datum/heretic_knowledge/crucible,
	)
	spell_to_add = /datum/action/cooldown/spell/aoe/rust_conversion
	cost = 1
	route = PATH_RUST

/datum/heretic_knowledge/blade_upgrade/rust
	name = "Toxic Blade"
	desc = "Your Rusty Blade now poisons enemies on attack."
	gain_text = "The Blacksmith hands you their blade. \"The Blade will guide you through the flesh, should you let it.\" \
		The heavy rust weights it down. You stare deeply into it. The Rusted Hills call for you, now."
	next_knowledge = list(/datum/heretic_knowledge/spell/entropic_plume)
	route = PATH_RUST

/datum/heretic_knowledge/blade_upgrade/rust/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	// No user == target check here, cause it's technically good for the heretic?
	target.reagents?.add_reagent(/datum/reagent/eldritch, 5)

/datum/heretic_knowledge/spell/entropic_plume
	name = "Entropic Plume"
	desc = "Grants you Entropic Plume, a spell that releases a vexing wave of Rust. \
		Blinds, poisons, and inflicts Amok on any heathen it hits, causing them to strike \
		at friend or foe wildly. Also rusts and destroys and surfaces it hits."
	gain_text = "The corrosion was unstoppable. The rust was unpleasable. \
		The Blacksmith was gone, and you hold their blade. Champions of hope, the Rustbringer is nigh!"
	adds_sidepath_points = 1
	next_knowledge = list(
		/datum/heretic_knowledge/ultimate/rust_final,
		/datum/heretic_knowledge/summon/rusty,
		/datum/heretic_knowledge/spell/rust_charge,
	)
	spell_to_add = /datum/action/cooldown/spell/cone/staggered/entropic_plume
	cost = 1
	route = PATH_RUST

/datum/heretic_knowledge/ultimate/rust_final
	name = "Rustbringer's Oath"
	desc = "The ascension ritual of the Path of Rust. \
		Bring 3 corpses to a transmutation rune on the bridge of the station to complete the ritual. \
		When completed, the ritual site will endlessly spread rust onto any surface, stopping for nothing. \
		Additionally, you will become extremely resilient on rust, healing at triple the rate \
		and becoming immune to many effects and dangers."
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
	priority_announce("[generate_heretic_text()] Fear the decay, for the Rustbringer, [user.real_name] has ascended! None shall escape the corrosion! [generate_heretic_text()]","[generate_heretic_text()]", ANNOUNCER_SPANOMALIES)
	new /datum/rust_spread(loc)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	user.client?.give_award(/datum/award/achievement/misc/rust_ascension, user)

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
	need_mob_update += source.adjustBruteLoss(-4, updating_health = FALSE)
	need_mob_update += source.adjustFireLoss(-4, updating_health = FALSE)
	need_mob_update += source.adjustToxLoss(-4, updating_health = FALSE, forced = TRUE)
	need_mob_update += source.adjustOxyLoss(-4, updating_health = FALSE)
	need_mob_update += source.adjustStaminaLoss(-20, updating_stamina = FALSE)
	if(need_mob_update)
		source.updatehealth()

/**
 * #Rust spread datum
 *
 * Simple datum that automatically spreads rust around it.
 *
 * Simple implementation of automatically growing entity.
 */
/datum/rust_spread
	/// The rate of spread every tick.
	var/spread_per_sec = 6
	/// The very center of the spread.
	var/turf/centre
	/// List of turfs at the edge of our rust (but not yet rusted).
	var/list/edge_turfs = list()
	/// List of all turfs we've afflicted.
	var/list/rusted_turfs = list()
	/// Static blacklist of turfs we can't spread to.
	var/static/list/blacklisted_turfs = typecacheof(list(
		/turf/open/indestructible,
		/turf/closed/indestructible,
		/turf/open/space,
		/turf/open/lava,
		/turf/open/chasm
	))

/datum/rust_spread/New(loc)
	centre = get_turf(loc)
	centre.rust_heretic_act()
	rusted_turfs += centre
	START_PROCESSING(SSprocessing, src)

/datum/rust_spread/Destroy(force, ...)
	centre = null
	edge_turfs.Cut()
	rusted_turfs.Cut()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/rust_spread/process(seconds_per_tick)
	var/spread_amount = round(spread_per_sec * seconds_per_tick)

	if(length(edge_turfs) < spread_amount)
		compile_turfs()

	for(var/i in 0 to spread_amount)
		if(!length(edge_turfs))
			break
		var/turf/afflicted_turf = pick_n_take(edge_turfs)
		afflicted_turf.rust_heretic_act()
		rusted_turfs |= afflicted_turf

/**
 * Compile turfs
 *
 * Recreates the edge_turfs list.
 * Updates the rusted_turfs list, in case any turfs within were un-rusted.
 */
/datum/rust_spread/proc/compile_turfs()
	edge_turfs.Cut()

	var/max_dist = 1
	for(var/turf/found_turf as anything in rusted_turfs)
		if(!HAS_TRAIT(found_turf, TRAIT_RUSTY))
			rusted_turfs -= found_turf
		max_dist = max(max_dist, get_dist(found_turf, centre) + 1)

	for(var/turf/nearby_turf as anything in spiral_range_turfs(max_dist, centre, FALSE))
		if(nearby_turf in rusted_turfs || is_type_in_typecache(nearby_turf, blacklisted_turfs))
			continue

		for(var/turf/line_turf as anything in get_line(nearby_turf, centre))
			if(get_dist(nearby_turf, line_turf) <= 1)
				edge_turfs |= nearby_turf
		CHECK_TICK
