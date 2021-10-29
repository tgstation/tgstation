/obj/structure/biohazard_blob
	anchored = TRUE
	var/datum/biohazard_blob_controller/our_controller
	var/blob_type

/obj/structure/biohazard_blob/Destroy()
	our_controller = null
	playsound(src.loc, 'sound/effects/splat.ogg', 30, TRUE)
	return ..()

/obj/structure/biohazard_blob/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/effects/attackblob.ogg', 100, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/biohazard_blob/Initialize(mapload, passed_blob_type)
	. = ..()
	if(passed_blob_type)
		blob_type = passed_blob_type
	switch(blob_type)
		if(BIO_BLOB_TYPE_FUNGUS)
			color = "#A85"
		if(BIO_BLOB_TYPE_FIRE)
			color = "#C50"
			resistance_flags = FIRE_PROOF
		if(BIO_BLOB_TYPE_EMP)
			color = "#0B9"
		if(BIO_BLOB_TYPE_TOXIC)
			color = "#480"
			resistance_flags = UNACIDABLE | ACID_PROOF
		if(BIO_BLOB_TYPE_RADIOACTIVE)
			color = "#80ff00"
			resistance_flags = ACID_PROOF | FIRE_PROOF //Shit's gonna get hot

/obj/structure/biohazard_blob/structure
	density = TRUE

/datum/looping_sound/core_heartbeat
	mid_length = 3 SECONDS
	mid_sounds = list('modular_skyrat/master_files/sound/effects/heart_beat_loop3.ogg'=1)
	volume = 20

#define CORE_RETALIATION_COOLDOWN 5 SECONDS

/obj/structure/biohazard_blob/structure/core
	name = "glowing core"
	icon = 'modular_skyrat/modules/biohazard_blob/icons/blob_core.dmi'
	icon_state = "blob_core"
	layer = TABLE_LAYER
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_LAVA
	max_integrity = 1200
	var/datum/looping_sound/core_heartbeat/soundloop
	var/next_retaliation = 0

/obj/structure/biohazard_blob/structure/core/fungus
	blob_type = BIO_BLOB_TYPE_FUNGUS

/obj/structure/biohazard_blob/structure/core/fire
	blob_type = BIO_BLOB_TYPE_FIRE

/obj/structure/biohazard_blob/structure/core/emp
	blob_type = BIO_BLOB_TYPE_EMP

/obj/structure/biohazard_blob/structure/core/toxic
	blob_type = BIO_BLOB_TYPE_TOXIC

/obj/structure/biohazard_blob/structure/core/radioactive
	blob_type = BIO_BLOB_TYPE_RADIOACTIVE

/obj/structure/biohazard_blob/structure/core/Initialize()
	if(!blob_type)
		blob_type = pick(ALL_BIO_BLOB_TYPES)
	. = ..()
	new /datum/biohazard_blob_controller(src, blob_type)
	soundloop = new(list(src),  TRUE)
	update_overlays()

/obj/structure/biohazard_blob/structure/core/Destroy()
	if(our_controller)
		our_controller.our_core = null
	soundloop.stop()
	QDEL_NULL(soundloop)
	return ..()

/obj/structure/biohazard_blob/structure/core/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_amount > 10 && world.time > next_retaliation && prob(40))
		if(our_controller)
			our_controller.CoreRetaliated()
		next_retaliation = world.time + CORE_RETALIATION_COOLDOWN
		//The core should try and seal the room its in, to prevent ranged cheese?
		//Add maybe a melee attack too?
		var/turf/my_turf = get_turf(src)
		switch(blob_type)
			if(BIO_BLOB_TYPE_FUNGUS)
				visible_message("<span class='warning'>The [src] emitts a cloud!</span>")
				var/datum/reagents/R = new/datum/reagents(300)
				R.my_atom = src
				R.add_reagent(/datum/reagent/cordycepsspores, 50)
				var/datum/effect_system/smoke_spread/chem/smoke = new()
				smoke.set_up(R, 5)
				smoke.attach(src)
				smoke.start()
			if(BIO_BLOB_TYPE_FIRE)
				visible_message("<span class='warning'>The [src] puffs a cloud of flames!</span>")
				my_turf.atmos_spawn_air("o2=20;plasma=20;TEMP=600")
			if(BIO_BLOB_TYPE_EMP)
				visible_message("<span class='warning'>The [src] sends out electrical discharges!</span>")
				empulse(src, 5, 10)
				if(prob(50))
					for(var/mob/living/M in get_hearers_in_view(3, my_turf))
						if(M.flash_act(affect_silicon = 1))
							M.Paralyze(20)
							M.Knockdown(20)
						M.soundbang_act(1, 20, 10, 5)
				else
					do_sparks(3, TRUE, src)
					tesla_zap(src, 4, 10000, ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE)
			if(BIO_BLOB_TYPE_TOXIC)
				visible_message("<span class='warning'>The [src] spews out foam!</span>")
				var/datum/reagents/R = new/datum/reagents(300)
				R.my_atom = src
				R.add_reagent(/datum/reagent/toxin, 30)
				var/datum/effect_system/foam_spread/foam = new
				foam.set_up(40, my_turf, R)
				foam.start()
			if(BIO_BLOB_TYPE_RADIOACTIVE)
				visible_message("<span class='warning'>The [src] emits a strong radiation pulse!</span>")
				radiation_pulse(src, 1500, 10, FALSE, TRUE)
				var/datum/reagents/R = new/datum/reagents(300)
				R.my_atom = src
				R.add_reagent(/datum/reagent/toxin/mutagen, 50)
				var/datum/effect_system/foam_spread/foam = new
				foam.set_up(50, my_turf, R)
				foam.start()
	return ..()

