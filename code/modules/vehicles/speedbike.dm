/obj/vehicle/space/speedbike
	name = "Speedbike"
	icon = 'icons/obj/bike.dmi'
	icon_state = "speedbike_blue"
	layer = LYING_MOB_LAYER
	var/overlay_state = "cover_blue"
	var/static/mutable_appearance/overlay

/obj/vehicle/space/speedbike/buckle_mob(mob/living/M, force = 0, check_loc = 1)
	. = ..()
	riding_datum = new/datum/riding/space/speedbike

/obj/vehicle/space/speedbike/New()
	. = ..()
	overlay = mutable_appearance(icon, overlay_state, ABOVE_MOB_LAYER)
	add_overlay(overlay)

/obj/vehicle/space/speedbike/Move(newloc,move_dir)
	if(has_buckled_mobs())
		new /obj/effect/temp_visual/dir_setting/speedbike_trail(loc,move_dir)
	. = ..()

/obj/vehicle/space/speedbike/red
	icon_state = "speedbike_red"
	overlay_state = "cover_red"


// ATMOBILE AND ATMOBILE UNIQUE INTERNAL ITEMS



/obj/vehicle/space/speedbike/atmos
	name = "prototype atmos vehicle"
	desc = "This vehicle possesses unparalleled utility for atmospheric containment and control"
	icon_state = "atmo_bike"
	overlay_state = "cover_atmo"
	var/obj/machinery/portable_atmospherics/scrubber/huge/internal_scubber = null
	var/obj/item/weapon/extinguisher/vehicle/internal_extinguisher = null
	var/ex_out = FALSE
	var/obj/machinery/portable_atmospherics/canister/proto/default/oxygen/CAN = null
	var/loaded = TRUE
	light_range = 7

/obj/vehicle/space/speedbike/atmos/New()
	. = ..()
	internal_scubber = new /obj/machinery/portable_atmospherics/scrubber/huge(src)
	internal_scubber.on = 1
	internal_extinguisher = new /obj/item/weapon/extinguisher/vehicle(src)
	internal_extinguisher.vehicle = src
	CAN = new /obj/machinery/portable_atmospherics/canister/oxygen(src)
//	CAN = new /obj/machinery/portable_atmospherics/canister/proto/default/oxygen(src)

/obj/item/weapon/extinguisher/vehicle
	name = "extinguisher nozzle"
	desc = "A heavy duty nozzle attached to a massive reserve tank."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "atmos_nozzle"
	item_state = "nozzleatmos"
	w_class = WEIGHT_CLASS_BULKY
	safety = FALSE
	max_water = 1000
	power = 8
	cooling_power = 10
	recoil = 0
	var/obj/vehicle/space/speedbike/atmos/vehicle = null

/obj/item/weapon/extinguisher/vehicle/dropped(mob/user)
	..()
	user << "<span class='notice'>The fire hose snaps back into the [src]!</span>"
	playsound(get_turf(src),'sound/items/change_jaws.ogg', 75, 1)
	if(vehicle)
		loc = vehicle
		vehicle.ex_out = FALSE




// ATMOBILE DATUMS



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
	if(ex_out)
		M.transferItemToLoc(internal_extinguisher,src)
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
	playsound(owner.loc,'sound/effects/bamf.ogg',100,1)
	nano_cooldown = world.time + 300


/datum/action/innate/atmos_bike/extinguish
	name = "Arm the Extinguisher"
	desc = "Unleashes a powerful fire extinguisher"
	button_icon_state = "noflame"

/datum/action/innate/atmos_bike/extinguish/Activate()
	if(!bike.ex_out)
		if(!owner.put_in_hands(VEX))
			owner << "<span class='warning'>You need a free hand to hold the extinguisher!</span>"
			return
		VEX.loc = owner
		bike.ex_out = TRUE
		owner << "<span class='warning'>The vehicle unwinds a fire hose into your hands!</span>"
		playsound(get_turf(owner),'sound/items/change_jaws.ogg', 75, 1)
		name = "Store the Extinguisher"
		desc = "Dropping the extinguisher will also automatically store it"
		button_icon_state = "summons"
		UpdateButtonIcon()
		return
	if(bike.ex_out)
		owner.transferItemToLoc(VEX,bike)
		name = "Arm the Extinguisher"
		desc = "Unleashes a powerful fire extinguisher"
		button_icon_state = "noflame"
		bike.ex_out = FALSE
		UpdateButtonIcon()


/datum/action/innate/atmos_bike/scrub
	name = "Scrubber Control"
	desc = "Toggles the scrubber device built in to your vehicle"
	button_icon_state = "mech_internals_on"

