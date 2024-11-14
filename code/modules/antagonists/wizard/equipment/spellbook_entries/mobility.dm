#define SPELLBOOK_CATEGORY_MOBILITY "Mobility"
// Wizard spells that aid mobiilty(or stealth?)
/datum/spellbook_entry/mindswap
	name = "Mindswap"
	desc = "Allows you to switch bodies with a target next to you. You will both fall asleep when this happens, and it will be quite obvious that you are the target's body if someone watches you do it."
	spell_type = /datum/action/cooldown/spell/pointed/mind_transfer
	category = SPELLBOOK_CATEGORY_MOBILITY

/datum/spellbook_entry/knock
	name = "Knock"
	desc = "Opens nearby doors and closets."
	spell_type = /datum/action/cooldown/spell/aoe/knock
	category = SPELLBOOK_CATEGORY_MOBILITY
	cost = 1

/datum/spellbook_entry/blink
	name = "Blink"
	desc = "Randomly teleports you a short distance."
	spell_type = /datum/action/cooldown/spell/teleport/radius_turf/blink
	category = SPELLBOOK_CATEGORY_MOBILITY

/datum/spellbook_entry/teleport
	name = "Teleport"
	desc = "Teleports you to an area of your selection."
	spell_type = /datum/action/cooldown/spell/teleport/area_teleport/wizard
	category = SPELLBOOK_CATEGORY_MOBILITY

/datum/spellbook_entry/jaunt
	name = "Ethereal Jaunt"
	desc = "Turns your form ethereal, temporarily making you invisible and able to pass through walls."
	spell_type = /datum/action/cooldown/spell/jaunt/ethereal_jaunt
	category = SPELLBOOK_CATEGORY_MOBILITY

/datum/spellbook_entry/swap
	name = "Swap"
	desc = "Switch places with any living target within nine tiles. Right click to mark a secondary target. You will always swap to your primary target."
	spell_type = /datum/action/cooldown/spell/pointed/swap
	category = SPELLBOOK_CATEGORY_MOBILITY
	cost = 1

/datum/spellbook_entry/item/warpwhistle
	name = "Warp Whistle"
	desc = "A strange whistle that will transport you to a distant safe place on the station. There is a window of vulnerability at the beginning of every use."
	item_path = /obj/item/warp_whistle
	category = SPELLBOOK_CATEGORY_MOBILITY
	cost = 1

/datum/spellbook_entry/item/staffdoor
	name = "Staff of Door Creation"
	desc = "A particular staff that can mold solid walls into ornate doors. Useful for getting around in the absence of other transportation. Does not work on glass."
	item_path = /obj/item/gun/magic/staff/door
	cost = 1
	category = SPELLBOOK_CATEGORY_MOBILITY

/datum/spellbook_entry/item/teleport_rod
	name = /obj/item/teleport_rod::name
	desc = /obj/item/teleport_rod::desc
	item_path = /obj/item/teleport_rod
	cost = 2 // Puts it at 3 cost if you go for safety instant summons, but teleporting anywhere on screen is pretty good.
	category = SPELLBOOK_CATEGORY_MOBILITY

#undef SPELLBOOK_CATEGORY_MOBILITY
