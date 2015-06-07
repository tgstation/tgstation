var/bomb_set

/obj/machinery/nuclearbomb
	name = "nuclear fission explosive"
	desc = "You probably shouldn't stick around to see if this is armed."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nuclearbomb0"
	density = 1

	var/timeleft = 60.0
	var/timing = 0
	var/r_code = "ADMIN"
	var/code = ""
	var/yes_code = 0
	var/safety = 1
	var/obj/item/weapon/disk/nuclear/auth = null
	use_power = 0
	var/previous_level = ""
	var/lastentered = ""
	var/immobile = 0 //Not all nukes should be moved
	var/obj/item/nuke_core/core = null
	var/construction_state = 6

/obj/machinery/nuclearbomb/selfdestruct
	name = "station self-destruct terminal"
	desc = "For when it all gets too much to bear. Do not taunt."
	icon = 'icons/obj/machines/bignuke.dmi'
	icon_state = "nuclearbomb_base"
	anchored = 1 //stops it being moved
	immobile = 1 //prevents it from ever being moved
	layer = 4
	var/icon/lights = null
	var/icon/panel = null
	var/icon/interior = null
	var/icon/glow = null

/obj/machinery/nuclearbomb/selfdestruct/New()
	core = new /obj/item/nuke_core(src)
	lights = new /icon(icon,"lights-off")
	panel = new /icon(icon,"panel-overlay")
	overlays += lights
	overlays += panel
	..()

