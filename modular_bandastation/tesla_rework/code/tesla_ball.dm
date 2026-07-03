#define TESLA_DEFAULT_ENERGY (1500 MEGA JOULES)
#define TESLA_MINI_ENERGY (200 MEGA JOULES)

#define TESLA_PASSIVE_DECAY_RATIO 0.04
#define TESLA_ZAP_POWER_RATIO 0.1
#define TESLA_MIN_ENERGY (100 MEGA JOULES)
#define TESLA_EMITTER_HIT_ENERGY (45 MEGA JOULES)

//Zap constants, speeds up targeting
#define BIKE (COIL + 1)
#define COIL (ROD + 1)
#define ROD (RIDE + 1)
#define RIDE (BLOB + 1)
#define BLOB (LIVING + 1)
#define LIVING (MACHINERY + 1)
#define MACHINERY (STRUCTURE + 1)
#define STRUCTURE (1)

// The Tesla engine based on energy_ball.dm
/obj/tesla_ball
	name = "тесла шар"
	desc = "Шар энергии, по поверхности которого пробегают небольшие разряды от термоядерных реакций, протекающих в шаре. Unlimited power!"
	icon = 'icons/obj/machines/engine/energy_ball.dmi'
	icon_state = "energy_ball"
	anchored = TRUE
	appearance_flags = LONG_GLIDE
	density = TRUE
	plane = MASSIVE_OBJ_PLANE
	plane = ABOVE_LIGHTING_PLANE
	light_range = 6
	move_resist = INFINITY
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION
	pixel_x = -ICON_SIZE_X
	pixel_y = -ICON_SIZE_Y
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF | SHUTTLE_CRUSH_PROOF
	flags_1 = SUPERMATTER_IGNORES_1
	light_color = "#5e5edd"

	var/energy // Joules
	var/target
	var/list/orbiting_balls = list()
	var/miniball = FALSE

	var/list/shocked_things = list()
	var/hit_heal

	var/temp = 0
	var/total_moles = 0
	var/plasma_moles = 0

	var/list/move_sounds

/obj/tesla_ball/Initialize(mapload, starting_energy = TESLA_DEFAULT_ENERGY, is_miniball = FALSE)
	. = ..()

	energy = starting_energy
	miniball = is_miniball

	if (!is_miniball)
		set_light(10, 7, light_color)

		var/turf/spawned_turf = get_turf(src)
		message_admins("Reworked tesla has been created at [ADMIN_VERBOSEJMP(spawned_turf)].")
		investigate_log("was created at [AREACOORD(spawned_turf)].", INVESTIGATE_ENGINE)

		move_sounds = list(
		'modular_bandastation/tesla_rework/sound/tesla_move_1.ogg',
		'modular_bandastation/tesla_rework/sound/tesla_move_2.ogg',
		'modular_bandastation/tesla_rework/sound/tesla_move_3.ogg'
		)

	START_PROCESSING(SSobj, src)

	RegisterSignal(src, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(check_hit))

/obj/tesla_ball/Destroy()
	if(orbiting && istype(orbiting.parent, /obj/tesla_ball))
		var/obj/tesla_ball/parent_tesla_ball = orbiting.parent
		parent_tesla_ball.orbiting_balls -= src

	QDEL_LIST(orbiting_balls)
	STOP_PROCESSING(SSobj, src)

	return ..()

