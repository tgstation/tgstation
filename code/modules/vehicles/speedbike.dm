/obj/vehicle/space/speedbike
	name = "Speedbike"
	icon = 'icons/obj/bike.dmi'
	icon_state = "speedbike_blue"
	layer = LYING_MOB_LAYER
	var/overlay_state = "cover_blue"
	var/image/overlay = null

/obj/vehicle/space/speedbike/buckle_mob(mob/living/M, force = 0, check_loc = 1)
 	. = ..()
		riding_datum = new/datum/riding/space/speedbike

/obj/vehicle/space/speedbike/New()
	. = ..()
	overlay = image("icons/obj/bike.dmi", overlay_state)
	overlay.layer = ABOVE_MOB_LAYER
	add_overlay(overlay)

/obj/effect/overlay/temp/speedbike_trail
	name = "speedbike trails"
	icon_state = "ion_fade"
	layer = BELOW_MOB_LAYER
	duration = 10
	randomdir = 0

/obj/effect/overlay/temp/speedbike_trail/New(loc,move_dir)
	..()
	setDir(move_dir)

/obj/vehicle/space/speedbike/Move(newloc,move_dir)
	if(has_buckled_mobs())
		new /obj/effect/overlay/temp/speedbike_trail(loc,move_dir)
	. = ..()

/obj/vehicle/space/speedbike/red
	icon_state = "speedbike_red"
	overlay_state = "cover_red"
	
// Atmos response bike

/obj/vehicle/space/speedbike/atmos
	icon_state = "atmo_bike"
	overlay_state = "cover_atmo"
	var/obj/machinery/portable_atmospherics/scrubber/huge/HS = null
	var/nano_cooldown = 0

/obj/vehicle/space/speedbike/atmos/New()
	. = ..()
	src.contents += new obj/machinery/portable_atmospherics/scrubber/huge/HS
	HS.on = 1

/obj/vehicle/space/speedbike/repair/buckle_mob(mob/living/M, force = 0, check_loc = 1)
	. = ..()
	riding_datum = new/datum/riding/space/speedbike
	var/datum/action/nanoice = new()
	NanoIce.Grant(M)
	
/obj/vehicle/space/speedbike/repair/unbuckle_mob(mob/living/M)
	. = ..()
	NanoIce.Remove(M)

/datum/action/nanoice
	name = "NanoIce"
	desc = "A potent anti-fire gas sprayed from your vehicle"
	button_icon_state = "nanofrost"
	background_icon_state = "bg_tech_blue"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS

/datum/action/nanoice/IsAvailable()
	if(world.time >= nano_cooldown)
		return 0
	return ..()

/datum/action/nanoice/Activate()
	var/datum/effect_system/smoke_spread/freezing/S = new
	S.set_up(2, src.loc, blasting=1)
	S.start()
	var/obj/effect/decal/cleanable/flour/F = new /obj/effect/decal/cleanable/flour(src.loc)
	F.add_atom_colour("#B2FFFF", FIXED_COLOUR_PRIORITY)
	F.name = "nanofrost residue"
	F.desc = "Residue left behind from a nanofrost detonation. Perhaps there was a fire here?"
	playsound(src,'sound/effects/bamf.ogg',100,1)
	nano_cooldown = world.time + 300

// Engineer's repair-bike

/obj/vehicle/space/speedbike/repair
	desc = "An experimental prototype repair device mounted on a speederbike... what will they think of next."
	icon_state = "engi_bike"
	overlay_state = "cover_engi"
	var/obj/machinery/repair_turret/turret = null

/obj/vehicle/space/speedbike/repair/New()
	. = ..()
	turret = new(loc)
	turret.pixel_x = 17
	turret.pixel_y = 37
	turret.layer = 4

/obj/vehicle/space/speedbike/repair/buckle_mob(mob/living/M, force = 0, check_loc = 1)
	. = ..()
	riding_datum = new/datum/riding/space/repair

/obj/vehicle/space/speedbike/repair/Move(newloc,move_dir)
	if(has_buckled_mobs())
		if(istype(newloc,/turf/open/space))
			new/turf/open/floor/plating(newloc)
	. = ..()


/obj/machinery/repair_turret
	name = "mounted repair turret"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "mini_off"
	density = 0
	anchored = 1
	var/cooldown = 0
	
/obj/machinery/repair_turret/proc/repair(obj/target, turf/target_loc)
	if(target.obj_integrity < target.max_integrity)
		playsound(get_turf(src),'sound/magic/LightningShock.ogg', 50, 1)
		Beam(target,icon_state="lightning[rand(1,12)]",time=20)
		target.obj_integrity = target.max_integrity
		target.update_icon()
		cooldown = world.time + 50
		return TRUE
	else
		return FALSE
	
/obj/machinery/repair_turret/proc/repair_grille(obj/target, turf/target_loc)
	if(istype(target,/obj/structure/grille/broken))
		var/N = 0
		var/list/C = list()
		new /obj/effect/overlay/temp/small_smoke(target_loc)
		for(var/obj/item/weapon/shard/S in range(1,target_loc))
			C += S
		if(C.len >= 2)
			cooldown = world.time + 120
			qdel(target)
			qdel(C[1])
			qdel(C[2])
			for(var/obj/item/stack/rods/R in range(1,target_loc))
				if (N >= 3)
					break
				var/T = min(3-N,R.amount)
				N += T
				R.use(T)
			switch(N)
				if(3 to 50) //should never be over 3 but hey
					new /obj/structure/grille(target_loc)
					new/obj/structure/window/reinforced/fulltile(target_loc)
				if(2)
					new/obj/structure/window/reinforced/fulltile(target_loc)
				if(1)
					new /obj/structure/grille(target_loc)
					new/obj/structure/window/fulltile(target_loc)
				if(0)
					new /obj/item/stack/rods(target_loc)
					new/obj/structure/window/fulltile(target_loc)
		else
			qdel(target)
			new /obj/item/stack/rods(target_loc)
			cooldown = world.time + 40
		playsound(get_turf(src),'sound/magic/lightningbolt.ogg', 100, 1)
		Beam(target,icon_state="lightning[rand(8,12)]",time=40)
		return TRUE
	else
		return FALSE
		
/obj/machinery/repair_turret/proc/repair_wall(obj/target, turf/target_loc)
	if(istype(target,/obj/structure/girder))
		var/goal = 0
		var/sum = 0
		for(var/obj/item/stack/sheet/metal/wall_fodder in range(1,target_loc))
			if(goal >= 2)
				break
			sum = min(2-goal,wall_fodder.amount)
			goal += sum
			wall_fodder.use(sum)
		if(goal >= 2)
			qdel(target)
			new /turf/closed/wall(target_loc)
			playsound(get_turf(src),'sound/magic/lightningbolt.ogg', 100, 1)
			Beam(target,icon_state="lightning[rand(8,12)]",time=40)
			cooldown = world.time + 180
			return TRUE
		if (goal == 1)
			new /obj/item/stack/sheet/metal(target_loc)
			return FALSE
	else
		return FALSE
		
/obj/machinery/repair_turret/proc/repair_floor()
	for(var/turf/open/floor/flooring in view(7, src))
		if(flooring.icon_state != initial(flooring.icon_state))
			flooring.icon_state = initial(flooring.icon_state)
			playsound(flooring,'sound/magic/LightningShock.ogg', 50, 1)
			Beam(flooring,icon_state="lightning[rand(1,12)]",time=20)
			cooldown = world.time + 30
			return

/obj/machinery/repair_turret/process()
	if(cooldown<=world.time)
		icon_state = "mini_on"
		for(var/obj/target in view(7, src))
			var/target_loc = get_turf(target)
			if(repair(target))
				return
			if(repair_grille(target,target_loc))
				return
			if(repair_wall(target,target_loc))
				return
			if(repair_wall(target,target_loc))
				return
		repair_floor()
	else
		icon_state = "mini_off"




//BM SPEEDWAGON

/obj/vehicle/space/speedbike/speedwagon
	name = "BM Speedwagon"
	desc = "Push it to the limit, walk along the razor's edge."
	icon = 'icons/obj/bike.dmi'
	icon_state = "speedwagon"
	layer = LYING_MOB_LAYER
	overlay_state = "speedwagon_cover"

/obj/vehicle/space/speedbike/speedwagon/Bump(mob/living/A)
	. = ..()
	if(A.density && has_buckled_mobs() && (istype(A, /mob/living/carbon/human) && has_buckled_mobs()))
		var/atom/throw_target = get_edge_target_turf(A, pick(cardinal))
		A.throw_at(throw_target, 4, 3)
		A.Weaken(5)
		A.adjustStaminaLoss(30)
		A.apply_damage(rand(20,35), BRUTE)
		visible_message("<span class='danger'>[src] crashes into [A]!</span>")
		playsound(src, 'sound/effects/bang.ogg', 50, 1)

/obj/vehicle/space/speedbike/speedwagon/buckle_mob(mob/living/M, force = 0, check_loc = 1)
 	. = ..()
		riding_datum = new/datum/riding/space/speedbike/speedwagon

/obj/vehicle/space/speedbike/memewagon
	name = "Engineering's Pinnacle X9"
	desc = "The supreme department, manifest"
	icon = 'icons/obj/bike.dmi'
	icon_state = "speedwagon"
	layer = LYING_MOB_LAYER
	overlay_state = "speedwagon_cover"

/obj/vehicle/space/speedbike/memewagon/Bump(mob/living/A)
	. = ..()
	if(A.density && has_buckled_mobs() && (istype(A, /mob/living/carbon/human) && has_buckled_mobs()))
		var/atom/throw_target = get_edge_target_turf(A, pick(cardinal))
		A.throw_at(throw_target, 10, 8)
		A.Weaken(2)
		A.adjustStaminaLoss(10)
		A.apply_damage(rand(1,5), BRUTE)
		visible_message("<span class='danger'>[src] crashes into [A]!</span>")
		playsound(src, 'sound/effects/bang.ogg', 75, 1)
		sleep(10)
		playsound(src, 'sound/items/carhorn.ogg', 100, 1)

/obj/vehicle/space/speedbike/memewagon/buckle_mob(mob/living/M, force = 0, check_loc = 1)
	. = ..()
	riding_datum = new/datum/riding/space/speedbike/speedwagon
