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

/obj/configuration/shuttle_loader/infiltrator/basic
	name = "basic syndicate infiltrator loader"
	shuttle_id = "infiltrator_basic"

/obj/configuration/shuttle_loader/emergency/delta
	name = "Delta emergency shuttle loader"
	shuttle_id = "emergency_delta"

/obj/configuration/shuttle_loader/cargo/delta
	name = "Delta cargo ferry loader"
	shuttle_id = "cargo_delta"

/obj/configuration/shuttle_loader/mining/delta
	name = "Delta mining shuttle loader"
	shuttle_id = "mining_delta"

/obj/configuration/shuttle_loader/labour/delta
	name = "Delta labour shuttle loader"
	shuttle_id = "labour_delta"

/obj/configuration/shuttle_loader/arrival/delta
	name = "Delta arrival shuttle loader"
	shuttle_id = "arrival_delta"

/obj/configuration/shuttle_loader/whiteship/delta
	name = "Delta whiteship loader"
	shuttle_id = "whiteship_delta"

/obj/configuration/shuttle_loader/emergency/meta
	name = "Metastation emergency shuttle loader"
	shuttle_id = "emergency_meta"

/obj/configuration/shuttle_loader/emergency/omega
	name = "Omega emergency shuttle loader"
	shuttle_id = "emergency_omega"

/obj/configuration/shuttle_loader/whiteship/pubby
	name = "Pubby whiteship loader"
	shuttle_id = "whiteship_pubby"

/obj/configuration/shuttle_loader/emergency/pubby
	name = "Pubby emergency shuttle loader"
	shuttle_id = "emergency_pubby"