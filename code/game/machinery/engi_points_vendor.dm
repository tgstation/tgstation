// Construction "nuke"


/obj/machinery/construction_nuke
	name = "nuclear fission construction device"
	desc = "The next level of interior redecoration."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "nuclearbomb0"
	density = TRUE

	var/timer_set = 90
	var/ui_style = "nanotrasen"
	var/range = 160

	var/timing = FALSE
	var/detonation_timer = null
	var/cooldown = 0
	var/safety = TRUE
	use_power = 0

	var/bomb_set = FALSE
	var/exploding = FALSE
	var/quiet = FALSE
	var/payload = "plasteel"
	var/payload_wall = /turf/closed/wall/r_wall
	var/payload_floor = /turf/open/floor/engine
	var/static/list/possible_payloads = list("wood","sand","ice","mining","silver","gold","bananium","abductor","desolation", "plasma","uranium","bluespace","diamond","plasteel","safety","titanium","plastitanium", )

/obj/machinery/nuclearbomb/Initialize()
	..()
	poi_list |= src

/obj/machinery/nuclearbomb/examine(mob/user)
	. = ..()
	if(timing)
		to_chat(user, "There are [get_time_left()] seconds until detonation.")

/obj/machinery/construction_nuke/process()
	if(timing)
		bomb_set = TRUE
		if(detonation_timer < world.time && !exploding)
			explode()
			qdel(src)
		else
			switch(get_time_left())
				if (30 to 3600)
					playsound(loc, 'sound/items/timer.ogg', 5, 0)
				if (15 to 29)
					playsound(loc, 'sound/items/timer.ogg', 30, 0)
				if (0 to 14)
					icon_state = "nuclearbomb3"
					quiet  = !quiet
					if(!quiet)
						return
					else
						playsound(loc, 'sound/machines/engine_alert2.ogg', 100, 0)

/obj/machinery/construction_nuke/interact(mob/user)
	user.set_machine(src)
	var/list/dat = list()
	dat +="<div class='statusDisplay'>"
	dat += "Timer: [get_time_left()] seconds<br>"
	dat += "</div>"
	dat += "<b><u>Detonation Payload</u>: <A href='?src=\ref[src];action=payload'>[payload]</A></b><br><br>"
	dat += "<A href='?src=\ref[src];action=set'>Set Timer</A><br>"
	dat += "<A href='?src=\ref[src];action=anchor'>[anchored ? "Anchored" : "Not Anchored"]</A><br>"
	dat += "<A href='?src=\ref[src];action=safety'>[safety ? "Safety On" : "Safety Off"]</A><br><br>"
	dat += "<b><A href='?src=\ref[src];action=activate'>[bomb_set ? "DEACTIVATE" : "ACTIVATE"]</A><b><br>"
	var/datum/browser/popup = new(user, "vending", "Construction Nuke", 300, 275)
	popup.set_content(dat.Join())
	popup.open()


/obj/machinery/construction_nuke/Topic(href, href_list)
	if(..())
		return
	switch(href_list["action"])
		if ("payload")
			set_payload()
			updateUsrDialog()
		if ("set")
			set_timer()
			updateUsrDialog()
		if ("anchor")
			set_anchor()
			updateUsrDialog()
		if ("safety")
			set_safety()
			updateUsrDialog()
		if ("activate")
			set_active()
			updateUsrDialog()

