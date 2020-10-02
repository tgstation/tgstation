
// Drill, Diamond drill, Mining scanner

#define DRILL_BASIC 1
#define DRILL_HARDENED 2


/obj/item/mecha_parts/mecha_equipment/drill
	name = "exosuit drill"
	desc = "Equipment for engineering and combat exosuits. This is the drill that'll pierce the heavens!"
	icon_state = "mecha_drill"
	equip_cooldown = 15
	energy_drain = 10
	force = 15
	harmful = TRUE
	range = MECHA_MELEE
	tool_behaviour = TOOL_DRILL
	toolspeed = 0.9
	var/drill_delay = 7
	var/drill_level = DRILL_BASIC
	mech_flags = EXOSUIT_MODULE_WORKING | EXOSUIT_MODULE_COMBAT

/obj/item/mecha_parts/mecha_equipment/drill/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 50, 100, null, null, TRUE)

/obj/item/mecha_parts/mecha_equipment/drill/action(mob/source, atom/target, params)
	// Check if we can even use the equipment to begin with.
	if(!action_checks(target))
		return

	// We can only drill non-space turfs, living mobs and objects.
	if(isspaceturf(target) || !(isliving(target) || isobj(target) || isturf(target)))
		return

	// For whatever reason we can't drill things that acid won't even stick too, and probably
	// shouldn't waste our time drilling indestructible things.
	if(isobj(target))
		var/obj/target_obj = target
		if(target_obj.resistance_flags & (UNACIDABLE | INDESTRUCTIBLE))
			return

	target.visible_message("<span class='warning'>[chassis] starts to drill [target].</span>", \
					"<span class='userdanger'>[chassis] starts to drill [target]...</span>", \
					 "<span class='hear'>You hear drilling.</span>")

	if(do_after_cooldown(target, source))
		log_message("Started drilling [target]", LOG_MECHA)
		// Drilling a turf is a one-and-done procedure.
		if(isturf(target))
			var/turf/T = target
			T.drill_act(src, source)
			return ..()
		// Drilling objects and mobs is a repeating procedure.
		while(do_after_mecha(target, source, drill_delay))
			if(isliving(target))
				drill_mob(target, source)
				playsound(src,'sound/weapons/drill.ogg',40,TRUE)
			else if(isobj(target))
				var/obj/O = target
				O.take_damage(15, BRUTE, 0, FALSE, get_dir(chassis, target))
				playsound(src,'sound/weapons/drill.ogg',40,TRUE)

			// If we caused a qdel drilling the target, we can stop drilling them.
			// Prevents starting a do_after on a qdeleted target.
			if(QDELETED(target))
				break

	return ..()

/turf/proc/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill, mob/user)
	return

/turf/closed/wall/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill, mob/user)
	if(drill.do_after_mecha(src, user, 60 / drill.drill_level))
		drill.log_message("Drilled through [src]", LOG_MECHA)
		dismantle_wall(TRUE, FALSE)

/turf/closed/wall/r_wall/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill, mob/user)
	if(drill.drill_level >= DRILL_HARDENED)
		if(drill.do_after_mecha(src, user, 120 / drill.drill_level))
			drill.log_message("Drilled through [src]", LOG_MECHA)
			dismantle_wall(TRUE, FALSE)
	else
		to_chat(user, "[icon2html(src, user)]<span class='danger'>[src] is too durable to drill through.</span>")

/turf/closed/mineral/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill, mob/user)
	for(var/turf/closed/mineral/M in range(drill.chassis,1))
		if(get_dir(drill.chassis,M)&drill.chassis.dir)
			M.gets_drilled()
	drill.log_message("[user] drilled through [src]", LOG_MECHA)
	drill.move_ores()

/turf/open/floor/plating/asteroid/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill)
	for(var/turf/open/floor/plating/asteroid/M in range(1, drill.chassis))
		if((get_dir(drill.chassis,M)&drill.chassis.dir) && !M.dug)
			M.getDug()
	drill.log_message("Drilled through [src]", LOG_MECHA)
	drill.move_ores()


