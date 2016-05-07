/proc/emergency_sanity_check()
	if(SSshuttle.emergency.mode != SHUTTLE_IDLE)
		var/confirm = alert(src, "Modification of the emergency shuttle while it is not idle can be highly dangerous, and may result in WEIRD UNPREDICTABLE SHIT. Are you SURE you want to continue? Obviously if you're not touching the emergency shuttle, then you're probably fine.", "Confirm", "Yes", "No")
		if(confirm == "Yes")
			return TRUE
		else
			return FALSE
	else
		return TRUE

/client/proc/cmd_admin_destroy_shuttle()
	set category = "Admin"
	set name = "Shuttle Destroy"

	if (!holder)
		src << "Only administrators may use this command."
		return

	if(!emergency_sanity_check())
		return

	var/list/names = list()
	var/obj/docking_port/mobile/M
	for (var/atom/AM in SSshuttle.mobile)
		M = AM
		names += M.name

	var/selected = input("Select shuttle to DESTROY", "Shuttles") as null|anything in names

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

	log_admin("[key_name_admin(usr)] - ShuttleDestroy: [M]")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has used <b>ShuttleDestroy on [selected]</b><BR></span>")
	feedback_add_details("admin_verb","SHTDEL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_import_shuttle()
	set category = "Admin"
	set name = "Shuttle Import"

	if (!holder)
		src << "Only administrators may use this command."
		return

	if(!emergency_sanity_check())
		return

	var/datum/map_template/template
	var/map = input(usr, "Choose a Shuttle Template to import","Import Shuttle Template") as null|anything in shuttle_templates
	if(!map)
		return
	template = shuttle_templates[map]

	if(alert(usr,"Confirm importing of [map]","Shuttle Import Confirm","Yes","No") != "Yes")
		return

	var/turf/T = get_turf(locate("landmark*Shuttle Import"))
	if(!T)
		usr << "<span class='warning'>Shuttle import landmark not found. \
			Aborting.</span>"
	template.load(T, centered = TRUE)

	var/obj/docking_port/mobile/M

	for(var/S in template.get_affected_turfs(T,centered = TRUE))
		for (var/AM in S)
			if(istype(AM, /obj/docking_port/mobile))
				if(!M)
					M = AM
				else
					usr << "<span class='warning'>More than one mobile docking port was detected ([AM]), this is a BAD THING, TELL A CODER.</span>"
			if(istype(AM, /obj/docking_port/stationary))
				usr << "<span class='warning'>REEEEEEEEEEEE! THE LOADED TEMPLATE HAS [AM], A STATIONARY DOCKING PORT, THIS IS A BAD THING FIX IT. TELL A CODER. WE CAN DELETE IT BUT IT SHOULD NOT BE THERE."
				var/obj/docking_port/stationary/bad = AM
				bad.i_know_what_im_doing = TRUE
				qdel(bad)

	if(!M)
		usr << "<span class='warning'>The loaded template didn't have a mobile docking port! The template has been deleted.</span>"
		for(var/S in template.get_affected_turfs(T,centered = TRUE))
			var/turf/T0 = S
			for(var/atom/AM in T0.GetAllContents())
				if(istype(AM, /mob/dead))
					continue
				qdel(AM)
			qdel(S)
		return

	var/status = M.dockRoundstart()
	if(status)
		log_admin("The imported shuttle [map]/[M] failed to travel to its roundstart \
			location (error code [status]). Please fix or delete the imported shuttle \
			before continuing any more shuttle import hijinks.")

	log_admin("[key_name_admin(usr)] - ShuttleImport: [map] - [M]")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has used <b>ShuttleImport: [map] - [M]</b><BR></span>")
	feedback_add_details("admin_verb","SHTIMP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
