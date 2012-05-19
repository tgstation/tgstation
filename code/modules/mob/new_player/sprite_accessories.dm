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


/*
////////////////////////////
/  =--------------------=  /
/  == Hair Definitions ==  /
/  =--------------------=  /
////////////////////////////
*/

/datum/sprite_accessory/hair

	icon = 'human_face.dmi'	  // default icon for all hairs

	short
		name = "Short Hair"	  // try to capatilize the names please~
		icon_state = "hair_a" // you do not need to define _s or _l sub-states, game automatically does this for you

	long
		name = "Long Hair"
		icon_state = "hair_b"

	longer
		name = "Longer Hair"
		icon_state = "hair_b2"

	longest
		name = "Longest Hair"
		icon_state = "hair_vlong"

	longalt
		name = "Long Hair Alt"
		icon_state = "hair_longfringe"

	longestalt
		name = "Longest Hair Alt"
		icon_state = "hair_vlongfringe"

	halfbang
		name = "Half-banged Hair"
		icon_state = "hair_halfbang"

	halfbangalt
		name = "Half-banged Hair Alt"
		icon_state = "hair_halfbang_alt"

	kusangi
		name = "Kusanagi Hair"
		icon_state = "hair_kusanagi"

	ponytail1
		name = "Ponytail 1"
		icon_state = "hair_ponytail"

	ponytail2
		name = "Ponytail 2"
		icon_state = "hair_pa"

	ponytail3
		name = "Ponytail 3"
		icon_state = "hair_ponytail3"

	cut
		name = "Cut Hair"
		icon_state = "hair_c"

	mohawk
		name = "Mohawk"
		icon_state = "hair_d"
		choose_female = 0 // gross

	balding
		name = "Balding Hair"
		icon_state = "hair_e"
		choose_female = 0 // turnoff!

	fag
		name = "Flow Hair"
		icon_state = "hair_f"

	bedhead1
		name = "Bedhead 1"
		icon_state = "hair_bedheadold"

	bedhead2
		name = "Bedhead 2"
		icon_state = "hair_bedhead"

	bedhead3
		name = "Bedhead 3"
		icon_state = "hair_bedheadv2"

	bedhead4
		name = "Bedhead 4"
		icon_state = "hair_bedheadalt"

	dreadlocks
		name = "Dreadlocks"
		icon_state = "hair_dreads"
		choose_female = 0 // okay.jpg

	jensen
		name = "Adam Jensen Hair"
		icon_state = "hair_jensen"

	skinhead
		name = "Skinhead"
		icon_state = "hair_skinhead"

	bald
		name = "Bald"
		icon_state = "bald"
		choose_female = 0

	himecut
		name = "Hime Cut"
		icon_state = "hair_himecut"

	curls
		name = "Curls"
		icon_state = "hair_curls"

	spikey
		name = "Spikey"
		icon_state = "hair_spikey"

/*
///////////////////////////////////
/  =---------------------------=  /
/  == Facial Hair Definitions ==  /
/  =---------------------------=  /
///////////////////////////////////
*/

/datum/sprite_accessory/facial_hair

	icon = 'human_face.dmi'
	choose_female = 0 // barf (unless you're a dorf, dorfs dig chix /w beards :P)

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

	shaved

		name = "Shaved"
		icon_state = "bald"
		choose_female = 1 // shaved is the only facial hair on women because why would chicks have beards???






