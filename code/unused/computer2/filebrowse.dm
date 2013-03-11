/datum/computer/file/computer_program/progman
	name = "ProgManager"
	size = 16.0
	var/datum/computer/folder/current_folder
	var/mode = 0
	var/datum/computer/file/clipboard


	return_text()
		if(..())
			return

		if((!src.current_folder) || !(src.current_folder.holder in src.master))
			src.current_folder = src.holder.root

		var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a> | "
		dat += "<a href='byond://?src=\ref[src];quit=1'>Quit</a>"

		switch(mode)
			if(0)
				dat += " |<a href='byond://?src=\ref[src];create=folder'>Create Folder</a>"
				//dat += " | <a href='byond://?src=\ref[src];create=file'>Create File</a>"
				dat += " | <a href='byond://?src=\ref[src];file=\ref[src.current_folder];function=paste'>Paste</a>"
				dat += " | <a href='byond://?src=\ref[src];top_folder=1'>Root</a>"
				dat += " | <a href='byond://?src=\ref[src];mode=1'>Drive</a><br>"

				dat += "<b>Contents of [current_folder] | Drive:\[[src.current_folder.holder.title]]</b><br>"
				dat += "<b>Used: \[[src.current_folder.holder.file_used]/[src.current_folder.holder.file_amount]\]</b><hr>"

				dat += "<table cellspacing=5>"
				for(var/datum/computer/P in current_folder.contents)
					if(P == src)
						dat += "<tr><td>System</td><td>Size: [src.size]</td><td>SYSTEM</td></tr>"
						continue
					dat += "<tr><td><a href='byond://?src=\ref[src];file=\ref[P];function=open'>[P.name]</a></td>"
					dat +=  "<td>Size: [P.size]</td>"

					dat += "<td>[(istype(P,/datum/computer/folder)) ? "FOLDER" : "[P:extension]"]</td>"

					dat += "<td><a href='byond://?src=\ref[src];file=\ref[P];function=delete'>Del</a></td>"
					dat += "<td><a href='byond://?src=\ref[src];file=\ref[P];function=rename'>Rename</a></td>"


					if(istype(P,/datum/computer/file))
						dat += "<td><a href='byond://?src=\ref[src];file=\ref[P];function=copy'>Copy</a></td>"

					dat += "</tr>"

				dat += "</table>"

			if(1)
				dat += " | <a href='byond://?src=\ref[src];mode=0'>Main</a>"
				dat += " | <a href='byond://?src=\ref[master];disk=1'>Eject</a><br>"

				for(var/obj/item/weapon/disk/data/D in src.master)
					if(D == current_folder.holder)
						dat += "[D.name]<br>"
					else
						dat += "<a href='byond://?src=\ref[src];drive=\ref[D]'>[D.title]</a><br>"


		return dat

	Topic(href, href_list)
		if(..())
			return

		if(href_list["create"])
			if(current_folder)
				var/datum/computer/F = null
				switch(href_list["create"])
					if("folder")
						F = new /datum/computer/folder
						if(!current_folder.add_file(F))
							//world << "Couldn't add folder :("
							del(F)
					if("file")
						F = new /datum/computer/file
						if(!current_folder.add_file(F))
							//world << "Couldn't add file :("
							del(F)

		if(href_list["file"] && href_list["function"])
			var/datum/computer/F = locate(href_list["file"])
			if(!F || !istype(F))
				return
			switch(href_list["function"])
				if("open")
					if(istype(F,/datum/computer/folder))
						src.current_folder = F
					else if(istype(F,/datum/computer/file/computer_program))
						src.master.run_program(F,src)
						src.master.updateUsrDialog()
						return

				if("delete")
					src.master.delete_file(F)

				if("copy")
					if(istype(F,/datum/computer/file) && (!F.holder || (F.holder in src.master.contents)))
						src.clipboard = F

				if("paste")
					if(istype(F,/datum/computer/folder))
						if(!src.clipboard || !src.clipboard.holder || !(src.clipboard.holder in src.master.contents))
							return

						if(!istype(src.clipboard))
							return

						src.clipboard.copy_file_to_folder(F)

				if("rename")
					spawn(0)
						var/t = input(usr, "Please enter new name", F.name, null) as text
						t = copytext(sanitize(t), 1, 16)
						if (!t)
							return
						if (!in_range(src.master, usr) || !(F.holder in src.master))
							return
						if(F.holder.read_only)
							return
						F.name = capitalize(lowertext(t))
						src.master.updateUsrDialog()
						return


/*
		if(href_list["open"])
			var/datum/computer/F = locate(href_list["open"])
			if(!F || !istype(F))
				return

			if(istype(F,/datum/computer/folder))
				src.current_folder = F
			else if(istype(F,/datum/computer/file/computer_program))
				src.master.run_program(F)
				src.master.updateUsrDialog()
				return

		if(href_list["delete"])
			var/datum/computer/F = locate(href_list["delete"])
			if(!F || !istype(F))
				return

			src.master.delete_file(F)
*/
		if(href_list["top_folder"])
			src.current_folder = src.current_folder.holder.root

		if(href_list["mode"])
			var/newmode = text2num(href_list["mode"])
			newmode = max(newmode,0)
			src.mode = newmode

		if(href_list["drive"])
			var/obj/item/weapon/disk/data/D = locate(href_list["drive"])
			if(D && istype(D) && D.root)
				current_folder = D.root
				src.mode = 0

		src.master.add_fingerprint(usr)
		src.master.updateUsrDialog()
		return