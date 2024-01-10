//I would like to do what beestation does and make both this and narsie be children of /eldritch but that would make this very non-modular
GLOBAL_DATUM(cult_ratvar, /obj/ratvar)

#define RATVAR_CONSUME_RANGE 12
#define RATVAR_GRAV_PULL 10
#define RATVAR_SINGULARITY_SIZE 11

/obj/ratvar
	name = "ratvar, the Clockwork Justicar"
	desc = "Oh, that's ratvar!"
	icon = 'monkestation/icons/obj/clock_cult/512x512.dmi'
	icon_state = "ratvar"
	anchored = TRUE
	density = FALSE
	appearance_flags = LONG_GLIDE
	plane = MASSIVE_OBJ_PLANE
	light_color = COLOR_ORANGE
	light_power = 1 //slightly brighter then narsie
	light_outer_range = 20
	move_resist = INFINITY
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION
	pixel_x = -236
	pixel_y = -256
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = SUPERMATTER_IGNORES_1

	/// The singularity component to move around Rat'var.
	/// A weak ref in case an admin removes the component to preserve the functionality.
	var/datum/weakref/singularity

	///next world tick we can attack our narsie target if we have one
	var/next_attack_tick = 0

/obj/ratvar/Initialize(mapload)
	SSpoints_of_interest.make_point_of_interest(src)

	singularity = WEAKREF(AddComponent(
		/datum/component/singularity, \
		bsa_targetable = FALSE, \
		consume_callback = CALLBACK(src, PROC_REF(consume)), \
		consume_range = RATVAR_CONSUME_RANGE, \
		disregard_failed_movements = TRUE, \
		grav_pull = RATVAR_GRAV_PULL, \
		roaming = TRUE, \
		singularity_size = RATVAR_SINGULARITY_SIZE, \
	))

	log_game("!!! RATVAR HAS RISEN. !!!")
	GLOB.cult_ratvar = src
	. = ..()
	desc = "[text2ratvar("That's Ratvar, the Clockwork Justicar. The great one has risen.")]"
	sound_to_playing_players('monkestation/sound/effects/ratvar_reveal.ogg', 100)
	send_to_playing_players(span_reallybig(span_ratvar("The bluespace veil gives way to Rat'var, his light shall shine upon all mortals!")))
	UnregisterSignal(src, COMSIG_ATOM_BSA_BEAM)
	SSshuttle.registerHostileEnvironment(src)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(clockcult_ending_start)), 5 SECONDS)
	if(GLOB.narsie_breaching_rune)
		if(istype(GLOB.narsie_breaching_rune, /obj/effect/rune/narsie))
			new /obj/narsie(get_turf(GLOB.narsie_breaching_rune))
		else
			new /obj/narsie(get_safe_random_station_turf())

	var/area/area = get_area(src)
	if(area)
		var/mutable_appearance/alert_overlay = mutable_appearance('monkestation/icons/obj/clock_cult/clockwork_effects.dmi', "ratvar_alert")
		notify_ghosts("Rat'var has risen in [area]. Reach out to the Justicar to be given a new shell for your soul.", source = src, \
					alert_overlay = alert_overlay, action = NOTIFY_PLAY)
	gods_battle()
	START_PROCESSING(SSobj, src)

/obj/ratvar/Destroy(force, ...)
	if(GLOB.cult_ratvar == src)
		GLOB.cult_ratvar = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/ratvar/process(seconds_per_tick)
	var/datum/component/singularity/singularity_component = singularity?.resolve()
	if(GLOB.cult_narsie)
		singularity_component?.target = GLOB.cult_narsie
		if(get_dist(src, GLOB.cult_narsie) < 5)
			if(next_attack_tick < world.time)
				next_attack_tick = world.time + rand(50, 100)
				send_to_playing_players(span_danger("[pick("Reality shudders around you.","You hear the tearing of flesh.","The sound of bones cracking fills the air.")]"))
				sound_to_playing_players('sound/magic/clockwork/ratvar_attack.ogg',100)
				explosion(GLOB.cult_narsie, 0, 2, 6)
				SpinAnimation(4, 0)

				for(var/mob/living/living_player in GLOB.player_list)
					shake_camera(living_player, 2.5 SECONDS, 5)
					living_player.Knockdown(1 SECONDS)

				if(prob(max(length(GLOB.main_clock_cult?.members)/2, 15)))
					sound_to_playing_players('sound/magic/demon_dies.ogg', 100)
					qdel(GLOB.cult_narsie)
					send_to_playing_players(span_ratvar("You were a fool for underestimating me..."))
					for(var/datum/mind/cultist_mind in get_antag_minds(/datum/antagonist/cult))
						to_chat(cultist_mind, span_userdanger("You feel a stabbing pain in your chest... This can't be happening!"))
						cultist_mind.current?.dust()
		return

/obj/ratvar/Bump(atom/the_atom)
	var/turf/the_turf = get_turf(the_atom)
	if(the_turf == loc)
		the_turf = get_step(the_atom, the_atom.dir) //please don't slam into a window like a bird, Ratvar
	forceMove(the_turf)

/obj/ratvar/attack_ghost(mob/user)
	if(!user.mind) //this should not happen but just to be safe
		return
	. = ..()
	var/mob/living/basic/drone/created_drone = new /mob/living/basic/drone/cogscarab(get_turf(src))
	created_drone.flags_1 |= (flags_1 & ADMIN_SPAWNED_1)
	user.mind.transfer_to(created_drone, TRUE)

