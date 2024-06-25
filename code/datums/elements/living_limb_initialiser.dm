/// Spawns a living limb mob inside a limb upon attachment if it doesn't have one
/datum/element/living_limb_initialiser

/datum/element/living_limb_initialiser/Attach(atom/target)
	. = ..()
	if(!isbodypart(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_BODYPART_CHANGED_OWNER, PROC_REF(try_animate_limb))

/datum/element/living_limb_initialiser/Detach(atom/target)
	UnregisterSignal(target, COMSIG_BODYPART_CHANGED_OWNER)
	return ..()

/// Create a living limb mob inside the limb if it doesn't already have one
/datum/element/living_limb_initialiser/proc/try_animate_limb(obj/item/bodypart/part)
	SIGNAL_HANDLER
	if (locate(/mob/living/basic/living_limb_flesh) in part)
		return
	new /mob/living/basic/living_limb_flesh(part, part)
