/datum/heretic_knowledge/base_rust
	name = "Blacksmith's Tale"
	desc = "Opens up the Path of Rust to you. Allows you to transmute a kitchen knife, or its derivatives, with any trash item into a Rusty Blade."
	gain_text = "\"Let me tell you a story\", said the Blacksmith, as he gazed deep into his rusty blade."
	banned_knowledge = list(
		/datum/heretic_knowledge/base_ash,
		/datum/heretic_knowledge/base_flesh,
		/datum/heretic_knowledge/final/ash_final,
		/datum/heretic_knowledge/final/flesh_final,
		/datum/heretic_knowledge/final/void_final,
		/datum/heretic_knowledge/base_void,
		)

	next_knowledge = list(/datum/heretic_knowledge/rust_fist)
	required_atoms = list(/obj/item/knife = 1, /obj/item/trash = 1)
	result_atoms = list(/obj/item/melee/sickly_blade/rust)
	cost = 1
	route = PATH_RUST

/datum/heretic_knowledge/rust_fist
	name = "Grasp of Rust"
	desc = "Empowers your Mansus Grasp to deal 500 damage to non-living matter and rust any surface it touches. \
		Already rusted surfaces are destroyed. You only rust surfaces and machinery with Right Click."
	gain_text = "On the ceiling of the Mansus, rust grows as moss does on a stone."
	cost = 1
	next_knowledge = list(/datum/heretic_knowledge/rust_regen)
	var/rust_force = 500
	var/static/list/blacklisted_turfs = typecacheof(list(
		/turf/closed,
		/turf/open/space,
		/turf/open/lava,
		/turf/open/chasm,
	))
	route = PATH_RUST

/datum/heretic_knowledge/rust_fist/on_gain(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, .proc/on_mansus_grasp)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, .proc/on_secondary_mansus_grasp)
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, .proc/on_eldritch_blade)

/datum/heretic_knowledge/rust_fist/on_lose(mob/user)
	. = ..()
	UnregisterSignal(user, list(COMSIG_HERETIC_MANSUS_GRASP_ATTACK, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, COMSIG_HERETIC_BLADE_ATTACK))

/datum/heretic_knowledge/rust_fist/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!issilicon(target) && !(target.mob_biotypes & MOB_ROBOTIC))
		return

	target.rust_heretic_act()

/datum/heretic_knowledge/rust_fist/proc/on_secondary_mansus_grasp(mob/living/source, atom/target)
	SIGNAL_HANDLER

	target.rust_heretic_act()

/datum/heretic_knowledge/rust_fist/proc/on_eldritch_blade(mob/living/user, mob/living/target)
	SIGNAL_HANDLER

	var/datum/status_effect/eldritch/mark = target.has_status_effect(/datum/status_effect/eldritch)
	mark?.on_effect()

	if(!iscarbon(target))
		return

	var/static/list/possible_organs = list(
		ORGAN_SLOT_BRAIN,
		ORGAN_SLOT_EARS,
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_STOMACH,
		ORGAN_SLOT_HEART,
	)

	target.adjustOrganLoss(pick(possible_organs), 25)

/datum/heretic_knowledge/spell/area_conversion
	name = "Aggressive Spread"
	desc = "Spreads rust to nearby surfaces. Already rusted surfaces are destroyed."
	gain_text = "All wise men know well not to touch the Bound King."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/aoe_turf/rust_conversion
	next_knowledge = list(
		/datum/heretic_knowledge/rust_blade_upgrade,
		/datum/heretic_knowledge/curse/corrosion,
		/datum/heretic_knowledge/crucible
	)
	route = PATH_RUST

/datum/heretic_knowledge/rust_regen
	name = "Leeching Walk"
	desc = "Passively heals you and provides stun resistance when you are on rusted tiles."
	gain_text = "The strength was unparalleled, unnatural. The Blacksmith was smiling."
	cost = 1
	next_knowledge = list(
		/datum/heretic_knowledge/rust_mark,
		/datum/heretic_knowledge/armor,
		/datum/heretic_knowledge/essence,
	)
	route = PATH_RUST
	processes_on_life = TRUE

