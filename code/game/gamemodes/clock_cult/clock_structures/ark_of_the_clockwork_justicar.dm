//The gateway to Reebe, from which Ratvar emerges.
/obj/structure/destructible/clockwork/massive/celestial_gateway
	name = "ark of the Clockwork Justicar"
	desc = "A massive, thrumming rip in spacetime."
	clockwork_desc = "A portal to the Celestial Derelict. Massive and intimidating, it is the only thing that can both transport Ratvar and withstand the massive amount of energy he emits."
	obj_integrity = 500
	max_integrity = 500
	mouse_opacity = 2
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "nothing"
	density = FALSE
	invisibility = INVISIBILITY_MAXIMUM
	resistance_flags = FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE
	can_be_repaired = FALSE
	immune_to_servant_attacks = TRUE
	var/progress_in_seconds = 0 //Once this reaches GATEWAY_RATVAR_ARRIVAL, it's game over
	var/wisdom_regen_cycle = 0 //How many ticks It's been between wisdom regenerations
	var/purpose_fulfilled = FALSE
	var/first_sound_played = FALSE
	var/second_sound_played = FALSE
	var/third_sound_played = FALSE
	var/fourth_sound_played = FALSE
	var/obj/effect/clockwork/overlay/gateway_glow/glow
	var/obj/effect/countdown/clockworkgate/countdown

/obj/structure/destructible/clockwork/massive/celestial_gateway/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)
	if(GLOB.ark_of_the_clockwork_justiciar)
		qdel(src)
		return
	else
		GLOB.ark_of_the_clockwork_justiciar = src
	density = TRUE
	invisibility = 0
	glow = new(get_turf(src))

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/spawn_animation()
	var/turf/T = get_turf(src)
	new/obj/effect/clockwork/general_marker/inathneq(T)
	hierophant_message("<span class='inathneq'>\"[text2ratvar("Engine, come forth and show your servants your mercy")]!\"</span>")
	playsound(T, 'sound/magic/clockwork/invoke_general.ogg', 30, 0)
	sleep(10)
	new/obj/effect/clockwork/general_marker/sevtug(T)
	hierophant_message("<span class='sevtug'>\"[text2ratvar("Engine, come forth and show this station your decorating skills")]!\"</span>")
	playsound(T, 'sound/magic/clockwork/invoke_general.ogg', 45, 0)
	sleep(10)
	new/obj/effect/clockwork/general_marker/nezbere(T)
	hierophant_message("<span class='nezbere'>\"[text2ratvar("Engine, come forth and shine your light across this realm")]!!\"</span>")
	playsound(T, 'sound/magic/clockwork/invoke_general.ogg', 60, 0)
	sleep(10)
	new/obj/effect/clockwork/general_marker/nzcrentr(T)
	hierophant_message("<span class='nzcrentr'>\"[text2ratvar("Engine, come forth")].\"</span>")
	playsound(T, 'sound/magic/clockwork/invoke_general.ogg', 75, 0)
	sleep(10)
	playsound(T, 'sound/magic/clockwork/invoke_general.ogg', 100, 0)
	countdown = new(src)
	countdown.start()
	hierophant_message("<span class='large_brass'><b>The Ark has begun the final rite in the City of Cogs!</b></span>", FALSE, src)
	first_sound_played = TRUE
	SSshuttle.registerHostileEnvironment(src)

/obj/structure/destructible/clockwork/massive/celestial_gateway/Destroy(force)
	if(!countdown && !force)
		return
	GLOB.ark_of_the_clockwork_justiciar = null
	STOP_PROCESSING(SSprocessing, src)
	if(!purpose_fulfilled)
		hierophant_message("<span class='large_brass'><b>The Ark has fallen!</b></span>")
		send_to_playing_players(sound(null, 0, channel = 8))
		priority_announce("The anomaly has been neutralized. Bluespace and energy levels are returning to acceptable thresholds. Get back to work.", "Central Command Higher Dimensional Affairs")
	set_security_level("blue")
	/*var/was_stranded = SSshuttle.emergency.mode == SHUTTLE_STRANDED
	SSshuttle.clearHostileEnvironment(src)*/
	if(glow)
		qdel(glow)
		glow = null
	if(countdown)
		qdel(countdown)
		countdown = null
	. = ..()

