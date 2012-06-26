//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/item/weapon/airlock_electronics
	name = "Airlock Electronics"
	icon = 'door_assembly.dmi'
	icon_state = "door_electronics"
	w_class = 2.0 //It should be tiny! -Agouri
	m_amt = 50
	g_amt = 50

	req_access = list(ACCESS_ENGINE)

	var/list/conf_access = null
	var/last_configurator = null
	var/locked = 1
	var/style_name = "General"
	var/style = /obj/structure/door_assembly/door_assembly_0

	attack_self(mob/user as mob)
		if (!ishuman(user))
			return ..(user)

		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60)
			return

		var/t1 = text("<B>Access control</B><br>\n")


		if (last_configurator)
			t1 += "Operator: [last_configurator]<br>"

		if (locked)
			t1 += "<a href='?src=\ref[src];login=1'>Swipe ID</a><hr>"
		else
			t1 += "<a href='?src=\ref[src];logout=1'>Block</a><hr>"

			t1 += "Style: <a href='?src=\ref[src];style=1'>[style_name]</a><br><br>"


			t1 += conf_access == null ? "<font color=red>All</font><br>" : "<a href='?src=\ref[src];access=all'>All</a><br>"

			t1 += "<br>"

			var/list/accesses = get_all_accesses()
			for (var/acc in accesses)
				var/aname = get_access_desc(acc)

				if (!conf_access || !conf_access.len || !(acc in conf_access))
					t1 += "<a href='?src=\ref[src];access=[acc]'>[aname]</a><br>"
				else
					t1 += "<a style='color: red' href='?src=\ref[src];access=[acc]'>[aname]</a><br>"

		t1 += text("<p><a href='?src=\ref[];close=1'>Close</a></p>\n", src)

		user << browse(t1, "window=airlock_electronics")
		onclose(user, "airlock")

	Topic(href, href_list)
		..()
		if (usr.stat || usr.restrained() || !ishuman(usr))
			return
		if (href_list["close"])
			usr << browse(null, "window=airlock")
			return

		if (href_list["login"])
			var/obj/item/I = usr.equipped()
			if (istype(I, /obj/item/device/pda))
				var/obj/item/device/pda/pda = I
				I = pda.id
			if (I && src.check_access(I))
				src.locked = 0
				src.last_configurator = I:registered_name

		if (locked)
			return

		if (href_list["logout"])
			locked = 1

		if (href_list["access"])
			toggle_access(href_list["access"])

		if (href_list["style"])
			style_name = input("Select the door's paint scheme.", "Door Style", style_name) in \
				list("General", "Command", "Security", "Engineering", "Medical", "Maintenance", "Airlock", "Freezer", "Research")

			switch(style_name)
				if("General")
					style = /obj/structure/door_assembly/door_assembly_0
				if("Command")
					style = /obj/structure/door_assembly/door_assembly_com
				if("Security")
					style = /obj/structure/door_assembly/door_assembly_sec
				if("Engineering")
					style = /obj/structure/door_assembly/door_assembly_eng
				if("Medical")
					style = /obj/structure/door_assembly/door_assembly_med
				if("Maintenance")
					style = /obj/structure/door_assembly/door_assembly_mai
				if("Airlock")
					style = /obj/structure/door_assembly/door_assembly_ext
				if("Freezer")
					style = /obj/structure/door_assembly/door_assembly_fre
				if("Research")
					style = /obj/structure/door_assembly/door_assembly_research

		attack_self(usr)

	proc
		toggle_access(var/acc)
			if (acc == "all")
				conf_access = null
			else
				var/req = text2num(acc)

				if (conf_access == null)
					conf_access = list()

				if (!(req in conf_access))
					conf_access += req
				else
					conf_access -= req
					if (!conf_access.len)
						conf_access = null

