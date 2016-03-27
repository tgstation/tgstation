var/datum/subsystem/gamemaster/SSgamemaster

/datum/subsystem/gamemaster
	name = "Game Master"
	wait = 100
	var/probability = 0
	var/probability_increment = 1
	var/first_announcement = FALSE
	var/list/event_list = list()
	var/list/z1_areas = list("bwoink", "singuloth", "el_dorado", "el_honkado", "privacy_windows", "give_guns", "ai_cameras", "ai_cameras",\
							"communism", "knockdown", "change_dir", "fakespace", "make_antag", "mecha_warfare", "clumsy", "dwarves_n_giants")

/datum/subsystem/gamemaster/New()
	NEW_SS_GLOBAL(SSgamemaster)

/datum/subsystem/gamemaster/Initialize()
	z1_areas = get_areas_in_z(1)
	..()

/datum/subsystem/gamemaster/fire()
	if(!first_announcement)
		first_announcement = TRUE
		gamemaster_announce("I CALL GM!")

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
		probability = 0
		probability_increment /= 2
	else
		probability += probability_increment

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
	for(var/V in player_list)
		var/mob/M = V
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
	var/mob/M = pick(player_list)
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
	gamemaster_announce("Some mean syndicate agents equipped with mechas are coming to kill you all.")
	spawn(30)
		gamemaster_announce("Hostile mecha pilots incoming; ETA 10 seconds. Let's balance things out.")
		for(var/V in player_list)
			var/mob/M = V
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
			M << "<span class='userdanger'>GET IN!</span>"
		sleep(100)
		gamemaster_announce("Hostile mechas are teleporting in!")
		var/num = abs(player_list / 10)
		var/image/I = image('icons/obj/tesla_engine/energy_ball.dmi', "energy_ball_fast", layer=FLY_LAYER)
		while(num)
			num--
			var/turf/T = get_turf(safepick(generic_event_spawns))
			if(!T)
				var/area/A = safepick(z1_areas)
				T = get_turf(safepick(A.contents))
			new /mob/living/simple_animal/hostile/syndicate/mecha_pilot(T)
			flick_overlay_static(I, T, 15)

/datum/subsystem/gamemaster/proc/clumsy()
	for(var/V in player_list)
		var/mob/living/carbon/human/H = V
		if(istype(H))
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
	for(var/V in giants)
		var/mob/M = V
		M.resize = 1.5
		M.update_transform()
		M.pass_flags |= PASSTABLE
	gamemaster_announce("At least none of you are elves.")