/datum/heretic_knowledge/rust_regen/on_gain(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/on_move)

/datum/heretic_knowledge/rust_regen/on_lose(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)

/*
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Checks if we should have stun resistance on the new turf.
 */
/datum/heretic_knowledge/rust_regen/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/turf/mover_turf = get_turf(source)
	if(HAS_TRAIT(mover_turf, TRAIT_RUSTY))
		ADD_TRAIT(source, TRAIT_STUNRESISTANCE, type)
		return

	REMOVE_TRAIT(source, TRAIT_STUNRESISTANCE, type)

/datum/heretic_knowledge/rust_regen/on_life(mob/user)
	if(!isliving(user))
		return
	var/turf/our_turf = get_turf(user)
	if(!HAS_TRAIT(our_turf, TRAIT_RUSTY))
		return

	var/mob/living/living_user = user
	living_user.adjustBruteLoss(-2, FALSE)
	living_user.adjustFireLoss(-2, FALSE)
	living_user.adjustToxLoss(-2, FALSE, forced = TRUE)
	living_user.adjustOxyLoss(-0.5, FALSE)
	living_user.adjustStaminaLoss(-2)
	living_user.AdjustAllImmobility(-5)

/datum/heretic_knowledge/rust_mark
	name = "Mark of Rust"
	desc = "Your Mansus Grasp now applies the Mark of Rust on hit. \
		Attack the afflicted with your Sickly Blade to detonate the mark. \
		Upon detonation, the Mark of Rust has a chance to deal \
		between 0 to 200 damage to 75% of your enemy's held items."
	gain_text = "Rusted Hills help those in dire need... at a cost."
	cost = 2
	next_knowledge = list(/datum/heretic_knowledge/spell/area_conversion)
	banned_knowledge = list(/datum/heretic_knowledge/ash_mark,/datum/heretic_knowledge/flesh_mark,/datum/heretic_knowledge/void_mark)
	route = PATH_RUST

/datum/heretic_knowledge/rust_mark/on_gain(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, .proc/on_mansus_grasp)

/datum/heretic_knowledge/rust_mark/on_lose(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/heretic_knowledge/rust_mark/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	target.apply_status_effect(/datum/status_effect/eldritch/rust)

/datum/heretic_knowledge/rust_blade_upgrade
	name = "Toxic Blade"
	desc = "Your blade will now poison your enemies on hit."
	gain_text = "The Blade will guide you through the flesh, should you let it."
	cost = 2
	next_knowledge = list(/datum/heretic_knowledge/spell/entropic_plume)
	banned_knowledge = list(/datum/heretic_knowledge/ash_blade_upgrade,/datum/heretic_knowledge/flesh_blade_upgrade,/datum/heretic_knowledge/void_blade_upgrade)
	route = PATH_RUST

/datum/heretic_knowledge/rust_blade_upgrade/on_gain(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, .proc/on_eldritch_blade)

/datum/heretic_knowledge/rust_blade_upgrade/on_lose(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK)

/datum/heretic_knowledge/rust_blade_upgrade/proc/on_eldritch_blade(mob/living/user, mob/living/target)
	SIGNAL_HANDLER

	target.reagents?.add_reagent(/datum/reagent/eldritch, 5)

/datum/heretic_knowledge/spell/entropic_plume
	name = "Entropic Plume"
	desc = "You can now send a disorienting plume of pure entropy that \
		blinds, poisons and makes enemies strike each other. \
		It also rusts any tiles it affects."
	gain_text = "Messengers of Hope, fear the Rustbringer!"
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/cone/staggered/entropic_plume
	next_knowledge = list(/datum/heretic_knowledge/final/rust_final, /datum/heretic_knowledge/spell/cleave, /datum/heretic_knowledge/summon/rusty)
	route = PATH_RUST

/datum/heretic_knowledge/armor
	name = "Armorer's Ritual"
	desc = "You can now create Eldritch Armor using a table and a gas mask. \
		The armor both protect from damage and works as a focus, allowing you to cast spells."
	gain_text = "The Rusted Hills welcomed the Blacksmith in their generosity."
	cost = 1
	next_knowledge = list(/datum/heretic_knowledge/rust_regen, /datum/heretic_knowledge/cold_snap)
	required_atoms = list(/obj/structure/table = 1, /obj/item/clothing/mask/gas = 1)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch)

