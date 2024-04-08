/datum/slime_trait/polluter
	name = "Polluter"
	desc = "Emits large quanitities of pollution."
	menu_buttons = list(ENVIRONMENT_CHANGE)
	incompatible_traits = list(/datum/slime_trait/cleaner)

/datum/slime_trait/polluter/on_add(mob/living/basic/slime/parent)
	. = ..()
	parent.AddElement(/datum/element/pollution_emitter, /datum/pollutant/slime_dust, 30)

/datum/slime_trait/polluter/on_remove(mob/living/basic/slime/parent)
	. = ..()
	parent.RemoveElement(/datum/element/pollution_emitter)

/datum/pollutant/slime_dust
	name = "Slime Dust"
	pollutant_flags = POLLUTANT_APPEARANCE | POLLUTANT_BREATHE_ACT | POLLUTANT_TOUCH_ACT
	thickness = 3
	color = "#5769a5"

/datum/pollutant/slime_dust/touch_act(mob/living/victim, amount)
	if(!istype(victim, /mob/living/basic/slime) || amount < 90)
		return
	if(HAS_TRAIT(victim, TRAIT_SLIME_DUST_IMMUNE))
		return

	victim.adjustBruteLoss(1)

