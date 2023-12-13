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
	///The bag's max "health". IE, how many times you need to poison it.
	var/max_health = 2
	///The bag's current "health". IE, how many more times you need to poison it to stop it.
	var/current_health = 2

/datum/component/curse_of_hunger/Initialize(add_dropdel = FALSE, max_health = 2)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.add_dropdel = add_dropdel
	src.max_health = max_health
	src.current_health = max_health

/datum/component/curse_of_hunger/RegisterWithParent()
	. = ..()
	var/obj/item/cursed_item = parent
	RegisterSignal(cursed_item, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(cursed_item, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))

/datum/component/curse_of_hunger/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
	))

///signal called on parent being examined
/datum/component/curse_of_hunger/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!awakened)
		return //we should not reveal we are cursed until equipped
	if(current_health < max_health)
		examine_list += span_notice("[parent] looks sick from something it ate.")
	if(hunger > HUNGER_THRESHOLD_WARNING)
		examine_list += span_danger("[parent] hungers for something to eat...")

///signal called from equipping parent
/datum/component/curse_of_hunger/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	var/obj/item/at_least_item = parent
	// Items with no slot flags curse on pickup (because hand slot)
	if(at_least_item.slot_flags && !(at_least_item.slot_flags & slot))
		return
	the_curse_begins(equipper)

///signal called from dropping parent
/datum/component/curse_of_hunger/proc/on_drop(datum/source, mob/dropper)
	SIGNAL_HANDLER

	the_curse_ends(dropper)

/datum/component/curse_of_hunger/proc/the_curse_begins(mob/cursed)
	var/obj/item/cursed_item = parent
	awakened = TRUE
	START_PROCESSING(SSobj, src)
	ADD_TRAIT(cursed_item, TRAIT_NODROP, CURSED_ITEM_TRAIT(cursed_item.type))
	cursed.add_traits(list(TRAIT_CLUMSY, TRAIT_PACIFISM), CURSED_ITEM_TRAIT(cursed_item.type))
	if(add_dropdel)
		cursed_item.item_flags |= DROPDEL

	RegisterSignal(cursed_item, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))

/datum/component/curse_of_hunger/proc/the_curse_ends(mob/uncursed)
	var/obj/item/cursed_item = parent
	STOP_PROCESSING(SSobj, src)
	REMOVE_TRAIT(cursed_item, TRAIT_NODROP, CURSED_ITEM_TRAIT(cursed_item.type))
	uncursed.remove_traits(list(TRAIT_CLUMSY, TRAIT_PACIFISM), CURSED_ITEM_TRAIT(cursed_item.type))
	//remove either one of the signals that could have called this proc
	UnregisterSignal(cursed_item, COMSIG_ITEM_DROPPED)

	var/turf/vomit_turf = get_turf(cursed_item)
	playsound(vomit_turf, 'sound/effects/splat.ogg', 50, TRUE)
	new /obj/effect/decal/cleanable/vomit(vomit_turf)

	uncursed.dropItemToGround(cursed_item, force = TRUE)
	if(!QDELING(cursed_item)) //gives a head start for the person to get away from the cursed item before it begins hunting again!
		addtimer(CALLBACK(src, PROC_REF(seek_new_target)), 10 SECONDS)

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

/datum/component/curse_of_hunger/process(seconds_per_tick)
	var/obj/item/cursed_item = parent
	var/mob/living/carbon/cursed = cursed_item.loc
	///check hp
	if(current_health <= 0)
		the_curse_ends(cursed)
		return

	hunger += seconds_per_tick
	if((hunger <= HUNGER_THRESHOLD_TRY_EATING) || prob(80))
		return

	playsound(cursed_item, 'sound/items/eatfood.ogg', 20, TRUE)
	hunger = 0

	//check hungry enough to eat something!
	for(var/obj/item/food in cursed_item.contents + cursed.contents)
		if(!IS_EDIBLE(food))
			continue
		food.forceMove(cursed.loc)
		///poisoned food damages it
		if(locate(/datum/reagent/toxin) in food.reagents.reagent_list)
			var/sick_word = pick("queasy", "sick", "iffy", "unwell")
			cursed.visible_message(
				span_notice("[cursed_item] eats something from [cursed], and looks [sick_word] afterwards!"),
				span_notice("[cursed_item] eats your [food.name] to sate [cursed_item.p_their()] hunger, and looks [sick_word] afterwards!"),
			)
			current_health--
		else
			cursed.visible_message(
				span_warning("[cursed_item] eats something from [cursed] to sate [cursed_item.p_their()] hunger."),
				span_warning("[cursed_item] eats your [food.name] to sate [cursed_item.p_their()] hunger."),
			)
		cursed.temporarilyRemoveItemFromInventory(food, force = TRUE)
		qdel(food)
		return

	///no food found, but you're dead: it bites you slightly, and doesn't regain health.
	if(cursed.stat == DEAD)
		cursed.visible_message(span_danger("[cursed_item] nibbles on [cursed]."), span_userdanger("[cursed_item] nibbles on you!"))
		cursed.apply_damage(10, BRUTE, BODY_ZONE_CHEST)
		return

	///no food found: it bites you and regains some health.
	cursed.visible_message(span_danger("[cursed_item] bites [cursed]!"), span_userdanger("[cursed_item] bites you to sate [cursed_item.p_their()] hunger!"))
	cursed.apply_damage(60, BRUTE, BODY_ZONE_CHEST, wound_bonus = -20, bare_wound_bonus = 20)
	current_health = min(current_health + 1, max_health)

#undef HUNGER_THRESHOLD_WARNING
#undef HUNGER_THRESHOLD_TRY_EATING
