//The gateway to Reebe, from which Ratvar emerges.
/obj/structure/destructible/clockwork/massive/celestial_gateway
	name = "\improper Ark of the Clockwork Justicar"
	desc = "A massive, hulking amalgamation of parts. It seems to be maintaining a very unstable bluespace anomaly."
	clockwork_desc = "Nezbere's magnum opus: a hulking clockwork machine capable of combining bluespace and steam power to summon Ratvar. Once activated, \
	its instability will cause one-way bluespace rifts to open across the station to the City of Cogs, so be prepared to defend it at all costs."
	max_integrity = 500
	mouse_opacity = 2
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "nothing"
	density = TRUE
	resistance_flags = FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	can_be_repaired = FALSE
	immune_to_servant_attacks = TRUE
	var/active = FALSE
	var/progress_in_seconds = 0 //Once this reaches GATEWAY_RATVAR_ARRIVAL, it's game over
	var/purpose_fulfilled = FALSE
	var/first_sound_played = FALSE
	var/second_sound_played = FALSE
	var/third_sound_played = FALSE
	var/fourth_sound_played = FALSE
	var/obj/effect/clockwork/overlay/gateway_glow/glow
	var/obj/effect/countdown/clockworkgate/countdown

/obj/structure/destructible/clockwork/massive/celestial_gateway/Initialize()
	. = ..()
	glow = new(get_turf(src))
	if(!GLOB.ark_of_the_clockwork_justiciar)
		GLOB.ark_of_the_clockwork_justiciar = src

/obj/structure/destructible/clockwork/massive/celestial_gateway/Destroy()
	if(GLOB.ark_of_the_clockwork_justiciar == src)
		GLOB.ark_of_the_clockwork_justiciar = null
	return ..()

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/cry_havoc()
	hierophant_message("<span class='nezbere_large'>\"You have one minute until the Ark activates.\"</span>")
	addtimer(CALLBACK(src, .proc/let_slip_the_dogs), 600)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/let_slip_the_dogs()
	spawn_animation()
	first_sound_played = TRUE
	active = TRUE
	priority_announce("Massive [Gibberish("bluespace", 100)] anomaly detected on all frequencies. All crew are directed to \
	@!$, [text2ratvar("PURGE ALL UNTRUTHS")] <&. the anomalies and destroy their source to prevent further damage to corporate property. This is \
	not a drill.", \
	"Central Command Higher Dimensional Affairs", 'sound/ambience/antag/new_clock.ogg')
	set_security_level("delta")
	for(var/V in GLOB.generic_event_spawns)
		addtimer(CALLBACK(src, .proc/open_portal, get_turf(V)), rand(100, 600))

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/open_portal(turf/T)
	new/obj/effect/clockwork/city_of_cogs_rift(T)

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
	var/list/open_turfs = list()
	for(var/turf/open/OT in orange(1, T))
		if(!is_blocked_turf(OT, TRUE))
			open_turfs |= OT
	if(open_turfs.len)
		for(var/mob/living/L in T)
			L.forceMove(pick(open_turfs))
	countdown = new(src)
	countdown.start()
	hierophant_message("<span class='large_brass'><b>The Ark has activated! Defend it at all costs!</b></span>", FALSE, src)
	SSshuttle.registerHostileEnvironment(src)
	START_PROCESSING(SSprocessing, src)

/obj/structure/destructible/clockwork/massive/celestial_gateway/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	if(!purpose_fulfilled)
		var/area/gate_area = get_area(src)
		hierophant_message("<span class='large_brass'><b>An Ark of the Clockwork Justicar has fallen at [gate_area.map_name]!</b></span>")
		send_to_playing_players(sound(null, 0, channel = CHANNEL_JUSTICAR_ARK))
	var/was_stranded = SSshuttle.emergency.mode == SHUTTLE_STRANDED
	SSshuttle.clearHostileEnvironment(src)
	if(!was_stranded && !purpose_fulfilled)
		priority_announce("Massive energy anomaly no longer on short-range scanners.","Anomaly Alert")
	if(glow)
		qdel(glow)
		glow = null
	if(countdown)
		qdel(countdown)
		countdown = null
	for(var/mob/living/L in GLOB.player_list)
		if(L.z == z)
			L.visible_message("<span class='warning'>[L] vanishes in a flash of yellow light!</span>", ignore_mob = L)
			L.forceMove(get_turf(pick(GLOB.generic_event_spawns)))
			L.overlay_fullscreen("flash", /obj/screen/fullscreen/flash/static)
		L.clear_fullscreen("flash", 30)
		L.Stun(50)
	for(var/obj/effect/clockwork/city_of_cogs_rift/R in GLOB.all_clockwork_objects)
		qdel(R)
	. = ..()

