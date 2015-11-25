var/list/GPS_list = list()
var/list/SPS_list = list()

/obj/item/device/gps
	name = "global positioning system"
	desc = "Helping lost spacemen find their way through the planets since 2016."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-c"
	w_class = 2.0
	flags = FPRINT
	slot_flags = SLOT_BELT
	origin_tech = "bluespace=2;magnets=2"
	var/gpstag = "COM0"
	var/emped = 0

/obj/item/device/gps/New()
	..()
	overlays += "working"
	handle_list()


/obj/item/device/gps/proc/handle_list()
	GPS_list.Add(src)
	name = "global positioning system ([gpstag])"

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
	if(emped)
		t += "ERROR"
	else
		t += "<BR><A href='?src=\ref[src];tag=1'>Set Tag</A> "
		t += "<BR>Tag: [gpstag]"

		for(var/obj/item/device/gps/G in locallist)
			var/turf/pos = get_turf(G)
			var/area/gps_area = get_area(G)
			var/tracked_gpstag = G.gpstag
			if(G.emped == 1)
				t += "<BR>[tracked_gpstag]: ERROR"
			else if(!pos || !gps_area)
				t += "<BR>[tracked_gpstag]: UNKNOWN"
			else if(pos.z > WORLD_X_OFFSET.len)
				t += "<BR>[tracked_gpstag]: [format_text(gps_area.name)] (UNKNOWN, UNKNOWN, UNKNOWN)"
			else
				t += "<BR>[tracked_gpstag]: [format_text(gps_area.name)] ([pos.x-WORLD_X_OFFSET[pos.z]], [pos.y-WORLD_Y_OFFSET[pos.z]], [pos.z])"

	var/datum/browser/popup = new(user, "GPS", name, 600, 450)
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/item/device/gps/examine(mob/user)
	if (Adjacent(user) || isobserver(user))
		src.attack_self(user)
	else
		..()

/obj/item/device/gps/Topic(href, href_list)
	..()
	if(href_list["tag"])
		if (isobserver(usr))
			to_chat(usr, "No way.")
			return
		if (usr.get_active_hand() != src || usr.stat) //no silicons allowed
			to_chat(usr, "<span class = 'caution'>You need to have the GPS in your hand to do that!</span>")
			return

		var/a = input("Please enter desired tag.", name, gpstag) as text|null
		if (!a) //what a check
			return

		if (usr.get_active_hand() != src || usr.stat) //second check in case some chucklefuck drops the GPS while typing the tag
			to_chat(usr, "<span class = 'caution'>The GPS needs to be kept in your active hand!</span>")
			return
		a = copytext(sanitize(a), 1, 20)
		if(length(a) != 4)
			to_chat(usr, "<span class = 'caution'>The tag must be four letters long!</span>")
			return

		else
			gpstag = a
			name = "global positioning system ([gpstag])"
			return

/obj/item/device/gps/science
	icon_state = "gps-s"
	gpstag = "SCI0"

/obj/item/device/gps/engineering
	icon_state = "gps-e"
	gpstag = "ENG0"

/obj/item/device/gps/paramedic
	icon_state = "gps-p"
	gpstag = "PMD0"

/obj/item/device/gps/mining
	desc = "A more rugged looking GPS device. Useful for finding miners. Or their corpses."
	icon_state = "gps-m"
	gpstag = "MIN0"

var/global/secure_GPS_count = 0

/obj/item/device/gps/secure
	name = "secure positioning system"
	desc = "A secure channel SPS. It announces the position of the wearer if killed or stripped off."
	icon_state = "sps"
	gpstag = "SEC0"

/obj/item/device/gps/secure/handle_list()
	SPS_list.Add(src)
	gpstag = "SEC[secure_GPS_count]"
	secure_GPS_count++
	name = "secure positioning system ([gpstag])"


/obj/item/device/gps/secure/OnMobDeath(mob/wearer as mob)
	if(emped) return

	for(var/E in SPS_list)
		var/obj/item/device/gps/secure/S  = E //No idea why casting it like this makes it work better instead of just defining it in the for each
		S.announce(wearer, src, "died")

/obj/item/device/gps/secure/stripped(mob/wearer as mob)
	if(emped) return
	.=..()

	for(var/E in SPS_list)
		var/obj/item/device/gps/secure/S  = E
		S.announce(wearer, src, "been stripped of [wearer.gender == FEMALE ? "her" : "his"] SPS")

/obj/item/device/gps/secure/proc/announce(var/mob/wearer, var/obj/item/device/gps/secure/SPS, var/reason)
	if(istype(src.loc, /mob/living))
		var/mob/living/L = src.loc
		L.show_message("[gpstag] beeps: <span class='warning'>Warning! [wearer] has [reason] at [get_area(SPS)].</span>",MESSAGE_HEAR)
	else if(isturf(src.loc))
		src.visible_message("[gpstag] beeps: <span class='warning'>Warning! [wearer] has [reason] at [get_area(SPS)].</span>")
