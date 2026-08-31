/obj/item/disk/tech_disk
	name = "technology disk"
	desc = "A disk for storing technology data for further research."
	icon_state = "datadisk0"
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT * 3, /datum/material/glass=SMALL_MATERIAL_AMOUNT)
	var/list/stored_nodes

/obj/item/disk/tech_disk/Initialize(mapload)
	. = ..()
	if(!islist(stored_nodes))
		// gotta make it assoc or else it breaks
		stored_nodes = list()
		for(var/node_path in SSresearch.techweb_nodes_starting)
			stored_nodes[node_path] = TRUE
	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)

/obj/item/disk/tech_disk/debug
	name = "\improper CentCom technology disk"
	desc = "A debug item for research"
	custom_materials = null

/obj/item/disk/tech_disk/debug/Initialize(mapload)
	var/datum/techweb/admin/admin_techweb = locate() in SSresearch.techwebs
	admin_techweb ||= new()
	stored_nodes = admin_techweb.researched_nodes.Copy()
	return ..()
