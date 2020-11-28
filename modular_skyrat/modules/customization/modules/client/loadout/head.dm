/datum/loadout_item/head
	category = LOADOUT_CATEGORY_HEAD

//MISC
/datum/loadout_item/head/baseball
	name = "Colorable ballcap"
	path = /obj/item/clothing/head/soft/mime
	extra_info = LOADOUT_INFO_ONE_COLOR

/datum/loadout_item/head/beanie
	name = "Colorable beanie"
	path = /obj/item/clothing/head/beanie
	extra_info = LOADOUT_INFO_ONE_COLOR

/datum/loadout_item/head/beret_white
	name = "Colorable beret"
	path = /obj/item/clothing/head/beret/white
	extra_info = LOADOUT_INFO_ONE_COLOR

/datum/loadout_item/head/beret
	name = "Black beret"
	path = /obj/item/clothing/head/beret/black

/datum/loadout_item/head/flatcap
	name = "Flat cap"
	path = /obj/item/clothing/head/flatcap

/datum/loadout_item/head/pirate
	name = "Pirate hat"
	path = /obj/item/clothing/head/pirate

/datum/loadout_item/head/rice_hat
	name = "Rice hat"
	path = /obj/item/clothing/head/rice_hat

/datum/loadout_item/head/ushanka
	name = "Ushanka"
	path = /obj/item/clothing/head/ushanka

/datum/loadout_item/head/slime
	name = "Slime hat"
	path = /obj/item/clothing/head/collectable/slime

/datum/loadout_item/head/fedora
	name = "Fedora"
	path = /obj/item/clothing/head/fedora

/datum/loadout_item/head/that
	name = "Top Hat"
	path = /obj/item/clothing/head/that

/datum/loadout_item/head/flakhelm
	name = "Flak Helmet"
	path = /obj/item/clothing/head/flakhelm
	cost = 2

/datum/loadout_item/head/bunnyears
	name = "Bunny Ears"
	path = /obj/item/clothing/head/rabbitears

/datum/loadout_item/head/mailmanhat
	name = "Mailman's Hat"
	path = /obj/item/clothing/head/mailman

/datum/loadout_item/head/whitekepi
	name = "White Kepi"
	path = /obj/item/clothing/head/kepi

/datum/loadout_item/head/whitekepiold
	name = "White Kepi, Old"
	path = /obj/item/clothing/head/kepi/old

/datum/loadout_item/head/maidhead
	name = "Maid Headband"
	path = /obj/item/clothing/head/maid

/datum/loadout_item/head/cardboard
	name = "Cardboard Helmet"
	path = /obj/item/clothing/head/cardborg
	cost = 2

/datum/loadout_item/head/wig
	name = "Wig"
	path = /obj/item/clothing/head/wig
	extra_info = LOADOUT_INFO_ONE_COLOR

/datum/loadout_item/head/wignatural
	name = "Natural Wig"
	path = /obj/item/clothing/head/wig/natural

//Cowboy Stuff
/datum/loadout_item/head/cowboyhat
	name = "Cowboy Hat, Brown"
	path = /obj/item/clothing/head/cowboyhat

/datum/loadout_item/head/cowboyhat/black
	name = "Cowboy Hat, Black"
	path = /obj/item/clothing/head/cowboyhat/black

/datum/loadout_item/head/cowboyhat/white
	name = "Cowboy Hat, White"
	path = /obj/item/clothing/head/cowboyhat/white

/datum/loadout_item/head/cowboyhat/pink
	name = "Cowboy Hat, Pink"
	path = /obj/item/clothing/head/cowboyhat/pink

/*
//trek fancy Hats!
/datum/gear/trekcap
	name = "Federation Officer's Cap (White)"
	category = SLOT_HEAD
	path = /obj/item/clothing/head/caphat/formal/fedcover
	restricted_roles = list("Captain","Head of Personnel")

/datum/gear/trekcapcap
	name = "Federation Officer's Cap (Black)"
	category = SLOT_HEAD
	path = /obj/item/clothing/head/caphat/formal/fedcover/black
	restricted_roles = list("Captain","Head of Personnel")

/datum/gear/trekcapmedisci
	name = "Federation Officer's Cap (Blue)"
	category = SLOT_HEAD
	path = /obj/item/clothing/head/caphat/formal/fedcover/medsci
	restricted_desc = "Medical and Science"
	restricted_roles = list("Chief Medical Officer","Medical Doctor","Chemist","Virologist","Geneticist","Research Director","Scientist", "Roboticist")

/datum/gear/trekcapeng
	name = "Federation Officer's Cap (Yellow)"
	category = SLOT_HEAD
	path = /obj/item/clothing/head/caphat/formal/fedcover/eng
	restricted_desc = "Engineering, Security, and Cargo"
	restricted_roles = list("Chief Engineer","Atmospheric Technician","Station Engineer","Warden","Detective","Security Officer","Head of Security","Cargo Technician", "Shaft Miner", "Quartermaster")

/datum/gear/trekcapsec
	name = "Federation Officer's Cap (Red)"
	category = SLOT_HEAD
	path = /obj/item/clothing/head/caphat/formal/fedcover/sec
	restricted_desc = "Engineering, Security, and Cargo"
	restricted_roles = list("Chief Engineer","Atmospheric Technician","Station Engineer","Warden","Detective","Security Officer","Head of Security","Cargo Technician", "Shaft Miner", "Quartermaster")
*/
/*Commenting out Until next Christmas or made automatic
/datum/gear/santahatr
	name = "Red Santa Hat"
	category = SLOT_HEAD
	path = /obj/item/clothing/head/christmashat
/datum/gear/santahatg
	name = "Green Santa Hat"
	category = SLOT_HEAD
	path = /obj/item/clothing/head/christmashatg
*/

//JOB
/datum/loadout_item/head/job
	subcategory = LOADOUT_SUBCATEGORY_JOB

/datum/loadout_item/head/job/cowboyhat/sec
	name = "Cowboy Hat, Security"
	path = /obj/item/clothing/head/cowboyhat/sec
	restricted_desc = "Security"
	restricted_roles = list("Warden","Detective","Security Officer","Head of Security")

/datum/loadout_item/head/job/navybluehosberet
	name = "Head of security's navyblue beret"
	path = /obj/item/clothing/head/beret/sec/navyhos
	restricted_roles = list("Head of Security")

/datum/loadout_item/head/job/navyblueofficerberet
	name = "Security officer's Navyblue beret"
	path = /obj/item/clothing/head/beret/sec/navyofficer
	restricted_roles = list("Security Officer")

/datum/loadout_item/head/job/navybluewardenberet
	name = "Warden's navyblue beret"
	path = /obj/item/clothing/head/beret/sec/navywarden
	restricted_roles = list("Warden")

/datum/loadout_item/head/job/nursehat
	name = "Nurse Hat"
	path = /obj/item/clothing/head/nursehat
	restricted_roles = list("Medical Doctor", "Chief Medical Officer", "Geneticist", "Chemist", "Virologist")
	restricted_desc = "Medical"
