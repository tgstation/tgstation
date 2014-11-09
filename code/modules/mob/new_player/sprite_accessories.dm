/*

	Hello and welcome to sprite_accessories: For sprite accessories, such as hair,
	facial hair, and possibly tattoos and stuff somewhere along the line. This file is
	intended to be friendly for people with little to no actual coding experience.
	The process of adding in new hairstyles has been made pain-free and easy to do.
	Enjoy! - Doohl


	Notice: This all gets automatically compiled in a list in dna2.dm, so you do not
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
	var/gender = NEUTER

	// Restrict some styles to specific species
	var/list/species_allowed = list("Human")

	// Whether or not the accessory can be affected by colouration
	var/do_colouration = 1

	var/flags = 0


/*
////////////////////////////
/  =--------------------=  /
/  == Hair Definitions ==  /
/  =--------------------=  /
////////////////////////////
*/

/datum/sprite_accessory/hair

	icon = 'icons/mob/human_face.dmi'	  // default icon for all hairs

	bald
		name = "Bald"
		icon_state = "bald"
		gender = MALE
		species_allowed = list("Human","Unathi","Grey","Plasmaman","Skellington")

	short
		name = "Short Hair"	  // try to capatilize the names please~
		icon_state = "hair_a" // you do not need to define _s or _l sub-states, game automatically does this for you

	cut
		name = "Cut Hair"
		icon_state = "hair_c"

	long
		name = "Shoulder-length Hair"
		icon_state = "hair_b"

	longalt
		name = "Shoulder-length Hair Alt"
		icon_state = "hair_longfringe"

	/*longish
		name = "Longer Hair"
		icon_state = "hair_b2"*/

	longer
		name = "Long Hair"
		icon_state = "hair_vlong"

	longeralt
		name = "Long Hair Alt"
		icon_state = "hair_vlongfringe"

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
		gender = FEMALE

	ponytail3
		name = "Ponytail 3"
		icon_state = "hair_ponytail3"

	parted
		name = "Parted"
		icon_state = "hair_parted"

	pompadour
		name = "Pompadour"
		icon_state = "hair_pompadour"
		gender = MALE
		species_allowed = list("Human","Unathi")

	quiff
		name = "Quiff"
		icon_state = "hair_quiff"
		gender = MALE

	bedhead
		name = "Bedhead"
		icon_state = "hair_bedhead"

	bedhead2
		name = "Bedhead 2"
		icon_state = "hair_bedheadv2"

	bedhead3
		name = "Bedhead 3"
		icon_state = "hair_bedheadv3"

	beehive
		name = "Beehive"
		icon_state = "hair_beehive"
		gender = FEMALE
		species_allowed = list("Human","Unathi")

	bobcurl
		name = "Bobcurl"
		icon_state = "hair_bobcurl"
		gender = FEMALE
		species_allowed = list("Human","Unathi")

	bob
		name = "Bob"
		icon_state = "hair_bobcut"
		gender = FEMALE
		species_allowed = list("Human","Unathi")

	bowl
		name = "Bowl"
		icon_state = "hair_bowlcut"
		gender = MALE

	buzz
		name = "Buzzcut"
		icon_state = "hair_buzzcut"
		gender = MALE
		species_allowed = list("Human","Unathi")

	crew
		name = "Crewcut"
		icon_state = "hair_crewcut"
		gender = MALE

	combover
		name = "Combover"
		icon_state = "hair_combover"
		gender = MALE

	devillock
		name = "Devil Lock"
		icon_state = "hair_devilock"

	dreadlocks
		name = "Dreadlocks"
		icon_state = "hair_dreads"

	curls
		name = "Curls"
		icon_state = "hair_curls"

	afro
		name = "Afro"
		icon_state = "hair_afro"

	afro2
		name = "Afro 2"
		icon_state = "hair_afro2"

	afro_large
		name = "Big Afro"
		icon_state = "hair_bigafro"
		gender = MALE

	sargeant
		name = "Flat Top"
		icon_state = "hair_sargeant"
		gender = MALE

	emo
		name = "Emo"
		icon_state = "hair_emo"

	fag
		name = "Flow Hair"
		icon_state = "hair_f"

	feather
		name = "Feather"
		icon_state = "hair_feather"

	hitop
		name = "Hitop"
		icon_state = "hair_hitop"
		gender = MALE

	jensen
		name = "Adam Jensen Hair"
		icon_state = "hair_jensen"
		gender = MALE

	gelled
		name = "Gelled Back"
		icon_state = "hair_gelled"
		gender = FEMALE

	spiky
		name = "Spiky"
		icon_state = "hair_spikey"
		species_allowed = list("Human","Unathi")
	kusangi
		name = "Kusanagi Hair"
		icon_state = "hair_kusanagi"

	kagami
		name = "Pigtails"
		icon_state = "hair_kagami"
		gender = FEMALE

	himecut
		name = "Hime Cut"
		icon_state = "hair_himecut"
		gender = FEMALE

	braid
		name = "Floorlength Braid"
		icon_state = "hair_braid"
		gender = FEMALE
		flags = HAIRSTYLE_CANTRIP

	odango
		name = "Odango"
		icon_state = "hair_odango"
		gender = FEMALE

	ombre
		name = "Ombre"
		icon_state = "hair_ombre"
		gender = FEMALE

	updo
		name = "Updo"
		icon_state = "hair_updo"
		gender = FEMALE

	skinhead
		name = "Skinhead"
		icon_state = "hair_skinhead"

	balding
		name = "Balding Hair"
		icon_state = "hair_e"
		gender = MALE // turnoff!

	familyman
		name = "The Family Man"
		icon_state = "hair_thefamilyman"
		gender = MALE

	mahdrills
		name = "Drillruru"
		icon_state = "hair_drillruru"
		gender = FEMALE

	dandypomp
		name = "Dandy Pompadour"
		icon_state = "hair_dandypompadour"
		gender = MALE

	poofy
		name = "Poofy"
		icon_state = "hair_poofy"
		gender = FEMALE

	crono
		name = "Toriyama"
		icon_state = "hair_toriyama"
		gender = MALE

	vegeta
		name = "Toriyama 2"
		icon_state = "hair_toriyama2"
		gender = MALE

	cia
		name = "CIA"
		icon_state = "hair_cia"
		gender = MALE

	mulder
		name = "Mulder"
		icon_state = "hair_mulder"
		gender = MALE

	scully
		name = "Scully"
		icon_state = "hair_scully"
		gender = FEMALE

	nitori
		name = "Nitori"
		icon_state = "hair_nitori"
		gender = FEMALE

	joestar
		name = "Joestar"
		icon_state = "hair_joestar"
		gender = MALE

	metal
		name = "Metal"
		icon_state = "hair_80s"

	edgeworth
		name = "Edgeworth"
		icon_state = "hair_edgeworth"
		gender = MALE

	objection
		name = "Objection!"
		icon_state = "hair_objection"
		gender = MALE

	dubs
		name = "Check 'Em"
		icon_state = "hair_dubs"
		gender = MALE

	swordsman
		name = "Black Swordsman"
		icon_state = "hair_blackswordsman"
		gender = MALE

	mentalist
		name = "Mentalist"
		icon_state = "hair_mentalist"
		gender = MALE

	fujisaki
		name = "Fujisaki"
		icon_state = "hair_fujisaki"
		gender = FEMALE

	schierke
		name = "Schierke"
		icon_state = "hair_schierke"
		gender = FEMALE

	akari
		name = "Akari"
		icon_state = "hair_akari"
		gender = FEMALE

	fujiyabashi
		name = "Fujuyabashi"
		icon_state = "hair_fujiyabashi"
		gender = FEMALE

	nia
		name = "Nia"
		icon_state = "hair_nia"
		gender = FEMALE

	shinobu
		name = "Shinobu"
		icon_state = "hair_shinobu"
		gender = FEMALE

	bald
		name = "Bald"
		icon_state = "bald"
/*
///////////////////////////////////
/  =---------------------------=  /
/  == Facial Hair Definitions ==  /
/  =---------------------------=  /
///////////////////////////////////
*/

/datum/sprite_accessory/facial_hair

	icon = 'icons/mob/human_face.dmi'
	gender = MALE // barf (unless you're a dorf, dorfs dig chix /w beards :P)

	shaved
		name = "Shaved"
		icon_state = "bald"
		gender = NEUTER
		species_allowed = list("Human","Unathi","Tajaran","Skrell","Vox","Grey","Plasmaman","Skellington")

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
		species_allowed = list("Human","Unathi")

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

	// Before Goon gets all hot and bothered for "stealing":
	// A. It's property of SEGA in the first place
	// B. I sprited this by hand, despite Steve's pleas to the contrary.  I've never played on your server and probably never will.
	// - Nexypoo
	robotnik
		name = "Robotnik Mustache"
		icon_state = "facial_robotnik"

/*
///////////////////////////////////
/  =---------------------------=  /
/  == Alien Style Definitions ==  /
/  =---------------------------=  /
///////////////////////////////////
*/

/datum/sprite_accessory/hair
	una_spines_long
		name = "Long Unathi Spines"
		icon_state = "soghun_longspines"
		species_allowed = list("Unathi")
		do_colouration = 0

	una_spines_short
		name = "Short Unathi Spines"
		icon_state = "soghun_shortspines"
		species_allowed = list("Unathi")
		do_colouration = 0

	una_frills_long
		name = "Long Unathi Frills"
		icon_state = "soghun_longfrills"
		species_allowed = list("Unathi")
		do_colouration = 0

	una_frills_short
		name = "Short Unathi Frills"
		icon_state = "soghun_shortfrill"
		species_allowed = list("Unathi")
		do_colouration = 0

	una_horns
		name = "Unathi Horns"
		icon_state = "soghun_horns"
		species_allowed = list("Unathi")
		do_colouration = 0

	skr_tentacle_m
		name = "Skrell Male Tentacles"
		icon_state = "skrell_hair_m"
		species_allowed = list("Skrell")
		gender = MALE
		do_colouration = 0

	skr_tentacle_f
		name = "Skrell Female Tentacles"
		icon_state = "skrell_hair_f"
		species_allowed = list("Skrell")
		gender = FEMALE
		do_colouration = 0

	skr_gold_m
		name = "Gold plated Skrell Male Tentacles"
		icon_state = "skrell_goldhair_m"
		species_allowed = list("Skrell")
		gender = MALE
		do_colouration = 0

	skr_gold_f
		name = "Gold chained Skrell Female Tentacles"
		icon_state = "skrell_goldhair_f"
		species_allowed = list("Skrell")
		gender = FEMALE
		do_colouration = 0

	skr_clothtentacle_m
		name = "Cloth draped Skrell Male Tentacles"
		icon_state = "skrell_clothhair_m"
		species_allowed = list("Skrell")
		gender = MALE
		do_colouration = 0

	skr_clothtentacle_f
		name = "Cloth draped Skrell Female Tentacles"
		icon_state = "skrell_clothhair_f"
		species_allowed = list("Skrell")
		gender = FEMALE
		do_colouration = 0

	taj_ears
		name = "Tajaran Ears"
		icon_state = "ears_plain"
		species_allowed = list("Tajaran")
		do_colouration = 0

	taj_ears_clean
		name = "Tajara Clean"
		icon_state = "hair_clean"
		species_allowed = list("Tajaran")
		do_colouration = 0

	taj_ears_shaggy
		name = "Tajara Shaggy"
		icon_state = "hair_shaggy"
		species_allowed = list("Tajaran")
		do_colouration = 0

	taj_ears_mohawk
		name = "Tajaran Mohawk"
		icon_state = "hair_mohawk"
		species_allowed = list("Tajaran")
		do_colouration = 0

	taj_ears_plait
		name = "Tajara Plait"
		icon_state = "hair_plait"
		species_allowed = list("Tajaran")
		do_colouration = 0

	taj_ears_straight
		name = "Tajara Straight"
		icon_state = "hair_straight"
		species_allowed = list("Tajaran")
		do_colouration = 0

	taj_ears_long
		name = "Tajara Long"
		icon_state = "hair_long"
		species_allowed = list("Tajaran")
		do_colouration = 0

	taj_ears_rattail
		name = "Tajara Rat Tail"
		icon_state = "hair_rattail"
		species_allowed = list("Tajaran")
		do_colouration = 0

	taj_ears_spiky
		name = "Tajara Spiky"
		icon_state = "hair_tajspiky"
		species_allowed = list("Tajaran")
		do_colouration = 0

	taj_ears_messy
		name = "Tajara Messy"
		icon_state = "hair_messy"
		species_allowed = list("Tajaran")
		do_colouration = 0

	vox_quills_short
		name = "Short Vox Quills"
		icon_state = "vox_shortquills"
		species_allowed = list("Vox")
		do_colouration = 0

	vox_quills_kingly
		name = "Kingly"
		icon_state = "vox_kingly"
		species_allowed = list("Vox")
		do_colouration = 0

	vox_quills_afro
		name = "Afro"
		icon_state = "vox_afro"
		species_allowed = list("Vox")
		do_colouration = 0

	vox_quills_mohawk
		name = "Mohawk"
		icon_state = "vox_mohawk"
		species_allowed = list("Vox")
		do_colouration = 0

	vox_quills_yasu
		name = "Yasuhiro"
		icon_state = "vox_yasu"
		species_allowed = list("Vox")
		do_colouration = 0

	vox_quills_horns
		name = "Quorns"
		icon_state = "vox_horns"
		species_allowed = list("Vox")
		do_colouration = 0

	vox_quills_nights
		name = "Nights"
		icon_state = "vox_nights"
		species_allowed = list("Vox")
		do_colouration = 0

/datum/sprite_accessory/facial_hair

	taj_sideburns
		name = "Tajara Sideburns"
		icon_state = "facial_mutton"
		species_allowed = list("Tajaran")
		do_colouration = 0

	taj_mutton
		name = "Tajara Mutton"
		icon_state = "facial_mutton"
		species_allowed = list("Tajaran")
		do_colouration = 0

	taj_pencilstache
		name = "Tajara Pencilstache"
		icon_state = "facial_pencilstache"
		species_allowed = list("Tajaran")
		do_colouration = 0

	taj_moustache
		name = "Tajara Moustache"
		icon_state = "facial_moustache"
		species_allowed = list("Tajaran")
		do_colouration = 0

	taj_goatee
		name = "Tajara Goatee"
		icon_state = "facial_goatee"
		species_allowed = list("Tajaran")
		do_colouration = 0

	taj_smallstache
		name = "Tajara Smallsatche"
		icon_state = "facial_smallstache"
		species_allowed = list("Tajaran")
		do_colouration = 0

	vox_face_colonel
		name = "Colonel"
		icon_state = "vox_colonel"
		species_allowed = list("Vox")
		do_colouration = 0

	vox_face_fu
		name = "Fu"
		icon_state = "vox_fu"
		species_allowed = list("Vox")
		do_colouration = 0

	vox_face_neck
		name = "Neck Quills"
		icon_state = "vox_neck"
		species_allowed = list("Vox")
		do_colouration = 0

	vox_face_beard
		name = "Quill Beard"
		icon_state = "vox_beard"
		species_allowed = list("Vox")
		do_colouration = 0

//skin styles - WIP
//going to have to re-integrate this with surgery
//let the icon_state hold an icon preview for now
/datum/sprite_accessory/skin
	icon = 'icons/mob/human_races/r_human.dmi'

	human
		name = "Default human skin"
		icon_state = "default"
		species_allowed = list("Human")

	human_tatt01
		name = "Tatt01 human skin"
		icon_state = "tatt1"
		species_allowed = list("Human")

	tajaran
		name = "Default tajaran skin"
		icon_state = "default"
		icon = 'icons/mob/human_races/r_tajaran.dmi'
		species_allowed = list("Tajaran")

	unathi
		name = "Default Unathi skin"
		icon_state = "default"
		icon = 'icons/mob/human_races/r_lizard.dmi'
		species_allowed = list("Unathi")

	skrell
		name = "Default skrell skin"
		icon_state = "default"
		icon = 'icons/mob/human_races/r_skrell.dmi'
		species_allowed = list("Skrell")

/datum/sprite_accessory/hair/mohawk
	name = "Mohawk"
	icon_state = "mohawk"