#define ARK_GRACE_PERIOD 300 //In seconds, how long the crew has before the Ark truly "begins"

//The gateway to Reebe, from which Ratvar emerges.
/obj/structure/destructible/clockwork/massive/celestial_gateway
	name = "\improper Ark of the Clockwork Justicar"
	desc = "A massive, hulking amalgamation of parts. It seems to be maintaining a very unstable bluespace anomaly."
	clockwork_desc = "Nezbere's magnum opus: a hulking clockwork machine capable of combining bluespace and steam power to summon Ratvar. Once activated, \
	its instability will cause one-way bluespace rifts to open across the station to the City of Cogs, so be prepared to defend it at all costs."
	max_integrity = 500
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "nothing"
	density = TRUE
	resistance_flags = FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	can_be_repaired = FALSE
	immune_to_servant_attacks = TRUE
	var/active = FALSE
	var/progress_in_seconds = 0 //Once this reaches GATEWAY_RATVAR_ARRIVAL, it's game over
	var/grace_period = ARK_GRACE_PERIOD //This exists to allow the crew to gear up and prepare for the invasion
	var/initial_activation_delay = -1 //How many seconds the Ark will have initially taken to activate
	var/seconds_until_activation = -1 //How many seconds until the Ark activates; if it should never activate, set this to -1
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
	START_PROCESSING(SSprocessing, src)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/cry_havoc()
	visible_message("<span class='boldwarning'>[src] shudders and roars to life, its parts beginning to whirr and screech!</span>")
	hierophant_message("<span class='bold large_brass'>The Ark is activating! Get back to the base!</span>")
	for(var/mob/M in GLOB.player_list)
		if(is_servant_of_ratvar(M) || isobserver(M) || M.z == z)
			M.playsound_local(M, 'sound/magic/clockwork/ark_activation_sequence.ogg', 30, FALSE, pressure_affected = FALSE)
	addtimer(CALLBACK(src, .proc/let_slip_the_dogs), 300)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/let_slip_the_dogs()
	spawn_animation()
	first_sound_played = TRUE
	active = TRUE
	priority_announce("Massive [Gibberish("bluespace", 100)] anomaly detected on all frequencies. All crew are directed to \
	@!$, [text2ratvar("PURGE ALL UNTRUTHS")] <&. the anomalies and destroy their source to prevent further damage to corporate property. This is \
	not a drill.[grace_period ? " Estimated time of appearance: [grace_period] seconds. Use this time to prepare." : ""]", \
	"Central Command Higher Dimensional Affairs", 'sound/magic/clockwork/ark_activation.ogg')
	set_security_level("delta")
	for(var/V in SSticker.mode.servants_of_ratvar)
		var/datum/mind/M = V
		if(ishuman(M.current))
			M.current.add_overlay(mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER))

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/open_portal(turf/T)
	new/obj/effect/clockwork/city_of_cogs_rift(T)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/spawn_animation()
	var/turf/T = get_turf(src)
	var/list/open_turfs = list()
	for(var/turf/open/OT in orange(1, T))
		if(!is_blocked_turf(OT, TRUE))
			open_turfs |= OT
	if(open_turfs.len)
		for(var/mob/living/L in T)
			L.forceMove(pick(open_turfs))
	hierophant_message("<span class='bold large_brass'>The Ark has activated! [grace_period ? "You have [round(grace_period / 60)] minutes until the crew invades! " : ""]Defend it at all costs!</span>", FALSE, src)
	sound_to_playing_players(volume = 10, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_charging.ogg', TRUE))
	seconds_until_activation = 0
	SSshuttle.registerHostileEnvironment(src)

/obj/structure/destructible/clockwork/massive/celestial_gateway/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	SSshuttle.clearHostileEnvironment(src)
	if(!purpose_fulfilled && istype(SSticker.mode, /datum/game_mode/clockwork_cult))
		hierophant_message("<span class='bold large_brass'>The Ark has fallen!</span>")
		sound_to_playing_players(null, channel = CHANNEL_JUSTICAR_ARK)
		SSticker.force_ending = TRUE //rip
	if(glow)
		qdel(glow)
		glow = null
	if(countdown)
		qdel(countdown)
		countdown = null
	for(var/mob/L in GLOB.player_list)
		if(L.z == z)
			L.forceMove(get_turf(pick(GLOB.generic_event_spawns)))
			L.overlay_fullscreen("flash", /obj/screen/fullscreen/flash/static)
		L.clear_fullscreen("flash", 30)
		if(isliving(L))
			var/mob/living/LI = L
			LI.Stun(50)
	for(var/obj/effect/clockwork/city_of_cogs_rift/R in GLOB.all_clockwork_objects)
		qdel(R)
	if(GLOB.ark_of_the_clockwork_justiciar == src)
		GLOB.ark_of_the_clockwork_justiciar = null
	. = ..()

/obj/structure/destructible/clockwork/massive/celestial_gateway/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!disassembled)
			resistance_flags |= INDESTRUCTIBLE
			countdown.stop()
			visible_message("<span class='userdanger'>[src] begins to pulse uncontrollably... you might want to run!</span>")
			sound_to_playing_players(volume = 50, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_disrupted.ogg'))
			make_glow()
			glow.icon_state = "clockwork_gateway_disrupted"
			resistance_flags |= INDESTRUCTIBLE
			sleep(27)
			explosion(src, 1, 3, 8, 8)
			sound_to_playing_players('sound/effects/explosion_distant.ogg', volume = 50)
	qdel(src)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/make_glow()
	if(!glow)
		glow = new /obj/effect/clockwork/overlay/gateway_glow(get_turf(src))
		glow.linked = src

/obj/structure/destructible/clockwork/massive/celestial_gateway/ex_act(severity)
	var/damage = max((obj_integrity * 0.7) / severity, 100) //requires multiple bombs to take down
	take_damage(damage, BRUTE, "bomb", 0)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/get_arrival_text(s_on_time)
	if(seconds_until_activation)
		return "[seconds_until_activation][s_on_time ? "S" : ""]"
	if(grace_period)
		return "[grace_period][s_on_time ? "S" : ""]"
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
			to_chat(user, "<span class='big'><b>Seconds until the Ark's activation:</b> [get_arrival_text(TRUE)]</span>")
		else
			if(grace_period)
				to_chat(user, "<span class='big'><b>Crew grace period time remaining:</b> [get_arrival_text(TRUE)]</span>")
			else
				to_chat(user, "<span class='big'><b>Seconds until Ratvar's arrival:</b> [get_arrival_text(TRUE)]</span>")
				switch(progress_in_seconds)
					if(-INFINITY to GATEWAY_REEBE_FOUND)
						to_chat(user, "<span class='heavy_brass'>The Ark is feeding power into the bluespace field.</span>")
					if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
						to_chat(user, "<span class='heavy_brass'>The field is ripping open a copy of itself in Ratvar's prison.</span>")
					if(GATEWAY_RATVAR_COMING to INFINITY)
						to_chat(user, "<span class='heavy_brass'>With the bluespace field established, Ratvar is preparing to come through!</span>")
	else
		if(!active)
			to_chat(user, "<span class='warning'>Whatever it is, it doesn't seem to be active.</span>")
		else
			switch(progress_in_seconds)
				if(-INFINITY to GATEWAY_REEBE_FOUND)
					to_chat(user, "<span class='warning'>You see a swirling bluespace anomaly steadily growing in intensity.</span>")
				if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
					to_chat(user, "<span class='warning'>The anomaly is stable, and you can see flashes of something from it.</span>")
				if(GATEWAY_RATVAR_COMING to INFINITY)
					to_chat(user, "<span class='boldwarning'>The anomaly is stable! Something is coming through!</span>")

/obj/structure/destructible/clockwork/massive/celestial_gateway/process()
	if(seconds_until_activation == -1) //we never do anything
		return
	adjust_clockwork_power(2.5) //Provides weak power generation on its own
	if(seconds_until_activation)
		if(!countdown)
			countdown = new(src)
			countdown.start()
		seconds_until_activation--
		if(!GLOB.script_scripture_unlocked && initial_activation_delay * 0.5 > seconds_until_activation)
			GLOB.script_scripture_unlocked = TRUE
			hierophant_message("<span class='large_brass bold'>The Ark is halfway prepared. Script scripture is now available!</span>")
		if(!seconds_until_activation)
			cry_havoc()
			seconds_until_activation = -1 //we'll set this after cry_havoc()
		return
	if(!first_sound_played || prob(7))
		for(var/mob/M in GLOB.player_list)
			if(M && !isnewplayer(M))
				if(M.z == z)
					to_chat(M, "<span class='warning'><b>You hear otherworldly sounds from the [dir2text(get_dir(get_turf(M), get_turf(src)))]...</span>")
				else
					to_chat(M, "<span class='boldwarning'>You hear otherworldly sounds from all around you...</span>")
	if(!obj_integrity)
		return
	for(var/turf/closed/wall/W in RANGE_TURFS(2, src))
		W.dismantle_wall()
	for(var/obj/O in orange(1, src))
		if(!O.pulledby && !istype(O, /obj/effect) && O.density)
			if(!step_away(O, src, 2) || get_dist(O, src) < 2)
				O.take_damage(50, BURN, "bomb")
			O.update_icon()
	if(grace_period)
		grace_period--
		return
	progress_in_seconds += GATEWAY_SUMMON_RATE
	switch(progress_in_seconds)
		if(-INFINITY to GATEWAY_REEBE_FOUND)
			if(!second_sound_played)
				for(var/V in GLOB.generic_event_spawns)
					addtimer(CALLBACK(src, .proc/open_portal, get_turf(V)), rand(100, 600))
				sound_to_playing_players('sound/magic/clockwork/invoke_general.ogg', 30, FALSE)
				sound_to_playing_players(volume = 30, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_charging.ogg', TRUE))
				second_sound_played = TRUE
			make_glow()
			glow.icon_state = "clockwork_gateway_charging"
		if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
			if(!third_sound_played)
				sound_to_playing_players(volume = 35, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_active.ogg', TRUE))
				third_sound_played = TRUE
			make_glow()
			glow.icon_state = "clockwork_gateway_active"
		if(GATEWAY_RATVAR_COMING to GATEWAY_RATVAR_ARRIVAL)
			if(!fourth_sound_played)
				sound_to_playing_players(volume = 40, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_closing.ogg', TRUE))
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
				sound_to_playing_players(volume = 100, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/ratvar_rises.ogg')) //End the sounds
				sleep(125)
				make_glow()
				animate(glow, transform = matrix() * 3, alpha = 0, time = 5)
				var/turf/startpoint = get_turf(src)
				QDEL_IN(src, 3)
				sleep(3)
				GLOB.clockwork_gateway_activated = TRUE
				var/obj/structure/destructible/clockwork/massive/ratvar/R = new(startpoint)
				var/turf/T =  locate(round(world.maxx * 0.5, 1), round(world.maxy * 0.5, 1), ZLEVEL_STATION_PRIMARY) //approximate center of the station
				R.forceMove(T)



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
