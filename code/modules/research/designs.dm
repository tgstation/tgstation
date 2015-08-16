/***************************************************************
**						Design Datums						  **
**	All the data for building stuff and tracking reliability. **
***************************************************************/
/*
For the materials datum, it assumes you need reagents unless specified otherwise. To designate a material that isn't a reagent,
you use one of the material IDs below. These are NOT ids in the usual sense (they aren't defined in the object or part of a datum),
they are simply references used as part of a "has materials?" type proc. They all start with a $ to denote that they aren't reagents.
The currently supporting non-reagent materials. All material amounts are set as the define MINERAL_MATERIAL_AMOUNT, which defaults to 2000
- MAT_METAL (/obj/item/stack/metal).
- MAT_GLASS (/obj/item/stack/glass).
- MAT_PLASMA (/obj/item/stack/plasma).
- MAT_SILVER (/obj/item/stack/silver).
- MAT_GOLD (/obj/item/stack/gold).
- MAT_URANIUM (/obj/item/stack/uranium).
- MAT_DIAMOND (/obj/item/stack/diamond).
- MAT_BANANIUM (/obj/item/stack/bananium).
(Insert new ones here)

Don't add new keyword/IDs if they are made from an existing one (such as rods which are made from metal). Only add raw materials.

Design Guidlines
- The reliability formula for all R&D built items is reliability (a fixed number) + total tech levels required to make it +
reliability_mod (starts at 0, gets improved through experimentation). Example: PACMAN generator. 79 base reliablity + 6 tech
(3 plasmatech, 3 powerstorage) + 0 (since it's completely new) = 85% reliability. Reliability is the chance it works CORRECTLY.
- When adding new designs, check rdreadme.dm to see what kind of things have already been made and where new stuff is needed.
- A single sheet of anything is 3750 units of material. Materials besides metal/glass require help from other jobs (mining for
other types of metals and chemistry for reagents).
- Add the AUTOLATHE tag to
*/

/datum/design						//Datum for object designs, used in construction
	var/name = "Name"					//Name of the created object.
	var/desc = "Desc"					//Description of the created object.
	var/id = "id"						//ID of the created object for easy refernece. Alphanumeric, lower-case, no symbols
	var/list/req_tech = list()			//IDs of that techs the object originated from and the minimum level requirements.			//Reliability modifier of the device at it's starting point.
	var/reliability = 100				//Reliability of the device.
	var/build_type = null				//Flag as to what kind machine the design is built in. See defines.
	var/list/materials = list()			//List of materials. Format: "id" = amount.
	var/construction_time				//Amount of time required for building the object
	var/build_path = ""					//The file path of the object that gets created
	var/list/category = null 			//Primarily used for Mech Fabricators, but can be used for anything


//A proc to calculate the reliability of a design based on tech levels and innate modifiers.
//Input: A list of /datum/tech; Output: The new reliabilty.
/datum/design/proc/CalcReliability(list/temp_techs)
	var/new_reliability
	for(var/datum/tech/T in temp_techs)
		if(T.id in req_tech)
			new_reliability += T.level
	new_reliability = Clamp(new_reliability, reliability, 100)
	reliability = new_reliability
	return


////////////////////////////////////////
//Disks for transporting design datums//
////////////////////////////////////////

/obj/item/weapon/disk/design_disk
	name = "Component Design Disk"
	desc = "A disk for storing device design data for construction in lathes."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = 1.0
	materials = list(MAT_METAL=30, MAT_GLASS=10)
	var/datum/design/blueprint

/obj/item/weapon/disk/design_disk/New()
	src.pixel_x = rand(-5.0, 5)
	src.pixel_y = rand(-5.0, 5)

///////////////////////////////////
/////Non-Board Computer Stuff//////
///////////////////////////////////

/datum/design/intellicard
	name = "Intellicard AI Transportation System"
	desc = "Allows for the construction of an intellicard."
	id = "intellicard"
	req_tech = list("programming" = 4, "materials" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 1000, MAT_GOLD = 200)
	build_path = /obj/item/device/aicard
	category = list("Electronics")

