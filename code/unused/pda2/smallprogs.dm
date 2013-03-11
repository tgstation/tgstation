//Assorted small programs not worthy of their own file
//CONTENTS:
//Crew Manifest viewer
//Status display controller
//Remote signaling program
//Cargo orders monitor

//Manifest
/datum/computer/file/pda_program/manifest
	name = "Manifest"

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()

		dat += "<h4>Crew Manifest</h4>"
		dat += "Entries cannot be modified from this terminal.<br><br>"

		for (var/datum/data/record/t in data_core.general)
			dat += "[t.fields["name"]] - [t.fields["rank"]]<br>"
		dat += "<br>"

		return dat

//Status Display
/datum/computer/file/pda_program/status_display
	name = "Status Controller"
	size = 8.0
	var/message1	// For custom messages on the displays.
	var/message2

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()

		dat += "<h4>Station Status Display Interlink</h4>"

		dat += "\[ <A HREF='?src=\ref[src];statdisp=blank'>Clear</A> \]<BR>"
		dat += "\[ <A HREF='?src=\ref[src];statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
		dat += "\[ <A HREF='?src=\ref[src];statdisp=message'>Message</A> \]"

		dat += "<ul><li> Line 1: <A HREF='?src=\ref[src];statdisp=setmsg1'>[ message1 ? message1 : "(none)"]</A>"
		dat += "<li> Line 2: <A HREF='?src=\ref[src];statdisp=setmsg2'>[ message2 ? message2 : "(none)"]</A></ul><br>"
		dat += "\[ Alert: <A HREF='?src=\ref[src];statdisp=alert;alert=default'>None</A> |"

		dat += " <A HREF='?src=\ref[src];statdisp=alert;alert=redalert'>Red Alert</A> |"
		dat += " <A HREF='?src=\ref[src];statdisp=alert;alert=lockdown'>Lockdown</A> |"
		dat += " <A HREF='?src=\ref[src];statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR>"

		return dat


	Topic(href, href_list)
		if(..())
			return

		if(href_list["statdisp"])
			switch(href_list["statdisp"])
				if("message")
					post_status("message", message1, message2)
				if("alert")
					post_status("alert", href_list["alert"])

				if("setmsg1")
					message1 = input("Line 1", "Enter Message Text", message1) as text|null
					if (!src.master || !in_range(src.master, usr) && src.master.loc != usr)
						return

					if(!(src.holder in src.master))
						return
					src.master.updateSelfDialog()

				if("setmsg2")
					message2 = input("Line 2", "Enter Message Text", message2) as text|null
					if (!src.master || !in_range(src.master, usr) && src.master.loc != usr)
						return

					if(!(src.holder in src.master))
						return

					src.master.updateSelfDialog()
				else
					post_status(href_list["statdisp"])

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return

	proc/post_status(var/command, var/data1, var/data2)
		if(!src.master)
			return

		var/datum/signal/status_signal = new
		status_signal.source = src.master
		status_signal.transmission_method = 1
		status_signal.data["command"] = command

		switch(command)
			if("message")
				status_signal.data["msg1"] = data1
				status_signal.data["msg2"] = data2
			if("alert")
				status_signal.data["picture_state"] = data1

		src.post_signal(status_signal,"1435")

//Signaler
/datum/computer/file/pda_program/signaler
	name = "Signalix 5"
	size = 8.0
	var/send_freq = 1457 //Frequency signal is sent at, should be kept within normal radio ranges.
	var/send_code = 30
	var/last_transmission = 0 //No signal spamming etc

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()

		dat += "<h4>Remote Signaling System</h4>"
		dat += {"
<a href='byond://?src=\ref[src];send=1'>Send Signal</A><BR>

Frequency:
<a href='byond://?src=\ref[src];adj_freq=-10'>-</a>
<a href='byond://?src=\ref[src];adj_freq=-2'>-</a>
[format_frequency(send_freq)]
<a href='byond://?src=\ref[src];adj_freq=2'>+</a>
<a href='byond://?src=\ref[src];adj_freq=10'>+</a><br>
<br>
Code:
<a href='byond://?src=\ref[src];adj_code=-5'>-</a>
<a href='byond://?src=\ref[src];adj_code=-1'>-</a>
[send_code]
<a href='byond://?src=\ref[src];adj_code=1'>+</a>
<a href='byond://?src=\ref[src];adj_code=5'>+</a><br>"}

		return dat

	Topic(href, href_list)
		if(..())
			return

		if (href_list["send"])
			if(last_transmission && world.time < (last_transmission + 5))
				return
			last_transmission = world.time
			spawn( 0 )
				var/time = time2text(world.realtime,"hh:mm:ss")
				lastsignalers.Add("[time] <B>:</B> [usr.key] used [src.master] @ location ([src.master.loc.x],[src.master.loc.y],[src.master.loc.z]) <B>:</B> [format_frequency(send_freq)]/[send_code]")

				var/datum/signal/signal = new
				signal.source = src
				signal.encryption = send_code
				signal.data["message"] = "ACTIVATE"

				src.post_signal(signal,"[send_freq]")
				return

		else if (href_list["adj_freq"])
			src.send_freq = sanitize_frequency(src.send_freq + text2num(href_list["adj_freq"]))

		else if (href_list["adj_code"])
			src.send_code += text2num(href_list["adj_code"])
			src.send_code = round(src.send_code)
			src.send_code = min(100, src.send_code)
			src.send_code = max(1, src.send_code)

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return

//Supply record monitor
/datum/computer/file/pda_program/qm_records
	name = "Supply Records"
	size = 8.0

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()
		dat += "<h4>Supply Record Interlink</h4>"

		dat += "<BR><B>Supply shuttle</B><BR>"
		dat += "Location: [supply_shuttle_moving ? "Moving to station ([supply_shuttle_timeleft] Mins.)":supply_shuttle_at_station ? "Station":"Dock"]<BR>"
		dat += "Current approved orders: <BR><ol>"
		for(var/S in supply_shuttle_shoppinglist)
			var/datum/supply_order/SO = S
			dat += "<li>[SO.object.name] approved by [SO.orderedby] [SO.comment ? "([SO.comment])":""]</li>"
		dat += "</ol>"

		dat += "Current requests: <BR><ol>"
		for(var/S in supply_shuttle_requestlist)
			var/datum/supply_order/SO = S
			dat += "<li>[SO.object.name] requested by [SO.orderedby]</li>"
		dat += "</ol><font size=\"-3\">Upgrade NOW to Space Parts & Space Vendors PLUS for full remote order control and inventory management."

		return dat
