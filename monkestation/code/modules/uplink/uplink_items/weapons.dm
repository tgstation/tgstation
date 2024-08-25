/datum/uplink_item/implants/hardlight
	name = "Hardlight Spear Implant"
	desc = "An implant that allows you to summon and control a hardlight spear. \
	Adding additional implants to your body will further refine the spear summoning process, allowing you to control up to 5 spears. \
	Wait a minimum of three seconds between injections. Exact mechanism for spear summoning is classified under Aetherofusion NDA."
	item = /obj/item/storage/box/syndie_kit/imp_hard_spear
	cost = 7

/datum/uplink_item/implants/hardlight/max
	name = "Commanding Hardlight Spear Implant"
	desc = "An implant that allows you to summon and control seven hardlight spears. \
	Additional implants will do nothing, you cannot improve on perfection. Side effects may include: Uncontrollable telepathy, formation of subconscious hiveminds, anamnesis, levitation, and hallucinations of music. \
	Aetherofusion is not responsable for any damages this may cause."
	purchasable_from = UPLINK_NUKE_OPS
	item = /obj/item/storage/box/syndie_kit/imp_hard_spear/max
	cost = 40

/datum/uplink_item/dangerous/laser_musket
	name = "Syndicate Laser Musket"
	desc = "An exprimental 'rifle' designed by Aetherofusion. This laser(probably) uses alien technology to fit 4 high energy capacitors \
			into a small rifle which can be stored safely(?) in any backpack. To charge, simply press down on the main control panel. \
			Rumors of this 'siphoning power off your lifeforce' are greatly exaggerated, and Aetherofusion assures safety for up to 2 years of use."
	item = /obj/item/gun/energy/laser/musket/syndicate
	progression_minimum = 30 MINUTES
	cost = 10
	surplus = 40
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/venom_knife
	name = "Poisoned Knife"
	desc = "A knife that is made of two razor sharp blades, it has a secret compartment in the handle to store liquids which are injected when stabbing something. Can hold up to forty units of reagents but comes empty."
	item = /obj/item/knife/venom
	cost = 6 // all in all it's not super stealthy and you have to get some chemicals yourself

/datum/uplink_item/dangerous/renoster
	name = "Renoster Shotgun Case"
	desc = "A twelve gauge shotgun with an eight shell capacity underneath. Comes with two boxes of buckshot."
	item = /obj/item/storage/toolbox/guncase/nova/opfor/renoster
	cost = 10

/datum/uplink_item/dangerous/infanteria
	name = "Carwo-Cawil Battle Rifle Case"
	desc = "A heavy battle rifle, this one seems to be painted tacticool black. Accepts any standard SolFed rifle magazine. Comes with two mags. This will NOT fit in a backpack... "
	progression_minimum = 10 MINUTES
	item = /obj/item/storage/toolbox/guncase/nova/opfor/infanteria
	cost = 12

/datum/uplink_item/dangerous/miecz
	name = "'Miecz' Submachinegun Case"
	desc = "A short barrel, further compacted conversion of the 'Lanca' rifle to fire pistol caliber cartridges. Comes with two magazines."
	progression_minimum = 10 MINUTES
	item = /obj/item/storage/toolbox/guncase/nova/opfor/miecz
	cost = 9

/datum/uplink_item/dangerous/kiboko
	name = "Kiboko Grenade Launcher Case"
	desc = "A unique grenade launcher firing .980 grenades. A laser sight system allows its user to specify a range for the grenades it fires to detonate at. Comes with two C980 Grenade Drums."
	progression_minimum = 10 MINUTES
	item = /obj/item/storage/toolbox/guncase/nova/opfor/kiboko
	cost = 14

/datum/uplink_item/dangerous/sidano
	name = "Sindano SMG"
	desc = "A small submachinegun, this one is painted in tacticool black. Accepts any standard Sol pistol magazine."
	progression_minimum = 10 MINUTES
	item = /obj/item/storage/toolbox/guncase/nova/pistol/opfor/sindano
	cost = 12

/datum/uplink_item/dangerous/wespe
	name = "Wespe Pistol"
	desc = "The standard issue service pistol of SolFed's various military branches. Comes with attached light."
	progression_minimum = 5 MINUTES
	item = /obj/item/storage/toolbox/guncase/nova/pistol/opfor/wespe
	cost = 6

/datum/uplink_item/dangerous/shotgun_revolver
	name = "\improper Bóbr 12 GA revolver"
	desc = "An outdated sidearm rarely seen in use by some members of the CIN. A revolver type design with a four shell cylinder. That's right, shell, this one shoots twelve guage."
	item = /obj/item/storage/box/syndie_kit/shotgun_revolver
	cost = 8

/datum/uplink_item/dangerous/surplus_smg
	name = "Surplus Smg henchmen Bundle"
	desc = "A single surplus Plastikov SMG and two extra magazines. A terrible weapon, perfect for henchmen."
	item = /obj/item/storage/box/syndie_kit/surplus_smg_bundle
	cost = 3
