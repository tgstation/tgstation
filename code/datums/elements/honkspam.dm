/// Attachable to items. Plays a bikehorn sound whenever attack_self is called (with a cooldown).
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
	ADD_TRAIT(source, TRAIT_HONKSPAMMING, ELEMENT_TRAIT(type))
	playsound(source.loc, 'sound/items/bikehorn.ogg', 50, TRUE)
	addtimer(TRAIT_CALLBACK_REMOVE(source, TRAIT_HONKSPAMMING, ELEMENT_TRAIT(type)), 2 SECONDS)
