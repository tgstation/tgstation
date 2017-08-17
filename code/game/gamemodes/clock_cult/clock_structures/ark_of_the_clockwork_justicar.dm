//The gateway to Reebe, from which Ratvar emerges.
/obj/structure/destructible/clockwork/massive/celestial_gateway
	name = "ark of the Clockwork Justicar"
	desc = "A massive, thrumming rip in spacetime."
	clockwork_desc = "A portal to the Celestial Derelict. Massive and intimidating, it is the only thing that can both transport Ratvar and withstand the massive amount of energy he emits."
	max_integrity = 500
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "nothing"
	density = TRUE
	resistance_flags = FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	can_be_repaired = FALSE
	immune_to_servant_attacks = TRUE
	var/start_time_added = FALSE
	var/progress_in_seconds = 0 //Once this reaches GATEWAY_RATVAR_ARRIVAL, it's game over
	var/active = FALSE
	var/activating = FALSE
	var/purpose_fulfilled = FALSE
	var/first_sound_played = FALSE
	var/second_sound_played = FALSE
	var/third_sound_played = FALSE
	var/obj/effect/clockwork/overlay/gateway_glow/glow
	var/obj/effect/countdown/clockworkgate/countdown

/obj/structure/destructible/clockwork/massive/celestial_gateway/Initialize()
	. = ..()
	make_glow()
	countdown = new(src)
	countdown.start()
	GLOB.ark_of_the_clockwork_justicar = src
	START_PROCESSING(SSprocessing, src)

/obj/structure/destructible/clockwork/massive/celestial_gateway/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	if(!purpose_fulfilled)
		SSticker.force_ending = TRUE
	if(glow)
		QDEL_NULL(glow)
	if(countdown)
		QDEL_NULL(countdown)
	for(var/mob/L in GLOB.player_list)
		if(L.z == z)
			var/turf/T = get_turf(pick(GLOB.generic_event_spawns))
			quick_spatial_gate(L.loc, T, L)
	for(var/obj/effect/clockwork/reebe_rift/R in GLOB.all_clockwork_objects)
		qdel(R)
	if(GLOB.ark_of_the_clockwork_justicar == src)
		GLOB.ark_of_the_clockwork_justicar = null
	. = ..()

/obj/structure/destructible/clockwork/massive/celestial_gateway/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(!disassembled)
			resistance_flags |= INDESTRUCTIBLE
			countdown.stop()
			visible_message("<span class='userdanger'>[src] begins to pulse uncontrollably... you might want to run!</span>")
			sound_to_playing_players(S = sound('sound/effects/clockcult_gateway_disrupted.ogg', 50, TRUE, frequency = 30000, channel = CHANNEL_JUSTICAR_ARK))
			make_glow()
			glow.icon_state = "clockwork_gateway_disrupted"
			animate(glow, transform = matrix() * 1.5, time = 9)
			animate(transform = matrix(), time = 9)
			animate(transform = matrix() * 2, time = 6)
			animate(transform = matrix(), time = 6)
			animate(transform = matrix() * 3, alpha = 0, time = 3)
			sleep(40)
			explosion(src, 5, 10, 20, 8)
			QDEL_NULL(glow)
			sleep(100)
	qdel(src)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/make_glow()
	if(!glow)
		glow = new /obj/effect/clockwork/overlay/gateway_glow(get_turf(src))
		glow.linked = src

/obj/structure/destructible/clockwork/massive/celestial_gateway/ex_act(severity)
	var/damage = max((obj_integrity * 0.70) / severity, 100) //requires multiple bombs to take down
	take_damage(damage, BRUTE, "bomb", 0)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/get_arrival_text(s_on_time)
	if(!active)
		if(!GLOB.initial_ark_time)
			return
		return "[Floor((GLOB.initial_ark_time - world.time) * 0.1)][s_on_time ? "S":""]"
	. = "IMMINENT"
	if(!obj_integrity)
		. = "DETONATING"
	else if(GATEWAY_RATVAR_ARRIVAL - progress_in_seconds > 0)
		. = "[Floor(max((GATEWAY_RATVAR_ARRIVAL - progress_in_seconds) / (GATEWAY_SUMMON_RATE), 0))][s_on_time ? "S":""]"