/datum/design/paicard
	name = "Personal Artificial Intelligence Card"
	desc = "Allows for the construction of a pAI Card."
	id = "paicard"
	req_tech = list("programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 500, MAT_METAL = 500)
	build_path = /obj/item/device/paicard
	category = list("Electronics")


////////////////////////////////////////
//////////Disk Construction Disks///////
////////////////////////////////////////
/datum/design/design_disk
	name = "Design Storage Disk"
	desc = "Produce additional disks for storing device designs."
	id = "design_disk"
	req_tech = list("programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 10)
	build_path = /obj/item/weapon/disk/design_disk
	category = list("Electronics")

/datum/design/tech_disk
	name = "Technology Data Storage Disk"
	desc = "Produce additional disks for storing technology data."
	id = "tech_disk"
	req_tech = list("programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 10)
	build_path = /obj/item/weapon/disk/tech_disk
	category = list("Electronics")


/////////////////////////////////////////
/////////////////Mining//////////////////
/////////////////////////////////////////

/datum/design/drill
	name = "Mining Drill"
	desc = "Yours is the drill that will pierce through the rock walls."
	id = "drill"
	req_tech = list("materials" = 2, "powerstorage" = 3, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000) //expensive, but no need for miners.
	build_path = /obj/item/weapon/pickaxe/drill
	category = list("Mining Designs")

/datum/design/drill_diamond
	name = "Diamond-Tipped Mining Drill"
	desc = "Yours is the drill that will pierce the heavens!"
	id = "drill_diamond"
	req_tech = list("materials" = 6, "powerstorage" = 4, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_DIAMOND = 3750) //Yes, a whole diamond is needed.
	reliability = 79
	build_path = /obj/item/weapon/pickaxe/drill/diamonddrill
	category = list("Mining Designs")

/datum/design/plasmacutter
	name = "Plasma Cutter"
	desc = "You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	id = "plasmacutter"
	req_tech = list("materials" = 2, "plasmatech" = 2, "engineering" = 2, "combat" = 1, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1500, MAT_GLASS = 500, MAT_PLASMA = 400)
	reliability = 79
	build_path = /obj/item/weapon/gun/energy/plasmacutter
	category = list("Mining Designs")

/datum/design/plasmacutter_adv
	name = "Advanced Plasma Cutter"
	desc = "It's an advanced plasma cutter, oh my god."
	id = "plasmacutter_adv"
	req_tech = list("materials" = 4, "plasmatech" = 3, "engineering" = 3, "combat" = 3, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000, MAT_PLASMA = 2000, MAT_GOLD = 500)
	reliability = 79
	build_path = /obj/item/weapon/gun/energy/plasmacutter/adv
	category = list("Mining Designs")

/datum/design/jackhammer
	name = "Sonic Jackhammer"
	desc = "Essentially a handheld planet-cracker. Can drill through walls with ease as well."
	id = "jackhammer"
	req_tech = list("materials" = 6, "powerstorage" = 6, "engineering" = 5, "magnets" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 8000, MAT_GLASS = 1500, MAT_SILVER = 2000, MAT_DIAMOND = 6000)
	build_path = /obj/item/weapon/pickaxe/drill/jackhammer
	category = list("Mining Designs")

/////////////////////////////////////////
//////////////Blue Space/////////////////
/////////////////////////////////////////

/datum/design/beacon
	name = "Tracking Beacon"
	desc = "A blue space tracking beacon."
	id = "beacon"
	req_tech = list("bluespace" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20, MAT_GLASS = 10)
	build_path = /obj/item/device/radio/beacon
	category = list("Bluespace Designs")

/datum/design/bag_holding
	name = "Bag of Holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	id = "bag_holding"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 3000, MAT_DIAMOND = 1500, MAT_URANIUM = 250)
	reliability = 80
	build_path = /obj/item/weapon/storage/backpack/holding
	category = list("Bluespace Designs")

/datum/design/bluespace_crystal
	name = "Artificial Bluespace Crystal"
	desc = "A small blue crystal with mystical properties."
	id = "bluespace_crystal"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_DIAMOND = 1500, MAT_PLASMA = 1500)
	reliability = 100
	build_path = /obj/item/bluespace_crystal/artificial
	category = list("Bluespace Designs")

/datum/design/telesci_gps
	name = "GPS Device"
	desc = "Little thingie that can track its position at all times."
	id = "telesci_gps"
	req_tech = list("materials" = 2, "magnets" = 3, "bluespace" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 1000)
	build_path = /obj/item/device/gps
	category = list("Bluespace Designs")

/datum/design/miningsatchel_holding
	name = "Mining Satchel of Holding"
	desc = "A mining satchel that can hold an infinite amount of ores."
	id = "minerbag_holding"
	req_tech = list("bluespace" = 3, "materials" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 250, MAT_URANIUM = 500) //quite cheap, for more convenience
	reliability = 100
	build_path = /obj/item/weapon/storage/bag/ore/holding
	category = list("Bluespace Designs")


/////////////////////////////////////////
/////////////////HUDs////////////////////
/////////////////////////////////////////

/datum/design/health_hud
	name = "Health Scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	id = "health_hud"
	req_tech = list("biotech" = 2, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/hud/health
	category = list("Equipment")

/datum/design/health_hud_night
	name = "Night Vision Health Scanner HUD"
	desc = "An advanced medical head-up display that allows doctors to find patients in complete darkness."
	id = "health_hud_night"
	req_tech = list("biotech" = 4, "magnets" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_URANIUM = 1000, MAT_SILVER = 250)
	build_path = /obj/item/clothing/glasses/hud/health/night
	category = list("Equipment")

/datum/design/security_hud
	name = "Security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status."
	id = "security_hud"
	req_tech = list("magnets" = 3, "combat" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/hud/security
	category = list("Equipment")

/datum/design/security_hud_night
	name = "Night Vision Security HUD"
	desc = "A heads-up display which provides id data and vision in complete darkness."
	id = "security_hud_night"
	req_tech = list("magnets" = 5, "combat" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_URANIUM = 1000, MAT_GOLD = 350)
	build_path = /obj/item/clothing/glasses/hud/security/night
	category = list("Equipment")

/////////////////////////////////////////
//////////////////Test///////////////////
/////////////////////////////////////////

	/*	test
			name = "Test Design"
			desc = "A design to test the new protolathe."
			id = "protolathe_test"
			build_type = PROTOLATHE
			req_tech = list("materials" = 1)
			materials = list(MAT_GOLD = 3000, "iron" = 15, "copper" = 10, MAT_SILVER = 2500)
			build_path = /obj/item/weapon/banhammer"
			category = list("Weapons") */

/////////////////////////////////////////
//////////////////Misc///////////////////
/////////////////////////////////////////

/datum/design/welding_mask
	name = "Welding Gas Mask"
	desc = "A gas mask with built in welding goggles and face shield. Looks like a skull, clearly designed by a nerd."
	id = "weldingmask"
	req_tech = list("materials" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1000)
	build_path = /obj/item/clothing/mask/gas/welding
	category = list("Equipment")

/datum/design/air_horn
	name = "Air Horn"
	desc = "Damn son, where'd you find this?"
	id = "air_horn"
	req_tech = list("materials" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_BANANIUM = 1000)
	build_path = /obj/item/weapon/bikehorn/airhorn
	category = list("Equipment")

/datum/design/mesons
	name = "Optical Meson Scanners"
	desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition."
	id = "mesons"
	req_tech = list("materials" = 3, "magnets" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 300)
	build_path = /obj/item/clothing/glasses/meson
	category = list("Equipment")

/datum/design/engine_goggles
	name = "Engineering Scanner Goggles"
	desc = "Goggles used by engineers. The Meson Scanner mode lets you see basic structural and terrain layouts through walls, regardless of lighting condition. The T-ray Scanner mode lets you see underfloor objects such as cables and pipes."
	id = "engine_goggles"
	req_tech = list("materials" = 4, "magnets" = 3, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 300, MAT_PLASMA = 100)
	build_path = /obj/item/clothing/glasses/meson/engine
	category = list("Equipment")

/datum/design/tray_goggles
	name = "Optical T-Ray Scanners"
	desc = "Used by engineering staff to see underfloor objects such as cables and pipes."
	id = "tray_goggles"
	req_tech = list("materials" = 3, "magnets" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 300)
	build_path = /obj/item/clothing/glasses/meson/engine/tray
	category = list("Equipment")

/datum/design/nvgmesons
	name = "Night Vision Optical Meson Scanners"
	desc = "Prototype meson scanners fitted with an extra sensor which amplifies the visible light spectrum and overlays it to the UHD display."
	id = "nvgmesons"
	req_tech = list("materials" = 5, "magnets" = 5, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 400, MAT_PLASMA = 250, MAT_URANIUM = 1000)
	build_path = /obj/item/clothing/glasses/meson/night
	category = list("Equipment")

/datum/design/night_vision_goggles
	name = "Night Vision Goggles"
	desc = "Goggles that let you see through darkness unhindered."
	id = "night_visision_goggles"
	req_tech = list("magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 100, MAT_URANIUM = 1000)
	build_path = /obj/item/clothing/glasses/night
	category = list("Equipment")

/datum/design/magboots
	name = "Magnetic Boots"
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	id = "magboots"
	req_tech = list("materials" = 4, "magnets" = 4, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 1500, MAT_GOLD = 2500)
	build_path = /obj/item/clothing/shoes/magboots
	category = list("Equipment")

/////////////////////////////////////////
////////////Janitor Designs//////////////
/////////////////////////////////////////

/datum/design/buffer
	name = "Floor Buffer Upgrade"
	desc = "A floor buffer that can be attached to vehicular janicarts."
	id = "buffer"
	req_tech = list("materials" = 5, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 200)
	build_path = /obj/item/janiupgrade
	category = list("Equipment")

/datum/design/holosign
	name = "Holographic Sign Projector"
	desc = "A holograpic projector used to project various warning signs."
	id = "holosign"
	req_tech = list("magnets" = 3, "powerstorage" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/holosign_creator
	category = list("Equipment")

/////////////////////////////////////////
////////////Tools//////////////
/////////////////////////////////////////

/datum/design/exwelder
	name = "Experimental Welding Tool"
	desc = "An experimental welder capable of self-fuel generation."
	id = "exwelder"
	req_tech = list("materials" = 4, "engineering" = 4, "bluespace" = 3, "plasmatech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_PLASMA = 1500, MAT_URANIUM = 200)
	build_path = /obj/item/weapon/weldingtool/experimental
	category = list("Equipment")