<<<<<<< HEAD
var/list/GPS_list = list()
/obj/item/device/gps
	name = "global positioning system"
	desc = "Helping lost spacemen find their way through the planets since 2016. Alt+click to toggle power."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-c"
	w_class = 2
	slot_flags = SLOT_BELT
	origin_tech = "materials=2;magnets=1;bluespace=2"
	var/gpstag = "COM0"
	var/emped = 0
	var/turf/locked_location
	var/tracking = TRUE

/obj/item/device/gps/New()
	..()
	GPS_list.Add(src)
	name = "global positioning system ([gpstag])"
	add_overlay("working")

/obj/item/device/gps/Destroy()
	GPS_list.Remove(src)
	return ..()

/obj/item/device/gps/emp_act(severity)
	emped = TRUE
	overlays -= "working"
	add_overlay("emp")
	addtimer(src, "reboot", 300)

/obj/item/device/gps/proc/reboot()
	emped = FALSE
	overlays -= "emp"
	add_overlay("working")

/obj/item/device/gps/AltClick(mob/user)
	if(!user.canUseTopic(src, be_close=TRUE))
		return //user not valid to use gps
	if(emped)
		user << "It's busted!"
	if(tracking)
		overlays -= "working"
		user << "[src] is no longer tracking, or visible to other GPS devices."
		tracking = FALSE
	else
		add_overlay("working")
		user << "[src] is now tracking, and visible to other GPS devices."
		tracking = TRUE

/obj/item/device/gps/attack_self(mob/user)
	if(!tracking)
		user << "[src] is turned off. Use alt+click to toggle it back on."
		return

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
			else if(G.tracking)
				t += "<BR>[tracked_gpstag]: [format_text(gps_area.name)] ([pos.x], [pos.y], [pos.z])"
			else
				continue
	var/datum/browser/popup = new(user, "GPS", name, 360, min(gps_window_height, 800))
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/item/device/gps/Topic(href, href_list)
	..()
	if(href_list["tag"] )
		var/a = input("Please enter desired tag.", name, gpstag) as text
		a = uppertext(copytext(sanitize(a), 1, 5))
		if(in_range(src, usr))
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

/obj/item/device/gps/cyborg
	icon_state = "gps-b"
	gpstag = "BORG0"
	desc = "A mining cyborg internal positioning system. Used as a recovery beacon for damaged cyborg assets, or a collaboration tool for mining teams."
	flags = NODROP

/obj/item/device/gps/internal
	icon_state = null
	flags = ABSTRACT
	gpstag = "Eerie Signal"
	desc = "Report to a coder immediately."
	invisibility = INVISIBILITY_MAXIMUM

/obj/item/device/gps/mining/internal
	icon_state = "gps-m"
	gpstag = "MINER"
	desc = "A positioning system helpful for rescuing trapped or injured miners, keeping one on you at all times while mining might just save your life."

/obj/item/device/gps/visible_debug
	name = "visible GPS"
	gpstag = "ADMIN"
	desc = "This admin-spawn GPS unit leaves the coordinates visible \
		on any turf that it passes over, for debugging. Especially useful \
		for marking the area around the transition edges."
	var/list/turf/tagged

/obj/item/device/gps/visible_debug/New()
	. = ..()
	tagged = list()
	SSfastprocess.processing += src

/obj/item/device/gps/visible_debug/process()
	var/turf/T = get_turf(src)
	if(T)
		// I assume it's faster to color,tag and OR the turf in, rather
		// then checking if its there
		T.color = RANDOM_COLOUR
		T.maptext = "[T.x],[T.y],[T.z]"
		tagged |= T

/obj/item/device/gps/visible_debug/proc/clear()
	while(tagged.len)
		var/turf/T = pop(tagged)
		T.color = initial(T.color)
		T.maptext = initial(T.maptext)

/obj/item/device/gps/visible_debug/Destroy()
	if(tagged)
		clear()
	tagged = null
	SSfastprocess.processing -= src
	. = ..()
=======
var/list/GPS_list = list()
var/list/SPS_list = list()

/obj/item/device/gps
	name = "global positioning system"
	desc = "Helping lost spacemen find their way through the planets since 2016."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-c"
	w_class = W_CLASS_SMALL
	flags = FPRINT
	slot_flags = SLOT_BELT
	origin_tech = "bluespace=2;magnets=2"
	var/gpstag = "COM0"
	var/emped = 0

/obj/item/device/gps/New()
	..()
	overlays += image(icon = icon, icon_state = "working")
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
	overlays -= image(icon = icon, icon_state = "working")
	overlays += image(icon = icon, icon_state = "emp")
	spawn(300)
		emped = 0
		overlays -= image(icon = icon, icon_state = "emp")
		overlays += image(icon = icon, icon_state = "working")

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
		S.announce(wearer, src, "has detected the death of their wearer")

/obj/item/device/gps/secure/stripped(mob/wearer as mob)
	if(emped) return
	.=..()

	for(var/E in SPS_list)
		var/obj/item/device/gps/secure/S  = E
		S.announce(wearer, src, "has been stripped from their wearer")

/obj/item/device/gps/secure/proc/announce(var/mob/wearer, var/obj/item/device/gps/secure/SPS, var/reason)
	var/turf/pos = get_turf(SPS)
	var/mob/living/L = get_holder_of_type(src, /mob/living/)
	if(L)
		L.show_message("\icon[src] [gpstag] beeps: <span class='danger'>Warning! SPS '[SPS.gpstag]' [reason] at [get_area(SPS)] ([pos.x-WORLD_X_OFFSET[pos.z]], [pos.y-WORLD_Y_OFFSET[pos.z]], [pos.z]).</span>", MESSAGE_HEAR)
	else if(isturf(src.loc))
		src.visible_message("\icon[src] [gpstag] beeps: <span class='danger'>Warning! SPS '[SPS.gpstag]' [reason] at [get_area(SPS)] ([pos.x-WORLD_X_OFFSET[pos.z]], [pos.y-WORLD_Y_OFFSET[pos.z]], [pos.z]).</span>")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
