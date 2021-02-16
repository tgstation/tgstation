/datum/eldritch_knowledge/base_void
	name = "Glimmer of Winter"
	desc = "Opens up the path of void to you. Allows you to transmute a knife in a sub-zero temperature into a void blade."
	gain_text = "I feel a shimmer in the air, atmosphere around me gets colder. I feel my body realizing the emptiness of existance. Something's watching me"
	banned_knowledge = list(/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_flesh,/datum/eldritch_knowledge/final/ash_final,/datum/eldritch_knowledge/final/flesh_final,/datum/eldritch_knowledge/base_rust,/datum/eldritch_knowledge/final/rust_final)
	next_knowledge = list(/datum/eldritch_knowledge/void_grasp)
	required_atoms = list(/obj/item/kitchen/knife)
	result_atoms = list(/obj/item/melee/sickly_blade/void)
	cost = 1
	route = PATH_VOID

/datum/eldritch_knowledge/base_void/recipe_snowflake_check(list/atoms, loc)
	. = ..()
	var/turf/open/turfie = loc
	if(turfie.GetTemperature() > T0C)
		return FALSE

/datum/eldritch_knowledge/void_grasp
	name = "Grasp of Void"
	desc = "Temporarily mutes your victim, also lowers their body temperature."
	gain_text = "I found the cold watcher who observes me. The resonance of cold grows within me. This isn't the end of the mystery."
	cost = 1
	route = PATH_VOID
	next_knowledge = list(/datum/eldritch_knowledge/cold_snap)

/datum/eldritch_knowledge/void_grasp/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/carbon_target = target
	var/turf/open/turfie = get_turf(carbon_target)
	turfie.TakeTemperature(-20)
	carbon_target.adjust_bodytemperature(-40)
	carbon_target.silent += 4
	return TRUE

/datum/eldritch_knowledge/void_grasp/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	var/datum/status_effect/eldritch/E = H.has_status_effect(/datum/status_effect/eldritch/rust) || H.has_status_effect(/datum/status_effect/eldritch/ash) || H.has_status_effect(/datum/status_effect/eldritch/flesh)  || H.has_status_effect(/datum/status_effect/eldritch/void)
	if(!E)
		return
	E.on_effect()
	H.silent += 3

/datum/eldritch_knowledge/cold_snap
	name = "Aristocrat's Way"
	desc = "Makes you immune to cold temperatures, and you no longer need to breathe, you can still take damage from lack of pressure."
	gain_text = "I found a thread of cold breath. It lead me to a strange shrine, all made of crystals. Translucent and white, a depiction of a nobleman stood before me."
	cost = 1
	route = PATH_VOID
	next_knowledge = list(/datum/eldritch_knowledge/void_cloak,/datum/eldritch_knowledge/void_mark,/datum/eldritch_knowledge/armor)

/datum/eldritch_knowledge/cold_snap/on_gain(mob/user)
	. = ..()
	ADD_TRAIT(user,TRAIT_RESISTCOLD,MAGIC_TRAIT)
	ADD_TRAIT(user, TRAIT_NOBREATH, MAGIC_TRAIT)

/datum/eldritch_knowledge/cold_snap/on_lose(mob/user)
	. = ..()
	REMOVE_TRAIT(user,TRAIT_RESISTCOLD,MAGIC_TRAIT)
	REMOVE_TRAIT(user, TRAIT_NOBREATH, MAGIC_TRAIT)

/datum/eldritch_knowledge/void_cloak
	name = "Void Cloak"
	desc = "A cloak that can become invisbile at will, hiding items you store in it. To create it transmute a glass shard, any item of clothing that you can fit over your uniform and any type of bedsheet."
	gain_text = "Owl is the keeper of things that quite not are in practice, but in theory are."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/flesh_ghoul,/datum/eldritch_knowledge/cold_snap)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/void)
	required_atoms = list(/obj/item/shard,/obj/item/clothing/suit,/obj/item/bedsheet)

/datum/eldritch_knowledge/void_mark
	name = "Mark of Void"
	gain_text = "A gust of wind? Maybe a shimmer in the air. Presence is overwhelming, my senses betrayed me, my mind is my enemy."
	desc = "Your mansus grasp now applies mark of void status effect. To proc the mark, use your sickly blade on the marked. Mark of void when procced lowers the victims body temperature significantly."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/spell/void_phase)
	banned_knowledge = list(/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/ash_mark,/datum/eldritch_knowledge/flesh_mark)
	route = PATH_VOID

/datum/eldritch_knowledge/void_mark/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!isliving(target))
		return
	. = TRUE
	var/mob/living/living_target = target
	living_target.apply_status_effect(/datum/status_effect/eldritch/void)

/datum/eldritch_knowledge/spell/void_phase
	name = "Void Phase"
	gain_text = "Reality bends under the power of memory, for all is fleeting, and what else stays?"
	desc = "You gain a long range pointed blink that allows you to instantly teleport to your location, it causes aoe damage around you and your chosen location."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/pointed/void_blink
	next_knowledge = list(/datum/eldritch_knowledge/rune_carver,/datum/eldritch_knowledge/crucible,/datum/eldritch_knowledge/void_blade_upgrade)
	route = PATH_VOID

