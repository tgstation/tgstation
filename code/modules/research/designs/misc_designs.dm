
/////////////////////////////////////////
/////////////////HUDs////////////////////
/////////////////////////////////////////

/datum/design/health_hud
	name = "Health Scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	id = "health_hud"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/health
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/health_hud_night
	name = "Night Vision Health Scanner HUD"
	desc = "An advanced medical head-up display that allows doctors to find patients in complete darkness."
	id = "health_hud_night"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_URANIUM = 1000, MAT_SILVER = 350)
	build_path = /obj/item/clothing/glasses/hud/health/night
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/security_hud
	name = "Security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status."
	id = "security_hud"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/security
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/security_hud_night
	name = "Night Vision Security HUD"
	desc = "A heads-up display which provides id data and vision in complete darkness."
	id = "security_hud_night"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_URANIUM = 1000, MAT_GOLD = 350)
	build_path = /obj/item/clothing/glasses/hud/security/night
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/diagnostic_hud
	name = "Diagnostic HUD"
	desc = "A HUD used to analyze and determine faults within robotic machinery."
	id = "diagnostic_hud"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/diagnostic
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/diagnostic_hud_night
	name = "Night Vision Diagnostic HUD"
	desc = "Upgraded version of the diagnostic HUD designed to function during a power failure."
	id = "diagnostic_hud_night"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_URANIUM = 1000, MAT_PLASMA = 300)
	build_path = /obj/item/clothing/glasses/hud/diagnostic/night
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/////////////////////////////////////////
//////////////////Misc///////////////////
/////////////////////////////////////////

/datum/design/welding_mask
	name = "Welding Gas Mask"
	desc = "A gas mask with built in welding goggles and face shield. Looks like a skull, clearly designed by a nerd."
	id = "weldingmask"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000)
	build_path = /obj/item/clothing/mask/gas/welding
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/portaseeder
	name = "Portable Seed Extractor"
	desc = "For the enterprising botanist on the go. Less efficient than the stationary model, it creates one seed per plant."
	id = "portaseeder"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 400)
	build_path = /obj/item/storage/bag/plants/portaseeder
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/air_horn
	name = "Air Horn"
	desc = "Damn son, where'd you find this?"
	id = "air_horn"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_BANANIUM = 1000)
	build_path = /obj/item/bikehorn/airhorn
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ALL			//HONK!

/datum/design/mesons
	name = "Optical Meson Scanners"
	desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition."
	id = "mesons"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/meson
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/engine_goggles
	name = "Engineering Scanner Goggles"
	desc = "Goggles used by engineers. The Meson Scanner mode lets you see basic structural and terrain layouts through walls, regardless of lighting condition. The T-ray Scanner mode lets you see underfloor objects such as cables and pipes."
	id = "engine_goggles"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_PLASMA = 100)
	build_path = /obj/item/clothing/glasses/meson/engine
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/tray_goggles
	name = "Optical T-Ray Scanners"
	desc = "Used by engineering staff to see underfloor objects such as cables and pipes."
	id = "tray_goggles"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/meson/engine/tray
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/nvgmesons
	name = "Night Vision Optical Meson Scanners"
	desc = "Prototype meson scanners fitted with an extra sensor which amplifies the visible light spectrum and overlays it to the UHD display."
	id = "nvgmesons"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_PLASMA = 350, MAT_URANIUM = 1000)
	build_path = /obj/item/clothing/glasses/meson/night
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_CARGO

/datum/design/night_vision_goggles
	name = "Night Vision Goggles"
	desc = "Goggles that let you see through darkness unhindered."
	id = "night_visision_goggles"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_PLASMA = 350, MAT_URANIUM = 1000)
	build_path = /obj/item/clothing/glasses/night
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_SECURITY