/datum/action/innate/atmos_bike/scrub/Activate()
	if(inner_scrubber.on)
		owner << "<span class='notice'>You disable the vehicle's massive air scrubbers</span>"
		button_icon_state = "mech_internals_off"
		inner_scrubber.on = 0
		UpdateButtonIcon()
		return
	if(!inner_scrubber.on)
		owner << "<span class='notice'>You enable the vehicle's massive air scrubbers</span>"
		button_icon_state = "mech_internals_on"
		inner_scrubber.on = 1
		UpdateButtonIcon()
		return

/datum/action/innate/atmos_bike/flood
	name = "Release Stored Gas"
	desc = "Toggles the scrubber device built in to your vehicle"
	button_icon_state = "flightpack_stabilizer"

/datum/action/innate/atmos_bike/flood/Activate()
	if(!bike.CAN || !bike.loaded)
		owner << "<span class='warning'>Alert: You have no canister to release gas from.</span>"
		playsound(get_turf(owner),'sound/machines/buzz-two.ogg', 50, 1)
		return
	if(bike.CAN.air_contents.return_pressure() < ONE_ATMOSPHERE)
		owner << "<span class='warning'>Alert: You have have exhausted your gas supply, refill or replace your canister.</span>"
		playsound(get_turf(owner),'sound/machines/buzz-two.ogg', 50, 1)
		bike.CAN.valve_open = 0
		name = "Release Stored Gas"
		button_icon_state = "flightpack_stabilizer"
		UpdateButtonIcon()
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
		playsound(get_turf(owner),'sound/mecha/mechmove03.ogg', 50, 1)
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
			owner << "<span class='warning'>There are no nearby canisters to load into the vehicle!</span>"
			playsound(get_turf(owner),'sound/machines/buzz-two.ogg', 50, 1)
			return
		else
			bike.CAN = input(owner, "Choose which canister to load", "Canisters:") as null|anything in canisters_to_load
		if (!owner || QDELETED(owner) || !bike.CAN || QDELETED(bike.CAN) || bike.loaded || !owner.Adjacent(bike.CAN))
			return
		bike.CAN.loc = bike
		owner << "<span class='notice'>The vehicle scoops up the [bike.CAN] and locks it into position.</span>"
		playsound(get_turf(owner),'sound/mecha/mechmove03.ogg', 50, 1)
		canisters_to_load.Cut()
		bike.loaded = TRUE
		name = "eject canister"
		desc = "Ejects the vehicle's internal canister"
		button_icon_state = "mech_eject"
		UpdateButtonIcon()




// Engineer's repair-bike and unique repair turret




/obj/vehicle/space/speedbike/repair
	name = "prototype repair vehicle"
	desc = "An experimental repair device mounted on a speederbike... what will they think of next."
	icon_state = "engi_bike"
	overlay_state = "cover_engi"
	var/obj/machinery/repair_turret/turret = null
	var/obj/item/weapon/inducer/vehicle/mounted = null
	var/inducer_out = FALSE
	light_range = 7


/obj/vehicle/space/speedbike/repair/Initialize()
	. = ..()
	turret = new(loc)
	mounted = new(loc)
	mounted.vehicle = src

/obj/vehicle/space/speedbike/repair/buckle_mob(mob/living/M, force = 0, check_loc = 1)
	. = ..()
	riding_datum = new/datum/riding/space/speedbike/repair
	var/datum/action/innate/repair_bike/foam_wall/F = new()
	var/datum/action/innate/repair_bike/toggle_turret/T = new()
	var/datum/action/innate/repair_bike/induction/I = new()
	T.Grant(M, src)
	F.Grant(M, src)
	I.Grant(M, src)

/obj/vehicle/space/speedbike/repair/unbuckle_mob(mob/living/M)
	. = ..()
	for(var/datum/action/innate/repair_bike/H in M.actions)
		qdel(H)

/datum/action/innate/repair_bike
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUNNED | AB_CHECK_CONSCIOUS
	var/obj/vehicle/space/speedbike/repair/bike
	var/obj/machinery/repair_turret/tesla

/datum/action/innate/repair_bike/Grant(mob/living/L, obj/vehicle/space/speedbike/repair/B)
	bike = B
	tesla = B.turret
	..()

/datum/action/innate/repair_bike/Destroy()
	bike = null
	return ..()

/datum/action/innate/repair_bike/foam_wall
	name = "Metal Foam Dispenser"
	desc = "Dispenses metal foam to help contain and control breaches"
	button_icon_state = "mech_phasing_off"
	var/metal_synth = 3