/obj/structure/biohazard_blob/structure/core/update_overlays()
	. = ..()
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	SSvis_overlays.add_vis_overlay(src, icon, "blob_core_overlay", layer, plane, dir, alpha)
	SSvis_overlays.add_vis_overlay(src, icon, "blob_core_overlay", 0, EMISSIVE_PLANE, dir, alpha)
	var/obj/effect/overlay/vis/overlay1 = managed_vis_overlays[1]
	var/obj/effect/overlay/vis/overlay2 = managed_vis_overlays[2]
	overlay1.appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_COLOR
	overlay2.appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_COLOR

#undef CORE_RETALIATION_COOLDOWN

/obj/structure/biohazard_blob/resin
	name = "mold"
	desc = "It looks like mold, but it seems alive."
	icon = 'modular_skyrat/modules/biohazard_blob/icons/blob_resin.dmi'
	icon_state = "blob_floor"
	density = FALSE
	plane = FLOOR_PLANE
	layer = ABOVE_NORMAL_TURF_LAYER
	max_integrity = 50
	var/blooming = FALSE
	//Are we a floor resin? If not then we're a wall resin
	var/floor = TRUE

/obj/structure/biohazard_blob/resin/Initialize(mapload, passed_blob_type)
	. = ..()
	switch(blob_type)
		if(BIO_BLOB_TYPE_FUNGUS)
			desc += " It looks like it's rotting."
		if(BIO_BLOB_TYPE_FIRE)
			desc += " It feels hot to the touch."
		if(BIO_BLOB_TYPE_EMP)
			desc += " You can notice small sparks travelling in the vines."
		if(BIO_BLOB_TYPE_TOXIC)
			desc += " It feels damp and smells of rat poison."
		if(BIO_BLOB_TYPE_RADIOACTIVE)
			desc += " It glows softly."

/obj/structure/biohazard_blob/resin/update_overlays()
	. = ..()
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	if(blooming)
		SSvis_overlays.add_vis_overlay(src, icon, "[icon_state]_overlay", layer, plane, dir, alpha)
		SSvis_overlays.add_vis_overlay(src, icon, "[icon_state]_overlay", 0, EMISSIVE_PLANE, dir, alpha)
		var/obj/effect/overlay/vis/overlay1 = managed_vis_overlays[1]
		var/obj/effect/overlay/vis/overlay2 = managed_vis_overlays[2]
		overlay1.appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_COLOR
		overlay2.appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_COLOR

/obj/structure/biohazard_blob/resin/proc/CalcDir()
	var/direction = 16
	var/turf/location = loc
	for(var/wallDir in GLOB.cardinals)
		var/turf/newTurf = get_step(location,wallDir)
		if(newTurf && newTurf.density)
			direction |= wallDir

	for(var/obj/structure/biohazard_blob/resin/tomato in location)
		if(tomato == src)
			continue
		if(tomato.floor) //special
			direction &= ~16
		else
			direction &= ~tomato.dir

	var/list/dirList = list()

	for(var/i=1,i<=16,i <<= 1)
		if(direction & i)
			dirList += i

	if(dirList.len)
		var/newDir = pick(dirList)
		if(newDir == 16)
			setDir(pick(GLOB.cardinals))
		else
			floor = FALSE
			setDir(newDir)
			switch(dir) //offset to make it be on the wall rather than on the floor
				if(NORTH)
					pixel_y = 32
				if(SOUTH)
					pixel_y = -32
				if(EAST)
					pixel_x = 32
				if(WEST)
					pixel_x = -32
			icon_state = "blob_wall"
			plane = GAME_PLANE
			layer = ABOVE_NORMAL_TURF_LAYER

	if(prob(7))
		blooming = TRUE
		set_light(2, 1, LIGHT_COLOR_LAVA)
		update_overlays()

