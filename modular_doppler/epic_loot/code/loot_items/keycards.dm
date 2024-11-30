/datum/export/epic_loot_lost_keycards
	cost = PAYCHECK_COMMAND * 2
	unit_name = "lost keycards"
	export_types = list(
		/obj/item/keycard/epic_loot/green,
		/obj/item/keycard/epic_loot/teal,
		/obj/item/keycard/epic_loot/blue,
		/obj/item/keycard/epic_loot/ourple,
		/obj/item/keycard/epic_loot/red,
		/obj/item/keycard/epic_loot/orange,
		/obj/item/keycard/epic_loot/yellow,
		/obj/item/keycard/epic_loot/black,
	)

/obj/item/keycard/epic_loot
	name = "broken keycard"
	desc = "You shouldn't have this."
	icon = 'modular_lethal_doppler/epic_loot/icons/epic_loot.dmi'
	icon_state = "keycard_basetype"
	color = "#ffffff"
	puzzle_id = "黄昏の"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'

/obj/item/keycard/epic_loot/examine(mob/user)
	. = ..()
	. += span_engradio("You can probably <b>sell</b> this for some good money if you have no other use for it.")
	return .

/obj/item/keycard/epic_loot/green
	name = "green keycard"
	desc = "A standard keycard with a green trim."
	icon_state = "keycard_green"
	puzzle_id = "epic_loot_green"

/obj/item/keycard/epic_loot/teal
	name = "teal keycard"
	desc = "A standard keycard with a teal trim."
	icon_state = "keycard_teal"
	puzzle_id = "epic_loot_teal"

/obj/item/keycard/epic_loot/blue
	name = "blue keycard"
	desc = "A standard keycard with a blue trim."
	icon_state = "keycard_blue"
	puzzle_id = "epic_loot_blue"

/obj/item/keycard/epic_loot/ourple
	name = "purple keycard"
	desc = "A standard keycard with a purple trim."
	icon_state = "keycard_ourple"
	puzzle_id = "epic_loot_purple"

/obj/item/keycard/epic_loot/red
	name = "red keycard"
	desc = "A standard keycard with a red trim."
	icon_state = "keycard_red"
	puzzle_id = "epic_loot_red"

/obj/item/keycard/epic_loot/orange
	name = "orange keycard"
	desc = "A standard keycard with an orange trim."
	icon_state = "keycard_orange"
	puzzle_id = "epic_loot_orange"

/obj/item/keycard/epic_loot/yellow
	name = "yellow keycard"
	desc = "A standard keycard with a yellow trim."
	icon_state = "keycard_yellow"
	puzzle_id = "epic_loot_yellow"

/obj/item/keycard/epic_loot/black
	name = "black keycard"
	desc = "A standard keycard with a black trim."
	icon_state = "keycard_evil"
	puzzle_id = "epic_loot_black"