/obj/structure/destructible/clockwork/massive/celestial_gateway/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(!disassembled)
			resistance_flags |= INDESTRUCTIBLE
			countdown.stop()
			visible_message("<span class='userdanger'>[src] begins to pulse uncontrollably... you might want to run!</span>")
			send_to_playing_players(sound('sound/effects/clockcult_gateway_disrupted.ogg', 0, channel = 8, volume = 50))
			make_glow()
			glow.icon_state = "clockwork_gateway_disrupted"
			resistance_flags |= INDESTRUCTIBLE
			sleep(27)
			explosion(src, 1, 3, 8, 8)
	qdel(src)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/make_glow()
	if(!glow)
		glow = new /obj/effect/clockwork/overlay/gateway_glow(get_turf(src))
		glow.linked = src

/obj/structure/destructible/clockwork/massive/celestial_gateway/ex_act(severity)
	var/damage = max((obj_integrity * 0.70) / severity, 100) //requires multiple bombs to take down
	take_damage(damage, BRUTE, "bomb", 0)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/get_arrival_text(s_on_time)
	. = "IMMINENT"
	if(!obj_integrity)
		. = "DETONATING"
	else if(GATEWAY_RATVAR_ARRIVAL - progress_in_seconds > 0)
		. = "[round(max((GATEWAY_RATVAR_ARRIVAL - progress_in_seconds) / (GATEWAY_SUMMON_RATE), 0), 1)][s_on_time ? "S":""]"

/obj/structure/destructible/clockwork/massive/celestial_gateway/examine(mob/user)
	icon_state = "spatial_gateway" //cheat wildly by pretending to have an icon
	..()
	icon_state = initial(icon_state)
	if(!countdown)
		if(is_servant_of_ratvar(user))
			to_chat(user, "Ratvar still hasn't finished preparing. The clock is ticking; get building!")
	else
		if(is_servant_of_ratvar(user) || isobserver(user))
			to_chat(user, "<span class='big'><b>Seconds until Ratvar's arrival:</b> [get_arrival_text(TRUE)]</span>")
			switch(progress_in_seconds)
				if(-INFINITY to GATEWAY_REEBE_FOUND)
					to_chat(user, "<span class='heavy_brass'>The Ark is trying to breach the walls of Ratvar's prison.</span>")
				if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
					to_chat(user, "<span class='heavy_brass'>The outer walls of the Derelict have fallen. The inner reinforcements are still being melted.</span>")
				if(GATEWAY_RATVAR_COMING to INFINITY)
					to_chat(user, "<span class='heavy_brass'>The Derelict has been breached! Ratvar is coming through!</span>")
		else
			switch(progress_in_seconds)
				if(-INFINITY to GATEWAY_REEBE_FOUND)
					to_chat(user, "<span class='warning'>You can make out a huge wall made of strange runed metal, slowly melting away.</span>")
				if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
					to_chat(user, "<span class='warning'>You can make out a melting, metal wall.</span>")
				if(GATEWAY_RATVAR_COMING to INFINITY)
					to_chat(user, "<span class='boldwarning'>A huge shape is slowly coming through the gateway!</span>")

