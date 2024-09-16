#define THUNDERDOME_TEMPLATE_FILE "metastation.dmm"

/obj/item/singlo_room
	name = "singlo loader"
	desc = "oh god oh fuck"
	icon = 'icons/obj/devices/remote.dmi'
	icon_state = "trapdoor_remote"

/obj/item/singlo_room/attack_self(mob/user, modifiers)
	var/area/thunderdome = GLOB.areas_by_type[/area/station/engineering/supermatter]
	for(var/obj/obj in thunderdome)
		if(!istype(obj, /obj/machinery/camera))
			qdel(obj) //Clear objects
	var/datum/map_template/thunderdome_template = SSmapping.map_templates[THUNDERDOME_TEMPLATE_FILE]
	thunderdome_template.should_place_on_top = FALSE
	var/turf/thunderdome_corner = locate(thunderdome.x, thunderdome.y, 1) // have to do a little bit of coord manipulation to get it in the right spot
	thunderdome_template.load(thunderdome_corner)


#undef THUNDERDOME_TEMPLATE_FILE