/obj/structure/biohazard_blob/resin/Destroy()
	if(our_controller)
		our_controller.ActivateAdjacentResin(get_turf(src))
		our_controller.all_resin -= src
		our_controller.active_resin -= src
	return ..()

#define BLOB_BULB_ALPHA 100

/obj/structure/biohazard_blob/structure/bulb
	name = "empty bulb"
	icon = 'modular_skyrat/modules/biohazard_blob/icons/blob_bulb.dmi'
	icon_state = "blob_bulb_empty"
	density = FALSE
	layer = TABLE_LAYER
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_LAVA
	var/is_full = FALSE
	var/list/registered_turfs = list()
	max_integrity = 100

/obj/structure/biohazard_blob/structure/bulb/Initialize()
	. = ..()
	make_full()
	for(var/t in get_adjacent_open_turfs(src))
		registered_turfs += t
		RegisterSignal(t, COMSIG_ATOM_ENTERED, .proc/proximity_trigger)

/obj/structure/biohazard_blob/structure/bulb/proc/proximity_trigger(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(!isliving(AM))
		return
	var/mob/living/L = AM
	if(!(MOLD_FACTION in L.faction))
		INVOKE_ASYNC(src, .proc/discharge)

/obj/structure/biohazard_blob/structure/bulb/proc/make_full()
	//Called by a timer, check if we exist
	if(QDELETED(src))
		return
	is_full = TRUE
	name = "filled bulb"
	icon_state = "blob_bulb_full"
	set_light(2,1,LIGHT_COLOR_LAVA)
	density = TRUE
	update_overlays()

/obj/structure/biohazard_blob/structure/bulb/proc/discharge()
	if(!is_full)
		return
	var/turf/T = get_turf(src)
	visible_message("<span class='warning'>The [src] ruptures!</span>")
	switch(blob_type)
		if(BIO_BLOB_TYPE_FUNGUS)
			var/datum/reagents/R = new/datum/reagents(300)
			R.my_atom = src
			R.add_reagent(/datum/reagent/cordycepsspores, 50)
			var/datum/effect_system/smoke_spread/chem/smoke = new()
			smoke.set_up(R, 5)
			smoke.attach(src)
			smoke.start()
		if(BIO_BLOB_TYPE_FIRE)
			T.atmos_spawn_air("o2=20;plasma=20;TEMP=600")
		if(BIO_BLOB_TYPE_EMP)
			if(prob(50))
				empulse(src, 5, 7)
				for(var/mob/living/M in get_hearers_in_view(3, T))
					if(M.flash_act(affect_silicon = 1))
						M.Paralyze(20)
						M.Knockdown(20)
					M.soundbang_act(1, 20, 10, 5)
			else
				tesla_zap(src, 4, 10000, ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE)
		if(BIO_BLOB_TYPE_TOXIC)
			var/datum/reagents/R = new/datum/reagents(300)
			R.my_atom = src
			R.add_reagent(/datum/reagent/toxin, 30)
			var/datum/effect_system/foam_spread/foam = new
			foam.set_up(40, T, R)
			foam.start()
		if(BIO_BLOB_TYPE_RADIOACTIVE)
			radiation_pulse(src, 1500, 15, FALSE, TRUE)
			fire_nuclear_particle()
			empulse(src, 5, 7)
			var/datum/reagents/R = new/datum/reagents(300)
			R.my_atom = src
			R.add_reagent(/datum/reagent/toxin/mutagen, 50)
			var/datum/effect_system/foam_spread/foam = new
			foam.set_up(50, T, R)
			foam.start()
	is_full = FALSE
	name = "empty bulb"
	icon_state = "blob_bulb_empty"
	playsound(src, 'sound/effects/bamf.ogg', 100, TRUE)
	set_light(0)
	update_overlays()
	density = FALSE
	addtimer(CALLBACK(src, .proc/make_full), 1 MINUTES, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)

/obj/structure/biohazard_blob/structure/bulb/attack_generic(mob/user, damage_amount, damage_type, damage_flag, sound_effect, armor_penetration)
	if(MOLD_FACTION in user.faction)
		return ..()
	discharge()
	. = ..()

/obj/structure/biohazard_blob/structure/bulb/bullet_act(obj/projectile/P)
	if(istype(P, /obj/projectile/energy/nuclear_particle))
		return ..()
	discharge()
	. = ..()

/obj/structure/biohazard_blob/structure/bulb/Destroy()
	if(our_controller)
		our_controller.other_structures -= src
	for(var/t in registered_turfs)
		UnregisterSignal(t, COMSIG_ATOM_ENTERED)
	registered_turfs = null
	return ..()

/obj/structure/biohazard_blob/structure/bulb/update_overlays()
	. = ..()
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	if(is_full)
		SSvis_overlays.add_vis_overlay(src, icon, "blob_bulb_overlay", layer, plane, dir, BLOB_BULB_ALPHA)
		SSvis_overlays.add_vis_overlay(src, icon, "blob_bulb_overlay", 0, EMISSIVE_PLANE, dir, alpha)
		var/obj/effect/overlay/vis/overlay1 = managed_vis_overlays[1]
		var/obj/effect/overlay/vis/overlay2 = managed_vis_overlays[2]
		overlay1.appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_COLOR
		overlay2.appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_COLOR

#undef BLOB_BULB_ALPHA


/obj/structure/biohazard_blob/structure/wall
	name = "mold wall"
	desc = "Looks like some kind of thick resin."
	icon = 'icons/obj/smooth_structures/alien/resin_wall.dmi'
	icon_state = "resin_wall-0"
	base_icon_state = "resin_wall"
	opacity = TRUE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_ALIEN_RESIN)
	canSmoothWith = list(SMOOTH_GROUP_ALIEN_RESIN)
	max_integrity = 200
	can_atmos_pass = ATMOS_PASS_DENSITY

/obj/structure/biohazard_blob/wall/Destroy()
	if(our_controller)
		our_controller.ActivateAdjacentResin(get_turf(src))
		our_controller.other_structures -= src
	return ..()

/obj/structure/biohazard_blob/structure/conditioner
	name = "pulsating vent"
	desc = "An unsightly vent, it appears to be puffing something out."
	density = FALSE
	icon = 'modular_skyrat/modules/biohazard_blob/icons/blob_spawner.dmi'
	icon_state = "blob_vent"
	density = FALSE
	layer = LOW_OBJ_LAYER
	max_integrity = 150
	///The mold atmosphere conditioner will spawn the molds preferred atmosphere every so often.
	var/happy_atmos = null
	var/puff_cooldown = 15 SECONDS
	var/puff_delay = 0

/obj/structure/biohazard_blob/structure/conditioner/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(our_controller)
		our_controller.other_structures -= src
	return ..()

/obj/structure/biohazard_blob/structure/conditioner/Initialize()
	. = ..()
	switch(blob_type)
		if(BIO_BLOB_TYPE_FUNGUS)
			happy_atmos = "miasma=50;TEMP=296"
		if(BIO_BLOB_TYPE_FIRE)
			happy_atmos = "co2=30;TEMP=1000"
		if(BIO_BLOB_TYPE_EMP)
			happy_atmos = "n2=30;TEMP=100"
		if(BIO_BLOB_TYPE_TOXIC)
			happy_atmos = "miasma=50;TEMP=296"
		if(BIO_BLOB_TYPE_RADIOACTIVE)
			happy_atmos = "tritium=5;TEMP=296"

	START_PROCESSING(SSobj, src)

/obj/structure/biohazard_blob/structure/conditioner/process(delta_time)
	if(!happy_atmos)
		return
	if(puff_delay > world.time)
		return
	puff_delay = world.time + puff_cooldown
	var/turf/holder_turf = get_turf(src)
	holder_turf.atmos_spawn_air(happy_atmos)
	if(blob_type == BIO_BLOB_TYPE_RADIOACTIVE)
		fire_nuclear_particle()

/obj/structure/biohazard_blob/structure/spawner
	name = "hatchery"
	density = FALSE
	icon = 'modular_skyrat/modules/biohazard_blob/icons/blob_spawner.dmi'
	icon_state = "blob_spawner"
	density = FALSE
	layer = LOW_OBJ_LAYER
	max_integrity = 150
	var/monster_types = list()
	var/max_spawns = 1
	var/spawn_cooldown = 1200 //In deciseconds

/obj/structure/biohazard_blob/structure/spawner/Destroy()
	if(our_controller)
		our_controller.other_structures -= src
	return ..()

/obj/structure/biohazard_blob/structure/spawner/Initialize()
	. = ..()
	switch(blob_type)
		if(BIO_BLOB_TYPE_FUNGUS)
			monster_types = list(/mob/living/simple_animal/hostile/biohazard_blob/diseased_rat)
			spawn_cooldown = 500
		if(BIO_BLOB_TYPE_FIRE)
			monster_types = list(/mob/living/simple_animal/hostile/biohazard_blob/oil_shambler)
		if(BIO_BLOB_TYPE_EMP)
			monster_types = list(/mob/living/simple_animal/hostile/biohazard_blob/electric_mosquito)
			spawn_cooldown = 500
		if(BIO_BLOB_TYPE_TOXIC)
			monster_types = list(/mob/living/simple_animal/hostile/giant_spider)
		if(BIO_BLOB_TYPE_RADIOACTIVE)
			monster_types = list(/mob/living/simple_animal/hostile/biohazard_blob/centaur)
	AddComponent(/datum/component/spawner, monster_types, spawn_cooldown, list(MOLD_FACTION), "emerges from", max_spawns)

	/datum/component/spawner
