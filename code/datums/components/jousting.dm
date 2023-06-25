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

	///How much time we have to move before the timer resets.
	var/movement_reset_tolerance
	///How much of an increase in damage is achieved every tile moved during jousting.
	var/mounted_damage_boost_per_tile
	///The boosted chances of a knockdown occuring while jousting.
	var/mounted_knockdown_chance_per_tile
	///How much of an increase in knockdown is achieved every tile moved during jousting, if it knocks down.
	var/mounted_knockdown_time
	///The max amount of tiles before you can joust someone.
	var/max_tile_charge
	///The min amount of tiles before you can joust someone.
	var/min_tile_charge

/datum/component/jousting/Initialize(
	movement_reset_tolerance = 0.3 SECONDS,
	mounted_damage_boost_per_tile = 2,
	mounted_knockdown_chance_per_tile = 20,
	mounted_knockdown_time = 20,
	max_tile_charge = 5,
	min_tile_charge = 2,
)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.movement_reset_tolerance = movement_reset_tolerance
	src.mounted_damage_boost_per_tile = mounted_damage_boost_per_tile
	src.mounted_knockdown_chance_per_tile = mounted_knockdown_chance_per_tile
	src.mounted_knockdown_time = mounted_knockdown_time
	src.max_tile_charge = max_tile_charge
	src.min_tile_charge = min_tile_charge

	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(on_attack))

/datum/component/jousting/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_ATTACK,
	))

/datum/component/jousting/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("[parent] can be used to joust while buckled to a vehicle, to deal knockdown and additional damage.")

///Called when a mob equips the spear, registers them as the holder and checks their signals for moving.
/datum/component/jousting/proc/on_equip(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(mob_move))
	current_holder = user

/datum/component/jousting/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	reset_charge()
	UnregisterSignal(current_holder, COMSIG_MOVABLE_MOVED)
	current_holder = null

///Performs the actual attack, handling damage/knockdown depending on how far you've jousted.
/datum/component/jousting/proc/on_attack(datum/source, mob/living/target, mob/user)
	SIGNAL_HANDLER
	if(user != current_holder || !user.buckled)
		return
	if(!current_direction || (current_tile_charge < min_tile_charge))
		return

	var/turf/target_turf = get_step(user, current_direction)
	if(target in range(1, target_turf))
		var/obj/item/parent_item = parent
		var/sharp = parent_item.get_sharpness()
		var/msg = "[user] [sharp ? "impales" : "slams into"] [target] [sharp ? "on" : "with"] their [parent]"
		target.apply_damage((mounted_damage_boost_per_tile * current_tile_charge), BRUTE, user.zone_selected, 0)
		if(prob(mounted_knockdown_chance_per_tile * current_tile_charge))
			msg += " and knocks [target] [target.buckled ? "off of [target.buckled]" : "down"]"
			if(target.buckled)
				target.buckled.unbuckle_mob(target)
			target.Paralyze(mounted_knockdown_time)
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
		current_tile_charge = 0
		current_direction = dir
	if(current_tile_charge < max_tile_charge)
		current_tile_charge++
	addtimer(CALLBACK(src, PROC_REF(reset_charge)), movement_reset_tolerance, TIMER_UNIQUE | TIMER_OVERRIDE)

/**
 * reset charge
 *
 * Resets their direction and tile charge back to their initial values.
 * This is used when someone is no longer jousting and it should cleanup.
 */
/datum/component/jousting/proc/reset_charge()
	current_direction = initial(current_direction)
	current_tile_charge = initial(current_tile_charge)
