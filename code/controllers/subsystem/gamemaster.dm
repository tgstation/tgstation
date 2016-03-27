var/datum/subsystem/gamemaster/SSgamemaster

/datum/subsystem/gamemaster
	name = "Game Master"
	wait = 100
	var/probability = 0
	var/first_announcement = FALSE
	var/list/z1_areas = list()
	var/list/event_list = list("bwoink", "singuloth", "el_dorado", "el_honkado", "privacy_windows", "give_guns", "ai_cameras", "ai_cameras",\
							"communism", "knockdown", "change_dir", "fakespace", "make_antag", "mecha_warfare", "clumsy", "dwarves_n_giants",\
							"investigate", "shuttle")

/datum/subsystem/gamemaster/New()
	NEW_SS_GLOBAL(SSgamemaster)

/datum/subsystem/gamemaster/Initialize()
	z1_areas = get_areas_in_z(1)
	z1_areas |= get_areas(/area/hallway/primary/port)
	..()

/datum/subsystem/gamemaster/fire()
	if(!first_announcement)
		first_announcement = TRUE
		gamemaster_announce("Let's all have fun together.")

	if(prob(probability))
		switch(pick_n_take(event_list))
			if("bwoink")
				bwoink()
			if("singuloth")
				singuloth()
			if("el_dorado")
				el_dorado()
			if("el_honkado")
				el_honkado()
			if("privacy_windows")
				privacy_windows()
			if("give_guns")
				give_guns()
			if("ai_cameras")
				ai_cameras()
			if("communism")
				communism()
			if("knockdown")
				knockdown()
			if("change_dir")
				change_dir()
			if("fakespace")
				fakespace()
			if("make_antag")
				make_antag()
			if("mecha_warfare")
				mecha_warfare()
			if("clumsy")
				clumsy()
			if("dwarves_n_giants")
				dwarves_n_giants()
			if("investigate")
				investigate()
			if("shuttle")
				shuttle()

		probability = 0
	else
		probability += 0.25

/datum/subsystem/gamemaster/proc/gamemaster_announce(text, sound = TRUE)
	var/announcement = ""
	announcement += "<h1 class='alert'>The Game Master Announces</h1>"
	announcement += "<br><span class='alert'>[text]</span><br>"
	for(var/mob/M in player_list)
		if(!istype(M,/mob/new_player) && !M.ear_deaf)
			M << announcement
			if(M.client.prefs.toggles & SOUND_ANNOUNCEMENTS)
				continue
			if(sound)
				M << sound('sound/misc/announce_dig.ogg')

/datum/subsystem/gamemaster/proc/bwoink()
	playsound_global('sound/effects/adminhelp.ogg', 0, channel=1, volume=100)
	spawn(50)
		gamemaster_announce("Why are you so nervous?")

/datum/subsystem/gamemaster/proc/singuloth()
	var/turf/T = get_turf(safepick(generic_event_spawns))
	if(!T)
		var/area/A = safepick(z1_areas)
		T = get_turf(safepick(A.contents))

	gamemaster_announce("The engineering department has started a singularity at [T.loc].")
	new /obj/singularity(T)

/datum/subsystem/gamemaster/proc/el_dorado()
	var/area/A = safepick(z1_areas)
	if(A)
		for(var/turf/T in A)
			if(T.density)
				T.ChangeTurf(/turf/simulated/wall/mineral/gold)
			else
				T.ChangeTurf(/turf/simulated/floor/mineral/gold)
			CHECK_TICK
		gamemaster_announce("The wonders of space alchemy have transformed [A] forever.")

/datum/subsystem/gamemaster/proc/el_honkado()
	var/area/A = safepick(z1_areas)
	if(A)
		for(var/turf/T in A)
			if(T.density)
				T.ChangeTurf(/turf/simulated/wall/mineral/clown)
			else
				T.ChangeTurf(/turf/simulated/floor/mineral/bananium)
			CHECK_TICK
		gamemaster_announce("The wonders of clown alchemy have transformed [A] forever.")

/datum/subsystem/gamemaster/proc/privacy_windows()
	for(var/V in z1_areas)
		var/area/A = V
		for(var/obj/structure/window/W in A)
			W.color = "#101010"
			W.opacity = 1
			CHECK_TICK
	gamemaster_announce("I turned all the windows opaque for enhanced privacy.")

/datum/subsystem/gamemaster/proc/give_guns()
	for(var/mob/living/M in player_list)
		M.put_in_hands(new /obj/item/weapon/gun/projectile/automatic/pistol/deagle(M))
	gamemaster_announce("An armed crew, is a civilized crew.")

