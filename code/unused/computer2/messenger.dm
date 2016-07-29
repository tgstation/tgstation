/datum/computer/file/computer_program/messenger
	name = "Messenger"
	size = 8.0
	var/messages = null
	var/screen_name = "User"

//To-do: take screen_name from inserted id card??
//Saving log to file datum

	return_text()
		if(..())
			return

		var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a> | "
		dat += "<a href='byond://?src=\ref[src];quit=1'>Quit</a><br>"

		dat += "<b>SpaceMessenger V4.1.2</b><br>"

		dat += "<a href='byond://?src=\ref[src];send_msg=1'>Send Message</a>"

		dat += " | <a href='byond://?src=\ref[src];func_msg=clear'>Clear</a>"
		dat += " | <a href='byond://?src=\ref[src];func_msg=print'>Print</a>"

		dat += " | Name:<a href='byond://?src=\ref[src];set_name=1'>[src.screen_name]</a><hr>"

		dat += messages

		dat += "</center>"

		return dat

	Topic(href, href_list)
		if(..())
			return

		if(href_list["send_msg"])
			var/t = input(usr, "Please enter messenger", src.id_tag, null) as text
			t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
			if (!t)
				return
			if (!in_range(src.master, usr))
				return

			var/datum/signal/signal = new
			signal.data["type"] = "message"
			signal.data["data"] = t
			signal.data["sender"] = src.screen_name
			src.messages += "<i><b>&rarr; You:</b></i><br>[t]<br>"

			peripheral_command("send signal", signal)

		if(href_list["func_msg"])
			switch(href_list["func_msg"])
				if("clear")
					src.messages = null

				if("print")
					var/datum/signal/signal = new
					signal.data["data"] = src.messages
					signal.data["title"] = "Chatlog"
					peripheral_command("print", signal)

				//if("save")
					//TO-DO


		if(href_list["set_name"])
			var/t = input(usr, "Please enter screen name", src.id_tag, null) as text
			t = copytext(sanitize(t), 1, 20)
			if (!t)
				return
			if (!in_range(src.master, usr))
				return

			src.screen_name = t

		src.master.add_fingerprint(usr)
		src.master.updateUsrDialog()
		return

	receive_command(obj/source, command, datum/signal/signal)
		if(..() || !signal)
			return

		if(command == "radio signal")
			switch(signal.data["type"])
				if("message")
					var/sender = signal.data["sender"]
					if(!sender)
						sender = "Unknown"

					src.messages += "<i><b>&larr; From [sender]:</b></i><br>[signal.data["data"]]<br>"
					if(src.master.active_program == src)
						playsound(src.master.loc, 'sound/machines/twobeep.ogg', 50, 1)
						src.master.updateUsrDialog()

		return