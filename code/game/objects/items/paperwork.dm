/obj/item/paperwork
	name = "paperwork documents"
	desc = "A disorganized mess of documents, research results, and investigation findings."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "docs_generic"
	inhand_icon_state = "paper"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	layer = MOB_LAYER
	///The stamp needed to "complete" this form.
	var/stamp_requested = /obj/item/stamp
	///Has the paperwork been properly stamped
	var/stamped = FALSE

/obj/item/paperwork/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()

	if(istype(attacking_item, stamp_requested) || istype(attacking_item, stamp_requested))
		stamped = TRUE

/obj/item/paperwork/cargo
	stamp_requested = /obj/item/stamp/qm
