/// Consume things that run into the supermatter from the tram. The tram calls forceMove (doesn't call Bump/ed) and not Move, and I'm afraid changing it will do something chaotic
/obj/machinery/power/supermatter_crystal/proc/tram_contents_consume(datum/source, list/tram_contents)
	SIGNAL_HANDLER

	for(var/atom/thing_to_consume as anything in tram_contents)
		Bumped(thing_to_consume)

/obj/machinery/power/supermatter_crystal/proc/eat_bullets(datum/source, obj/projectile/projectile)
	SIGNAL_HANDLER

	var/turf/local_turf = loc
	if(!istype(local_turf))
		return NONE

	var/kiss_power = 0
	if (istype(projectile, /obj/projectile/kiss/death))
		kiss_power = 20000
	else if (istype(projectile, /obj/projectile/kiss))
		kiss_power = 60


	if(!istype(projectile.firer, /obj/machinery/power/emitter))
		investigate_log("has been hit by [projectile] fired by [key_name(projectile.firer)]", INVESTIGATE_ENGINE)
	if(projectile.armor_flag != BULLET || kiss_power)
		if(kiss_power)
			psy_coeff = 1
		external_power_immediate += projectile.damage * bullet_energy + kiss_power
		log_activation(who = projectile.firer, how = projectile.fired_from)
	else
		external_damage_immediate += projectile.damage * bullet_energy * 0.1
		// Stop taking damage at emergency point, yell to players at danger point.
		// This isn't clean and we are repeating [/obj/machinery/power/supermatter_crystal/proc/calculate_damage], sorry for this.
		var/damage_to_be = damage + external_damage_immediate * clamp((emergency_point - damage) / emergency_point, 0, 1)
		if(damage_to_be > danger_point)
			visible_message(span_notice("[src] compresses under stress, resisting further impacts!"))
		playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)

	qdel(projectile)
	return COMPONENT_BULLET_BLOCKED

/obj/machinery/power/supermatter_crystal/singularity_act()
	var/gain = 100
	investigate_log("was consumed by a singularity.", INVESTIGATE_ENGINE)
	message_admins("Singularity has consumed a supermatter shard and can now become stage six.")
	visible_message(span_userdanger("[src] is consumed by the singularity!"))
	var/turf/sm_turf = get_turf(src)
	for(var/mob/hearing_mob as anything in GLOB.player_list)
		if(!is_valid_z_level(get_turf(hearing_mob), sm_turf))
			continue
		SEND_SOUND(hearing_mob, 'sound/effects/supermatter.ogg') //everyone goan know bout this
		to_chat(hearing_mob, span_boldannounce("A horrible screeching fills your ears, and a wave of dread washes over you..."))
	qdel(src)
	return gain

/obj/machinery/power/supermatter_crystal/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/jedi = user
	to_chat(jedi, span_userdanger("That was a really dense idea."))
	jedi.investigate_log("had [jedi.p_their()] brain dusted by touching [src] with telekinesis.", INVESTIGATE_DEATHS)
	jedi.ghostize()
	var/obj/item/organ/brain/rip_u = locate(/obj/item/organ/brain) in jedi.organs
	if(rip_u)
		rip_u.Remove(jedi)
		qdel(rip_u)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/power/supermatter_crystal/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/scalpel/supermatter))
		var/obj/item/scalpel/supermatter/scalpel = item
		to_chat(user, span_notice("You carefully begin to scrape \the [src] with \the [scalpel]..."))
		if(!scalpel.use_tool(src, user, 60, volume=100))
			return
		if (scalpel.usesLeft)
			to_chat(user, span_danger("You extract a sliver from \the [src]. \The [src] begins to react violently!"))
			new /obj/item/nuke_core/supermatter_sliver(src.drop_location())
			supermatter_sliver_removed = TRUE
			external_power_trickle += 800
			log_activation(who = user, how = scalpel)
			scalpel.usesLeft--
			if (!scalpel.usesLeft)
				to_chat(user, span_notice("A tiny piece of \the [scalpel] falls off, rendering it useless!"))
		else
			to_chat(user, span_warning("You fail to extract a sliver from \The [src]! \the [scalpel] isn't sharp enough anymore."))
		return

	if(istype(item, /obj/item/hemostat/supermatter))
		to_chat(user, span_warning("You poke [src] with [item]'s hyper-noblium tips. Nothing happens."))
		return

	if(istype(item, /obj/item/destabilizing_crystal))
		var/obj/item/destabilizing_crystal/destabilizing_crystal = item

		if(!is_main_engine)
			to_chat(user, span_warning("You can't use \the [destabilizing_crystal] on \a [name]."))
			return

		if(get_integrity_percent() < SUPERMATTER_CASCADE_PERCENT)
			to_chat(user, span_warning("You can only apply \the [destabilizing_crystal] to \a [name] that is at least [SUPERMATTER_CASCADE_PERCENT]% intact."))
			return

		to_chat(user, span_warning("You begin to attach \the [destabilizing_crystal] to \the [src]..."))
		if(do_after(user, 3 SECONDS, src))
			message_admins("[ADMIN_LOOKUPFLW(user)] attached [destabilizing_crystal] to the supermatter at [ADMIN_VERBOSEJMP(src)].")
			user.log_message("attached [destabilizing_crystal] to the supermatter", LOG_GAME)
			user.investigate_log("attached [destabilizing_crystal] to a supermatter crystal.", INVESTIGATE_ENGINE)
			to_chat(user, span_danger("\The [destabilizing_crystal] snaps onto \the [src]."))
			set_delam(SM_DELAM_PRIO_IN_GAME, /datum/sm_delam/cascade)
			external_damage_immediate += 10
			external_power_trickle += 500
			log_activation(who = user, how = destabilizing_crystal)
			qdel(destabilizing_crystal)
		return

	return ..()

//Do not blow up our internal radio
/obj/machinery/power/supermatter_crystal/contents_explosion(severity, target)
	return

/obj/machinery/power/supermatter_crystal/proc/wrench_act_callback(mob/user, obj/item/tool)
	if(moveable)
		default_unfasten_wrench(user, tool)

/obj/machinery/power/supermatter_crystal/proc/consume_callback(matter_increase, damage_increase)
	external_power_trickle += matter_increase
	external_damage_immediate += damage_increase
