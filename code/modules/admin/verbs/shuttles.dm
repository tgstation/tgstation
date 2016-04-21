
/client/proc/cmd_admin_destroy_shuttle()
	set category = "Admin"
	set name = "Shuttle Destroy"

	if (!holder)
		src << "Only administrators may use this command."
		return

	var/obj/docking_port/mobile/M = input("Select shuttle to DESTROY", "Shuttles") as null|anything in SSshuttle.mobile

	if(!M)
		return

	var/confirm = alert(src, "Are you sure you want to destroy [M]?", "Confirm", "Yes", "No")
	if(confirm != "Yes")
		return

	M.jumpToNullSpace()

	log_admin("ShuttleDestroy: [M]")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has used <b>ShuttleDestroy on [M]</b><BR></span>")
	feedback_add_details("admin_verb","SHTDEL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