/obj/machinery/construction_nuke/proc/set_payload()
	playsound(loc, 'sound/machines/terminal_prompt.ogg', 75, 1)
	if(timing || bomb_set)
		to_chat(usr, "<span class='danger'>Error: Payload cannot be altered while the device is armed.</span>")
		playsound(loc, 'sound/machines/defib_failed.ogg', 75, 1)
		return
	payload = input(usr, "Choose your Payload", "Payload:") as null|anything in possible_payloads
	if (!src || QDELETED(src))
		return
	playsound(loc, 'sound/machines/terminal_prompt_confirm.ogg', 75, 1)
	switch(payload)
		if("plasteel")
			payload_wall = /turf/closed/wall/r_wall
			payload_floor = /turf/open/floor/engine
		if("wood")
			payload_wall = /turf/closed/wall/mineral/wood
			payload_floor = /turf/open/floor/wood
		if("sand")
			payload_wall = /turf/closed/wall/mineral/sandstone
			payload_floor = /turf/open/floor/plating/beach/sand
		if("ice")
			payload_wall = /turf/closed/wall/ice
			payload_floor = /turf/open/floor/plating/ice
		if("mining")
			payload_wall = /turf/closed/wall/shuttle/survival/pod
			payload_floor = /turf/open/floor/plating/asteroid/basalt/lava
		if("desolation")
			payload_wall = /turf/closed/wall/rust
			payload_floor = /turf/open/floor/fakespace
		if("bluespace")
			payload_wall = /turf/closed/wall/mineral/titanium
			payload_floor = /turf/open/floor/bluespace
		if("safety")
			payload_wall = /turf/closed/wall/r_wall
			payload_floor = /turf/open/floor/noslip
		if("bananium")
			payload_wall = /turf/closed/wall/mineral/clown
			payload_floor = /turf/open/floor/mineral/bananium
		else
			payload_wall = text2path("/turf/closed/wall/mineral/[payload]")
			payload_floor = text2path("/turf/open/floor/mineral/[payload]")


/obj/machinery/construction_nuke/proc/set_timer()
	playsound(loc, 'sound/machines/terminal_prompt.ogg', 75, 1)
	timer_set = input("Set timer in seconds:", name, timer_set)
	if (!src || QDELETED(src))
		return
	playsound(loc, 'sound/machines/terminal_prompt_confirm.ogg', 75, 1)
	if(timer_set < 90)
		timer_set = 90
	if(timer_set > 300)
		timer_set = 300

/obj/machinery/construction_nuke/proc/set_anchor()
	if(timing || !safety)
		to_chat(usr, "<span class='warning'>Cannot remove anchors while the safety is off!</span>")
		return
	if(!isinspace())
		anchored = !anchored
		playsound(loc, 'sound/items/Deconstruct.ogg', 75, 1)
		icon_state = "nuclearbomb2"
	else
		to_chat(usr, "<span class='warning'>There is nothing to anchor to!</span>")
/obj/machinery/construction_nuke/proc/set_safety()
	if(!anchored)
		to_chat(usr, "<span class='danger'>Error: Safety cannot be altered on an unanchored device.</span>")
		playsound(loc, 'sound/machines/defib_failed.ogg', 75, 1)
		return
	safety = !safety
	if(safety)
		if(timing)
			priority_announce("Radioactive energy levels are normalizing, please submit an incident report as soon as possible.","Central Command Nuclear Safety Division", 'sound/AI/attention.ogg')
		timing = FALSE
		bomb_set = FALSE
		detonation_timer = null
		icon_state = "nuclearbomb2"
		playsound(loc, 'sound/machines/terminal_prompt.ogg', 75, 1)
	else
		playsound(loc, 'sound/machines/engine_alert1.ogg', 50, 1)
		icon_state = "nuclearbomb1"
	update_icon()

/obj/machinery/construction_nuke/proc/set_active()
	var/area/A = get_area(src)
	if(safety && !bomb_set)
		to_chat(usr, "<span class='danger'>Error: The safety is still on.</span>")
		playsound(loc, 'sound/machines/defib_failed.ogg', 75, 1)
		return
	if(!A.blob_allowed)
		to_chat(usr, "<span class='danger'>Error: The device's safety countermeasures flash red: you cannot arm this device outside of the station.</span>")
		playsound(loc, 'sound/machines/defib_failed.ogg', 75, 1)
		return
	timing = !timing
	if(timing)
		if(cooldown > world.time)
			to_chat(usr, "<span class='danger'>Error: The device is still resetting from the last activation, it will be ready again in [round((cooldown-world.time)/10)] seconds.</span>")
			playsound(loc, 'sound/machines/defib_failed.ogg', 75, 1)
			timing = FALSE
			return
		bomb_set = TRUE
		priority_announce("We are detecting a massive spike of radioactive energy from \a [payload] payload originating from [A.map_name]. If this is not a scheduled occurrence, please investigate immediately.","Nanotrasen Nuclear Safety Division", 'sound/misc/airraid.ogg')
		cooldown = world.time + 1200
		detonation_timer = world.time + (timer_set * 10)
		icon_state = "nuclearbombc"
	else
		bomb_set = FALSE
		priority_announce("Radioactive energy levels are normalizing, please submit an incident report as soon as possible.","Central Command Nuclear Safety Division", 'sound/AI/attention.ogg')
		detonation_timer = null
		icon_state = "nuclearbomb1"
		playsound(loc, 'sound/machines/terminal_off.ogg', 75, 1)
	update_icon()

