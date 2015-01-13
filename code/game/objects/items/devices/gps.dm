var/list/GPS_list = list()
/obj/item/device/gps
	name = "global positioning system"
	desc = "Helping lost spacemen find their way through the planets since 2016."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-c"
	w_class = 2.0
	slot_flags = SLOT_BELT
	origin_tech = "programming=2;engineering=2"
	var/gpstag = "COM0"
	var/emped = 0
	var/turf/locked_location

/obj/item/device/gps/New()
	..()
	GPS_list.Add(src)
	name = "global positioning system ([gpstag])"
	overlays += "working"

/obj/item/device/gps/Destroy()
	GPS_list.Remove(src)
	..()

/obj/item/device/gps/emp_act(severity)
	emped = 1
	overlays -= "working"
	overlays += "emp"
	spawn(300)
		emped = 0
		overlays -= "emp"
		overlays += "working"

/obj/item/device/gps/attack_self(mob/user as mob)

	var/obj/item/device/gps/t = ""
	var/gps_window_height = 110 + GPS_list.len * 20 // Variable window height, depending on how many GPS units there are to show
	if(emped)
		t += "ERROR"
	else
		t += "<BR><A href='?src=\ref[src];tag=1'>Set Tag</A> "
		t += "<BR>Tag: [gpstag]"
		if(locked_location && locked_location.loc)
			t += "<BR>Bluespace coordinates saved: [locked_location.loc]"
			gps_window_height += 20

		for(var/obj/item/device/gps/G in GPS_list)
			var/turf/pos = get_turf(G)
			var/area/gps_area = get_area(G)
			var/tracked_gpstag = G.gpstag
			if(G.emped == 1)
				t += "<BR>[tracked_gpstag]: ERROR"
			else
				t += "<BR>[tracked_gpstag]: [format_text(gps_area.name)] ([pos.x], [pos.y], [pos.z])"

	var/datum/browser/popup = new(user, "GPS", name, 360, min(gps_window_height, 800))
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/item/device/gps/Topic(href, href_list)
	..()
	if(href_list["tag"] )
		var/a = input("Please enter desired tag.", name, gpstag) as text
		a = uppertext(copytext(sanitize(a), 1, 5))
		if(src.loc == usr)
			gpstag = a
			name = "global positioning system ([gpstag])"
			attack_self(usr)

/obj/item/device/gps/science
	icon_state = "gps-s"
	gpstag = "SCI0"

/obj/item/device/gps/engineering
	icon_state = "gps-e"
	gpstag = "ENG0"

/obj/item/device/gps/mining
	icon_state = "gps-m"
	gpstag = "MINE0"
	desc = "A positioning system helpful for rescuing trapped or injured miners, keeping one on you at all times while mining might just save your life."