/obj/ratvar/proc/consume(atom/consumed)
	consumed.ratvar_act()

#undef RATVAR_CONSUME_RANGE
#undef RATVAR_GRAV_PULL
#undef RATVAR_SINGULARITY_SIZE

/obj/narsie
	///next world tick we can attack our ratvar target if we have one
	var/next_attack_tick = 0

/proc/clockcult_ending_start()
	SSsecurity_level.set_level(3)
	priority_announce("Huge gravitational-energy spike detected emminating from a neutron star near your sector. Event has been determined to be survivable by 0% of life. \
					   ESTIMATED TIME UNTIL ENERGY PULSE REACHES [GLOB.station_name]: 56 SECONDS. Godspeed crew, glory to Nanotrasen. -Admiral Telvig.", \
					   "Central Command Anomolous Materials Division", 'sound/misc/airraid.ogg')
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(clockcult_pre_ending)), 50 SECONDS)

/proc/clockcult_pre_ending()
	priority_announce("Station [GLOB.station_name] is in the wa#e %o[text2ratvar("YOU WILL SEE THE LIGHT")] action imminent. Glory[text2ratvar(" TO ENG'INE")].", \
					  "Central Command Anomolous Materials Division", 'sound/machines/alarm.ogg')
	for(var/mob/player_mob in GLOB.player_list)
		if(player_mob.client)
			player_mob.client.color = COLOR_WHITE
			animate(player_mob.client, color = LIGHT_COLOR_CLOCKWORK, time = 135)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(clockcult_final_ending)), 135)

/proc/clockcult_final_ending()
	SSshuttle.lockdown = TRUE
	for(var/mob/lit_mob in GLOB.mob_list)
		if(lit_mob.client)
			lit_mob.client.color = LIGHT_COLOR_CLOCKWORK
			animate(lit_mob.client, color=COLOR_WHITE, time = 5)
			SEND_SOUND(lit_mob, sound(null))
			SEND_SOUND(lit_mob, sound('sound/magic/fireball.ogg'))
		if(!IS_CLOCK(lit_mob) && isliving(lit_mob))
			var/mob/living/very_lit_mob = lit_mob
			very_lit_mob.fire_stacks = 1000
			very_lit_mob.ignite_mob()
			very_lit_mob.emote("scream")
	sleep(1.5 SECONDS)
	SSticker.force_ending = TRUE

//ratvar_act stuff

/atom/proc/ratvar_act()
	SEND_SIGNAL(src, COMSIG_ATOM_RATVAR_ACT)

/obj/structure/lattice/ratvar_act()
	var/our_loc = loc
	qdel(src)
	new /obj/structure/lattice/clockwork(our_loc)

/obj/item/stack/sheet/iron/ratvar_act()
	new /obj/item/stack/sheet/bronze(loc, amount)
	qdel(src)

/obj/item/stack/sheet/runed_metal/ratvar_act()
	new /obj/item/stack/sheet/bronze(loc, amount)
	qdel(src)

/turf/ratvar_act(force, ignore_mobs)
	. = (prob(60) || force)
	for(var/atom/checked_atom in src)
		if(ignore_mobs && ismob(checked_atom))
			continue
		if(ismob(checked_atom) || .)
			checked_atom.ratvar_act()

/turf/open/floor/ratvar_act(force, ignore_mobs)
	. = ..()
	if(.)
		ChangeTurf(/turf/open/indestructible/reebe_flooring, flags = CHANGETURF_INHERIT_AIR)

/turf/closed/wall/ratvar_act(force, ignore_mobs)
	. = ..()
	if(.)
		ChangeTurf(/turf/closed/wall/clockwork)

/obj/structure/chair/ratvar_act()
	new /obj/structure/chair/bronze(get_turf(src))
	qdel(src)

/obj/structure/chair/bronze/ratvar_act()
	return

/obj/structure/window/ratvar_act()
	if(!fulltile)
		new/obj/structure/window/reinforced/clockwork(get_turf(src), dir)
	else
		new/obj/structure/window/reinforced/clockwork/fulltile(get_turf(src))
	qdel(src)

/obj/structure/table/ratvar_act()
	var/atom/location = loc
	qdel(src)
	new /obj/structure/table/bronze(location)

/obj/structure/table/bronze/ratvar_act()
	return

/obj/machinery/door/airlock/ratvar_act() //Airlocks become clock airlocks that only allow servants
	var/obj/machinery/door/airlock/bronze/clock/made_door
	if(glass)
		made_door = new/obj/machinery/door/airlock/bronze/clock/glass(get_turf(src))
	else
		made_door = new/obj/machinery/door/airlock/bronze/clock(get_turf(src))
	made_door.name = name
	qdel(src)

/obj/machinery/computer
	///used for tracking ratvar_act() and narsie_act()
	var/clockwork = FALSE

/obj/machinery/computer/ratvar_act()
	if(!clockwork)
		clockwork = TRUE
		icon_screen = "ratvar[rand(1, 3)]"
		icon_keyboard = "ratvar_key[rand(1, 2)]"
		icon_state = "ratvarcomputer"
		update_appearance()
