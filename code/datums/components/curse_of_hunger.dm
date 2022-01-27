///inital food tolerances, two dishes
#define FULL_HEALTH 2
///the point where you can notice the item is hungry on examine.
#define HUNGER_THRESHOLD_WARNING 25
///the point where the item has a chance to eat something on every tick. possibly you!
#define HUNGER_THRESHOLD_TRY_EATING 50

/**
 * curse of hunger component; for very hungry items.
 *
 * Used as a rpgloot suffix and wizard spell!
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
	var/obj/item/cursed_item = parent
	RegisterSignal(cursed_item, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	//checking slot_equipment_priority is the better way to decide if it should be an equip-curse (alternative being if it has slot_flags)
	//because it needs to know where to equip to (and stuff like buckets and cones can be on_pickup curses despite having slots to equip to)
	if(cursed_item.slot_equipment_priority)
		RegisterSignal(cursed_item, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
	else
		RegisterSignal(cursed_item, COMSIG_ITEM_PICKUP, .proc/on_pickup)

/datum/component/curse_of_hunger/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_POST_UNEQUIP, COMSIG_ITEM_PICKUP, COMSIG_ITEM_DROPPED))

///signal called on parent being examined
/datum/component/curse_of_hunger/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!awakened)
		return //we should not reveal we are cursed until equipped
	if(poison_food_tolerance != FULL_HEALTH)
		examine_list += span_notice("[parent] looks sick from something it ate.")
	if(hunger > HUNGER_THRESHOLD_WARNING)
		examine_list += span_danger("[parent] hungers for something to eat...")

///signal called from equipping parent
/datum/component/curse_of_hunger/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	var/obj/item/at_least_item = parent
	if(!(at_least_item.slot_flags & slot))
		return
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
	var/obj/item/cursed_item = parent
	awakened = TRUE
	START_PROCESSING(SSobj, src)
	ADD_TRAIT(cursed_item, TRAIT_NODROP, CURSED_ITEM_TRAIT(cursed_item.type))
	ADD_TRAIT(cursed, TRAIT_CLUMSY, CURSED_ITEM_TRAIT(cursed_item.type))
	ADD_TRAIT(cursed, TRAIT_PACIFISM, CURSED_ITEM_TRAIT(cursed_item.type))
	if(add_dropdel)
		cursed_item.item_flags |= DROPDEL
		return
	if(cursed_item.slot_equipment_priority)
		RegisterSignal(cursed_item, COMSIG_ITEM_POST_UNEQUIP, .proc/on_unequip)
	else
		RegisterSignal(cursed_item, COMSIG_ITEM_DROPPED, .proc/on_drop)

/datum/component/curse_of_hunger/proc/the_curse_ends(mob/uncursed)
	var/obj/item/at_least_item = parent
	STOP_PROCESSING(SSobj, src)
	REMOVE_TRAIT(parent, TRAIT_NODROP, CURSED_ITEM_TRAIT(parent.type))
	REMOVE_TRAIT(uncursed, TRAIT_CLUMSY, CURSED_ITEM_TRAIT(at_least_item.type))
	REMOVE_TRAIT(uncursed, TRAIT_PACIFISM, CURSED_ITEM_TRAIT(at_least_item.type))
	//remove either one of the signals that could have called this proc
	UnregisterSignal(parent, list(COMSIG_ITEM_POST_UNEQUIP, COMSIG_ITEM_DROPPED))

	var/turf/vomit_turf = get_turf(at_least_item)
	playsound(vomit_turf, 'sound/effects/splat.ogg', 50, TRUE)
	new /obj/effect/decal/cleanable/vomit(vomit_turf)

	if(!add_dropdel) //gives a head start for the person to get away from the cursed item before it begins hunting again!
		addtimer(CALLBACK(src, .proc/seek_new_target), 10 SECONDS)

///proc called after a timer to awaken the AI in the cursed item if it doesn't have a target already.
/datum/component/curse_of_hunger/proc/seek_new_target()
	var/obj/item/cursed_item = parent
	if(iscarbon(cursed_item.loc))
		return
	else if(!isturf(cursed_item.loc))
		cursed_item.forceMove(get_turf(cursed_item))
	//only taking the most reasonable slot is fine since it unequips what is there to equip itself.
	cursed_item.AddElement(/datum/element/cursed, cursed_item.slot_equipment_priority[1])
	cursed_item.visible_message(span_warning("[cursed_item] begins to move on [cursed_item.p_their()] own..."))

/datum/component/curse_of_hunger/process(delta_time)
	var/obj/item/cursed_item = parent
	var/mob/living/carbon/cursed = cursed_item.loc
	///check hp
	if(!poison_food_tolerance)
		cursed.dropItemToGround(cursed_item, TRUE)
		return
	hunger += delta_time
	if((hunger <= HUNGER_THRESHOLD_TRY_EATING) || prob(80))
		return

	var/list/locations_to_check = (cursed.contents + cursed_item.contents)
	//check hungry enough to eat something!
	for(var/obj/item/food in locations_to_check)
		if(!IS_EDIBLE(food))
			continue
		food.forceMove(cursed.loc)
		playsound(cursed_item, 'sound/items/eatfood.ogg', 20, TRUE)
		///poisoned food damages it
		if(istype(food, /obj/item/food/badrecipe))
			to_chat(cursed, span_warning("[cursed_item] eats your [food] to sate [cursed_item.p_their()] hunger, and looks [pick("queasy", "sick", "iffy", "unwell")] afterwards!"))
			poison_food_tolerance--
		else
			to_chat(cursed, span_notice("[cursed_item] eats your [food] to sate [cursed_item.p_their()] hunger."))
		cursed.temporarilyRemoveItemFromInventory(food, force = TRUE)
		qdel(food)
		hunger = 0
		return
	///no food found: it bites you and regains some poison food tolerance
	playsound(cursed_item, 'sound/items/eatfood.ogg', 20, TRUE)
	to_chat(cursed, span_userdanger("[cursed_item] bites you to sate [cursed_item.p_their()] hunger!"))
	var/affecting = cursed.get_bodypart(BODY_ZONE_CHEST)
	cursed.apply_damage(60, BRUTE, affecting)
	hunger = 0
	poison_food_tolerance = min(poison_food_tolerance + 1, FULL_HEALTH)

/datum/component/curse_of_hunger/proc/test()
	var/obj/item/cursed_item = parent
	var/mob/living/carbon/cursed = cursed_item.loc
	cursed.dropItemToGround(cursed_item, TRUE)
