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
	var/obj/item/organ/brain/rip_u = locate(/obj/item/organ/brain) in jedi.internal_organs
	if(rip_u)
		rip_u.Remove(jedi)
		qdel(rip_u)
	return COMPONENT_CANCEL_ATTACK_CHAIN

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
