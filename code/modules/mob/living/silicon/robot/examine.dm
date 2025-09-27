/mob/living/silicon/robot/examine(mob/user)
	. = list()
	if(desc)
		. += "[desc]"

	var/model_name = model ? "\improper [model.name]" : "\improper Default"
	. += "[p_Theyre()] currently <b>\a [model_name]-type</b> cyborg."

	var/obj/act_module = get_active_held_item()
	if(act_module)
		. += "[p_Theyre()] holding [icon2html(act_module, user)] \a [act_module]."
	. += get_status_effect_examinations()
	if (getBruteLoss())
		if (getBruteLoss() < maxHealth*0.5)
			. += span_warning("[p_They()] look[p_s()] slightly dented.")
		else
			. += span_boldwarning("[p_They()] look[p_s()] severely dented!")
	if (getFireLoss() || getToxLoss())
		var/overall_fireloss = getFireLoss() + getToxLoss()
		if (overall_fireloss < maxHealth * 0.5)
			. += span_warning("[p_They()] look[p_s()] slightly charred.")
		else
			. += span_boldwarning("[p_They()] look[p_s()] severely burnt and heat-warped!")
	if (health < -maxHealth*0.5)
		. += span_warning("[p_They()] look[p_s()] barely operational.")
	if (fire_stacks < 0)
		. += span_warning("[p_Theyre()] covered in water.")
	else if (fire_stacks > 0)
		. += span_warning("[p_Theyre()] coated in something flammable.")

	if(opened)
		. += span_warning("[p_Their()] cover is open and the power cell is [cell ? "installed" : "missing"].")
	else
		. += "[p_Their()] cover is closed[locked ? "" : ", and looks unlocked"]."

	if(cell && cell.charge <= 0)
		. += span_warning("[p_Their()] battery indicator is blinking red!")

	switch(stat)
		if(CONSCIOUS)
			if(shell)
				. += "[p_They()] appear[p_s()] to be an [deployed ? "active" : "empty"] AI shell."
			else if(!client)
				. += "[p_They()] appear[p_s()] to be in stand-by mode." //afk
		if(SOFT_CRIT, UNCONSCIOUS, HARD_CRIT)
			. += span_warning("[p_They()] do[p_es()]n't seem to be responding.")
		if(DEAD)
			. += span_deadsay("[p_They()] look[p_s()] like its system is corrupted and requires a reset.")

	. += ..()
