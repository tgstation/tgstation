/obj/machinery/computer/rdconsole
	name = "R&D Console"
	icon_state = "rdcomp"
	var
		datum/research/files
		obj/item/weapon/disk/tech_disk/t_disk = null
		obj/item/weapon/disk/design_disk/d_disk = null

		screen = 1.0 //1 = MAIN,

	New()
		files = new /datum/research(src)

	meteorhit()
		del(src)
		return

	blob_act()
		if (prob(50))
			del(src)

	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
				return
			if(2.0)
				if (prob(50))
					del(src)
					return

	attackby(var/obj/item/weapon/disk/D as obj, var/mob/user as mob)
		if(istype(D, /obj/item/weapon/disk/tech_disk))
			if(t_disk)
				user << "A disk is already loaded into the machine."
				return
			t_disk = D
		else if (istype(D, /obj/item/weapon/disk/design_disk))
			if(d_disk)
				user << "A disk is already loaded into the machine."
				return
			d_disk = D
		user.drop_item()
		D.loc = src
		user << "You add the disk to the machine!"
		src.updateUsrDialog()
		//Insert icon change here.

	Topic(href, href_list)
		if(stat & BROKEN) return
		if(usr.stat || usr.restrained()) return
		if(!in_range(src, usr)) return

		add_fingerprint(usr)

		usr.machine = src
		if(href_list["menu"])
			screen = text2num(href_list["menu"])

		else if(href_list["updt_tech"])
			screen = 0.0
			spawn(50)
				screen = 3.0
				files.AddTech2Known(t_disk.stored)
				updateUsrDialog()

		else if(href_list["clear_tech"])
			t_disk.stored = null

		else if(href_list["eject_tech"])
			t_disk:loc = src.loc
			t_disk = null
			screen = 1.0

		else if(href_list["copy_tech"])
			for(var/datum/tech/T in files.known_tech)
				if(href_list["copy_tech_ID"] == T.id)
					t_disk.stored = T
					break
			screen = 3.0

		else if(href_list["clear_design"])
			d_disk.blueprint = null

		else if(href_list["eject_design"])
			d_disk:loc = src.loc
			d_disk = null
			screen = 1.0

		else if(href_list["copy_design"])
			for(var/datum/design/D in files.known_designs)
				if(href_list["copy_design_ID"] == D.id)
					d_disk.blueprint = D
					break
			screen = 4.0

		updateUsrDialog()

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(stat & BROKEN)
			return
		user.machine = src
		var/dat = ""
		switch(screen)
			if(0.0)
				dat += "Updating Database...."
			if(1.0) //Main Menu
				dat += "Main Menu:<BR><BR>"
				dat += "<A href='?src=\ref[src];menu=2.0'>Current Research Levels</A><BR>"
				if(t_disk) dat += "<A href='?src=\ref[src];menu=3.0'>Disk Operations</A><BR>"
				else if(d_disk) dat += "<A href='?src=\ref[src];menu=4.0'>Disk Operations</A><BR>"
				else dat += "(Please Insert Disk)<BR>"

			if(2.0) //Research viewer
				dat += "Current Research Levels:<BR><BR>"
				for(var/datum/tech/T in files.known_tech)
					dat += "[T.name]<BR>"
					dat +=  "* Level: [T.level]<BR>"
					dat +=  "* Summary: [T.desc]<HR>"
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

			if(3.0) //Technology Disk Menu
				dat += "Disk Contents: (Technology Data Disk)<BR><BR>"
				if(t_disk.stored == null)
					dat += "The disk has no data stored on it.<HR>"
					dat += "Operations: "
					dat += "<A href='?src=\ref[src];menu=3.1'>Load Tech to Disk</A> || "
				else
					dat += "Name: [t_disk.stored.name]<BR>"
					dat += "Level: [t_disk.stored.level]<BR>"
					dat += "Description: [t_disk.stored.desc]<HR>"
					dat += "Operations: "
					dat += "<A href='?src=\ref[src];updt_tech=1'>Upload to Database</A> || "
					dat += "<A href='?src=\ref[src];clear_tech=1'>Clear Disk</A> || "
				dat += "<A href='?src=\ref[src];eject_tech=1'>Eject Disk</A><HR>"
				dat += "<BR><A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			if(3.1) //Technology Disk submenu
				dat += "Load Technology to Disk:<BR><BR>"
				for(var/datum/tech/T in files.known_tech)
					dat += "[T.name] "
					dat += "<A href='?src=\ref[src];copy_tech=1;copy_tech_ID=[T.id]'>(Copy to Disk)</A><BR>"
				dat += "<HR><BR><A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
				dat += "<A href='?src=\ref[src];menu=3.0'>Return to Disk Operations</A>"

			if(4.0) //Design Disk menu.
				if(d_disk.blueprint == null)
					dat += "The disk has no data stored on it.<HR>"
					dat += "Operations: "
					dat += "<A href='?src=\ref[src];menu=4.1'>Load Design to Disk</A> || "
				else
					dat += "Name: [d_disk.blueprint.name]<BR>"
					dat += "Level: [between(0, (d_disk.blueprint.reliability + rand(-15,15)), 100)]<BR>"
					switch(d_disk.blueprint.build_type)
						if(IMPRINTER) dat += "Lathe Type: Circuit Imprinter<BR>"
						if(PROTOLATHE) dat += "Lathe Type: Proto-lathe<BR>"
						if(AUTOLATHE) dat += "Lathe Type: Auto-lathe<BR>"
					dat += "Required Materials:<BR>"
					for(var/M in d_disk.blueprint.materials)
						if(copytext(M, 1, 2) == "$") dat += "* [copytext(M, 2)] x [d_disk.blueprint.materials[M]]<BR>"
						else dat += "* [M] x [d_disk.blueprint.materials[M]]<BR>"
					dat += "<HR>Operations: "
					dat += "<A href='?src=\ref[src];clear_design=1'>Clear Disk</A> || "
				dat += "<A href='?src=\ref[src];eject_design=1'>Eject Disk</A><HR>"
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			if(4.1) //Technology disk submenu
				dat += "Load Design to Disk:<BR><BR>"
				for(var/datum/design/D in files.known_designs)
					dat += "[D.name] "
					dat += "<A href='?src=\ref[src];copy_design=1;copy_design_ID=[D.id]'>(Copy to Disk)</A><BR>"
				dat += "<HR><A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
				dat += "<A href='?src=\ref[src];menu=3.0'>Return to Disk Operations</A>"


		user << browse("<TITLE>Research and Development Console</TITLE><HR>[dat]", "window=rdconsole;size=575x400")
		onclose(user, "rdconsole")