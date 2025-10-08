/datum/uplink_category/spy_unique
	name = "Spy Unique"

// This is solely for uplink items that the spy can randomly obtain via bounties.
/datum/uplink_item/spy_unique
	category = /datum/uplink_category/spy_unique
	cant_discount = TRUE
	surplus = FALSE
	purchasable_from = UPLINK_SPY
	// Cost doesn't really matter since it's free, but it determines which loot pool it falls into.
	// By default, these fall into easy-medium spy bounty loot pool
	cost = SPY_LOWER_COST_THRESHOLD
	uplink_item_flags = NONE

/datum/uplink_item/spy_unique/syndie_bowman
	name = "Syndicate Bowman"
	desc = "A bowman headset for members of the Syndicate. Not very conspicuous."
	item = /obj/item/radio/headset/syndicate/alt
	cost = 1
	uplink_item_flags = SYNDIE_ILLEGAL_TECH

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
	uplink_item_flags = SYNDIE_TRIPS_CONTRABAND

/datum/uplink_item/spy_unique/big_knife
	name = "Combat Knife"
	desc = "A big knife. It's sharp."
	item = /obj/item/knife/combat

/datum/uplink_item/spy_unique/switchblade
	name = "Switchblade"
	desc = "A switchblade. Switches between not sharp and sharp."
	item = /obj/item/switchblade
	uplink_item_flags = SYNDIE_TRIPS_CONTRABAND

/datum/uplink_item/spy_unique/sechud_implant
	name = "SecHUD Implant"
	desc = "A SecHUD implant. Shows you the ID of people you're looking at. It's also stealthy!"
	item = /obj/item/autosurgeon/syndicate/contraband_sechud

/datum/uplink_item/spy_unique/rifle_prime
	name = "Bolt-Action Rifle"
	desc = "A bolt-action rifle, with a scope. Won't jam, either."
	item = /obj/item/gun/ballistic/rifle/boltaction/prime
	cost = SPY_UPPER_COST_THRESHOLD
	uplink_item_flags = SYNDIE_ILLEGAL_TECH | SYNDIE_TRIPS_CONTRABAND

/datum/uplink_item/spy_unique/cycler_shotgun
	name = "Cycler Shotgun"
	desc = "A cycler shotgun. It's a shotgun that cycles between two barrels."
	item = /obj/item/gun/ballistic/shotgun/automatic/dual_tube/deadly
	cost = SPY_UPPER_COST_THRESHOLD
	uplink_item_flags = SYNDIE_ILLEGAL_TECH | SYNDIE_TRIPS_CONTRABAND

/datum/uplink_item/spy_unique/bulldog_shotgun
	name = "Bulldog Shotgun"
	desc = "A bulldog shotgun. It's a shotgun that shoots bulldogs."
	item = /obj/item/gun/ballistic/shotgun/bulldog/unrestricted
	cost = SPY_UPPER_COST_THRESHOLD
	uplink_item_flags = SYNDIE_ILLEGAL_TECH | SYNDIE_TRIPS_CONTRABAND

/datum/uplink_item/spy_unique/ansem_pistol
	name = "Ansem Pistol"
	desc = "A pistol that's really good at making people sleep."
	item = /obj/item/gun/ballistic/automatic/pistol/clandestine
	cost = SPY_UPPER_COST_THRESHOLD
	uplink_item_flags = SYNDIE_ILLEGAL_TECH | SYNDIE_TRIPS_CONTRABAND

/datum/uplink_item/spy_unique/rocket_launcher
	name = "Rocket Launcher"
	desc = "A rocket launcher. I would recommend against jumping with it."
	item = /obj/item/gun/ballistic/rocketlauncher
	cost = SPY_UPPER_COST_THRESHOLD - 1 // It's a meme item
	uplink_item_flags = SYNDIE_ILLEGAL_TECH | SYNDIE_TRIPS_CONTRABAND

/datum/uplink_item/spy_unique/shotgun_ammo
	name = "Box of Buckshot"
	desc = "A box of buckshot rounds for a shotgun. For when you don't want to miss."
	item = /obj/item/storage/box/lethalshot
	cost = 1

/datum/uplink_item/spy_unique/shotgun_ammo/breacher_slug
	name = "Box of Breacher Slugs"
	desc = "A box of breacher slugs for a shotgun. For making a good first impression."
	item = /obj/item/storage/box/breacherslug

