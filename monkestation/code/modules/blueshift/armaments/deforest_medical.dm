/datum/armament_entry/company_import/deforest
	category = DEFOREST_MEDICAL_NAME
	company_bitflag = CARGO_COMPANY_DEFOREST

// Precompiled first aid kits, ready to go if you don't want to bother getting individual items

/datum/armament_entry/company_import/deforest/first_aid_kit
	subcategory = "First-Aid Kits"

/datum/armament_entry/deforest/first_aid_kit/civil_defense/comfort
	item_type = /obj/item/storage/medkit/civil_defense/comfort/stocked
	cost = PAYCHECK_COMMAND * 2

/datum/armament_entry/company_import/deforest/first_aid_kit/civil_defense
	item_type = /obj/item/storage/medkit/civil_defense/stocked
	cost = PAYCHECK_COMMAND * 2.5

/datum/armament_entry/company_import/deforest/first_aid_kit/frontier
	item_type = /obj/item/storage/medkit/frontier/stocked
	cost = PAYCHECK_COMMAND * 3.5

/datum/armament_entry/company_import/deforest/first_aid_kit/combat_surgeon
	item_type = /obj/item/storage/medkit/combat_surgeon/stocked
	cost = PAYCHECK_COMMAND * 3.5

/datum/armament_entry/company_import/deforest/first_aid_kit/robo_repair
	item_type = /obj/item/storage/medkit/robotic_repair/stocked
	cost = PAYCHECK_COMMAND * 3.5

/datum/armament_entry/company_import/deforest/first_aid_kit/robo_repair_super
	item_type = /obj/item/storage/medkit/robotic_repair/preemo/stocked
	cost = PAYCHECK_COMMAND * 8

/datum/armament_entry/company_import/deforest/first_aid_kit/first_responder
	item_type = /obj/item/storage/backpack/duffelbag/deforest_surgical/stocked
	cost = PAYCHECK_COMMAND * 10

/datum/armament_entry/company_import/deforest/first_aid_kit/orange_satchel
	item_type = /obj/item/storage/backpack/duffelbag/deforest_medkit/stocked
	cost = PAYCHECK_COMMAND * 10

// Basic first aid supplies like gauze, sutures, mesh, so on

/datum/armament_entry/company_import/deforest/first_aid
	subcategory = "First-Aid Consumables"

/datum/armament_entry/company_import/deforest/first_aid/coagulant
	item_type = /obj/item/stack/medical/suture/coagulant
	cost = PAYCHECK_LOWER

/datum/armament_entry/company_import/deforest/first_aid/suture
	item_type = /obj/item/stack/medical/suture
	cost = PAYCHECK_LOWER

/datum/armament_entry/company_import/deforest/first_aid/red_sun
	item_type = /obj/item/stack/medical/ointment/red_sun
	cost = PAYCHECK_LOWER

/datum/armament_entry/company_import/deforest/first_aid/ointment
	item_type = /obj/item/stack/medical/ointment
	cost = PAYCHECK_LOWER

/datum/armament_entry/company_import/deforest/first_aid/mesh
	item_type = /obj/item/stack/medical/mesh
	cost = PAYCHECK_LOWER

/datum/armament_entry/company_import/deforest/first_aid/sterile_gauze
	item_type = /obj/item/stack/medical/gauze/sterilized
	cost = PAYCHECK_LOWER

/datum/armament_entry/company_import/deforest/first_aid/amollin
	item_type = /obj/item/storage/pill_bottle/painkiller
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/deforest/first_aid/robo_patch
	item_type = /obj/item/reagent_containers/pill/robotic_patch/synth_repair
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/deforest/first_aid/subdermal_splint
	item_type = /obj/item/stack/medical/wound_recovery
	cost = PAYCHECK_COMMAND * 2

/datum/armament_entry/company_import/deforest/first_aid/rapid_coagulant
	item_type = /obj/item/stack/medical/wound_recovery/rapid_coagulant
	cost = PAYCHECK_COMMAND * 2

// Autoinjectors for healing

/datum/armament_entry/company_import/deforest/medpens
	subcategory = "Medical Autoinjectors"
	cost = PAYCHECK_LOWER * 3

/datum/armament_entry/company_import/deforest/medpens/occuisate
	item_type = /obj/item/reagent_containers/hypospray/medipen/deforest/occuisate

/datum/armament_entry/company_import/deforest/medpens/morpital
	item_type = /obj/item/reagent_containers/hypospray/medipen/deforest/morpital

/datum/armament_entry/company_import/deforest/medpens/lipital
	item_type = /obj/item/reagent_containers/hypospray/medipen/deforest/lipital

