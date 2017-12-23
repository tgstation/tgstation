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
	else
		CRASH("[src] failed loading template with id `[shuttle_id]`")

/obj/configuration/shuttle_loader/arrival/box
	name = "Box arrival shuttle loader"
	shuttle_id = "arrival_box"

/obj/configuration/shuttle_loader/emergency/box
	name = "Box emergency shuttle loader"
	shuttle_id = "emergency_box"

/obj/configuration/shuttle_loader/cargo/box
	name = "Box cargo ferry loader"
	shuttle_id = "cargo_box"

/obj/configuration/shuttle_loader/mining/box
	name = "Box mining shuttle loader"
	shuttle_id = "mining_box"

/obj/configuration/shuttle_loader/labour/box
	name = "Box labour shuttle loader"
	shuttle_id = "labour_box"

/obj/configuration/shuttle_loader/ferry/fancy
	name = "fancy transport ferry loader"
	shuttle_id = "ferry_fancy"

/obj/configuration/shuttle_loader/whiteship/box
	name = "NT Medical Ship loader"
	shuttle_id = "whiteship_box"

/obj/configuration/shuttle_loader/whiteship/meta
	name = "NT Recovery Whiteship loader"
	shuttle_id = "whiteship_meta"