/datum/eldritch_knowledge/rune_carver
	name = "Carving Knife"
	gain_text = "Etched, carved... eternal. I can carve the monolith and evoke their powers!"
	desc = "You can create a carving knife, which allows you to create up to 3 carvings on the floor that have various effects on nonbelievers who walk over them. They make quite a handy throwing weapon. To create the carving knife transmute a knife with a glass shard and a piece of paper."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/spell/void_phase,/datum/eldritch_knowledge/summon/raw_prophet)
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/shard,/obj/item/paper)
	result_atoms = list(/obj/item/melee/rune_knife)

/datum/eldritch_knowledge/crucible
	name = "Mawed Crucible"
	gain_text = "This is pure agony, i wasn't able to summon the dereliction of the emperor, but i stumbled upon a diffrent recipe..."
	desc = "Allows you to create a mawed crucible, eldritch structure that allows you to create potions of various effects, to do so transmute a table with a watertank"
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/spell/void_phase,/datum/eldritch_knowledge/spell/area_conversion)
	required_atoms = list(/obj/structure/reagent_dispensers/watertank,/obj/structure/table)
	result_atoms = list(/obj/structure/eldritch_crucible)

/datum/eldritch_knowledge/void_blade_upgrade
	name = "Seeking blade"
	gain_text = "Fleeting memories, fleeting feet. I can mark my way with the frozen blood upon the snow. Covered and forgotten."
	desc = "You can now use your blade on a distant marked target to move to them and attack them."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/spell/voidpull)
	banned_knowledge = list(/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade,/datum/eldritch_knowledge/rust_blade_upgrade)
	route = PATH_VOID

/datum/eldritch_knowledge/void_blade_upgrade/on_ranged_attack_eldritch_blade(atom/target, mob/user, click_parameters)
	. = ..()
	if(!ishuman(target) || !iscarbon(user))
		return
	var/mob/living/carbon/carbon_human = user
	var/mob/living/carbon/human/human_target = target
	var/datum/status_effect/eldritch/effect = human_target.has_status_effect(/datum/status_effect/eldritch/rust) || human_target.has_status_effect(/datum/status_effect/eldritch/ash) || human_target.has_status_effect(/datum/status_effect/eldritch/flesh) || human_target.has_status_effect(/datum/status_effect/eldritch/void)
	if(!effect)
		return
	var/dir = angle2dir(dir2angle(get_dir(user,human_target))+180)
	carbon_human.forceMove(get_step(human_target,dir))
	var/obj/item/melee/sickly_blade/blade = carbon_human.get_active_held_item()
	blade.melee_attack_chain(carbon_human,human_target)

/datum/eldritch_knowledge/spell/voidpull
	name = "Void Pull"
	gain_text = "This entity calls itself the aristocrat, I'm close to ending what was started."
	desc = "You gain an ability that let's you pull people around you closer to you."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/targeted/void_pull
	next_knowledge = list(/datum/eldritch_knowledge/final/void_final,/datum/eldritch_knowledge/spell/blood_siphon,/datum/eldritch_knowledge/summon/rusty)
	route = PATH_VOID

/datum/eldritch_knowledge/final/void_final
	name = "Waltz at the End of Time"
	desc = "Bring 3 corpses onto the transmutation rune. After you finish the ritual you will automatically silence people around you and will summon a snow storm around you."
	gain_text = "The world falls into darkness. I stand in an empty plane, small flakes of ice fall from the sky. Aristocrat stand before me, he motions to me. We will play a waltz to the whispers of dying reality, as the world is destroyed before our eyes."
	cost = 3
	required_atoms = list(/mob/living/carbon/human)
	route = PATH_VOID
	///soundloop for the void theme
	var/datum/looping_sound/void_loop/sound_loop
	///Reference to the ongoing voidstrom that surrounds the heretic
	var/datum/weather/void_storm/storm

/datum/eldritch_knowledge/final/void_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	var/mob/living/carbon/human/H = user
	H.physiology.brute_mod *= 0.5
	H.physiology.burn_mod *= 0.5
	ADD_TRAIT(H, TRAIT_RESISTLOWPRESSURE, MAGIC_TRAIT)
	H.client?.give_award(/datum/award/achievement/misc/void_ascension, H)
	priority_announce("$^@&#*$^@(#&$(@&#^$&#^@# The nobleman of void [H.real_name] has arrived, step along the Waltz that ends worlds! $^@&#*$^@(#&$(@&#^$&#^@#","#$^@&#*$^@(#&$(@&#^$&#^@#", ANNOUNCER_SPANOMALIES)

	sound_loop = new(list(user),TRUE,TRUE)
	return ..()

/datum/eldritch_knowledge/final/void_final/on_death()
	if(sound_loop)
		sound_loop.stop()
	if(storm)
		storm.end()
		QDEL_NULL(storm)

/datum/eldritch_knowledge/final/void_final/on_life(mob/user)
	. = ..()
	if(!finished)
		return

	for(var/mob/living/carbon/livies in spiral_range(7,user)-user)
		if(IS_HERETIC_MONSTER(livies) || IS_HERETIC(livies))
			return
		livies.silent += 1
		livies.adjust_bodytemperature(-20)

	var/turf/turfie = get_turf(user)
	if(!isopenturf(turfie))
		return
	var/turf/open/open_turfie = turfie
	open_turfie.TakeTemperature(-20)

	var/area/user_area = get_area(user)
	var/turf/user_turf = get_turf(user)

	if(!storm)
		storm = new /datum/weather/void_storm(list(user_turf.z))
		storm.telegraph()

	storm.area_type = user_area.type
	storm.impacted_areas = list(user_area)
	storm.update_areas()
