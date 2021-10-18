/mob/living/basic/pigeon
	name = "secretary pigeon"
	desc = "a species of columbid bird bred to deliver mail, documents and small packages.\nIt is said a large online retailer reduced their employment costs by 73% after replacing their delivery drivers with pidgeons."
	icon = 'icons/mob/pigeon.dmi'
	icon_state = "pigeon"
	icon_living = "pigeon"
	icon_dead = "pigeon_dead"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	mob_size = MOB_SIZE_TINY
	speak_emote = list("coos","moos hauntingly")
	speed = 0
	see_in_dark = 3
	butcher_results = list(/obj/item/food/meat/slab/chicken/pigeon = 2)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "pecks"
	attack_verb_simple = "peck"
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_BOOP
	health = 30
	maxHealth = 30
	melee_damage_lower = 3
	melee_damage_upper = 8
	blood_volume = BLOOD_VOLUME_NORMAL
	ai_controller = /datum/ai_controller/basic_controller/pigeon
	///The item the pigeon is carrying in its beak
	var/obj/item/held_item
	var/datum/action/unload_package/unload_package
	var/datum/action/coo/coo

/mob/living/basic/pigeon/Initialize(mapload)
	. = ..()
	unload_package = new()
	unload_package.Grant(src)
	coo = new()
	coo.Grant(src)

	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddElement(/datum/element/basic_body_temp_sensitive, 270, INFINITY)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_PIGEON, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/basic/pigeon/is_literate()
	return TRUE

/mob/living/basic/pigeon/melee_attack(atom/target))
	if(held_item)
		held_item.melee_attack_chain(src, target)
		if(held_item?.loc != src) //If the item ceases to be in our possesion after attacking, we no longer have a held item.
			held_item = null
		update_appearance()
		return
	if(ismob(target))
		return ..()
	if(pick_up_item(target))
		return
	. = ..()

/mob/living/basic/pigeon/proc/pick_up_item(atom/target)
	if(held_item)
		to_chat(src, span_warning("Your beak is full!"))
		return FALSE
	if(!isitem(target))
		return FALSE
	///A static list of item types a pigeon can pick up
	var/static/list/allowed_item_types
	if(!allowed_item_types?.len)
		allowed_item_types = list(
			/obj/item/paper,
			/obj/item/pen,
			/obj/item/mail,
			/obj/item/small_delivery,
			/obj/item/holochip,
			/obj/item/stack/spacecash,
			/obj/item/coin,
		)

	if(!is_type_in_list(target, allowed_item_types))
		return FALSE

	var/obj/item/potential_pigeon_payload = target

	if(potential_pigeon_payload.w_class > WEIGHT_CLASS_SMALL) //Make this weight class normal when fugu glanded, once basic mobs gain fugu compability.
		to_chat(src, span_warning("That package is too heavy for you! Maybe try something lighter..."))
		return FALSE

	held_item = potential_pigeon_payload
	potential_pigeon_payload.forceMove(src)
	to_chat(src, span_notice("You pick up [potential_pigeon_payload]."))
	update_appearance()
	return TRUE

/mob/living/basic/pigeon/proc/drop_item()
	dropItemToGround(held_item)
	held_item = null
	update_appearance()

/datum/ai_controller/basic_controller/pigeon
	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/pigeon,
	)

/datum/action/unload_package
	name = "unload package"
	desc = "Drops whatever item you are carrying in your beak."

/datum/action/unload_package/Trigger()
	. = ..()
	if(!istype(owner, /mob/living/basic/pigeon))
		return
	var/mob/living/basic/pigeon/owner_pigeon = owner
	owner_pigeon.drop_item()

/datum/action/coo
	name = "Coo"
	desc = "Announce your presence with some pigeon noises."

/datum/action/coo/Trigger()
	. = ..()
	owner.emote("coo")