/obj/item/mecha_parts/mecha_equipment/drill/proc/move_ores()
	if(locate(/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp) in chassis.equipment && istype(chassis, /obj/vehicle/sealed/mecha/working/ripley))
		var/obj/vehicle/sealed/mecha/working/ripley/R = chassis //we could assume that it's a ripley because it has a clamp, but that's ~unsafe~ and ~bad practice~
		R.collect_ore()

/obj/item/mecha_parts/mecha_equipment/drill/can_attach(obj/vehicle/sealed/mecha/M as obj)
	if(..())
		if(istype(M, /obj/vehicle/sealed/mecha/working) || istype(M, /obj/vehicle/sealed/mecha/combat))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/drill/attach(obj/vehicle/sealed/mecha/M)
	..()
	var/datum/component/butchering/butchering = src.GetComponent(/datum/component/butchering)
	butchering.butchering_enabled = TRUE

/obj/item/mecha_parts/mecha_equipment/drill/detach(atom/moveto)
	..()
	var/datum/component/butchering/butchering = src.GetComponent(/datum/component/butchering)
	butchering.butchering_enabled = FALSE

/obj/item/mecha_parts/mecha_equipment/drill/proc/drill_mob(mob/living/target, mob/user)
	target.visible_message("<span class='danger'>[chassis] is drilling [target] with [src]!</span>", \
						"<span class='userdanger'>[chassis] is drilling you with [src]!</span>")
	log_combat(user, target, "drilled", "[name]", "(INTENT: [uppertext(user.a_intent)]) (DAMTYPE: [uppertext(damtype)])")
	if(target.stat == DEAD && target.getBruteLoss() >= 200)
		log_combat(user, target, "gibbed", name)
		if(LAZYLEN(target.butcher_results) || LAZYLEN(target.guaranteed_butcher_results))
			var/datum/component/butchering/butchering = src.GetComponent(/datum/component/butchering)
			butchering.Butcher(chassis, target)
		else
			target.gib()
	else
		//drill makes a hole
		var/obj/item/bodypart/target_part = target.get_bodypart(ran_zone(BODY_ZONE_CHEST))
		target.apply_damage(10, BRUTE, BODY_ZONE_CHEST, target.run_armor_check(target_part, MELEE))

		//blood splatters
		var/splatter_dir = get_dir(chassis, target)
		if(isalien(target))
			new /obj/effect/temp_visual/dir_setting/bloodsplatter/xenosplatter(target.drop_location(), splatter_dir)
		else
			new /obj/effect/temp_visual/dir_setting/bloodsplatter(target.drop_location(), splatter_dir)

		//organs go everywhere
		if(target_part && prob(10 * drill_level))
			target_part.dismember(BRUTE)

/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill
	name = "diamond-tipped exosuit drill"
	desc = "Equipment for engineering and combat exosuits. This is an upgraded version of the drill that'll pierce the heavens!"
	icon_state = "mecha_diamond_drill"
	equip_cooldown = 10
	drill_delay = 4
	drill_level = DRILL_HARDENED
	force = 15
	toolspeed = 0.7


/obj/item/mecha_parts/mecha_equipment/mining_scanner
	name = "exosuit mining scanner"
	desc = "Equipment for working exosuits. It will automatically check surrounding rock for useful minerals."
	icon_state = "mecha_analyzer"
	selectable = 0
	equip_cooldown = 15
	var/scanning_time = 0
	mech_flags = EXOSUIT_MODULE_WORKING

/obj/item/mecha_parts/mecha_equipment/mining_scanner/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/item/mecha_parts/mecha_equipment/mining_scanner/can_attach(obj/vehicle/sealed/mecha/M as obj)
	if(..())
		if(istype(M, /obj/vehicle/sealed/mecha/working))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/mining_scanner/process()
	if(!loc)
		STOP_PROCESSING(SSfastprocess, src)
		qdel(src)
	if(istype(loc, /obj/vehicle/sealed/mecha/working) && scanning_time <= world.time)
		var/obj/vehicle/sealed/mecha/working/mecha = loc
		if(!mecha.occupants)
			return
		scanning_time = world.time + equip_cooldown
		mineral_scan_pulse(get_turf(src))

#undef DRILL_BASIC
#undef DRILL_HARDENED
