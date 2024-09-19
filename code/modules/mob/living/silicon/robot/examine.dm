#define ADD_NEWLINE_IF_NECESSARY(list) if(length(list) > 0 && list[length(list)]) { list += "" }

/mob/living/silicon/robot/examine(mob/user)
	. = list()
	if(desc)
		. += "[desc]"

	// DOPPLER EDIT BEGIN: flavor text
	var/short_desc = READ_PREFS(src, text/silicon_short_desc)
	if (short_desc)
		. += "[short_desc] [get_extended_description_href("\[👁️\]")]"
	ADD_NEWLINE_IF_NECESSARY(.)
	var/custom_model_name = READ_PREFS(src, text/silicon_model_name)
	if (custom_model_name)
		. += "It is [prefix_a_or_an(custom_model_name)] <em>[get_species_description_href(custom_model_name)]</em> model construct."
	// DOPPLER EDIT END

	var/model_name = model ? "\improper [model.name]" : "\improper Default"
	. += "It is currently <b>\a [model_name]-type</b> cyborg."

	var/obj/act_module = get_active_held_item()
	if(act_module)
		. += "It is holding [icon2html(act_module, user)] \a [act_module]."
	. += get_status_effect_examinations()
	if (getBruteLoss())
		if (getBruteLoss() < maxHealth*0.5)
			. += span_warning("It looks slightly dented.")
		else
			. += span_boldwarning("It looks severely dented!")
	if (getFireLoss() || getToxLoss())
		var/overall_fireloss = getFireLoss() + getToxLoss()
		if (overall_fireloss < maxHealth * 0.5)
			. += span_warning("It looks slightly charred.")
		else
			. += span_boldwarning("It looks severely burnt and heat-warped!")
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

	. += ..()

#undef ADD_NEWLINE_IF_NECESSARY
