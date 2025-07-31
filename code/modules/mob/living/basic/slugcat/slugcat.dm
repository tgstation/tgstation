/mob/living/basic/slugcat
	name = "slugcat"
	desc = "They're a cat... and slug!"
	icon_state = "spacecat"
	icon_living = "spacecat"
	icon_dead = "spacecat_dead"
	held_state = "spacecat"
	icon = 'icons/mob/simple/slugcat/slugcat.dmi'
	held_lh = 'icons/mob/simple/slugcat/slugcat_held_lh.dmi'
	held_rh = 'icons/mob/simple/slugcat/slugcat_held_rh.dmi'
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = ICEBOX_MIN_TEMPERATURE - 10
	maximum_survivable_temperature = LAVALAND_MAX_TEMPERATURE + 10
	maxHealth = 45
	health = 45
	speak_emote = list("purrs", "meows")
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	butcher_results = list(
		/obj/item/food/meat/slab = 1,
		/obj/item/organ/ears/cat = 1,
		/obj/item/organ/tail/cat = 1,
		/obj/item/stack/sheet/animalhide/cat = 1
	)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	gold_core_spawnable = FRIENDLY_SPAWN
	can_be_held = TRUE
	ai_controller = /datum/ai_controller/basic_controller/cat
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/items/weapons/slash.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	var/static/list/scug_food = list(
		/obj/item/food/grown/berries,
		/obj/item/food/grown/grapes,
		/obj/item/food/grown/mushroom/,
		/obj/item/food/grown/ash_flora/,
	)
	var/static/list/scug_bad_items = typecacheof(list(
		/obj/item/gun,
		/obj/item/melee/baton,
		/obj/item/grenade,
		/obj/item/transfer_valve,
		/obj/item/aicard,
		/obj/item/assembly,
	))
	hud_type = /datum/hud/dextrous/slugcat
	/// Back slot
	var/obj/item/internal_storage
	var/list/slugcat_overlays[DRONE_TOTAL_LAYERS]


/mob/living/basic/slugcat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/pet_bonus, "purr", /datum/mood_event/pet_animal)
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_CLAW)
	add_verb(src, /mob/living/proc/toggle_resting)
	add_traits(list(TRAIT_CATLIKE_GRACE, TRAIT_VENTCRAWLER_ALWAYS, TRAIT_WOUND_LICKER, TRAIT_COLORBLIND, TRAIT_NODROWN, TRAIT_SWIMMER, TRAIT_ADVANCEDTOOLUSER, TRAIT_LITERATE, TRAIT_CAN_STRIP, TRAIT_CAN_THROW_ITEMS), INNATE_TRAIT)
	AddElement(/datum/element/dextrous, hud_type = hud_type, can_throw = TRUE)
	AddComponent(/datum/component/personal_crafting)
	AddComponent(/datum/component/basic_inhands, y_offset = -5)
	LoadComponent(/datum/component/item_blacklist, scug_bad_items, "You don't know how to use %TARGET.")
	AddElement(/datum/element/basic_eating, heal_amt = 10, food_types = scug_food)

/mob/living/basic/slugcat/update_resting()
	. = ..()
	if(stat == DEAD)
		return
	update_appearance(UPDATE_ICON_STATE)

/mob/living/basic/slugcat/update_icon_state()
	. = ..()
	if (resting)
		icon_state = "[icon_living]_rest"
		return
	icon_state = "[icon_living]"

/mob/living/basic/slugcat/examine(mob/user)
	. = list()

	for(var/obj/item/held_thing in held_items)
		if((held_thing.item_flags & (ABSTRACT|HAND_ITEM)) || HAS_TRAIT(held_thing, TRAIT_EXAMINE_SKIP))
			continue
		. += "It has [held_thing.examine_title(user)] in its [get_held_index_name(get_held_index_of_item(held_thing))]."

	if(internal_storage && !(internal_storage.item_flags & ABSTRACT))
		. += "It is wearing [internal_storage.examine_title(user)] on its back."
	if((health != maxHealth) && stat != DEAD)
		if(health > maxHealth * 0.33)
			. += span_warning("It appears to be injured.")
		else
			. += span_boldwarning("It appears to be severely injured!")
	if(stat == DEAD)
		if(client)
			. += span_deadsay("It is unmoving. But still bound to a soul.")
		else
			. += span_deadsay("It is unmoving.")

/mob/living/basic/slugcat/rivulet
	name = "rivulet"
	desc = "A very territorial predator known to hunt local fauna using improvised weaponry. Highly agile underwater."
	icon = 'icons/mob/simple/slugcat/rivulet.dmi'
	speed = 0.75
	maxHealth = 50
	health = 50
	melee_damage_lower = 6
	melee_damage_upper = 8
	melee_attack_cooldown = CLICK_CD_MELEE-2
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile
	gold_core_spawnable = NO_SPAWN
	faction = list(FACTION_ASHWALKER)
	can_be_held = FALSE
	unique_name = TRUE

/mob/living/basic/slugcat/rivulet/Initialize(mapload)
	. = ..()
	REMOVE_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(check_location))
	check_location(src, null)

/mob/living/basic/slugcat/rivulet/proc/check_location(atom/movable/mover, turf/old_loc, dir, forced)
	SIGNAL_HANDLER
	var/was_water = istype(old_loc, /turf/open/water)
	var/is_water = istype(src.loc, /turf/open/water) && !HAS_TRAIT(src.loc, TRAIT_TURF_IGNORE_SLOWDOWN)
	if(was_water && !is_water)
		src.remove_movespeed_modifier(/datum/movespeed_modifier/wet_scug)
		src.add_traits(list(TRAIT_NO_STAGGER, TRAIT_NO_THROW_HITPUSH), type)
	else if(!was_water && is_water)
		src.add_movespeed_modifier(/datum/movespeed_modifier/wet_scug)
		src.add_traits(list(TRAIT_NO_STAGGER, TRAIT_NO_THROW_HITPUSH), type)