/datum/design/magboots
	name = "Magnetic Boots"
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	id = "magboots"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 1500, MAT_GOLD = 2500)
	build_path = /obj/item/clothing/shoes/magboots
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/forcefield_projector
	name = "Forcefield Projector"
	desc = "A device which can project temporary forcefields to seal off an area."
	id = "forcefield_projector"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2500, MAT_GLASS = 1000)
	build_path = /obj/item/forcefield_projector
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/sci_goggles
	name = "Science Goggles"
	desc = "Goggles fitted with a portable analyzer capable of determining the research worth of an item or components of a machine."
	id = "scigoggles"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/science
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/diskplantgene
	name = "Plant Data Disk"
	desc = "A disk for storing plant genetic data."
	id = "diskplantgene"
	build_type = PROTOLATHE
	materials = list(MAT_METAL=200, MAT_GLASS=100)
	build_path = /obj/item/disk/plantgene
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/roastingstick
	name = "Advanced Roasting Stick"
	desc = "A roasting stick for cooking sausages in exotic ovens."
	id = "roastingstick"
	build_type = PROTOLATHE
	materials = list(MAT_METAL=1000, MAT_GLASS=500, MAT_BLUESPACE = 250)
	build_path = /obj/item/melee/roastingstick
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/locator
	name = "Bluespace Locator"
	desc = "Used to track portable teleportation beacons and targets with embedded tracking implants."
	id = "locator"
	build_type = PROTOLATHE
	materials = list(MAT_METAL=1000, MAT_GLASS=500, MAT_SILVER = 500)
	build_path = /obj/item/locator
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	
/datum/design/quantum_keycard
	name = "Quantum Keycard"
	desc = "Allows for the construction of a quantum keycard."
	id = "quantum_keycard"
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 500, MAT_METAL = 500, MAT_SILVER = 500, MAT_BLUESPACE = 1000)
	build_path = /obj/item/quantum_keycard
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/anomaly_neutralizer
	name = "Anomaly Neutralizer"
	desc = "An advanced tool capable of instantly neutralizing anomalies, designed to capture the fleeting aberrations created by the engine."
	id = "anomaly_neutralizer"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GOLD = 2000, MAT_PLASMA = 5000, MAT_URANIUM = 2000)
	build_path = /obj/item/anomaly_neutralizer
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/donksoft_refill
	name = "Donksoft Toy Vendor Refill"
	desc = "A refill canister for Donksoft Toy Vendors."
	id = "donksoft_refill"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 25000, MAT_GLASS = 15000, MAT_PLASMA = 20000, MAT_GOLD = 10000, MAT_SILVER = 10000)
	build_path = /obj/item/vending_refill/donksoft
	category = list("Equipment")

/datum/design/oxygen_tank
	name = "Oxygen Tank"
	desc = "An empty oxygen tank."
	id = "oxygen_tank"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000)
	build_path = /obj/item/tank/internals/oxygen/empty
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/plasma_tank
	name = "Plasma Tank"
	desc = "An empty oxygen tank."
	id = "plasma_tank"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000)
	build_path = /obj/item/tank/internals/plasma/empty
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/////////////////////////////////////////
////////////Janitor Designs//////////////
/////////////////////////////////////////

/datum/design/advmop
	name = "Advanced Mop"
	desc = "An upgraded mop with a large internal capacity for holding water or other cleaning chemicals."
	id = "advmop"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2500, MAT_GLASS = 200)
	build_path = /obj/item/mop/advanced
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/blutrash
	name = "Trashbag of Holding"
	desc = "An advanced trash bag with bluespace properties; capable of holding a plethora of garbage."
	id = "blutrash"
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 1500, MAT_URANIUM = 250, MAT_PLASMA = 1500)
	build_path = /obj/item/storage/bag/trash/bluespace
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/buffer
	name = "Floor Buffer Upgrade"
	desc = "A floor buffer that can be attached to vehicular janicarts."
	id = "buffer"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 200)
	build_path = /obj/item/janiupgrade
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/spraybottle
	name = "Spray Bottle"
	desc = "A spray bottle, with an unscrewable top."
	id = "spraybottle"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 200)
	build_path = /obj/item/reagent_containers/spray
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/beartrap
	name = "Bear Trap"
	desc = "A trap used to catch space bears and other legged creatures."
	id = "beartrap"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_TITANIUM = 1000)
	build_path = /obj/item/restraints/legcuffs/beartrap
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/////////////////////////////////////////
/////////////Holobarriers////////////////
/////////////////////////////////////////

/datum/design/holosign
	name = "Holographic Sign Projector"
	desc = "A holograpic projector used to project various warning signs."
	id = "holosign"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	build_path = /obj/item/holosign_creator
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/holobarrier_jani
	name = "Custodial Holobarrier Projector"
	desc = "A holograpic projector used to project hard light wet floor barriers."
	id = "holobarrier_jani"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000, MAT_SILVER = 1000)
	build_path = /obj/structure/holosign/barrier/wetsign
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE


/datum/design/holosignsec
	name = "Security Holobarrier Projector"
	desc = "A holographic projector that creates holographic security barriers."
	id = "holosignsec"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_GOLD = 1000, MAT_SILVER = 1000)
	build_path = /obj/item/holosign_creator/security
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/holosignengi
	name = "Engineering Holobarrier Projector"
	desc = "A holographic projector that creates holographic engineering barriers."
	id = "holosignengi"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_GOLD = 1000, MAT_SILVER = 1000)
	build_path = /obj/item/holosign_creator/engineering
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/holosignatmos
	name = "ATMOS Holofan Projector"
	desc = "A holographic projector that creates holographic barriers that prevent changes in atmospheric conditions."
	id = "holosignatmos"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_GOLD = 1000, MAT_SILVER = 1000)
	build_path = /obj/item/holosign_creator/atmos
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/holobarrier_med
	name = "PENLITE Holobarrier Projector"
	desc = "PENLITE holobarriers, a device that halts individuals with malicious diseases."
	build_type = PROTOLATHE
	build_path = /obj/item/holosign_creator/medical
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_SILVER = 100) //a hint of silver since it can troll 2 antags (bad viros and sentient disease)
	id = "holobarrier_med"
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/////////////////////////////////////////
////////////////Armour///////////////////
/////////////////////////////////////////

/datum/design/reactive_armour
	name = "Reactive Armour Shell"
	desc = "An experimental suit of armour capable of utilizing an implanted anomaly core to protect the user."
	id = "reactive_armour"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_DIAMOND = 5000, MAT_URANIUM = 8000, MAT_SILVER = 4500, MAT_GOLD = 5000)
	build_path = /obj/item/reactive_armour_shell
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/////////////////////////////////////////
/////////////Security////////////////////
/////////////////////////////////////////

/datum/design/seclite
	name = "Seclite"
	desc = "A robust flashlight used by security."
	id = "seclite"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2500)
	build_path = /obj/item/flashlight/seclite
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/detective_scanner
	name = "Forensic Scanner"
	desc = "Used to remotely scan objects and biomass for DNA and fingerprints. Can print a report of the findings."
	id = "detective_scanner"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_GOLD = 2500, MAT_SILVER = 2000)
	build_path = /obj/item/detective_scanner
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/pepperspray
	name = "Pepper Spray"
	desc = "Manufactured by UhangInc, used to blind and down an opponent quickly. Printed pepper sprays do not contain reagents."
	id = "pepperspray"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000)
	build_path = /obj/item/reagent_containers/spray/pepper/empty
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/bola_energy
	name = "Energy Bola"
	desc = "A specialized hard-light bola designed to ensnare fleeing criminals and aid in arrests."
	id = "bola_energy"
	build_type = PROTOLATHE
	materials = list(MAT_SILVER = 500, MAT_PLASMA = 500, MAT_TITANIUM = 500)
	build_path = /obj/item/restraints/legcuffs/bola/energy
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/zipties
	name = "Zipties"
	desc = "Plastic, disposable zipties that can be used to restrain temporarily but are destroyed after use."
	id = "zipties"
	build_type = PROTOLATHE
	materials = list(MAT_PLASTIC = 250)
	build_path = /obj/item/restraints/handcuffs/cable/zipties
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/evidencebag
	name = "Evidence Bag"
	desc = "An empty evidence bag."
	id = "evidencebag"
	build_type = PROTOLATHE
	materials = list(MAT_PLASTIC = 100)
	build_path = /obj/item/evidencebag
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/c38_trac
	name = "Speed Loader (.38 TRAC)"
	desc = "Designed to quickly reload revolvers. TRAC bullets embed a tracking implant within the target's body."
	id = "c38_trac"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20000, MAT_SILVER = 5000, MAT_GOLD = 1000)
	build_path = /obj/item/ammo_box/c38/trac
	category = list("Security")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/c38_hotshot
	name = "Speed Loader (.38 Hot Shot)"
	desc = "Designed to quickly reload revolvers. Hot Shot bullets contain an incendiary payload."
	id = "c38_hotshot"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 5000)
	build_path = /obj/item/ammo_box/c38/hotshot
	category = list("Security")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/c38_iceblox
	name = "Speed Loader (.38 Iceblox)"
	desc = "Designed to quickly reload revolvers. Iceblox bullets contain a cryogenic payload."
	id = "c38_iceblox"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20000, MAT_PLASMA = 5000)
	build_path = /obj/item/ammo_box/c38/iceblox
	category = list("Security")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
