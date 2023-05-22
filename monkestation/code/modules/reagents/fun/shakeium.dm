/datum/reagent/shakeium
	name = "Shakeium"
	description = "Causes violent shaking in consumers."
	color = "#6fda28"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_CLEANS
	taste_description = "milkshakes"
	overdose_threshold = 25
	var/intensity = 1
	var/damage_amount = 3
	var/triggered_breakdown = FALSE

/datum/reagent/shakeium/on_mob_life(mob/living/L)
	. = ..()
	var/pixel_shift = (1 + (intensity / 10))
	L.Shake(pixel_shift)
	intensity++

/datum/reagent/shakium/overdose_start(mob/living/M)
	. = ..()
	to_chat(M, span_warning("I feel like your vibrating to much, my body can't handle this."))

/datum/reagent/shakeium/overdose_process(mob/living/M, seconds_per_tick, times_fired)
	. = ..()
	M.adjustBruteLoss(damage_amount)
	if(intensity > 15)
		intensity++
		damage_amount++
	if(damage_amount > 10)
		to_chat(M, span_warning("Oh god my brain is rattling inside my head. I should seek medical help."))
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3)
	if(damage_amount > 20)
		to_chat(M, span_warning("my body can't contain itself anymore, I think I'm gonna die."))
		if(iscarbon(M))
			var/mob/living/carbon/carbon_target = M
			if(!triggered_breakdown)
				var/timer = 15 SECONDS
				triggered_breakdown = TRUE
				for (var/_limb in carbon_target.bodyparts)
					var/obj/item/bodypart/limb = _limb
					if (limb.body_part == HEAD || limb.body_part == CHEST)
						continue
					addtimer(CALLBACK(limb, TYPE_PROC_REF(/obj/item/bodypart/, dismember)), timer)
					addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), carbon_target, 'sound/effects/cartoon_pop.ogg', 70), timer)
					timer += 15 SECONDS
