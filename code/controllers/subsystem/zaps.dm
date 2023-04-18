//Subsystem processing.

//Return values for zap processing.
///Stop the zap, remove from processing and delete the zap.
#define KILL_ZAP 0
///Stop zap processing for the tick.
#define STOP_ZAP 1
///End of zap process loop. Will let the zap to process again in the same tick.
#define CONTINUE_ZAP 2

SUBSYSTEM_DEF(zaps)
	name = "Zaps"
	flags = SS_BACKGROUND | SS_NO_INIT
	wait = 0.05 SECONDS

	///List of zaps to be processed.
	var/list/processing = list()

/datum/controller/subsystem/zaps/fire(resumed)
	while(processing.len)
		var/datum/zap_information/zap_information = processing[1]
		var/zap_result = zap_information.zap()
		if(zap_result == KILL_ZAP)
			processing.Cut(1,2)
		if(zap_result == STOP_ZAP || MC_TICK_CHECK)
			return


//Zap procs and defines below here.
//Zap constants, speeds up targeting
#define BIKE (COIL + 1)
#define COIL (ROD + 1)
#define ROD (RIDE + 1)
#define RIDE (LIVING + 1)
#define LIVING (MACHINERY + 1)
#define MACHINERY (BLOB + 1)
#define BLOB (STRUCTURE + 1)
#define STRUCTURE (OBJECT + 1)
#define OBJECT (LOWEST + 1)
#define LOWEST (1)

/datum/controller/subsystem/zaps/proc/process_zap(datum/zap_information/zap = src)
	var/atom/source = zap.source
	if(QDELETED(source))
		return KILL_ZAP
	var/zap_flags = zap.zap_flags
	var/list/shocked_targets = zap.shocked_targets.Copy()
	if(!(zap_flags & ZAP_ALLOW_DUPLICATES))
		LAZYSET(shocked_targets, source, TRUE) //I don't want no null refs in my list yeah?
	. = source.dir
	var/power = zap.power
	if(power < 1000)
		return KILL_ZAP

	/*
	THIS IS SO FUCKING UGLY AND I HATE IT, but I can't make it nice without making it slower, check*N rather then n. So we're stuck with it.
	*/
	var/zap_range = zap.zap_range
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
	//I hate existance
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
		return KILL_ZAP
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
		power = closest_atom.zap_act(power, zap_flags)


	if(prob(20))//I know I know
		var/list/shocked_copy = shocked_targets.Copy()
		tesla_zap(closest_atom, next_range, power * 0.5, zap_flags, shocked_copy, TRUE)//Normally I'd copy here so grounding rods work properly, but it fucks with movement


	zap.zap_range = next_range
	zap.source = source
	zap.shocked_targets = shocked_targets

	if(MC_TICK_CHECK)
		return STOP_ZAP

	return CONTINUE_ZAP


