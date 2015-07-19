#define NUKESTATE_INTACT		6
#define NUKESTATE_OPEN			5
#define NUKESTATE_OPEN_TRAP		4
#define NUKESTATE_WIRES_TIED	3
#define NUKESTATE_CUT_LINES		2
#define NUKESTATE_CORE_EXPOSED	1
#define NUKESTATE_CORE_REMOVED	0

#define NUKE_OFF_LOCKED		0
#define NUKE_OFF_UNLOCKED	1
#define NUKE_ON_TIMING		2
#define NUKE_ON_EXPLODING	3

var/bomb_set

/obj/machinery/nuclearbomb
	name = "nuclear fission explosive"
	desc = "You probably shouldn't stick around to see if this is armed."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "nuclearbomb_base"
	density = 1

	var/timeleft = 60
	var/timing = 0
	var/r_code = "ADMIN"
	var/code = ""
	var/yes_code = 0
	var/safety = 1
	var/obj/item/weapon/disk/nuclear/auth = null
	use_power = 0
	var/previous_level = ""
	var/lastentered = ""
	var/obj/item/nuke_core/core = null
	var/deconstruction_state = NUKESTATE_INTACT
	var/image/lights = null
	var/image/panel = null
	var/image/interior = null
	var/image/glow = null

/obj/machinery/nuclearbomb/New()
	..()
	nuke_list += src
	core = new /obj/item/nuke_core(src)
	update_icon()
	previous_level = get_security_level()

/obj/machinery/nuclearbomb/selfdestruct
	name = "station self-destruct terminal"
	desc = "For when it all gets too much to bear. Do not taunt."
	icon = 'icons/obj/machines/bignuke.dmi'
	icon_state = "nuclearbomb_base"
	anchored = 1 //stops it being moved
	layer = 4

