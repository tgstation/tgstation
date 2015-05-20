var/list/GPS_list = list()
var/list/SPS_list = list()


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
	if(istype(src,/obj/item/device/gps/secure))
		SPS_list.Remove(src)
	else
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
	var/list/locallist = null
	if(istype(src,/obj/item/device/gps/secure))
		locallist = SPS_list.Copy()
	else
		locallist = GPS_list.Copy()
	var/gps_window_height = 110 + locallist.len * 20 // Variable window height, depending on how many GPS units there are to show
	if(emped)
		t += "ERROR"
	else
		t += "<BR><A href='?src=\ref[src];tag=1'>Set Tag</A> "
		t += "<BR>Tag: [gpstag]"
		if(locked_location && locked_location.loc)
			t += "<BR>Bluespace coordinates saved: [locked_location.loc]"
			gps_window_height += 20

		for(var/obj/item/device/gps/G in locallist)
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



/obj/item/device/gps/secure
	name = "secure positioning system"
	desc = "A secure channel SPS with several features designed to keep its wearer safe."
	icon_state = "sps"
	gpstag = "SEC0"

/obj/item/device/gps/secure/New()
	SPS_list.Add(src)
	gpstag = "SEC0"
	name = "secure positioning system ([gpstag])"
	overlays += "working"

/obj/item/device/gps/secure/OnMobDeath(mob/holder)
	var/obj/item/device/gps/secure/S
	for(S in SPS_list)
		S.announce(holder, src, "died")
	..(holder)

/obj/item/device/gps/secure/dropped(mob/wearer as mob)
	..()
	spawn (1) //Race conditions
		if(istype(src.loc, /turf))
			for(var/obj/item/device/gps/secure/S in SPS_list)
				S.announce(wearer, src, "lost [wearer.gender == FEMALE ? "her" : "his"] SPS")
		else
			return

/obj/item/device/gps/secure/proc/announce(var/mob/wearer, var/obj/item/SPS, var/reason)
	var/mob/holder = src.loc
	if(holder)
		holder << "Your SPS beeps: <span class='warning'>Warning! [wearer] has [reason] at [get_area(SPS)].</span>"

