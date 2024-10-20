/// Attachable to items. Plays a bikehorn sound whenever attack_self is called (with a cooldown).
/datum/element/honkspam

/datum/element/honkspam/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ITEM_ATTACK_SELF, PROC_REF(interact))

/datum/element/honkspam/Detach(datum/source)
	UnregisterSignal(source, COMSIG_ITEM_ATTACK_SELF)
	return ..()

/datum/element/honkspam/proc/interact(obj/item/source, mob/user)
	SIGNAL_HANDLER
	if(HAS_TRAIT(source, TRAIT_HONKSPAMMING))
		return
	ADD_TRAIT(source, TRAIT_HONKSPAMMING, ELEMENT_TRAIT(type))
	create_sound(source.loc, 'sound/items/bikehorn.ogg').vary(TRUE).play()
	addtimer(TRAIT_CALLBACK_REMOVE(source, TRAIT_HONKSPAMMING, ELEMENT_TRAIT(type)), 2 SECONDS)