/datum/controller/subsystem/zaps/proc/process_supermatter_zap(datum/zap_information/supermatter/supermatter_zap_information = src)
	var/atom/zapstart = supermatter_zap_information.zapstart
	if(QDELETED(zapstart))
		return KILL_ZAP

	. = zapstart.dir
	var/zap_str = supermatter_zap_information.zap_str
	var/zap_cutoff = supermatter_zap_information.zap_cutoff
	//If the strength of the zap decays past the cutoff, we stop
	if(zap_str < zap_cutoff)
		return KILL_ZAP

	var/range = supermatter_zap_information.range
	var/zap_flags = supermatter_zap_information.zap_flags
	var/list/targets_hit = supermatter_zap_information.targets_hit.Copy()
	var/power_level = supermatter_zap_information.power_level
	var/zap_icon = supermatter_zap_information.zap_icon
	var/color = supermatter_zap_information.color
	var/atom/target
	var/target_type = LOWEST
	var/list/arc_targets = list()
	//Making a new copy so additons further down the recursion do not mess with other arcs
	//Lets put this ourself into the do not hit list, so we don't curve back to hit the same thing twice with one arc
	for(var/atom/test as anything in oview(zapstart, range))
		if(!(zap_flags & ZAP_ALLOW_DUPLICATES) && LAZYACCESS(targets_hit, test))
			continue

		if(istype(test, /obj/vehicle/ridden/bicycle/))
			var/obj/vehicle/ridden/bicycle/bike = test
			if(!HAS_TRAIT(bike, TRAIT_BEING_SHOCKED) && bike.can_buckle)//God's not on our side cause he hates idiots.
				if(target_type != BIKE)
					arc_targets = list()
				arc_targets += test
				target_type = BIKE

		if(target_type > COIL)
			continue

		if(istype(test, /obj/machinery/power/energy_accumulator/tesla_coil/))
			var/obj/machinery/power/energy_accumulator/tesla_coil/coil = test
			if(!HAS_TRAIT(coil, TRAIT_BEING_SHOCKED) && coil.anchored && !coil.panel_open && prob(70))//Diversity of death
				if(target_type != COIL)
					arc_targets = list()
				arc_targets += test
				target_type = COIL

		if(target_type > ROD)
			continue

		if(istype(test, /obj/machinery/power/energy_accumulator/grounding_rod/))
			var/obj/machinery/power/energy_accumulator/grounding_rod/rod = test
			//We're adding machine damaging effects, rods need to be surefire
			if(rod.anchored && !rod.panel_open)
				if(target_type != ROD)
					arc_targets = list()
				arc_targets += test
				target_type = ROD

		if(target_type > LIVING)
			continue

		if(isliving(test))
			var/mob/living/alive = test
			if(!HAS_TRAIT(alive, TRAIT_TESLA_SHOCKIMMUNE) && !HAS_TRAIT(alive, TRAIT_BEING_SHOCKED) && alive.stat != DEAD && prob(20))//let's not hit all the engineers with every beam and/or segment of the arc
				if(target_type != LIVING)
					arc_targets = list()
				arc_targets += test
				target_type = LIVING

		if(target_type > MACHINERY)
			continue

		if(ismachinery(test))
			if(!HAS_TRAIT(test, TRAIT_BEING_SHOCKED) && prob(40))
				if(target_type != MACHINERY)
					arc_targets = list()
				arc_targets += test
				target_type = MACHINERY

		if(target_type > OBJECT)
			continue

		if(isobj(test))
			if(!HAS_TRAIT(test, TRAIT_BEING_SHOCKED))
				if(target_type != OBJECT)
					arc_targets = list()
				arc_targets += test
				target_type = OBJECT

	if(arc_targets.len)//Pick from our pool
		target = pick(arc_targets)

	if(QDELETED(target))//If we didn't found something
		return KILL_ZAP

	//Do the animation to zap to it from here
	if(!(zap_flags & ZAP_ALLOW_DUPLICATES))
		LAZYSET(targets_hit, target, TRUE)
	zapstart.Beam(target, icon_state=zap_icon, time = 0.5 SECONDS, beam_color = color)
	var/zapdir = get_dir(zapstart, target)
	if(zapdir)
		. = zapdir

	//Going boom should be rareish
	if(prob(80))
		zap_flags &= ~ZAP_MACHINE_EXPLOSIVE
	if(target_type == COIL)
		var/multi = 2
		switch(power_level)//Between 7k and 9k it's 4, above that it's 8
			if(SEVERE_POWER_PENALTY_THRESHOLD to CRITICAL_POWER_PENALTY_THRESHOLD)
				multi = 4
			if(CRITICAL_POWER_PENALTY_THRESHOLD to INFINITY)
				multi = 8
		if(zap_flags & ZAP_SUPERMATTER_FLAGS)
			var/remaining_power = target.zap_act(zap_str * multi, zap_flags)
			zap_str = remaining_power * 0.5 //Coils should take a lot out of the power of the zap
		else
			zap_str /= 3

	else if(isliving(target))//If we got a fleshbag on our hands
		var/mob/living/creature = target
		ADD_TRAIT(creature, TRAIT_BEING_SHOCKED, WAS_SHOCKED)
		addtimer(TRAIT_CALLBACK_REMOVE(creature, TRAIT_BEING_SHOCKED, WAS_SHOCKED), 1 SECONDS)
		//3 shots a human with no resistance. 2 to crit, one to death. This is at at least 10000 power.
		//There's no increase after that because the input power is effectivly capped at 10k
		//Does 1.5 damage at the least
		var/shock_damage = ((zap_flags & ZAP_MOB_DAMAGE) ? (power_level / 200) - 10 : rand(5,10))
		creature.electrocute_act(shock_damage, "Supermatter Discharge Bolt", 1,  ((zap_flags & ZAP_MOB_STUN) ? SHOCK_TESLA : SHOCK_NOSTUN))
		zap_str /= 1.5 //Meatsacks are conductive, makes working in pairs more destructive

	else
		zap_str = target.zap_act(zap_str, zap_flags)

	//This gotdamn variable is a boomer and keeps giving me problems
	var/turf/target_turf = get_turf(target)
	var/pressure = 1
	if(target_turf?.return_air())
		pressure = max(1,target_turf.return_air().return_pressure())
	//We get our range with the strength of the zap and the pressure, the higher the former and the lower the latter the better
	var/new_range = clamp(zap_str / pressure * 10, 2, 7)
	var/child_targets_hit = targets_hit
	if(prob(5))
		zap_str -= (zap_str/10)
		child_targets_hit = targets_hit.Copy() //Pass by ref begone
		supermatter_zap(target, new_range, zap_str, zap_flags, child_targets_hit, zap_cutoff, power_level, zap_icon, color, TRUE)

	//Update supermatter_zap_information as it will get called again.
	supermatter_zap_information.zap_str = zap_str
	supermatter_zap_information.zapstart = target
	supermatter_zap_information.range = new_range
	supermatter_zap_information.targets_hit = child_targets_hit

	if(MC_TICK_CHECK)
		return STOP_ZAP

	return CONTINUE_ZAP

#undef BIKE
#undef COIL
#undef ROD
#undef RIDE
#undef LIVING
#undef MACHINERY
#undef BLOB
#undef STRUCTURE
#undef OBJECT
#undef LOWEST

#undef KILL_ZAP
#undef STOP_ZAP
#undef CONTINUE_ZAP
