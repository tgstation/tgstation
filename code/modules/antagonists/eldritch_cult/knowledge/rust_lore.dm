/datum/eldritch_knowledge/base_rust
	name = "Blacksmith's Tale"
	desc = "Opens up the path of rust to you. Allows you to transmute a knife with any trash item into a Rusty Blade."
	gain_text = "Let me tell you a story, blacksmith said as he glazed into his rusty blade."
	banned_knowledge = list(/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_flesh,/datum/eldritch_knowledge/final/ash_final,/datum/eldritch_knowledge/final/flesh_final)
	next_knowledge = list(/datum/eldritch_knowledge/rust_fist)
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/trash)
	result_atoms = list(/obj/item/melee/sickly_blade/rust)
	cost = 1
	route = PATH_RUST

/datum/eldritch_knowledge/rust_fist
	name = "Grasp of rust"
	desc = "Empowers your mansus grasp to deal 500 damage to non-living matter and rust any turf it touches. Destroys already rusted turfs."
	gain_text = "Rust grows on the ceiling of the mansus."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_regen)
	var/rust_force = 500
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/closed,/turf/open/space,/turf/open/lava,/turf/open/chasm,/turf/open/floor/plating/rust))
	route = PATH_RUST

/datum/eldritch_knowledge/rust_fist/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/datum/status_effect/eldritch/E = H.has_status_effect(/datum/status_effect/eldritch/rust) || H.has_status_effect(/datum/status_effect/eldritch/ash) || H.has_status_effect(/datum/status_effect/eldritch/flesh)
		if(E)
			E.on_effect()
			H.adjustOrganLoss(pick(ORGAN_SLOT_BRAIN,ORGAN_SLOT_EARS,ORGAN_SLOT_EYES,ORGAN_SLOT_LIVER,ORGAN_SLOT_LUNGS,ORGAN_SLOT_STOMACH,ORGAN_SLOT_HEART),25)
	target.rust_heretic_act()
	return TRUE

/datum/eldritch_knowledge/spell/area_conversion
	name = "Agressive Spread"
	desc = "Spreads rust to nearby turfs. Destroys already rusted walls."
	gain_text = "All men wise know not to touch the bound king."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/aoe_turf/rust_conversion
	next_knowledge = list(/datum/eldritch_knowledge/rust_blade_upgrade,/datum/eldritch_knowledge/curse/corrosion,/datum/eldritch_knowledge/spell/blood_siphon)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_regen
	name = "Leeching Walk"
	desc = "Passively heals you when you are on rusted tiles."
	gain_text = "The strength was unparallel, it was unnatural. Blacksmith was smiling."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/armor,/datum/eldritch_knowledge/essence)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_regen/on_life(mob/user)
	. = ..()
	var/turf/user_loc_turf = get_turf(user)
	if(!istype(user_loc_turf, /turf/open/floor/plating/rust) || !isliving(user))
		return
	var/mob/living/living_user = user
	living_user.adjustBruteLoss(-2, FALSE)
	living_user.adjustFireLoss(-2, FALSE)
	living_user.adjustToxLoss(-2, FALSE)
	living_user.adjustOxyLoss(-0.5, FALSE)
	living_user.adjustStaminaLoss(-2)

/datum/eldritch_knowledge/rust_mark
	name = "Mark of Rust"
	desc = "Your eldritch blade now applies a rust mark. Rust mark has a chance to deal between 0 to 200 damage to 75% of enemies items. To Detonate the mark use your mansus grasp on it."
	gain_text = "Lords of the depths help those in dire need at a cost."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/spell/area_conversion)
	banned_knowledge = list(/datum/eldritch_knowledge/ash_mark,/datum/eldritch_knowledge/flesh_mark)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_mark/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/eldritch/rust)

/datum/eldritch_knowledge/rust_blade_upgrade
	name = "Toxic blade"
	gain_text = "Let the blade guide you through the flesh."
	desc = "Your blade of choice will now add toxin to enemies bloodstream."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/spell/entropic_plume)
	banned_knowledge = list(/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_blade_upgrade/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		carbon_target.reagents.add_reagent(/datum/reagent/eldritch, 5)

/datum/eldritch_knowledge/spell/entropic_plume
	name = "Entropic Plume"
	desc = "You can now send a befuddling plume that blinds, poisons and makes enemies strike each other. Also converts the area into rust."
	gain_text = "Messenger's of hope fear the rustbringer!"
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/cone/staggered/entropic_plume
	next_knowledge = list(/datum/eldritch_knowledge/final/rust_final,/datum/eldritch_knowledge/spell/cleave,/datum/eldritch_knowledge/summon/rusty)
	route = PATH_RUST

/datum/eldritch_knowledge/armor
	name = "Armorer's ritual"
	desc = "You can now create eldritch armor using a table and a gas mask."
	gain_text = "For I am the heir to the throne of doom."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_regen,/datum/eldritch_knowledge/flesh_ghoul)
	required_atoms = list(/obj/structure/table,/obj/item/clothing/mask/gas)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch)

/datum/eldritch_knowledge/essence
	name = "Priest's ritual"
	desc = "You can now transmute a tank of water into a bottle of eldritch water."
	gain_text = "This is an old recipe, i got it from an owl."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_regen,/datum/eldritch_knowledge/spell/ashen_shift)
	required_atoms = list(/obj/structure/reagent_dispensers/watertank)
	result_atoms = list(/obj/item/reagent_containers/glass/beaker/eldritch)

/datum/eldritch_knowledge/final/rust_final
	name = "Rustbringer's Oath"
	desc = "Bring 3 corpses onto the transmutation rune. After you finish the ritual rust will now automatically spread from the rune. Your healing on rust is also tripled, while you become more resillient overall."
	gain_text = "Champion of rust. Corruptor of steel. Fear the dark for Rustbringer has come!"
	cost = 3
	required_atoms = list(/mob/living/carbon/human)
	route = PATH_RUST

/datum/eldritch_knowledge/final/rust_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	var/mob/living/carbon/human/H = user
	H.physiology.brute_mod *= 0.5
	H.physiology.burn_mod *= 0.5
	priority_announce("$^@&#*$^@(#&$(@&#^$&#^@# Fear the decay, for Rustbringer [user.real_name] has come! $^@&#*$^@(#&$(@&#^$&#^@#","#$^@&#*$^@(#&$(@&#^$&#^@#", 'sound/ai/spanomalies.ogg')
	new /datum/rust_spread(loc)
	var/datum/antagonist/heretic/ascension = H.mind.has_antag_datum(/datum/antagonist/heretic)
	ascension.ascended = TRUE
	return ..()


/datum/eldritch_knowledge/final/rust_final/on_life(mob/user)
	. = ..()
	if(!finished)
		return
	var/mob/living/carbon/human/human_user = user
	human_user.adjustBruteLoss(-3, FALSE)
	human_user.adjustFireLoss(-3, FALSE)
	human_user.adjustToxLoss(-3, FALSE)
	human_user.adjustOxyLoss(-1, FALSE)
	human_user.adjustStaminaLoss(-10)


/**
  * #Rust spread datum
  *
  * Simple datum that automatically spreads rust around it
  *
  * Simple implementation of automatically growing entity
  */
/datum/rust_spread
	var/list/edge_turfs = list()
	var/list/turfs = list()
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/open/indestructible,/turf/closed/indestructible,/turf/open/space,/turf/open/lava,/turf/open/chasm))
	var/spread_per_tick = 6


/datum/rust_spread/New(loc)
	. = ..()
	var/turf/turf_loc = get_turf(loc)
	turf_loc.rust_heretic_act()
	turfs += turf_loc
	START_PROCESSING(SSprocessing,src)


/datum/rust_spread/Destroy(force, ...)
	STOP_PROCESSING(SSprocessing,src)
	return ..()

/datum/rust_spread/process()
	compile_turfs()
	var/turf/T
	for(var/i in 0 to spread_per_tick)
		T = pick(edge_turfs)
		T.rust_heretic_act()
		turfs += get_turf(T)

/**
  * Compile turfs
  *
  * Recreates all edge_turfs as well as normal turfs.
  */
/datum/rust_spread/proc/compile_turfs()
	edge_turfs = list()
	for(var/X in turfs)
		if(!istype(X,/turf/closed/wall/rust) && !istype(X,/turf/closed/wall/r_wall/rust) && !istype(X,/turf/open/floor/plating/rust))
			turfs -=X
			continue
		for(var/turf/T in range(1,X))
			if(T in turfs)
				continue
			if(is_type_in_typecache(T,blacklisted_turfs))
				continue
			edge_turfs += T
