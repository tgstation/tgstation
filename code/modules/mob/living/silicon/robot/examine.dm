/mob/living/silicon/robot/examine(mob/user)
	. = list("<span class='info'>This is [icon2html(src, user)] <EM>[src]</EM>!")
	if(desc)
		. += "[desc]"

	var/model_name = model ? "\improper [model.name]" : "\improper Default"
	. += "\nIt is currently \a \"[span_bold("[model_name]")]\"-type cyborg.\n"

	var/obj/act_module = get_active_held_item()
	if(act_module)
		. += "It is holding [icon2html(act_module, user)] \a [act_module]."
	. += get_status_effect_examinations()
	if (getBruteLoss())
		if (getBruteLoss() < maxHealth*0.5)
			. += span_warning("It looks slightly dented.")
		else
			. += span_warning("<B>It looks severely dented!</B>")
	if (getFireLoss() || getToxLoss())
		var/overall_fireloss = getFireLoss() + getToxLoss()
		if (overall_fireloss < maxHealth * 0.5)
			. += span_warning("It looks slightly charred.")
		else
			. += span_warning("<B>It looks severely burnt and heat-warped!</B>")
	if (health < -maxHealth*0.5)
		. += span_warning("It looks barely operational.")
	if (fire_stacks < 0)
		. += span_warning("It's covered in water.")
	else if (fire_stacks > 0)
		. += span_warning("It's coated in something flammable.")

	if(opened)
		. += span_warning("Its cover is open and the power cell is [cell ? "installed" : "missing"].")
	else
		. += "Its cover is closed[locked ? "" : ", and looks unlocked"]."

	if(cell && cell.charge <= 0)
		. += span_warning("Its battery indicator is blinking red!")

	switch(stat)
		if(CONSCIOUS)
			if(shell)
				. += "It appears to be an [deployed ? "active" : "empty"] AI shell."
			else if(!client)
				. += "It appears to be in stand-by mode." //afk
		if(SOFT_CRIT, UNCONSCIOUS, HARD_CRIT)
			. += span_warning("It doesn't seem to be responding.")
		if(DEAD)
			. += span_deadsay("It looks like its system is corrupted and requires a reset.")
	. += "</span>"

	. += ..()

/mob/living/silicon/robot/get_examine_string(mob/user, thats = FALSE)
	return null
