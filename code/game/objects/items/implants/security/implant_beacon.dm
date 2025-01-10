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
	return "<b>Implant Specifications:</b><BR> \
		<b>Name:</b> Robust Corp JMP-21 Fugitive Retrieval Implant<BR> \
		<b>Life:</b> Deactivates upon death after ten minutes, but remains within the body.<BR> \
		<b>Important Notes: N/A</B><BR> \
		<HR> \
		<b>Implant Details: </b><BR> \
		<b>Function:</b> Acts as a teleportation beacon that can be tracked by any standard bluespace transponder. \
		Using this, you can teleport directly to whoever has this implant inside of them."

/obj/item/implant/beacon/is_shown_on_console(obj/machinery/computer/prisoner/management/console)
	return TRUE

/obj/item/implant/beacon/get_management_console_data()
	var/list/info_shown = ..()

	var/area/destination_area = get_area(imp_in)
	if(isnull(destination_area) || !check_teleport_valid(imp_in, usr))
		info_shown["Status"] = "Implant carrier teleport signal cannot be reached!"
	else
		var/turf/turf_to_check = get_turf(imp_in)
		info_shown["Status"] = "Implant carrier is in [is_safe_turf(turf_to_check, dense_atoms = TRUE) ? "a safe environment." : "a hazardous environment!"]"

	return info_shown

/obj/item/implanter/beacon
	imp_type = /obj/item/implant/beacon

/obj/item/implantcase/beacon
	name = "implant case - 'Beacon'"
	desc = "A glass case containing a beacon implant."
	imp_type = /obj/item/implant/beacon
