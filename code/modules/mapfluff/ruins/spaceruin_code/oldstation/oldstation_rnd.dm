/obj/machinery/rnd/server/oldstation
	name = "\improper Ancient R&D Server"
	circuit = /obj/item/circuitboard/machine/rdserver/oldstation
	req_access = list(ACCESS_AWAY_SCIENCE)

/obj/machinery/rnd/server/oldstation/Initialize(mapload)
	var/datum/techweb/oldstation_web = locate(/datum/techweb/oldstation) in SSresearch.techwebs
	stored_research = oldstation_web
	return ..()

/obj/machinery/rnd/server/oldstation/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(istype(held_item, /obj/item/research_notes))
		context[SCREENTIP_CONTEXT_LMB] = "Generate research points"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/rnd/server/oldstation/examine(mob/user)
	. = ..()

	if(!in_range(user, src) && !isobserver(user))
		return

	. += span_notice("Insert [EXAMINE_HINT("Research Notes")] to generate points.")

/obj/machinery/rnd/server/oldstation/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/research_notes) && stored_research)
		var/obj/item/research_notes/research_notes = tool
		stored_research.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = research_notes.value))
		playsound(src, 'sound/machines/copier.ogg', 50, TRUE)
		qdel(research_notes)
		return ITEM_INTERACT_SUCCESS

	return ..()

///Ancient computer that starts with dissection to tell players they have it.
/obj/machinery/computer/operating/oldstation
	name = "ancient operating computer"
	advanced_surgeries = list(/datum/surgery_operation/basic/dissection)