/datum/subsystem/gamemaster/proc/ai_cameras()
	for(var/V in z1_areas)
		var/area/A = V
		for(var/obj/machinery/camera/C in A)
			C.icon = 'icons/mob/AI.dmi'
			C.icon_state = "ai-holo-old"
	gamemaster_announce("Remember crew, the AI is ever vigilant.")

/datum/subsystem/gamemaster/proc/communism()
	for(var/V in z1_areas)
		var/area/A = V
		for(var/obj/machinery/door/door in A)
			door.req_access_txt = ""
			door.req_one_access_txt = ""
			door.req_access = null
			door.req_one_access = null
			CHECK_TICK
		for(var/obj/structure/closet/closet in A)
			closet.req_access_txt = ""
			closet.req_one_access_txt = ""
			closet.req_access = null
			closet.req_one_access = null
			CHECK_TICK
	gamemaster_announce("All crew members are equal! VIVA!")

/datum/subsystem/gamemaster/proc/knockdown()
	gamemaster_announce("Buckle up!")
	spawn(50)
		for(var/mob/living/carbon/M in player_list)
			if(M.buckled)
				shake_camera(M, 2, 1) // turn it down a bit come on
			else
				shake_camera(M, 7, 1)
				if(istype(M))
					M.Weaken(3)

/datum/subsystem/gamemaster/proc/change_dir()
	var/direction = pick(SOUTH, EAST, WEST)
	for(var/client/C in clients)
		if(!(C in admins))
			C.dir = direction
	gamemaster_announce("This will take some time for you to get used to...")
	spawn(3600)
		for(var/client/C in clients)
			C.dir = NORTH

/datum/subsystem/gamemaster/proc/fakespace()
	for(var/V in z1_areas)
		var/area/A = V
		for(var/turf/simulated/floor/floor in A)
			floor.ChangeTurf(/turf/simulated/floor/fakespace)
			CHECK_TICK
	gamemaster_announce("I upgraded all the station flooring so you can marvel at the beauty of space.")

/datum/subsystem/gamemaster/proc/make_antag()
	var/list/living = list()
	for(var/mob/living/M in player_list)
		living += M
	var/mob/living/M = pick(living)
	var/antag_type = pick("Traitor", "Changeling", "Wizard", "Revolutionary", "Cultist")
	switch(antag_type)
		if("Traitor")
			M.mind.make_Traitor()
		if("Changeling")
			M.mind.make_Changling()
		if("Wizard")
			M.mind.make_Wizard()
		if("Revolutionary")
			M.mind.make_Rev()
		if("Cultist")
			M.mind.make_Cultist()
	gamemaster_announce("To spice things up, I have turned [M] into a [antag_type].")

/datum/subsystem/gamemaster/proc/mecha_warfare()
	var/list/living = list()
	for(var/mob/living/M in player_list)
		living += M
	gamemaster_announce("Some mean syndicate agents equipped with mechas are coming to kill you all.")
	spawn(200)
		gamemaster_announce("Hostile mecha pilots incoming; ETA 10 seconds. Let's balance things out.")
		sleep(20)
		for(var/mob/living/M in living)
			var/obj/mecha/combat/gygax/gygax = new(get_turf(M))
			gygax.name = "[M]'s Gygax"
			var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy(gygax)
			ME.attach(gygax)
			ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg(gygax)
			ME.attach(gygax)
			ME = new /obj/item/mecha_parts/mecha_equipment/teleporter(gygax)
			ME.attach(gygax)
			ME = new /obj/item/mecha_parts/mecha_equipment/repair_droid(gygax)
			ME.attach(gygax)
			gygax.cell = new /obj/item/weapon/stock_parts/cell/bluespace(gygax)
			CHECK_TICK
			M << "<span class='userdanger'>GET IN!</span>"
		sleep(100)
		gamemaster_announce("Hostile mechas are teleporting in!")
		var/num = max(1, abs(living.len / 10))
		var/image/I = image('icons/obj/tesla_engine/energy_ball.dmi', "energy_ball_fast", layer=FLY_LAYER)
		while(num > 0)
			num--
			var/turf/T = get_turf(safepick(generic_event_spawns))
			if(!T)
				var/area/A = safepick(z1_areas)
				T = get_turf(safepick(A.contents))
			new /mob/living/simple_animal/hostile/syndicate/mecha_pilot(T)
			flick_overlay_static(I, T, 15)

