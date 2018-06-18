/turf/open
	plane = FLOOR_PLANE
	var/slowdown = 0 //negative for faster, positive for slower

	var/postdig_icon_change = FALSE
	var/postdig_icon
	var/list/archdrops
	var/wet

/turf/open/ComponentInitialize()
	. = ..()
	if(wet)
		AddComponent(/datum/component/wet_floor, wet, INFINITY, 0, INFINITY, TRUE)
	if(LAZYLEN(archdrops))
		AddComponent(/datum/component/archaeology, archdrops)

/turf/open/indestructible
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"

/turf/open/indestructible/Melt()
	to_be_destroyed = FALSE
	return src

/turf/open/indestructible/TerraformTurf(path, defer_change = FALSE, ignore_air = FALSE)
	return

/turf/open/indestructible/sound
	name = "squeeky floor"
	var/sound

/turf/open/indestructible/sound/Entered(var/mob/AM)
	..()
	if(istype(AM))
		playsound(src,sound,50,1)

/turf/open/indestructible/necropolis
	name = "necropolis floor"
	desc = "It's regarding you suspiciously."
	icon = 'icons/turf/floors.dmi'
	icon_state = "necro1"
	baseturfs = /turf/open/indestructible/necropolis
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/indestructible/necropolis/Initialize()
	. = ..()
	if(prob(12))
		icon_state = "necro[rand(2,3)]"

/turf/open/indestructible/necropolis/air
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"

/turf/open/indestructible/boss //you put stone tiles on this and use it as a base
	name = "necropolis floor"
	icon = 'icons/turf/boss_floors.dmi'
	icon_state = "boss"
	baseturfs = /turf/open/indestructible/boss
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/indestructible/boss/air
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"

/turf/open/indestructible/hierophant
	icon = 'icons/turf/floors/hierophant_floor.dmi'
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	baseturfs = /turf/open/indestructible/hierophant
	smooth = SMOOTH_TRUE

/turf/open/indestructible/hierophant/two

/turf/open/indestructible/hierophant/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE

/turf/open/indestructible/paper
	name = "notebook floor"
	desc = "A floor made of invulnerable notebook paper."
	icon_state = "paperfloor"

/turf/open/indestructible/binary
	name = "tear in the fabric of reality"
	CanAtmosPass = ATMOS_PASS_NO
	baseturfs = /turf/open/indestructible/binary
	icon_state = "binary"

/turf/open/indestructible/airblock
	icon_state = "bluespace"
	CanAtmosPass = ATMOS_PASS_NO
	baseturfs = /turf/open/indestructible/airblock

/turf/open/indestructible/clock_spawn_room
	name = "cogmetal floor"
	desc = "Brass plating that gently radiates heat. For some reason, it reminds you of blood."
	icon_state = "reebe"
	baseturfs = /turf/open/indestructible/clock_spawn_room

/turf/open/indestructible/clock_spawn_room/Entered()
	..()
	START_PROCESSING(SSfastprocess, src)

/turf/open/indestructible/clock_spawn_room/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/turf/open/indestructible/clock_spawn_room/process()
	if(!port_servants())
		STOP_PROCESSING(SSfastprocess, src)

/turf/open/indestructible/clock_spawn_room/proc/port_servants()
	. = FALSE
	for(var/mob/living/L in src)
		if(is_servant_of_ratvar(L) && L.stat != DEAD)
			. = TRUE
			L.forceMove(get_turf(pick(GLOB.servant_spawns)))
			visible_message("<span class='warning'>[L] vanishes in a flash of red!</span>")
			L.visible_message("<span class='warning'>[L] appears in a flash of red!</span>", \
			"<span class='bold cult'>sas'so c'arta forbici</span><br><span class='danger'>You're yanked away from [src]!</span>")
			playsound(src, 'sound/magic/enter_blood.ogg', 50, TRUE)
			playsound(L, 'sound/magic/exit_blood.ogg', 50, TRUE)
			flash_color(L, flash_color = "#C80000", flash_time = 10)

/turf/open/Initalize_Atmos(times_fired)
	excited = 0
	update_visuals()

	current_cycle = times_fired

	//cache some vars
	var/list/atmos_adjacent_turfs = src.atmos_adjacent_turfs

	for(var/direction in GLOB.cardinals)
		var/turf/open/enemy_tile = get_step(src, direction)
		if(!istype(enemy_tile))
			if (atmos_adjacent_turfs)
				atmos_adjacent_turfs -= enemy_tile
			continue
		var/datum/gas_mixture/enemy_air = enemy_tile.return_air()

		//only check this turf, if it didn't check us when it was initalized
		if(enemy_tile.current_cycle < times_fired)
			if(CANATMOSPASS(src, enemy_tile))
				LAZYINITLIST(atmos_adjacent_turfs)
				LAZYINITLIST(enemy_tile.atmos_adjacent_turfs)
				atmos_adjacent_turfs[enemy_tile] = TRUE
				enemy_tile.atmos_adjacent_turfs[src] = TRUE
			else
				if (atmos_adjacent_turfs)
					atmos_adjacent_turfs -= enemy_tile
				if (enemy_tile.atmos_adjacent_turfs)
					enemy_tile.atmos_adjacent_turfs -= src
				UNSETEMPTY(enemy_tile.atmos_adjacent_turfs)
				continue
		else
			if (!atmos_adjacent_turfs || !atmos_adjacent_turfs[enemy_tile])
				continue

		if(!excited && air.compare(enemy_air))
			//testing("Active turf found. Return value of compare(): [is_active]")
			excited = TRUE
			SSair.active_turfs |= src
	UNSETEMPTY(atmos_adjacent_turfs)
	if (atmos_adjacent_turfs)
		src.atmos_adjacent_turfs = atmos_adjacent_turfs

