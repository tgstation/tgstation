/*
	Station Airlocks Regular
*/
/obj/machinery/door/airlock/command
	icon = 'icons/obj/doors/airlocks/station/command.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_com

/obj/machinery/door/airlock/security
	icon = 'icons/obj/doors/airlocks/station/security.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_sec

/obj/machinery/door/airlock/engineering
	icon = 'icons/obj/doors/airlocks/station/engineering.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_eng

/obj/machinery/door/airlock/medical
	icon = 'icons/obj/doors/airlocks/station/medical.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_med

/obj/machinery/door/airlock/maintenance
	name = "maintenance access"
	icon = 'icons/obj/doors/airlocks/station/maintenance.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_mai

/obj/machinery/door/airlock/mining
	name = "mining airlock"
	icon = 'icons/obj/doors/airlocks/station/mining.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_min

/obj/machinery/door/airlock/atmos
	name = "atmospherics airlock"
	icon = 'icons/obj/doors/airlocks/station/atmos.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_atmo

/obj/machinery/door/airlock/research
	icon = 'icons/obj/doors/airlocks/station/research.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_research

/obj/machinery/door/airlock/freezer
	name = "freezer airlock"
	icon = 'icons/obj/doors/airlocks/station/freezer.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_fre

/obj/machinery/door/airlock/science
	icon = 'icons/obj/doors/airlocks/station/science.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_science

/obj/machinery/door/airlock/virology
	icon = 'icons/obj/doors/airlocks/station/virology.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_viro

//////////////////////////////////
/*
	Station Airlocks Glass
*/

/obj/machinery/door/airlock/glass_command
	icon = 'icons/obj/doors/airlocks/station/command.dmi'
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_com/glass
	glass = 1

/obj/machinery/door/airlock/glass_engineering
	icon = 'icons/obj/doors/airlocks/station/engineering.dmi'
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_eng/glass
	glass = 1

/obj/machinery/door/airlock/glass_security
	icon = 'icons/obj/doors/airlocks/station/security.dmi'
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_sec/glass
	glass = 1

/obj/machinery/door/airlock/glass_medical
	icon = 'icons/obj/doors/airlocks/station/medical.dmi'
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_med/glass
	glass = 1

/obj/machinery/door/airlock/glass_research
	icon = 'icons/obj/doors/airlocks/station/research.dmi'
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_research/glass
	glass = 1

/obj/machinery/door/airlock/glass_mining
	icon = 'icons/obj/doors/airlocks/station/mining.dmi'
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_min/glass
	glass = 1

/obj/machinery/door/airlock/glass_atmos
	icon = 'icons/obj/doors/airlocks/station/atmos.dmi'
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_atmo/glass
	glass = 1

/obj/machinery/door/airlock/glass_science
	icon = 'icons/obj/doors/airlocks/station/science.dmi'
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_science/glass
	glass = 1

/obj/machinery/door/airlock/glass_virology
	icon = 'icons/obj/doors/airlocks/station/virology.dmi'
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_viro/glass
	glass = 1

/obj/machinery/door/airlock/glass_maintenance
	icon = 'icons/obj/doors/airlocks/station/maintenance.dmi'
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_mai/glass
	glass = 1

//////////////////////////////////
/*
	Station Airlocks Mineral
*/

/obj/machinery/door/airlock/gold
	name = "gold airlock"
	icon = 'icons/obj/doors/airlocks/station/gold.dmi'
	var/mineral = "gold"
	assemblytype = /obj/structure/door_assembly/door_assembly_gold

/obj/machinery/door/airlock/silver
	name = "silver airlock"
	icon = 'icons/obj/doors/airlocks/station/silver.dmi'
	var/mineral = "silver"
	assemblytype = /obj/structure/door_assembly/door_assembly_silver

/obj/machinery/door/airlock/diamond
	name = "diamond airlock"
	icon = 'icons/obj/doors/airlocks/station/diamond.dmi'
	var/mineral = "diamond"
	assemblytype = /obj/structure/door_assembly/door_assembly_diamond

/obj/machinery/door/airlock/uranium
	name = "uranium airlock"
	icon = 'icons/obj/doors/airlocks/station/uranium.dmi'
	var/mineral = "uranium"
	assemblytype = /obj/structure/door_assembly/door_assembly_uranium
	var/last_event = 0

/obj/machinery/door/airlock/uranium/process()
	if(world.time > last_event+20)
		if(prob(50))
			radiate()
		last_event = world.time
	..()

/obj/machinery/door/airlock/uranium/proc/radiate()
	radiation_pulse(get_turf(src), 3, 3, 15, 0)
	return

