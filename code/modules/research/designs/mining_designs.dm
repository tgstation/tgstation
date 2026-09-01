
/////////////////////////////////////////
/////////////////Mining//////////////////
/////////////////////////////////////////
/datum/design/cargo_express
	name = "Express Supply Console Board"//shes beautiful
	desc = "Allows for the construction of circuit boards used to build an Express Supply Console."//who?
	build_type = IMPRINTER
	materials = list(/datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/circuitboard/computer/cargo/express
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/bluespace_pod
	name = "Express Supply Drop Pod Upgrade Disk"
	desc = "Allows the Cargo Express Console to call down the Bluespace Drop Pod, greatly increasing user safety."//who?
	build_type = PROTOLATHE
	materials = list(/datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/disk/cargo/bluespace_pod
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/pickaxe
	name = "Pickaxe"
	build_type = PROTOLATHE | AWAY_LATHE | AUTOLATHE
	materials = list(/datum/material/iron =SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/pickaxe
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MINING
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/drill
	name = "Mining Drill"
	desc = "Yours is the drill that will pierce through the rock walls."
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*3, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT) //expensive, but no need for miners.
	build_path = /obj/item/pickaxe/drill
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MINING
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/drill_diamond
	name = "Diamond-Tipped Mining Drill"
	desc = "Yours is the drill that will pierce the heavens!"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT*3,
		/datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond =SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/pickaxe/drill/diamonddrill
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MINING
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/plasmacutter
	name = "Plasma Cutter"
	desc = "You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron =HALF_SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/glass =SMALL_MATERIAL_AMOUNT*5,
		/datum/material/plasma = SMALL_MATERIAL_AMOUNT*4,
	)
	build_path = /obj/item/gun/energy/plasmacutter
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MINING
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/plasmacutter_adv
	name = "Advanced Plasma Cutter"
	desc = "It's an advanced plasma cutter, oh my god."
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron =SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/plasma =SHEET_MATERIAL_AMOUNT,
		/datum/material/gold =SMALL_MATERIAL_AMOUNT*5,
	)
	build_path = /obj/item/gun/energy/plasmacutter/adv
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MINING
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/jackhammer
	name = "Sonic Jackhammer"
	desc = "Essentially a handheld planet-cracker. Rock walls cower in fear when they hear one of these."
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT*3,
		/datum/material/glass =SHEET_MATERIAL_AMOUNT,
		/datum/material/silver =SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond = SHEET_MATERIAL_AMOUNT*3,
	)
	build_path = /obj/item/pickaxe/drill/jackhammer
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MINING
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/superresonator
	name = "Upgraded Resonator"
	desc = "An upgraded version of the resonator that allows more fields to be active at once."
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT*2,
		/datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/silver =HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/uranium =HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/resonator/upgraded
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MINING
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/trigger_guard_mod
	name = "Kinetic Accelerator Trigger Guard Mod"
	desc = "A device which allows kinetic accelerators to be wielded by any organism."
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron =SHEET_MATERIAL_AMOUNT,
		/datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/gold =HALF_SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/uranium =HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/borg/upgrade/modkit/trigger_guard
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_PKA_MODS
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/damage_mod
	name = "Kinetic Accelerator Damage Mod"
	desc = "A device which allows kinetic accelerators to deal more damage."
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron =SHEET_MATERIAL_AMOUNT,
		/datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/gold =HALF_SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/uranium =HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/borg/upgrade/modkit/damage
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_PKA_MODS
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/damage_mod/borg
	build_type = MECHFAB
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_MINING
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/cooldown_mod
	name = "Kinetic Accelerator Cooldown Mod"
	desc = "A device which decreases the cooldown of a Kinetic Accelerator."
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron =SHEET_MATERIAL_AMOUNT, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/gold =HALF_SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/uranium =HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/borg/upgrade/modkit/cooldown
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_PKA_MODS
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/cooldown_mod/borg
	build_type = MECHFAB
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_MINING
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/range_mod
	name = "Kinetic Accelerator Range Mod"
	desc = "A device which allows kinetic accelerators to fire at a further range."
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron =SHEET_MATERIAL_AMOUNT, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/gold =HALF_SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/uranium =HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/borg/upgrade/modkit/range
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_PKA_MODS
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/range_mod/borg
	build_type = MECHFAB
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_MINING
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/hyperaccelerator
	name = "Kinetic Accelerator Mining AoE Mod"
	desc = "A modification kit for Kinetic Accelerators which causes it to fire AoE blasts that destroy rock."
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT*4,
		/datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/silver =SHEET_MATERIAL_AMOUNT,
		/datum/material/gold =SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond =SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/borg/upgrade/modkit/cooldown/aoe/turfs
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_PKA_MODS
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/hyperaccelerator/borg
	build_type = MECHFAB
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_MINING
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mining_scanner
	name = "Mining Scanner"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/glass =SMALL_MATERIAL_AMOUNT*5,
		/datum/material/iron =SMALL_MATERIAL_AMOUNT*5,
		/datum/material/silver =HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/t_scanner/adv_mining_scanner/lesser
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MINING
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/unique_modkit
	abstract_type = /datum/design/unique_modkit
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_PKA_MODS,
	)
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/unique_modkit/offensive_turf_aoe
	name = "Kinetic Accelerator Offensive Mining Explosion Mod"
	desc = "A device which causes kinetic accelerators to fire AoE blasts that destroy rock and damage creatures."
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*3.5, /datum/material/glass = SHEET_MATERIAL_AMOUNT*1.5, /datum/material/silver =SHEET_MATERIAL_AMOUNT*1.5, /datum/material/gold =SHEET_MATERIAL_AMOUNT*1.5, /datum/material/diamond = SHEET_MATERIAL_AMOUNT*2)
	build_path = /obj/item/borg/upgrade/modkit/cooldown/aoe/mobs/andturfs

/datum/design/unique_modkit/rapid_repeater
	name = "Kinetic Accelerator Rapid Repeater Mod"
	desc = "A device which greatly reduces a kinetic accelerator's cooldown on striking a living target or rock, but greatly increases its base cooldown."
	materials = list(/datum/material/iron =HALF_SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass =SHEET_MATERIAL_AMOUNT * 2.5, /datum/material/uranium = SHEET_MATERIAL_AMOUNT*4, /datum/material/bluespace =SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/borg/upgrade/modkit/cooldown/repeater

/datum/design/unique_modkit/resonator_blast
	name = "Kinetic Accelerator Resonator Blast Mod"
	desc = "A device which causes kinetic accelerators to fire shots that leave and detonate resonator blasts."
	materials = list(/datum/material/iron =HALF_SHEET_MATERIAL_AMOUNT*5, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT*5, /datum/material/silver =HALF_SHEET_MATERIAL_AMOUNT*5, /datum/material/uranium =SHEET_MATERIAL_AMOUNT * 2.5)
	build_path = /obj/item/borg/upgrade/modkit/resonator_blasts

/datum/design/unique_modkit/bounty
	name = "Kinetic Accelerator Death Syphon Mod"
	desc = "A device which causes kinetic accelerators to permanently gain damage against creature types killed with it."
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*2, /datum/material/silver = SHEET_MATERIAL_AMOUNT*2, /datum/material/gold = SHEET_MATERIAL_AMOUNT*2, /datum/material/bluespace = SHEET_MATERIAL_AMOUNT*2)
	build_path = /obj/item/borg/upgrade/modkit/bounty
