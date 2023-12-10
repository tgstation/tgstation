/datum/quirk/cyborg_lover
	name = "Cyborg Lover"
	desc = "You find silicon life forms fascinating! You like inspecting and touching their hulls and robo-bodies, as well you like being touched by their manipulators."
	icon = FA_ICON_ROBOT
	value = 2
	mob_trait = TRAIT_CYBORG_LOVER
	gain_text = span_notice("You are fascinated by silicon life forms.")
	lose_text = span_danger("Cyborgs and other silicons aren't cool anymore.")
	medical_record_text = "Patient reports being fascinated by silicon life forms."
	mail_goodies = list(
		/obj/item/stock_parts/cell/potato,
		/obj/item/stack/cable_coil,
		/obj/item/toy/talking/ai,
		/obj/item/toy/figure/borg,
	)

/datum/quirk/cyborg_lover/add(client/client_source)
	var/datum/atom_hud/fan = GLOB.huds[DATA_HUD_FAN]
	fan.show_to(quirk_holder)
