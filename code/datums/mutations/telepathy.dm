/datum/mutation/human/telepathy
	name = "Telepathy"
	desc = "A rare mutation that allows the user to telepathically communicate to others."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>You can hear your own voice echoing in your mind!</span>"
	text_lose_indication = "<span class='notice'>You don't hear your mind echo anymore.</span>"
	difficulty = 12
	power_path = /datum/action/cooldown/spell/list_target/telepathy
	instability = POSITIVE_INSTABILITY_MINOR // basically a mediocre PDA messager
	energy_coeff = 1
