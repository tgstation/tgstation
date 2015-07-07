
// Drill, Diamond drill, Mining scanner


/obj/item/mecha_parts/mecha_equipment/drill
	name = "exosuit drill"
	desc = "Equipment for engineering and combat exosuits. This is the drill that'll pierce the heavens!"
	icon_state = "mecha_drill"
	equip_cooldown = 30
	energy_drain = 10
	force = 15

/obj/item/mecha_parts/mecha_equipment/drill/action(atom/target)
	if(!action_checks(target))
		return
	if(istype(target, /turf) && !istype(target, /turf/simulated))
		return
	if(isobj(target))
		var/obj/target_obj = target
		if(target_obj.unacidable)
			return
	target.visible_message("<span class='warning'>[chassis] starts to drill [target].</span>", \
					"<span class='userdanger'>[chassis] starts to drill [target]...</span>", \
					 "<span class='italics'>You hear drilling.</span>")

	if(do_after_cooldown(target))
		if(istype(target, /turf/simulated/wall/r_wall))
			if(istype(src , /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill))
				if(do_after_cooldown(target))//To slow down how fast mechs can drill through the station
					log_message("Drilled through [target]")
					target.ex_act(3)
			else
				occupant_message("<span class='danger'>[target] is too durable to drill through.</span>")
		else if(istype(target, /turf/simulated/mineral))
			for(var/turf/simulated/mineral/M in range(chassis,1))
				if(get_dir(chassis,M)&chassis.dir)
					M.gets_drilled(chassis.occupant)
			log_message("Drilled through [target]")
			if(locate(/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp) in chassis.equipment)
				var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in chassis:cargo
				if(ore_box)
					for(var/obj/item/weapon/ore/ore in range(chassis,1))
						if(get_dir(chassis,ore)&chassis.dir)
							ore.Move(ore_box)
		else if(istype(target, /turf/simulated/floor/plating/asteroid))
			for(var/turf/simulated/floor/plating/asteroid/M in range(chassis,1))
				if(get_dir(chassis,M)&chassis.dir)
					M.gets_dug()
			log_message("Drilled through [target]")
			if(locate(/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp) in chassis.equipment)
				var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in chassis:cargo
				if(ore_box)
					for(var/obj/item/weapon/ore/ore in range(chassis,1))
						if(get_dir(chassis,ore)&chassis.dir)
							ore.Move(ore_box)
		else
			log_message("Drilled through [target]")
			if(isliving(target))
				if(istype(src , /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill))
					drill_mob(target, chassis.occupant, 120)
				else
					drill_mob(target, chassis.occupant)
			else
				target.ex_act(2)


/obj/item/mecha_parts/mecha_equipment/drill/can_attach(obj/mecha/M as obj)
	if(..())
		if(istype(M, /obj/mecha/working) || istype(M, /obj/mecha/combat))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/drill/proc/drill_mob(mob/living/target, mob/user, var/drill_damage=80)
	target.visible_message("<span class='danger'>[chassis] drills [target] with [src].</span>", \
						"<span class='userdanger'>[chassis] drills [target] with [src].</span>")
	add_logs(user, target, "attacked", object="[name]", addition="(INTENT: [uppertext(user.a_intent)]) (DAMTYPE: [uppertext(damtype)])")
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/limb/affecting = H.get_organ("chest")
		affecting.take_damage(drill_damage)
		H.update_damage_overlays(0)
	else
		target.take_organ_damage(drill_damage)
	if(target)
		target.Paralyse(10)
		target.updatehealth()



/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill
	name = "diamond-tipped exosuit drill"
	desc = "Equipment for engineering and combat exosuits. This is an upgraded version of the drill that'll pierce the heavens!"
	icon_state = "mecha_diamond_drill"
	origin_tech = "materials=4;engineering=3"
	equip_cooldown = 20
	force = 15



/obj/item/mecha_parts/mecha_equipment/mining_scanner
	name = "exosuit mining scanner"
	desc = "Equipment for engineering and combat exosuits. It will automatically check surrounding rock for useful minerals."
	icon_state = "mecha_analyzer"
	origin_tech = "materials=3;engineering=2"
	equip_cooldown = 30
	var/scanning = 0

/obj/item/mecha_parts/mecha_equipment/mining_scanner/New()
	SSobj.processing |= src

/obj/item/mecha_parts/mecha_equipment/mining_scanner/process()
	if(!loc)
		SSobj.processing.Remove(src)
		qdel(src)
	if(scanning)
		return
	if(istype(loc,/obj/mecha/working))
		var/obj/mecha/working/mecha = loc
		if(!mecha.occupant)
			return
		var/list/occupant = list()
		occupant |= mecha.occupant
		scanning = 1
		mineral_scan_pulse(occupant,get_turf(loc))
		spawn(equip_cooldown)
			scanning = 0

