/obj/item/research_notes
	name = "research notes"
	desc = "Valuable scientific data. Use it in a research console to scan it."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	w_class = WEIGHT_CLASS_SMALL
	///research points it holds
	var/value = 100
	///origin of the research
	var/origin_type = "debug"

/obj/item/research_notes/Initialize(mapload, value, origin_type)
	. = ..()
	if(value)
		src.value = value
	if(origin_type)
		src.origin_type = origin_type
	change_vol()

/obj/item/research_notes/examine(mob/user)
	. = ..()
	. += span_notice("It is worth [value] research points.")

/obj/item/research_notes/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/research_notes))
		var/obj/item/research_notes/notes = attacking_item
		value = value + notes.value
		change_vol()
		qdel(notes)
		return
	return ..()

/// proc that changes name and icon depending on value
/obj/item/research_notes/proc/change_vol()
	if(value >= 10000)
		name = "revolutionary discovery in the field of [origin_type]"
		icon_state = "docs_verified"
	else if(value >= 2500)
		name = "essay about [origin_type]"
		icon_state = "paper_words"
	else if(value >= 100)
		name = "notes of [origin_type]"
		icon_state = "paperslip_words"
	else
		name = "fragmentary data of [origin_type]"
		icon_state = "scrap"

//research notes for ruins
/obj/item/research_notes/loot
	origin_type = "exotic particle physics"

/obj/item/research_notes/loot/tiny
	value = 250

/obj/item/research_notes/loot/small
	value = 1000

/obj/item/research_notes/loot/medium
	value = 2500

/obj/item/research_notes/loot/big
	value = 5000

/obj/item/research_notes/loot/genius//have a very good reason to give this one out
	value = 10000
