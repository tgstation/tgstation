/*

	Hello and welcome to sprite_accessories: For sprite accessories, such as hair,
	facial hair, and possibly tattoos and stuff somewhere along the line. This file is
	intended to be friendly for people with little to no actual coding experience.
	The process of adding in new hairstyles has been made pain-free and easy to do.
	Enjoy! - Doohl


	Notice: This all gets automatically compiled in a list in dna.dm, so you do not
	have to define any UI values for sprite accessories manually for hair and facial
	hair. Just add in new hair types and the game will naturally adapt.

	!!WARNING!!: changing existing hair information can be VERY hazardous to savefiles,
	to the point where you may completely corrupt a server's savefiles. Please refrain
	from doing this unless you absolutely know what you are doing, and have defined a
	conversion in savefile.dm
*/

/datum/sprite_accessory

	var/icon			// the icon file the accessory is located in
	var/icon_state		// the icon_state of the accessory
	var/preview_state	// a custom preview state for whatever reason

	var/name			// the preview name of the accessory

	// Determines if the accessory will be skipped or included in random hair generations
	var/choose_female = 1
	var/choose_male = 1

	// Restrict some styles to specific races
	var/list/species_allowed = list("Human")


/*
////////////////////////////
/  =--------------------=  /
/  == Hair Definitions ==  /
/  =--------------------=  /
////////////////////////////
*/

/datum/sprite_accessory/hair

	icon = 'icons/mob/Human_face.dmi'	  // default icon for all hairs

	bald
		name = "Bald"
		icon_state = "bald"
		choose_female = 0
		species_allowed = list("Human","Soghun")

	short
		name = "Short Hair"	  // try to capatilize the names please~
		icon_state = "hair_a" // you do not need to define _s or _l sub-states, game automatically does this for you

	cut
		name = "Cut Hair"
		icon_state = "hair_c"

	long
		name = "Shoulder-length Hair"
		icon_state = "hair_b"

	longer
		name = "Long Hair"
		icon_state = "hair_vlong"

	longest
		name = "Very Long Hair"
		icon_state = "hair_longest"

	longfringe
		name = "Long Fringe"
		icon_state = "hair_longfringe"

	longestalt
		name = "Longer Fringe"
		icon_state = "hair_vlongfringe"

	halfbang
		name = "Half-banged Hair"
		icon_state = "hair_halfbang"

	halfbangalt
		name = "Half-banged Hair Alt"
		icon_state = "hair_halfbang_alt"

	ponytail1
		name = "Ponytail 1"
		icon_state = "hair_ponytail"

	ponytail2
		name = "Ponytail 2"
		icon_state = "hair_pa"
		choose_male = 0

	ponytail3
		name = "Ponytail 3"
		icon_state = "hair_ponytail3"

	bedhead
		name = "Bedhead"
		icon_state = "hair_bedhead"

	bedhead2
		name = "Bedhead 2"
		icon_state = "hair_bedheadv2"

	bedhead3
		name = "Bedhead 3"
		icon_state = "hair_bedheadv3"

	dreadlocks
		name = "Dreadlocks"
		icon_state = "hair_dreads"
		choose_female = 0 // okay.jpg

	curls
		name = "Curls"
		icon_state = "hair_curls"

	afro
		name = "Afro"
		icon_state = "hair_afro"

	afro_large
		name = "Big Afro"
		icon_state = "hair_bigafro"
		choose_female = 0

	sargeant
		name = "Flat Top"
		icon_state = "hair_sargeant"
		choose_female = 0

	fag
		name = "Flow Hair"
		icon_state = "hair_f"

	mohawk
		name = "Mohawk"
		icon_state = "hair_d"
		species_allowed = list("Human","Soghun")

	jensen
		name = "Adam Jensen Hair"
		icon_state = "hair_jensen"
		choose_female = 0

	gelled
		name = "Gelled Back"
		icon_state = "hair_gelled"
		choose_male = 0

	spiky
		name = "Spiky"
		icon_state = "hair_spikey"
		species_allowed = list("Human","Soghun")

	kusangi
		name = "Kusanagi Hair"
		icon_state = "hair_kusanagi"

	kagami
		name = "Pigtails"
		icon_state = "hair_kagami"
		choose_male = 0

	himecut
		name = "Hime Cut"
		icon_state = "hair_himecut"
		choose_male = 0

	braid
		name = "Floorlength Braid"
		icon_state = "hair_braid"
		choose_male = 0

	skinhead
		name = "Skinhead"
		icon_state = "hair_skinhead"

	balding
		name = "Balding Hair"
		icon_state = "hair_e"
		choose_female = 0 // turnoff!

/*
///////////////////////////////////
/  =---------------------------=  /
/  == Facial Hair Definitions ==  /
/  =---------------------------=  /
///////////////////////////////////
*/

/datum/sprite_accessory/facial_hair

	icon = 'icons/mob/Human_face.dmi'
	choose_female = 0 // barf (unless you're a dorf, dorfs dig chix /w beards :P)

	shaved
		name = "Shaved"
		icon_state = "bald"
		choose_female = 1 // shaved is the only facial hair on women because why would chicks have beards???
		species_allowed = list("Human","Soghun","Tajaran","Skrell")

	watson
		name = "Watson Mustache"
		icon_state = "facial_watson"

	hogan
		name = "Hulk Hogan Mustache"
		icon_state = "facial_hogan" //-Neek

	vandyke
		name = "Van Dyke Mustache"
		icon_state = "facial_vandyke"

	chaplin
		name = "Square Mustache"
		icon_state = "facial_chaplin"

	selleck
		name = "Selleck Mustache"
		icon_state = "facial_selleck"

	neckbeard
		name = "Neckbeard"
		icon_state = "facial_neckbeard"

	fullbeard
		name = "Full Beard"
		icon_state = "facial_fullbeard"

	longbeard
		name = "Long Beard"
		icon_state = "facial_longbeard"

	vlongbeard
		name = "Very Long Beard"
		icon_state = "facial_wise"

	elvis
		name = "Elvis Sideburns"
		icon_state = "facial_elvis"

	abe
		name = "Abraham Lincoln Beard"
		icon_state = "facial_abe"

	chinstrap
		name = "Chinstrap"
		icon_state = "facial_chin"

	hip
		name = "Hipster Beard"
		icon_state = "facial_hip"

	gt
		name = "Goatee"
		icon_state = "facial_gt"

	jensen
		name = "Adam Jensen Beard"
		icon_state = "facial_jensen"

	dwarf
		name = "Dwarf Beard"
		icon_state = "facial_dwarf"

/*
///////////////////////////////////
/  =---------------------------=  /
/  == Alien Style Definitions ==  /
/  =---------------------------=  /
///////////////////////////////////
*/

/datum/sprite_accessory/hair
	tentacle_m
		name = "Skrell Male Tentacles"
		icon_state = "skrell_hair_m"
		species_allowed = list("Skrell")
		choose_female = 0

	tentacle_f
		name = "Skrell Female Tentacles"
		icon_state = "skrell_hair_f"
		species_allowed = list("Skrell")
		choose_male = 0

	gold_m
		name = "Gold plated Skrell Male Tentacles"
		icon_state = "skrell_goldhair_m"
		species_allowed = list("Skrell")
		choose_female = 0

	gold_f
		name = "Gold chained Skrell Female Tentacles"
		icon_state = "skrell_goldhair_f"
		species_allowed = list("Skrell")
		choose_male = 0

	clothtentacle_m
		name = "Cloth draped Skrell Male Tentacles"
		icon_state = "skrell_clothhair_m"
		species_allowed = list("Skrell")
		choose_female = 0

	clothtentacle_f
		name = "Cloth draped Skrell Female Tentacles"
		icon_state = "skrell_clothhair_f"
		species_allowed = list("Skrell")
		choose_male = 0

	taj_ears
		name = "Tajaran Ears"
		icon_state = "tajears"
		species_allowed = list("Tajaran")
