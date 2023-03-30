/datum/component/mclinker
	var/obj/item/mcobject/target = null

/datum/component/mclinker/Initialize(obj/item/mcobject/_target)
	target = _target
	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(target_del))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(unlink))

/datum/component/mclinker/Destroy(force, silent)
	target = null
	return ..()

/datum/component/mclinker/proc/target_del()
	SIGNAL_HANDLER
	qdel(src)

/datum/component/mclinker/proc/unlink(mob/source)
	SIGNAL_HANDLER
	to_chat(source, span_notice("You remove the saved component from [parent]."))
	qdel(src)