/obj/structure/destructible/clockwork/massive/celestial_gateway/process()
	wisdom_regen_cycle++
	if(wisdom_regen_cycle >= ARK_WISDOM_REGEN)
		ADJUST_CLOCKWORK_WISDOM(1)
		wisdom_regen_cycle = 0
	if(countdown)
		if(!first_sound_played || prob(7))
			for(var/M in GLOB.player_list)
				var/mob/MO = M
				if(M && !isnewplayer(M) && MO.z == z)
					to_chat(M, "<span class='warning'><b>You hear otherworldly sounds from the [dir2text(get_dir(get_turf(M), get_turf(src)))]...</span>")
		if(!obj_integrity)
			return 0
		var/convert_dist = 1 + (round(Floor(progress_in_seconds, 15) * 0.067))
		for(var/t in RANGE_TURFS(convert_dist, loc))
			var/turf/T = t
			if(!T)
				continue
			if(get_dist(T, src) < 2)
				if(iswallturf(T))
					var/turf/closed/wall/W = T
					W.dismantle_wall()
				else if(t && (isclosedturf(T) || !is_blocked_turf(T)))
					T.ChangeTurf(/turf/open/floor/clockwork)
			var/dist = cheap_hypotenuse(T.x, T.y, x, y)
			if(dist < convert_dist)
				T.ratvar_act(FALSE, TRUE, 3)
		for(var/obj/O in orange(1, src))
			if(!O.pulledby && !istype(O, /obj/effect) && O.density)
				if(!step_away(O, src, 2) || get_dist(O, src) < 2)
					O.take_damage(50, BURN, "bomb")
				O.update_icon()
		progress_in_seconds += GATEWAY_SUMMON_RATE
		switch(progress_in_seconds)
			if(-INFINITY to GATEWAY_REEBE_FOUND)
				if(!second_sound_played)
					send_to_playing_players(sound('sound/effects/clockcult_gateway_charging.ogg', 1, channel = 8, volume = 30))
					second_sound_played = TRUE
				make_glow()
				glow.icon_state = "clockwork_gateway_charging"
			if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
				if(!third_sound_played)
					priority_announce("Attention: The energy anomaly has been reclassified as a spacetime anomaly. You are reminded that, as part of your contract, we are under no obligation to \
					continue employing you, nor continue to keep your genetic data backed up, if you do not respond to spacetime threats as directed.", "Central Command Higher Dimensional Affairs")
					send_to_playing_players(sound('sound/effects/clockcult_gateway_active.ogg', 1, channel = 8, volume = 35))
					third_sound_played = TRUE
				make_glow()
				glow.icon_state = "clockwork_gateway_active"
			if(GATEWAY_RATVAR_COMING to GATEWAY_RATVAR_ARRIVAL)
				if(!fourth_sound_played)
					priority_announce("CRITICAL ALERT: As of three seconds ago, the anomaly has been reclassified as a catastrophic extradimensional anomaly. You have approximately one minute \
					to reach and neutralize the anomaly before it reaches full power. All crew unable - not unwilling - to fight are directed to board and launch an escape pod filled to capacity.", \
					"Central Command Higher Dimensional Affairs", 'sound/misc/airraid.ogg')
					send_to_playing_players(sound('sound/effects/clockcult_gateway_closing.ogg', 1, channel = 8, volume = 40))
					set_security_level("delta")
					fourth_sound_played = TRUE
				make_glow()
				glow.icon_state = "clockwork_gateway_closing"
			if(GATEWAY_RATVAR_ARRIVAL to INFINITY)
				if(!purpose_fulfilled)
					countdown.stop()
					resistance_flags |= INDESTRUCTIBLE
					purpose_fulfilled = TRUE
					make_glow()
					animate(glow, transform = matrix() * 1.5, alpha = 255, time = 125)
					send_to_playing_players(sound('sound/effects/ratvar_rises.ogg', 0, channel = 8)) //End the sounds
					sleep(125)
					make_glow()
					animate(glow, transform = matrix() * 3, alpha = 0, time = 5)
					var/turf/startpoint = get_turf(src)
					GLOB.clockwork_gateway_activated = TRUE
					QDEL_IN(src, 3)
					sleep(3)
					new/obj/structure/destructible/clockwork/massive/ratvar(startpoint)
					send_to_playing_players("<span class='inathneq_large'>\"[text2ratvar("See Engine's mercy")]!\"</span>\n\
					<span class='sevtug_large'>\"[text2ratvar("Observe Engine's design skills")]!\"</span>\n<span class='nezbere_large'>\"[text2ratvar("Behold Engine's light")]!!\"</span>\n\
					<span class='nzcrentr_large'>\"[text2ratvar("Gaze upon Engine's power")].\"</span>")
					send_to_playing_players('sound/magic/clockwork/invoke_general.ogg')
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
	icon_state = "clockwork_gateway_charging"
	pixel_x = -32
	pixel_y = -32
	layer = BELOW_OPEN_DOOR_LAYER
	light_range = 2
	light_power = 4
	light_color = "#6A4D2F"
