//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/item/weapon/airlock_electronics
	name = "Airlock Electronics"
	icon = 'door_assembly.dmi'
	icon_state = "door_electronics"
	w_class = 2.0 //It should be tiny! -Agouri
	m_amt = 50
	g_amt = 50

	req_access = list(access_engine)

	var/list/conf_access = null
	var/last_configurator = null
	var/locked = 1

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
			var/obj/item/I = usr.get_active_hand()
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

