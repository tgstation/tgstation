/obj/item/supermatter_replacer
	name = "singlo loader"
	desc = "oh god oh fuck"
	icon = 'icons/obj/devices/remote.dmi'
	icon_state = "trapdoor_remote"
	var/singlo_map = "metastation.dmm"
	var/x_offset
	var/y_offset

/obj/item/supermatter_replacer/attack_self(mob/user, modifiers)
	var/area/supermatter = GLOB.areas_by_type[/area/station/engineering/supermatter/room]
	var/area/supermatter_engine = GLOB.areas_by_type[/area/station/engineering/supermatter]
	for(var/obj/obj in supermatter)
		qdel(obj) //Clear objects
	for(var/obj/obj in supermatter_engine)
		qdel(obj)
	var/datum/map_template/singlo_template = SSmapping.map_templates[singlo_map]
	singlo_template.should_place_on_top = FALSE
	var/turf/supermatter_corner = locate(supermatter.x+x_offset, supermatter.y+y_offset, supermatter.z) // have to do a little bit of coord manipulation to get it in the right spot
	singlo_template.load(supermatter_corner)

