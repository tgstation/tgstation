datum/computer/file/embedded_program
	var/list/memory = list()
	var/state
	var/obj/machinery/embedded_controller/master

	proc
		post_signal(datum/signal/signal, comm_line)
			if(master)
				master.post_signal(signal, comm_line)
			else
				del(signal)

		receive_user_command(command)

		receive_signal(datum/signal/signal, receive_method, receive_param)
			return null

		process()
			return 0

obj/machinery/embedded_controller
	var/datum/computer/file/embedded_program/program

	name = "Embedded Controller"
	density = 0
	anchored = 1

	var/on = 1

	attack_hand(mob/user)
		user << browse(return_text(), "window=computer")
		user.set_machine(src)
		onclose(user, "computer")

	attackby(var/obj/item/W as obj, var/mob/user as mob)
		if(istype(W,/obj/item/device/multitool))
			update_multitool_menu(user,W)
		else
			..()

	update_icon()

	proc/return_text()

	proc/post_signal(datum/signal/signal, comm_line)
		return 0

	receive_signal(datum/signal/signal, receive_method, receive_param)
		if(!signal || signal.encryption) return

		if(program)
			program.receive_signal(signal, receive_method, receive_param)
			//spawn(5) program.process() //no, program.process sends some signals and machines respond and we here again and we lag -rastaf0

	Topic(href, href_list)
		if(..())
			return 0

		var/processed=0
		if(program)
			processed=program.receive_user_command(href_list["command"])
			spawn(5)
				program.process()
		if(processed)
			usr.set_machine(src)
			src.updateUsrDialog()
		return processed

	process()
		if(program)
			program.process()

		update_icon()
		//src.updateUsrDialog()

	radio
		var/frequency
		var/datum/radio_frequency/radio_connection

		initialize()
			set_frequency(frequency)

		post_signal(datum/signal/signal)
			signal.transmission_method = TRANSMISSION_RADIO
			if(radio_connection)
				return radio_connection.post_signal(src, signal)
			else
				del(signal)

		proc
			set_frequency(new_frequency)
				radio_controller.remove_object(src, frequency)
				frequency = new_frequency
				radio_connection = radio_controller.add_object(src, frequency)

	proc/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
		return "<b>NO MULTITOOL_MENU!</b>"

	proc/format_tag(var/label,var/varname)
		var/value = vars[varname]
		if(!value || value=="")
			value="-----"
		return "<b>[label]:</b> <a href=\"?src=\ref[src];set_tag=[varname]\">[value]</a>"

	proc/update_multitool_menu(mob/user as mob,var/obj/item/device/multitool/P)
		var/dat = {"<html>
	<head>
		<title>[name] Access</title>
		<style type="text/css">
html,body {
	font-family:courier;
	background:#999999;
	color:#333333;
}

a {
	color:#000000;
	text-decoration:none;
	border-bottom:1px solid black;
}
		</style>
	</head>
	<body>
		<h3>[name]</h3>
"}
		dat += multitool_menu(user,P)
		if(P)
			if(P.buffer)
				var/id="???"
				if(istype(P.buffer, /obj/machinery/telecomms))
					id=P.buffer:id
				else
					id=P.buffer:id_tag
				dat += "<p><b>MULTITOOL BUFFER:</b> [P.buffer] ([id])"
				if(!istype(P.buffer, /obj/machinery/telecomms))
					dat += " <a href='?src=\ref[src];link=1'>\[Link\]</a> <a href='?src=\ref[src];flush=1'>\[Flush\]</a>"
				dat += "</p>"
			else
				dat += "<p><b>MULTITOOL BUFFER:</b> <a href='?src=\ref[src];buffer=1'>\[Add Machine\]</a></p>"
		dat += "</body></html>"
		user << browse(dat, "window=mtcomputer")
		user.set_machine(src)
		onclose(user, "mtcomputer")