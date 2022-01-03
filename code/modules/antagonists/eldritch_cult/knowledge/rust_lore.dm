/datum/eldritch_knowledge/base_rust
	name = "Blacksmith's Tale"
	desc = "Opens up the Path of Rust to you. Allows you to transmute a kitchen knife, or its derivatives, with any trash item into a Rusty Blade."
	gain_text = "'Let me tell you a story', said the Blacksmith, as he gazed deep into his rusty blade."
	banned_knowledge = list(/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_flesh,/datum/eldritch_knowledge/final/ash_final,/datum/eldritch_knowledge/final/flesh_final,/datum/eldritch_knowledge/final/void_final,/datum/eldritch_knowledge/base_void)
	next_knowledge = list(/datum/eldritch_knowledge/rust_fist)
	required_atoms = list(/obj/item/knife,/obj/item/trash)
	result_atoms = list(/obj/item/melee/sickly_blade/rust)
	cost = 1
	route = PATH_RUST

/datum/eldritch_knowledge/rust_fist
	name = "Grasp of Rust"
	desc = "Empowers your Mansus Grasp to deal 500 damage to non-living matter and rust any surface it touches. Already rusted surfaces are destroyed. You only rust surfaces and machinery while in combat mode."
	gain_text = "On the ceiling of the Mansus, rust grows as moss does on a stone."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_regen)
	var/rust_force = 500
	var/static/list/blacklisted_turfs = typecacheof(list(
		/turf/closed,
		/turf/open/space,
		/turf/open/lava,
		/turf/open/chasm,
	))
	route = PATH_RUST

/datum/eldritch_knowledge/rust_fist/on_mansus_grasp(atom/target, mob/living/user, proximity_flag, click_parameters)
	. = ..()
	var/check = FALSE
	if(ismob(target))
		var/mob/living/mobster = target
		if(!(mobster.mob_biotypes & MOB_ROBOTIC))
			return FALSE
		else
			check = TRUE
	if(user.combat_mode || check)
		target.rust_heretic_act()
		return TRUE

/datum/eldritch_knowledge/rust_fist/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/victim = target
		var/datum/status_effect/eldritch/effect = victim.has_status_effect(/datum/status_effect/eldritch/rust) || victim.has_status_effect(/datum/status_effect/eldritch/ash) || victim.has_status_effect(/datum/status_effect/eldritch/flesh) || victim.has_status_effect(/datum/status_effect/eldritch/void)
		if(effect)
			effect.on_effect()
			victim.adjustOrganLoss(pick(ORGAN_SLOT_BRAIN,ORGAN_SLOT_EARS,ORGAN_SLOT_EYES,ORGAN_SLOT_LIVER,ORGAN_SLOT_LUNGS,ORGAN_SLOT_STOMACH,ORGAN_SLOT_HEART),25)

/datum/eldritch_knowledge/spell/area_conversion
	name = "Aggressive Spread"
	desc = "Spreads rust to nearby surfaces. Already rusted surfaces are destroyed."
	gain_text = "All wise men know well not to touch the Bound King."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/aoe_turf/rust_conversion
	next_knowledge = list(
		/datum/eldritch_knowledge/rust_blade_upgrade,
		/datum/eldritch_knowledge/curse/corrosion,
		/datum/eldritch_knowledge/crucible
	)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_regen
	name = "Leeching Walk"
	desc = "Passively heals you and provides stun resistance when you are on rusted tiles."
	gain_text = "The strength was unparalleled, unnatural. The Blacksmith was smiling."
	cost = 1
	next_knowledge = list(
		/datum/eldritch_knowledge/rust_mark,
		/datum/eldritch_knowledge/armor,
		/datum/eldritch_knowledge/essence,
	)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_regen/on_gain(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/on_move)

/datum/eldritch_knowledge/rust_regen/proc/on_move(mob/mover)
	SIGNAL_HANDLER

	var/turf/mover_turf = get_turf(mover)
	if(HAS_TRAIT(mover_turf, TRAIT_RUSTY))
		ADD_TRAIT(mover, TRAIT_STUNRESISTANCE, type)
		return

	REMOVE_TRAIT(mover, TRAIT_STUNRESISTANCE, type)

/datum/eldritch_knowledge/rust_regen/on_life(mob/user)
	. = ..()
	var/turf/our_turf = get_turf(user)
	if(!HAS_TRAIT(our_turf, TRAIT_RUSTY) || !isliving(user))
		return

	var/mob/living/living_user = user
	living_user.adjustBruteLoss(-2, FALSE)
	living_user.adjustFireLoss(-2, FALSE)
	living_user.adjustToxLoss(-2, FALSE, forced = TRUE)
	living_user.adjustOxyLoss(-0.5, FALSE)
	living_user.adjustStaminaLoss(-2)
	living_user.AdjustAllImmobility(-5)

/datum/eldritch_knowledge/rust_mark
	name = "Mark of Rust"
	desc = "Your Mansus Grasp now applies the Mark of Rust on hit. Attack the afflicted with your Sickly Blade to detonate the mark. Upon detonation, the Mark of Rust has a chance to deal between 0 to 200 damage to 75% of your enemy's held items."
	gain_text = "Rusted Hills help those in dire need at a cost."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/spell/area_conversion)
	banned_knowledge = list(/datum/eldritch_knowledge/ash_mark,/datum/eldritch_knowledge/flesh_mark,/datum/eldritch_knowledge/void_mark)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_mark/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(isliving(target))
		. = TRUE
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/eldritch/rust)

/datum/eldritch_knowledge/rust_blade_upgrade
	name = "Toxic Blade"
	gain_text = "The Blade will guide you through the flesh, should you let it."
	desc = "Your blade of choice will now poison your enemies on hit."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/spell/entropic_plume)
	banned_knowledge = list(/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade,/datum/eldritch_knowledge/void_blade_upgrade)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_blade_upgrade/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		carbon_target.reagents.add_reagent(/datum/reagent/eldritch, 5)

/datum/eldritch_knowledge/spell/entropic_plume
	name = "Entropic Plume"
	desc = "You can now send a disorienting plume of pure entropy that blinds, poisons and makes enemies strike each other. It also rusts any tiles it affects."
	gain_text = "Messengers of Hope, fear the Rustbringer!"
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/cone/staggered/entropic_plume
	next_knowledge = list(/datum/eldritch_knowledge/final/rust_final,/datum/eldritch_knowledge/spell/cleave,/datum/eldritch_knowledge/summon/rusty)
	route = PATH_RUST

/datum/eldritch_knowledge/armor
	name = "Armorer's Ritual"
	desc = "You can now create Eldritch Armor using a table and a gas mask."
	gain_text = "The Rusted Hills welcomed the Blacksmith in their generosity."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_regen,/datum/eldritch_knowledge/cold_snap)
	required_atoms = list(/obj/structure/table,/obj/item/clothing/mask/gas)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch)

/datum/eldritch_knowledge/essence
	name = "Priest's Ritual"
	desc = "You can now transmute a tank of water and a glass shard into a bottle of eldritch water."
	gain_text = "This is an old recipe. The Owl whispered it to me."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_regen,/datum/eldritch_knowledge/spell/ashen_shift)
	required_atoms = list(/obj/structure/reagent_dispensers/watertank,/obj/item/shard)
	result_atoms = list(/obj/item/reagent_containers/glass/beaker/eldritch)

/datum/eldritch_knowledge/final/rust_final
	name = "Rustbringer's Oath"
	desc = "Bring 3 corpses onto the transmutation rune. After you finish the ritual rust will now automatically spread from the rune. Your healing on rust is also tripled, while you become extremely more resillient."
	gain_text = "Champion of rust. Corruptor of steel. Fear the dark for the Rustbringer has come! Rusted Hills, CALL MY NAME!"
	cost = 3
	required_atoms = list(/mob/living/carbon/human)
	route = PATH_RUST
	var/list/conditional_immunities = list(TRAIT_STUNIMMUNE,TRAIT_SLEEPIMMUNE,TRAIT_PUSHIMMUNE,TRAIT_SHOCKIMMUNE,TRAIT_NOSLIPALL,TRAIT_RADIMMUNE,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RESISTCOLD,TRAIT_RESISTHEAT,TRAIT_PIERCEIMMUNE,TRAIT_BOMBIMMUNE,TRAIT_NOBREATH)
	///if this is set to true then immunities are active, if false then they are not active, simple as.
	var/immunities_active = FALSE

/datum/eldritch_knowledge/final/rust_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	var/mob/living/carbon/human/H = user
	H.physiology.brute_mod *= 0.5
	H.physiology.burn_mod *= 0.5
	H.client?.give_award(/datum/award/achievement/misc/rust_ascension, H)
	RegisterSignal(H,COMSIG_MOVABLE_MOVED,.proc/on_move)
	priority_announce("$^@&#*$^@(#&$(@&#^$&#^@# Fear the decay, for the Rustbringer, [user.real_name] has ascended! None shall escape the corrosion! $^@&#*$^@(#&$(@&#^$&#^@#","#$^@&#*$^@(#&$(@&#^$&#^@#", ANNOUNCER_SPANOMALIES)
	new /datum/rust_spread(loc)
	return ..()

/datum/eldritch_knowledge/final/rust_final/proc/on_move(mob/mover)
	SIGNAL_HANDLER
	var/atom/mover_turf = get_turf(mover)
	var/mover_on_rust = HAS_TRAIT(mover_turf, TRAIT_RUSTY)

	//We check if we are currently standing on a rust tile, but the immunities are not active, if so apply immunities, set immunities_active to TRUE
	if(mover_on_rust && !immunities_active)
		for(var/trait in conditional_immunities)
			ADD_TRAIT(mover,trait,type)
		immunities_active = TRUE
		return

	//We check if we are NOT standing on a rust tile, if so we check if immunities are active, if immunities are active then we de-apply them and set immunities to FALSE
	if(!mover_on_rust && immunities_active)
		for(var/trait in conditional_immunities)
			REMOVE_TRAIT(mover,trait,type)
		immunities_active = FALSE


/datum/eldritch_knowledge/final/rust_final/on_life(mob/user)
	. = ..()
	var/turf/user_loc_turf = get_turf(user)
	if(!HAS_TRAIT(user_loc_turf, TRAIT_RUSTY) || !isliving(user) || !finished)
		return
	var/mob/living/carbon/human/human_user = user
	human_user.adjustBruteLoss(-4, FALSE)
	human_user.adjustFireLoss(-4, FALSE)
	human_user.adjustToxLoss(-4, FALSE, forced = TRUE)
	human_user.adjustOxyLoss(-4, FALSE)
	human_user.adjustStaminaLoss(-20)

/**
 * #Rust spread datum
 *
 * Simple datum that automatically spreads rust around it
 *
 * Simple implementation of automatically growing entity
 */
/datum/rust_spread
	/// The rate of spread every tick.
	var/spread_per_sec = 6
	/// The very center of the spread.
	var/turf/centre
	/// Lazylist of turfs at the edge of our rust (but not yet rusted).
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
 * Recreates the edge_turfs list and the rusted_turfs list.
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