/obj/structure/destructible/clockwork/massive/celestial_gateway/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(!disassembled)
			resistance_flags |= INDESTRUCTIBLE
			countdown.stop()
			visible_message("<span class='userdanger'>[src] begins to pulse uncontrollably... you might want to run!</span>")
			send_to_playing_players(sound('sound/effects/clockcult_gateway_disrupted.ogg', 0, channel = CHANNEL_JUSTICAR_ARK, volume = 50))
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
	if(is_servant_of_ratvar(user) || isobserver(user))
		if(!active)
			to_chat(user, "<span class='heavy_brass'>It's running final preparations for activation. You have time, but not much. Get to it.</span>")
		else
			to_chat(user, "<span class='big'><b>Seconds until Ratvar's arrival:</b> [get_arrival_text(TRUE)]</span>")
			switch(progress_in_seconds)
				if(-INFINITY to GATEWAY_REEBE_FOUND)
					to_chat(user, "<span class='heavy_brass'>It's still opening.</span>")
				if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
					to_chat(user, "<span class='heavy_brass'>It's reached the Celestial Derelict and is drawing power from it.</span>")
				if(GATEWAY_RATVAR_COMING to INFINITY)
					to_chat(user, "<span class='heavy_brass'>Ratvar is coming through the gateway!</span>")
	else
		if(!active)
			to_chat(user, "<span class='warning'>Whatever it is, it doesn't seem to be active.</span>")
		else
			switch(progress_in_seconds)
				if(-INFINITY to GATEWAY_REEBE_FOUND)
					to_chat(user, "<span class='warning'>It's a swirling mass of blackness.</span>")
				if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
					to_chat(user, "<span class='warning'>It seems to be leading somewhere.</span>")
				if(GATEWAY_RATVAR_COMING to INFINITY)
					to_chat(user, "<span class='boldwarning'>Something is coming through!</span>")

/obj/structure/destructible/clockwork/massive/celestial_gateway/process()
	if(!first_sound_played || prob(7))
		for(var/mob/M in GLOB.player_list)
			if(M && !isnewplayer(M))
				if(M.z == z)
					to_chat(M, "<span class='warning'><b>You hear otherworldly sounds from the [dir2text(get_dir(get_turf(M), get_turf(src)))]...</span>")
				else
					to_chat(M, "<span class='boldwarning'>You hear otherworldly sounds from all around you...</span>")
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
				send_to_playing_players(sound('sound/effects/clockcult_gateway_charging.ogg', 1, channel = CHANNEL_JUSTICAR_ARK, volume = 30))
				second_sound_played = TRUE
			make_glow()
			glow.icon_state = "clockwork_gateway_charging"
		if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
			if(!third_sound_played)
				var/area/gate_area = get_area(src)
				priority_announce("Location of massive energy anomaly has been triangulated. Location: [gate_area.map_name].", "Anomaly Alert")
				send_to_playing_players(sound('sound/effects/clockcult_gateway_active.ogg', 1, channel = CHANNEL_JUSTICAR_ARK, volume = 35))
				third_sound_played = TRUE
			make_glow()
			glow.icon_state = "clockwork_gateway_active"
		if(GATEWAY_RATVAR_COMING to GATEWAY_RATVAR_ARRIVAL)
			if(!fourth_sound_played)
				send_to_playing_players(sound('sound/effects/clockcult_gateway_closing.ogg', 1, channel = CHANNEL_JUSTICAR_ARK, volume = 40))
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
				send_to_playing_players(sound('sound/effects/ratvar_rises.ogg', 0, channel = CHANNEL_JUSTICAR_ARK)) //End the sounds
				sleep(125)
				make_glow()
				animate(glow, transform = matrix() * 3, alpha = 0, time = 5)
				var/turf/startpoint = get_turf(src)
				QDEL_IN(src, 3)
				sleep(3)
				GLOB.clockwork_gateway_activated = TRUE
				var/obj/structure/destructible/clockwork/massive/ratvar/R = new(startpoint)
				var/turf/T =  locate(round(world.maxx * 0.5, 1), round(world.maxy * 0.5, 1), ZLEVEL_STATION) //approximate center of the station
				R.forceMove(T)
				send_to_playing_players("<span class='inathneq_large'>\"[text2ratvar("See Engine's mercy")]!\"</span>\n\
				<span class='sevtug_large'>\"[text2ratvar("Observe Engine's design skills")]!\"</span>\n<span class='nezbere_large'>\"[text2ratvar("Behold Engine's light")]!!\"</span>\n\
				<span class='nzcrentr_large'>\"[text2ratvar("Gaze upon Engine's power")].\"</span>")
				send_to_playing_players('sound/magic/clockwork/invoke_general.ogg')



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
