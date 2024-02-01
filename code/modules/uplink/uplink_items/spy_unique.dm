/datum/uplink_category/spy_unique
	name = "Spy Unique"

// This is solely for uplink items that the spy can randomly obtain via bounties.
/datum/uplink_item/spy_unique
	category = /datum/uplink_category/spy_unique
	cant_discount = TRUE
	surplus = FALSE
	purchasable_from = UPLINK_SPY
	// Cost doesn't really matter since it's free, but it determines which loot pool it falls into.
	// By default, these fall into easy-medium spy bounty loot pool.atom
	cost = SPY_LOWER_COST_THRESHOLD

/datum/uplink_item/spy_unique/syndie_bowman
	name = "Syndicate Bowman"
	desc = "A bowman headset for members of the Syndicate. Not very conspicuous."
	item = /obj/item/radio/headset/syndicate/alt
	cost = 1

/datum/uplink_item/spy_unique/megaphone
	name = "Megaphone"
	desc = "A megaphone. It's loud."
	item = /obj/item/megaphone
	cost = 1

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

/datum/uplink_item/spy_unique/kudzu
	name = "Kudzu"
	desc = "A packet of Kudzu - plant and forget, a great distraction."
	item = /obj/item/seeds/kudzu

/datum/uplink_item/spy_unique/big_knife
	name = "Combat Knife"
	desc = "A big knife. It's sharp."
	item = /obj/item/knife/combat

/datum/uplink_item/spy_unique/switchblade
	name = "Switchblade"
	desc = "A switchblade. Switches between not sharp and sharp."
	item = /obj/item/switchblade

/datum/uplink_item/spy_unique/sechud_implant
	name = "SecHUD Implant"
	desc = "A SecHUD implant. Shows you the ID of people you're looking at. It's also stealthy!"
	item = /obj/item/autosurgeon/syndicate/contraband_sechud

/datum/uplink_item/spy_unique/rifle_prime
	name = "Bolt-Action Rifle"
	desc = "A bolt-action rifle, with a scope. Won't jam, either."
	item = /obj/item/gun/ballistic/rifle/boltaction/prime
	cost = SPY_UPPER_COST_THRESHOLD

/datum/uplink_item/spy_unique/cycler_shotgun
	name = "Cycler Shotgun"
	desc = "A cycler shotgun. It's a shotgun that cycles between two barrels."
	item = /obj/item/gun/ballistic/shotgun/automatic/dual_tube
	cost = SPY_UPPER_COST_THRESHOLD

/datum/uplink_item/spy_unique/bulldog_shotgun
	name = "Bulldog Shotgun"
	desc = "A bulldog shotgun. It's a shotgun that shoots bulldogs."
	item = /obj/item/gun/ballistic/shotgun/bulldog/unrestricted
	cost = SPY_UPPER_COST_THRESHOLD

/datum/uplink_item/spy_unique/katana
	name = "Katana"
	desc = "A really sharp Katana. Did I mention it's sharp?"
	item = /obj/item/katana
	cost = 16 // dualsaber-tier

/datum/uplink_item/spy_unique/medkit_lite
	name = "Syndicate First Medic Kit"
	desc = "A syndicate tactical combat medkit, but only stocked enough to do basic first aid."
	item = /obj/item/storage/medkit/tactical_lite
	purchasable_from = UPLINK_SPY
