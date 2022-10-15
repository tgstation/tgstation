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
	///The stamp overlay, used to show that the paperwork is complete without making a bunch of sprites
	var/image/stamp_overlay
	///The specific stamp icon to be overlaid on the paperwork
	var/stamp_icon = "paper_stamp-void"
	///The stamp needed to "complete" this form.
	var/stamp_requested = /obj/item/stamp/void
	///Has the paperwork been properly stamped
	var/stamped = FALSE
	///The job of the associated paperwork form
	var/stamp_job = /datum/job/assistant

/obj/item/paperwork/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()

	if(istype(attacking_item, stamp_requested) || istype(attacking_item, stamp_requested))
		stamped = TRUE
		update_overlays()
		desc = "A slightly more organized mess of documents. "

/obj/item/paperwork/Initialize(mapload)
	. = ..()
	stamp_overlay = mutable_appearance('icons/obj/bureaucracy.dmi', stamp_icon)
	var/datum/job/stamp_title = stamp_job
	var/title = initial(stamp_title.title)
	desc += " Trying to read through it makes your head spin. Judging by the few words you can make out, this looks like a job for a [title]." //fix grammar here

/obj/item/paperwork/update_overlays()
	. = ..()

	if(stamped)
		. += stamp_overlay

/obj/item/paperwork/cargo
	stamp_requested = /obj/item/stamp/qm
	stamp_job = /datum/job/quartermaster
	stamp_icon = "paper_stamp-qm"

/obj/item/paperwork/security
	stamp_requested = /obj/item/stamp/hos
	stamp_job = /datum/job/head_of_security
	stamp_icon = "paper_stamp-hos"

/obj/item/paperwork/rd
	stamp_requested = /obj/item/stamp/hop
	stamp_job = /datum/job/head_of_personnel
	stamp_icon = "paper_stamp-hop"

/obj/item/paperwork/medical
	stamp_requested = /obj/item/stamp/cmo
	stamp_job = /datum/job/chief_medical_officer
	stamp_icon = "paper_stamp-cmo"

/obj/item/paperwork/ce
	stamp_requested = /obj/item/stamp/ce
	stamp_job = /datum/job/chief_engineer
	stamp_icon = "paper_stamp-ce"

/obj/item/paperwork/rd
	stamp_requested = /obj/item/stamp/rd
	stamp_job = /datum/job/research_director
	stamp_icon = "paper_stamp-rd"


