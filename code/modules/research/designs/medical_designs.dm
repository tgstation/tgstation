/////////////////////////////////////////
////////////Medical Tools////////////////
/////////////////////////////////////////

/datum/design/mass_spectrometer
	name = "Mass-Spectrometer"
	desc = "A device for analyzing chemicals in the blood."
	id = "mass_spectrometer"
	req_tech = list("biotech" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	reliability = 76
	build_path = /obj/item/device/mass_spectrometer
	category = list("Medical Designs")

/datum/design/adv_mass_spectrometer
	name = "Advanced Mass-Spectrometer"
	desc = "A device for analyzing chemicals in the blood and their quantities."
	id = "adv_mass_spectrometer"
	req_tech = list("biotech" = 2, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	reliability = 74
	build_path = /obj/item/device/mass_spectrometer/adv
	category = list("Medical Designs")

/datum/design/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	id = "mmi"
	req_tech = list("programming" = 2, "biotech" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	construction_time = 75
	reliability = 76
	build_path = /obj/item/device/mmi
	category = list("Misc","Medical Designs")

/datum/design/mmi_radio
	name = "Radio-enabled Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity. This one comes with a built-in radio."
	id = "mmi_radio"
	req_tech = list("programming" = 2, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1200, MAT_GLASS = 500)
	construction_time = 75
	reliability = 74
	build_path = /obj/item/device/mmi/radio_enabled
	category = list("Misc","Medical Designs")

/datum/design/posibrain
	name = "Positronic Brain"
	desc = "The latest in Artificial Intelligences."
	id = "mmi_posi"
	req_tech = list("programming" = 5, "biotech" = 4, "materials" = 6, "bluespace" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1700, MAT_GLASS = 1350, MAT_DIAMOND = 1000, MAT_URANIUM = 500)
	reliability = 74
	construction_time = 75
	build_path = /obj/item/device/mmi/posibrain
	category = list("Misc", "Medical Designs")


/datum/design/synthetic_flash
	name = "Flash"
	desc = "When a problem arises, SCIENCE is the solution."
	id = "sflash"
	req_tech = list("magnets" = 3, "combat" = 2)
	build_type = MECHFAB
	materials = list(MAT_METAL = 750, MAT_GLASS = 750)
	construction_time = 100
	reliability = 76
	build_path = /obj/item/device/flash/handheld
	category = list("Misc")

/datum/design/bluespacebeaker
	name = "Bluespace Beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology and Element Cuban combined with the Compound Pete. Can hold up to 300 units."
	id = "bluespacebeaker"
	req_tech = list("bluespace" = 2, "materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_PLASMA = 3000, MAT_DIAMOND = 500)
	reliability = 76
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/bluespace
	category = list("Misc","Medical Designs")

/datum/design/noreactbeaker
	name = "Cryostasis Beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions. Can hold up to 50 units."
	id = "splitbeaker"
	req_tech = list("materials" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000)
	reliability = 76
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/noreact
	category = list("Medical Designs")

/datum/design/bluespacebodybag
	name = "Bluespace body bag"
	desc = "A bluespace body bag, powered by experimental bluespace technology. It can hold loads of bodies and the largest of creatures."
	id = "bluespacebodybag"
	req_tech = list("bluespace" = 2, "materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_PLASMA = 2000, MAT_DIAMOND = 500)
	reliability = 76
	build_path = /obj/item/bodybag/bluespace
	category = list("Medical Designs")


/////////////////////////////////////////
//////////Cybernetic Implants////////////
/////////////////////////////////////////

/datum/design/cyberimp_eyes
	name = "Cybernetic eyes"
	desc = "These cybernetic eyes function as organic eyes do."
	id = "ci-eyes"
	req_tech = list("materials" = 6, "programming" = 4, "biotech" = 4)
	build_type = MECHFAB
	materials = list(MAT_METAL = 200, MAT_GLASS = 200)
	construction_time = 75
	build_path = /obj/item/organ/internal/eyes/cyberimp
	category = list("Misc")

/datum/design/cyberimp_medical_hud
	name = "Medical HUD implant"
	desc = "These cybernetic eyes will display a medical HUD over everything you see. Wiggle eyes to control."
	id = "ci-medhud"
	req_tech = list("materials" = 6, "programming" = 4, "biotech" = 4)
	build_type = MECHFAB
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_SILVER = 200, MAT_GOLD = 100)
	construction_time = 75
	build_path = /obj/item/organ/internal/eyes/cyberimp/hud/medical
	category = list("Misc")

/datum/design/cyberimp_security_hud
	name = "Security HUD implant"
	desc = "These cybernetic eyes will display a security HUD over everything you see. Wiggle eyes to control."
	id = "ci-sechud"
	req_tech = list("materials" = 6, "programming" = 5, "biotech" = 4, "combat" = 2)
	build_type = MECHFAB
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_SILVER = 300, MAT_GOLD = 300)
	construction_time = 75
	build_path = /obj/item/organ/internal/eyes/cyberimp/hud/security
	category = list("Misc")

/datum/design/cyberimp_xray
	name = "X-Ray implant"
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile."
	id = "ci-xray"
	req_tech = list("materials" = 7, "programming" = 5, "biotech" = 4, "magnets" = 5, "plasmatech" = 3)
	build_type = MECHFAB
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_SILVER = 200, MAT_GOLD = 200, MAT_PLASMA = 200, MAT_URANIUM = 500, MAT_DIAMOND = 1000)
	construction_time = 75
	build_path = /obj/item/organ/internal/eyes/cyberimp/xray
	category = list("Misc")

/datum/design/cyberimp_thermals
	name = "Thermals implant"
	desc = "These cybernetic eyes will give you Thermal vision. Vertical slit pupil included."
	id = "ci-thermals"
	req_tech = list("materials" = 7, "programming" = 5, "biotech" = 4, "magnets" = 5, "plasmatech" = 3, "syndicate" = 3)
	build_type = MECHFAB
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_SILVER = 200, MAT_GOLD = 200, MAT_PLASMA = 200, MAT_DIAMOND = 1000)
	construction_time = 75
	build_path = /obj/item/organ/internal/eyes/cyberimp/thermals
	category = list("Misc")

/datum/design/cyberimp_antidrop
	name = "Anti-Drop implant"
	desc = "This cybernetic brain implant will allow you to force your hand muscles to contract, preventing item dropping. Twitch ear to toggle."
	id = "ci-antidrop"
	req_tech = list("materials" = 7, "programming" = 5, "biotech" = 4)
	build_type = MECHFAB
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_SILVER = 400, MAT_GOLD = 400)
	construction_time = 75
	build_path = /obj/item/organ/internal/cyberimp/brain/anti_drop
	category = list("Misc")

