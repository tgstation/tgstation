///Causes the target to see incorrect health damages on the healthdoll
/datum/hallucination/fake_health_doll
	var/del_timer_id

///Creates a specified doll hallucination, or picks one randomly
/datum/hallucination/fake_health_doll/New(mob/living/hallucinator, specific_limb, severity, duration = 50 SECONDS)
	. = ..()
	if(!ishuman(hallucinator))
		//stack_trace("[type] - [hallucinator] was assigned a fake health doll hallucination while not being a human mob.")
		qdel(src)
		return

	add_fake_limb(specific_limb, severity)
	del_timer_id = QDEL_IN(src, duration)

// So that the associated addition proc cleans it up correctly
/datum/hallucination/fake_health_doll/Destroy()
	if(del_timer_id)
		deltimer(del_timer_id)
	var/mob/living/carbon/human/human_mob = hallucinator
	LAZYNULL(human_mob.hal_screwydoll)
	human_mob.update_health_hud()
	return ..()

/datum/hallucination/fake_health_doll/start()
	return TRUE // Starts from creation

///Increments the severity of the damage seen on the doll
/datum/hallucination/fake_health_doll/proc/increment_fake_damage()
	var/mob/living/carbon/human/human_mob = hallucinator
	for(var/entry in human_mob.hal_screwydoll)
		human_mob.hal_screwydoll[entry] = clamp(human_mob.hal_screwydoll[entry] + 1, 1, 5)
	human_mob.update_health_hud()

///Adds a fake limb to the hallucination datum effect
/datum/hallucination/fake_health_doll/proc/add_fake_limb(specific_limb, severity)
	var/static/list/screwy_limbs = list(
		SCREWYDOLL_HEAD,
		SCREWYDOLL_CHEST,
		SCREWYDOLL_L_ARM,
		SCREWYDOLL_R_ARM,
		SCREWYDOLL_L_LEG,
		SCREWYDOLL_R_LEG,
	)

	var/mob/living/carbon/human/human_mob = hallucinator
	LAZYSET(human_mob.hal_screwydoll, specific_limb || pick(screwy_limbs), severity || rand(1, 5))
	hallucinator.update_health_hud()
