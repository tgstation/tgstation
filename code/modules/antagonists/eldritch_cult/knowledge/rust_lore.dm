/datum/eldritch_knowledge/base_rust
	name = "Blacksmith's Tale"
	desc = "Opens up the path of rust to you. Allows you to transmute a knife with any trash item into a Rusty Blade."
	gain_text = "Let me tell you a story, blacksmith said as he glazed into his rusty blade."
	banned_knowledge = list(/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_flesh,/datum/eldritch_knowledge/ash_final,/datum/eldritch_knowledge/flesh_final)
	next_knowledge = list(/datum/eldritch_knowledge/rust_fist)
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/trash)
	result_atoms = list(/obj/item/melee/sickly_blade/rust)
	cost = 1
	route = "Rust"

/datum/eldritch_knowledge/rust_fist
	name = "Grasp of rust"
	desc = "Empowers your mansus grasp to deal 500 damage to non-living matter and rust any turf it touches. Destroys already rusted turfs."
	gain_text = "Rust grows on the ceiling of the mansus."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_regen)
	var/rust_force = 500
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/closed,/turf/open/space,/turf/open/lava,/turf/open/chasm,/turf/open/floor/plating/rust))
	route = "Rust"

/datum/eldritch_knowledge/rust_fist/mansus_grasp_act(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(ishumanbasic(target))
		var/mob/living/carbon/human/H = target
		var/datum/status_effect/eldritch/E = H.has_status_effect(/datum/status_effect/eldritch/rust) || H.has_status_effect(/datum/status_effect/eldritch/ash) || H.has_status_effect(/datum/status_effect/eldritch/flesh)
		if(E)
			E.on_effect()
			H.bleed_rate = min(H.bleed_rate + 4, 8)
	conv_area(target)
	return

/datum/eldritch_knowledge/rust_fist/proc/conv_area(atom/target)
	if(istype(target,/mob/living/simple_animal/bot))
		var/mob/living/simple_animal/bot/B = target
		B.adjustBruteLoss(rust_force)
		return

	if(istype(target,/mob/living/silicon))
		var/mob/living/silicon/S = target
		S.adjustBruteLoss(rust_force)
		return

	if(istype(target,/obj/structure))
		var/obj/structure/S = target
		S.take_damage(rust_force, BRUTE, "melee", 1)
		return

	if(istype(target,/obj/machinery))
		var/obj/machinery/M = target
		M.take_damage(rust_force, BRUTE, "melee", 1)
		return

	//Walls
	var/turf/T = get_turf(target)
	if(T.type == /turf/closed/wall/rust)
		T.ScrapeAway()
		return
	if(T.type == /turf/closed/wall/r_wall/rust && prob(50))
		T.ScrapeAway()
		return
	if(T.type == /turf/closed/wall)
		T.ChangeTurf(/turf/closed/wall/rust)
		return
	if(T.type == /turf/closed/wall/r_wall && prob(50))
		T.ChangeTurf(/turf/closed/wall/r_wall/rust)
		return
	if(!is_type_in_typecache(T, blacklisted_turfs))
		T.ChangeTurf(/turf/open/floor/plating/rust)
		return

/datum/eldritch_knowledge/spell/area_conversion
	name = "Agressive Spread"
	desc = "Spreads rust to nearby turfs. Destroys already rusted walls."
	gain_text = "All men wise know not to touch the bound king."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/aoe_turf/rust_conversion
	next_knowledge = list(/datum/eldritch_knowledge/rust_blade_upgrade,/datum/eldritch_knowledge/curse/corrosion,/datum/eldritch_knowledge/spell/cleave)
	route = "Rust"

/datum/eldritch_knowledge/rust_regen
	name = "Leeching Walk"
	desc = "Passively heals you when you are on rusted tiles."
	gain_text = "The strength was unparallel, it was unnatural. Blacksmith was smiling."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/armor,/datum/eldritch_knowledge/essence)
	route = "Rust"

/datum/eldritch_knowledge/rust_regen/on_life(mob/user)
	. = ..()
	var/turf/T = get_turf(user)
	if(!istype(T,/turf/open/floor/plating/rust) || !isliving(user))
		return
	var/mob/living/L = user
	L.adjustBruteLoss(-2)
	L.adjustFireLoss(-2)
	L.adjustToxLoss(-2)
	L.adjustOxyLoss(-0.5)
	L.adjustStaminaLoss(-2)
	return

/datum/eldritch_knowledge/rust_mark
	name = "Mark of Rust"
	desc = "Your eldritch blade now applies a rust mark. Rust mark has a chance to deal between 0 to 200 damage to 75% of enemies items. To Detonate the mark use your mansus grasp on it."
	gain_text = "Lords of the depths help those in dire need at a cost."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/spell/area_conversion)
	banned_knowledge = list(/datum/eldritch_knowledge/ash_mark,/datum/eldritch_knowledge/flesh_mark)
	route = "Rust"

/datum/eldritch_knowledge/rust_mark/eldritch_blade_act(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(istype(target,/mob/living))
		var/mob/living/L = target
		L.apply_status_effect(/datum/status_effect/eldritch/rust)

/datum/eldritch_knowledge/rust_blade_upgrade
	name = "Toxic blade"
	gain_text = "Let the blade guide you through the flesh."
	desc = "Your blade of choice will now add toxin to enemies bloodstream."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/spell/rust_wave)
	banned_knowledge = list(/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade)
	route = "Rust"

