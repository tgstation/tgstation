/spell/targeted/subjugation
	name = "Subjugation"
	desc = "This spell temporarily subjugates a target's mind and does not require wizard garb."

	school = "transmutation"
	charge_max = 300
	invocation = "DII ODA BAJI"
	invocation_type = SpI_WHISPER
	message = "<span class='danger'>You suddenly feel completely overwhelmed!<span>"

	max_targets = 1

	amt_dizziness = 86
	amt_confused = 86 // 2.1 seconds per = 180.6s
	amt_stuttering = 86

	compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey)

	hud_state = "wiz_subj"