/datum/action/cooldown/mob_cooldown/dash/headbutt
	name = "Headbutt"
	desc = "Dashes 3 tiles in a direction headbutting anyone in the last tile. (You can overshoot your dash!)"
	cooldown_time = 1 MINUTES
	dash_range = 3


/datum/action/cooldown/mob_cooldown/dash/headbutt/dash_end(turf/ending_turf)
	. = ..()
	var/knocked = FALSE
	for(var/mob/living/mob in ending_turf?.contents)
		if(mob == owner)
			continue
		owner.visible_message(span_danger("[owner] headbutts [mob]!"))
		mob.adjustBruteLoss(15)
		mob.AdjustKnockdown(0.3 SECONDS)
		if(iscarbon(mob))
			var/mob/living/carbon/carbon = mob
			carbon.stamina.adjust(-55)
		log_combat(owner, mob, "headbutted (10 brute damage)")
		if(!knocked)
			var/mob/living/owner_mob = owner
			owner_mob.AdjustKnockdown(0.2 SECONDS)
			knocked = TRUE
