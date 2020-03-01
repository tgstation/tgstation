/**
  * fate.dm
  *
  *	This is where you can store special one-time modifiers for rolls
  * *
  */

/datum/modifier
  var/mob/caster
  var/amount

/datum/modifier/New(mob/caster, amount)
  src.caster = caster
  src.amount = amount

/datum/modifier/proc/getValue()
  return amount

/datum/modifier/proc/getCaster()
  return caster


/datum/fate
	var/list/queue = list()
	var/datum/mind/owner

/**
  * Here you can add a blessing to someone's fate queue, which will give them a plus modifier to whatever roll this ends up being called for
  *
  * Arguments:
  * * mob/caster: Who blessed us?
  * * amount: How much will we add to the roll this is called for?
  */
/datum/fate/proc/bless(mob/caster, amount)
	var/datum/modifier/M = new (caster, amount)
	queue += M

/**
  * Here you can add a blessing to someone's fate queue, which will give them a plus modifier to whatever roll this ends up being called for
  *
  * Arguments:
  * * mob/caster: Who cursed us?
  * * amount: How much will we subtract from the roll this is called for?
  */
/datum/fate/proc/curse(mob/caster, amount)
	var/datum/modifier/M = new (caster, -amount)
	queue += M

/**
  * Here you can add a blessing to someone's fate queue, which will give them a plus modifier to whatever roll this ends up being called for
  *
  * Arguments:
  * * mob/caster: Who blessed us?
  * * amount: How much will we add to the roll this is called for?
  * *
  * Returns:
  * * Either the /datum/modifier that's up next in the queue, or nothing
  */
/datum/fate/proc/getModifier()
	var/datum/modifier/M = queue[1]
	if(M)
		queue.Remove(M)
		return M

/**
  * Call this to clear this fate's queue
  */
/datum/fate/proc/clearQueue()
	queue = list()

