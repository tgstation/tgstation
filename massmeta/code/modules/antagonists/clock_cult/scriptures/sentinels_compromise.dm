/datum/clockcult/scripture/slab/sentinelscompromise
	name = "Компромисс Часового"
	use_time = 80
	slab_overlay = "compromise"
	desc = "Исцелите любого слугу в пределах видимости, но половина их исцеленного урона будет передана вам в виде урона токсином."
	tip = "Используйте на любого слугу, попавшего в беду, чтобы залечить его раны."
	invokation_time = 10
	button_icon_state = "Sentinel's Compromise"
	category = SPELLTYPE_PRESERVATION
	cogs_required = 1
	power_cost = 80

/datum/clockcult/scripture/slab/sentinelscompromise/InterceptClickOn(mob/living/caller, params, atom/target)
	if(!(invoker in viewers(7, get_turf(target))))
		return
	var/mob/living/M = target
	if(!istype(M))
		return
	if(!is_servant_of_ratvar(M))
		return
	if(apply_effects(target))
		uses_left --
		if(uses_left <= 0)
			if(after_use_text)
				clockwork_say(invoker, text2ratvar(after_use_text), TRUE)
			end_invokation()

/datum/clockcult/scripture/slab/sentinelscompromise/apply_effects(mob/living/M)
	if(M.stat == DEAD)
		return FALSE
	var/total_damage = (M.getBruteLoss() + M.getFireLoss() + M.getOxyLoss() + M.getCloneLoss()) * 0.6
	M.adjustBruteLoss(-M.getBruteLoss() * 0.6, FALSE)
	M.adjustFireLoss(-M.getFireLoss() * 0.6, FALSE)
	M.adjustOxyLoss(-M.getOxyLoss() * 0.6, FALSE)
	M.adjustCloneLoss(-M.getCloneLoss() * 0.6, TRUE)
	M.blood_volume = BLOOD_VOLUME_NORMAL
	M.reagents.remove_reagent(/datum/reagent/water/holywater, INFINITY)
	M.set_nutrition(NUTRITION_LEVEL_FULL)
	M.bodytemperature = BODYTEMP_NORMAL
	M.set_temp_blindness(0)
	M.set_eye_blur(0)
	M.set_dizzy(0)
	M.cure_husk()
	M.set_hallucinations(0)
	new /obj/effect/temp_visual/heal(get_turf(M), "#f8d984")
	playsound(M, 'sound/magic/magic_missile.ogg', 50, TRUE)
	playsound(invoker, 'sound/magic/magic_missile.ogg', 50, TRUE)
	invoker.adjustToxLoss(min(total_damage/2, 80))
	return TRUE
