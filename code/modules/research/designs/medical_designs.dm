/////////////////////////////////////////
////////////Medical Tools////////////////
/////////////////////////////////////////

/datum/design/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	id = "mmi"
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	construction_time = 75
	build_path = /obj/item/mmi
	category = list("Misc","Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/posibrain
	name = "Positronic Brain"
	desc = "The latest in Artificial Intelligences."
	id = "mmi_posi"
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1700, MAT_GLASS = 1350, MAT_GOLD = 500) //Gold, because SWAG.
	construction_time = 75
	build_path = /obj/item/mmi/posibrain
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/bluespacebeaker
	name = "Bluespace Beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology and Element Cuban combined with the Compound Pete. Can hold up to 300 units."
	id = "bluespacebeaker"
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 3000, MAT_PLASMA = 3000, MAT_DIAMOND = 250, MAT_BLUESPACE = 250)
	build_path = /obj/item/reagent_containers/glass/beaker/bluespace
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/noreactbeaker
	name = "Cryostasis Beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions. Can hold up to 50 units."
	id = "splitbeaker"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000)
	build_path = /obj/item/reagent_containers/glass/beaker/noreact
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/xlarge_beaker
	name = "X-large Beaker"
	id = "xlarge_beaker"
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	materials = list(MAT_GLASS = 2500, MAT_PLASTIC = 3000)
	build_path = /obj/item/reagent_containers/glass/beaker/plastic
	category = list("Medical Designs")

/datum/design/meta_beaker
	name = "Metamaterial Beaker"
	id = "meta_beaker"
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	materials = list(MAT_GLASS = 2500, MAT_PLASTIC = 3000, MAT_GOLD = 1000, MAT_TITANIUM = 1000)
	build_path = /obj/item/reagent_containers/glass/beaker/meta
	category = list("Medical Designs")

/datum/design/bluespacesyringe
	name = "Bluespace Syringe"
	desc = "An advanced syringe that can hold 60 units of chemicals"
	id = "bluespacesyringe"
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 2000, MAT_PLASMA = 1000, MAT_DIAMOND = 1000, MAT_BLUESPACE = 500)
	build_path = /obj/item/reagent_containers/syringe/bluespace
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/cloning_disk
	name = "Cloning Data Disk"
	desc = "Produce additional disks for storing genetic data."
	id = "cloning_disk"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 100, MAT_SILVER=50)
	build_path = /obj/item/disk/data
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/noreactsyringe
	name = "Cryo Syringe"
	desc = "An advanced syringe that stops reagents inside from reacting. It can hold up to 20 units."
	id = "noreactsyringe"
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 1000)
	build_path = /obj/item/reagent_containers/syringe/noreact
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/piercesyringe
	name = "Piercing Syringe"
	desc = "A diamond-tipped syringe that pierces armor when launched at high velocity. It can hold up to 10 units."
	id = "piercesyringe"
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 2000, MAT_DIAMOND = 1000)
	build_path = /obj/item/reagent_containers/syringe/piercing
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/bluespacebodybag
	name = "Bluespace Body Bag"
	desc = "A bluespace body bag, powered by experimental bluespace technology. It can hold loads of bodies and the largest of creatures."
	id = "bluespacebodybag"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_PLASMA = 2000, MAT_DIAMOND = 500, MAT_BLUESPACE = 500)
	build_path = /obj/item/bodybag/bluespace
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/plasmarefiller
	name = "Plasma-Man Jumpsuit Refill"
	desc = "A refill pack for the auto-extinguisher on Plasma-man suits."
	id = "plasmarefiller" //Why did this have no plasmatech
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_PLASMA = 1000)
	build_path = /obj/item/extinguisher_refill
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/defibrillator
	name = "Defibrillator"
	id = "defibrillator"
	build_type = PROTOLATHE
	build_path = /obj/item/defibrillator
	materials = list(MAT_METAL = 8000, MAT_GLASS = 4000, MAT_SILVER = 3000, MAT_GOLD = 1500)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/defibrillator_mount
	name = "Defibrillator Wall Mount"
	desc = "An all-in-one mounted frame for holding defibrillators, complete with ID-locked clamps and recharging cables."
	id = "defibmount"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	build_path = /obj/item/wallframe/defib_mount
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/alienscalpel
	name = "Alien Scalpel"
	desc = "An advanced scalpel obtained through Abductor technology."
	id = "alien_scalpel"
	build_path = /obj/item/scalpel/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/alienhemostat
	name = "Alien Hemostat"
	desc = "An advanced hemostat obtained through Abductor technology."
	id = "alien_hemostat"
	build_path = /obj/item/hemostat/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/alienretractor
	name = "Alien Retractor"
	desc = "An advanced retractor obtained through Abductor technology."
	id = "alien_retractor"
	build_path = /obj/item/retractor/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aliensaw
	name = "Alien Circular Saw"
	desc = "An advanced surgical saw obtained through Abductor technology."
	id = "alien_saw"
	build_path = /obj/item/circular_saw/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 1500)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aliendrill
	name = "Alien Drill"
	desc = "An advanced drill obtained through Abductor technology."
	id = "alien_drill"
	build_path = /obj/item/surgicaldrill/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 1500)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aliencautery
	name = "Alien Cautery"
	desc = "An advanced cautery obtained through Abductor technology."
	id = "alien_cautery"
	build_path = /obj/item/cautery/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	