/datum/subsystem/gamemaster/proc/clumsy()
	for(var/mob/living/carbon/human/H in player_list)
		H.disabilities |= CLUMSY
		var/obj/item/clothing/mask/gas/clownmask
		if(H.gender == FEMALE)
			clownmask = new /obj/item/clothing/mask/gas/sexyclown
		else
			clownmask = new /obj/item/clothing/mask/gas/clown_hat
		clownmask.flags |= NODROP
		if(!H.unEquip(H.wear_mask))
			qdel(H.wear_mask)
		H.equip_to_slot_if_possible(clownmask, slot_wear_mask, 1, 1)
	gamemaster_announce("Honk!")


/datum/subsystem/gamemaster/proc/dwarves_n_giants()
	var/list/dwarves = player_list.Copy()
	var/list/giants = list()
	var/half = abs(dwarves.len / 2)
	while(half > 0)
		half--
		giants += pick_n_take(dwarves)

	for(var/V in dwarves)
		var/mob/M = V
		M.resize = 0.8
		M.update_transform()
		M.pass_flags |= PASSTABLE
		M << "<span class='notice'>You are now a dwarf.</span>"
	for(var/V in giants)
		var/mob/M = V
		M.resize = 1.5
		M.update_transform()
		M.pass_flags |= PASSTABLE
		M << "<span class='notice'>You are now a giant.</span>"
	gamemaster_announce("At least none of you are elves.")

/datum/subsystem/gamemaster/proc/investigate()
	var/timetowait = max(0, 5 - world.time)
	spawn(timetowait)
		var/highest = 0
		var/client/naughty
		var/current = 0
		for(var/V in player_list)
			var/mob/M = V
			current = 0
			for(var/log in M.attack_log)
				if(findtext(log, "Has attacked"))
					current++
				CHECK_TICK
			if(current > highest && M.client)
				highest = current
				naughty = M.client
		if(!naughty)
			event_list += "investigate"
			gamemaster_announce("Because you have been so nice to each other, I am rewarding all crew members.")
			for(var/V in player_list)
				var/mob/living/M = V
				if(istype(M))
					var/obj/mecha/combat/honker/loaded/honker = new(get_turf(M))
					honker.operation_req_access = list()
					CHECK_TICK
			return
		naughty << "<font color='red'>Admin PM from-<b>The Game Master</b>: Why have you been attacking so many people?</font>"
		naughty << sound('sound/effects/adminhelp.ogg')
		sleep(100)
		naughty << "<font color='red'>Admin PM from-<b>The Game Master</b>: You play in my universe normie.</font>"
		naughty << sound('sound/effects/adminhelp.ogg')
		sleep(80)
		var/mob/mob = naughty.mob
		gamemaster_announce("For breaking Rule 1 too many times, [mob.real_name] is now known as Validsalad and is valid.")
		mob.real_name = "Validsalad"

/datum/subsystem/gamemaster/proc/shuttle()
	switch(SSshuttle.emergency.mode)
		if(SHUTTLE_IDLE)
			SSshuttle.emergency.request()
			log_admin("The Game Master admin-called the emergency shuttle.")
			message_admins("<span class='adminnotice'>The Game Master admin-called the emergency shuttle.</span>")
			gamemaster_announce("I think this round is spent.")
		if(SHUTTLE_RECALL, SHUTTLE_ESCAPE)
			SSshuttle.emergency.setTimer(3000+SSshuttle.emergency.timer)
			gamemaster_announce("It seems the escape shuttle got lost.")
		if(SHUTTLE_CALL)
			SSshuttle.emergency.cancel()
			log_admin("The Game Master admin-recalled the emergency shuttle.")
			message_admins("<span class='adminnotice'>The Game Master admin-recalled the emergency shuttle.</span>")
			gamemaster_announce("You don't need to leave just yet.")
		if(SHUTTLE_DOCKED)
			SSshuttle.emergencyNoEscape = 1
			gamemaster_announce("The shuttle engines are malfunctioning. I have sent some drones to repair them.")
			spawn(100)
				var/timetowait = rand(2300+SSshuttle.emergency.timer, 4500+SSshuttle.emergency.timer)
				gamemaster_announce("ETA on those repairs is [timetowait/600] minutes. Hang in there.")
				SSshuttle.emergency.setTimer(timetowait)
				SSshuttle.emergencyNoEscape = 0

/obj/mecha/combat/honker/loaded/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/honker(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/gravcatapult(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay(src)
	ME.attach(src)