/turf/open/proc/GetHeatCapacity()
	. = air.heat_capacity()

/turf/open/proc/GetTemperature()
	. = air.temperature

/turf/open/proc/TakeTemperature(temp)
	air.temperature += temp
	air_update_turf()

/turf/open/proc/freon_gas_act()
	for(var/obj/I in contents)
		if(I.resistance_flags & FREEZE_PROOF)
			return
		if(!(I.obj_flags & FROZEN))
			I.make_frozen_visual()
	for(var/mob/living/L in contents)
		if(L.bodytemperature <= 50)
			L.apply_status_effect(/datum/status_effect/freon)
	MakeSlippery(TURF_WET_PERMAFROST, 50)
	return 1

/turf/open/proc/water_vapor_gas_act()
	MakeSlippery(TURF_WET_WATER, min_wet_time = 100, wet_time_to_add = 50)

	for(var/mob/living/simple_animal/slime/M in src)
		M.apply_water()

	SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	for(var/obj/effect/O in src)
		if(is_cleanable(O))
			qdel(O)
	return TRUE

/turf/open/handle_slip(mob/living/carbon/C, knockdown_amount, obj/O, lube)
	if(C.movement_type & FLYING)
		return 0
	if(has_gravity(src))
		var/obj/buckled_obj
		if(C.buckled)
			buckled_obj = C.buckled
			if(!(lube&GALOSHES_DONT_HELP)) //can't slip while buckled unless it's lube.
				return 0
		else
			if(C.lying || !(C.status_flags & CANKNOCKDOWN)) // can't slip unbuckled mob if they're lying or can't fall.
				return 0
			if(C.m_intent == MOVE_INTENT_WALK && (lube&NO_SLIP_WHEN_WALKING))
				return 0
		if(!(lube&SLIDE_ICE))
			to_chat(C, "<span class='notice'>You slipped[ O ? " on the [O.name]" : ""]!</span>")
			playsound(C.loc, 'sound/misc/slip.ogg', 50, 1, -3)

		SEND_SIGNAL(C, COMSIG_ADD_MOOD_EVENT, "slipped", /datum/mood_event/slipped)
		for(var/obj/item/I in C.held_items)
			C.accident(I)

		var/olddir = C.dir
		if(!(lube & SLIDE_ICE))
			C.Knockdown(knockdown_amount)
			C.stop_pulling()
		else
			C.Stun(20)

		if(buckled_obj)
			buckled_obj.unbuckle_mob(C)
			lube |= SLIDE_ICE

		if(lube&SLIDE)
			new /datum/forced_movement(C, get_ranged_target_turf(C, olddir, 4), 1, FALSE, CALLBACK(C, /mob/living/carbon/.proc/spin, 1, 1))
		else if(lube&SLIDE_ICE)
			new /datum/forced_movement(C, get_ranged_target_turf(C, olddir, 1), 1, FALSE)	//spinning would be bad for ice, fucks up the next dir
		return 1

/turf/open/copyTurf(turf/T)
	. = ..()
	if(. && isopenturf(T))
		GET_COMPONENT(slip, /datum/component/wet_floor)
		if(slip)
			var/datum/component/wet_floor/WF = T.AddComponent(/datum/component/wet_floor)
			WF.InheritComponent(slip)

/turf/open/proc/MakeSlippery(wet_setting = TURF_WET_WATER, min_wet_time = 0, wet_time_to_add = 0, max_wet_time = MAXIMUM_WET_TIME, permanent)
	AddComponent(/datum/component/wet_floor, wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)

/turf/open/proc/MakeDry(wet_setting = TURF_WET_WATER, immediate = FALSE, amount = INFINITY)
	SEND_SIGNAL(src, COMSIG_TURF_MAKE_DRY, wet_setting, immediate, amount)

/turf/open/get_dumping_location()
	return src

/turf/open/proc/ClearWet()//Nuclear option of immediately removing slipperyness from the tile instead of the natural drying over time
	qdel(GetComponent(/datum/component/wet_floor))

/turf/open/rad_act(pulse_strength)
	. = ..()
	if (air.gases[/datum/gas/carbon_dioxide] && air.gases[/datum/gas/oxygen])
		pulse_strength = min(pulse_strength,air.gases[/datum/gas/carbon_dioxide][MOLES]*1000,air.gases[/datum/gas/oxygen][MOLES]*2000) //Ensures matter is conserved properly
		air.gases[/datum/gas/carbon_dioxide][MOLES]=max(air.gases[/datum/gas/carbon_dioxide][MOLES]-(pulse_strength/1000),0)
		air.gases[/datum/gas/oxygen][MOLES]=max(air.gases[/datum/gas/oxygen][MOLES]-(pulse_strength/2000),0)
		air.assert_gas(/datum/gas/pluoxium)
		air.gases[/datum/gas/pluoxium][MOLES]+=(pulse_strength/4000)
		air.garbage_collect()