/datum/design/healthanalyzer_advanced
	name = "advanced health analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject with high accuracy."
	id = "healthanalyzer_advanced"
	build_path = /obj/item/healthanalyzer/advanced
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 2500, MAT_SILVER = 2000, MAT_GOLD = 1500)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	
/////////////////////////////////////////
//////////Cybernetic Implants////////////
/////////////////////////////////////////

/datum/design/cyberimp_welding
	name = "Welding Shield Eyes"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	id = "ci-welding"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(MAT_METAL = 600, MAT_GLASS = 400)
	build_path = /obj/item/organ/eyes/robotic/shield
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_gloweyes
	name = "Luminescent Eyes"
	desc = "A pair of cybernetic eyes that can emit multicolored light"
	id = "ci-gloweyes"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(MAT_METAL = 600, MAT_GLASS = 1000)
	build_path = /obj/item/organ/eyes/robotic/glow
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_breather
	name = "Breathing Tube Implant"
	desc = "This simple implant adds an internals connector to your back, allowing you to use internals without a mask and protecting you from being choked."
	id = "ci-breather"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 35
	materials = list(MAT_METAL = 600, MAT_GLASS = 250)
	build_path = /obj/item/organ/cyberimp/mouth/breathing_tube
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_surgical
	name = "Surgical Arm Implant"
	desc = "A set of surgical tools hidden behind a concealed panel on the user's arm."
	id = "ci-surgery"
	build_type = PROTOLATHE | MECHFAB
	materials = list (MAT_METAL = 2500, MAT_GLASS = 1500, MAT_SILVER = 1500)
	construction_time = 200
	build_path = /obj/item/organ/cyberimp/arm/surgery
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_toolset
	name = "Toolset Arm Implant"
	desc = "A stripped-down version of engineering cyborg toolset, designed to be installed on subject's arm."
	id = "ci-toolset"
	build_type = PROTOLATHE | MECHFAB
	materials = list (MAT_METAL = 2500, MAT_GLASS = 1500, MAT_SILVER = 1500)
	construction_time = 200
	build_path = /obj/item/organ/cyberimp/arm/toolset
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_medical_hud
	name = "Medical HUD Implant"
	desc = "These cybernetic eyes will display a medical HUD over everything you see. Wiggle eyes to control."
	id = "ci-medhud"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 500, MAT_GOLD = 500)
	build_path = /obj/item/organ/cyberimp/eyes/hud/medical
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_security_hud
	name = "Security HUD Implant"
	desc = "These cybernetic eyes will display a security HUD over everything you see. Wiggle eyes to control."
	id = "ci-sechud"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 750, MAT_GOLD = 750)
	build_path = /obj/item/organ/cyberimp/eyes/hud/security
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_xray
	name = "X-ray Eyes"
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile."
	id = "ci-xray"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 600, MAT_GOLD = 600, MAT_PLASMA = 1000, MAT_URANIUM = 1000, MAT_DIAMOND = 1000, MAT_BLUESPACE = 1000)
	build_path = /obj/item/organ/eyes/robotic/xray
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_thermals
	name = "Thermal Eyes"
	desc = "These cybernetic eyes will give you Thermal vision. Vertical slit pupil included."
	id = "ci-thermals"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 600, MAT_GOLD = 600, MAT_PLASMA = 1000, MAT_DIAMOND = 2000)
	build_path = /obj/item/organ/eyes/robotic/thermals
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_antidrop
	name = "Anti-Drop Implant"
	desc = "This cybernetic brain implant will allow you to force your hand muscles to contract, preventing item dropping. Twitch ear to toggle."
	id = "ci-antidrop"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 400, MAT_GOLD = 400)
	build_path = /obj/item/organ/cyberimp/brain/anti_drop
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_antistun
	name = "CNS Rebooter Implant"
	desc = "This implant will automatically give you back control over your central nervous system, reducing downtime when stunned."
	id = "ci-antistun"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 500, MAT_GOLD = 1000)
	build_path = /obj/item/organ/cyberimp/brain/anti_stun
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_nutriment
	name = "Nutriment Pump Implant"
	desc = "This implant with synthesize and pump into your bloodstream a small amount of nutriment when you are starving."
	id = "ci-nutriment"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_GOLD = 500)
	build_path = /obj/item/organ/cyberimp/chest/nutriment
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_nutriment_plus
	name = "Nutriment Pump Implant PLUS"
	desc = "This implant with synthesize and pump into your bloodstream a small amount of nutriment when you are hungry."
	id = "ci-nutrimentplus"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_GOLD = 500, MAT_URANIUM = 750)
	build_path = /obj/item/organ/cyberimp/chest/nutriment/plus
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_reviver
	name = "Reviver Implant"
	desc = "This implant will attempt to revive you if you lose consciousness. For the faint of heart!"
	id = "ci-reviver"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 800, MAT_GLASS = 800, MAT_GOLD = 300, MAT_URANIUM = 500)
	build_path = /obj/item/organ/cyberimp/chest/reviver
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_thrusters
	name = "Thrusters Set Implant"
	desc = "This implant will allow you to use gas from environment or your internals for propulsion in zero-gravity areas."
	id = "ci-thrusters"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 80
	materials = list(MAT_METAL = 4000, MAT_GLASS = 2000, MAT_SILVER = 1000, MAT_DIAMOND = 1000)
	build_path = /obj/item/organ/cyberimp/chest/thrusters
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/////////////////////////////////////////
////////////Regular Implants/////////////
/////////////////////////////////////////

