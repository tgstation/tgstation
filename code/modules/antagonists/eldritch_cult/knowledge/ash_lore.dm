/datum/eldritch_knowledge/base_ash
	name = "Nightwatcher's secret"
	desc = "Opens up the path of ash to you. Allows you to transmute a match with a knife into an ashen blade."
	gain_text = "City guard knows their watch. If you ask them at night they may tell you about the ashy lantern."
	banned_knowledge = list(/datum/eldritch_knowledge/base_rust,/datum/eldritch_knowledge/base_flesh,/datum/eldritch_knowledge/rust_final,/datum/eldritch_knowledge/flesh_final)
	next_knowledge = list(/datum/eldritch_knowledge/ashen_grasp)
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/match)
	result_atoms = list(/obj/item/melee/sickly_blade/ash)
	cost = 1
	route = "Ash"

/datum/eldritch_knowledge/spell/ashen_shift
	name = "Ashen Shift"
	gain_text = "Ash is all the same, how can one man master it all?"
	desc = "Short range jaunt that can help you escape from bad situations."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash
	next_knowledge = list(/datum/eldritch_knowledge/ash_mark,/datum/eldritch_knowledge/essence,/datum/eldritch_knowledge/ashen_eyes)
	route = "Ash"

/datum/eldritch_knowledge/ashen_grasp
	name = "Grasp of Ash"
	gain_text = "Gates have opened, minds have flooded, I remain."
	desc = "Empowers your mansus grasp to throw away enemies."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/spell/ashen_shift)
	route = "Ash"

/datum/eldritch_knowledge/ashen_grasp/mansus_grasp_act(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!iscarbon(target))
		return

	var/mob/living/carbon/C = target
	var/datum/status_effect/eldritch/E = C.has_status_effect(/datum/status_effect/eldritch/rust) || C.has_status_effect(/datum/status_effect/eldritch/ash) || C.has_status_effect(/datum/status_effect/eldritch/flesh)
	if(E)
		E.on_effect()
		for(var/X in user.mind.spell_list)
			if(!istype(X,/obj/effect/proc_holder/spell/targeted/touch/mansus_grasp))
				continue
			var/obj/effect/proc_holder/spell/targeted/touch/mansus_grasp/MG = X
			MG.charge_counter = min(round(MG.charge_counter + MG.charge_max * 0.75),MG.charge_max) // refunds 75% of charge.
	var/atom/throw_target = get_edge_target_turf(C, user.dir)
	if(!C.anchored)
		C.throw_at(throw_target, rand(4,8), 14, user)
	return

/datum/eldritch_knowledge/ashen_eyes
	name = "Ashen Eyes"
	gain_text = "Piercing eyes may guide me through the mundane."
	desc = "Allows you to craft thermal vision amulet by transmutating eyes with a glass shard."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/spell/ashen_shift,/datum/eldritch_knowledge/flesh_ghoul)
	required_atoms = list(/obj/item/organ/eyes,/obj/item/shard)
	result_atoms = list(/obj/item/clothing/neck/eldritch_amulet)

/datum/eldritch_knowledge/ash_mark
	name = "Mark of ash"
	gain_text = "Spread the famine."
	desc = "Your sickly blade now applies ash mark on hit. Use your mansus grasp to proc the mark. Mark of Ash causes stamina damage, and fire loss, and spreads to a nearby carbon. Damage scales with how many times the mark has spread."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/curse/blindness)
	banned_knowledge = list(/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/flesh_mark)
	route = "Ash"

/datum/eldritch_knowledge/ash_mark/eldritch_blade_act(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(istype(target,/mob/living))
		var/mob/living/L = target
		L.apply_status_effect(/datum/status_effect/eldritch/ash,1)

/datum/eldritch_knowledge/curse/blindness
	name = "Curse of blindness"
	gain_text = "Blind man walks through the world, unnoticed by the masses."
	desc = "Curse someone with 2 minutes of complete blindness by sacrificing a pair of eyes, a knife and a pool of blood, with an object that the victim has touched."
	cost = 1
	required_atoms = list(/obj/item/organ/eyes,/obj/item/kitchen/knife,/obj/effect/decal/cleanable/blood)
	next_knowledge = list(/datum/eldritch_knowledge/curse/corrosion,/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/curse/paralysis)
	timer = 2 MINUTES
	route = "Ash"

/datum/eldritch_knowledge/curse/blindness/curse(mob/living/chosen_mob)
	. = ..()
	chosen_mob.become_blind(MAGIC_TRAIT)

/datum/eldritch_knowledge/curse/blindness/uncurse(mob/living/chosen_mob)
	. = ..()
	chosen_mob.cure_blind(MAGIC_TRAIT)

/datum/eldritch_knowledge/spell/mad_touch
	name = "Touch of Madness"
	gain_text = "Take what's yours."
	desc = "Short range spell that allows you to curse someone with massive sanity loss."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/pointed/touch/mad_touch
	next_knowledge = list(/datum/eldritch_knowledge/spell/blood_siphon,/datum/eldritch_knowledge/summon/ashy,/datum/eldritch_knowledge/ash_final)
	route = "Ash"

/datum/eldritch_knowledge/ash_blade_upgrade
	name = "Fiery blade"
	gain_text = "May the sun burn the heretics."
	desc = "Your blade of choice will now add firestacks."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/spell/mad_touch)
	banned_knowledge = list(/datum/eldritch_knowledge/rust_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade)
	route = "Ash"

