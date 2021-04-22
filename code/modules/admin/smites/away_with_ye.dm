/datum/smite/away_with_ye
	name = "THEY MUST GO"

/datum/smite/away_with_ye/effect(client/user, mob/living/target)
	. = ..()
	target.apply_status_effect(STATUS_EFFECT_GO_AWAY_HARD)
