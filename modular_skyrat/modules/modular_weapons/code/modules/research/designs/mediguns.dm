//Tier 2 Medicells//
/datum/design/brute2medicell
	name = "Brute II Medicell"
	desc = "Allows cell loaded Mediguns to use the Brute II functoinality"
	id = "brute2medicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000, /datum/material/plasma = 1000)
	reagents_list = list(/datum/reagent/medicine/c2/libital = 10)
	build_path = /obj/item/weaponcell/medical/brute/better
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/burn2medicell
	name = "Burn II Medicell"
	desc = "Allows cell loaded Mediguns to use the Burn II functoinality"
	id = "burn2medicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000, /datum/material/plasma = 1000)
	reagents_list = list(/datum/reagent/medicine/c2/aiuri = 10)
	build_path = /obj/item/weaponcell/medical/burn/better
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/toxin2medicell
	name = "Toxin II Medicell"
	desc = "Allows cell loaded Mediguns to use the Toxin II functoinality"
	id = "toxin2medicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000, /datum/material/plasma = 1000)
	reagents_list = list(/datum/reagent/medicine/c2/multiver = 10)
	build_path = /obj/item/weaponcell/medical/toxin/better
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/oxy2medicell
	name = "Oxygen II Medicell"
	desc = "Allows cell loaded Mediguns to use the Oxygen II functoinality"
	id = "oxy2medicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000, /datum/material/plasma = 1000)
	reagents_list = list(/datum/reagent/medicine/c2/convermol = 10)
	build_path = /obj/item/weaponcell/medical/oxygen/better
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

//Tier 3 Medicells//
/datum/design/brute3medicell
	name = "Brute III Medicell"
	desc = "Allows cell loaded Mediguns to use the Brute III functoinality"
	id = "brute3medicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000, /datum/material/plasma = 1000, /datum/material/diamond = 500)
	reagents_list = list(/datum/reagent/medicine/sal_acid = 10)
	build_path = /obj/item/weaponcell/medical/brute/better/best
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/burn3medicell
	name = "Burn III Medicell"
	desc = "Allows cell loaded Mediguns to use the Burn III functoinality"
	id = "burn3medicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 3000, /datum/material/glass = 3000, /datum/material/plasma = 1000, /datum/material/diamond = 500)
	reagents_list = list(/datum/reagent/medicine/oxandrolone = 10)
	build_path = /obj/item/weaponcell/medical/burn/better/best
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/toxin3medicell
	name = "Toxin III Medicell"
	desc = "Allows cell loaded Mediguns to use the Toxin III functoinality"
	id = "toxin3medicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 3000, /datum/material/glass = 3000, /datum/material/plasma = 1000, /datum/material/diamond = 500)
	reagents_list = list(/datum/reagent/medicine/pen_acid = 10)
	build_path = /obj/item/weaponcell/medical/toxin/better/best
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/oxy3medicell
	name = "Oxygem III Medicell"
	desc = "Allows cell loaded Mediguns to use the Oxygen III functoinality"
	id = "oxy3medicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000, /datum/material/plasma = 1000, /datum/material/diamond = 500)
	build_path = /obj/item/weaponcell/medical/oxygen/better/best
	reagents_list = list(/datum/reagent/medicine/salbutamol = 10)
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

//Utility Medicells
/datum/design/clotmedicell
	name = "Clotting Medicell"
	desc = "A Medicell designed to help deal with bleeding patients"
	id = "clotmedicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000, /datum/material/plasma = 1000, /datum/material/diamond = 500)
	build_path = /obj/item/weaponcell/medical/utility/clotting
	reagents_list = list(/datum/reagent/medicine/salglu_solution = 5, /datum/reagent/blood = 5)
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/tempmedicell
	name = "Temperature Adjustment Medicell"
	desc = "A Medicell that adjusts the hosts temperature to acceptable levels"
	id = "tempmedicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000, /datum/material/plasma = 1000, /datum/material/diamond = 500)
	build_path = /obj/item/weaponcell/medical/utility/temperature
	reagents_list = list(/datum/reagent/medicine/leporazine = 10)
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/gownmedicell
	name = "Hardlight Gown Medicell"
	desc = "A Medicell that deploys a hardlight hospital gown on a patient."
	id = "gownmedicell"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plastic = 2000, /datum/material/glass = 2000)
	build_path = /obj/item/weaponcell/medical/utility/hardlight_gown
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

//Upgrade Kit//
/datum/design/medigunspeedkit
	name = "VeyMedical CWM-479 Upgrade kit"
	desc = "Upgrades the CWM-479 to have a faster charger time and larger cell"
	id = "medigunspeed"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/uranium = 5000, /datum/material/glass = 4000, /datum/material/plasma = 2000, /datum/material/diamond = 500)
	build_path = /obj/item/device/custom_kit/medigun_fastcharge
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
