/datum/uplink_category/spy_unique
	name = "Spy Unique"

// This is solely for uplink items that the spy can randomly obtain via bounties.
// As such the name is really the only thing that matters - cost is free and description is never shown
/datum/uplink_item/spy_unique
	category = /datum/uplink_category/spy_unique
	cant_discount = TRUE
	surplus = FALSE
	purchasable_from = UPLINK_SPY
	cost = SPY_LOWER_COST_THRESHOLD // by default, these fall into easy-medium spy bounty loot pool

/datum/uplink_item/spy_unique/combat_gloves
	name = "Combat Gloves"
	desc = "A pair of combat gloves. They're insulated!"
	item = /obj/item/clothing/gloves/combat
	cost = 1

/datum/uplink_item/spy_unique/krav_maga
	name = "Combat Gloves Plus"
	desc = "A pair of combat gloves plus. They're insulated AND you can do martial arts with it!"
	item = /obj/item/clothing/gloves/krav_maga/combatglovesplus

/datum/uplink_item/spy_unique/tackle_gloves
	name = "Guerrilla Gloves"
	desc = "A pair of Guerrilla gloves. They're insulated AND you can tackle people with it!"
	item = /obj/item/clothing/gloves/tackler/combat/insulated

/datum/uplink_item/spy_unique/syndie_bowman
	name = "Syndicate Bowman"
	desc = "A bowman headset for members of the Syndicate. Not very conspicuous."
	item = /obj/item/radio/headset/syndicate/alt
	cost = 1

/datum/uplink_item/spy_unique/kudzu
	name = "Kudzu"
	desc = "A packet of Kudzu - plant and forget, a great distraction."
	item = /obj/item/seeds/kudzu

/datum/uplink_item/spy_unique/megaphone
	name = "Megaphone"
	desc = "A megaphone. It's loud."
	item = /obj/item/megaphone
	cost = 1

/datum/uplink_item/spy_unique/big_knife
	name = "Combat Knife"
	desc = "A big knife. It's sharp."
	item = /obj/item/knife/combat

/datum/uplink_item/spy_unique/sechud_implant
	name = "SecHUD Implant"
	desc = "A SecHUD implant. Shows you the ID of people you're looking at. It's also stealthy!"
	item = /obj/item/autosurgeon/syndicate/contraband_sechud

/obj/item/autosurgeon/syndicate/contraband_sechud
	desc = "Contains a contraband SecHUD implant, undetectable by health scanners."
	uses = 1
	starting_organ = /obj/item/organ/internal/cyberimp/eyes/hud/security/syndicate