/datum/design/cyberimp_antistun
	name = "CNS Rebooter implant"
	desc = "This implant will automatically give you back control over your central nervous system, reducing downtime when stunned."
	id = "ci-antistun"
	req_tech = list("materials" = 7, "programming" = 5, "biotech" = 4)
	build_type = MECHFAB
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_SILVER = 500, MAT_GOLD = 1000)
	construction_time = 75
	build_path = /obj/item/organ/internal/cyberimp/brain/anti_stun
	category = list("Misc")


/datum/design/cyberimp_nutriment
	name = "Nutriment pump implant"
	desc = "This implant with synthesize and pump into your bloodstream a small amount of nutriment when you are starving."
	id = "ci-nutriment"
	req_tech = list("materials" = 6, "programming" = 4, "biotech" = 4)
	build_type = MECHFAB
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_GOLD = 500, MAT_URANIUM = 500)
	construction_time = 75
	build_path = /obj/item/organ/internal/cyberimp/chest/nutriment
	category = list("Misc")

/datum/design/cyberimp_nutriment_plus
	name = "Nutriment pump implant PLUS"
	desc = "This implant with synthesize and pump into your bloodstream a small amount of nutriment when you are hungry."
	id = "ci-nutrimentplus"
	req_tech = list("materials" = 6, "programming" = 4, "biotech" = 4)
	build_type = MECHFAB
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_GOLD = 500, MAT_URANIUM = 750)
	construction_time = 75
	build_path = /obj/item/organ/internal/cyberimp/chest/nutriment/plus
	category = list("Misc")
/*
/datum/design/cyberimp_reviver
	name = "Reviver implant"
	desc = "This implant will automatically deliver a therapeutic dose of electrical energy to your heart if it ever stops beating, and inject you with nanites. A second chance!"
	id = "ci-reviver"
	req_tech = list("materials" = 6, "programming" = 4, "biotech" = 4)
	build_type = MECHFAB
	materials = list(MAT_METAL = 500, MAT_GOLD = 1000, MAT_URANIUM = 1000, MAT_DIAMOND = 2000)
	category = list("Misc")
*/