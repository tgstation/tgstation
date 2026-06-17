/client/proc/tag_datum(datum/target_datum)
	if(!holder || QDELETED(target_datum))
		return
	holder.add_tagged_datum(target_datum)

/client/proc/toggle_tag_datum(datum/target_datum)
	if(!holder || !target_datum)
		return

	if(LAZYFIND(holder.tagged_datums, target_datum))
		holder.remove_tagged_datum(target_datum)
	else
		holder.add_tagged_datum(target_datum)

ADMIN_VERB_ONLY_CONTEXT_MENU(tag_datum, R_NONE, "Tag Datum", /datum)
	VERB_ARG(target_datum, ADMIN_VERB_ARG_TYPE_MOB | ADMIN_VERB_ARG_TYPE_OBJ | ADMIN_VERB_ARG_TYPE_TURF | ADMIN_VERB_ARG_TYPE_AREA, ADMIN_VERB_ARG_SOURCE_VIEW, /datum)
	user.tag_datum(target_datum)