/obj/structure/destructible/clockwork/massive/celestial_gateway/examine(mob/user)
	icon_state = "spatial_gateway" //cheat wildly by pretending to have an icon
	..()
	icon_state = initial(icon_state)
	if(is_servant_of_ratvar(user) || isobserver(user))
		if(GLOB.initial_ark_time)
			to_chat(user, "<span class='big'><b>Seconds until Ratvar's arrival:</b> [get_arrival_text(TRUE)]</span>")
		switch(progress_in_seconds)
			if(-INFINITY to GATEWAY_REEBE_FOUND)
				to_chat(user, "<span class='heavy_brass'>It's powering up.</span>")
			if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
				to_chat(user, "<span class='heavy_brass'>It's reached the station and is stabilizing.</span>")
			if(GATEWAY_RATVAR_COMING to INFINITY)
				to_chat(user, "<span class='heavy_brass'>Ratvar is leaving through the gateway!</span>")
	else
		switch(progress_in_seconds)
			if(-INFINITY to GATEWAY_REEBE_FOUND)
				to_chat(user, "<span class='warning'>It's a swirling mass of blackness.</span>")
			if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
				to_chat(user, "<span class='warning'>It seems to be leading somewhere.</span>")
			if(GATEWAY_RATVAR_COMING to INFINITY)
				to_chat(user, "<span class='boldwarning'>A massive humanoid machine is leaving through the portal!</span>")

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/open_portal(turf/T)
	new /obj/effect/clockwork/reebe_rift(T)

