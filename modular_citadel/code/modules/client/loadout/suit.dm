/datum/gear/poncho
	name = "Poncho"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/poncho

/datum/gear/ponchogreen
	name = "Green poncho"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/poncho/green

/datum/gear/ponchored
	name = "Red poncho"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/poncho/red

/datum/gear/redhood
	name = "Red cloak"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/cloak/david
	cost = 3

/datum/gear/jacketbomber
	name = "Bomber jacket"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/jacket

/datum/gear/jacketleather
	name = "Leather jacket"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/jacket/leather

/datum/gear/overcoatleather
	name = "Leather overcoat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/jacket/leather/overcoat

/datum/gear/jacketpuffer
	name = "Puffer jacket"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/jacket/puffer

/datum/gear/vestpuffer
	name = "Puffer vest"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/jacket/puffer/vest

/datum/gear/jacketlettermanbrown
	name = "Brown letterman jacket"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/jacket/letterman

/datum/gear/jacketlettermanred
	name = "Red letterman jacket"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/jacket/letterman_red

/datum/gear/jacketlettermanNT
	name = "Nanotrasen letterman jacket"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/jacket/letterman_nanotrasen

/datum/gear/coat
	name = "Winter coat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/wintercoat

/datum/gear/militaryjacket
	name = "Military Jacket"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/jacket/miljacket

/datum/gear/ianshirt
	name = "Ian Shirt"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/ianshirt

/datum/gear/flakjack
	name = "Flak Jacket"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/flakjack
	cost = 2

/datum/gear/trekds9_coat
	name = "DS9 Overcoat (use uniform)"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/storage/trek/ds9
	restricted_roles = list("Head of Security","Captain","Head of Personnel","Chief Engineer","Research Director","Chief Medical Officer","Quartermaster",
							"Medical Doctor","Chemist","Virologist","Geneticist","Scientist", "Roboticist",
							"Atmospheric Technician","Station Engineer","Warden","Detective","Security Officer",
							"Cargo Technician", "Shaft Miner") //everyone who actually deserves a job.
//Federation jackets from movies
/datum/gear/trekcmdcap
	name = "fed (movie) uniform, Captain"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/storage/fluff/fedcoat/capt
	restricted_roles = list("Captain","Head of Personnel")

/datum/gear/trekcmdmov
	name = "fed (movie) uniform, sec"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/storage/fluff/fedcoat
	restricted_roles = list("Head of Security","Captain","Head of Personnel","Chief Engineer","Research Director","Chief Medical Officer","Quartermaster","Warden","Detective","Security Officer")

/datum/gear/trekmedscimov
	name = "fed (movie) uniform, med/sci"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/storage/fluff/fedcoat/medsci
	restricted_roles = list("Chief Medical Officer","Medical Doctor","Chemist","Virologist","Geneticist","Research Director","Scientist", "Roboticist")

/datum/gear/trekengmov
	name = "fed (movie) uniform, ops/eng"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/storage/fluff/fedcoat/eng
	restricted_roles = list("Chief Engineer","Atmospheric Technician","Station Engineer","Cargo Technician", "Shaft Miner", "Quartermaster")