/datum/action/innate/repair_bike/foam_wall/Activate()
	if(metal_synth >= 1)
		var/obj/effect/particle_effect/foam/metal/iron/S = new /obj/effect/particle_effect/foam/metal/iron(get_turf(owner))
		S.amount = 0
		metal_synth--
		sleep(150)
		if(!owner || QDELETED(owner))
			return
		metal_synth++
	else
		owner << "<span class='warning'>Metal foam mix is still being synthesized...</span>"

/datum/action/innate/repair_bike/toggle_turret
	name = "Toggle Repair Turret"
	desc = "Toggles the mounted repair turret"
	button_icon_state = "lightning0"
	background_icon_state = "bg_default_on"

/datum/action/innate/repair_bike/toggle_turret/Activate()
	if(tesla.active)
		tesla.active = FALSE
		tesla.icon_state = "mini_off"
		STOP_PROCESSING(SSobj, tesla)
		background_icon_state = "bg_default"
		UpdateButtonIcon()
		return
	if(!tesla.active)
		tesla.active = TRUE
		tesla.icon_state = "mini_on"
		START_PROCESSING(SSobj, tesla)
		background_icon_state = "bg_default_on"
		UpdateButtonIcon()
		return

/datum/action/innate/repair_bike/induction
	name = "Equip power inducer"
	desc = "Used to charge power cells in weapons and APCs"
	button_icon_state = "flightpack_power"
	var/obj/item/weapon/inducer/vehicle = null

/datum/action/innate/repair_bike/induction/Activate()
	if(!bike.inducer_out)
		if(!owner.put_in_hands(bike.mounted))
			owner << "<span class='warning'>You need a free hand to hold the e!</span>"
			return
		bike.mounted.loc = owner
		bike.inducer_out = TRUE
		owner << "<span class='warning'>The vehicle deploys a power inducer into your hands!</span>"
		playsound(get_turf(owner),'sound/items/change_jaws.ogg', 75, 1)
		name = "Store the Inducer"
		desc = "Stores the inducer back inside the vehicle, dropping the inducer will trigger automatic storage as well."
		button_icon_state = "summons"
		UpdateButtonIcon()
		return
	if(bike.inducer_out)
		owner.transferItemToLoc(bike.mounted,bike)
		name = "Equip power inducer"
		desc = "Used to charge power cells in weapons and APCs"
		button_icon_state = "flightpack_power"
		bike.inducer_out = FALSE
		UpdateButtonIcon()


/obj/vehicle/space/speedbike/repair/Move(newloc,move_dir)
	if(has_buckled_mobs())
		if(istype(newloc,/turf/open/space))
			new/turf/open/floor/plating(newloc)
	. = ..()




// Unique repair turret


/obj/machinery/repair_turret
	name = "mounted repair turret"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "mini_off"
	density = FALSE
	anchored = TRUE
	var/cooldown = 0
	var/active = TRUE

/obj/machinery/repair_turret/Initialize()
	..()
	pixel_x = 17
	pixel_y = 37
	layer = 4
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
		new /obj/effect/temp_visual/small_smoke(target_loc)
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
			break

/obj/machinery/repair_turret/process()
	if(cooldown<=world.time && active)
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
	icon = 'icons/obj/car.dmi'
	icon_state = "speedwagon"
	layer = LYING_MOB_LAYER
	overlay_state = "speedwagon_cover"
	max_buckled_mobs = 4
	var/crash_all = FALSE //CHAOS
	pixel_y = -48 //to fix the offset when Initialized()
	pixel_x = -48

/obj/vehicle/space/speedbike/speedwagon/Bump(atom/movable/A)
	. = ..()
	if(A.density && has_buckled_mobs())
		var/atom/throw_target = get_edge_target_turf(A, src.dir)
		if(crash_all)
			A.throw_at(throw_target, 4, 3)
			visible_message("<span class='danger'>[src] crashes into [A]!</span>")
			playsound(src, 'sound/effects/bang.ogg', 50, 1)
		if(ishuman(A))
			var/mob/living/carbon/human/H = A
			H.Weaken(5)
			H.adjustStaminaLoss(30)
			H.apply_damage(rand(20,35), BRUTE)
			if(!crash_all)
				H.throw_at(throw_target, 4, 3)
				visible_message("<span class='danger'>[src] crashes into [H]!</span>")
				playsound(src, 'sound/effects/bang.ogg', 50, 1)

/obj/vehicle/space/speedbike/speedwagon/buckle_mob(mob/living/M, force = 0, check_loc = 1)
 	. = ..()
		riding_datum = new/datum/riding/space/speedwagon

/obj/vehicle/space/speedbike/speedwagon/Moved()
	. = ..()
	if(src.has_buckled_mobs())
		for(var/atom/A in range(2, src))
			if(!(A in src.buckled_mobs))
				Bump(A)
