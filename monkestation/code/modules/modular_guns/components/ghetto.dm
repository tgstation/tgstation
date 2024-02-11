/* This component is added to guns when they are made using rubber bands and cardboard
it will cause bad shit to happen sometimes on fire modified by attachments used
*/

/datum/component/makeshift_guns
	///our misfire chance
	var/misfire_chance
	///our explosion chance
	var/explosion_chance
	///our disassemble chance
	var/disassemble_chance
	/// a datum for unique effects
	var/datum/makeshift_effect/linked_effect

/datum/component/makeshift_guns/RegisterWithParent()
	RegisterSignal(parent, COMSIG_GUN_TRY_FIRE, PROC_REF(attempt_makeshift))


/datum/component/makeshift_guns/proc/attempt_makeshift(obj/item/gun/source, mob/living/user, atom/target, flag, params)
	SIGNAL_HANDLER
	return NONE
