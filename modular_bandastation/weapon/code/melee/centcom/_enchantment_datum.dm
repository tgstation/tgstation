/datum/enchantment
	/// Used for blackbox logging
	var/name = "You shouldn't be seeing this, file an issue report."
	/// Used for wizards/cultists examining the runes on the blade
	var/desc = "Someone messed up, file an issue report."
	/// Used for damage values
	var/power = 1
	/// Whether the enchant procs despite not being in proximity
	var/ranged = FALSE
	/// Distance in tiles
	var/range = 1
	/// Stores the world.time after which it can be used again, the `initial(cooldown)` is the cooldown between activations.
	var/cooldown = -1
	/// If has traits, has it applied them?
	var/applied_traits = FALSE
	/// A modifier that can be appled to the cooldown after the enchantment has been initialized. Used by the forcewall spellblade
	var/cooldown_multiplier = 1
	/// Used for saveng target info
	var/target
	/// List of actions added by enchantment
	var/list/actions_types = list()

/datum/enchantment/proc/on_hit(mob/living/target, mob/living/user, proximity, obj/item/melee/S)
	if(world.time < cooldown)
		return FALSE
	if(!istype(target))
		return FALSE
	if(target.stat == DEAD)
		return FALSE
	if(!ranged && !proximity)
		return FALSE
	cooldown = world.time + (initial(cooldown) * cooldown_multiplier)
	return TRUE

/datum/enchantment/proc/on_gain(obj/item/I)
	I.reach = range
	return

/datum/enchantment/proc/toggle_traits(obj/item/I, mob/living/user)
	return

/datum/enchantment/proc/on_apply(obj/item/I)
	return
