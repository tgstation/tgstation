/obj/item/mcobject/messaging/paper_scanner
	name = "paper sensor"
	base_icon_state = "comp_pscan"
	icon_state = "comp_pscan"
	///does this consume paper?
	var/deletes_paper = TRUE
	///does this only use thermal paper?
	var/uses_thermal_only = FALSE


/obj/item/mcobject/messaging/paper_scanner/Initialize(mapload)
	. = ..()
	MC_ADD_CONFIG("Toggle Paper Consumption", toggle_consume)
	MC_ADD_CONFIG("Toggle Thermal Paper Usage", toggle_thermal)

/obj/item/mcobject/messaging/paper_scanner/attacked_by(obj/item/attacking_item, mob/living/user)
	. = ..()
	if(!istype(attacking_item, /obj/item/paper))
		return

	var/obj/item/paper/attacked_paper = attacking_item
	if(uses_thermal_only && !attacked_paper.thermal_paper)
		return

	flick("comp_pscan1", src)
	var/sanitized_string = strip_html(html_encode(attacked_paper.raw_text_inputs))
	if(!sanitized_string)
		return
	fire(sanitized_string)
	if(deletes_paper)
		qdel(attacking_item)
	return TRUE


/obj/item/mcobject/messaging/paper_scanner/proc/toggle_consume(mob/user, obj/item/tool)
	deletes_paper = !deletes_paper
	say("[deletes_paper ? "Now consuming paper" : "Now saving paper"]")
	return TRUE

/obj/item/mcobject/messaging/paper_scanner/proc/toggle_thermal(mob/user, obj/item/tool)
	uses_thermal_only = !uses_thermal_only
	say("[uses_thermal_only ? "Now only accepts thermal paper" : "Now accepts all paper types"]")
	return TRUE
