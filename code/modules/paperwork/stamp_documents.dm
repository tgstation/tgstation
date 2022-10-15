/**
 * # Paperwork
 *
 * Paperwork documents that can be stamped by their associated stamp to provide a bonus to cargo.
 *
 * Paperwork documents are a cargo item meant to provide the opportunity to make money.
 * Each piece of paperwork has its own associated stamp it needs to be stamped with. Selling a
 * properly stamped piece of paperwork will provide a cash bonus to the cargo budget. If a document is
 * not properly stamped it will instead drain a small stipend from the cargo budget.
 *
 */

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
	var/stamp_requested = /obj/item/stamp/void
	///Has the paperwork been properly stamped
	var/stamped = FALSE
	///The job of the associated paperwork form
	var/stamp_job = /datum/job/head_of_personnel

/obj/item/paperwork/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()

	if(istype(attacking_item, stamp_requested) || istype(attacking_item, stamp_requested))
		stamped = TRUE

/obj/item/paperwork/Initialize(mapload)
	. = ..()
	var/datum/job/stamp_title = stamp_job
	desc += "Trying to read through it makes your head spin. It looks like the [stamp_title.title] could make sense of this."

/obj/item/paperwork/cargo
	stamp_requested = /obj/item/stamp/qm
	stamp_job = /datum/job/quartermaster



