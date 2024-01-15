/datum/armament_entry/company_import/deforest
	category = DEFOREST_MEDICAL_NAME
	company_bitflag = CARGO_COMPANY_DEFOREST

// Basic first aid supplies like gauze, sutures, mesh, so on

/datum/armament_entry/company_import/deforest/first_aid
	subcategory = "First-Aid Consumables"

/datum/armament_entry/company_import/deforest/first_aid/gauze
	item_type = /obj/item/stack/medical/gauze/twelve
	cost = PAYCHECK_LOWER
/datum/armament_entry/company_import/deforest/first_aid/bruise_pack
	item_type = /obj/item/stack/medical/bruise_pack
	cost = PAYCHECK_LOWER

/datum/armament_entry/company_import/deforest/first_aid/ointment
	item_type = /obj/item/stack/medical/ointment
	cost = PAYCHECK_LOWER

/datum/armament_entry/company_import/deforest/first_aid/suture
	item_type = /obj/item/stack/medical/suture
	cost = PAYCHECK_LOWER

/datum/armament_entry/company_import/deforest/first_aid/mesh
	item_type = /obj/item/stack/medical/mesh
	cost = PAYCHECK_LOWER

/datum/armament_entry/company_import/deforest/first_aid/bone_gel
	item_type = /obj/item/stack/medical/bone_gel
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/deforest/first_aid/medicated_sutures
	item_type = /obj/item/stack/medical/suture/medicated
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/deforest/first_aid/advanced_mesh
	item_type = /obj/item/stack/medical/mesh/advanced
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/deforest/medpens
	subcategory = "Autoinjectors"
	cost = PAYCHECK_COMMAND * 1.5

/datum/armament_entry/company_import/deforest/medpens/epipen
	item_type = /obj/item/reagent_containers/hypospray/medipen

/datum/armament_entry/company_import/deforest/medpens/emergency_pen
	item_type = /obj/item/reagent_containers/hypospray/medipen/ekit

/datum/armament_entry/company_import/deforest/medpens/blood_loss
	item_type = /obj/item/reagent_containers/hypospray/medipen/blood_loss

/datum/armament_entry/company_import/deforest/medpens/atropine
	item_type = /obj/item/reagent_containers/hypospray/medipen/atropine

/datum/armament_entry/company_import/deforest/medpens/oxandrolone
	item_type = /obj/item/reagent_containers/hypospray/medipen/oxandrolone

/datum/armament_entry/company_import/deforest/medpens/salacid
	item_type = /obj/item/reagent_containers/hypospray/medipen/salacid

/datum/armament_entry/company_import/deforest/medpens/penacid
	item_type = /obj/item/reagent_containers/hypospray/medipen/penacid

/datum/armament_entry/company_import/deforest/medpens/salbutamol
	item_type = /obj/item/reagent_containers/hypospray/medipen/salbutamol

// Various chemicals, with a box of syringes to come with

/datum/armament_entry/company_import/deforest/medical_chems
	subcategory = "Chemical Supplies"

/datum/armament_entry/company_import/deforest/medical_chems/syringes
	item_type = /obj/item/storage/box/syringes
	cost = PAYCHECK_LOWER

/datum/armament_entry/company_import/deforest/medical_chems/epinephrine
	item_type = /obj/item/reagent_containers/cup/bottle/epinephrine
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/deforest/medical_chems/mannitol
	item_type = /obj/item/reagent_containers/cup/bottle/mannitol
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/deforest/medical_chems/morphine
	item_type = /obj/item/reagent_containers/cup/bottle/morphine
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/deforest/medical_chems/multiver
	item_type = /obj/item/reagent_containers/cup/bottle/multiver
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/deforest/medical_chems/formadehyde
	item_type = /obj/item/reagent_containers/cup/bottle/formaldehyde
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/deforest/medical_chems/potassium_iodide
	item_type = /obj/item/reagent_containers/cup/bottle/potass_iodide
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/deforest/medical_chems/atropine
	item_type = /obj/item/reagent_containers/cup/bottle/atropine
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/deforest/medical_chems/syriniver
	item_type = /obj/item/reagent_containers/cup/bottle/syriniver
	cost = PAYCHECK_CREW

// Equipment, from defibs to scanners to surgical tools

/datum/armament_entry/company_import/deforest/equipment
	subcategory = "Medical Equipment"

/datum/armament_entry/company_import/deforest/equipment/health_analyzer
	item_type = /obj/item/healthanalyzer
	cost = PAYCHECK_LOWER

/datum/armament_entry/company_import/deforest/equipment/loaded_defib
	item_type = /obj/item/defibrillator/loaded
	cost = PAYCHECK_COMMAND