/obj/machinery/construction_nuke/proc/get_time_left()
	if(timing)
		. = round(max(0, detonation_timer - world.time) / 10, 1)
	else
		. = timer_set

/obj/machinery/construction_nuke/proc/explode()
	if(safety || !bomb_set)
		timing = FALSE
		return
	exploding = TRUE
	update_icon()
	for(var/mob/M in player_list)
		M << 'sound/machines/Alarm.ogg'
	var/turf/startpoint = get_turf(src)
	sleep(100)
	for(var/mob/M in player_list)
		M << 'sound/effects/explosionfar.ogg'
	spawn_atom_to_turf(/obj/effect/overlay/temp/explosion, startpoint, 1, FALSE)
	qdel(src)
	for(var/I in spiral_range_turfs(range, startpoint))
		var/turf/T = I
		if(!T)
			continue
		if(istype(T, /turf/open/floor/))
			T.ChangeTurf(payload_floor)
			spawn_atom_to_turf(/obj/effect/overlay/temp/fire, T, 1, FALSE)
		else if(istype(T, /turf/closed/wall/))
			T.ChangeTurf(payload_wall)
			spawn_atom_to_turf(/obj/effect/overlay/temp/fire, T, 1, FALSE)
		CHECK_TICK



// DISCO BALL



/obj/machinery/disco
	name = "Radiant Dance Machine Mark IV"
	desc = "The first three prototypes were discontinued after mass casualty incidents."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "disco0"
	density = TRUE
	anchored = FALSE
	verb_say = "states"
	density = TRUE
	req_access = list(access_engine)
	var/active = FALSE
	var/list/rangers = list()
	var/list/listeners = list()
	var/charge = 35
	var/stop = 0
	var/list/available = list()
	var/list/select_name = list()
	req_access = list(access_engine)
	var/list/spotlights = list()
	var/list/sparkles = list()
	var/static/list/songs = list(
		new /datum/track("Engineering's Basic Beat", 					'sound/misc/disco.ogg', 	600, 	5),
		new /datum/track("Engineering's Domination Dance", 				'sound/misc/e1m1.ogg', 		950, 	6),
		new /datum/track("Engineering's Superiority Shimmy", 			'sound/misc/Paradox.ogg', 	2400, 	3),
		new /datum/track("Engineering's Ultimate High-Energy Hustle",	'sound/misc/boogie2.ogg',	1770, 	5),
		)
	var/datum/track/selection = null

/datum/track
	var/song_name = "generic"
	var/song_path = null
	var/song_length = 0
	var/song_beat = 0

/datum/track/New(name, path, length, beat)
	song_name = name
	song_path = path
	song_length = length
	song_beat = beat

/obj/machinery/disco/Initialize()
	selection = songs[1]


/obj/machinery/disco/Destroy()
	dance_over()
	return ..()

/obj/machinery/disco/attackby(obj/item/O, mob/user, params)
	if(!active)
		if(istype(O, /obj/item/weapon/wrench))
			if(!anchored && !isinspace())
				user << "<span class='notice'>You secure the [src] to the floor.</span>"
				anchored = TRUE
			else if(anchored)
				user << "<span class='notice'>You unsecure and disconnect the [src].</span>"
				anchored = FALSE
			playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
			return
	return ..()


/obj/machinery/disco/interact(mob/user)
	if (!anchored)
		user << "<span class='warning'>This device must be anchored by a wrench!</span>"
		return
	if(!allowed(user))
		user << "<span class='warning'>You are overwhelmed by the raw amount of data being displayed, only an engineer could operate such a sophisticated device.</span>"
		playsound(src, 'sound/misc/compiler-failure.ogg', 50, 1)
		return
	if(!Adjacent(user))
		if(!isAI(user))
			return
	user.set_machine(src)
	var/list/dat = list()
	dat +="<div class='statusDisplay' style='text-align:center'>"
	dat += "<b><A href='?src=\ref[src];action=toggle'>[!active ? "BREAK IT DOWN" : "SHUT IT DOWN"]<b></A><br>"
	dat += "</div><br>"
	dat += "<A href='?src=\ref[src];action=select'> Select Track</A><br>"
	dat += "Track Selected: [selection.song_name]<br>"
	dat += "Track Length: [selection.song_length/10] seconds<br><br>"
	dat += "<i>More songs can be unlocked by earning more IEV points</i><br>"
	dat += "<br>DJ's Soundboard:<b><br>"
	dat +="<div class='statusDisplay'><div style='text-align:center'>"
	dat += "<A href='?src=\ref[src];action=horn'>Air Horn</A>  "
	dat += "<A href='?src=\ref[src];action=alert'>Station Alert</A>  "
	dat += "<A href='?src=\ref[src];action=siren'>Warning Siren</A>  "
	dat += "<A href='?src=\ref[src];action=honk'>Honk</A><br>"
	dat += "<A href='?src=\ref[src];action=pump'>Shotgun Pump</A>"
	dat += "<A href='?src=\ref[src];action=pop'>Gunshot</A>"
	dat += "<A href='?src=\ref[src];action=saber'>Esword</A>"
	dat += "<A href='?src=\ref[src];action=harm'>Harm Alarm</A>"
	var/datum/browser/popup = new(user, "vending", "Radiance Dance Machine - Mark IV", 400, 350)
	popup.set_content(dat.Join())
	popup.open()


/obj/machinery/disco/Topic(href, href_list)
	if(..())
		return
	add_fingerprint(usr)
	switch(href_list["action"])
		if("toggle")
			if (!src || QDELETED(src))
				return
			if(!active)
				if(stop > world.time)
					to_chat(usr, "<span class='warning'>Error: The device is still resetting from the last activation, it will be ready again in [round((stop-world.time)/10)] seconds.</span>")
					playsound(src, 'sound/misc/compiler-failure.ogg', 50, 1)
					return
				active = TRUE
				icon_state = "disco1"
				dance_setup()
				START_PROCESSING(SSobj, src)
				lights_spin()
				src.updateUsrDialog()
			else if(active)
				active = FALSE
				STOP_PROCESSING(SSobj, src)
				icon_state = "disco0"
				dance_over()
				stop = world.time + 300
				src.updateUsrDialog()
		if("select")
			if(active)
				to_chat(usr, "<span class='warning'>Error: You cannot change the song until the current one is over.</span>")
				return
			check_GBP()
			select_name = input(usr, "Choose your song", "Track:") as null|anything in available
			if (!src || QDELETED(src))
				return
			for(var/datum/track/S in songs)
				if(select_name == S.song_name)
					selection = S
					break
			src.updateUsrDialog()
		if("horn")
			deejay('sound/items/AirHorn2.ogg')
		if("alert")
			deejay('sound/misc/notice1.ogg')
		if("siren")
			deejay('sound/machines/engine_alert1.ogg')
		if("honk")
			deejay('sound/items/bikehorn.ogg')
		if("pump")
			deejay('sound/weapons/shotgunpump.ogg')
		if("pop")
			deejay('sound/weapons/Gunshot3.ogg')
		if("saber")
			deejay('sound/weapons/saberon.ogg')
		if("harm")
			deejay('sound/AI/harmalarm.ogg')

/obj/machinery/disco/proc/deejay(var/S)
	if (!src || QDELETED(src) || !active || charge < 5)
		to_chat(usr, "<span class='warning'>The device is not able to play more DJ sounds at this time.</span>")
		return
	charge -= 5
	playsound(src, S,300,1)

/obj/machinery/disco/proc/check_GBP()
	available |= "Engineering's Basic Beat"
	available |= "Engineering's Domination Dance"
	available |= "Engineering's Superiority Shimmy"
	available |= "Engineering's Ultimate High-Energy Hustle"
/*	var/point_total = 0
	available.Cut()
	for(var/obj/machinery/engi_points_manager/EPM in machines)
		point_total = EPM.GBPearned
		break
	for(var/i in 1 to min(songs.len,round((point_total+10000)/10000)))
		var/datum/track/S = songs[i]
		available += S.song_name
*/