/obj/structure/destructible/clockwork/massive/celestial_gateway/process()
	if(!obj_integrity || !GLOB.initial_ark_time)
		return
	if(!start_time_added)
		GLOB.initial_ark_time += SSticker.round_start_time
		start_time_added = TRUE
	var/turf/own_turf = get_turf(src)
	var/list/open_turfs = list()
	for(var/t in RANGE_TURFS(1, own_turf))
		var/turf/T = t
		if(T && !is_blocked_turf(T, TRUE))
			open_turfs += T
	if(LAZYLEN(open_turfs))
		for(var/a in own_turf)
			var/atom/movable/A = a
			if(!A.anchored || isliving(A))
				A.forceMove(pick(open_turfs))
	for(var/obj/O in orange(1, src))
		if(!O.pulledby && !istype(O, /obj/effect) && O.density)
			if(!step_away(O, src, 2) || get_dist(O, src) < 2)
				O.take_damage(50, BURN, "bomb")
			O.update_icon()
	if(!active)
		if(!GLOB.herald_vote_complete && GLOB.initial_ark_time - 16200 <= world.time)
			GLOB.herald_vote_complete = TRUE
			if(GLOB.herald_votes > LAZYLEN(SSticker.mode.servants_of_ratvar) * 0.5)
				priority_announce("A group of fanatics following the cause of Ratvar have rashly sacrificed stealth for power, and dare anyone to try and stop them.", title = "The Justiciar Comes")
				hierophant_message("<span class='brass'>Ratvar's arrival has been heralded, and clockwork slabs and replica fabricators will work at greatly increased speed.</span><br>\
				<span class='big_brass'>With no need for stealth, the Ark will activate five minutes earlier.</span>")
				GLOB.initial_ark_time -= 3000
				GLOB.ark_heralded = TRUE
				for(var/datum/mind/M in SSticker.mode.servants_of_ratvar)
					if(M.current)
						for(var/datum/action/innate/herald_vote/vote in M.current.actions)
							vote.Remove(M.current)
				for(var/obj/O in GLOB.all_clockwork_objects)
					O.ratvar_act()
			else
				hierophant_message("<span class='brass'>Ratvar's arrival has not been heralded, and stealth is retained.</span>")
		if(!activating && GLOB.initial_ark_time - 300 <= world.time)
			visible_message("<span class='boldwarning'>[src] whirrs to life!</span>")
			hierophant_message("<span class='bold large_brass'>The Ark is activating! Return to Reebe!</span>")
			for(var/mob/M in GLOB.player_list)
				if(is_servant_of_ratvar(M) || isobserver(M) || M.z == z)
					M.playsound_local(M, 'sound/magic/clockwork/ark_activation_sequence.ogg', 30, FALSE, pressure_affected = FALSE)
			activating = TRUE
		if(activating && GLOB.initial_ark_time <= world.time)
			active = TRUE
			priority_announce("Massive bluespace anomaly detected on all frequencies. All crew are directed to @!$ [Gibberish(text2ratvar("PURGE ALL UNTRUTHS"), 100)] <& the anomalies and \
			destroy their source to prevent further damage to corporate property. This is not a drill.", "Central Command Higher Dimensional Affairs")
			set_security_level("delta")
			SSshuttle.registerHostileEnvironment(src)
			for(var/V in GLOB.generic_event_spawns)
				addtimer(CALLBACK(src, .proc/open_portal, get_turf(V)), rand(100, 600))
			for(var/V in SSticker.mode.servants_of_ratvar)
				var/datum/mind/M = V
				var/datum/antagonist/clockcult/C = M.has_antag_datum(ANTAG_DATUM_CLOCKCULT)
				C.apply_glow()
		return
	if(!first_sound_played || prob(7))
		for(var/mob/M in GLOB.player_list)
			if(M && !isnewplayer(M))
				if(M.z == z)
					to_chat(M, "<span class='warning'><b>You hear otherworldly sounds from the [dir2text(get_dir(get_turf(M), get_turf(src)))]...</span>")
				else
					to_chat(M, "<span class='boldwarning'>You hear otherworldly sounds from all around you...</span>")
	progress_in_seconds += GATEWAY_SUMMON_RATE
	switch(progress_in_seconds)
		if(-INFINITY to GATEWAY_REEBE_FOUND)
			if(!first_sound_played)
				sound_to_playing_players(S = sound('sound/effects/clockcult_gateway_charging.ogg', 1, channel = CHANNEL_JUSTICAR_ARK, volume = 30))
				first_sound_played = TRUE
			make_glow()
			glow.icon_state = "clockwork_gateway_charging"
		if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
			if(!second_sound_played)
				sound_to_playing_players(S = sound('sound/effects/clockcult_gateway_active.ogg', 1, channel = CHANNEL_JUSTICAR_ARK, volume = 35))
				second_sound_played = TRUE
			make_glow()
			glow.icon_state = "clockwork_gateway_active"
		if(GATEWAY_RATVAR_COMING to GATEWAY_RATVAR_ARRIVAL)
			if(!third_sound_played)
				sound_to_playing_players(S = sound('sound/effects/clockcult_gateway_closing.ogg', 1, channel = CHANNEL_JUSTICAR_ARK, volume = 40))
				third_sound_played = TRUE
			make_glow()
			glow.icon_state = "clockwork_gateway_closing"
		if(GATEWAY_RATVAR_ARRIVAL to INFINITY)
			if(!purpose_fulfilled)
				var/turf/startpoint = locate(round(world.maxx * 0.5, 1), round(world.maxy * 0.5, 1), ZLEVEL_STATION)
				countdown.stop()
				resistance_flags |= INDESTRUCTIBLE
				purpose_fulfilled = TRUE
				make_glow()
				var/obj/effect/clockwork/overlay/gateway_glow/second_glow = new(startpoint)
				second_glow.icon_state = "clockwork_gateway_closing"
				animate(glow, transform = matrix() * 1.5, time = 125)
				animate(second_glow, transform = matrix() * 1.5, time = 125)
				sound_to_playing_players(S = sound('sound/effects/ratvar_rises.ogg', 0, channel = CHANNEL_JUSTICAR_ARK)) //End the sounds
				sleep(125)
				make_glow()
				animate(glow, transform = matrix() * 3, alpha = 0, time = 5)
				animate(second_glow, transform = matrix() * 3, alpha = 0, time = 5)
				QDEL_IN(src, 5)
				QDEL_IN(second_glow, 5)
				sleep(3)
				GLOB.clockwork_gateway_activated = TRUE
				new/obj/structure/destructible/clockwork/massive/ratvar(startpoint)
				send_to_playing_players("<span class='inathneq_large'>\"[text2ratvar("See Engine's mercy")]!\"</span>\n\
				<span class='sevtug_large'>\"[text2ratvar("Observe Engine's design skills")]!\"</span>\n<span class='nezbere_large'>\"[text2ratvar("Behold Engine's light")]!!\"</span>\n\
				<span class='nzcrentr_large'>\"[text2ratvar("Gaze upon Engine's power")].\"</span>")
				sound_to_playing_players('sound/magic/clockwork/invoke_general.ogg')
				var/x0 = startpoint.x
				var/y0 = startpoint.y
				for(var/I in spiral_range_turfs(255, startpoint))
					var/turf/T = I
					if(!T)
						continue
					var/dist = cheap_hypotenuse(T.x, T.y, x0, y0)
					if(dist < 100)
						dist = TRUE
					else
						dist = FALSE
					T.ratvar_act(dist, TRUE)
					CHECK_TICK

//the actual appearance of the Ark of the Clockwork Justicar; an object so the edges of the gate can be clicked through.
/obj/effect/clockwork/overlay/gateway_glow
	icon = 'icons/effects/96x96.dmi'
	icon_state = "clockwork_gateway_components"
	pixel_x = -32
	pixel_y = -32
	layer = BELOW_OPEN_DOOR_LAYER
	light_range = 2
	light_power = 4
	light_color = "#6A4D2F"
