/obj/machinery/computer/telecomms/remote_control
	name = "telecommunications remote control"
	desc = "Lets the user, generally the CE, enable or disable remote control from circuitry."
	icon_screen = "comm_monitor"
	circuit = /obj/item/circuitboard/computer/remote_control

/obj/machinery/computer/telecomms/remote_control/attack_hand(mob/user)
	if(..())
		return
	user.set_machine(src)
	var/dat = "<TITLE>Telecommunications Remote Control</TITLE><br>Remote control: "
	dat += "<a href='?src=[REF(src)];toggle_remote_control=1'>[GLOB.remote_control ? "<font color='green'><b>ENABLED</b></font>" : "<font color='red'><b>DISABLED</b></font>"]</a>"
	user << browse(dat, "window=comm_monitor;size=575x400")
	onclose(user, "server_control")

/obj/machinery/computer/telecomms/remote_control/Topic(href, href_list)
	if(..())
		return
	add_fingerprint(usr)
	usr.set_machine(src)
	if(href_list["toggle_remote_control"])
		GLOB.remote_control = !GLOB.remote_control
	updateUsrDialog()