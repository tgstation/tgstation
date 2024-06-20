///Amount of time each timer has, used to reset the jousting back, indicating that the person has stopped moving.
#define MOVEMENT_RESET_COOLDOWN_TIME (0.3 SECONDS)

/**
 * ##jousting
 *
 * Given to items, it allows you to charge into people with additional damage and potential knockdown
 * by being buckled onto something. If the other person is also jousting, can knock eachother down.
 */
/datum/component/jousting
	///The current person holding parent.
	var/mob/living/current_holder
	///The current direction of the jousting.
	var/current_direction = NONE
	///How many tiles we've charged up thus far
	var/current_tile_charge = 0

	///How much of an increase in damage is achieved every tile moved during jousting.
	var/damage_boost_per_tile
	///The boosted chances of a knockdown occuring while jousting.
	var/knockdown_chance_per_tile
	///How much of an increase in knockdown is achieved every tile moved during jousting, if it knocks down.
	var/knockdown_time
	///The max amount of tiles before you can joust someone.
	var/max_tile_charge
	///The min amount of tiles before you can joust someone.
	var/min_tile_charge

/datum/component/jousting/Initialize(
	damage_boost_per_tile = 2,
	knockdown_chance_per_tile = 20,
	knockdown_time = 2 SECONDS,
	max_tile_charge = 5,
	min_tile_charge = 2,
)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.damage_boost_per_tile = damage_boost_per_tile
	src.knockdown_chance_per_tile = knockdown_chance_per_tile
	src.knockdown_time = knockdown_time
	src.max_tile_charge = max_tile_charge
	src.min_tile_charge = min_tile_charge

	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_successful_attack))
	RegisterSignal(parent, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/datum/component/jousting/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_AFTERATTACK,
		COMSIG_TRANSFORMING_ON_TRANSFORM,
	))

/datum/component/jousting/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("It can be used on a vehicle for jousting, dealing potential knockdowns and additional damage.")

/datum/component/jousting/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER
	if(!user)
		return

	if(active)
		INVOKE_ASYNC(src, PROC_REF(on_equip), source, user)
	else
		INVOKE_ASYNC(src, PROC_REF(on_drop), source, user)

///Called when a mob equips the spear, registers them as the holder and checks their signals for moving.
/datum/component/jousting/proc/on_equip(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	if(current_holder)
		INVOKE_ASYNC(src, PROC_REF(on_drop), source, user)

	current_holder = user
	RegisterSignal(current_holder, COMSIG_MOVABLE_MOVED, PROC_REF(mob_move), TRUE)

/datum/component/jousting/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!current_holder)
		return

	reset_charge()
	UnregisterSignal(current_holder, COMSIG_MOVABLE_MOVED)
	current_holder = null

/**
 * Performs the actual attack, handling damage/knockdown depending on how far you've jousted.
 * We deduct the minimum tile charge from the current tile charge to get what will actually be buffed
 * So your charge will only get benefits from each extra tile after the minimum (and before the maximum).
 */
/datum/component/jousting/proc/on_successful_attack(datum/source, mob/living/target, mob/user)
	SIGNAL_HANDLER
	if(user != current_holder || !user.buckled)
		return
	var/usable_charge = (current_tile_charge - min_tile_charge)
	if(!current_direction || (usable_charge <= 0))
		return

	var/turf/target_turf = get_step(user, current_direction)
	if(target in range(1, target_turf))
		var/obj/item/parent_item = parent
		var/sharp = parent_item.get_sharpness()
		var/msg = "[user] [sharp ? "impales" : "slams into"] [target] [sharp ? "on" : "with"] their [parent]"
		target.apply_damage((damage_boost_per_tile * usable_charge), BRUTE, user.zone_selected, 0)
		if(prob(knockdown_chance_per_tile * usable_charge))
			msg += " and knocks [target] [target.buckled ? "off of [target.buckled]" : "down"]"
			if(target.buckled)
				target.buckled.unbuckle_mob(target)
			target.Paralyze(knockdown_time)
		user.visible_message(span_danger("[msg]!"))

/**
 * Called when a mob moves.
 * Handles checking their direction, changing it if they turned,
 * and increments how many tiles they've been charging for.
 * Lastly, refreshes their charge reset timer, giving them a new one instead.
 */
/datum/component/jousting/proc/mob_move(datum/source, newloc, dir)
	SIGNAL_HANDLER

	if(!current_holder)
		CRASH("[src] called mob_move despite supposedly not having a mob registed to joust as.")
	if(!current_holder.buckled)
		return

	if(dir != current_direction)
		current_tile_charge = initial(current_tile_charge)
		current_direction = dir
	if(current_tile_charge < max_tile_charge)
		current_tile_charge++
	addtimer(CALLBACK(src, PROC_REF(reset_charge)), MOVEMENT_RESET_COOLDOWN_TIME, TIMER_UNIQUE | TIMER_OVERRIDE)

/**
 * reset charge
 *
 * Resets their direction and tile charge back to their initial values.
 * This is used when someone is no longer jousting and it should cleanup.
 */
/datum/component/jousting/proc/reset_charge()
	current_direction = initial(current_direction)
	current_tile_charge = initial(current_tile_charge)

#undef MOVEMENT_RESET_COOLDOWN_TIME