/obj/machinery/nuclearbomb/selfdestruct/attackby(obj/item/I, mob/user, params)
	switch(construction_state)
		if(6)
			if(istype(I, /obj/item/weapon/screwdriver/nuke))
				playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
				user << "<span class='notice'>You start removing the front panel's screws...</span>"
				if(do_after(user, 100))
					construction_state = 5
					user << "<span class='notice'>You remove the screws and the front panel slides open.</span>"
					update_icon()
				return
		if(4,5)
			if((construction_state == 5) && istype(I, /obj/item/weapon/wirecutters))
				playsound(loc, 'sound/effects/sparks4.ogg', 100, 1)
				playsound(loc, 'sound/effects/EMPulse.ogg', 100, 1)
				user << "<span class='warning'>You must have cut the wrong wire!</span>"
				for(var/mob/living/L in range(5,src))
					L.irradiate(200)
				construction_state = 4 //cant cut wires no more
			else
				if(istype(I, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/S = I
					user << "<span class='notice'>You start tying the uncountable wires...</span>"
					if(do_after(user,30))
						if(S.use(15))
							user << "<span class='notice'>You tie the uncountable wires with some cable, clearing the insides of [src].</span>"
							construction_state = 3
							update_icon()
						else
							user << "<span class='warning'>You need more cable to do that.</span>"
					return
				if(istype(I, /obj/item/weapon/restraints/handcuffs/cable))
					user << "<span class='notice'>You start tying the uncountable wires...</span>"
					if(do_after(user,30))
						if(user.drop_item())
							qdel(I)
							user << "<span class='notice'>You tie the uncountable wires with the [I], clearing the insides of [src].</span>"
							construction_state = 3
							update_icon()
					return
		if(3)
			if(istype(I, /obj/item/weapon/pen))
				user << "<span class='notice'>You start drawing cut lines...</span>"
				if(do_after(user,30))
					user << "<span class='notice'>You draw cut lines inside [src].</span>"
					construction_state = 2
					update_icon()
				return
			if(istype(I, /obj/item/toy/crayon))
				var/obj/item/toy/crayon/cray = I
				user << "<span class='notice'>You start drawing cut lines...</span>"
				if(do_after(user,30))
					if(cray.uses != 0)
						user << "<span class='notice'>You draw cut lines inside [src].</span>"
						cray.uses = cray.uses < 0 ? cray.uses : cray.uses - 1
						construction_state = 2
						update_icon()
				return
			if(istype(I, /obj/item/weapon/lipstick))
				user << "<span class='notice'>You start drawing cut lines...</span>"
				var/obj/item/weapon/lipstick/lipstick = I
				if(lipstick.open)
					if(do_after(user,30))
						user << "<span class='notice'>You draw cut lines inside [src].</span>"
						construction_state = 2
						update_icon()
				else
					user << "<span class='warning'>You can't draw with the lipstick closed!</span>"
				return
		if(2)
			if(istype(I, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/welder = I
				playsound(loc, 'sound/items/Welder.ogg', 100, 1)
				user << "<span class='notice'>You start cutting into [src]'s warhead...</span>"
				if(welder.remove_fuel(1,user))
					if(do_after(user,50))
						playsound(loc, 'sound/items/Deconstruct.ogg', 100, 1)
						user << "<span class='notice'>You cut into [src]'s warhead. You can see the core's green glow.</span>"
						construction_state = 1
						update_icon()
						SSobj.processing += core
				return
		if(1)
			if(istype(I, /obj/item/nuke_core_container))
				var/obj/item/nuke_core_container/core_box = I
				user << "<span class='notice'>You start loading the plutonium core into [core_box]...</span>"
				if(do_after(user,50))
					user << "<span class='notice'>You load the plutonium core into [core_box].</span>"
					core_box.load(core)
					construction_state = 0
					update_icon()
				return
		else
			..()

/obj/machinery/nuclearbomb/proc/get_nuke_state()
	if(timing < 0)
		return "exploding"
	if(timing > 0)
		return "timing"
	if(safety)
		return "locked"
	else
		return "unlocked"

/obj/machinery/nuclearbomb/selfdestruct/update_icon()
	if(construction_state == 6)
		switch(get_nuke_state())
			if("locked", "unlocked")
				update_icon_interior()
				update_icon_lights()
			if("timing")
				overlays.Cut()
				icon_state = "nuclearbomb_timing"
			if("exploding")
				overlays.Cut()
				icon_state = "nuclearbomb_exploding"
	else
		update_icon_interior()
		update_icon_lights()

/obj/machinery/nuclearbomb/selfdestruct/proc/update_icon_interior()
	overlays -= interior
	overlays -= glow
	switch(construction_state)
		if(4,5)
			glow = null
			interior = new /icon(icon,"panel-removed")
		if(0,2,3)
			glow = null
			interior = new /icon(icon,"wires-sorted")
		if(1)
			glow = new /icon(icon,"core-exposed")
			interior = new /icon(icon,"wires-sorted")
		if(6)
			glow = null
			interior = new /icon(icon,"panel-overlay")
	overlays += interior
	overlays += glow

/obj/machinery/nuclearbomb/selfdestruct/proc/update_icon_lights()
	overlays -= lights
	overlays -= panel
	panel = null
	switch(get_nuke_state())
		if("locked")
			lights = new /icon(icon,"lights-off")
			if(construction_state != 6)
				panel = new /icon(icon,"panel-removed-blue")
		if("unlocked")
			lights = new /icon(icon,"lights-safety")
			if(construction_state != 6)
				panel = new /icon(icon,"panel-removed-blue")
		if("timing")
			lights = new /icon(icon,"lights-timing")
			if(construction_state != 6)
				panel = new /icon(icon,"panel-removed-timing")
		if("exploding")
			lights = new /icon(icon,"lights-exploding")
			if(construction_state != 6)
				panel = new /icon(icon,"panel-removed-exploding")
	overlays += lights
	overlays += panel

/obj/machinery/nuclearbomb/process()
	if (timing)
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

/obj/machinery/nuclearbomb/attackby(obj/item/I as obj, mob/user as mob, params)
	if (istype(I, /obj/item/weapon/disk/nuclear))
		usr.drop_item()
		I.loc = src
		auth = I
		add_fingerprint(user)
		return
	..()

/obj/machinery/nuclearbomb/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/nuclearbomb/attack_ai(mob/user as mob)
	return

/obj/machinery/nuclearbomb/attack_hand(mob/user as mob)
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
						message_admins("[key_name_admin(usr)] tried to exploit a nuclear bomb by entering non-numerical codes: <a href='?_src_=vars;Vars=\ref[src]'>[lastentered]</a> ! ([LOC ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[LOC.x];Y=[LOC.y];Z=[LOC.z]'>JMP</a>" : "null"])", 0)
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
				if (timing == -1.0)
					return
				if (safety)
					usr << "<span class='danger'>The safety is still on.</span>"
					return
				timing = !( timing )
				if (timing)
					if(!safety)
						bomb_set = 1//There can still be issues with this reseting when there are multiple bombs. Not a big deal tho for Nuke/N
						previous_level = "[get_security_level()]"
						set_security_level("delta")
						update_icon()
					else
						bomb_set = 0
						set_security_level("[previous_level]")
						update_icon()
				else
					update_icon()
					bomb_set = 0
					set_security_level("[previous_level]")
			if (href_list["safety"])
				safety = !safety
				if(safety)
					timing = 0
					bomb_set = 0
					update_icon()
				else
					update_icon()
			if (href_list["anchor"])
				if(!isinspace()&&(!immobile))
					anchored = !( anchored )
				else if(immobile)
					usr << "<span class='warning'>This device is immovable!</span>"
				else
					usr << "<span class='warning'>There is nothing to anchor to!</span>"
	add_fingerprint(usr)
	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			attack_hand(M)


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
	timing = -1.0
	yes_code = 0
	safety = 1
	update_icon("exploding")
	for(var/mob/M in player_list)
		M << 'sound/machines/Alarm.ogg'
	if (ticker && ticker.mode)
		ticker.mode.explosion_in_progress = 1
	sleep(100)

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

/obj/machinery/nuclearbomb/selfdestruct/explode()
	if(core)
		..()
	else
		timing = -1
		yes_code = 0
		safety = 1
		update_icon("exploding")

/*
This is here to make the tiles around the station mininuke change when it's armed.
*/

/obj/machinery/nuclearbomb/selfdestruct/proc/SetTurfs()
	if(loc == initial(loc))
		var/text_icon_state = "[timing ? "rcircuitanim" : "gcircuit"]"
		for(var/turf/simulated/floor/bluegrid/T in orange(src, 1))
			T.icon_state = text_icon_state

/obj/machinery/nuclearbomb/selfdestruct/Topic()
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
