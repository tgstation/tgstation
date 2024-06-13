// MONKESTATION NOTE: Prevents silicons from losing their soul when suiciding since they can be ordered to do so.

/mob/living/silicon/set_suicide(suicide_state)
	return

/mob/living/silicon/final_checkout(obj/item/suicide_tool, apply_damage)
	if(apply_damage) // copy paste for the most part
		apply_suicide_damage()

	suicide_log(suicide_tool)
	death(FALSE)
	ghostize(TRUE) // except this is set to TRUE
