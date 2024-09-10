//TRANSLATOR NECKLACE//
#define LANGUAGE_TRANSLATOR "translator"

/obj/item/clothing/neck/necklace/translator/
	name = "antique necklace"
	desc = "A necklace with a old, strange device as its pendant. Symbols \
		constantly seem to appear on its screen, as noises happen around it, \
		but its purpose is not immediately apparent."
	icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/translator.dmi'
	worn_icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/translator_worn.dmi'
	icon_state = "translator"
	slot_flags = ITEM_SLOT_NECK | ITEM_SLOT_OCLOTHING
	w_class = WEIGHT_CLASS_SMALL //allows this to fit inside of pockets.
	/// The language granted by this necklace
	var/datum/language/language_granted = /datum/language/uncommon


/obj/item/clothing/neck/necklace/translator/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, PROC_REF(on_necklace_equip))


/// Handles giving the language to the equipper when equipped.
/obj/item/clothing/neck/necklace/translator/proc/on_necklace_equip(datum/source, mob/living/carbon/human/equipper, slot)
	SIGNAL_HANDLER

	if(!(slot_flags & slot))
		return

	if(!istype(equipper))
		return

	equipper.grant_language(language_granted, source = LANGUAGE_TRANSLATOR)
	RegisterSignal(src, COMSIG_ITEM_DROPPED, PROC_REF(on_necklace_unequip))

	equip_feedback(equipper)


/// Handles sending text feedback to the equipper. Override to change the text.
/obj/item/clothing/neck/necklace/translator/proc/equip_feedback(mob/living/carbon/human/equipper)
	to_chat(equipper, span_notice( \
		"<i>Slipping the necklace on, you notice a slight buzzing in your ears, \
		and that any word in [initial(language_granted.name)] said in your \
		general vicinity is immediately translated to your native language, \
		directly in your ears. Not only that, but you find yourself able to \
		speak your mind in such a way that the pendant translates your words \
		back in [initial(language_granted.name)].</i>" \
	))


/// Handles removing the language from the unequipper when unequipped.
/obj/item/clothing/neck/necklace/translator/proc/on_necklace_unequip(obj/item/source, mob/living/carbon/human/unequipper)
	SIGNAL_HANDLER

	if(!istype(unequipper))
		return

	unequipper.remove_language(language_granted, source = LANGUAGE_TRANSLATOR)
	UnregisterSignal(source, COMSIG_ITEM_DROPPED)

	unequip_feedback(unequipper)


/// Handles sending text feedback to the unequipper. Override to change the text.
/obj/item/clothing/neck/necklace/translator/proc/unequip_feedback(mob/living/carbon/human/unequipper)
	to_chat(unequipper, span_boldnotice( \
		"<i>\The [src]'s constant buzzing suddenly stops. Peace, at last. \
		You also lose your artificial grasp on [initial(language_granted.name)], \
		unfortunately. Such is the price for peace and quiet.</i>" \
	))


#undef LANGUAGE_TRANSLATOR