/datum/eldritch_knowledge/ash_blade_upgrade/eldritch_blade_act(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.adjust_fire_stacks(1)
		C.IgniteMob()

/datum/eldritch_knowledge/curse/corrosion
	name = "Curse of Corrosion"
	gain_text = "Cursed land, cursed man, cursed mind."
	desc = "Curse someone for 2 minutes of vomiting and slight organ damage. Using a knife, a spill of blood, a heart, left arm and a right arm, and an item that the victim touched."
	cost = 1
	required_atoms = list(/obj/item/kitchen/knife,/obj/effect/decal/cleanable/blood,/obj/item/organ/heart,/obj/item/bodypart/l_arm,/obj/item/bodypart/r_arm)
	next_knowledge = list(/datum/eldritch_knowledge/curse/blindness,/datum/eldritch_knowledge/spell/area_conversion)
	timer = 2 MINUTES

/datum/eldritch_knowledge/curse/corrosion/curse(mob/living/chosen_mob)
	. = ..()
	chosen_mob.apply_status_effect(/datum/status_effect/corrosion_curse)

/datum/eldritch_knowledge/curse/corrosion/uncurse(mob/living/chosen_mob)
	. = ..()
	chosen_mob.remove_status_effect(/datum/status_effect/corrosion_curse)

/datum/eldritch_knowledge/curse/paralysis
	name = "Curse of Paralysis"
	gain_text = "Corrupt their flesh, make them bleed."
	desc = "Curse someone for 5 minutes of inability to walk. Using a knife, pool of blood, left leg, right leg, a hatchet and an item that the victim touched. "
	cost = 1
	required_atoms = list(/obj/item/kitchen/knife,/obj/effect/decal/cleanable/blood,/obj/item/bodypart/l_leg,/obj/item/bodypart/r_leg,/obj/item/hatchet)
	next_knowledge = list(/datum/eldritch_knowledge/curse/blindness,/datum/eldritch_knowledge/summon/raw_prophet)
	timer = 5 MINUTES

/datum/eldritch_knowledge/curse/paralysis/curse(mob/living/chosen_mob)
	. = ..()
	ADD_TRAIT(chosen_mob,TRAIT_PARALYSIS_L_LEG,MAGIC_TRAIT)
	ADD_TRAIT(chosen_mob,TRAIT_PARALYSIS_R_LEG,MAGIC_TRAIT)

/datum/eldritch_knowledge/curse/paralysis/uncurse(mob/living/chosen_mob)
	. = ..()
	REMOVE_TRAIT(chosen_mob,TRAIT_PARALYSIS_L_LEG,MAGIC_TRAIT)
	REMOVE_TRAIT(chosen_mob,TRAIT_PARALYSIS_R_LEG,MAGIC_TRAIT)

/datum/eldritch_knowledge/spell/cleave
	name = "Blood Cleave"
	gain_text = "At first i didn't know these instruments of war, but the priest told me to use them."
	desc = "Gives AOE spell that causes heavy bleeding."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/pointed/ash_cleave
	next_knowledge = list(/datum/eldritch_knowledge/summon/raw_prophet,/datum/eldritch_knowledge/spell/area_conversion)

/datum/eldritch_knowledge/ash_final
	name = "Ashlord's rite"
	gain_text = "The forgotten lords have spoken! The lord of ash have come! Fear the fire!"
	desc = "Bring 3 corpses onto a transmutation rune, you will become immune to fire ,space ,cold and other enviromental hazards. You will gain a spell that passively creates ring of fire around you as well as you will gain a powerful abiltiy that let's you breath flames of the beast.
	required_atoms = list(/mob/living/carbon/human)
	cost = 3
	route = "Ash"
	var/finished = FALSE
	var/list/trait_list = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOFIRE,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER,TRAIT_BOMBIMMUNE)

/datum/eldritch_knowledge/ash_final/recipe_snowflake_check(list/atoms, loc,list/selected_atoms)
	if(finished)
		return FALSE
	var/counter = 0
	for(var/mob/living/carbon/human/H in atoms)
		selected_atoms |= H
		counter++
		if(counter == 3)
			return TRUE
	return FALSE

/datum/eldritch_knowledge/ash_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	if(finished)
		return
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/pointed/ash_final)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/fire_sworn)
	for(var/X in trait_list)
		ADD_TRAIT(user,X,MAGIC_TRAIT)
	finished = TRUE
	. = ..()

/datum/eldritch_knowledge/ash_final/on_life(mob/user)
	. = ..()
	if(!finished)
		return
	var/turf/L = get_turf(user)
	var/datum/gas_mixture/env = L.return_air()
	env.temperature += 50
	for(var/turf/T in range(1,user)-range(0,user))
		env = T.return_air()
		env.temperature += 25
		T.air_update_turf()
	L.air_update_turf()
