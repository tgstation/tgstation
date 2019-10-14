
/obj/item/disk/tech_disk
	name = "technology disk"
	desc = "A disk for storing technology data for further research."
	icon_state = "datadisk0"
	custom_materials = list(/datum/material/iron=300, /datum/material/glass=100)
	var/datum/techweb/stored_research

/obj/item/disk/tech_disk/Initialize()
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)
	stored_research = new /datum/techweb

/obj/item/disk/tech_disk/debug
	name = "\improper CentCom technology disk"
	desc = "A debug item for research"
	custom_materials = null

/obj/item/disk/tech_disk/debug/Initialize()
	. = ..()
	stored_research = new /datum/techweb/admin

/obj/item/research_notes
	name = "research notes"
	desc = "Valuable scientific data. Use it in a research console to scan it."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	item_state = "paper"
	///research points it holds
	var/value = 69
	///origin of the research
	var/typee = "debug"
	///if it ws merged with different origins to apply a bonus
	var/mixed = FALSE

/obj/item/research_notes/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is worth [value] research points.</span>"

/// proc that changes name and icon depending on value
/obj/item/research_notes/proc/change_vol()
	if(value >= 10000)
		name = "revolutionary discovery in the field of [typee]"
		icon_state = "docs_verified"
		return
	else if(value >= 2500)
		name = "essay about [typee]"
		icon_state = "paper_words"
		return
	else if(value >= 100)
		name = "notes of [typee]"
		icon_state = "paperslip_words"
		return
	else
		name = "fragmentary data of [typee]"
		icon_state = "scrap"
		return

///proc when you slap research notes into another one, it applies a bonus if they are of different origin (only applied once)
/obj/item/research_notes/proc/merge(obj/item/research_notes/new_paper)
	value = value + new_paper.value
	if(typee != new_paper.typee && !mixed)
		value = value * 1.3
		typee = "[typee] and [new_paper.typee]"
		mixed = TRUE
	change_vol()
	qdel(new_paper)


/obj/item/research_notes/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/research_notes))
		var/obj/item/research_notes/R = I
		merge(R)
		return