/obj/machinery/door/airlock/plasma
	name = "plasma airlock"
	desc = "No way this can end badly."
	icon = 'icons/obj/doors/airlocks/station/plasma.dmi'
	var/mineral = "plasma"
	assemblytype = /obj/structure/door_assembly/door_assembly_plasma

/obj/machinery/door/airlock/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/PlasmaBurn(temperature)
	atmos_spawn_air("plasma=500;TEMP=1000")
	new/obj/structure/door_assembly/door_assembly_0( src.loc )
	qdel(src)

/obj/machinery/door/airlock/plasma/BlockSuperconductivity() //we don't stop the heat~
	return 0

/obj/machinery/door/airlock/clown
	name = "bananium airlock"
	desc = "Honkhonkhonk"
	icon = 'icons/obj/doors/airlocks/station/bananium.dmi'
	var/mineral = "bananium"
	doorOpen = 'sound/items/bikehorn.ogg'
	assemblytype = /obj/structure/door_assembly/door_assembly_clown

/obj/machinery/door/airlock/sandstone
	name = "sandstone airlock"
	icon = 'icons/obj/doors/airlocks/station/sandstone.dmi'
	var/mineral = "sandstone"
	assemblytype = /obj/structure/door_assembly/door_assembly_sandstone


/obj/machinery/door/airlock/wood
	name = "wooden airlock"
	icon = 'icons/obj/doors/airlocks/station/wood.dmi'
	var/mineral = "wood"
	assemblytype = /obj/structure/door_assembly/door_assembly_wood

//////////////////////////////////
/*
	Station2 Airlocks
*/

/obj/machinery/door/airlock/glass
	name = "glass airlock"
	icon = 'icons/obj/doors/airlocks/station2/glass.dmi'
	overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_glass
	glass = 1

//////////////////////////////////
/*
	External Airlocks
*/

/obj/machinery/door/airlock/external
	name = "external airlock"
	icon = 'icons/obj/doors/airlocks/external/external.dmi'
	overlays_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_ext

/obj/machinery/door/airlock/glass_external
	name = "external airlock"
	icon = 'icons/obj/doors/airlocks/external/external.dmi'
	overlays_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_ext/glass
	opacity = 0
	glass = 1

//////////////////////////////////
/*
	Centcom Airlocks
*/

/obj/machinery/door/airlock/centcom
	icon = 'icons/obj/doors/airlocks/centcom/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/centcom/overlays.dmi'
	opacity = 1
	assemblytype = /obj/structure/door_assembly/door_assembly_centcom

//////////////////////////////////
/*
	Vault Airlocks
*/

/obj/machinery/door/airlock/vault
	name = "vault door"
	icon = 'icons/obj/doors/airlocks/vault/vault.dmi'
	overlays_file = 'icons/obj/doors/airlocks/vault/overlays.dmi'
	opacity = 1
	assemblytype = /obj/structure/door_assembly/door_assembly_vault
	explosion_block = 2

//////////////////////////////////
/*
	Hatch Airlocks
*/

/obj/machinery/door/airlock/hatch
	name = "airtight hatch"
	icon = 'icons/obj/doors/airlocks/hatch/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	opacity = 1
	assemblytype = /obj/structure/door_assembly/door_assembly_hatch

/obj/machinery/door/airlock/maintenance_hatch
	name = "maintenance hatch"
	icon = 'icons/obj/doors/airlocks/hatch/maintenance.dmi'
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	opacity = 1
	assemblytype = /obj/structure/door_assembly/door_assembly_mhatch

//////////////////////////////////
/*
	High Security Airlocks
*/

/obj/machinery/door/airlock/highsecurity
	name = "high tech security airlock"
	icon = 'icons/obj/doors/airlocks/highsec/highsec.dmi'
	overlays_file = 'icons/obj/doors/airlocks/highsec/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_highsecurity
	explosion_block = 2

//////////////////////////////////
/*
	Shuttle Airlocks
*/

/obj/machinery/door/airlock/shuttle
	name = "shuttle airlock"
	icon = 'icons/obj/doors/airlocks/shuttle/shuttle.dmi'
	overlays_file = 'icons/obj/doors/airlocks/shuttle/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_shuttle

/obj/machinery/door/airlock/abductor
	name = "alien airlock"
	desc = "With humanity's current technological level, it could take years to hack this advanced airlock... or maybe we should give a screwdriver a try?"
	icon = 'icons/obj/doors/airlocks/abductor/abductor_airlock.dmi'
	overlays_file = 'icons/obj/doors/airlocks/abductor/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_abductor
	opacity = 1
	explosion_block = 3
	hackProof = 1
	aiControlDisabled = 1

//////////////////////////////////
/*
	Cult Airlocks
*/

/obj/machinery/door/airlock/cult
	name = "cult airlock"
	icon = 'icons/obj/doors/airlocks/cult/runed/cult.dmi'
	overlays_file = 'icons/obj/doors/airlocks/cult/runed/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_cult
	hackProof = 1
	aiControlDisabled = 1
	var/openingoverlaytype = /obj/effect/overlay/temp/cult/door
	var/friendly = FALSE

/obj/machinery/door/airlock/cult/New()
	..()
	PoolOrNew(openingoverlaytype, src.loc)

/obj/machinery/door/airlock/cult/canAIControl(mob/user)
	return (iscultist(user) && !isAllPowerCut())

/obj/machinery/door/airlock/cult/allowed(mob/M)
	if(!density)
		return 1
	if(friendly || \
			iscultist(M) || \
			istype(M, /mob/living/simple_animal/shade) || \
			istype(M, /mob/living/simple_animal/hostile/construct))
		PoolOrNew(openingoverlaytype, src.loc)
		return 1
	else
		PoolOrNew(/obj/effect/overlay/temp/cult/sac, src.loc)
		var/atom/throwtarget
		throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(M, src)))
		M << pick(sound('sound/hallucinations/turn_around1.ogg',0,1,50), sound('sound/hallucinations/turn_around2.ogg',0,1,50))
		flash_color(M, flash_color="#960000", flash_time=20)
		M.Weaken(2)
		M.throw_at_fast(throwtarget, 5, 1,src)
		return 0

/obj/machinery/door/airlock/cult/narsie_act()
	return

/obj/machinery/door/airlock/cult/ratvar_act()
	..()
	if(src)
		var/previouscolor = color
		color = "#FAE48C"
		animate(src, color = previouscolor, time = 8)

/obj/machinery/door/airlock/cult/friendly
	friendly = TRUE

/obj/machinery/door/airlock/cult/glass
	assemblytype = /obj/structure/door_assembly/door_assembly_cult/glass
	glass = 1
	opacity = 0

/obj/machinery/door/airlock/cult/glass/friendly
	friendly = TRUE

/obj/machinery/door/airlock/cult/unruned
	icon = 'icons/obj/doors/airlocks/cult/unruned/cult.dmi'
	overlays_file = 'icons/obj/doors/airlocks/cult/unruned/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_cult/unruned
	openingoverlaytype = /obj/effect/overlay/temp/cult/door/unruned

/obj/machinery/door/airlock/cult/unruned/friendly
	friendly = TRUE

/obj/machinery/door/airlock/cult/unruned/glass
	assemblytype = /obj/structure/door_assembly/door_assembly_cult/unruned/glass
	glass = 1
	opacity = 0

/obj/machinery/door/airlock/cult/unruned/glass/friendly
	friendly = TRUE

#define GEAR_SECURE 1 //Construction defines for the pinion airlock
#define GEAR_UNFASTENED 2
#define GEAR_LOOSE 3

//Pinion airlocks: Clockwork doors that only let servants of Ratvar through.
/obj/machinery/door/airlock/clockwork
	name = "pinion airlock"
	desc = "A massive cogwheel set into two heavy slabs of brass."
	icon = 'icons/obj/doors/airlocks/clockwork/pinion_airlock.dmi'
	overlays_file = 'icons/obj/doors/airlocks/clockwork/overlays.dmi'
	opacity = 1
	hackProof = TRUE
	aiControlDisabled = TRUE
	use_power = FALSE
	var/construction_state = GEAR_SECURE //Pinion airlocks have custom deconstruction

/obj/machinery/door/airlock/clockwork/New()
	..()
	var/turf/T = get_turf(src)
	PoolOrNew(/obj/effect/overlay/temp/ratvar/door, T)
	PoolOrNew(/obj/effect/overlay/temp/ratvar/beam/door, T)

/obj/machinery/door/airlock/clockwork/canAIControl(mob/user)
	return (is_servant_of_ratvar(user) && !isAllPowerCut())

/obj/machinery/door/airlock/clockwork/ratvar_act()
	return 0

/obj/machinery/door/airlock/clockwork/narsie_act()
	..()
	if(src)
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)

/obj/machinery/door/airlock/clockwork/attackby(obj/item/I, mob/living/user, params)
	if(!attempt_construction(I, user))
		return ..()

/obj/machinery/door/airlock/clockwork/allowed(mob/M)
	if(is_servant_of_ratvar(M))
		return 1
	return 0

/obj/machinery/door/airlock/clockwork/hasPower()
	return TRUE //yes we do have power