/datum/heretic_knowledge/essence
	name = "Priest's Ritual"
	desc = "Allows you to transmute a tank of water and a glass shard into a flask of eldritch water. \
		Eldritch water can be consumed for potent healing, or given to heathens for deadly poisoning."
	gain_text = "This is an old recipe. The Owl whispered it to me."
	cost = 1
	next_knowledge = list(/datum/heretic_knowledge/rust_regen, /datum/heretic_knowledge/spell/ashen_shift)
	required_atoms = list(/obj/structure/reagent_dispensers/watertank = 1, /obj/item/shard = 1)
	result_atoms = list(/obj/item/reagent_containers/glass/beaker/eldritch)

/datum/heretic_knowledge/final/rust_final
	name = "Rustbringer's Oath"
	desc = "Bring 3 corpses onto the transmutation rune. \
		After you finish the ritual rust will now automatically spread from the rune. \
		Your healing on rust is also tripled, while you become extremely more resillient."
	gain_text = "Champion of rust. Corruptor of steel. Fear the dark for the Rustbringer has come! Rusted Hills, CALL MY NAME!"
	cost = 3
	required_atoms = list(/mob/living/carbon/human = 3)
	route = PATH_RUST
	processes_on_life = TRUE
	/// A list of traits we give to the heretic when on rust.
	var/static/list/conditional_immunities = list(
		TRAIT_STUNIMMUNE,
		TRAIT_SLEEPIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_SHOCKIMMUNE,
		TRAIT_NOSLIPALL,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_PIERCEIMMUNE,
		TRAIT_BOMBIMMUNE,
		TRAIT_NOBREATH,
		)
	/// If TRUE, then immunities are active.
	var/immunities_active = FALSE

/datum/heretic_knowledge/final/rust_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	priority_announce("[generate_heretic_text()] Fear the decay, for the Rustbringer, [user.real_name] has ascended! None shall escape the corrosion! [generate_heretic_text()]","[generate_heretic_text()]", ANNOUNCER_SPANOMALIES)
	new /datum/rust_spread(loc)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/on_move)
	user.client?.give_award(/datum/award/achievement/misc/rust_ascension, user)

/**
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Gives our heretic buffs if they stand on rust.
 */
/datum/heretic_knowledge/final/rust_final/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	// If we're on a rusty turf, and haven't given out our traits, buff our guy
	var/turf/our_turf = get_turf(source)
	if(HAS_TRAIT(our_turf, TRAIT_RUSTY))
		if(!immunities_active)
			for(var/trait in conditional_immunities)
				ADD_TRAIT(source, trait, type)
			immunities_active = TRUE

	// If we're not on a rust turf, and we have given out our traits, nerf our guy
	else
		if(immunities_active)
			for(var/trait in conditional_immunities)
				REMOVE_TRAIT(source, trait, type)
			immunities_active = FALSE

/datum/heretic_knowledge/final/rust_final/on_life(mob/user)
	if(!isliving(user))
		return
	var/turf/our_turf = get_turf(user)
	if(!HAS_TRAIT(our_turf, TRAIT_RUSTY))
		return

	var/mob/living/living_user = user
	living_user.adjustBruteLoss(-4, FALSE)
	living_user.adjustFireLoss(-4, FALSE)
	living_user.adjustToxLoss(-4, FALSE, forced = TRUE)
	living_user.adjustOxyLoss(-4, FALSE)
	living_user.adjustStaminaLoss(-20)

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

/datum/rust_spread/process(delta_time)
	var/spread_amount = round(spread_per_sec * delta_time)

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