/obj/tesla_ball/process()
	if(orbiting)
		energy = 0 // ensure we dont have miniballs of miniballs
		return

	// GAS PROCESSING
	//
	process_atmos()
	var/temp_phase_1_clamped = min(temp, 10000) // everything below 10000K
	var/temp_phase_2_over = max(0, temp - 10000) // everything above 10000K

	// 1. Calcualte zap power ratio (ZPR)
	// +0.05 up until 10000K, after +0.5 for each 1000K
	var/zpr_growth_1 = temp_phase_1_clamped * 0.000005
	var/zpr_growth_2 = temp_phase_2_over * 0.0005
	var/zap_ratio = TESLA_ZAP_POWER_RATIO + zpr_growth_1 + zpr_growth_2
	zap_ratio *= plasma_moles * 0.0001

	// 2. Calculate passive decay ratio (PDR)
	// growth only after 10000K, +0.01 for each 1000K
	var/pdr_growth = temp_phase_2_over * 0.00001
	var/decay_ratio = TESLA_PASSIVE_DECAY_RATIO + pdr_growth
	var/passive_decay_amount = energy * decay_ratio

	// 3. Healing coefficent calculated based on how much plasma is on loc turf and its temperature. 0.03 for each 100K above 275K
	var/temp_steps = temp / 100
	var/temp_bonus_joules = temp_steps * 0.03
	// reduce below 275K, if temp > 250K = normal
	var/temp_multiplier = clamp((temp / 275), 0.85, 1.0)
	var/temp_bonus = max(temp_bonus_joules, 0) // отрицательные убираем
	temp_multiplier *= 1.0 + (temp_bonus / TESLA_EMITTER_HIT_ENERGY)

	var/plasma_factor = max(plasma_moles * 0.1, 1)
	hit_heal = TESLA_EMITTER_HIT_ENERGY * temp_multiplier * plasma_factor
	//
	// END GAS PROCESSING

	// PASSIVE DECAY
	energy = max(0, energy - passive_decay_amount)

	// Actual zap power
	var/current_zap_power = energy * zap_ratio

	// Charge visual indicator, mini balls spawn with each 200 MJ because we need some charge visualization
	handle_energy()

	move(4 + orbiting_balls.len * 1.5)
	playsound(src.loc, pick(move_sounds), 100, TRUE, extrarange = 10, pressure_affected = FALSE)

	pixel_x = 0
	pixel_y = 0
	shocked_things.Cut(1, shocked_things.len / 1.3)
	var/list/shocking_info = list()

	tesla_reworked_zap(source = src, zap_range = 3, power = current_zap_power, shocked_targets = shocking_info)
	playsound(src.loc, 'sound/effects/magic/lightningbolt.ogg', 120, TRUE, extrarange = 30, pressure_affected = FALSE)

	// ACTIVE DECAY
	energy = max(0, energy - current_zap_power)

	pixel_x = -ICON_SIZE_X
	pixel_y = -ICON_SIZE_Y

	for (var/ball in orbiting_balls)
		var/range = rand(1, clamp(orbiting_balls.len, 2, 3))
		var/list/temp_shock = list()
		//We zap off the main ball instead of ourselves to make things looks proper
		var/mini_zap_power = (energy / 2) / 7 * range
		tesla_reworked_zap(source = src, zap_range = range, power = mini_zap_power, shocked_targets = temp_shock)
		shocking_info += temp_shock
	shocked_things += shocking_info

/obj/tesla_ball/proc/disperse_event()
	visible_message(span_warning("[src] вспыхивает с жутким треском и растворяется, ионизируя воздух вокруг!"))
	playsound(src, 'modular_bandastation/tesla_rework/sound/tesla_destroy.ogg', 165, TRUE, extrarange = 75, pressure_affected = FALSE)
	qdel(src)

/obj/tesla_ball/proc/check_hit(datum/source, obj/projectile/projectile) // similar to sm proc hit implementation
	SIGNAL_HANDLER

	var/turf/local_turf = loc
	if(!istype(local_turf))
		return NONE

	// safety check
	if (!projectile || QDELETED(projectile))
		return COMPONENT_BULLET_BLOCKED

	if (!istype(projectile.firer, /obj/machinery/power/emitter))
		investigate_log("[src] has been hit by [projectile] fired by [key_name(projectile.firer)]", INVESTIGATE_ENGINE)
		qdel(projectile)
		return COMPONENT_BULLET_BLOCKED

	// adding energy
	var/energy_gain = hit_heal
	energy += energy_gain

	visible_message(span_notice("[src] потрескивает от попадания!"))

	qdel(projectile)
	return COMPONENT_BULLET_BLOCKED

/obj/tesla_ball/proc/process_atmos()
	var/turf/local_turf = loc
	if (!istype(local_turf))
		return 1
	if (isclosedturf(local_turf))
		return 0.1

	var/datum/gas_mixture/env = local_turf.return_air()
	if (!env)
		return 1

	total_moles = env.total_moles()
	temp = env.return_temperature()

	if (env.has_gas(/datum/gas/plasma))
		plasma_moles = env.gases[/datum/gas/plasma][MOLES]

/obj/tesla_ball/examine(mob/user)
	. = ..()
	var/count = orbiting_balls.len
	. += "Вокруг него вращается [count] [declent_ru(count, "мини шар", "мини шара", "мини шаров")]"

