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
	icon_state = "docs_part"
	inhand_icon_state = "paper"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	layer = MOB_LAYER
	///The stamp overlay, used to show that the paperwork is complete without making a bunch of sprites
	var/mutable_appearance/stamp_overlay
	///The specific stamp icon to be overlaid on the paperwork
	var/stamp_icon = "paper_stamp-void"
	///The stamp needed to "complete" this form.
	var/stamp_requested = /obj/item/stamp/void
	///Has the paperwork been properly stamped
	var/stamped = FALSE
	///The job of the associated paperwork form
	var/stamp_job = /datum/job/assistant

/obj/item/paperwork/Initialize(mapload)
	. = ..()
	stamp_overlay = mutable_appearance('icons/obj/bureaucracy.dmi', stamp_icon)

/obj/item/paperwork/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(istype(attacking_item, /obj/item/stamp))
		if(istype(attacking_item, stamp_requested) || istype(attacking_item, stamp_requested))
			stamped = TRUE
			add_overlay(stamp_overlay)
			update_overlays()
			to_chat(user, span_warning("You skim through the papers until you find a field reading 'STAMP HERE', and complete the paperwork."))
		else
			to_chat(user, span_warning("You hunt through the papers for somewhere to use the [attacking_item], but can't find anything."))

/obj/item/paperwork/update_overlays()
	. = ..()

	if(stamped)
		. += stamp_overlay

/obj/item/paperwork/examine(mob/user)
	. = ..()

	if(stamped)
		. += "It looks like these documents have already been stamped. Now they can be returned to Central Command."
	else
		var/datum/job/stamp_title = stamp_job
		var/title = initial(stamp_title.title)
		. += "Trying to read through it makes your head spin. Judging by the few words you can make out, this looks like a job for a [title]." //fix grammar here

/obj/item/paperwork/examine_more(mob/user)
	. = ..()

	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/viewer = user
		if(istype(viewer?.mind.assigned_role, stamp_job)) //Examining the paperwork as the proper job gets you some bonus details
			return . + span_notice("<i>As you sift through the papers, you slowly start to piece together what you're reading.</i>")

//HEAD OF STAFF DOCUMENTS

/obj/item/paperwork/cargo
	stamp_requested = /obj/item/stamp/qm
	stamp_job = /datum/job/quartermaster
	stamp_icon = "paper_stamp-qm"

/obj/item/paperwork/cargo/examine_more()
	. = ..()

	. += "\t[span_info("The papers are a stack of mundane cargo shipping orders. Most of these papers are completely unecessary, with seemingly no rhyme or reason to their placement.")]"
	. += "\t[span_info("Whoever sent this probably just put extra papers in to make the stack of documents look bigger and more important. You should probably still stamp it anyways.")]"

/obj/item/paperwork/security
	stamp_requested = /obj/item/stamp/hos
	stamp_job = /datum/job/head_of_security
	stamp_icon = "paper_stamp-hos"

/obj/item/paperwork/security/examine_more()
	. = ..()

	. += "\t[span_info("The stack of documents are related to a criminal case being processed by a neighboring installation.")]"
	. += "\t[span_info("The document requests that you review a conduct report submitted by the lawyer of the station.")]"
	. += "\t[span_info("The case file detail accusations against the station's security department, including misconduct, harassment an-")]"
	. += "\t[span_info("What a bunch of crap, the security team were clearly just doing what they had to. You should probably stamp this.")]"

/obj/item/paperwork/hop
	stamp_requested = /obj/item/stamp/hop
	stamp_job = /datum/job/head_of_personnel
	stamp_icon = "paper_stamp-hop"

/obj/item/paperwork/hop/examine_more()
	. = ..()

	. += "\t[span_info("Your begin scanning over the document. This is a standard Nanotrasen NT-435Z3 form used for requests to Central Command.")]"
	. += "\t[span_info("Looks like a nearby station has sent in a MAXIMUM priority request for coal, in seemingly ridiculous quantities.")]"
	. += "\t[span_info("The reason listed for the request seems to be hastily filled in -- 'Engine exploded, need coal to power auxiliary generators.'")]"
	. += "\t[span_info("A MAXIMUM priority request like this is nothing to balk at. You should probably stamp this.")]"

/obj/item/paperwork/medical
	stamp_requested = /obj/item/stamp/cmo
	stamp_job = /datum/job/chief_medical_officer
	stamp_icon = "paper_stamp-cmo"

/obj/item/paperwork/medical/examine_more()
	. = ..()

	. += "\t[span_info("The stack of documents appear to be a medical report from a nearby station, detailing the vivisection of an unknown xenofauna.")]"
	. += "\t[span_info("In the report, the specimen was reportedly 'inarticulate and extremely hostile', requiring restraints during the surgical process.")]"
	. += "\t[span_info("Inspection of the attached photos reveal that the specimen was the station bartender's pet monkey, with parts of its uniform still visible.")]"
	. += "\t[span_info("Regardless, the vivisection results look like they could be useful. You should probably stamp this.")]"

/obj/item/paperwork/ce
	stamp_requested = /obj/item/stamp/ce
	stamp_job = /datum/job/chief_engineer
	stamp_icon = "paper_stamp-ce"

/obj/item/paperwork/ce/examine_more()
	. = ..()

	. += "\t[span_info("These papers are a power output report from a neighboring station. It details the power output and other engineering data regarding the station during a typical shift.")]"
	. += "\t[span_info("Checking the logs, you notice the energy output and engine temperature spike dramatically, and shortly after, the surrounding department appears to be depressurized by an unknown force.")]"
	. += "\t[span_info("Clearly the station's engineering department was testing an experimental engine setup, and had to use the air in the nearby rooms to help cool the engine. Totally.")]"
	. += "\t[span_info("Damn, that's impressive stuff. You should probably stamp this.")]"

/obj/item/paperwork/rd
	stamp_requested = /obj/item/stamp/rd
	stamp_job = /datum/job/research_director
	stamp_icon = "paper_stamp-rd"

/obj/item/paperwork/rd/examine_more()
	. = ..()

	. += "\t[span_info("The documents detail the results of a standard ordnance test that occured on a nearby station.")]"
	. += "\t[span_info("As you read further, you realize something strange with the results -- The epicenter doesn't seem to be correct.")]"
	. += "\t[span_info("If your math is correct, this explosion didn't happen at the station's ordnance site, it occured in the station's engine room.")]"
	. += "\t[span_info("Regardless, they're still perfectly usable test results. You should probably stamp this.")]"

/obj/item/paperwork/captain
	stamp_requested = /obj/item/stamp/captain
	stamp_job = /datum/job/captain
	stamp_icon = "paper_stamp-cap"

/obj/item/paperwork/captain/examine_more()
	. = ..()

	. += "\t[span_info("The documents are an unsigned correspondence from the captain's desk of a nearby station.")]"
	. += "\t[span_info("It seems to be a standard check-in message, reporting that the station is functioning at optimal efficiency.")]"
	. += "\t[span_info("The message repeatedly asserts that the engine is functioning 'perfectly fine' and is generating 'buttloads' of power.")]"
	. += "\t[span_info("Everything checks out. You should probably stamp this.")]"

//RANDOM PAPERWORK GROUPS
/obj/item/paperwork/random/Initialize(mapload)
	. = ..()

	var/paperwork_type = pick(subtypesof(/obj/item/paperwork))
	new paperwork_type(get_turf(src))

	return INITIALIZE_HINT_QDEL
