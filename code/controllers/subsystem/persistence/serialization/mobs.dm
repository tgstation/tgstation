/mob/living/basic/dark_wizard/get_save_vars()
	return ..() - NAMEOF(src, icon_state) // icon_state is applied via apply_dynamic_human_appearance()
