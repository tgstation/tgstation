/**
 * ## Chicks
 *
 * Baby birds that grow into big chickens.
 */
/mob/living/basic/chick
	name = "\improper chick"
	desc = "Adorable! They make such a racket though."
	icon = 'monkestation/icons/mob/ranching/chickens.dmi'
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak_emote = list("cheeps")
	density = FALSE
	butcher_results = list(/obj/item/food/meat/slab/chicken = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	health = 3
	maxHealth = 3
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = FRIENDLY_SPAWN

	ai_controller = /datum/ai_controller/basic_controller/chick

	/// What we grow into.
	var/grown_type = /mob/living/basic/chicken
	///Glass chicken exclusive:what reagent were the eggs filled with?
	var/list/glass_egg_reagent = list()
	///Stone Chicken Exclusive: what ore type is in the eggs?
	var/obj/item/stack/ore/production_type = null

/mob/living/basic/chick/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-6, 6)
	pixel_y = base_pixel_y + rand(0, 10)

	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	AddElement(/datum/element/pet_bonus, "chirps!")
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CHICKEN, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)

	if(!isnull(grown_type)) // we don't have a set time to grow up beyond whatever RNG dictates, and if we somehow get a client, all growth halts.
		AddComponent(\
			/datum/component/growth_and_differentiation,\
			growth_time = null,\
			growth_path = grown_type,\
			growth_probability = 100,\
			lower_growth_value = 1,\
			upper_growth_value = 2,\
			signals_to_kill_on = list(COMSIG_MOB_CLIENT_LOGIN),\
			optional_checks = CALLBACK(src, PROC_REF(ready_to_grow)),\
			optional_grow_behavior = CALLBACK(src, PROC_REF(grow_up)),\
		)

/// We don't grow into a chicken if we're not conscious.
/mob/living/basic/chick/proc/ready_to_grow()
	return (stat == CONSCIOUS)

/// Variant of chick that just spawns in the holodeck so you can pet it. Doesn't grow up.
/mob/living/basic/chick/permanent
	grown_type = null

/mob/living/basic/chick/proc/assign_chick_icon(mob/living/basic/chicken/chicken_type)
	if(!chicken_type) // do we have a grown type?
		return

	var/mob/living/basic/chicken/hatched_type = new chicken_type(src)
	icon_state = "chick_[hatched_type.icon_suffix]"
	held_state = "chick_[hatched_type.icon_suffix]"
	icon_living = "chick_[hatched_type.icon_suffix]"
	icon_dead = "dead_[hatched_type.icon_suffix]"
	qdel(hatched_type)

/mob/living/basic/chick/proc/grow_up()
	if(!grown_type)
		return
	var/mob/living/basic/chicken/new_chicken = new grown_type(src.loc)
	SEND_SIGNAL(src, COMSIG_FRIENDSHIP_PASS_FRIENDSHIP, new_chicken)
	SEND_SIGNAL(src, COMSIG_HAPPINESS_PASS_HAPPINESS, new_chicken)
	SEND_SIGNAL(new_chicken, COMSIG_AGE_ADJUSTMENT, rand(1, 10))

	if(istype(new_chicken, /mob/living/basic/chicken/glass))
		for(var/list_item in glass_egg_reagent)
			new_chicken.glass_egg_reagents.Add(list_item)

	if(istype(new_chicken, /mob/living/basic/chicken/stone))
		if(production_type)
			new_chicken.production_type = production_type
	qdel(src)



/mob/living/basic/chick/proc/absorb_eggstat(obj/item/food/egg/host_egg)
	for(var/listed_faction in host_egg.faction_holder)
		src.faction |= listed_faction

	SEND_SIGNAL(host_egg, COMSIG_HAPPINESS_PASS_HAPPINESS, src)
	SEND_SIGNAL(host_egg, COMSIG_FRIENDSHIP_PASS_FRIENDSHIP, src)
	if(istype(grown_type, /mob/living/basic/chicken/glass))
		for(var/list_item in host_egg.glass_egg_reagents)
			src.glass_egg_reagent.Add(list_item)

	if(istype(grown_type, /mob/living/basic/chicken/stone))
		if(host_egg.production_type)
			src.production_type = host_egg.production_type
