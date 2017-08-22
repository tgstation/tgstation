
/////////////////////////////////////////
/////////////////Mining//////////////////
/////////////////////////////////////////

/datum/design/drill
	name = "Mining Drill"
	desc = "Yours is the drill that will pierce through the rock walls."
	id = "drill"
	req_tech = list("materials" = 2, "powerstorage" = 2, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000) //expensive, but no need for miners.
	build_path = /obj/item/pickaxe/drill
	category = list("Mining Designs")

/datum/design/drill_diamond
	name = "Diamond-Tipped Mining Drill"
	desc = "Yours is the drill that will pierce the heavens!"
	id = "drill_diamond"
	req_tech = list("materials" = 6, "powerstorage" = 5, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_DIAMOND = 2000) //Yes, a whole diamond is needed.
	build_path = /obj/item/pickaxe/drill/diamonddrill
	category = list("Mining Designs")

/datum/design/plasmacutter
	name = "Plasma Cutter"
	desc = "You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	id = "plasmacutter"
	req_tech = list("materials" = 3, "plasmatech" = 3, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1500, MAT_GLASS = 500, MAT_PLASMA = 400)
	build_path = /obj/item/gun/energy/plasmacutter
	category = list("Mining Designs")

/datum/design/plasmacutter_adv
	name = "Advanced Plasma Cutter"
	desc = "It's an advanced plasma cutter, oh my god."
	id = "plasmacutter_adv"
	req_tech = list("materials" = 4, "plasmatech" = 4, "engineering" = 2, "combat" = 3, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000, MAT_PLASMA = 2000, MAT_GOLD = 500)
	build_path = /obj/item/gun/energy/plasmacutter/adv
	category = list("Mining Designs")

/datum/design/jackhammer
	name = "Sonic Jackhammer"
	desc = "Essentially a handheld planet-cracker. Can drill through walls with ease as well."
	id = "jackhammer"
	req_tech = list("materials" = 7, "powerstorage" = 5, "engineering" = 6, "magnets" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 2000, MAT_SILVER = 2000, MAT_DIAMOND = 6000)
	build_path = /obj/item/pickaxe/drill/jackhammer
	category = list("Mining Designs")

/datum/design/superresonator
	name = "Upgraded Resonator"
	desc = "An upgraded version of the resonator that allows more fields to be active at once."
	id = "superresonator"
	req_tech = list("materials" = 4, "powerstorage" = 3, "engineering" = 3, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1500, MAT_SILVER = 1000, MAT_URANIUM = 1000)
	build_path = /obj/item/resonator/upgraded
	category = list("Mining Designs")

/datum/design/trigger_guard_mod
	name = "Kinetic Accelerator Trigger Guard Mod"
	desc = "A device which allows kinetic accelerators to be wielded by any organism."
	id = "triggermod"
	req_tech = list("materials" = 5, "powerstorage" = 4, "engineering" = 4, "magnets" = 4, "combat" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500, MAT_GOLD = 1500, MAT_URANIUM = 1000)
	build_path = /obj/item/borg/upgrade/modkit/trigger_guard
	category = list("Mining Designs")

/datum/design/damage_mod
	name = "Kinetic Accelerator Damage Mod"
	desc = "A device which allows kinetic accelerators to deal more damage."
	id = "damagemod"
	req_tech = list("materials" = 5, "powerstorage" = 4, "engineering" = 4, "magnets" = 4, "combat" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500, MAT_GOLD = 1500, MAT_URANIUM = 1000)
	build_path = /obj/item/borg/upgrade/modkit/damage
	category = list("Mining Designs", "Cyborg Upgrade Modules")

/datum/design/cooldown_mod
	name = "Kinetic Accelerator Cooldown Mod"
	desc = "A device which decreases the cooldown of a Kinetic Accelerator."
	id = "cooldownmod"
	req_tech = list("materials" = 5, "powerstorage" = 4, "engineering" = 4, "magnets" = 4, "combat" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500, MAT_GOLD = 1500, MAT_URANIUM = 1000)
	build_path = /obj/item/borg/upgrade/modkit/cooldown
	category = list("Mining Designs", "Cyborg Upgrade Modules")

/datum/design/range_mod
	name = "Kinetic Accelerator Range Mod"
	desc = "A device which allows kinetic accelerators to fire at a further range."
	id = "rangemod"
	req_tech = list("materials" = 5, "powerstorage" = 4, "engineering" = 4, "magnets" = 4, "combat" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500, MAT_GOLD = 1500, MAT_URANIUM = 1000)
	build_path = /obj/item/borg/upgrade/modkit/range
	category = list("Mining Designs", "Cyborg Upgrade Modules")

/datum/design/hyperaccelerator
	name = "Kinetic Accelerator Mining AoE Mod"
	desc = "A modification kit for Kinetic Accelerators which causes it to fire AoE blasts that destroy rock."
	id = "hypermod"
	req_tech = list("materials" = 7, "powerstorage" = 5, "engineering" = 5, "magnets" = 5, "combat" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 8000, MAT_GLASS = 1500, MAT_SILVER = 2000, MAT_GOLD = 2000, MAT_DIAMOND = 2000)
	build_path = /obj/item/borg/upgrade/modkit/aoe/turfs
	category = list("Mining Designs", "Cyborg Upgrade Modules")