/datum/armament_entry/company_import/deforest/equipment/surgical_tools
	item_type = /obj/item/surgery_tray/full
	cost = PAYCHECK_COMMAND

/datum/armament_entry/company_import/deforest/equipment/advanced_health_analyer
	item_type = /obj/item/healthanalyzer/advanced
	cost = PAYCHECK_COMMAND * 3

/datum/armament_entry/company_import/deforest/equipment/penlite_defib_mount
	item_type = /obj/item/wallframe/defib_mount/charging
	cost = PAYCHECK_CREW * 3

/datum/armament_entry/company_import/deforest/equipment/advanced_scalpel
	item_type = /obj/item/scalpel/advanced
	cost = PAYCHECK_COMMAND * 3

/datum/armament_entry/company_import/deforest/equipment/advanced_retractor
	item_type = /obj/item/retractor/advanced
	cost = PAYCHECK_COMMAND * 3

/datum/armament_entry/company_import/deforest/equipment/advanced_cautery
	item_type = /obj/item/cautery/advanced
	cost = PAYCHECK_COMMAND * 3

/datum/armament_entry/company_import/deforest/equipment/medigun_upgrade
	item_type = /obj/item/device/custom_kit/medigun_fastcharge
	cost = PAYCHECK_COMMAND * 2

/datum/armament_entry/company_import/deforest/equipment/afad
	item_type = /obj/item/gun/medbeam/afad
	cost = PAYCHECK_COMMAND * 5

// Modsuit Modules from the medical category, here instead of in Nakamura because nobody buys from this company

/datum/armament_entry/company_import/deforest/medical_modules
	subcategory = "MOD Medical Modules"
	cost = PAYCHECK_COMMAND * 2

/datum/armament_entry/company_import/deforest/medical_modules/injector
	name = "MOD injector module"
	item_type = /obj/item/mod/module/injector

/datum/armament_entry/company_import/deforest/medical_modules/organ_thrower
	name = "MOD organ thrower module"
	item_type = /obj/item/mod/module/organ_thrower

/datum/armament_entry/company_import/deforest/medical_modules/patient_transport
	name = "MOD patient transport module"
	item_type = /obj/item/mod/module/criminalcapture/patienttransport

/datum/armament_entry/company_import/deforest/medical_modules/thread_ripper
	name = "MOD thread ripper module"
	item_type = /obj/item/mod/module/thread_ripper

/datum/armament_entry/company_import/deforest/medical_modules/surgical_processor
	name = "MOD surgical processor module"
	item_type = /obj/item/mod/module/surgical_processor

// Various advanced cybernetic organs, organ replacements for the rich

/datum/armament_entry/company_import/deforest/cyber_organs
	subcategory = "Premium Cybernetic Organs"
	cost = PAYCHECK_CREW * 3

/datum/armament_entry/company_import/deforest/cyber_organs/eyes
	name = "shielded cybernetic eyes"
	item_type = /obj/item/storage/organbox/advanced_cyber_eyes

/datum/armament_entry/company_import/deforest/cyber_organs/ears
	name = "upgraded cybernetic ears"
	item_type = /obj/item/storage/organbox/advanced_cyber_ears

/datum/armament_entry/company_import/deforest/cyber_organs/heart
	name = "upgraded cybernetic heart"
	item_type = /obj/item/storage/organbox/advanced_cyber_heart

/datum/armament_entry/company_import/deforest/cyber_organs/liver
	name = "upgraded cybernetic liver"
	item_type = /obj/item/storage/organbox/advanced_cyber_liver

/datum/armament_entry/company_import/deforest/cyber_organs/lungs
	name = "upgraded cybernetic lungs"
	item_type = /obj/item/storage/organbox/advanced_cyber_lungs

/datum/armament_entry/company_import/deforest/cyber_organs/stomach
	name = "upgraded cybernetic stomach"
	item_type = /obj/item/storage/organbox/advanced_cyber_stomach

/datum/armament_entry/company_import/deforest/cyber_organs/augments
	cost = PAYCHECK_COMMAND * 2

/datum/armament_entry/company_import/deforest/cyber_organs/augments/nutriment
	name = "Nutriment pump implant"
	item_type = /obj/item/organ/internal/cyberimp/chest/nutriment

/datum/armament_entry/company_import/deforest/cyber_organs/augments/reviver
	name = "Reviver implant"
	item_type = /obj/item/organ/internal/cyberimp/chest/reviver

/datum/armament_entry/company_import/deforest/cyber_organs/augments/surgery_implant
	name = "surgical toolset implant"
	item_type = /obj/item/organ/internal/cyberimp/arm/surgery

/datum/armament_entry/company_import/deforest/cyber_organs/augments/breathing_tube
	name = "breathing tube implant"
	item_type = /obj/item/organ/internal/cyberimp/mouth/breathing_tube
