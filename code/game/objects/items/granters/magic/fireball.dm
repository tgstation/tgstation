/obj/item/book/granter/action/spell/fireball
	granted_action = /datum/action/cooldown/spell/pointed/projectile/fireball
	action_name = "fireball"
	icon_state ="bookfireball"
	desc = "This book feels warm to the touch."
	remarks = list(
		"Aim...AIM, FOOL!",
		"Just catching them on fire won't do...",
		"Accounting for crosswinds... really?",
		"I think I just burned my hand...",
		"Why the dumb stance? It's just a flick of the hand...",
		"OMEE... ONI... Ugh...",
		"What's the difference between a fireball and a pyroblast...",
	)

/obj/item/book/granter/action/spell/fireball/recoil(mob/living/user)
	. = ..()
	explosion(
		user,
		devastation_range = 1,
		light_impact_range = 2,
		flame_range = 2,
		flash_range = 3,
		adminlog = FALSE,
		explosion_cause = src,
	)
	qdel(src)
