/mob/living/silicon/robot/proc/latejoin_find_parent_ai(target_z_level = 3)
	if(connected_ai)
		return
	var/mob/living/silicon/ai/AI = select_active_ai_with_fewest_borgs(target_z_level)
	if(AI)
		set_connected_ai(AI)
	lawsync()
	show_laws()
