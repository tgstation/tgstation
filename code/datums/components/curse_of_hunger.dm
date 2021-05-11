
///inital food tolerances, two dishes
#define FULL_HEALTH 2
///the point where you can notice the item is hungry on examine.
#define HUNGER_THRESHOLD_WARNING 25
///the point where the item has a chance to eat something on every tick. possibly you!
#define HUNGER_THRESHOLD_TRY_EATING 50
/**
 * curse of hunger component; for very hungry items.
 *
 *
 */
/datum/component/curse_of_hunger
	///whether to add dropdel to the item with curse of hunger, used for temporary curses like the wizard duffelbags
	var/add_dropdel
	///items given the curse of hunger will not seek out someone else to latch onto until they are dropped for the first time.
	var/awakened = FALSE
	///counts time passed since it ate food
	var/hunger = 0
	///how many times it needs to be fed poisoned food for it to drop off of you
	var/poison_food_tolerance = FULL_HEALTH

/datum/component/curse_of_hunger/Initialize(add_dropdel = FALSE)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.add_dropdel = add_dropdel

/datum/component/curse_of_hunger/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	if(isclothing(parent))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
		RegisterSignal(parent, COMSIG_ITEM_POST_UNEQUIP, .proc/on_unequip)
	else
		RegisterSignal(parent, COMSIG_ITEM_PICKUP, .proc/on_pickup)
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)

/datum/component/curse_of_hunger/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_POST_UNEQUIP, COMSIG_ITEM_PICKUP, COMSIG_ITEM_DROPPED))

///signal called on parent being examined
/datum/component/curse_of_hunger/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!awakened)
		return //we should not reveal we are cursed until equipped
	if(hunger > HUNGER_THRESHOLD_WARNING)
		examine_list += "<span class='danger'>[parent] is growling for food...</span>"
	if(poison_food_tolerance == FULL_HEALTH)
		examine_list += "<span class='notice'>[parent] looks healthy.</span>"
	else
		examine_list += "<span class='notice'>[parent] looks sick.</span>"

///signal called from equipping parent
/datum/component/curse_of_hunger/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	the_curse_begins(equipper)

///signal called from a successful unequip of parent
/datum/component/curse_of_hunger/proc/on_unequip(mob/living/unequipper, force, atom/newloc, no_move, invdrop, silent)
	SIGNAL_HANDLER
	the_curse_ends(unequipper)

///signal called from picking up parent
/datum/component/curse_of_hunger/proc/on_pickup(datum/source, mob/grabber)
	SIGNAL_HANDLER
	the_curse_begins(grabber)

///signal called from dropping parent
/datum/component/curse_of_hunger/proc/on_drop(datum/source, mob/dropper)
	SIGNAL_HANDLER
	the_curse_ends(dropper)

/datum/component/curse_of_hunger/proc/the_curse_begins(mob/cursed)
	var/obj/item/at_least_item = parent
	if(!(at_least_item.slot_flags && slot))
		return
	awakened = TRUE
	START_PROCESSING(SSobj, src)
	ADD_TRAIT(at_least_item, TRAIT_NODROP, CURSED_ITEM_TRAIT(at_least_item.type))
	if(add_dropdel)
		at_least_item.item_flags |= DROPDEL
	ADD_TRAIT(equipper, TRAIT_CLUMSY, CURSED_ITEM_TRAIT(at_least_item.type))
	ADD_TRAIT(equipper, TRAIT_PACIFISM, CURSED_ITEM_TRAIT(at_least_item.type))

/datum/component/curse_of_hunger/proc/the_curse_ends(mob/uncursed)
	var/obj/item/at_least_item = parent
	STOP_PROCESSING(SSobj, src)
	REMOVE_TRAIT(parent, TRAIT_NODROP, CURSED_ITEM_TRAIT(parent.type))
	REMOVE_TRAIT(unequipper, TRAIT_CLUMSY, CURSED_ITEM_TRAIT(at_least_item.type))
	REMOVE_TRAIT(unequipper, TRAIT_PACIFISM, CURSED_ITEM_TRAIT(at_least_item.type))

	var/turf/vomit_turf = get_turf(newloc)
	playsound(vomit_turf, 'sound/effects/splat.ogg', 50, TRUE)
	new /obj/effect/decal/cleanable/vomit(vomit_turf)

	//if(!add_dropdel) //will still exist after this, why not make it hunt new targets

/datum/component/curse_of_hunger/process(delta_time)
	var/obj/item/cursed_item = parent
	var/mob/living/carbon/cursed = cursed_item.loc
	///check hp
	if(!poison_food_tolerance)
		cursed.dropItemToGround(src, TRUE)
		return
	hunger++
	///check hunger
	if((hunger > HUNGER_THRESHOLD_TRY_EATING) && prob(20))
		for(var/obj/item/food in cursed.contents)
			if(!IS_EDIBLE(food))
				return
			food.forceMove(cursed.loc)
			playsound(src, 'sound/items/eatfood.ogg', 20, TRUE)
			///poisoned food damages it
			if(istype(food, /obj/item/food/badrecipe))
				to_chat(cursed, "<span class='warning'>[cursed_item] begins to look sick after eating [food]!</span>")
				poison_food_tolerance--
			else
				to_chat(cursed, "<span class='notice'>[cursed_item] eats your [food] to sate its hunger.</span>")
			QDEL_NULL(food)
			hunger = 0
			return
		///no food found: it bites you and loses some hp
		var/affecting = cursed.get_bodypart(BODY_ZONE_CHEST)
		cursed.apply_damage(60, BRUTE, affecting)
		hunger = 0
		playsound(src, 'sound/items/eatfood.ogg', 20, TRUE)
		to_chat(cursed, "<span class='userdanger'>[cursed_item] bites you to sate its hunger!</span>")
		poison_food_tolerance = min(poison_food_tolerance++, FULL_HEALTH)
