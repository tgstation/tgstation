/datum/action/changeling/adrenaline
	name = "Gene Stim"
	desc = "Мы концентрируем наши химикаты в мощный стимулятор, делающий нашу форму потрясающе устойчивой к недееспособности. Стоит 25 химикатов"
	helptext = "Избавляет от любого оглушения и вливает в нашу форму ЧЕТЫРЕ единицы адреналина генокрада; наша форма восстанавливает огромное количество выносливости и просто не замечает боли или усталости во время его воздействия."
	button_icon_state = "adrenaline"
	category = "combat"
	chemical_cost = 25 // similar cost to biodegrade, as they serve similar purposes
	dna_cost = 2
	req_human = FALSE
	req_stat = CONSCIOUS
	disabled_by_fire = TRUE

//Recover from stuns.
/datum/action/changeling/adrenaline/sting_action(mob/living/carbon/user)
	..()

	// Get us standing up.
	user.SetAllImmobility(0)
	user.set_stamina_loss(0)
	user.set_resting(FALSE, instant = TRUE)

	user.reagents.add_reagent(/datum/reagent/medicine/changelingadrenaline, 4) //Tank 5 consecutive baton hits

	to_chat(user, span_changeling("The staggering rush of a stimulant honed precisely to our biology is INVIGORATING. We will not be subdued."))

	return TRUE