/obj/machinery/door/airlock/clockwork/proc/attempt_construction(obj/item/I, mob/living/user)
	if(!I || !user || !user.canUseTopic(src))
		return 0
	if(istype(I, /obj/item/weapon/screwdriver))
		if(construction_state == GEAR_SECURE)
			user.visible_message("<span class='notice'>[user] begins unfastening [src]'s gear...</span>", "<span class='notice'>You begin unfastening [src]'s gear...</span>")
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			if(!do_after(user, 75 / I.toolspeed, target = src))
				return 1 //Returns 1 so as not to have extra interactions with the tools used (i.e. prying open)
			user.visible_message("<span class='notice'>[user] unfastens [src]'s gear!</span>", "<span class='notice'>[src]'s gear shifts slightly with a pop.</span>")
			playsound(src, 'sound/items/Screwdriver2.ogg', 50, 1)
			construction_state = GEAR_UNFASTENED
		else if(construction_state == GEAR_UNFASTENED)
			user.visible_message("<span class='notice'>[user] begins fastening [src]'s gear...</span>", "<span class='notice'>You begin fastening [src]'s gear...</span>")
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			if(!do_after(user, 75 / I.toolspeed, target = src))
				return 1
			user.visible_message("<span class='notice'>[user] fastens [src]'s gear!</span>", "<span class='notice'>[src]'s gear shifts back into place.</span>")
			playsound(src, 'sound/items/Screwdriver2.ogg', 50, 1)
			construction_state = GEAR_SECURE
		else if(construction_state == GEAR_LOOSE)
			user << "<span class='warning'>The gear isn't secure enough to fasten!</span>"
		return 1
	else if(istype(I, /obj/item/weapon/wrench))
		if(construction_state == GEAR_SECURE)
			user << "<span class='warning'>[src] is too tightly secured! Your [I.name] can't get a solid grip!</span>"
			return 0
		else if(construction_state == GEAR_UNFASTENED)
			user.visible_message("<span class='notice'>[user] begins loosening [src]'s gear...</span>", "<span class='notice'>You begin loosening [src]'s gear...</span>")
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			if(!do_after(user, 80 / I.toolspeed, target = src))
				return 1
			user.visible_message("<span class='notice'>[user] loosens [src]'s gear!</span>", "<span class='notice'>[src]'s gear pops off and dangles loosely.</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			construction_state = GEAR_LOOSE
		else if(construction_state == GEAR_LOOSE)
			user.visible_message("<span class='notice'>[user] begins tightening [src]'s gear...</span>", "<span class='notice'>You begin tightening [src]'s gear into place...</span>")
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			if(!do_after(user, 80 / I.toolspeed, target = src))
				return 1
			user.visible_message("<span class='notice'>[user] tightens [src]'s gear!</span>", "<span class='notice'>You firmly tighten [src]'s gear into place.</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			construction_state = GEAR_UNFASTENED
		return 1
	else if(istype(I, /obj/item/weapon/crowbar))
		if(construction_state == GEAR_SECURE || construction_state == GEAR_UNFASTENED)
			user << "<span class='warning'>[src]'s gear is too tightly secured! Your [I.name] can't reach under it!</span>"
			return 1
		else if(construction_state == GEAR_LOOSE)
			user.visible_message("<span class='notice'>[user] begins slowly lifting off [src]'s gear...</span>", "<span class='notice'>You slowly begin lifting off [src]'s gear...</span>")
			playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
			if(!do_after(user, 85 / I.toolspeed, target = src))
				return 1
			user.visible_message("<span class='notice'>[user] lifts off [src]'s gear, causing it to fall apart!</span>", "<span class='notice'>You lift off [src]'s gear, causing it to fall \
			apart!</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			new/obj/item/clockwork/alloy_shards(get_turf(src))
			new/obj/item/clockwork/component/vanguard_cogwheel/pinion_lock(get_turf(src))
			qdel(src)
		return 1
	return 0

/obj/machinery/door/airlock/clockwork/brass
	glass = 1
	opacity = 0

#undef GEAR_SECURE
#undef GEAR_UNFASTENED
#undef GEAR_LOOSE

//////////////////////////////////
/*
	Misc Airlocks
*/

/obj/machinery/door/airlock/glass_large
	name = "large glass airlock"
	icon = 'icons/obj/doors/airlocks/glass_large/glass_large.dmi'
	overlays_file = 'icons/obj/doors/airlocks/glass_large/overlays.dmi'
	opacity = 0
	assemblytype = null
	glass = 1
	bound_width = 64 // 2x1

/obj/machinery/door/airlock/glass_large/narsie_act()
	return