/datum/eldritch_knowledge/rust_blade_upgrade/eldritch_blade_act(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.reagents.add_reagent(/datum/reagent/toxin,5)

/datum/eldritch_knowledge/spell/rust_wave
	name = "Wave of Rust"
	desc = "You can now send a projectile that converts an area into rust."
	gain_text = "Messenger's of hope fear the rustbringer!"
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/targeted/projectile/dumbfire/rust_wave
	next_knowledge = list(/datum/eldritch_knowledge/rust_final,/datum/eldritch_knowledge/spell/blood_siphon,/datum/eldritch_knowledge/summon/rusty)
	route = "Rust"

/datum/eldritch_knowledge/armor
	name = "Armorer's ritual"
	desc = "You can now create eldritch armor using a table and a kitchen knife."
	gain_text = "For I am the heir to the throne of doom."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_regen,/datum/eldritch_knowledge/flesh_ghoul)
	required_atoms = list(/obj/structure/table,/obj/item/kitchen/knife)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch)

/datum/eldritch_knowledge/essence
	name = "Priest's ritual"
	desc = "You can now transmute a tank of water into a bottle of eldritch water."
	gain_text = "This is an old recipe, i got it from an owl."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_regen,/datum/eldritch_knowledge/spell/ashen_shift)
	required_atoms = list(/obj/structure/reagent_dispensers/watertank)
	result_atoms = list(/obj/item/reagent_containers/glass/beaker/eldritch)

/datum/eldritch_knowledge/rust_final
	name = "Rustbringer's Oath"
	desc = "Bring 3 corpses onto the transmutation rune. After you finish the ritual rust will now automatically spread from the rune. Your healing on rust is also tripled, while you become more resillient while on rust tiles."
	gain_text = "Champion of rust. Corruptor of steel. Fear the dark for Rustbringer has come!"
	cost = 3
	required_atoms = list(/mob/living/carbon/human)
	route = "Rust"
	var/finished = FALSE
	///keeps track of previous brute mod
	var/prev_brute_mod
	///keeps track of previous burn mod
	var/prev_burn_mod

/datum/eldritch_knowledge/rust_final/recipe_snowflake_check(list/atoms, loc,list/selected_atoms)
	if(finished)
		return FALSE
	var/counter = 0
	for(var/mob/living/carbon/human/H in atoms)
		selected_atoms |= H
		counter++
		if(counter == 3)
			return TRUE
	return FALSE

/datum/eldritch_knowledge/rust_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	prev_brute_mod = user.physiology.brute_mod
	prev_burn_mod = user.physiology.burn_mod
	finished = TRUE
	priority_announce("$^@&#*$^@(#&$(@&#^$&#^@# Fear the decay, for Rustbringer [user.real_name] has come! $^@&#*$^@(#&$(@&#^$&#^@#","#$^@&#*$^@(#&$(@&#^$&#^@#", 'sound/ai/spanomalies.ogg')
	new /datum/rust_spread(loc)


	. = ..()

/datum/eldritch_knowledge/rust_final/on_life(mob/user)
	. = ..()
	if(!finished)
		return
	var/mob/living/L = user
	var/turf/T = get_turf(user)
	if(!istype(T,/turf/open/floor/plating/rust) || !isliving(user))
		L.physiology.brute_mod = prev_brute_mod
		L.physiology.burn_mod = prev_burn_mod
		return

	L.adjustBruteLoss(-3)
	L.adjustFireLoss(-3)
	L.adjustToxLoss(-3)
	L.adjustOxyLoss(-1)
	L.adjustStaminaLoss(-10)
	L.physiology.brute_mod = prev_brute_mod * 0.5
	L.physiology.burn_mod = prev_burn_mod * 0.5


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
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/closed/wall/rust,/turf/closed/wall/r_wall/rust,/turf/open/space,/turf/open/lava,/turf/open/chasm,/turf/open/floor/plating/rust))
	var/spread_per_tick = 5


/datum/rust_spread/New(loc)
	var/turf/T = get_turf(loc)
	T.ChangeTurf(/turf/open/floor/plating/rust)
	turfs += T
	START_PROCESSING(SSprocessing,src)
	. = ..()

/datum/rust_spread/Destroy(force, ...)
	STOP_PROCESSING(SSprocessing,src)
	. = ..()

/datum/rust_spread/process()
	compile_turfs()
	var/turf/T
	var/T1
	for(var/i = 0, i < spread_per_tick,i++)
		T = pick(edge_turfs)
		if(istype(T,/turf/closed/wall))
			edge_turfs -= T
			T1 = T.ChangeTurf(/turf/closed/wall/rust)
			turfs += T1
			continue
		if(istype(T,/turf/closed/wall/r_wall))
			edge_turfs -= T
			T1 = T.ChangeTurf(/turf/closed/wall/r_wall/rust)
			turfs += T1
			continue
		if(istype(T,/turf/open/floor))
			edge_turfs -= T
			T1 = T.ChangeTurf(/turf/open/floor/plating/rust)
			turfs += T1
			continue

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
			if(is_type_in_typecache(T,blacklisted_turfs))
				continue
			edge_turfs += T