/obj/machinery/nuclearbomb/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/weapon/disk/nuclear))
		if(!user.drop_item())
			return
		I.loc = src
		auth = I
		add_fingerprint(user)
		return

	switch(deconstruction_state)
		if(NUKESTATE_INTACT)
			if(istype(I, /obj/item/weapon/screwdriver/nuke))
				playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
				user << "<span class='notice'>You start removing the front panel's screws...</span>"
				if(do_after(user, 100,target=src))
					deconstruction_state = NUKESTATE_OPEN
					user << "<span class='notice'>You remove the screws and the front panel slides open.</span>"
					update_icon()
				return
		if(NUKESTATE_OPEN,NUKESTATE_OPEN_TRAP)
			if((deconstruction_state == NUKESTATE_OPEN) && istype(I, /obj/item/weapon/wirecutters))
				playsound(loc, 'sound/effects/sparks4.ogg', 100, 1)
				playsound(loc, 'sound/effects/EMPulse.ogg', 100, 1)
				user << "<span class='warning'>You must have cut the wrong wire!</span>"
				for(var/mob/living/L in range(5,src))
					L.irradiate(200)
				deconstruction_state = NUKESTATE_OPEN_TRAP //cant cut wires no more
			else
				if(istype(I, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/S = I
					user << "<span class='notice'>You start tying the wires...</span>"
					if(do_after(user,30,target=src))
						if(S.use(15))
							user << "<span class='notice'>You tie the wires with some cable, clearing the insides of [src].</span>"
							deconstruction_state = NUKESTATE_WIRES_TIED
							update_icon()
						else
							user << "<span class='warning'>You need more cable to do that.</span>"
				else
					user << "<span class='warning'>You can't do anything with this tangle of cables in the way.</span>"
				return
		if(NUKESTATE_WIRES_TIED)
			if(istype(I, /obj/item/weapon/pen))
				user << "<span class='notice'>You start drawing cut lines...</span>"
				if(do_after(user,30,target=src))
					user << "<span class='notice'>You draw cut lines inside [src].</span>"
					deconstruction_state = NUKESTATE_CUT_LINES
					update_icon()
				return
		if(NUKESTATE_CUT_LINES)
			if(istype(I, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/welder = I
				playsound(loc, 'sound/items/Welder.ogg', 100, 1)
				user << "<span class='notice'>You start cutting into [src]'s warhead...</span>"
				if(welder.remove_fuel(1,user))
					if(do_after(user,50,target=src))
						playsound(loc, 'sound/items/Deconstruct.ogg', 100, 1)
						user << "<span class='notice'>You cut into [src]'s warhead. You can see the core's green glow.</span>"
						deconstruction_state = NUKESTATE_CORE_EXPOSED
						update_icon()
						SSobj.processing += core
				return
		if(NUKESTATE_CORE_EXPOSED)
			if(istype(I, /obj/item/nuke_core_container))
				var/obj/item/nuke_core_container/core_box = I
				user << "<span class='notice'>You start loading the plutonium core into [core_box]...</span>"
				if(do_after(user,50,target=src))
					if(core_box.load(core,src))
						user << "<span class='notice'>You load the plutonium core into [core_box].</span>"
						deconstruction_state = NUKESTATE_CORE_REMOVED
						update_icon()
					else
						user << "<span class='warning'>You fail to load the plutonium core into [core_box]. [core_box] has already been used!</span>"
				return
		else
			..()

/obj/machinery/nuclearbomb/proc/get_nuke_state()
	if(timing < 0)
		return NUKE_ON_EXPLODING
	if(timing > 0)
		return NUKE_ON_TIMING
	if(safety)
		return NUKE_OFF_LOCKED
	else
		return NUKE_OFF_UNLOCKED

/obj/machinery/nuclearbomb/update_icon()
	if(deconstruction_state == NUKESTATE_INTACT)
		switch(get_nuke_state())
			if(NUKE_OFF_LOCKED, NUKE_OFF_UNLOCKED)
				update_icon_interior()
				update_icon_lights()
			if(NUKE_ON_TIMING)
				overlays.Cut()
				icon_state = "nuclearbomb_timing"
			if(NUKE_ON_EXPLODING)
				overlays.Cut()
				icon_state = "nuclearbomb_exploding"
	else
		update_icon_interior()
		update_icon_lights()

/obj/machinery/nuclearbomb/proc/update_icon_interior()
	overlays -= interior
	overlays -= glow
	switch(deconstruction_state)
		if(NUKESTATE_OPEN_TRAP,NUKESTATE_OPEN)
			glow = null
			interior = image(icon,"panel-removed")
		if(NUKESTATE_CORE_REMOVED,NUKESTATE_CUT_LINES,NUKESTATE_WIRES_TIED)
			glow = null
			interior = image(icon,"wires-sorted")
		if(NUKESTATE_CORE_EXPOSED)
			glow = image(icon,"core-exposed")
			interior = image(icon,"wires-sorted")
		if(NUKESTATE_INTACT)
			glow = null
			interior = image(icon,"panel-overlay")
	overlays += interior
	overlays += glow

/obj/machinery/nuclearbomb/proc/update_icon_lights()
	overlays -= lights
	overlays -= panel
	panel = null
	switch(get_nuke_state())
		if(NUKE_OFF_LOCKED)
			lights = image(icon,"lights-off")
			if(deconstruction_state != NUKESTATE_INTACT)
				panel = image(icon,"panel-removed-blue")
		if(NUKE_OFF_UNLOCKED)
			lights = image(icon,"lights-safety")
			if(deconstruction_state != NUKESTATE_INTACT)
				panel = image(icon,"panel-removed-blue")
		if(NUKE_ON_TIMING)
			lights = image(icon,"lights-timing")
			if(deconstruction_state != NUKESTATE_INTACT)
				panel = image(icon,"panel-removed-timing")
		if(NUKE_ON_EXPLODING)
			lights = image(icon,"lights-exploding")
			if(deconstruction_state != NUKESTATE_INTACT)
				panel = image(icon,"panel-removed-exploding")
	overlays += lights
	overlays += panel

/obj/machinery/nuclearbomb/process()
	if (timing > 0)
		bomb_set = 1 //So long as there is one nuke timing, it means one nuke is armed.
		timeleft--
		if (timeleft <= 0)
			explode()
		else
			var/volume = (timeleft <= 20 ? 30 : 5)
			playsound(loc, 'sound/items/timer.ogg', volume, 0)
		for(var/mob/M in viewers(1, src))
			if ((M.client && M.machine == src))
				attack_hand(M)
	return

/obj/machinery/nuclearbomb/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/nuclearbomb/attack_ai(mob/user)
	return

/obj/machinery/nuclearbomb/attack_hand(mob/user)
	user.set_machine(src)
	var/dat = text("<TT>\nAuth. Disk: <A href='?src=\ref[];auth=1'>[]</A><HR>", src, (auth ? "++++++++++" : "----------"))
	if (auth)
		if (yes_code)
			dat += text("\n<B>Status</B>: []-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] <A href='?src=\ref[];timer=1'>Toggle</A><BR>\nTime: <A href='?src=\ref[];time=-10'>-</A> <A href='?src=\ref[];time=-1'>-</A> [] <A href='?src=\ref[];time=1'>+</A> <A href='?src=\ref[];time=10'>+</A><BR>\n<BR>\nSafety: [] <A href='?src=\ref[];safety=1'>Toggle</A><BR>\nAnchor: [] <A href='?src=\ref[];anchor=1'>Toggle</A><BR>\n", (timing ? "Func/Set" : "Functional"), (safety ? "Safe" : "Engaged"), timeleft, (timing ? "On" : "Off"), src, src, src, timeleft, src, src, (safety ? "On" : "Off"), src, (anchored ? "Engaged" : "Off"), src)
		else
			dat += text("\n<B>Status</B>: Auth. S2-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] Toggle<BR>\nTime: - - [] + +<BR>\n<BR>\n[] Safety: Toggle<BR>\nAnchor: [] Toggle<BR>\n", (safety ? "Safe" : "Engaged"), timeleft, (timing ? "On" : "Off"), timeleft, (safety ? "On" : "Off"), (anchored ? "Engaged" : "Off"))
	else
		if (timing)
			dat += text("\n<B>Status</B>: Set-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] Toggle<BR>\nTime: - - [] + +<BR>\n<BR>\nSafety: [] Toggle<BR>\nAnchor: [] Toggle<BR>\n", (safety ? "Safe" : "Engaged"), timeleft, (timing ? "On" : "Off"), timeleft, (safety ? "On" : "Off"), (anchored ? "Engaged" : "Off"))
		else
			dat += text("\n<B>Status</B>: Auth. S1-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] Toggle<BR>\nTime: - - [] + +<BR>\n<BR>\nSafety: [] Toggle<BR>\nAnchor: [] Toggle<BR>\n", (safety ? "Safe" : "Engaged"), timeleft, (timing ? "On" : "Off"), timeleft, (safety ? "On" : "Off"), (anchored ? "Engaged" : "Off"))
	var/message = "AUTH"
	if (auth)
		message = text("[]", code)
		if (yes_code)
			message = "*****"
	dat += text("<HR>\n>[]<BR>\n<A href='?src=\ref[];type=1'>1</A><A href='?src=\ref[];type=2'>2</A><A href='?src=\ref[];type=3'>3</A><BR>\n<A href='?src=\ref[];type=4'>4</A><A href='?src=\ref[];type=5'>5</A><A href='?src=\ref[];type=6'>6</A><BR>\n<A href='?src=\ref[];type=7'>7</A><A href='?src=\ref[];type=8'>8</A><A href='?src=\ref[];type=9'>9</A><BR>\n<A href='?src=\ref[];type=R'>R</A><A href='?src=\ref[];type=0'>0</A><A href='?src=\ref[];type=E'>E</A><BR>\n</TT>", message, src, src, src, src, src, src, src, src, src, src, src, src)
	var/datum/browser/popup = new(user, "nuclearbomb", name, 300, 400)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/nuclearbomb/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	if (href_list["auth"])
		if (auth)
			auth.loc = loc
			yes_code = 0
			auth = null
		else
			var/obj/item/I = usr.get_active_hand()
			if (istype(I, /obj/item/weapon/disk/nuclear))
				usr.drop_item()
				I.loc = src
				auth = I
	if (auth)
		if (href_list["type"])
			if (href_list["type"] == "E")
				if (code == r_code)
					yes_code = 1
					code = null
				else
					code = "ERROR"
			else
				if (href_list["type"] == "R")
					yes_code = 0
					code = null
				else
					lastentered = text("[]", href_list["type"])
					if (text2num(lastentered) == null)
						var/turf/LOC = get_turf(usr)
						message_admins("[key_name_admin(usr)] (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[usr]'>FLW</A>) tried to exploit a nuclear bomb by entering non-numerical codes: <a href='?_src_=vars;Vars=\ref[src]'>[lastentered]</a> ! ([LOC ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[LOC.x];Y=[LOC.y];Z=[LOC.z]'>JMP</a>" : "null"])", 0)
						log_admin("EXPLOIT : [key_name(usr)] tried to exploit a nuclear bomb by entering non-numerical codes: [lastentered] !")
					else
						code += lastentered
						if (length(code) > 5)
							code = "ERROR"
		if (yes_code)
			if (href_list["time"])
				var/time = text2num(href_list["time"])
				timeleft += time
				timeleft = min(max(round(timeleft), 60), 600)
			if (href_list["timer"])
				set_active()
			if (href_list["safety"])
				set_safety()
			if (href_list["anchor"])
				set_anchor()
	add_fingerprint(usr)
	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			attack_hand(M)

/obj/machinery/nuclearbomb/proc/set_anchor()
	if(!isinspace())
		anchored = !anchored
	else
		usr << "<span class='warning'>There is nothing to anchor to!</span>"

/obj/machinery/nuclearbomb/proc/set_safety()
	safety = !safety
	if(safety)
		timing = 0
		bomb_set = 0
		set_security_level(previous_level)
	update_icon()

/obj/machinery/nuclearbomb/proc/set_active()
	if(safety)
		usr << "<span class='danger'>The safety is still on.</span>"
		return
	timing = !timing
	previous_level = get_security_level()
	if(timing)
		bomb_set = 1
		set_security_level("delta")
	else
		bomb_set = 0
		set_security_level(previous_level)
	update_icon()

/obj/machinery/nuclearbomb/ex_act(severity, target)
	return

/obj/machinery/nuclearbomb/blob_act()
	if (timing == -1.0)
		return
	else
		return ..()
	return


#define NUKERANGE 80
/obj/machinery/nuclearbomb/proc/explode()
	if (safety)
		timing = 0
		return

	timing = -1
	yes_code = 0
	safety = 1
	update_icon()
	for(var/mob/M in player_list)
		M << 'sound/machines/Alarm.ogg'
	if (ticker && ticker.mode)
		ticker.mode.explosion_in_progress = 1
	sleep(100)

	if(!core)
		ticker.station_explosion_cinematic(3,"no_core")
		ticker.mode.explosion_in_progress = 0
		return

	enter_allowed = 0

	var/off_station = 0
	var/turf/bomb_location = get_turf(src)
	if( bomb_location && (bomb_location.z == ZLEVEL_STATION) )
		if( (bomb_location.x < (128-NUKERANGE)) || (bomb_location.x > (128+NUKERANGE)) || (bomb_location.y < (128-NUKERANGE)) || (bomb_location.y > (128+NUKERANGE)) )
			off_station = 1
	else
		off_station = 2

	if(ticker.mode && ticker.mode.name == "nuclear emergency")
		var/obj/docking_port/mobile/Shuttle = SSshuttle.getShuttle("syndicate")
		ticker.mode:syndies_didnt_escape = (Shuttle && Shuttle.z == ZLEVEL_CENTCOM) ? 0 : 1
		ticker.mode:nuke_off_station = off_station
	ticker.station_explosion_cinematic(off_station,null)
	if(ticker.mode)
		ticker.mode.explosion_in_progress = 0
		if(ticker.mode.name == "nuclear emergency")
			ticker.mode:nukes_left --
		else
			world << "<B>The station was destoyed by the nuclear blast!</B>"
		ticker.mode.station_was_nuked = (off_station<2)	//offstation==1 is a draw. the station becomes irradiated and needs to be evacuated.
														//kinda shit but I couldn't  get permission to do what I wanted to do.
		if(!ticker.mode.check_finished())//If the mode does not deal with the nuke going off so just reboot because everyone is stuck as is
			world.Reboot("Station destroyed by Nuclear Device.", "end_error", "nuke - unhandled ending")
			return
	return


/*
This is here to make the tiles around the station mininuke change when it's armed.
*/

/obj/machinery/nuclearbomb/selfdestruct/proc/SetTurfs()
	if(loc == initial(loc))
		for(var/turf/simulated/floor/bluegrid/T in orange(src, 1))
			T.icon_state = (timing ? "rcircuitanim" : "gcircuit")

/obj/machinery/nuclearbomb/selfdestruct/set_anchor()
	return

/obj/machinery/nuclearbomb/selfdestruct/set_active()
	..()
	SetTurfs()

//==========DAT FUKKEN DISK===============
/obj/item/weapon/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon = 'icons/obj/items.dmi'
	icon_state = "nucleardisk"
	item_state = "card-id"
	w_class = 1.0

/obj/item/weapon/disk/nuclear/New()
	..()
	SSobj.processing |= src

/obj/item/weapon/disk/nuclear/process()
	var/turf/disk_loc = get_turf(src)
	if(disk_loc.z > ZLEVEL_CENTCOM)
		get(src, /mob) << "<span class='danger'>You can't help but feel that you just lost something back there...</span>"
		qdel(src)

/obj/item/weapon/disk/nuclear/Destroy()
	if(blobstart.len > 0)
		var/obj/item/weapon/disk/nuclear/NEWDISK = new(pick(blobstart))
		transfer_fingerprints_to(NEWDISK)
		var/turf/diskturf = get_turf(src)
		message_admins("[src] has been destroyed in ([diskturf.x], [diskturf.y] ,[diskturf.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[diskturf.x];Y=[diskturf.y];Z=[diskturf.z]'>JMP</a>). Moving it to ([NEWDISK.x], [NEWDISK.y], [NEWDISK.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[NEWDISK.x];Y=[NEWDISK.y];Z=[NEWDISK.z]'>JMP</a>).")
		log_game("[src] has been destroyed in ([diskturf.x], [diskturf.y] ,[diskturf.z]). Moving it to ([NEWDISK.x], [NEWDISK.y], [NEWDISK.z]).")
		return QDEL_HINT_HARDDEL_NOW
	else
		ERROR("[src] was supposed to be destroyed, but we were unable to locate a blobstart landmark to spawn a new one.")
	return QDEL_HINT_LETMELIVE // Cancel destruction.
