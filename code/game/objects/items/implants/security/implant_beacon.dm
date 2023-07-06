/obj/item/implant/beacon
	name = "beacon implant"
	desc = "Teleports things."
	icon_state = "reagents" //change
	actions_types = null
	implant_flags = IMPLANT_TYPE_SECURITY

	///How long will the implant continue to function after death?
	var/lifespan_postmortem = 10 MINUTES

/obj/item/implant/beacon/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Robust Corp JMP-21 Fugitive Retrieval Implant<BR>
				<b>Life:</b> Deactivates upon death after ten minutes, but remains within the body.<BR>
				<b>Important Notes: N/A</B><BR>
				<HR>
				<b>Implant Details: </b><BR>
				<b>Function:</b> Acts as a teleportation beacon that can be tracked by any standard bluespace transponder.
				Using this, you can teleport to whoever has this implant inside of them."}
	return dat

/obj/item/implant/beacon/Initialize(mapload)
	. = ..()
	GLOB.tracked_beacon_implants += src

/obj/item/implant/beacon/Destroy()
	GLOB.tracked_beacon_implants -= src
	return ..()

/obj/item/implanter/beacon
	imp_type = /obj/item/implant/beacon

/obj/item/implantcase/beacon
	name = "implant case - 'Beacon'"
	desc = "A glass case containing a beacon implant."
	imp_type = /obj/item/implant/beacon
