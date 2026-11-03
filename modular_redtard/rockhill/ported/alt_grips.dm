/datum/alt_grip/halfsword
	name = "halfsword"
	two_handed = TRUE
	skill_rank = 3
	grip_intents = list(/datum/intent/sword/thrust/long/halfsword/jab, /datum/intent/sword/strike/bash/mordhau, /datum/intent/sword/thrust/long/deep/halfsword, /datum/intent/sword/thrust/long/halfsword)
	inhand_suffix = "_halfsword"
	var_overrides = list("wlength" = 1)
	additive_var_overrides = list("wdefense" = 2)

/datum/alt_grip/halfsword/greatsword
	name = "halfsword"
	two_handed = TRUE
	skill_rank = 3
	grip_intents = list(/datum/intent/sword/thrust/long/halfsword)
	inhand_suffix = "_greatsword"
	var_overrides = list("wlength" = 2)
	additive_var_overrides = list("wdefense" = 2)

/datum/alt_grip/mordhau/broadsword
	name = "mordhau"
	two_handed = TRUE
	grip_intents = list(/datum/intent/sword/strike/bash/mordhau, /datum/intent/sword/strike/bash/mordhau/smash, /datum/intent/effect/daze)
	inhand_suffix = "_broadsword"

/datum/alt_grip/mordhau/broadsword/forgotten_blade
	name = "mordhau"
	two_handed = TRUE
	grip_intents = list(/datum/intent/sword/strike/bash/mordhau, /datum/intent/sword/strike/bash/mordhau/smash, /datum/intent/effect/daze)
	inhand_suffix = "_forgotten_blade"

/datum/alt_grip/mordhau/greatsword
	name = "mordhau"
	two_handed = TRUE
	grip_intents = list(/datum/intent/sword/strike/bash/mordhau, /datum/intent/sword/strike/bash/mordhau/smash, /datum/intent/effect/daze)
	inhand_suffix = "_greatsword"
	var_overrides = list("wlength" = 2)

/datum/alt_grip/mordhau/sword
	name = "mordhau"
	two_handed = TRUE
	grip_intents = list(/datum/intent/sword/strike/bash/mordhau, /datum/intent/sword/strike/bash/mordhau/smash, /datum/intent/effect/daze)
	inhand_suffix = "_sword"
	var_overrides = list("wlength" = 1)
	additive_var_overrides = list("wdefense" = -2)
