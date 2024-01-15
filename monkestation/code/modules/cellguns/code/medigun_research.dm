//Tier 2 Medicells//
/datum/design/brute2medicell
	name = "Brute II Medicell"
	desc = "Allows cell loaded Mediguns to use the Brute II functoinality"
	id = "brute2medicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000, /datum/material/plasma = 1000)
	reagents_list = list(/datum/reagent/medicine/c2/libital = 10)
	build_path = /obj/item/weaponcell/medical/brute/better
	category = list(RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/burn2medicell
	name = "Burn II Medicell"
	desc = "Allows cell loaded Mediguns to use the Burn II functoinality"
	id = "burn2medicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000, /datum/material/plasma = 1000)
	reagents_list = list(/datum/reagent/medicine/c2/aiuri = 10)
	build_path = /obj/item/weaponcell/medical/burn/better
	category = list(RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/toxin2medicell
	name = "Toxin II Medicell"
	desc = "Allows cell loaded Mediguns to use the Toxin II functoinality"
	id = "toxin2medicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000, /datum/material/plasma = 1000)
	reagents_list = list(/datum/reagent/medicine/c2/multiver = 10)
	build_path = /obj/item/weaponcell/medical/toxin/better
	category = list(RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/oxy2medicell
	name = "Oxygen II Medicell"
	desc = "Allows cell loaded Mediguns to use the Oxygen II functoinality"
	id = "oxy2medicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000, /datum/material/plasma = 1000)
	reagents_list = list(/datum/reagent/medicine/c2/convermol = 10)
	build_path = /obj/item/weaponcell/medical/oxygen/better
	category = list(RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

//Tier 3 Medicells//
/datum/design/brute3medicell
	name = "Brute III Medicell"
	desc = "Allows cell loaded Mediguns to use the Brute III functoinality"
	id = "brute3medicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000, /datum/material/plasma = 1000, /datum/material/diamond = 500)
	reagents_list = list(/datum/reagent/medicine/sal_acid = 10)
	build_path = /obj/item/weaponcell/medical/brute/better/best
	category = list(RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/burn3medicell
	name = "Burn III Medicell"
	desc = "Allows cell loaded Mediguns to use the Burn III functoinality"
	id = "burn3medicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 3000, /datum/material/glass = 3000, /datum/material/plasma = 1000, /datum/material/diamond = 500)
	reagents_list = list(/datum/reagent/medicine/oxandrolone = 10)
	build_path = /obj/item/weaponcell/medical/burn/better/best
	category = list(RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/toxin3medicell
	name = "Toxin III Medicell"
	desc = "Allows cell loaded Mediguns to use the Toxin III functoinality"
	id = "toxin3medicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 3000, /datum/material/glass = 3000, /datum/material/plasma = 1000, /datum/material/diamond = 500)
	reagents_list = list(/datum/reagent/medicine/pen_acid = 10)
	build_path = /obj/item/weaponcell/medical/toxin/better/best
	category = list(RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/oxy3medicell
	name = "Oxygem III Medicell"
	desc = "Allows cell loaded Mediguns to use the Oxygen III functoinality"
	id = "oxy3medicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000, /datum/material/plasma = 1000, /datum/material/diamond = 500)
	build_path = /obj/item/weaponcell/medical/oxygen/better/best
	reagents_list = list(/datum/reagent/medicine/salbutamol = 10)
	category = list(RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

//Utility Medicells
/datum/design/clotmedicell
	name = "Clotting Medicell"
	desc = "A Medicell designed to help deal with bleeding patients"
	id = "clotmedicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000, /datum/material/plasma = 1000, /datum/material/diamond = 500)
	build_path = /obj/item/weaponcell/medical/utility/clotting
	reagents_list = list(/datum/reagent/medicine/salglu_solution = 5, /datum/reagent/blood = 5)
	category = list(RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/tempmedicell
	name = "Temperature Adjustment Medicell"
	desc = "A Medicell that adjusts the hosts temperature to acceptable levels"
	id = "tempmedicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000, /datum/material/plasma = 1000, /datum/material/diamond = 500)
	build_path = /obj/item/weaponcell/medical/utility/temperature
	reagents_list = list(/datum/reagent/medicine/leporazine = 10)
	category = list(RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/gownmedicell
	name = "Hardlight Gown Medicell"
	desc = "A Medicell that deploys a hardlight hospital gown on a patient."
	id = "gownmedicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000)
	build_path = /obj/item/weaponcell/medical/utility/hardlight_gown
	category = list(RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/bedmedicell
	name = "Hardlight Roller Bed Medicell"
	desc = "A Medicell that deploys a hardlight roller bed under a patient lying down."
	id = "bedmedicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000)
	build_path = /obj/item/weaponcell/medical/utility/bed
	category = list(RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/salvemedicell
	name = "Empty Salve Medicell"
	desc = "A Empty Medicell that can be upgraded by aloe into a usable Salve Medicell."
	id = "salvemedicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000)
	build_path = /obj/item/device/custom_kit/empty_cell
	category = list(RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/bodymedicell
	name = "Empty Body Teleporter Medicell"
	desc = "An empty medicell that can be upgraded by a bluespace slime extract into an usable body teleporter medicell."
	id = "bodymedicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000, /datum/material/plasma = 1000, /datum/material/diamond = 500, /datum/material/bluespace = 2000)
	build_path = /obj/item/device/custom_kit/empty_cell/body_teleporter
	category = list(RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/relocatemedicell
	name = "Oppressive Force Relocation Medicell"
	desc = "A medicell that can be used to teleport non-medical staff to the lobby."
	id = "relocatemedicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000, /datum/material/plasma = 1000, /datum/material/diamond = 500, /datum/material/bluespace = 2000)
	reagents_list = list(/datum/reagent/eigenstate = 10)
	build_path = /obj/item/weaponcell/medical/utility/relocation
	category = list(RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

//Upgrade Kit//
/datum/design/medigunspeedkit
	name = "VeyMedical CWM-479 Upgrade kit"
	desc = "Upgrades the CWM-479 to have a faster charger time and larger cell"
	id = "medigunspeed"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/uranium = 5000, /datum/material/glass = 4000, /datum/material/plasma = 2000, /datum/material/diamond = 500)
	build_path = /obj/item/device/custom_kit/medigun_fastcharge
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_EQUIPMENT_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL
