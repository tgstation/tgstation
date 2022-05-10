#define HAL_LINES_FILE "hallucination.json"

/mob/living/proc/set_screwyhud(hud_type)
	hal_screwyhud = hud_type
	update_health_hud()

/*
/obj/effect/hallucination/simple/clown
	image_icon = 'icons/mob/animal.dmi'
	image_state = "clown"

/obj/effect/hallucination/simple/clown/Initialize(mapload, mob/living/carbon/T, duration)
	..(loc, T)
	name = pick(GLOB.clown_names)
	QDEL_IN(src,duration)

/obj/effect/hallucination/simple/clown/scary
	image_state = "scary_clown"
*/

/datum/hallucination/delusion
	var/list/image/delusions = list()

/datum/hallucination/delusion/New(mob/living/carbon/C, forced, force_kind = null , duration = 300,skip_nearby = TRUE, custom_icon = null, custom_icon_file = null, custom_name = null)
	set waitfor = FALSE
	. = ..()
	var/image/A = null
	var/kind = force_kind ? force_kind : pick("nothing","monkey","corgi","carp","skeleton","demon","zombie")
	feedback_details += "Type: [kind]"
	var/list/nearby
	if(skip_nearby)
		nearby = get_hearers_in_view(7, hallucinator)
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(H == hallucinator)
			continue
		if(skip_nearby && (H in nearby))
			continue
		switch(kind)
			if("nothing")
				A = image('icons/effects/effects.dmi',H,"nothing")
				A.name = "..."
			if("monkey")//Monkey
				A = image('icons/mob/human.dmi',H,"monkey")
				A.name = "Monkey ([rand(1,999)])"
			if("carp")//Carp
				A = image('icons/mob/carp.dmi',H,"carp")
				A.name = "Space Carp"
			if("corgi")//Corgi
				A = image('icons/mob/pets.dmi',H,"corgi")
				A.name = "Corgi"
			if("skeleton")//Skeletons
				A = image('icons/mob/human.dmi',H,"skeleton")
				A.name = "Skeleton"
			if("zombie")//Zombies
				A = image('icons/mob/human.dmi',H,"zombie")
				A.name = "Zombie"
			if("demon")//Demon
				A = image('icons/mob/mob.dmi',H,"daemon")
				A.name = "Demon"
			if("custom")
				A = image(custom_icon_file, H, custom_icon)
				A.name = custom_name
		A.override = 1
		if(hallucinator.client)
			delusions |= A
			hallucinator.client.images |= A
	if(duration)
		QDEL_IN(src, duration)

/datum/hallucination/delusion/Destroy()
	for(var/image/I in delusions)
		if(hallucinator.client)
			hallucinator.client.images.Remove(I)
	return ..()

/datum/hallucination/self_delusion
	var/image/delusion

/datum/hallucination/self_delusion/New(mob/living/carbon/C, forced, force_kind = null , duration = 300, custom_icon = null, custom_icon_file = null, wabbajack = TRUE) //set wabbajack to false if you want to use another fake source
	set waitfor = FALSE
	..()
	var/image/A = null
	var/kind = force_kind ? force_kind : pick("monkey","corgi","carp","skeleton","demon","zombie","robot")
	feedback_details += "Type: [kind]"
	switch(kind)
		if("monkey")//Monkey
			A = image('icons/mob/human.dmi',hallucinator,"monkey")
		if("carp")//Carp
			A = image('icons/mob/animal.dmi',hallucinator,"carp")
		if("corgi")//Corgi
			A = image('icons/mob/pets.dmi',hallucinator,"corgi")
		if("skeleton")//Skeletons
			A = image('icons/mob/human.dmi',hallucinator,"skeleton")
		if("zombie")//Zombies
			A = image('icons/mob/human.dmi',hallucinator,"zombie")
		if("demon")//Demon
			A = image('icons/mob/mob.dmi',hallucinator,"daemon")
		if("robot")//Cyborg
			A = image('icons/mob/robots.dmi',hallucinator,"robot")
			hallucinator.playsound_local(hallucinator,'sound/voice/liveagain.ogg', 75, 1)
		if("custom")
			A = image(custom_icon_file, hallucinator, custom_icon)
	A.override = 1
	if(hallucinator.client)
		if(wabbajack)
			to_chat(hallucinator, span_hear("...wabbajack...wabbajack..."))
			hallucinator.playsound_local(hallucinator,'sound/magic/staff_change.ogg', 50, 1)
		delusion = A
		hallucinator.client.images |= A
	QDEL_IN(src, duration)

/datum/hallucination/self_delusion/Destroy()
	if(hallucinator.client)
		hallucinator.client.images.Remove(delusion)
	return ..()

/datum/hallucination/bolts
	var/list/airlocks_to_hit
	var/list/locks
	var/next_action = 0
	var/locking = TRUE

/datum/hallucination/bolts/New(mob/living/carbon/C, forced, door_number)
	set waitfor = FALSE
	..()
	if(!door_number)
		door_number = rand(0,4) //if 0 bolts all visible doors
	var/count = 0
	feedback_details += "Door amount: [door_number]"

	for(var/obj/machinery/door/airlock/A in range(7, hallucinator))
		if(count>door_number && door_number>0)
			break
		if(!A.density)
			continue
		count++
		LAZYADD(airlocks_to_hit, A)

	if(!LAZYLEN(airlocks_to_hit)) //no valid airlocks in sight
		qdel(src)
		return

	START_PROCESSING(SSfastprocess, src)

/datum/hallucination/bolts/process(delta_time)
	next_action -= (delta_time * 10)
	if (next_action > 0)
		return

	if (locking)
		var/atom/next_airlock = pop(airlocks_to_hit)
		if (next_airlock)
			var/obj/effect/hallucination/fake_door_lock/lock = new(get_turf(next_airlock))
			lock.target = target
			lock.airlock = next_airlock
			LAZYADD(locks, lock)

		if (!LAZYLEN(airlocks_to_hit))
			locking = FALSE
			next_action = 10 SECONDS
			return
	else
		var/obj/effect/hallucination/fake_door_lock/next_unlock = popleft(locks)
		if (next_unlock)
			next_unlock.unlock()
		else
			qdel(src)
			return

	next_action = rand(4, 12)

/datum/hallucination/bolts/Destroy()
	. = ..()
	QDEL_LIST(locks)
	STOP_PROCESSING(SSfastprocess, src)

/obj/effect/hallucination/fake_door_lock
	layer = CLOSED_DOOR_LAYER + 1 //for Bump priority
	plane = GAME_PLANE
	var/image/bolt_light
	var/obj/machinery/door/airlock/airlock

/obj/effect/hallucination/fake_door_lock/proc/lock()
	bolt_light = image(airlock.overlays_file, get_turf(airlock), "lights_bolts",layer=airlock.layer+0.1)
	if(hallucinator.client)
		hallucinator.client.images |= bolt_light
		hallucinator.playsound_local(get_turf(airlock), 'sound/machines/boltsdown.ogg',30,0,3)

/obj/effect/hallucination/fake_door_lock/proc/unlock()
	if(hallucinator.client)
		hallucinator.client.images.Remove(bolt_light)
		hallucinator.playsound_local(get_turf(airlock), 'sound/machines/boltsup.ogg',30,0,3)
	qdel(src)

/obj/effect/hallucination/fake_door_lock/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(mover == target && airlock.density)
		return FALSE

/datum/hallucination/chat

/datum/hallucination/chat/New(mob/living/carbon/C, forced = TRUE, force_radio = FALSE, specific_message)
	set waitfor = FALSE
	..()
	var/target_name = hallucinator.first_name()
	var/speak_messages = list("[pick_list_replacements(HAL_LINES_FILE, "suspicion")]",\
		"[pick_list_replacements(HAL_LINES_FILE, "conversation")]",\
		"[pick_list_replacements(HAL_LINES_FILE, "greetings")][hallucinator.first_name()]!",\
		"[pick_list_replacements(HAL_LINES_FILE, "getout")]",\
		"[pick_list_replacements(HAL_LINES_FILE, "weird")]",\
		"[pick_list_replacements(HAL_LINES_FILE, "didyouhearthat")]",\
		"[pick_list_replacements(HAL_LINES_FILE, "doubt")]",\
		"[pick_list_replacements(HAL_LINES_FILE, "aggressive")]",\
		"[pick_list_replacements(HAL_LINES_FILE, "help")]!!",\
		"[pick_list_replacements(HAL_LINES_FILE, "escape")]",\
		"I'm infected, [pick_list_replacements(HAL_LINES_FILE, "infection_advice")]!")

	var/radio_messages = list("[pick_list_replacements(HAL_LINES_FILE, "people")] is [pick_list_replacements(HAL_LINES_FILE, "accusations")]!",\
		"Help!",\
		"[pick_list_replacements(HAL_LINES_FILE, "threat")] in [pick_list_replacements(HAL_LINES_FILE, "location")][prob(50)?"!":"!!"]",\
		"[pick("Where's [hallucinator.first_name()]?", "Set [hallucinator.first_name()] to arrest!")]",\
		"[pick("C","Ai, c","Someone c","Rec")]all the shuttle!",\
		"AI [pick("rogue", "is dead")]!!")

	var/mob/living/carbon/person = null
	var/datum/language/understood_language = hallucinator.get_random_understood_language()
	for(var/mob/living/carbon/H in view(hallucinator))
		if(H == hallucinator)
			continue
		if(!person)
			person = H
		else
			if(get_dist(hallucinator,H)<get_dist(hallucinator,person))
				person = H

	// Get person to affect if radio hallucination
	var/is_radio = !person || force_radio
	if (is_radio)
		var/list/humans = list()
		for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
			humans += H
		person = pick(humans)

	// Generate message
	var/spans = list(person.speech_span)
	var/chosen = specific_message || capitalize(pick(is_radio ? speak_messages : radio_messages))
	chosen = replacetext(chosen, "%TARGETNAME%", target_name)
	var/message = hallucinator.compose_message(person, understood_language, chosen, is_radio ? "[FREQ_COMMON]" : null, spans, face_name = TRUE)
	feedback_details += "Type: [is_radio ? "Radio" : "Talk"], Source: [person.real_name], Message: [message]"

	// Display message
	if (!is_radio && !hallucinator.client?.prefs.read_preference(/datum/preference/toggle/enable_runechat))
		var/image/speech_overlay = image('icons/mob/talk.dmi', person, "default0", layer = ABOVE_MOB_LAYER)
		INVOKE_ASYNC(GLOBAL_PROC, /proc/flick_overlay, speech_overlay, list(hallucinator.client), 30)
	if (hallucinator.client?.prefs.read_preference(/datum/preference/toggle/enable_runechat))
		hallucinator.create_chat_message(person, understood_language, chosen, spans)
	to_chat(hallucinator, message)
	qdel(src)

/datum/hallucination/message

/datum/hallucination/message/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	var/list/mobpool = list()
	var/mob/living/carbon/human/other
	var/close_other = FALSE
	for(var/mob/living/carbon/human/H in oview(hallucinator, 7))
		if(get_dist(H, hallucinator) <= 1)
			other = H
			close_other = TRUE
			break
		mobpool += H
	if(!other && mobpool.len)
		other = pick(mobpool)

	var/list/message_pool = list()
	if(other)
		if(close_other) //increase the odds
			for(var/i in 1 to 5)
				message_pool.Add(span_warning("You feel a tiny prick!"))
		var/obj/item/storage/equipped_backpack = other.get_item_by_slot(ITEM_SLOT_BACK)
		if(istype(equipped_backpack))
			for(var/i in 1 to 5) //increase the odds
				message_pool.Add("<span class='notice'>[other] puts the [pick(\
					"revolver","energy sword","cryptographic sequencer","power sink","energy bow",\
					"hybrid taser","stun baton","flash","syringe gun","circular saw","tank transfer valve",\
					"ritual dagger","spellbook",\
					"Codex Cicatrix", "Living Heart",\
					"pulse rifle","captain's spare ID","hand teleporter","hypospray","antique laser gun","X-01 MultiPhase Energy Gun","station's blueprints"\
					)] into [equipped_backpack].</span>")

		message_pool.Add("<B>[other]</B> [pick("sneezes","coughs")].")

	message_pool.Add(span_notice("You hear something squeezing through the ducts..."), \
		span_notice("Your [pick("arm", "leg", "back", "head")] itches."),\
		span_warning("You feel [pick("hot","cold","dry","wet","woozy","faint")]."),
		span_warning("Your stomach rumbles."),
		span_warning("Your head hurts."),
		span_warning("You hear a faint buzz in your head."),
		"<B>[target]</B> sneezes.")
	if(prob(10))
		message_pool.Add(span_warning("Behind you."),\
			span_warning("You hear a faint laughter."),
			span_warning("You see something move."),
			span_warning("You hear skittering on the ceiling."),
			span_warning("You see an inhumanly tall silhouette moving in the distance."))
	if(prob(10))
		message_pool.Add("[pick_list_replacements(HAL_LINES_FILE, "advice")]")
	var/chosen = pick(message_pool)
	feedback_details += "Message: [chosen]"
	to_chat(hallucinator, chosen)
	qdel(src)

/datum/hallucination/sounds

/datum/hallucination/sounds/New(mob/living/carbon/C, forced = TRUE, sound_type)
	set waitfor = FALSE
	..()
	var/turf/source = random_far_turf()
	if(!sound_type)
		sound_type = pick("airlock","airlock pry","console","explosion","far explosion","mech","glass","alarm","beepsky","mech","wall decon","door hack")
	feedback_details += "Type: [sound_type]"
	//Strange audio
	switch(sound_type)
		if("airlock")
			hallucinator.playsound_local(source,'sound/machines/airlock.ogg', 30, 1)
		if("airlock pry")
			hallucinator.playsound_local(source,'sound/machines/airlock_alien_prying.ogg', 100, 1)
			addtimer(CALLBACK(hallucinator, /mob/.proc/playsound_local, source, 'sound/machines/airlockforced.ogg', 30, 1), 50)
		if("console")
			hallucinator.playsound_local(source,'sound/machines/terminal_prompt.ogg', 25, 1)
		if("explosion")
			if(prob(50))
				hallucinator.playsound_local(source,'sound/effects/explosion1.ogg', 50, 1)
			else
				hallucinator.playsound_local(source, 'sound/effects/explosion2.ogg', 50, 1)
		if("far explosion")
			hallucinator.playsound_local(source, 'sound/effects/explosionfar.ogg', 50, 1)
		if("glass")
			hallucinator.playsound_local(source, pick('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg'), 50, 1)
		if("alarm")
			hallucinator.playsound_local(source, 'sound/machines/alarm.ogg', 100, 0)
		if("beepsky")
			hallucinator.playsound_local(source, 'sound/voice/beepsky/freeze.ogg', 35, 0)
		if("mech")
			hallucinator.cause_hallucination(/datum/hallucination/mech_sounds, source = "fake sounds hallucination")
		//Deconstructing a wall
		if("wall decon")
			hallucinator.playsound_local(source, 'sound/items/welder.ogg', 50, 1)
			addtimer(CALLBACK(hallucinator, /mob/.proc/playsound_local, source, 'sound/items/welder2.ogg', 50, 1), 105)
			addtimer(CALLBACK(hallucinator, /mob/.proc/playsound_local, source, 'sound/items/ratchet.ogg', 50, 1), 120)
		//Hacking a door
		if("door hack")
			hallucinator.playsound_local(source, 'sound/items/screwdriver.ogg', 50, 1)
			addtimer(CALLBACK(hallucinator, /mob/.proc/playsound_local, source, 'sound/machines/airlockforced.ogg', 30, 1), rand(40, 80))
	qdel(src)

/datum/hallucination/mech_sounds
	var/mech_dir
	var/steps_left
	var/next_action = 0
	var/turf/source

/datum/hallucination/mech_sounds/New()
	. = ..()
	mech_dir = pick(GLOB.cardinals)
	steps_left = rand(4, 9)
	source = random_far_turf()
	START_PROCESSING(SSfastprocess, src)

/datum/hallucination/mech_sounds/process(delta_time)
	next_action -= delta_time
	if (next_action > 0)
		return

	if(prob(75))
		hallucinator.playsound_local(source, 'sound/mecha/mechstep.ogg', 40, 1)
		source = get_step(source, mech_dir)
	else
		hallucinator.playsound_local(source, 'sound/mecha/mechturn.ogg', 40, 1)
		mech_dir = pick(GLOB.cardinals)

	steps_left -= 1
	if (!steps_left)
		qdel(src)
		return
	next_action = 1

/datum/hallucination/mech_sounds/Destroy()
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)

/datum/hallucination/weird_sounds

/datum/hallucination/weird_sounds/New(mob/living/carbon/C, forced = TRUE, sound_type)
	set waitfor = FALSE
	..()
	var/turf/source = random_far_turf()
	if(!sound_type)
		sound_type = pick("phone","hallelujah","highlander","laughter","hyperspace","game over","creepy","tesla")
	feedback_details += "Type: [sound_type]"
	//Strange audio
	switch(sound_type)
		if("phone")
			hallucinator.playsound_local(source, 'sound/weapons/ring.ogg', 15)
			for (var/next_rings in 1 to 3)
				addtimer(CALLBACK(hallucinator, /mob/.proc/playsound_local, source, 'sound/weapons/ring.ogg', 15), 25 * next_rings)
		if("hyperspace")
			hallucinator.playsound_local(null, 'sound/runtime/hyperspace/hyperspace_begin.ogg', 50)
		if("hallelujah")
			hallucinator.playsound_local(source, 'sound/effects/pray_chaplain.ogg', 50)
		if("highlander")
			hallucinator.playsound_local(null, 'sound/misc/highlander.ogg', 50)
		if("game over")
			hallucinator.playsound_local(source, 'sound/misc/compiler-failure.ogg', 50)
		if("laughter")
			if(prob(50))
				hallucinator.playsound_local(source, 'sound/voice/human/womanlaugh.ogg', 50, 1)
			else
				hallucinator.playsound_local(source, pick('sound/voice/human/manlaugh1.ogg', 'sound/voice/human/manlaugh2.ogg'), 50, 1)
		if("creepy")
		//These sounds are (mostly) taken from Hidden: Source
			hallucinator.playsound_local(source, pick(GLOB.creepy_ambience), 50, 1)
		if("tesla") //Tesla loose!
			hallucinator.playsound_local(source, 'sound/magic/lightningbolt.ogg', 35, 1)
			addtimer(CALLBACK(hallucinator, /mob/.proc/playsound_local, source, 'sound/magic/lightningbolt.ogg', 65, 1), 30)
			addtimer(CALLBACK(hallucinator, /mob/.proc/playsound_local, source, 'sound/magic/lightningbolt.ogg', 100, 1), 60)

	qdel(src)

/datum/hallucination/stationmessage

/datum/hallucination/stationmessage/New(mob/living/carbon/C, forced = TRUE, message)
	set waitfor = FALSE
	..()
	if(!message)
		message = pick("ratvar","shuttle dock","blob alert","malf ai","meteors","supermatter")
	feedback_details += "Type: [message]"
	switch(message)
		if("blob alert")
			to_chat(hallucinator, "<h1 class='alert'>Biohazard Alert</h1>")
			to_chat(hallucinator, "<br><br>[span_alert("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.")]<br><br>")
			SEND_SOUND(hallucinator,  SSstation.announcer.event_sounds[ANNOUNCER_OUTBREAK5])
		if("ratvar")
			hallucinator.playsound_local(hallucinator, 'sound/machines/clockcult/ark_deathrattle.ogg', 50, FALSE, pressure_affected = FALSE)
			hallucinator.playsound_local(hallucinator, 'sound/effects/clockcult_gateway_disrupted.ogg', 50, FALSE, pressure_affected = FALSE)
			addtimer(CALLBACK(
				hallucinator,
				/mob/.proc/playsound_local,
				hallucinator,
				'sound/effects/explosion_distant.ogg',
				50,
				FALSE,
				/* frequency = */ null,
				/* falloff_exponential = */ null,
				/* channel = */ null,
				/* pressure_affected = */ FALSE
			), 27)
		if("shuttle dock")
			to_chat(hallucinator, "<h1 class='alert'>Priority Announcement</h1>")
			to_chat(hallucinator, "<br><br>[span_alert("The Emergency Shuttle has docked with the station. You have 3 minutes to board the Emergency Shuttle.")]<br><br>")
			SEND_SOUND(hallucinator, SSstation.announcer.event_sounds[ANNOUNCER_SHUTTLEDOCK])
		if("malf ai") //AI is doomsdaying!
			to_chat(hallucinator, "<h1 class='alert'>Anomaly Alert</h1>")
			to_chat(hallucinator, "<br><br>[span_alert("Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.")]<br><br>")
			SEND_SOUND(hallucinator, SSstation.announcer.event_sounds[ANNOUNCER_AIMALF])
		if("meteors") //Meteors inbound!
			to_chat(hallucinator, "<h1 class='alert'>Meteor Alert</h1>")
			to_chat(hallucinator, "<br><br>[span_alert("Meteors have been detected on collision course with the station.")]<br><br>")
			SEND_SOUND(hallucinator, SSstation.announcer.event_sounds[ANNOUNCER_METEORS])
		if("supermatter")
			SEND_SOUND(hallucinator, 'sound/magic/charge.ogg')
			to_chat(hallucinator, span_boldannounce("You feel reality distort for a moment..."))

/datum/hallucination/hudscrew

/datum/hallucination/hudscrew/New(mob/living/carbon/C, forced = TRUE, screwyhud_type)
	set waitfor = FALSE
	..()
	//Screwy HUD
	var/chosen_screwyhud = screwyhud_type
	if(!chosen_screwyhud)
		chosen_screwyhud = pick(SCREWYHUD_CRIT,SCREWYHUD_DEAD,SCREWYHUD_HEALTHY)
	hallucinator.set_screwyhud(chosen_screwyhud)
	feedback_details += "Type: [hallucinator.hal_screwyhud]"
	QDEL_IN(src, rand(100, 250))

/datum/hallucination/hudscrew/Destroy()
	hallucinator.set_screwyhud(SCREWYHUD_NONE)
	return ..()

/datum/hallucination/items/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	//Strange items

	var/obj/halitem = new

	halitem = new
	var/obj/item/l_hand = hallucinator.get_item_for_held_index(1)
	var/obj/item/r_hand = hallucinator.get_item_for_held_index(2)
	var/l = ui_hand_position(hallucinator.get_held_index_of_item(l_hand))
	var/r = ui_hand_position(hallucinator.get_held_index_of_item(r_hand))
	var/list/slots_free = list(l,r)
	if(l_hand)
		slots_free -= l
	if(r_hand)
		slots_free -= r
	if(ishuman(hallucinator))
		var/mob/living/carbon/human/H = target
		if(!H.belt)
			slots_free += ui_belt
		if(!H.l_store)
			slots_free += ui_storage1
		if(!H.r_store)
			slots_free += ui_storage2
	if(slots_free.len)
		halitem.screen_loc = pick(slots_free)
		halitem.plane = ABOVE_HUD_PLANE
		switch(rand(1,6))
			if(1) //revolver
				halitem.icon = 'icons/obj/guns/ballistic.dmi'
				halitem.icon_state = "revolver"
				halitem.name = "Revolver"
			if(2) //c4
				halitem.icon = 'icons/obj/grenade.dmi'
				halitem.icon_state = "plastic-explosive0"
				halitem.name = "C4"
				if(prob(25))
					halitem.icon_state = "plasticx40"
			if(3) //sword
				halitem.icon = 'icons/obj/transforming_energy.dmi'
				halitem.icon_state = "e_sword"
				halitem.name = "energy sword"
			if(4) //stun baton
				halitem.icon = 'icons/obj/items_and_weapons.dmi'
				halitem.icon_state = "stunbaton"
				halitem.name = "Stun Baton"
			if(5) //emag
				halitem.icon = 'icons/obj/card.dmi'
				halitem.icon_state = "emag"
				halitem.name = "Cryptographic Sequencer"
			if(6) //flashbang
				halitem.icon = 'icons/obj/grenade.dmi'
				halitem.icon_state = "flashbang1"
				halitem.name = "Flashbang"
		feedback_details += "Type: [halitem.name]"
		if(hallucinator.client)
			hallucinator.client.screen += halitem
		QDEL_IN(halitem, rand(150, 350))

	qdel(src)

/datum/hallucination/dangerflash

/datum/hallucination/dangerflash/New(mob/living/carbon/C, forced = TRUE, danger_type)
	set waitfor = FALSE
	..()
	//Flashes of danger

	var/list/possible_points = list()
	for(var/turf/open/floor/F in view(hallucinator,world.view))
		possible_points += F
	if(possible_points.len)
		var/turf/open/floor/danger_point = pick(possible_points)
		if(!danger_type)
			danger_type = pick("lava","chasm","anomaly")
		switch(danger_type)
			if("lava")
				new /obj/effect/hallucination/danger/lava(danger_point, hallucinator)
			if("chasm")
				new /obj/effect/hallucination/danger/chasm(danger_point, hallucinator)
			if("anomaly")
				new /obj/effect/hallucination/danger/anomaly(danger_point, hallucinator)

	qdel(src)

/obj/effect/hallucination/danger
	var/image/image

/obj/effect/hallucination/danger/proc/show_icon()
	return

/obj/effect/hallucination/danger/proc/clear_icon()
	if(image && hallucinator.client)
		hallucinator.client.images -= image

/obj/effect/hallucination/danger/Initialize(mapload, _hallucinator)
	. = ..()
	target = _target
	show_icon()
	QDEL_IN(src, rand(200, 450))

/obj/effect/hallucination/danger/Destroy()
	clear_icon()
	. = ..()

/obj/effect/hallucination/danger/lava
	name = "lava"

/obj/effect/hallucination/danger/lava/Initialize(mapload, _hallucinator)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/hallucination/danger/lava/show_icon()
	var/turf/danger_turf = get_turf(src)
	image = image('icons/turf/floors/lava.dmi', src, "lava-[danger_turf.smoothing_junction || 0]", TURF_LAYER)
	if(hallucinator.client)
		hallucinator.client.images += image

/obj/effect/hallucination/danger/lava/proc/on_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER

	if(entered != hallucinator)
		return

	hallucinator.adjustStaminaLoss(20)
	hallucinator.cause_hallucination(/datum/hallucination/fire, source = "fake lava hallucination")

/obj/effect/hallucination/danger/chasm
	name = "chasm"

/obj/effect/hallucination/danger/chasm/Initialize(mapload, _hallucinator)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/hallucination/danger/chasm/show_icon()
	var/turf/danger_turf = get_turf(src)
	image = image('icons/turf/floors/chasms.dmi', src, "chasms-[danger_turf.smoothing_junction || 0]", TURF_LAYER)
	if(hallucinator.client)
		hallucinator.client.images += image

/obj/effect/hallucination/danger/chasm/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(AM == hallucinator)
		if(istype(hallucinator, /obj/effect/dummy/phased_mob))
			return
		to_chat(hallucinator, span_userdanger("You fall into the chasm!"))
		hallucinator.Paralyze(40)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, hallucinator, span_notice("It's surprisingly shallow.")), 15)
		QDEL_IN(src, 30)

/obj/effect/hallucination/danger/anomaly
	name = "flux wave anomaly"

/obj/effect/hallucination/danger/anomaly/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/hallucination/danger/anomaly/process(delta_time)
	if(DT_PROB(45, delta_time))
		step(src,pick(GLOB.alldirs))

/obj/effect/hallucination/danger/anomaly/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/hallucination/danger/anomaly/show_icon()
	image = image('icons/effects/effects.dmi',src,"electricity2",OBJ_LAYER+0.01)
	if(hallucinator.client)
		hallucinator.client.images += image

/obj/effect/hallucination/danger/anomaly/proc/on_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER

	if(entered != hallucinator)
		return

	hallucinator.cause_hallucination(/datum/hallucination/shock, source = "fake anomaly hallucination")

/datum/hallucination/death

/datum/hallucination/death/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	hallucinator.set_screwyhud(SCREWYHUD_DEAD)
	hallucinator.Paralyze(300)
	hallucinator.silent += 10
	to_chat(hallucinator, span_deadsay("<b>[hallucinator.real_name]</b> has died at <b>[get_area_name(hallucinator)]</b>."))

	var/delay = 0

	if(prob(50))
		var/mob/fakemob
		var/list/dead_people = list()
		for(var/mob/dead/observer/G in GLOB.player_list)
			dead_people += G
		if(LAZYLEN(dead_people))
			fakemob = pick(dead_people)
		else
			fakemob = target //ever been so lonely you had to haunt yourself?
		if(fakemob)
			delay = rand(20, 50)
			addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, hallucinator, "<span class='deadsay'><b>DEAD: [fakemob.name]</b> says, \"[pick("rip","why did i just drop dead?","hey [hallucinator.first_name()]","git gud","you too?","is the AI rogue?",\
				"i[prob(50)?" fucking":""] hate [pick("blood cult", "clock cult", "revenants", "this round","this","myself","admins","you")]")]\"</span>"), delay)

	addtimer(CALLBACK(src, .proc/cleanup), delay + rand(70, 90))

/datum/hallucination/death/proc/cleanup()
	if (hallucinator)
		hallucinator.set_screwyhud(SCREWYHUD_NONE)
		hallucinator.SetParalyzed(0)
		hallucinator.silent = FALSE
	qdel(src)

#define RAISE_FIRE_COUNT 3
#define RAISE_FIRE_TIME 3

/datum/hallucination/fire
	var/active = TRUE
	var/stage = 0
	var/image/fire_overlay

	var/next_action = 0
	var/times_to_lower_stamina
	var/fire_clearing = FALSE
	var/increasing_stages = TRUE
	var/time_spent = 0

/datum/hallucination/fire/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	hallucinator.set_fire_stacks(max(hallucinator.fire_stacks, 0.1)) //Placebo flammability
	fire_overlay = image('icons/mob/onfire.dmi', hallucinator, "human_burning", ABOVE_MOB_LAYER)
	if(hallucinator.client)
		hallucinator.client.images += fire_overlay
	to_chat(hallucinator, span_userdanger("You're set on fire!"))
	hallucinator.throw_alert(ALERT_FIRE, /atom/movable/screen/alert/fire, override = TRUE)
	times_to_lower_stamina = rand(5, 10)
	addtimer(CALLBACK(src, .proc/start_expanding), 20)

/datum/hallucination/fire/Destroy()
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)

/datum/hallucination/fire/proc/start_expanding()
	if (isnull(hallucinator))
		qdel(src)
		return
	START_PROCESSING(SSfastprocess, src)

/datum/hallucination/fire/process(delta_time)
	if (isnull(hallucinator))
		qdel(src)
		return

	if(hallucinator.fire_stacks <= 0)
		clear_fire()

	time_spent += delta_time

	if (fire_clearing)
		next_action -= delta_time
		if (next_action < 0)
			stage -= 1
			update_temp()
			next_action += 3
	else if (increasing_stages)
		var/new_stage = min(round(time_spent / RAISE_FIRE_TIME), RAISE_FIRE_COUNT)
		if (stage != new_stage)
			stage = new_stage
			update_temp()

			if (stage == RAISE_FIRE_COUNT)
				increasing_stages = FALSE
	else if (times_to_lower_stamina)
		next_action -= delta_time
		if (next_action < 0)
			hallucinator.adjustStaminaLoss(15)
			next_action += 2
			times_to_lower_stamina -= 1
	else
		clear_fire()

/datum/hallucination/fire/proc/update_temp()
	if(stage <= 0)
		hallucinator.clear_alert(ALERT_TEMPERATURE, clear_override = TRUE)
	else
		hallucinator.clear_alert(ALERT_TEMPERATURE, clear_override = TRUE)
		hallucinator.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, stage, override = TRUE)

/datum/hallucination/fire/proc/clear_fire()
	if(!active)
		return
	active = FALSE
	hallucinator.clear_alert(ALERT_FIRE, clear_override = TRUE)
	if(hallucinator.client)
		hallucinator.client.images -= fire_overlay
	QDEL_NULL(fire_overlay)
	fire_clearing = TRUE
	next_action = 0

#undef RAISE_FIRE_COUNT
#undef RAISE_FIRE_TIME

/datum/hallucination/shock
	var/image/shock_image
	var/image/electrocution_skeleton_anim

/datum/hallucination/shock/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	shock_image = image(hallucinator, hallucinator, dir = hallucinator.dir)
	shock_image.appearance_flags |= KEEP_APART
	shock_image.color = rgb(0,0,0)
	shock_image.override = TRUE
	electrocution_skeleton_anim = image('icons/mob/human.dmi', hallucinator, icon_state = "electrocuted_base", layer=ABOVE_MOB_LAYER)
	electrocution_skeleton_anim.appearance_flags |= RESET_COLOR|KEEP_APART
	to_chat(hallucinator, span_userdanger("You feel a powerful shock course through your body!"))
	if(hallucinator.client)
		hallucinator.client.images |= shock_image
		hallucinator.client.images |= electrocution_skeleton_anim
	addtimer(CALLBACK(src, .proc/reset_shock_animation), 40)
	hallucinator.playsound_local(get_turf(src), SFX_SPARKS, 100, 1)
	hallucinator.staminaloss += 50
	hallucinator.Stun(40)
	hallucinator.jitteriness += 1000
	hallucinator.do_jitter_animation(hallucinator.jitteriness)
	addtimer(CALLBACK(src, .proc/shock_drop), 20)

/datum/hallucination/shock/proc/reset_shock_animation()
	if(hallucinator.client)
		hallucinator.client.images.Remove(shock_image)
		hallucinator.client.images.Remove(electrocution_skeleton_anim)

/datum/hallucination/shock/proc/shock_drop()
	hallucinator.jitteriness = max(hallucinator.jitteriness - 990, 10) //Still jittery, but vastly less
	hallucinator.Paralyze(60)

/datum/hallucination/husks
	var/image/halbody

/datum/hallucination/husks/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	var/list/possible_points = list()
	for(var/turf/open/floor/F in view(hallucinator,world.view))
		possible_points += F
	if(possible_points.len)
		var/turf/open/floor/husk_point = pick(possible_points)
		switch(rand(1,4))
			if(1)
				var/image/body = image('icons/mob/human.dmi',husk_point,"husk",TURF_LAYER)
				var/matrix/M = matrix()
				M.Turn(90)
				body.transform = M
				halbody = body
			if(2,3)
				halbody = image('icons/mob/human.dmi',husk_point,"husk",TURF_LAYER)
			if(4)
				halbody = image('icons/mob/alien.dmi',husk_point,"alienother",TURF_LAYER)

		if(hallucinator.client)
			hallucinator.client.images += halbody
		QDEL_IN(src, rand(30,50)) //Only seen for a brief moment.

/datum/hallucination/husks/Destroy()
	hallucinator.client?.images -= halbody
	QDEL_NULL(halbody)
	return ..()

//hallucination projectile code in code/modules/projectiles/projectile/special.dm
/datum/hallucination/stray_bullet

/datum/hallucination/stray_bullet/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	var/list/turf/startlocs = list()
	for(var/turf/open/T in view(world.view+1,hallucinator)-view(world.view,hallucinator))
		startlocs += T
	if(!startlocs.len)
		qdel(src)
		return
	var/turf/start = pick(startlocs)
	var/proj_type = pick(subtypesof(/obj/projectile/hallucination))
	feedback_details += "Type: [proj_type]"
	var/obj/projectile/hallucination/H = new proj_type(start)
	hallucinator.playsound_local(start, H.hal_fire_sound, 60, 1)
	H.hal_target = target
	H.preparePixelProjectile(hallucinator, start)
	H.fire()
	qdel(src)
