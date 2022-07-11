/// Consume things that run into the supermatter from the tram. The tram calls forceMove (doesn't call Bump/ed) and not Move, and I'm afraid changing it will do something chaotic
/obj/machinery/power/supermatter_crystal/proc/tram_contents_consume(datum/source, list/tram_contents)
	SIGNAL_HANDLER

	for(var/atom/thing_to_consume as anything in tram_contents)
		Bumped(thing_to_consume)

/obj/machinery/power/supermatter_crystal/bullet_act(obj/projectile/projectile)
	var/turf/local_turf = loc
	var/kiss_power = 0
	switch(projectile.type)
		if(/obj/projectile/kiss)
			kiss_power = 60
		if(/obj/projectile/kiss/death)
			kiss_power = 20000
	if(!istype(local_turf))
		return FALSE
	if(!istype(projectile.firer, /obj/machinery/power/emitter) && power_changes)
		investigate_log("has been hit by [projectile] fired by [key_name(projectile.firer)]", INVESTIGATE_ENGINE)
	if(projectile.armor_flag != BULLET || kiss_power)
		if(kiss_power)
			psyCoeff = 1
			psy_overlay = TRUE
		if(power_changes) //This needs to be here I swear
			power += projectile.damage * bullet_energy + kiss_power
			if(!has_been_powered)
				var/fired_from_str = projectile.fired_from ? " with [projectile.fired_from]" : ""
				investigate_log(
					projectile.firer \
						? "has been powered for the first time by [key_name(projectile.firer)][fired_from_str]." \
						: "has been powered for the first time.",
					INVESTIGATE_ENGINE
				)
				message_admins(
					projectile.firer \
						? "[src] [ADMIN_JMP(src)] has been powered for the first time by [ADMIN_FULLMONTY(projectile.firer)][fired_from_str]." \
						: "[src] [ADMIN_JMP(src)] has been powered for the first time."
				)
				has_been_powered = TRUE
	else if(takes_damage)
		damage += (projectile.damage * bullet_energy) * clamp((emergency_point - damage) / emergency_point, 0, 1)
		if(damage > damage_penalty_point)
			visible_message(span_notice("[src] compresses under stress, resisting further impacts!"))
	return BULLET_ACT_HIT

/obj/machinery/power/supermatter_crystal/singularity_act()
	var/gain = 100
	investigate_log("consumed by singularity.", INVESTIGATE_ENGINE)
	message_admins("Singularity has consumed a supermatter shard and can now become stage six.")
	visible_message(span_userdanger("[src] is consumed by the singularity!"))
	for(var/mob/hearing_mob as anything in GLOB.player_list)
		if(hearing_mob.z != z)
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
	jedi.ghostize()
	var/obj/item/organ/internal/brain/rip_u = locate(/obj/item/organ/internal/brain) in jedi.internal_organs
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
			matter_power += 800
			scalpel.usesLeft--
			if (!scalpel.usesLeft)
				to_chat(user, span_notice("A tiny piece of \the [scalpel] falls off, rendering it useless!"))
		else
			to_chat(user, span_warning("You fail to extract a sliver from \The [src]! \the [scalpel] isn't sharp enough anymore."))
		return

	if(istype(item, /obj/item/destabilizing_crystal))
		var/obj/item/destabilizing_crystal/destabilizing_crystal = item

		if(!anomaly_event)
			to_chat(user, span_warning("You can't use \the [destabilizing_crystal] on \a [name]."))
			return

		if(get_integrity_percent() < SUPERMATTER_CASCADE_PERCENT)
			to_chat(user, span_warning("You can only apply \the [destabilizing_crystal] to \a [name] that is at least [SUPERMATTER_CASCADE_PERCENT]% intact."))
			return

		to_chat(user, span_warning("You begin to attach \the [destabilizing_crystal] to \the [src]..."))
		if(do_after(user, 3 SECONDS, src))
			message_admins("[ADMIN_LOOKUPFLW(user)] attached [destabilizing_crystal] to the supermatter at [ADMIN_VERBOSEJMP(src)]")
			log_game("[key_name(user)] attached [destabilizing_crystal] to the supermatter at [AREACOORD(src)]")
			investigate_log("[key_name(user)] attached [destabilizing_crystal] to a supermatter crystal.", INVESTIGATE_ENGINE)
			to_chat(user, span_danger("\The [destabilizing_crystal] snaps onto \the [src]."))
			has_destabilizing_crystal = TRUE
			cascade_initiated = TRUE
			damage += 100
			matter_power += 500
			addtimer(CALLBACK(src, .proc/announce_incoming_cascade), 2 MINUTES)
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
	if(matter_increase && power_changes)
		matter_power += matter_increase
	if(damage_increase && takes_damage)
		damage += damage_increase
		damage = max(damage, 0)
