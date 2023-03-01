/mob/living/simple_animal/hostile/smspider
	name = "supermatter spider"
	desc= "A sliver of supermatter placed upon a robotically enhanced pedestal."
	icon = 'icons/mob/simple/smspider.dmi'
	icon_state = "smspider"
	icon_living = "smspider"
	icon_dead = "smspider_dead"
	gender = NEUTER
	mob_biotypes = MOB_BUG|MOB_ROBOTIC
	turns_per_move = 2
	speak_emote = list("vibrates")
	emote_see = list("vibrates")
	emote_taunt = list("vibrates")
	taunt_chance = 40
	combat_mode = TRUE
	maxHealth = 10
	health = 10
	minbodytemp = 0
	maxbodytemp = 1500
	healable = 0
	attack_verb_continuous = "slices"
	attack_verb_simple = "slice"
	attack_sound = 'sound/effects/supermatter.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	robust_searching = 1
	faction = list(FACTION_HOSTILE)
	// Gold, supermatter tinted
	lighting_cutoff_red = 30
	lighting_cutoff_green = 30
	lighting_cutoff_blue = 10
	death_message = "falls to the ground, its shard dulling to a miserable grey!"
	footstep_type = FOOTSTEP_MOB_CLAW
	var/overcharged = FALSE // if true, spider will not die if it dusts a limb

/mob/living/simple_animal/hostile/smspider/AttackingTarget()
	. = ..()
	if(isliving(target))
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 10, TRUE)
		visible_message(span_danger("[src] knocks into [target], turning them to dust in a brilliant flash of light!"))
		var/mob/living/victim = target
		victim.investigate_log("has been dusted by [src].", INVESTIGATE_DEATHS)
		victim.dust()
		if(!overcharged)
			death()
	else if(!isturf(target))
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 10, TRUE)
		visible_message(span_danger("[src] knocks into [target], turning it to dust in a brilliant flash of light!"))
		qdel(target)
		if(!overcharged)
			death()
	return FALSE

/mob/living/simple_animal/hostile/smspider/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/swarming)

/mob/living/simple_animal/hostile/smspider/overcharged
	name = "overcharged supermatter spider"
	desc = "A sliver of overcharged supermatter placed upon a robotically enhanced pedestal. This one seems especially dangerous."
	icon_state = "smspideroc"
	icon_living = "smspideroc"
	maxHealth = 25
	health = 25
	overcharged = TRUE
