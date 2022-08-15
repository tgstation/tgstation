// Wizard spells that aid mobiilty(or stealth?)
/datum/spellbook_entry/mindswap
	name = "Mindswap"
	desc = "Allows you to switch bodies with a target next to you. You will both fall asleep when this happens, and it will be quite obvious that you are the target's body if someone watches you do it."
	spell_type = /datum/action/cooldown/spell/pointed/mind_transfer
	category = "Mobility"

/datum/spellbook_entry/knock
	name = "Knock"
	desc = "Opens nearby doors and closets."
	spell_type = /datum/action/cooldown/spell/aoe/knock
	category = "Mobility"
	cost = 1

/datum/spellbook_entry/blink
	name = "Blink"
	desc = "Randomly teleports you a short distance."
	spell_type = /datum/action/cooldown/spell/teleport/radius_turf/blink
	category = "Mobility"

/datum/spellbook_entry/teleport
	name = "Teleport"
	desc = "Teleports you to an area of your selection."
	spell_type = /datum/action/cooldown/spell/teleport/area_teleport/wizard
	category = "Mobility"

/datum/spellbook_entry/jaunt
	name = "Ethereal Jaunt"
	desc = "Turns your form ethereal, temporarily making you invisible and able to pass through walls."
	spell_type = /datum/action/cooldown/spell/jaunt/ethereal_jaunt
	category = "Mobility"

/datum/spellbook_entry/item/warpwhistle
	name = "Warp Whistle"
	desc = "A strange whistle that will transport you to a distant safe place on the station. There is a window of vulnerability at the beginning of every use."
	item_path = /obj/item/warp_whistle
	category = "Mobility"
	cost = 1

/datum/spellbook_entry/item/staffdoor
	name = "Staff of Door Creation"
	desc = "A particular staff that can mold solid walls into ornate doors. Useful for getting around in the absence of other transportation. Does not work on glass."
	item_path = /obj/item/gun/magic/staff/door
	cost = 1
	category = "Mobility"
