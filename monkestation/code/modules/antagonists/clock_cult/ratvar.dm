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
	light_range = 20
	move_resist = INFINITY
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION
	pixel_x = -236
	pixel_y = -256
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = SUPERMATTER_IGNORES_1

	/// The singularity component to move around Rat'var.
	/// A weak ref in case an admin removes the component to preserve the functionality.
	var/datum/weakref/singularity

	///what god are we currently trying to target
//	var/target_god
	///can we attack our target yet
//	var/next_attack_tick

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
	SEND_SOUND(world, 'monkestation/sound/effects/ratvar_reveal.ogg')
	send_to_playing_players(span_ratvar("The bluespace veil gives way to Ratvar, his light shall shine upon all mortals!"))
	UnregisterSignal(src, COMSIG_ATOM_BSA_BEAM)
	SSshuttle.registerHostileEnvironment(src)

	var/area/area = get_area(src)
	if(area)
		notify_ghosts("Rat'var has risen in [area]. Reach out to the Justicar to be given a new shell for your soul.", source = src, action = NOTIFY_ATTACK)
//	check_gods_battle() todo

/obj/ratvar/proc/consume(atom/consumed)
	consumed.ratvar_act()

//tasty, once again god battle stuff so todo
/*/obj/eldritch/ratvar/process(delta_time)
	var/datum/component/singularity/singularity_component = singularity.resolve()
	if(ratvar_target)
		singularity_component?.target = ratvar_target
		if(get_dist(src, ratvar_target) < 5)
			if(next_attack_tick < world.time)
				next_attack_tick = world.time + rand(50, 100)
				to_chat(world, "<span class='danger'>[pick("Reality shudders around you.","You hear the tearing of flesh.","The sound of bones cracking fills the air.")]</span>")
				SEND_SOUND(world, 'sound/magic/clockwork/ratvar_attack.ogg')
				SpinAnimation(4, 0)
				for(var/mob/living/M in GLOB.player_list)
					shake_camera(M, 25, 6)
					M.Knockdown(5 * delta_time)
				if(prob(max(GLOB.servants_of_ratvar.len/2, 15)))
					SEND_SOUND(world, 'sound/magic/demon_dies.ogg')
					to_chat(world, "<span class='ratvar'>You were a fool for underestimating me...</span>")
					qdel(ratvar_target)
					for(var/datum/mind/M as() in SSticker.mode?.cult)
						to_chat(M, "<span class='userdanger'>You feel a stabbing pain in your chest... This can't be happening!</span>")
						M.current?.dust()
				return*/

/obj/ratvar/Bump(atom/the_atom)
	var/turf/the_turf = get_turf(the_atom)
	if(the_turf == loc)
		the_turf = get_step(the_atom, the_atom.dir) //please don't slam into a window like a bird, Ratvar
	forceMove(the_turf)

/obj/ratvar/attack_ghost(mob/user)
	if(!user.mind) //this should not happen but just to be safe
		return
	. = ..()
	var/mob/living/simple_animal/drone/created_drone = new /mob/living/simple_animal/drone/cogscarab(get_turf(src))
	created_drone.flags_1 |= (flags_1 & ADMIN_SPAWNED_1)
	user.mind.transfer_to(created_drone, TRUE)

#undef RATVAR_CONSUME_RANGE
#undef RATVAR_GRAV_PULL
#undef RATVAR_SINGULARITY_SIZE

//ratvar_act stuff

/atom/proc/ratvar_act()
	SEND_SIGNAL(src, COMSIG_ATOM_RATVAR_ACT)

/obj/structure/lattice/ratvar_act()
	new /obj/structure/lattice/clockwork(loc)
	qdel(src)

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

/turf/open/ratvar_act(force, ignore_mobs)
	. = ..()
	if(.)
		ChangeTurf(/turf/open/indestructible/reebe_flooring, flags = CHANGETURF_INHERIT_AIR)

/*/obj/machinery/computer/ratvar_act()
	if(!clockwork)
		clockwork = TRUE
		icon_screen = "ratvar[rand(1, 3)]"
		icon_keyboard = "ratvar_key[rand(1, 2)]"
		icon_state = "ratvarcomputer"
		broken_overlay_emissive = TRUE
		update_appearance()*/

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

/obj/machinery/door/airlock/ratvar_act() //Airlocks become clock airlocks that only allow servants
	var/obj/machinery/door/airlock/bronze/clock/made_door
	if(glass)
		made_door = new/obj/machinery/door/airlock/bronze/clock/glass(get_turf(src))
	else
		made_door = new/obj/machinery/door/airlock/bronze/clock(get_turf(src))
	made_door.name = name
	qdel(src)

/obj/structure/table/ratvar_act()
	var/atom/location = loc
	qdel(src)
	new /obj/structure/table/bronze(location)

/obj/structure/table/bronze/ratvar_act()
	return
