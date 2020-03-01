
/**
  * fate.dm
  *
  * This is a component that gives you some control over fate itself! The idea is that Chaplains and possibly other supernatural roles have this ability by default as they can petition the fates
  *		to favor or screw someone over, but it may be expanded from there with different strengths and weaknesses.
  *
  *	This component allows the mob holder to bless and curse other mobs around them. This works by saying (or muttering under your breath) blessings and jinxes along with your target's name,
  *		or just freestyling and saying either "bless" or "damn" without any target, which will pick a random person around you to target! Note that while you can't bless yourself, you
  * 	CAN curse yourself, so be careful with your tongue when you have the ears of the fates!
  *
  *	Currently blessing and jinxing only affects your rolls for hitting a vending machine and getting loot/killed, but if there's interest, rolls with degrees of success can be added
  *		in other places as well. It's something I'd like to do!
  *
  * Arguments: none. why, are we really gonna fight over this right now in front of our guests?
  * *
  */
/datum/component/fate
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// when did we last bless someone?
	var/list/queue = list()


/datum/component/fate/Initialize()

/datum/component/fate/Destroy(force, silent)
	return ..()

/datum/component/fate/RegisterWithParent()
	RegisterSignal(parent, COMSIG_FATE_CHECK, .proc/applyModifier)
	RegisterSignal(parent, COMSIG_FATE_ADD, .proc/addModifier)
	RegisterSignal(parent, COMSIG_FATE_RESET, .proc/resetQueue)

/datum/component/fate/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_FATE_CHECK, COMSIG_FATE_ADD, COMSIG_FATE_RESET))

/**
  * Check if there's any modifiers in the queue, and if so, remove it from the queue and apply it to the roll we're given
  *
  * Arguments:
  * * roll: The roll we're modifying
  *
  * Returns:
  *	* Our adjusted roll
  */
/datum/component/fate/proc/applyModifier(datum/us, roll)
	if(length(queue))
		var/Q = queue[1]
		roll += Q
		queue.Remove(Q)

	return roll

/**
  * Here you can add a modifier to someone's fate queue, which will give them a modifier to whatever roll this ends up being called for
  *
  * Arguments:
  * * datum/source: What was the source?
  * * amount: How much will we add to the roll this is called for?
  */
/datum/component/fate/proc/addModifier(datum/us, amount)
	queue += amount

/**
  * Call this to clear this fate's queue
  */
/datum/component/fate/proc/resetQueue()
	queue = list()