/obj/machinery/disco/proc/dance_setup()
	stop = world.time + selection.song_length
	var/turf/cen = get_turf(src)
	for(var/turf/t in view(src,3))
		if(t.x == cen.x && t.y > cen.y)
			var/obj/item/device/flashlight/spotlight/L = new /obj/item/device/flashlight/spotlight(t)
			L.light_color = "red"
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1+get_dist(src, L)
			spotlights+=L
			continue
		if(t.x == cen.x && t.y < cen.y)
			var/obj/item/device/flashlight/spotlight/L = new /obj/item/device/flashlight/spotlight(t)
			L.light_color = "purple"
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1+get_dist(src, L)
			spotlights+=L
			continue
		if(t.x > cen.x && t.y == cen.y)
			var/obj/item/device/flashlight/spotlight/L = new /obj/item/device/flashlight/spotlight(t)
			L.light_color = "#ffff00"
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1+get_dist(src, L)
			spotlights+=L
			continue
		if(t.x < cen.x && t.y == cen.y)
			var/obj/item/device/flashlight/spotlight/L = new /obj/item/device/flashlight/spotlight(t)
			L.light_color = "green"
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1+get_dist(src, L)
			spotlights+=L
			continue
		if((t.x+1 == cen.x && t.y+1 == cen.y) || (t.x+2==cen.x && t.y+2 == cen.y))
			var/obj/item/device/flashlight/spotlight/L = new /obj/item/device/flashlight/spotlight(t)
			L.light_color = "sw"
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1.4+get_dist(src, L)
			spotlights+=L
			continue
		if((t.x-1 == cen.x && t.y-1 == cen.y) || (t.x-2==cen.x && t.y-2 == cen.y))
			var/obj/item/device/flashlight/spotlight/L = new /obj/item/device/flashlight/spotlight(t)
			L.light_color = "ne"
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1.4+get_dist(src, L)
			spotlights+=L
			continue
		if((t.x-1 == cen.x && t.y+1 == cen.y) || (t.x-2==cen.x && t.y+2 == cen.y))
			var/obj/item/device/flashlight/spotlight/L = new /obj/item/device/flashlight/spotlight(t)
			L.light_color = "se"
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1.4+get_dist(src, L)
			spotlights+=L
			continue
		if((t.x+1 == cen.x && t.y-1 == cen.y) || (t.x+2==cen.x && t.y-2 == cen.y))
			var/obj/item/device/flashlight/spotlight/L = new /obj/item/device/flashlight/spotlight(t)
			L.light_color = "nw"
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1.4+get_dist(src, L)
			spotlights+=L
			continue
		continue

/obj/machinery/disco/proc/hierofunk()
	for(var/i in 1 to 10)
		spawn_atom_to_turf(/obj/effect/overlay/temp/hierophant/telegraph/edge, src, 1, FALSE)
		sleep(5)

/obj/machinery/disco/proc/lights_spin()
	for(var/i in 1 to 25)
		if(!src || QDELETED(src) || !active)
			return
		var/obj/effect/overlay/sparkles/S = new /obj/effect/overlay/sparkles(src)
		S.alpha = 0
		sparkles += S
		switch(i)
			if(1 to 8)
				S.orbit(src, 30, TRUE, 60, 36, TRUE, FALSE)
			if(9 to 16)
				S.orbit(src, 62, TRUE, 60, 36, TRUE, FALSE)
			if(17 to 24)
				S.orbit(src, 95, TRUE, 60, 36, TRUE, FALSE)
			if(25)
				S.pixel_y = 7
				S.loc = get_turf(src)
		sleep(7)
	for(var/obj/reveal in sparkles)
		reveal.alpha = 255
	while(active)
		for(var/obj/item/device/flashlight/spotlight/glow in spotlights) // The multiples reflects custom adjustments to each colors after dozens of tests
			if(!src || QDELETED(src) || !active || !glow || QDELETED(glow))
				return
			if(glow.light_color == "red")
				glow.light_color = "nw"
				glow.light_power = glow.light_power * 1.48
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == "nw")
				glow.light_color = "green"
				glow.light_range = glow.range * 1.1
				glow.light_power = glow.light_power * 2 // Any changes to power must come in pairs to neutralize it for other colors
				glow.update_light()
				continue
			if(glow.light_color == "green")
				glow.light_color = "sw"
				glow.light_power = glow.light_power * 0.5
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == "sw")
				glow.light_color = "purple"
				glow.light_power = glow.light_power * 2.27
				glow.light_range = glow.range * 1.15
				glow.update_light()
				continue
			if(glow.light_color == "purple")
				glow.light_color = "se"
				glow.light_power = glow.light_power * 0.44
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == "se")
				glow.light_color = "#ffff00"
				glow.light_range = glow.range * 0.9
				glow.update_light()
				continue
			if(glow.light_color == "#ffff00")
				glow.light_color = "ne"
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == "ne")
				glow.light_color = "red"
				glow.light_power = glow.light_power * 0.68
				glow.light_range = glow.range * 0.85
				glow.update_light()
				continue
		if(prob(2))
			INVOKE_ASYNC(src, .proc/hierofunk)
		sleep(selection.song_beat)


