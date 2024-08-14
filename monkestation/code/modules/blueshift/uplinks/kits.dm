
/datum/uplink_category/weapon_kits
	name = "Weapon Kits (Recommended)"
	weight = 30

/datum/uplink_item/weapon_kits
	category = /datum/uplink_category/weapon_kits
	surplus = 40
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/weapon_kits/low_cost/clandestine
	name = "Ansem Pistol Case (Easy/Spare)"
	desc = "A small, easily concealable handgun that uses 10mm auto rounds in 8-round magazines and is compatible \
			with suppressors. Comes with three spare magazines."
	item = /obj/item/storage/toolbox/guncase/clandestine
	cost = 7 //this stuff is lying around the base to begin with so its not worth much

/datum/uplink_item/weapon_kits/medium_cost/carbine
	name = "M-90gl Carbine Case (Hard)"
	desc = "A fully-loaded, specialized three-round burst carbine that fires .223 ammunition from a 30 round magazine \
		with a 40mm underbarrel grenade launcher. Use secondary-fire to fire the grenade launcher. Comes with two spare magazines \
		and a box of 40mm rubber slugs."
	item = /obj/item/storage/toolbox/guncase/m90gl
	cost = 14

/datum/uplink_item/weapon_kits/medium_cost/bulldog
	name = "Bulldog bundle (Easy)"
	desc = "Lean and mean: Optimized for people that want to get up close and personal. Contains the popular \
			Bulldog shotgun, two 12g buckshot drums, and a pair of Thermal imaging goggles."
	item = /obj/item/storage/backpack/duffelbag/syndie/bulldogbundle
	cost = 13 // normally 16
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/weapon_kits/medium_cost/c20r
	name = "C-20r bundle (Easy)"
	desc = "Old Faithful: The classic C-20r, bundled with two magazines and a suppressor at discount price."
	item = /obj/item/storage/backpack/duffelbag/syndie/c20rbundle
	cost = 14 // normally 16
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/weapon_kits/medium_cost/rawketlawnchair
	name = "Dardo-RE Rocket Propelled Grenade Launcher (Hard)"
	desc = "A reusable rocket propelled grenade launcher preloaded with a low-yield 84mm HE round. \
		Guaranteed to send your target out with a bang or your money back! Comes with a bouquet of additional rockets!"
	cost = 16
	item = /obj/item/storage/toolbox/guncase/rocketlauncher

/datum/uplink_item/weapon_kits/medium_cost/revolvercase
	name = "Syndicate Revolver Case (Moderate)"
	desc = "Waffle Co.'s modernized Syndicate revolver. Fires 7 brutal rounds of .357 Magnum. \
		A classic operative weapon, brought to the modern era. Comes with 3 additional speedloaders of .357. Try not to miss."
	cost = 15
	item = /obj/item/storage/toolbox/guncase/revolver

/datum/uplink_item/weapon_kits/high_cost/sword_and_board
	name = "Energy sword and shield combo box (Moderate)"
	desc = "An Energy Shield and sword combo, popular amongst agents that like to get shot in the back."
	cost = 18
	item = /obj/item/storage/toolbox/guncase/sword_and_board

/datum/uplink_item/weapon_kits/high_cost/cqc
	name = "CQC Equipment Case (Very Hard)"
	desc = "Contains a manual that instructs you in the ways of CQC, or Close Quarters Combat. Comes with a stealth implant, a pack of smokes and a discount bandana and a thermal eyepatch."
	item = /obj/item/storage/toolbox/guncase/cqc
	purchasable_from = UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS
	cost = 15
	surplus = 0