/obj/tesla_ball/proc/move(move_amount)
	var/list/dirs = GLOB.alldirs.Copy()
	if(shocked_things.len)
		for (var/i in 1 to 30)
			var/atom/real_thing = pick(shocked_things)
			dirs += get_dir(src, real_thing) //Carry some momentum yeah? Just a bit tho
	for (var/i in 0 to move_amount)
		var/move_dir = pick(dirs) //ensures teslas don't just sit around
		if (target && prob(10))
			move_dir = get_dir(src, target)
		var/turf/turf_to_move = get_step(src, move_dir)
		if (can_move(turf_to_move))
			forceMove(turf_to_move)
			setDir(move_dir)
			for (var/mob/living/carbon/mob_to_dust in loc)
				dust_mobs(mob_to_dust)

/obj/tesla_ball/proc/can_move(turf/to_move)
	if (!to_move)
		return FALSE

	for (var/_thing in to_move)
		var/atom/thing = _thing
		if (SEND_SIGNAL(thing, COMSIG_ATOM_SINGULARITY_TRY_MOVE) & SINGULARITY_TRY_MOVE_BLOCK)
			return FALSE

	return TRUE

/obj/tesla_ball/proc/handle_energy()
	if (energy <= TESLA_MIN_ENERGY)
		disperse_event()

	var/target_miniball_count = round(energy / TESLA_MINI_ENERGY)

	var/current_count = orbiting_balls.len

	if (current_count < target_miniball_count)
		playsound(src.loc, 'sound/effects/magic/lightning_chargeup.ogg', 100, TRUE, extrarange = 30, pressure_affected = FALSE)
		addtimer(CALLBACK(src, PROC_REF(new_mini_ball)), 2 SECONDS)

	else if (current_count > target_miniball_count)
		var/Orchiectomy_target = pick(orbiting_balls)
		qdel(Orchiectomy_target)

/obj/tesla_ball/proc/new_mini_ball()
	if(!loc)
		return

	var/obj/tesla_ball/miniball = new /obj/tesla_ball(
		loc,
		/* starting_energy = */ 0,
		/* is_miniball = */ TRUE
	)

	miniball.transform *= pick(0.3, 0.4, 0.5, 0.6, 0.7)
	var/list/icon_dimensions = get_icon_dimensions(icon)

	var/orbitsize = (icon_dimensions["width"] + icon_dimensions["height"]) * pick(0.4, 0.5, 0.6, 0.7, 0.8)
	orbitsize -= (orbitsize / ICON_SIZE_ALL) * (ICON_SIZE_ALL * 0.25)
	miniball.orbit(src, orbitsize, pick(FALSE, TRUE), rand(10, 25), pick(3, 4, 5, 6, 36))

/obj/tesla_ball/Bump(atom/A)
	dust_mobs(A)

/obj/tesla_ball/Bumped(atom/movable/AM)
	dust_mobs(AM)

/obj/tesla_ball/attack_tk(mob/user)
	if(!iscarbon(user))
		return

	var/mob/living/L = user
	var/mob/living/carbon/jedi = user
	to_chat(jedi, span_userdanger("Это была шокирующе идиотская идея!"))

	ADD_TRAIT(user, TRAIT_BEING_SHOCKED, WAS_SHOCKED)
	addtimer(TRAIT_CALLBACK_REMOVE(user, TRAIT_BEING_SHOCKED, WAS_SHOCKED), 1 SECONDS)

	var/power = energy * 0.1 // That's gonna hurt
	var/shock_damage = min(round(power / 600), 90) + rand(-5, 5)
	L.electrocute_act(shock_damage, src, 1, SHOCK_TESLA | SHOCK_NOSTUN | SHOCK_NOGLOVES)

	if(issilicon(user))
		user.emp_act(EMP_LIGHT)

	playsound(src, 'sound/effects/magic/lightningbolt.ogg', 80, TRUE)
	flash_color(user, "#99ccff", 3)

	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/tesla_ball/orbit(obj/tesla_ball/target)
	if (istype(target))
		target.orbiting_balls += src
	. = ..()

