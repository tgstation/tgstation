//cow
/mob/living/basic/cow
	name = "cow"
	desc = "Known for their milk, just don't tip them over."
	icon = 'icons/mob/simple/cows.dmi'
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speak_emote = list("moos","moos hauntingly")
	speed = 1.1
	butcher_results = list(/obj/item/food/meat/slab/grassfed = 6)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	attack_sound = 'sound/items/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_KICK
	health = 50
	maxHealth = 50
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	ai_controller = /datum/ai_controller/basic_controller/cow
	/// what this cow munches on, and what can be used to tame it.
	var/list/food_types = list(/obj/item/food/grown/wheat)
	/// message sent when tamed
	var/tame_message = "lets out a happy moo"
	/// singular version for player cows
	var/self_tame_message = "let out a happy moo"
	/// What kind of juice do we produce?
	var/milked_reagent = /datum/reagent/consumable/milk

/datum/emote/cow
	mob_type_allowed_typecache = /mob/living/basic/cow
	mob_type_blacklist_typecache = list()

/datum/emote/cow/moo
	key = "moo"
	key_third_person = "moos"
	message = "moos happily!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/mobs/non-humanoids/cow/cow.ogg'

/mob/living/basic/cow/Initialize(mapload)
	AddComponent(/datum/component/tippable, \
		tip_time = 0.5 SECONDS, \
		untip_time = 0.5 SECONDS, \
		self_right_time = rand(25 SECONDS, 50 SECONDS), \
		post_tipped_callback = CALLBACK(src, PROC_REF(after_cow_tipped)))
	AddElement(/datum/element/pet_bonus, "moo")
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_COW, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	setup_udder()
	setup_eating()
	. = ..()
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(food_types))

///wrapper for the udder component addition so you can have uniquely uddered cow subtypes
/mob/living/basic/cow/proc/setup_udder()
	AddComponent(/datum/component/udder, reagent_produced_override = milked_reagent)

/*
 * food related components and elements are set up here for a few reasons:
 *
 * * static list can be created per-subtype, since static lists cannot be inherited and then changed
 * * all eating-related components and elements share the same pool of food the mob likes
 */
/mob/living/basic/cow/proc/setup_eating()
	var/static/list/food_types
	if(!food_types)
		food_types = src.food_types.Copy()
	AddComponent(/datum/component/tameable, food_types = food_types, tame_chance = 25, bonus_tame_chance = 15)
	AddElement(/datum/element/basic_eating, food_types = food_types)

/mob/living/basic/cow/tamed(mob/living/tamer, atom/food)
	buckle_lying = 0
	visible_message("[src] [tame_message] as it seems to bond with [tamer].", "You [self_tame_message], recognizing [tamer] as your new pal.")
	AddElement(/datum/element/ridable, /datum/component/riding/creature/cow)

/*
 * Proc called via callback after the cow is tipped by the tippable component.
 * Begins a timer for us pleading for help.
 *
 * tipper - the mob who tipped us
 */
/mob/living/basic/cow/proc/after_cow_tipped(mob/living/carbon/tipper)
	addtimer(CALLBACK(src, PROC_REF(set_tip_react_blackboard), tipper), rand(10 SECONDS, 20 SECONDS))

/*
 * We've been waiting long enough, we're going to tell our AI to begin pleading.
 *
 * tipper - the mob who originally tipped us
 */
/mob/living/basic/cow/proc/set_tip_react_blackboard(mob/living/carbon/tipper)
	if(!HAS_TRAIT_FROM(src, TRAIT_IMMOBILIZED, TIPPED_OVER) || !ai_controller)
		return
	ai_controller.set_blackboard_key(BB_BASIC_MOB_TIP_REACTING, TRUE)
	ai_controller.set_blackboard_key(BB_BASIC_MOB_TIPPER, tipper)
