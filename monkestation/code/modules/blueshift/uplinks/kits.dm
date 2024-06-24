
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

/datum/uplink_item/weapon_kits/high_cost/carbine
	name = "M-90gl Carbine Case (Hard)"
	desc = "A fully-loaded, specialized three-round burst carbine that fires .223 ammunition from a 30 round magazine \
		with a 40mm underbarrel grenade launcher. Use secondary-fire to fire the grenade launcher. Comes with two spare magazines \
		and a box of 40mm rubber slugs."
	item = /obj/item/storage/toolbox/guncase/m90gl

/datum/uplink_item/weapon_kits/medium_cost/rawketlawnchair
	name = "Dardo-RE Rocket Propelled Grenade Launcher (Hard)"
	desc = "A reusable rocket propelled grenade launcher preloaded with a low-yield 84mm HE round. \
		Guaranteed to send your target out with a bang or your money back! Comes with a bouquet of additional rockets!"
	item = /obj/item/storage/toolbox/guncase/rocketlauncher

/datum/uplink_item/weapon_kits/medium_cost/revolvercase
	name = "Syndicate Revolver Case (Moderate)"
	desc = "Waffle Co.'s modernized Syndicate revolver. Fires 7 brutal rounds of .357 Magnum. \
		A classic operative weapon, brought to the modern era. Comes with 3 additional speedloaders of .357."
	item = /obj/item/storage/toolbox/guncase/revolver

/datum/uplink_item/weapon_kits/medium_cost/cqc
	name = "CQC Equipment Case (Very Hard)"
	desc = "Contains a manual that instructs you in the ways of CQC, or Close Quarters Combat. Comes with a stealth implant, a pack of smokes and a snazzy bandana (use it with the hat stabilizers in your MODsuit)."
	item = /obj/item/storage/toolbox/guncase/cqc
	purchasable_from = UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS
	surplus = 0
