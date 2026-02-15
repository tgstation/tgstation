/mob/living/carbon/human/proc/delayed_suicide()
	suicide_log()
	adjust_brute_loss(max(200 - get_total_damage(), 0))
	investigate_log("has died from committing suicide.", INVESTIGATE_DEATHS)
	death(FALSE)
	ghostize(FALSE) // Disallows reentering body and disassociates mind
