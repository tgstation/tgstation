/**
 * This used to be in paper.dm, it was some snowflake code that was
 * used ONLY on april's fool. We moved it to an element so it could be used in other places.
 */
/datum/element/honkspam
	element_flags = ELEMENT_DETACH

/datum/element/honkspam/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ITEM_ATTACK_SELF, .proc/interact)

/datum/element/honkspam/Detach(datum/source)
	UnregisterSignal(source, COMSIG_ITEM_ATTACK_SELF)
	return ..()

/datum/element/honkspam/proc/interact(obj/item/source, mob/user)
	SIGNAL_HANDLER
	if(HAS_TRAIT(source, TRAIT_HONKSPAMMING))
		return
	ADD_TRAIT(source, TRAIT_HONKSPAMMING, ELEMENT_TRAIT)
	playsound(source.loc, 'sound/items/bikehorn.ogg', 50, TRUE)
	addtimer(TRAIT_CALLBACK_REMOVE(src, TRAIT_HONKSPAMMING, ELEMENT_TRAIT), 2 SECONDS)
