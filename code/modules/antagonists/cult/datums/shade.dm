/datum/antagonist/cult/shade
	name = "Тень культа"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	antagpanel_category = ANTAG_GROUP_HORRORS
	///The time this player was most recently released from a soulstone.
	var/release_time
	///The time needed after release time to enable rune invocation.
	var/invoke_delay = (1 MINUTES)

/datum/antagonist/cult/shade/check_invoke_validity()
	if(isnull(release_time))
		to_chat(owner.current, span_alert("Вы не можете вызывать руны, находясь в камне душ!"))
		return FALSE

	if(release_time + invoke_delay > world.time)
		to_chat(owner.current, span_alert("Вы не накопили достаточно сил для вызова рун. Вам нужно некоторое время с момента выхода из камня душ!"))
		return FALSE
	return TRUE