/obj/tesla_ball/stop_orbit()
	if (orbiting && istype(orbiting.parent, /obj/tesla_ball))
		var/obj/tesla_ball/orbitingball = orbiting.parent
		orbitingball.orbiting_balls -= src
	. = ..()
	if (!QDELETED(src))
		qdel(src)


/obj/tesla_ball/proc/dust_mobs(atom/A)
	if(isliving(A))
		var/mob/living/living = A
		if(living.incorporeal_move || HAS_TRAIT(living, TRAIT_GODMODE))
			return
	if(!iscarbon(A))
		return
	for(var/obj/machinery/power/energy_accumulator/grounding_rod/GR in orange(src, 2))
		if(GR.anchored)
			return
	var/mob/living/carbon/C = A
	C.investigate_log("has been dusted by an energy ball.", INVESTIGATE_DEATHS)
	C.dust()

/proc/tesla_reworked_zap(atom/source, zap_range = 3, power, cutoff = 4e5, zap_flags = ZAP_TESLA_FLAGS, list/shocked_targets = list())
	if(QDELETED(source))
		return
	if(!(zap_flags & ZAP_ALLOW_DUPLICATES))
		LAZYSET(shocked_targets, source, TRUE) //I don't want no null refs in my list yeah?
	. = source.dir
	if(power < cutoff)
		return

	/*
	THIS IS SO FUCKING UGLY AND I HATE IT, but I can't make it nice without making it slower, check*N rather then n. So we're stuck with it.
	*/
	var/atom/closest_atom
	var/closest_type = 0
	var/static/list/things_to_shock = zebra_typecacheof(list(
		// Things that we want to shock.
		/obj/machinery = TRUE,
		/mob/living = TRUE,
		/obj/structure = TRUE,
		/obj/vehicle/ridden = TRUE,

		// Things that we don't want to shock.
		/obj/machinery/atmospherics = FALSE,
		/obj/machinery/portable_atmospherics = FALSE,
		/obj/machinery/power/emitter = FALSE,
		/obj/machinery/field/generator = FALSE,
		/obj/machinery/field/containment = FALSE,
		/obj/machinery/camera = FALSE,
		/obj/machinery/gateway = FALSE,
		/mob/living/simple_animal = FALSE,
		/obj/structure/disposalpipe = FALSE,
		/obj/structure/disposaloutlet = FALSE,
		/obj/machinery/disposal/delivery_chute = FALSE,
		/obj/structure/sign = FALSE,
		/obj/structure/lattice = FALSE,
		/obj/structure/grille = FALSE,
		/obj/structure/frame/machine = FALSE,
	))

	//Ok so we are making an assumption here. We assume that view() still calculates from the center out.
	//This means that if we find an object we can assume it is the closest one of its type. This is somewhat of a speed increase.
	//This also means we have no need to track distance, as the doview() proc does it all for us.

	//Darkness fucks oview up hard. I've tried dview() but it doesn't seem to work
	//I hate existence
	for(var/atom/A as anything in typecache_filter_list(oview(zap_range+2, source), things_to_shock))
		if(!(zap_flags & ZAP_ALLOW_DUPLICATES) && LAZYACCESS(shocked_targets, A))
			continue
		// NOTE: these type checks are safe because CURRENTLY the range family of procs returns turfs in least to greatest distance order
		// This is unspecified behavior tho, so if it ever starts acting up just remove these optimizations and include a distance check
		if(closest_type >= BIKE)
			break

		else if(istype(A, /obj/vehicle/ridden/bicycle))//God's not on our side cause he hates idiots.
			var/obj/vehicle/ridden/bicycle/B = A
			if(!HAS_TRAIT(B, TRAIT_BEING_SHOCKED) && B.can_buckle)//Gee goof thanks for the boolean
				//we use both of these to save on istype and typecasting overhead later on
				//while still allowing common code to run before hand
				closest_type = BIKE
				closest_atom = B

		else if(closest_type >= COIL)
			continue //no need checking these other things

		else if(istype(A, /obj/machinery/power/energy_accumulator/tesla_coil))
			if(!HAS_TRAIT(A, TRAIT_BEING_SHOCKED))
				closest_type = COIL
				closest_atom = A

		else if(closest_type >= ROD)
			continue

		else if(istype(A, /obj/machinery/power/energy_accumulator/grounding_rod))
			closest_type = ROD
			closest_atom = A

		else if(closest_type >= RIDE)
			continue

		else if(istype(A,/obj/vehicle/ridden))
			var/obj/vehicle/ridden/R = A
			if(R.can_buckle && !HAS_TRAIT(R, TRAIT_BEING_SHOCKED))
				closest_type = RIDE
				closest_atom = A

		else if(closest_type >= LIVING)
			continue

		else if(isliving(A))
			var/mob/living/L = A
			if(L.stat != DEAD && !HAS_TRAIT(L, TRAIT_TESLA_SHOCKIMMUNE) && !HAS_TRAIT(L, TRAIT_BEING_SHOCKED))
				closest_type = LIVING
				closest_atom = A

		else if(closest_type >= MACHINERY)
			continue

		else if(ismachinery(A))
			if(!HAS_TRAIT(A, TRAIT_BEING_SHOCKED))
				closest_type = MACHINERY
				closest_atom = A

		else if(closest_type >= BLOB)
			continue

		else if(istype(A, /obj/structure/blob))
			if(!HAS_TRAIT(A, TRAIT_BEING_SHOCKED))
				closest_type = BLOB
				closest_atom = A

		else if(closest_type >= STRUCTURE)
			continue

		else if(isstructure(A))
			if(!HAS_TRAIT(A, TRAIT_BEING_SHOCKED))
				closest_type = STRUCTURE
				closest_atom = A

	//Alright, we've done our loop, now lets see if was anything interesting in range
	if(!closest_atom)
		return
	//common stuff
	source.Beam(closest_atom, icon_state="lightning[rand(1,12)]", time = 5)
	var/zapdir = get_dir(source, closest_atom)
	if(zapdir)
		. = zapdir

	var/next_range = 2
	if(closest_type == COIL)
		next_range = 5

	if(closest_type == LIVING)
		var/mob/living/closest_mob = closest_atom
		ADD_TRAIT(closest_mob, TRAIT_BEING_SHOCKED, WAS_SHOCKED)
		addtimer(TRAIT_CALLBACK_REMOVE(closest_mob, TRAIT_BEING_SHOCKED, WAS_SHOCKED), 1 SECONDS)
		var/shock_damage = (zap_flags & ZAP_MOB_DAMAGE) ? (min(round(power / 600), 90) + rand(-5, 5)) : 0
		closest_mob.electrocute_act(shock_damage, source, 1, SHOCK_TESLA | ((zap_flags & ZAP_MOB_STUN) ? NONE : SHOCK_NOSTUN))
		if(issilicon(closest_mob))
			var/mob/living/silicon/S = closest_mob
			if((zap_flags & ZAP_MOB_STUN) && (zap_flags & ZAP_MOB_DAMAGE))
				S.emp_act(EMP_LIGHT)
			next_range = 7 // metallic folks bounce it further
		else
			next_range = 5
		power /= 1.5

	else
		power = closest_atom.zap_act(power, zap_flags)

	// Electrolysis.
	var/turf/target_turf = get_turf(closest_atom)
	if(target_turf?.return_air())
		var/datum/gas_mixture/air_mixture = target_turf.return_air()
		air_mixture.electrolyze(working_power = power / 200)
		target_turf.air_update_turf()

	if(prob(20))//I know I know
		var/list/shocked_copy = shocked_targets.Copy()
		tesla_reworked_zap(source = closest_atom, zap_range = next_range, power = power * 0.5, cutoff = cutoff, zap_flags = zap_flags, shocked_targets = shocked_copy)
		tesla_reworked_zap(source = closest_atom, zap_range = next_range, power = power * 0.5, cutoff = cutoff, zap_flags = zap_flags, shocked_targets = shocked_targets)
		shocked_targets += shocked_copy
	else
		tesla_reworked_zap(source = closest_atom, zap_range = next_range, power = power, cutoff = cutoff, zap_flags = zap_flags, shocked_targets = shocked_targets)

#undef BIKE
#undef COIL
#undef ROD
#undef RIDE
#undef LIVING
#undef MACHINERY
#undef BLOB
#undef STRUCTURE

#undef TESLA_DEFAULT_ENERGY
#undef TESLA_MINI_ENERGY

#undef TESLA_PASSIVE_DECAY_RATIO
#undef TESLA_ZAP_POWER_RATIO
#undef TESLA_MIN_ENERGY
#undef TESLA_EMITTER_HIT_ENERGY

