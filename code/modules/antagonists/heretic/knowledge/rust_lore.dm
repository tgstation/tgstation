/datum/heretic_knowledge_tree_column/rust
	route = PATH_RUST
	ui_bgr = "node_rust"
	complexity = "Medium"
	complexity_color = COLOR_YELLOW
	icon = list(
		"icon" = 'icons/obj/weapons/khopesh.dmi',
		"state" = "rust_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"The Path of Rust revolves around durability, corruption and brute forcing your way through obstacles.",
		"Pick this path if you enjoy a standing your ground and letting the fight come to you.",
	)
	pros = list(
		"Standing on rusted tiles makes you highly durable; regenerating wounds and removing stuns.",
		"Rusted tiles harm your foes and slow them down.",
		"You are able to destroy walls, objects, mechs, structures and airlocks with ease.",
		"You can instantly obliterate silicons or synthetic crew members with your Mansus Grasp.",
		"You have a high amount of disruption abilities to make it easier to fight in your territory.",
	)
	cons = list(
		"Extremely overt; throws stealth completely out as an option.",
		"If you are not on rusted tiles, you become significantly more vulnerable.",
		"Being locked to a territorial conflict makes it much easier to use destructive tools (like bombs) against you.",
		"Your high amount of defensive power is at the cost of offensive power.",
	)
	tips = list(
		"Your Mansus Grasp will instantly destroy mechs, silicons and androids. Hitting a marked target with your blade will cause heavy disgust and make them vomit, knocking them down briefly.",
		"Your Mansus Grasp and your spells are capable of rusting walls and floors, making them beneficial to you and harmful to the crew and silicons. Spread rust as much as possible.",
		"Rusted turfs will heal you, regulate your blood temperature, make you resistant to batons knockdown, regenerate your stamina and blood and heal your wound and limbs once you level up your passive.",
		"Always fight on your turf. Your opponent entering your turf are at a significant disadvantage.",
		"Your Reassembled Raiment is only empowered while you are on your rusted tiles. If you want the most out of its power, stay on your rusted tiles.",
		"Your ability to destroy objects and walls improves as your passive ugprade increases; eventually you will be able to melt through airlocks, reinforced walls and even titanium walls.",
		"Spreading rust can be fairly slow, especially early on. Consider summoning a few rust walkers to help you expand your domain.",
		"Rusted Construction allows you to produce barriers for cover or escape, or even block off someone else's escape in a pinch. Make the most of it to manipulate the environment to your needs.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_rust
	knowledge_tier1 = /datum/heretic_knowledge/spell/area_conversion
	guaranteed_side_tier1 = /datum/heretic_knowledge/rust_sower
	knowledge_tier2 = /datum/heretic_knowledge/spell/rust_construction
	guaranteed_side_tier2 = /datum/heretic_knowledge/summon/rusty
	robes = /datum/heretic_knowledge/armor/rust
	knowledge_tier3 = /datum/heretic_knowledge/spell/entropic_plume
	guaranteed_side_tier3 = /datum/heretic_knowledge/crucible
	blade = /datum/heretic_knowledge/blade_upgrade/rust
	knowledge_tier4 = /datum/heretic_knowledge/spell/rust_charge
	ascension = /datum/heretic_knowledge/ultimate/rust_final

/datum/heretic_knowledge/limited_amount/starting/base_rust
	name = "Blacksmith's Tale"
	desc = "Opens up the Path of Rust to you. \
		Allows you to transmute a knife with any trash item into a Rusty Blade. \
		You can only create two at a time."
	gain_text = "\"Let me tell you a story\", said the Blacksmith, as he gazed deep into his rusty blade."
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/trash = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/rust)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "rust_blade"
	mark_type = /datum/status_effect/eldritch/rust
	eldritch_passive = /datum/status_effect/heretic_passive/rust

/datum/heretic_knowledge/limited_amount/starting/base_rust/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, PROC_REF(on_secondary_mansus_grasp))
	user.RemoveElement(/datum/element/leeching_walk/minor)

/datum/heretic_knowledge/limited_amount/starting/base_rust/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY)
	user.AddElement(/datum/element/leeching_walk/minor)

/datum/heretic_knowledge/limited_amount/starting/base_rust/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		for(var/obj/item/bodypart/robotic_limb as anything in carbon_target.bodyparts)
			if(IS_ROBOTIC_LIMB(robotic_limb))
				robotic_limb.receive_damage(500)

	if(!issilicon(target) && !(target.mob_biotypes & MOB_ROBOTIC))
		return

	source.do_rust_heretic_act(target)

/datum/heretic_knowledge/limited_amount/starting/base_rust/proc/on_secondary_mansus_grasp(mob/living/source, atom/target)
	SIGNAL_HANDLER

	// Rusting an airlock causes it to lose power, mostly to prevent the airlock from shocking you.
	// This is a bit of a hack, but fixing this would require the entire wire cut/pulse system to be reworked.
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock = target
		airlock.loseMainPower()

	source.do_rust_heretic_act(target)
	return COMPONENT_USE_HAND

/datum/heretic_knowledge/spell/rust_charge
	name = "Rust Charge"
	desc = "A charge that must be started on a rusted tile and will destroy any rusted objects you come into contact with, will deal high damage to others and rust around you during the charge."
	gain_text = "The hills sparkled now, as I neared them my mind began to wander. I quickly regained my resolve and pushed forward, this last leg would be the most treacherous."

	action_to_add = /datum/action/cooldown/mob_cooldown/charge/rust
	cost = 2
	is_final_knowledge = TRUE

