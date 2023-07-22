/datum/action/cooldown/spell/conjure_item/snowball
	name = "Snowball"
	desc = "Concentrates cryokinetic forces to create snowballs, useful for throwing at people."
	button_icon = 'icons/obj/toys/toy.dmi'
	button_icon_state = "snowball"

	spell_requirements = NONE
	antimagic_flags = NONE
	cooldown_time = 1.5 SECONDS
	delete_on_failure = FALSE
	drop_inhand = TRUE
	item_type = /obj/item/toy/snowball
