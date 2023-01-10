/mob/living/carbon/human/proc/delayed_suicide()
	suicide_log()
	adjustBruteLoss(max(200 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
	investigate_log("has died from committing suicide.", INVESTIGATE_DEATHS)
	death(FALSE)
	ghostize(FALSE) // Disallows reentering body and disassociates mind