/obj/machinery/disco/proc/dance(var/mob/living/carbon/M) //Show your moves
	switch(rand(0,9))
		if(0 to 1)
			set waitfor = 0
			for(var/i = 1, i < 8, i++)
				M.SpinAnimation(7,1)
				M.setDir(pick(cardinal))
				sleep(10)
		if(2 to 3)
			set waitfor = 0
			for(var/i in 1 to 6)
				if (!M)
					return
				M.SpinAnimation(7,1)
				M.setDir(pick(cardinal))
				for (var/x in 1 to 12)
					sleep(1)
					if (!M)
						return
					if (i<5)
						M.pixel_y += 1
					if (i>4)
						M.pixel_y -= 2
					M.setDir(turn(M.dir, 90))
					switch (M.dir)
						if (NORTH)
							M.pixel_y += 3
						if (SOUTH)
							M.pixel_y -= 3
						if (EAST)
							M.pixel_x -= 3
						if (WEST)
							M.pixel_x += 3
				sleep(12)
			M.pixel_x = 0
			M.pixel_y = 0
		if(4 to 6)
			var/speed = rand(1,3)
			set waitfor = 0
			var/time = 30
			while(time)
				sleep(speed)
				for(var/i in 1 to speed)
					M.setDir(pick(cardinal))
					M.lay_down(TRUE)
				 time--

		if(7 to 9)
			M.setDir(get_dir(M, src))
			spawn (0)
				if (M)
					animate(M, transform = matrix(180, MATRIX_ROTATE), time = 1, loop = 0)
				sleep (70)
				if (M)
					animate(M, transform = null, time = 1, loop = 0)
			for (var/i = 0, i < 60, i++)
				if (!M)
					return
				if (i<31)
					M.pixel_y += 1
				if (i>30)
					M.pixel_y -= 1
				M.setDir(turn(M.dir, 90))
				switch (M.dir)
					if (NORTH)
						M.pixel_y += 3
					if (SOUTH)
						M.pixel_y -= 3
					if (EAST)
						M.pixel_x -= 3
					if (WEST)
						M.pixel_x += 3
				sleep (1)
			M.pixel_x = 0
			M.pixel_y = 0

/obj/machinery/disco/proc/dance_over()
	for(var/obj/item/device/flashlight/spotlight/SL in spotlights)
		qdel(SL)
	spotlights.Cut()
	for(var/obj/effect/overlay/sparkles/SP in sparkles)
		qdel(SP)
	sparkles.Cut()
	rangers.Cut()
	for(var/mob/living/L in listeners)
		if(!L || !L.client)
			continue
		L.client.stop_client_sounds()
	listeners.Cut()


/obj/machinery/disco/process()
	if(charge<35)
		charge += 1
	if(world.time < stop && active)
		rangers = list()
		for(var/mob/living/M in range(9,src))
			rangers += M
			if(!(M in listeners))
				M << selection.song_path
				listeners += M
			if(prob(4+(allowed(M)*4)))
				dance(M)
		for(var/mob/living/L in listeners)
			if(!(L in rangers))
				listeners -= L
				if(!L || !L.client)
					continue
				L.client.stop_client_sounds()

	else if(active)
		STOP_PROCESSING(SSobj, src)
		dance_over()
		playsound(src,'sound/machines/terminal_off.ogg',50,1)
		active = FALSE
		icon_state = "disco0"
