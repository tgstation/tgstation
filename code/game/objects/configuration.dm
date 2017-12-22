/obj/configuration
	name = "map configuration"
	desc = "This is a pseudo-object used for configuring various subsystems for specific maps."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "blueprints"
	anchored = TRUE
	density = TRUE

/obj/configuration/Initialize(mapload)
	. = INITIALIZE_HINT_QDEL

/obj/configuration/shuttle_loader
	name = "shuttle loader configuration"
	desc = "Change `shuttle_id` var to selected shuttle to load it for this map."
	var/shuttle_id

/obj/configuration/shuttle_loader/Initialize(mapload)
	. = ..()
	var/datum/map_template/shuttle/D = SSmapping.shuttle_templates[shuttle_id]
	if(istype(D))
		SSshuttle.shuttle_templates_to_load += D

/obj/configuration/shuttle_loader/arrival_box
	name = "arrival shuttle (Box) loader"
	shuttle_id = "arrival_box"

/obj/configuration/shuttle_loader/emergency_box
	name = "emergency shuttle (Box) loader"
	shuttle_id = "emergency_box"