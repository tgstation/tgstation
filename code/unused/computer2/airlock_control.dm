/datum/computer/file/computer_program/airlock_control
	name = "Airlock Master"
	size = 16.0
	id_tag = "TAG"


	return_text()
		if(..())
			return

		var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a> | "
		dat += "<a href='byond://?src=\ref[src];quit=1'>Quit</a>"

		/*
		dat += "<br><TT>Frequency: "
		dat += "<a href='?src=\ref[src];adj_freq=-10'>--</a> "
		dat += "<a href='?src=\ref[src];adj_freq=-2'>-</a> "
		dat += "[format_frequency(src.master.frequency)] "
		dat += "<a href='?src=\ref[src];adj_freq=2'>+</a> "
		dat += "<a href='?src=\ref[src];adj_freq=10'>++</a>"
		dat += "</TT><br>"
		*/


		dat += "<br>ID:<a href='byond://?src=\ref[src];set_tag=1'>[src.id_tag]</a><br>"

		dat += "<a href='byond://?src=\ref[src];send_command=cycle'>Cycle</a>"


		dat += "</b></center>"

		return dat

	Topic(href, href_list)
		if(..())
			return

		if(href_list["set_tag"])
			var/t = input(usr, "Please enter new tag", src.id_tag, null) as text
			t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
			if (!t)
				return
			if (!in_range(src.master, usr))
				return

			src.id_tag = t

//		if(href_list["adj_freq"])
//			var/new_frequency = (src.master.frequency + text2num(href_list["adj_freq"]))
//			src.master.set_frequency(new_frequency)

		if(href_list["send_command"])
			var/datum/signal/signal = new
			signal.data["tag"] = id_tag
			signal.data["command"] = href_list["send_command"]
			peripheral_command("send signal", signal)

		src.master.add_fingerprint(usr)
		src.master.updateUsrDialog()
		return