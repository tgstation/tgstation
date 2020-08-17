#define TESLA_DEFAULT_POWER 1738260
#define TESLA_MINI_POWER 869130
//Zap constants, speeds up targeting
#define BIKE (COIL + 1)
#define COIL (ROD + 1)
#define ROD (RIDE + 1)
#define RIDE (LIVING + 1)
#define LIVING (MACHINERY + 1)
#define MACHINERY (BLOB + 1)
#define BLOB (STRUCTURE + 1)
#define STRUCTURE (1)

/proc/tesla_zap(atom/source, zap_range = 3, power, zap_flags = ZAP_DEFAULT_FLAGS, list/shocked_targets = list())
	if(QDELETED(source))
		return
	. = source.dir
	if(power < 1000)
		return

	/*
	THIS IS SO FUCKING UGLY AND I HATE IT, but I can't make it nice without making it slower, check*N rather then n. So we're stuck with it.
	*/
	var/atom/closest_atom
	var/closest_type = 0
	var/static/things_to_shock = typecacheof(list(/obj/machinery, /mob/living, /obj/structure, /obj/vehicle/ridden))
	var/static/blacklisted_tesla_types = typecacheof(list(/obj/machinery/atmospherics,
										/obj/machinery/power/emitter,
										/obj/machinery/field/generator,
										/mob/living/simple_animal,
										/obj/machinery/field/containment,
										/obj/structure/disposalpipe,
										/obj/structure/disposaloutlet,
										/obj/machinery/disposal/delivery_chute,
										/obj/machinery/camera,
										/obj/structure/sign,
										/obj/machinery/gateway,
										/obj/structure/lattice,
										/obj/structure/grille,
										/obj/structure/frame/machine))

	//Ok so we are making an assumption here. We assume that view() still calculates from the center out.
	//This means that if we find an object we can assume it is the closest one of its type. This is somewhat of a speed increase.
	//This also means we have no need to track distance, as the doview() proc does it all for us.

	//Darkness fucks oview up hard. I've tried dview() but it doesn't seem to work
	//I hate existance
	for(var/a in typecache_filter_multi_list_exclusion(oview(zap_range+2, source), things_to_shock, blacklisted_tesla_types))
		var/atom/A = a
		if(!(zap_flags & ZAP_ALLOW_DUPLICATES) && LAZYACCESS(shocked_targets, A))
			continue
		if(closest_type >= BIKE)
			break

		else if(istype(A, /obj/vehicle/ridden/bicycle))//God's not on our side cause he hates idiots.
			var/obj/vehicle/ridden/bicycle/B = A
			if(!(B.obj_flags & BEING_SHOCKED) && B.can_buckle)//Gee goof thanks for the boolean
				//we use both of these to save on istype and typecasting overhead later on
				//while still allowing common code to run before hand
				closest_type = BIKE
				closest_atom = B

		else if(closest_type >= COIL)
			continue //no need checking these other things

		else if(istype(A, /obj/machinery/power/tesla_coil))
			var/obj/machinery/power/tesla_coil/C = A
			if(!(C.obj_flags & BEING_SHOCKED))
				closest_type = COIL
				closest_atom = C

		else if(closest_type >= ROD)
			continue

		else if(istype(A, /obj/machinery/power/grounding_rod))
			closest_type = ROD
			closest_atom = A

		else if(closest_type >= RIDE)
			continue

		else if(istype(A,/obj/vehicle/ridden))
			var/obj/vehicle/ridden/R = A
			if(R.can_buckle && !(R.obj_flags & BEING_SHOCKED))
				closest_type = RIDE
				closest_atom = A

		else if(closest_type >= LIVING)
			continue

		else if(isliving(A))
			var/mob/living/L = A
			if(L.stat != DEAD && !(HAS_TRAIT(L, TRAIT_TESLA_SHOCKIMMUNE)) && !(L.flags_1 & SHOCKED_1))
				closest_type = LIVING
				closest_atom = A

		else if(closest_type >= MACHINERY)
			continue

		else if(ismachinery(A))
			var/obj/machinery/M = A
			if(!(M.obj_flags & BEING_SHOCKED))
				closest_type = MACHINERY
				closest_atom = A

		else if(closest_type >= BLOB)
			continue

		else if(istype(A, /obj/structure/blob))
			var/obj/structure/blob/B = A
			if(!(B.obj_flags & BEING_SHOCKED))
				closest_type = BLOB
				closest_atom = A

		else if(closest_type >= STRUCTURE)
			continue

		else if(isstructure(A))
			var/obj/structure/S = A
			if(!(S.obj_flags & BEING_SHOCKED))
				closest_type = STRUCTURE
				closest_atom = A

	//Alright, we've done our loop, now lets see if was anything interesting in range
	if(!closest_atom)
		return
	//common stuff
	source.Beam(closest_atom, icon_state="lightning[rand(1,12)]", time=5, maxdistance = INFINITY)
	if(!(zap_flags & ZAP_ALLOW_DUPLICATES))
		LAZYSET(shocked_targets, closest_atom, TRUE)
	var/zapdir = get_dir(source, closest_atom)
	if(zapdir)
		. = zapdir

	var/next_range = 3
	if(closest_type == COIL)
		next_range = 5

	if(closest_type == LIVING)
		var/mob/living/closest_mob = closest_atom
		closest_mob.set_shocked()
		addtimer(CALLBACK(closest_mob, /mob/living/proc/reset_shocked), 10)
		var/shock_damage = (zap_flags & ZAP_MOB_DAMAGE) ? (min(round(power/600), 90) + rand(-5, 5)) : 0
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
		power = closest_atom.zap_act(power, zap_flags, shocked_targets)
	if(prob(20))//I know I know
		tesla_zap(closest_atom, next_range, power * 0.5, zap_flags, shocked_targets.Copy())//No pass by ref, it's a bad play
		tesla_zap(closest_atom, next_range, power * 0.5, zap_flags, shocked_targets.Copy())
	else
		tesla_zap(closest_atom, next_range, power, zap_flags, shocked_targets)

#undef BIKE
#undef COIL
#undef ROD
#undef RIDE
#undef LIVING
#undef MACHINERY
#undef BLOB
#undef STRUCTURE
