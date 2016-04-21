
/client/proc/cmd_admin_destroy_shuttle()
	set category = "Admin"
	set name = "Shuttle Destroy"

	if (!holder)
		src << "Only administrators may use this command."
		return

	var/list/names = list()
	var/obj/docking_port/mobile/M
	for (var/atom/AM in SSshuttle.mobile)
		M = AM
		names += M.name

	var/selected = input("Select shuttle to DESTROY", "Shuttles") in names

	var/decide_against_msg = "You decide against destroying a shuttle."

	if(!selected)
		src << decide_against_msg
		return

	var/confirm = alert(src, "Are you sure you want to destroy [selected]?", "Confirm", "Yes", "No")

	if(confirm != "Yes")
		src << decide_against_msg
		return

	var/destroyed = FALSE
	for (var/atom/AM in SSshuttle.mobile)
		M = AM
		if(M.name == selected)
			M.jumpToNullSpace()
			destroyed = TRUE
			break

	if(!destroyed)
		src << "<span class='warning'>Something went wrong, the selected shuttle doesn't exist anymore."
		return

	log_admin("ShuttleDestroy: [M]")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has used <b>ShuttleDestroy on [M]</b><BR></span>")
	feedback_add_details("admin_verb","SHTDEL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_import_shuttle()
	set category = "Admin"
	set name = "Shuttle Import"

	if (!holder)
		src << "Only administrators may use this command."
		return

	var/datum/map_template/template
	// TODO would be helpful if it only highlighted actual shuttles rather
	// than ALL OF THEM
	var/map = input(usr, "Choose a Shuttle Template to import","Import Shuttle Template") as null|anything in map_templates
	if(!map)
		return
	template = map_templates[map]

	if(alert(usr,"Confirm importing of [map]","Shuttle Import Confirm","Yes","No") != "Yes")
		return

	var/turf/T = get_turf(locate("landmark*Shuttle Import"))
	template.load(T, centered = TRUE)

	var/obj/docking_port/mobile/M

	for(var/S in template.get_affected_turfs(T,centered = TRUE))
		for (var/AM in S)
			if(istype(AM, /obj/docking_port/mobile))
				M = AM
				break

	if(!M)
		usr << "<span class='warning'>The loaded template didn't have a mobile docking port!</span>"
		// TODO maybe unload the template? Pff, let the admins clean up

	M.dockRoundstart()

	log_admin("ShuttleImport: [map] - [M]")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has used <b>ShuttleImport: [map] - [M]</b><BR></span>")
	feedback_add_details("admin_verb","SHTIMP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
