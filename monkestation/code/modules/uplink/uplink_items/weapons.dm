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
	cost = 12
	surplus = 40
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/venom_knife
	name = "Poisoned Knife"
	desc = "A knife that is made of two razor sharp blades, it has a secret compartment in the handle to store liquids which are injected when stabbing something. Can hold up to forty units of reagents but comes empty."
	item = /obj/item/knife/venom
	cost = 6 // all in all it's not super stealthy and you have to get some chemicals yourself
