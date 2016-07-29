/datum/design/bruise_pack
	name = "Roll of gauze"
	desc = "Some sterile gauze to wrap around bloody stumps."
	id = "bruise_pack"
	req_tech = list("biotech" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 400, MAT_GLASS = 125)
	category = "Medical"
	build_path = /obj/item/stack/medical/bruise_pack

/datum/design/ointment
	name = "Ointment"
	desc = "Used to treat those nasty burns."
	id = "ointment"
	req_tech = list("biotech" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 400, MAT_GLASS = 125)
	category = "Medical"
	build_path = /obj/item/stack/medical/ointment

/datum/design/adv_bruise_pack
	name = "Advanced trauma kit"
	desc = "Used to treat those nasty burns."
	id = "adv_bruise_pack"
	req_tech = list("biotech" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 600, MAT_GLASS = 250)
	category = "Medical"
	build_path = /obj/item/stack/medical/advanced/bruise_pack

/datum/design/adv_ointment
	name = "Advanced burn kit"
	desc = "Used to treat those nasty burns."
	id = "adv_ointment"
	req_tech = list("biotech" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 600, MAT_GLASS = 250)
	category = "Medical"
	build_path = /obj/item/stack/medical/advanced/ointment

/datum/design/mass_spectrometer
	name = "Mass-Spectrometer"
	desc = "A device for analyzing chemicals in the blood."
	id = "mass_spectrometer"
	req_tech = list("biotech" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 30, MAT_GLASS = 20)
	reliability_base = 76
	category = "Medical"
	build_path = /obj/item/device/mass_spectrometer

/datum/design/adv_mass_spectrometer
	name = "Advanced Mass-Spectrometer"
	desc = "A device for analyzing chemicals in the blood and their quantities."
	id = "adv_mass_spectrometer"
	req_tech = list("biotech" = 2, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 30, MAT_GLASS = 20)
	reliability_base = 74
	category = "Medical"
	build_path = /obj/item/device/mass_spectrometer/adv

/datum/design/defibrillator
	name = "Defibrillator"
	desc = "A handheld emergency defibrillator, used to bring people back from the brink of death or put them there."
	id = "defibrillator"
	req_tech = list("magnets" = 3, "materials" = 4, "biotech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 9000, MAT_SILVER = 250, MAT_GLASS = 10000)
	category = "Medical"
	build_path = /obj/item/weapon/melee/defibrillator

/datum/design/healthanalyzer
	name = "Health Analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	id = "healthanalyzer"
	req_tech = list("magnets" = 2, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 1000, MAT_GLASS = 1000)
	category = "Medical"
	build_path = /obj/item/device/healthanalyzer

/datum/design/laserscalpel1
	name = "Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, allowing for bloodless incisions and built-in cautery."
	id = "laserscalpel1"
	req_tech = list("materials" = 3, "engineering" = 2, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 10000, MAT_GLASS = 5000)
	category = "Medical"
	build_path = /obj/item/weapon/scalpel/laser/tier1

/datum/design/laserscalpel2
	name = "High Precision Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, allowing for bloodless incisions and built-in cautery."
	id = "laserscalpel2"
	req_tech = list("materials" = 4, "engineering" = 3, "biotech" = 4)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 10000, MAT_GLASS = 5000, MAT_URANIUM = 500)
	category = "Medical"
	build_path = /obj/item/weapon/scalpel/laser/tier2

/datum/design/incisionmanager
	name = "Surgical Incision Manager"
	desc = "A true extension of the surgeon's body, this marvel instantly cuts the organ, clamp any bleeding, and retract the skin, allowing for the immediate commencement of therapeutic steps."
	id = "incisionmanager"
	req_tech = list("materials" = 5, "engineering" = 4, "biotech" = 5)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 10000, MAT_GLASS = 5000, MAT_URANIUM = 250, MAT_SILVER = 500)
	category = "Medical"
	build_path = /obj/item/weapon/retractor/manager

/datum/design/health_hud
	name = "Health Scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	id = "health_hud"
	req_tech = list("biotech" = 2, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 50, MAT_GLASS = 50)
	category = "Medical"
	build_path = /obj/item/clothing/glasses/hud/health

/datum/design/chemmask
	name = "Chemical Mask"
	desc = "A rather sinister mask designed for connection to a chemical pack, providing the pack's safeties are disabled."
	id = "chemmask"
	req_tech = list("biotech" = 5, "materials" = 5, "engineering" = 5, "combat" = 5, "syndicate" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 500, MAT_SILVER = 100)
	category = "Medical"
	build_path = /obj/item/clothing/mask/chemmask

/datum/design/antibody_scanner
	name = "Antibody Scanner"
	desc = "Used to scan living beings for antibodies in their blood."
	id = "antibody_scanner"
	req_tech = list("magnets" = 2, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 1000, MAT_GLASS = 1000)
	category = "Medical"
	build_path = /obj/item/device/antibody_scanner

/datum/design/switchtool
	name = "Surgeon's Switchtool"
	desc = "A switchtool containing most of the necessary items for impromptu surgery. For the surgeon on the go."
	id = "switchtool"
	req_tech = list("materials" = 5, "bluespace" = 3, "biotech" = 3)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 10000, MAT_GLASS = 5000)
	category = "Medical"
	build_path = /obj/item/weapon/switchtool/surgery
