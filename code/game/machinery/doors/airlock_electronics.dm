//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/item/weapon/airlock_electronics
	name = "airlock electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	w_class = 2.0 //It should be tiny! -Agouri
	m_amt = 50
	g_amt = 50

	req_access = list(access_maint_tunnels)

	var/list/conf_access = null
	var/use_one_access = 0 //If the door should require ALL or only ONE of the listed accesses.
	var/last_configurator = null
	var/locked = 1

/obj/item/weapon/airlock_electronics/attack_self(mob/user as mob)
	if (!ishuman(user))
		return ..(user)

	var/mob/living/carbon/human/H = user
	if(H.getBrainLoss() >= 60)
		return

	var/t1 = text("")


	if (last_configurator)
		t1 += "Operator: [last_configurator]<br>"

	if (locked)
		t1 += "<a href='?src=\ref[src];login=1'>Swipe ID</a><hr>"
	else
		t1 += "<a href='?src=\ref[src];logout=1'>Lock Interface</a><hr>"

		if(use_one_access)
			t1 += "Restriction Type: <a href='?src=\ref[src];access=one'>At least one access required</a><br>"
		else
			t1 += "Restriction Type: <a href='?src=\ref[src];access=one'>All accesses required</a><br>"

		t1 += "<a href='?src=\ref[src];access=all'>Remove All</a><br>"

		var/accesses = ""
		accesses += "<div align='center'><b>Access</b></div>"
		accesses += "<table style='width:100%'>"
		accesses += "<tr>"
		for(var/i = 1; i <= 7; i++)
			accesses += "<td style='width:14%'><b>[get_region_accesses_name(i)]:</b></td>"
		accesses += "</tr><tr>"
		for(var/i = 1; i <= 7; i++)
			accesses += "<td style='width:14%' valign='top'>"
			for(var/A in get_region_accesses(i))
				if(A in conf_access)
					accesses += "<a href='?src=\ref[src];access=[A]'><font color=\"red\">[replacetext(get_access_desc(A), " ", "&nbsp")]</font></a> "
				else
					accesses += "<a href='?src=\ref[src];access=[A]'>[replacetext(get_access_desc(A), " ", "&nbsp")]</a> "
				accesses += "<br>"
			accesses += "</td>"
		accesses += "</tr></table>"
		t1 += "<tt>[accesses]</tt>"

	t1 += text("<p><a href='?src=\ref[];close=1'>Close</a></p>\n", src)

	var/datum/browser/popup = new(user, "airlock_electronics", "Access Control", 900, 500)
	popup.set_content(t1)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	onclose(user, "airlock")

/obj/item/weapon/airlock_electronics/Topic(href, href_list)
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

/obj/item/weapon/airlock_electronics/proc/toggle_access(var/acc)
	if (acc == "all")
		conf_access = null
	else if(acc == "one")
		use_one_access = !use_one_access
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

