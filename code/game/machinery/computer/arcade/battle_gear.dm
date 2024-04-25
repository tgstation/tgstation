/datum/battle_arcade_gear
	///The name of the gear, used in shops.
	var/name = "Gear"
	///The slot this gear fits into
	var/slot
	///The world the player has to be at in order to buy this item.
	var/world_available
	///The stat given by the gear
	var/bonus_modifier

/datum/battle_arcade_gear/tier_1
	world_available = BATTLE_WORLD_ONE

/datum/battle_arcade_gear/tier_1/weapon
	name = "Sword"
	slot = WEAPON_SLOT
	bonus_modifier = 1.5

/datum/battle_arcade_gear/tier_1/armor
	name = "Leather Armor"
	slot = ARMOR_SLOT
	bonus_modifier = 1.5

/datum/battle_arcade_gear/tier_2
	world_available = BATTLE_WORLD_TWO

/datum/battle_arcade_gear/tier_2/weapon
	name = "Axe"
	slot = WEAPON_SLOT
	bonus_modifier = 1.75

/datum/battle_arcade_gear/tier_2/armor
	name = "Chainmail"
	slot = ARMOR_SLOT
	bonus_modifier = 1.75

/datum/battle_arcade_gear/tier_3
	world_available = BATTLE_WORLD_THREE

/datum/battle_arcade_gear/tier_3/weapon
	name = "Mace"
	slot = WEAPON_SLOT
	bonus_modifier = 2

/datum/battle_arcade_gear/tier_3/armor
	name = "Plate Armor"
	slot = ARMOR_SLOT
	bonus_modifier = 2

/datum/battle_arcade_gear/tier_4
	world_available = BATTLE_WORLD_FOUR

/datum/battle_arcade_gear/tier_4/weapon
	name = "Greatsword"
	slot = WEAPON_SLOT
	bonus_modifier = 2.5

/datum/battle_arcade_gear/tier_4/armor
	name = "Full Plate Armor"
	slot = ARMOR_SLOT
	bonus_modifier = 2.5

/datum/battle_arcade_gear/tier_5
	world_available = BATTLE_WORLD_FIVE

/datum/battle_arcade_gear/tier_5/weapon
	name = "Halberd"
	slot = WEAPON_SLOT
	bonus_modifier = 3

/datum/battle_arcade_gear/tier_5/armor
	name = "Dragon Scale Armor"
	slot = ARMOR_SLOT
	bonus_modifier = 3

/datum/battle_arcade_gear/tier_6
	world_available = BATTLE_WORLD_SIX

/datum/battle_arcade_gear/tier_6/weapon
	name = "Warhammer"
	slot = WEAPON_SLOT
	bonus_modifier = 3.5

/datum/battle_arcade_gear/tier_6/armor
	name = "Adamantine Armor"
	slot = ARMOR_SLOT
	bonus_modifier = 3.5

/datum/battle_arcade_gear/tier_7
	world_available = BATTLE_WORLD_SEVEN

/datum/battle_arcade_gear/tier_7/weapon
	name = "Excalibur"
	slot = WEAPON_SLOT
	bonus_modifier = 4

/datum/battle_arcade_gear/tier_7/armor
	name = "Ethereal Armor"
	slot = ARMOR_SLOT
	bonus_modifier = 4

/datum/battle_arcade_gear/tier_8
	world_available = BATTLE_WORLD_EIGHT

/datum/battle_arcade_gear/tier_8/weapon
	name = "Gungnir"
	slot = WEAPON_SLOT
	bonus_modifier = 4.5

/datum/battle_arcade_gear/tier_8/armor
	name = "Celestial Armor"
	slot = ARMOR_SLOT
	bonus_modifier = 4.5

/datum/battle_arcade_gear/tier_9
	world_available = BATTLE_WORLD_NINE

/datum/battle_arcade_gear/tier_9/weapon
	name = "Mjolnir"
	slot = WEAPON_SLOT
	bonus_modifier = 5

/datum/battle_arcade_gear/tier_9/armor
	name = "Void Armor"
	slot = ARMOR_SLOT
	bonus_modifier = 5