/datum/uplink_item/spy_unique/shotgun_ammo/slugs
	name = "Box of Slugs"
	desc = "A box of slugs for a shotgun. For big game hunting."
	item = /obj/item/storage/box/slugs

/datum/uplink_item/spy_unique/stealth_belt
	name = "Stealth Belt"
	desc = "A stealth belt that lets you sneak behind enemy lines."
	item = /obj/item/shadowcloak/weaker
	cost = SPY_UPPER_COST_THRESHOLD
	uplink_item_flags = SYNDIE_ILLEGAL_TECH

/datum/uplink_item/spy_unique/katana
	name = "Katana"
	desc = "A really sharp Katana. Did I mention it's sharp?"
	item = /obj/item/katana
	cost = /datum/uplink_item/dangerous/doublesword::cost // Puts it in the same pool as Desword
	uplink_item_flags = SYNDIE_ILLEGAL_TECH | SYNDIE_TRIPS_CONTRABAND

/datum/uplink_item/spy_unique/medkit_lite
	name = "Syndicate First Medic Kit"
	desc = "A syndicate tactical combat medkit, but only stocked enough to do basic first aid."
	item = /obj/item/storage/medkit/tactical_lite
	uplink_item_flags = SYNDIE_TRIPS_CONTRABAND

/datum/uplink_item/spy_unique/antistun
	name = /datum/uplink_item/implants/nuclear/antistun::name
	desc = /datum/uplink_item/implants/nuclear/antistun::desc
	item = /obj/item/autosurgeon/syndicate/anti_stun/single_use

/datum/uplink_item/spy_unique/reviver
	name = /datum/uplink_item/implants/nuclear/reviver::name
	desc = /datum/uplink_item/implants/nuclear/reviver::desc
	item = /obj/item/autosurgeon/syndicate/reviver/single_use

/datum/uplink_item/spy_unique/thermals
	name = /datum/uplink_item/implants/nuclear/thermals::name
	desc = /datum/uplink_item/implants/nuclear/thermals::desc
	item = /obj/item/autosurgeon/syndicate/thermal_eyes/single_use

/datum/uplink_item/spy_unique/nunchaku
	name = "Syndie Fitness Nunchuks"
	desc = "Heavyweight titanium nunchucks, quickly knocking opponents to the ground, then just as easily smashing the opponent afterward."
	item = /obj/item/melee/baton/nunchaku
	cost = SPY_UPPER_COST_THRESHOLD
	uplink_item_flags = SYNDIE_ILLEGAL_TECH | SYNDIE_TRIPS_CONTRABAND

/datum/uplink_item/spy_unique/penbang
	name = "Penbang"
	desc = "A flashbang disguised as a normal pen - click and throw! Has no other warning upon being activated. \
		Fuse duration depends on how far the cap is twisted."
	item = /obj/item/pen/penbang
	cost = 1

/datum/uplink_item/spy_unique/cameraflash
	name = "Camera Flash"
	desc = "A camera with a high-powered flash. Can be used as a normal flash when in close proximity to a target."
	item = /obj/item/camera/flash
	cost = 1

/datum/uplink_item/spy_unique/daggerboot
	name = "Boot Dagger"
	desc = "A pair of boots with a dagger embedded into the sole. Kicks with these will stab the target, potentially causing bleeding."
	item = /obj/item/clothing/shoes/jackboots/dagger
	cost = 1

/datum/uplink_item/spy_unique/monster_cube_box
	name = "Random Monster Cubes"
	desc = "A box containing a bunch of random monster cubes. Add water and see what you get!"
	item = /obj/item/storage/box/monkeycubes/random
	cost = SPY_LOWER_COST_THRESHOLD // There's some really bad stuff in here but also some really mild stuff

/datum/uplink_item/spy_unique/sleeping_carp
	name = "Sleeping Carp Technique"
	desc = "A scroll teaching you the basics of the Sleeping Carp martial art."
	item = /datum/uplink_item/stealthy_weapons/martialarts::item
	cost = /datum/uplink_item/stealthy_weapons/martialarts::cost

/datum/uplink_item/spy_unique/spider_bite
	name = "Spider Bite Technique"
	desc = "A scroll teaching you the basics of the Spider Bite martial art."
	item = /obj/item/book/granter/martial/spider_bite
	cost = SPY_UPPER_COST_THRESHOLD // While SCarp is firmly in the upper threshold, Spider Bite can be in either middle or upper.
