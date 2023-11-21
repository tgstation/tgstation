///List of all beacon implants currently in a mob.
GLOBAL_LIST_EMPTY(tracked_beacon_implants)

///Essentially, just turns the implantee into a teleport beacon.
/obj/item/implant/beacon
	name = "beacon implant"
	desc = "Teleports things."
	actions_types = null
	implant_flags = IMPLANT_TYPE_SECURITY
	hud_icon_state = "hud_imp_beacon"
	///How long will the implant be teleportable to after death?
	var/lifespan_postmortem = 10 MINUTES

/obj/item/implant/beacon/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Robust Corp JMP-21 Fugitive Retrieval Implant<BR>
				<b>Life:</b> Deactivates upon death after ten minutes, but remains within the body.<BR>
				<b>Important Notes: N/A</B><BR>
				<HR>
				<b>Implant Details: </b><BR>
				<b>Function:</b> Acts as a teleportation beacon that can be tracked by any standard bluespace transponder.
				Using this, you can teleport directly to whoever has this implant inside of them."}
	return dat

/obj/item/implant/beacon/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/tracked_implant, \
		global_list = GLOB.tracked_beacon_implants, \
	)

/obj/item/implanter/beacon
	imp_type = /obj/item/implant/beacon

/obj/item/implantcase/beacon
	name = "implant case - 'Beacon'"
	desc = "A glass case containing a beacon implant."
	imp_type = /obj/item/implant/beacon