/datum/armament_entry/company_import/deforest/medpens/meridine
	item_type = /obj/item/reagent_containers/hypospray/medipen/deforest/meridine

/datum/armament_entry/company_import/deforest/medpens/calopine
	item_type = /obj/item/reagent_containers/hypospray/medipen/deforest/calopine

/datum/armament_entry/company_import/deforest/medpens/coagulants
	item_type = /obj/item/reagent_containers/hypospray/medipen/deforest/coagulants

/datum/armament_entry/company_import/deforest/medpens/lepoturi
	item_type = /obj/item/reagent_containers/hypospray/medipen/deforest/lepoturi

/datum/armament_entry/company_import/deforest/medpens/psifinil
	item_type = /obj/item/reagent_containers/hypospray/medipen/deforest/psifinil

/datum/armament_entry/company_import/deforest/medpens/halobinin
	item_type = /obj/item/reagent_containers/hypospray/medipen/deforest/halobinin

/datum/armament_entry/company_import/deforest/medpens/robo_solder
	item_type = /obj/item/reagent_containers/hypospray/medipen/deforest/robot_liquid_solder

/datum/armament_entry/company_import/deforest/medpens/robo_cleaner
	item_type = /obj/item/reagent_containers/hypospray/medipen/deforest/robot_system_cleaner

/datum/armament_entry/company_import/deforest/medpens/pentibinin
	item_type = /obj/item/reagent_containers/hypospray/medipen/deforest/pentibinin
	contraband = TRUE

// Autoinjectors for fighting

/datum/armament_entry/company_import/deforest/medpens_stim
	subcategory = "Stimulant Autoinjectors"
	cost = PAYCHECK_COMMAND * 2

/datum/armament_entry/company_import/deforest/medpens_stim/adrenaline
	item_type = /obj/item/reagent_containers/hypospray/medipen/deforest/adrenaline

/datum/armament_entry/company_import/deforest/medpens_stim/synephrine
	item_type = /obj/item/reagent_containers/hypospray/medipen/deforest/synephrine

/datum/armament_entry/company_import/deforest/medpens_stim/krotozine
	item_type = /obj/item/reagent_containers/hypospray/medipen/deforest/krotozine

/datum/armament_entry/company_import/deforest/medpens_stim/aranepaine
	item_type = /obj/item/reagent_containers/hypospray/medipen/deforest/aranepaine
	contraband = TRUE

/datum/armament_entry/company_import/deforest/medpens_stim/synalvipitol
	item_type = /obj/item/reagent_containers/hypospray/medipen/deforest/synalvipitol
	contraband = TRUE

/datum/armament_entry/company_import/deforest/medpens_stim/twitch
	item_type = /obj/item/reagent_containers/hypospray/medipen/deforest/twitch
	cost = PAYCHECK_COMMAND * 3
	contraband = TRUE

/datum/armament_entry/company_import/deforest/medpens_stim/demoneye
	item_type = /obj/item/reagent_containers/hypospray/medipen/deforest/demoneye
	cost = PAYCHECK_COMMAND * 3
	contraband = TRUE

// Equipment, from defibs to scanners to surgical tools

/datum/armament_entry/company_import/deforest/equipment
	subcategory = "Medical Equipment"

/datum/armament_entry/company_import/deforest/equipment/treatment_zone_projector
	item_type = /obj/item/holosign_creator/medical/treatment_zone
	cost = PAYCHECK_LOWER

/datum/armament_entry/company_import/deforest/equipment/health_analyzer
	item_type = /obj/item/healthanalyzer
	cost = PAYCHECK_LOWER

/datum/armament_entry/company_import/deforest/equipment/loaded_defib
	item_type = /obj/item/defibrillator/loaded
	cost = PAYCHECK_COMMAND

/datum/armament_entry/company_import/deforest/equipment/surgical_tools
	item_type = /obj/item/surgery_tray
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


/datum/armament_entry/company_import/deforest/equipment/medstation
	item_type = /obj/item/wallframe/frontier_medstation
	cost = PAYCHECK_COMMAND * 5

// Advanced implants, some of these can be printed but this is a way to get them before tech if you REALLY wanted

/datum/armament_entry/company_import/deforest/cyber_implants
	subcategory = "Cybernetic Implants"
	cost = PAYCHECK_COMMAND * 3

/datum/armament_entry/company_import/deforest/cyber_implants/razorwire
	name = "Razorwire Spool Implant"
	item_type = /obj/item/organ/internal/cyberimp/arm/item_set/razorwire
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
