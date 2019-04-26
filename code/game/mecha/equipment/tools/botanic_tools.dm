// Hose

/obj/item/mecha_parts/mecha_equipment/botanic

/obj/item/mecha_parts/mecha_equipment/botanic/can_attach(obj/mecha/working/aquifer/M)
	if(..() && istype(M))
		return 1

/obj/item/mecha_parts/mecha_equipment/botanic/hose
	name = "Hose"
	desc = "Used for watering plants, the mechanics of this tool allow for the perfect amount of water to be dispensed on the plant to fully hydrate it."
	icon_state = "mecha_exting"

/obj/item/mecha_parts/mecha_equipment/botanic/hose/action()//i'm waiting to see if this will stay open to work on this.
	if(!action_checks(target) || get_dist(chassis, target)>3)
		return
	var/obj/mecha/working/aquifer/M = chassis

	if(istype(target, /obj/structure/reagent_dispensers/watertank) && get_dist(chassis,target) <= 1)
		occupant_message("<span class='warning'>Use the internal menu to siphon the water instead!</span>")
		return 0
	if(!chassis.reagents.total_volume > 0)
		playsound(chassis, 'sound/effects/extinguish.ogg', 75, 1, -3)
		if(istype(target, /obj/machinery/hydroponics) && get_dist(chassis,target) <= 1)
		//EXTINGUISHER
		var/direction = get_dir(chassis,target)
		var/turf/T = get_turf(target)
		var/turf/T1 = get_step(T,turn(direction, 90))
		var/turf/T2 = get_step(T,turn(direction, -90))
		var/list/the_targets = list(T,T1,T2)
		spawn(0)
			for(var/a=0, a<5, a++)
				var/obj/effect/particle_effect/water/W = new /obj/effect/particle_effect/water(get_turf(chassis))
				if(!W)
					return
				var/turf/my_target = pick(the_targets)
				var/datum/reagents/R = new/datum/reagents(5)
				W.reagents = R
				R.my_atom = W
				reagents.trans_to(W,1, transfered_by = chassis.occupant)
				for(var/b=0, b<4, b++)
					if(!W)
						return
					step_towards(W,my_target)
					if(!W)
						return
					var/turf/W_turf = get_turf(W)
					W.reagents.reaction(W_turf)
					for(var/atom/atm in W_turf)
						W.reagents.reaction(atm)
					if(W.loc == my_target)
						break
					sleep(2)
	return 1