/datum/heretic_knowledge/spell/rust_construction
	name = "Rust Construction"
	desc = "Grants you Rust Construction, a spell that allows you to raise a wall out of a rusted floor. \
		Anyone overtop the wall will be throw aside (or upwards) and sustain damage."
	gain_text = "Images of foreign and ominous structures began to dance in my mind. Covered head to toe in thick rust, \
		they no longer looked man made. Or perhaps they never were in the first place."
	action_to_add = /datum/action/cooldown/spell/pointed/rust_construction
	cost = 2

/datum/heretic_knowledge/armor/rust
	desc = "Allows you to transmute a table (or a suit), a mask and any trash item to create a Salvaged Remains. \
			Has extra armor, tackle resistance and syringe immunity while standing on rust. \
			Acts as a focus while hooded."
	gain_text = "From beneath warped scrap, the Blacksmith pulls forth an ancient fabric. \
				\"Whatever this once stood for is lost. So now, we give it new purpose.\""
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust)
	research_tree_icon_state = "rust_armor"
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/trash = 1,
	)

/datum/heretic_knowledge/spell/area_conversion
	name = "Aggressive Spread"
	desc = "Grants you Aggressive Spread, a spell that spreads rust to nearby surfaces. \
		Already rusted surfaces are destroyed \ Also improves the rusting abilities of non rust-heretics."
	gain_text = "All wise men know well not to visit the Rusted Hills... Yet the Blacksmith's tale was inspiring."
	action_to_add = /datum/action/cooldown/spell/aoe/rust_conversion
	cost = 2
	research_tree_icon_frame = 5

/datum/heretic_knowledge/blade_upgrade/rust
	name = "Toxic Blade"
	desc = "Your Rusty Blade now disgusts enemies on attack \ Allows you to rust Titanium and Plastitanium.."
	gain_text = "The Blacksmith hands you their blade. \"The Blade will guide you through the flesh, should you let it.\" \
		The heavy rust weights it down. You stare deeply into it. The Rusted Hills call for you, now."
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_rust"

/datum/heretic_knowledge/blade_upgrade/rust/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return
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

	action_to_add = /datum/action/cooldown/spell/cone/staggered/entropic_plume
	cost = 2
	drafting_tier = 5

/datum/heretic_knowledge/ultimate/rust_final
	name = "Rustbringer's Oath"
	desc = "The ascension ritual of the Path of Rust. \
		Bring 3 corpses to a transmutation rune on the bridge of the station to complete the ritual. \
		When completed, the ritual site will endlessly spread rust onto any surface, stopping for nothing. \
		Additionally, you will become extremely resilient on rust, healing at triple the rate \
		and becoming immune to many effects and dangers \ You will be able to rust almost anything upon ascending."
	gain_text = "Champion of rust. Corruptor of steel. Fear the dark, for the RUSTBRINGER has come! \
		The Blacksmith forges ahead! Rusted Hills, CALL MY NAME! WITNESS MY ASCENSION!"

	ascension_achievement = /datum/award/achievement/misc/rust_ascension
	announcement_text = "%SPOOKY% Fear the decay, for the Rustbringer, %NAME% has ascended! None shall escape the corrosion! %SPOOKY%"
	announcement_sound = 'sound/music/antag/heretic/ascend_rust.ogg'
	/// If TRUE, then immunities are currently active.
	var/immunities_active = FALSE
	/// A typepath to an area that we must finish the ritual in.
	var/area/ritual_location = /area/station/command/bridge
	/// A static list of traits we give to the heretic when on rust.
	var/static/list/conditional_immunities = list(
		TRAIT_BOMBIMMUNE,
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
		addtimer(CALLBACK(src, PROC_REF(transform_area), turfs_to_transform["[iterator]"]), (2 SECONDS) * iterator)

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
/datum/heretic_knowledge/ultimate/rust_final/proc/on_move(mob/living/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	// If we're on a rusty turf, and haven't given out our traits, buff our guy
	var/turf/our_turf = get_turf(source)
	if(HAS_TRAIT(our_turf, TRAIT_RUSTY))
		if(!immunities_active)
			source.add_traits(conditional_immunities, type)
			source.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
			immunities_active = TRUE

	// If we're not on a rust turf, and we have given out our traits, nerf our guy
	else
		if(immunities_active)
			source.remove_traits(conditional_immunities, type)
			source.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
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
	var/base_heal_amt = 1 * DELTA_WORLD_TIME(SSmobs)
	need_mob_update += source.adjust_brute_loss(-base_heal_amt, updating_health = FALSE)
	need_mob_update += source.adjust_fire_loss(-base_heal_amt, updating_health = FALSE)
	need_mob_update += source.adjust_tox_loss(-base_heal_amt, updating_health = FALSE, forced = TRUE)
	need_mob_update += source.adjust_oxy_loss(-base_heal_amt, updating_health = FALSE)
	need_mob_update += source.adjust_stamina_loss(-base_heal_amt * 4, updating_stamina = FALSE)

	source.adjust_blood_volume(base_heal_amt, maximum = BLOOD_VOLUME_NORMAL)

	if(need_mob_update)
		source.updatehealth()