/datum/design/implanter
	name = "Implanter"
	desc = "A sterile automatic implant injector."
	id = "implanter"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 200)
	build_path = /obj/item/implanter
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/implantcase
	name = "Implant Case"
	desc = "A glass case for containing an implant."
	id = "implantcase"
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 500)
	build_path = /obj/item/implantcase
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/implant_sadtrombone
	name = "Sad Trombone Implant Case"
	desc = "Makes death amusing."
	id = "implant_trombone"
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 500, MAT_BANANIUM = 500)
	build_path = /obj/item/implantcase/sad_trombone
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ALL		//if you get bananium you get the sad trombones.

/datum/design/implant_chem
	name = "Chemical Implant Case"
	desc = "A glass case containing an implant."
	id = "implant_chem"
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 700)
	build_path = /obj/item/implantcase/chem
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/implant_tracking
	name = "Tracking Implant Case"
	desc = "A glass case containing an implant."
	id = "implant_tracking"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/implantcase/track
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

//Cybernetic organs

/datum/design/cybernetic_liver
	name = "Cybernetic Liver"
	desc = "A cybernetic liver"
	id = "cybernetic_liver"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/organ/liver/cybernetic
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_heart
	name = "Cybernetic Heart"
	desc = "A cybernetic heart"
	id = "cybernetic_heart"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/organ/heart/cybernetic
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_liver_u
	name = "Upgraded Cybernetic Liver"
	desc = "An upgraded cybernetic liver"
	id = "cybernetic_liver_u"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/organ/liver/cybernetic/upgraded
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_lungs
	name = "Cybernetic Lungs"
	desc = "A pair of cybernetic lungs."
	id = "cybernetic_lungs"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/organ/lungs/cybernetic
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_lungs_u
	name = "Upgraded Cybernetic Lungs"
	desc = "A pair of upgraded cybernetic lungs."
	id = "cybernetic_lungs_u"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_SILVER = 500)
	build_path = /obj/item/organ/lungs/cybernetic/upgraded
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/surgery_lobotomy
	name = "Lobotomy Surgery Disk"
	desc = "A disk containing the instructions for a Lobotomy surgery."
	id = "surgery_lobotomy"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 100)
	build_path = /obj/item/disk/surgery/lobotomy
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/surgery_pacify
	name = "Pacification Surgery Disk"
	desc = "A disk containing the instructions for a Pacification surgery."
	id = "surgery_pacify"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 100)
	build_path = /obj/item/disk/surgery/pacification
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/surgery_viral_bonding
	name = "Viral Bonding Surgery Disk"
	desc = "A disk containing the instructions for a Viral Bonding surgery."
	id = "surgery_viral_bond"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 100)
	build_path = /obj/item/disk/surgery/viral_bonding
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/surgery_reconstruction
	name = "Reconstruction Surgery Disk"
	desc = "A disk containing the instructions for a Reconstruction surgery."
	id = "surgery_reconstruction"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 100)
	build_path = /obj/item/disk/surgery/reconstruction
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/surgery_revival
	name = "Revival Surgery Disk"
	desc = "A disk containing the instructions for a Revival surgery."
	id = "surgery_revival"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 100)
	build_path = /obj/item/disk/surgery/revival
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/surgery_brainwashing
	name = "Brainwashing Surgery Disk"
	desc = "A disk containing the instructions for a Brainwashing surgery."
	id = "surgery_brainwashing"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 100)
	build_path = /obj/item/disk/surgery/brainwashing
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/surgery_nerve_splicing
	name = "Nerve Splicing Surgery Disk"
	desc = "A disk containing the instructions for a Nerve Splicing surgery."
	id = "surgery_nerve_splice"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 100)
	build_path = /obj/item/disk/surgery/nerve_splicing
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/surgery_nerve_grounding
	name = "Nerve Grounding Surgery Disk"
	desc = "A disk containing the instructions for a Nerve Grounding surgery."
	id = "surgery_nerve_ground"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 100)
	build_path = /obj/item/disk/surgery/nerve_grounding
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/surgery_vein_threading
	name = "Vein Threading Surgery Disk"
	desc = "A disk containing the instructions for a Vein Threading surgery."
	id = "surgery_vein_thread"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 100)
	build_path = /obj/item/disk/surgery/vein_threading
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/surgery_necrotic_revival
	name = "Necrotic Revival Surgery Disk"
	desc = "A disk containing the instructions for a Necrotic Revival surgery."
	id = "surgery_zombie"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 100)
	build_path = /obj/item/disk/surgery/necrotic_revival
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE
