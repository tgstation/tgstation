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


/obj/vehicle/space/speedbike/atmos
	name = "prototype atmos vehicle"
	desc = "This vehicle possesses unparalled utility for atmospherics containment and control"
	icon_state = "atmo_bike"
	overlay_state = "cover_atmo"
	var/obj/machinery/portable_atmospherics/scrubber/huge/internal_scubber = null
	var/obj/item/weapon/extinguisher/vehicle/internal_extinguisher = null
	var/obj/machinery/portable_atmospherics/canister/internal_canister = null
	var/loaded = TRUE

/obj/vehicle/space/speedbike/atmos/New()
	. = ..()
	internal_scubber = new /obj/machinery/portable_atmospherics/scrubber/huge(src)
	internal_scubber.on = 1
	internal_extinguisher = new /obj/item/weapon/extinguisher/vehicle(src)
	internal_canister = new /obj/machinery/portable_atmospherics/canister/oxygen(src)

/obj/machinery/portable_atmospherics/canister/proto/oxygen
	icon_state = "proto"
	gas_type = "o2"
	filled = 1
	release_pressure = ONE_ATMOSPHERE*2

/obj/item/weapon/extinguisher/vehicle
	name = "extinguisher nozzle"
	desc = "A heavy duty nozzle attached to a massive reserve tank."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "atmos_nozzle"
	w_class = WEIGHT_CLASS_BULKY
	safety = 0
	max_water = 1000
	power = 10
	precision = 1
	cooling_power = 7
	var/vehicle = null

/obj/item/weapon/extinguisher/vehicle/dropped(mob/user)
	..()
	user << "<span class='notice'>The fire hose snaps back into the [src]!</span>"
	playsound(get_turf(src),'sound/items/change_jaws.ogg', 75, 1)
	loc = vehicle

/obj/vehicle/space/speedbike/atmos/buckle_mob(mob/living/M, force = 0, check_loc = 1)
	. = ..()
	riding_datum = new/datum/riding/space/speedbike/atmos
	var/datum/action/innate/atmos_bike/nanoice/N = new()
	var/datum/action/innate/atmos_bike/scrub/S = new()
	var/datum/action/innate/atmos_bike/extinguish/E = new()
	var/datum/action/innate/atmos_bike/flood/F = new()
	var/datum/action/innate/atmos_bike/control/C = new()
	N.Grant(M, src)
	S.Grant(M, src)
	E.Grant(M, src)
	F.Grant(M, src)
	C.Grant(M, src)


/obj/vehicle/space/speedbike/atmos/unbuckle_mob(mob/living/M)
	. = ..()
	for(var/datum/action/innate/atmos_bike/H in M.actions)
		qdel(H)

/datum/action/innate/atmos_bike
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUNNED | AB_CHECK_CONSCIOUS
	var/obj/vehicle/space/speedbike/atmos/bike
	var/obj/machinery/portable_atmospherics/scrubber/huge/inner_scrubber
	var/obj/item/weapon/extinguisher/vehicle/VEX

/datum/action/innate/atmos_bike/Grant(mob/living/L, obj/vehicle/B)
	bike = B
	inner_scrubber = bike.internal_scubber
	VEX = bike.internal_extinguisher
	..()

/datum/action/innate/atmos_bike/Destroy()
	bike = null
	inner_scrubber = null
	VEX = null
	return ..()

/datum/action/innate/atmos_bike/nanoice
	name = "nanoice"
	desc = "A potent anti-fire gas sprayed from your vehicle"
	button_icon_state = "nanofrost"
	var/nano_cooldown = 0

/datum/action/innate/atmos_bike/nanoice/Activate()
	if(world.time <= nano_cooldown)
		owner << "<span class='warning'><b>Nanoice dispensers require another [round((nano_cooldown - world.time)/10)] seconds to recharge!</b></span>"
		return
	var/datum/effect_system/smoke_spread/freezing/S = new
	S.set_up(2, owner.loc, blasting=1)
	S.start()
	var/obj/effect/decal/cleanable/flour/F = new /obj/effect/decal/cleanable/flour(owner.loc)
	F.add_atom_colour("#B2FFFF", FIXED_COLOUR_PRIORITY)
	F.name = "nanofrost residue"
	F.desc = "Residue left behind from a nanofrost detonation. Perhaps there was a fire here?"
	playsound(src,'sound/effects/bamf.ogg',100,1)
	nano_cooldown = world.time + 300


/datum/action/innate/atmos_bike/extinguish
	name = "Arm the Extinguisher"
	desc = "Unleashes a powerful fire extinguisher"
	button_icon_state = "noflame"
	var/out = FALSE

/datum/action/innate/atmos_bike/extinguish/Activate()
	if(!out)
		if(!owner.put_in_hands(VEX))
			owner << "<span class='warning'>You need a free hand to hold the extinguisher!</span>"
			return
		VEX.loc = owner
		out = TRUE
		owner << "<span class='warning'>The vehicle unwinds a fire hose into your hands!</span>"
		playsound(get_turf(owner),'sound/items/change_jaws.ogg', 75, 1)
		name = "Store the Extinguisher"
		desc = "Dropping the extinguisher will also automatically store it"
		button_icon_state = "summons"
		UpdateButtonIcon()
		return
	if(out)
		VEX.loc = bike
		owner.drop_item(VEX)
		owner.swap_hand()
		owner.drop_item(VEX)
		name = "Arm the Extinguisher"
		desc = "Unleashes a powerful fire extinguisher"
		button_icon_state = "noflame"
		out = FALSE
		UpdateButtonIcon()

/datum/action/innate/atmos_bike/scrub
	name = "Scrubber Control"
	desc = "Toggles the scrubber device built in to your vehicle"
	button_icon_state = "mech_internals_on"

/datum/action/innate/atmos_bike/scrub/Activate()
	if(inner_scrubber.on)
		owner << "<span class='notice'>You have disabled the vehicle's massive air scrubbers</span>"
		button_icon_state = "mech_internals_off"
		inner_scrubber.on = 0
		UpdateButtonIcon()
		return
	if(!inner_scrubber.on)
		owner << "<span class='notice'>You have enabled the vehicle's massive air scrubbers</span>"
		button_icon_state = "mech_internals_on"
		inner_scrubber.on = 1
		UpdateButtonIcon()
		return

/datum/action/innate/atmos_bike/flood
	name = "Release Stored Gas"
	desc = "Toggles the scrubber device built in to your vehicle"
	button_icon_state = "flightpack_stabilizer"

/datum/action/innate/atmos_bike/flood/Activate()
	if(!bike.CAN)
		owner << "<span class='notice'>Alert: You have no canister to release gas from.</span>"
		playsound(get_turf(owner),'sound/machines/buzz-two.ogg', 50, 1)
		return
	if(bike.CAN.air_contents.return_pressure() < ONE_ATMOSPHERE)
		owner << "<span class='notice'>Alert: You have have exhausted your gas supply, refill or replace your canister.</span>"
		playsound(get_turf(owner),'sound/machines/buzz-two.ogg', 50, 1)
		return
	if(!bike.CAN.valve_open)
		owner << "<span class='notice'>Alert: You begin to dispense gas from the stored canister at [bike.CAN.release_pressure]kPa.</span>"
		bike.CAN.valve_open = 1
		button_icon_state = "flightpack_airbrake"
		name = "Stop Gas Release"
		UpdateButtonIcon()
		return
	if(bike.CAN.valve_open)
		owner << "<span class='notice'>Alert: You have stopped dispensing gas from your stored canister, it has [bike.CAN.air_contents.return_pressure()]kPa of gas remaining.</span>"
		bike.CAN.valve_open = 0
		name = "Release Stored Gas"
		button_icon_state = "flightpack_stabilizer"
		UpdateButtonIcon()

/datum/action/innate/atmos_bike/control
	name = "eject canister"
	desc = "Ejects the vehicle's internal canister"
	button_icon_state = "mech_eject"
	var/list/canisters_to_load = list()

/datum/action/innate/atmos_bike/control/Activate()
	if(!bike.CAN)
		bike.loaded = FALSE
	if(bike.loaded)
		owner << "<span class='notice'>You eject the vehicle's internal canister.</span>"
		bike.CAN.loc = get_turf(bike)
		button_icon_state = "mech_cycle_equip_off"
		name = "load canister"
		desc = "Loads the vehicle's internal canister"
		bike.loaded = FALSE
		UpdateButtonIcon()
		return
	if(!bike.loaded)
		for(var/obj/machinery/portable_atmospherics/canister/C in range(1,owner))
			canisters_to_load += C
		if(canisters_to_load.len==0)
			owner << "<span class='notice'>There are no nearby canisters to load into the vehicle!</span>"
			playsound(get_turf(owner),'sound/machines/buzz-two.ogg', 50, 1)
			return
		else
			bike.CAN = input(owner, "Choose which canister to load", "Canisters:") as null|anything in canisters_to_load
		if (!owner || QDELETED(owner) || !bike.CAN || QDELETED(bike.CAN))
			return
		bike.CAN.loc = bike
		owner << "<span class='notice'>The vehicle scoops up the [bike.CAN] and locks it into position.</span>"
		canisters_to_load.Cut()
		bike.loaded = TRUE
		name = "eject canister"
		desc = "Ejects the vehicle's internal canister"
		button_icon_state = "mech_eject"
		UpdateButtonIcon()


// Engineer's repair-bike

/obj/vehicle/space/speedbike/repair
	name = "prototype repair vehicle"
	desc = "An experimental repair device mounted on a speederbike... what will they think of next."
	icon_state = "engi_bike"
	overlay_state = "cover_engi"
	var/obj/machinery/repair_turret/turret = null

/obj/vehicle/space/speedbike/repair/Initialize()
	. = ..()
	turret = new(loc)

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

/obj/machinery/repair_turret/Initialize()
	..()
	update_icon()

/obj/machinery/repair_turret/proc/repair(obj/target, turf/target_loc)
	if(target.obj_integrity < target.max_integrity)
		playsound(get_turf(src),'sound/magic/LightningShock.ogg', 50, 1)
		Beam(target,icon_state="lightning[rand(1,12)]",time=20)
		target.obj_integrity = target.max_integrity
		target.update_icon()
		cooldown = world.time + 40
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
		Beam(target_loc,icon_state="lightning[rand(8,12)]",time=40)
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
			Beam(target_loc,icon_state="lightning[rand(8,12)]",time=40)
			cooldown = world.time + 150
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
			sleep(10)

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
