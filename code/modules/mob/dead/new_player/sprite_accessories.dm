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
/proc/init_sprite_accessory_subtypes(prototype, list/L, list/male, list/female,var/roundstart = FALSE)//Roundstart argument builds a specific list for roundstart parts where some parts may be locked
	if(!istype(L))
		L = list()
	if(!istype(male))
		male = list()
	if(!istype(female))
		female = list()

	for(var/path in typesof(prototype))
		if(path == prototype)
			continue
		if(roundstart)
			var/datum/sprite_accessory/P = path
			if(initial(P.locked))
				continue
		var/datum/sprite_accessory/D = new path()

		if(D.icon_state)
			L[D.name] = D
		else
			L += D.name

		switch(D.gender)
			if(MALE)
				male += D.name
			if(FEMALE)
				female += D.name
			else
				male += D.name
				female += D.name
	return L

/datum/sprite_accessory
	var/icon			//the icon file the accessory is located in
	var/icon_state		//the icon_state of the accessory
	var/name			//the preview name of the accessory
	var/gender = NEUTER	//Determines if the accessory will be skipped or included in random hair generations
	var/gender_specific //Something that can be worn by either gender, but looks different on each
	var/color_src = MUTCOLORS	//Currently only used by mutantparts so don't worry about hair and stuff. This is the source that this accessory will get its color from. Default is MUTCOLOR, but can also be HAIR, FACEHAIR, EYECOLOR and 0 if none.
	var/hasinner		//Decides if this sprite has an "inner" part, such as the fleshy parts on ears.
	var/locked = FALSE		//Is this part locked from roundstart selection? Used for parts that apply effects
	var/dimension_x = 32
	var/dimension_y = 32
	var/center = FALSE	//Should we center the sprite?

//////////////////////
// Hair Definitions //
//////////////////////
/datum/sprite_accessory/hair
	icon = 'icons/mob/human_face.dmi'	  // default icon for all hairs

/datum/sprite_accessory/hair/short
	name = "Short Hair"	  // try to capatilize the names please~ // try to spell
	icon_state = "hair_a" // you do not need to define _s or _l sub-states, game automatically does this for you

/datum/sprite_accessory/hair/shorthair2
	name = "Short Hair 2"
	icon_state = "hair_shorthair2"

/datum/sprite_accessory/hair/shorthair3
	name = "Short Hair 3"
	icon_state = "hair_shorthair3"

/datum/sprite_accessory/hair/cut
	name = "Cut Hair"
	icon_state = "hair_c"

/datum/sprite_accessory/hair/long
	name = "Shoulder-length Hair"
	icon_state = "hair_b"

/datum/sprite_accessory/hair/longer
	name = "Long Hair"
	icon_state = "hair_vlong"

/datum/sprite_accessory/hair/over_eye
	name = "Over Eye"
	icon_state = "hair_shortovereye"

/datum/sprite_accessory/hair/long_over_eye
	name = "Long Over Eye"
	icon_state = "hair_longovereye"

/datum/sprite_accessory/hair/longest2
	name = "Very Long Over Eye"
	icon_state = "hair_longest2"

/datum/sprite_accessory/hair/longest
	name = "Very Long Hair"
	icon_state = "hair_longest"

/datum/sprite_accessory/hair/longfringe
	name = "Long Fringe"
	icon_state = "hair_longfringe"

/datum/sprite_accessory/hair/longestalt
	name = "Longer Fringe"
	icon_state = "hair_vlongfringe"

/datum/sprite_accessory/hair/gentle
	name = "Gentle"
	icon_state = "hair_gentle"

/datum/sprite_accessory/hair/halfbang
	name = "Half-banged Hair"
	icon_state = "hair_halfbang"

/datum/sprite_accessory/hair/halfbang2
	name = "Half-banged Hair 2"
	icon_state = "hair_halfbang2"

/datum/sprite_accessory/hair/ponytail1
	name = "Ponytail"
	icon_state = "hair_ponytail"

/datum/sprite_accessory/hair/ponytail2
	name = "Ponytail 2"
	icon_state = "hair_ponytail2"

/datum/sprite_accessory/hair/ponytail3
	name = "Ponytail 3"
	icon_state = "hair_ponytail3"

/datum/sprite_accessory/hair/ponytail4
	name = "Ponytail 4"
	icon_state = "hair_ponytail4"

/datum/sprite_accessory/hair/ponytail5
	name = "Ponytail 5"
	icon_state = "hair_ponytail5"


/datum/sprite_accessory/hair/sidetail
	name = "Side Pony"
	icon_state = "hair_sidetail"

/datum/sprite_accessory/hair/sidetail2
	name = "Side Pony 2"
	icon_state = "hair_sidetail2"

/datum/sprite_accessory/hair/sidetail3
	name = "Side Pony 3"
	icon_state = "hair_sidetail3"

/datum/sprite_accessory/hair/sidetail4
	name = "Side Pony 4"
	icon_state = "hair_sidetail4"

/datum/sprite_accessory/hair/oneshoulder
	name = "One Shoulder"
	icon_state = "hair_oneshoulder"

/datum/sprite_accessory/hair/tressshoulder
	name = "Tress Shoulder"
	icon_state = "hair_tressshoulder"

/datum/sprite_accessory/hair/parted
	name = "Parted"
	icon_state = "hair_parted"

/datum/sprite_accessory/hair/pompadour
	name = "Pompadour"
	icon_state = "hair_pompadour"

/datum/sprite_accessory/hair/bigpompadour
	name = "Big Pompadour"
	icon_state = "hair_bigpompadour"

/datum/sprite_accessory/hair/quiff
	name = "Quiff"
	icon_state = "hair_quiff"

/datum/sprite_accessory/hair/bedhead
	name = "Bedhead"
	icon_state = "hair_bedhead"

/datum/sprite_accessory/hair/bedhead2
	name = "Bedhead 2"
	icon_state = "hair_bedheadv2"

/datum/sprite_accessory/hair/bedhead3
	name = "Bedhead 3"
	icon_state = "hair_bedheadv3"

/datum/sprite_accessory/hair/messy
	name = "Messy"
	icon_state = "hair_messy"

/datum/sprite_accessory/hair/beehive
	name = "Beehive"
	icon_state = "hair_beehive"

/datum/sprite_accessory/hair/beehive2
	name = "Beehive 2"
	icon_state = "hair_beehivev2"

/datum/sprite_accessory/hair/bobcurl
	name = "Bobcurl"
	icon_state = "hair_bobcurl"

/datum/sprite_accessory/hair/bob
	name = "Bob"
	icon_state = "hair_bobcut"

/datum/sprite_accessory/hair/bowl
	name = "Bowl"
	icon_state = "hair_bowlcut"

/datum/sprite_accessory/hair/buzz
	name = "Buzzcut"
	icon_state = "hair_buzzcut"

/datum/sprite_accessory/hair/crew
	name = "Crewcut"
	icon_state = "hair_crewcut"

/datum/sprite_accessory/hair/combover
	name = "Combover"
	icon_state = "hair_combover"

/datum/sprite_accessory/hair/devillock
	name = "Devil Lock"
	icon_state = "hair_devilock"

/datum/sprite_accessory/hair/dreadlocks
	name = "Dreadlocks"
	icon_state = "hair_dreads"

/datum/sprite_accessory/hair/curls
	name = "Curls"
	icon_state = "hair_curls"

/datum/sprite_accessory/hair/afro
	name = "Afro"
	icon_state = "hair_afro"

/datum/sprite_accessory/hair/afro2
	name = "Afro 2"
	icon_state = "hair_afro2"

/datum/sprite_accessory/hair/afro_large
	name = "Big Afro"
	icon_state = "hair_bigafro"

/datum/sprite_accessory/hair/sargeant
	name = "Flat Top"
	icon_state = "hair_sargeant"

/datum/sprite_accessory/hair/emo
	name = "Emo"
	icon_state = "hair_emo"

/datum/sprite_accessory/hair/longemo
	name = "Long Emo"
	icon_state = "hair_longemo"

/datum/sprite_accessory/hair/fag
	name = "Flow Hair"
	icon_state = "hair_f"

/datum/sprite_accessory/hair/feather
	name = "Feather"
	icon_state = "hair_feather"

/datum/sprite_accessory/hair/hitop
	name = "Hitop"
	icon_state = "hair_hitop"

/datum/sprite_accessory/hair/mohawk
	name = "Mohawk"
	icon_state = "hair_d"

/datum/sprite_accessory/hair/reversemohawk
	name = "Reverse Mohawk"
	icon_state = "hair_reversemohawk"

/datum/sprite_accessory/hair/jensen
	name = "Jensen Hair"
	icon_state = "hair_jensen"

/datum/sprite_accessory/hair/gelled
	name = "Gelled Back"
	icon_state = "hair_gelled"

/datum/sprite_accessory/hair/spiky
	name = "Spiky"
	icon_state = "hair_spikey"

/datum/sprite_accessory/hair/spiky2
	name = "Spiky 2"
	icon_state = "hair_spiky"

/datum/sprite_accessory/hair/spiky3
	name = "Spiky 3"
	icon_state = "hair_spiky2"

/datum/sprite_accessory/hair/protagonist
	name = "Slightly Long"
	icon_state = "hair_protagonist"

/datum/sprite_accessory/hair/kusangi
	name = "Kusanagi Hair"
	icon_state = "hair_kusanagi"

/datum/sprite_accessory/hair/kagami
	name = "Pigtails"
	icon_state = "hair_kagami"

/datum/sprite_accessory/hair/pigtail
	name = "Pigtails 2"
	icon_state = "hair_pigtails"

/datum/sprite_accessory/hair/pigtail
	name = "Pigtails 3"
	icon_state = "hair_pigtails2"

/datum/sprite_accessory/hair/himecut
	name = "Hime Cut"
	icon_state = "hair_himecut"

/datum/sprite_accessory/hair/himecut2
	name = "Hime Cut 2"
	icon_state = "hair_himecut2"

/datum/sprite_accessory/hair/himeup
	name = "Hime Updo"
	icon_state = "hair_himeup"

/datum/sprite_accessory/hair/antenna
	name = "Ahoge"
	icon_state = "hair_antenna"

/datum/sprite_accessory/hair/front_braid
	name = "Braided front"
	icon_state = "hair_braidfront"

/datum/sprite_accessory/hair/lowbraid
	name = "Low Braid"
	icon_state = "hair_hbraid"

/datum/sprite_accessory/hair/not_floorlength_braid
	name = "High Braid"
	icon_state = "hair_braid2"

/datum/sprite_accessory/hair/shortbraid
	name = "Short Braid"
	icon_state = "hair_shortbraid"

/datum/sprite_accessory/hair/braid
	name = "Floorlength Braid"
	icon_state = "hair_braid"

/datum/sprite_accessory/hair/odango
	name = "Odango"
	icon_state = "hair_odango"

/datum/sprite_accessory/hair/ombre
	name = "Ombre"
	icon_state = "hair_ombre"

/datum/sprite_accessory/hair/updo
	name = "Updo"
	icon_state = "hair_updo"

/datum/sprite_accessory/hair/skinhead
	name = "Skinhead"
	icon_state = "hair_skinhead"

/datum/sprite_accessory/hair/longbangs
	name = "Long Bangs"
	icon_state = "hair_lbangs"

/datum/sprite_accessory/hair/balding
	name = "Balding Hair"
	icon_state = "hair_e"

/datum/sprite_accessory/hair/bald
	name = "Bald"
	icon_state = null

/datum/sprite_accessory/hair/parted
	name = "Side Part"
	icon_state = "hair_part"

/datum/sprite_accessory/hair/braided
	name = "Braided"
	icon_state = "hair_braided"

/datum/sprite_accessory/hair/bun
	name = "Bun Head"
	icon_state = "hair_bun"

/datum/sprite_accessory/hair/bun2
	name = "Bun Head 2"
	icon_state = "hair_bunhead2"

/datum/sprite_accessory/hair/braidtail
	name = "Braided Tail"
	icon_state = "hair_braidtail"

/datum/sprite_accessory/hair/bigflattop
	name = "Big Flat Top"
	icon_state = "hair_bigflattop"

/datum/sprite_accessory/hair/drillhair
	name = "Drill Hair"
	icon_state = "hair_drillhair"

/datum/sprite_accessory/hair/keanu
	name = "Keanu Hair"
	icon_state = "hair_keanu"

/datum/sprite_accessory/hair/swept
	name = "Swept Back Hair"
	icon_state = "hair_swept"

/datum/sprite_accessory/hair/swept2
	name = "Swept Back Hair 2"
	icon_state = "hair_swept2"

/datum/sprite_accessory/hair/business
	name = "Business Hair"
	icon_state = "hair_business"

/datum/sprite_accessory/hair/business2
	name = "Business Hair 2"
	icon_state = "hair_business2"

/datum/sprite_accessory/hair/business3
	name = "Business Hair 3"
	icon_state = "hair_business3"

/datum/sprite_accessory/hair/business4
	name = "Business Hair 4"
	icon_state = "hair_business4"

/datum/sprite_accessory/hair/hedgehog
	name = "Hedgehog Hair"
	icon_state = "hair_hedgehog"

/datum/sprite_accessory/hair/bob
	name = "Bob Hair"
	icon_state = "hair_bob"

/datum/sprite_accessory/hair/bob2
	name = "Bob Hair 2"
	icon_state = "hair_bob2"

/datum/sprite_accessory/hair/boddicker
	name = "Boddicker"
	icon_state = "hair_boddicker"

/datum/sprite_accessory/hair/long
	name = "Long Hair 1"
	icon_state = "hair_long"

/datum/sprite_accessory/hair/long2
	name = "Long Hair 2"
	icon_state = "hair_long2"

/datum/sprite_accessory/hair/pixie
	name = "Pixie Cut"
	icon_state = "hair_pixie"

/datum/sprite_accessory/hair/megaeyebrows
	name = "Mega Eyebrows"
	icon_state = "hair_megaeyebrows"

/datum/sprite_accessory/hair/highponytail
	name = "High Ponytail"
	icon_state = "hair_highponytail"

/datum/sprite_accessory/hair/longponytail
	name = "Long Ponytail"
	icon_state = "hair_longstraightponytail"

/datum/sprite_accessory/hair/sidepartlongalt
	name = "Long Side Part"
	icon_state = "hair_longsidepart"

/datum/sprite_accessory/hair/sidecut
	name = "Sidecut"
	icon_state = "hair_sidecut"

/////////////////////////////
// Facial Hair Definitions //
/////////////////////////////
/datum/sprite_accessory/facial_hair
	icon = 'icons/mob/human_face.dmi'
	gender = MALE // barf (unless you're a dorf, dorfs dig chix w/ beards :P)

/datum/sprite_accessory/facial_hair/shaved
	name = "Shaved"
	icon_state = null
	gender = NEUTER

/datum/sprite_accessory/facial_hair/watson
	name = "Watson Mustache"
	icon_state = "facial_watson"

/datum/sprite_accessory/facial_hair/hogan
	name = "Hulk Hogan Mustache"
	icon_state = "facial_hogan" //-Neek

/datum/sprite_accessory/facial_hair/vandyke
	name = "Van Dyke Mustache"
	icon_state = "facial_vandyke"

/datum/sprite_accessory/facial_hair/chaplin
	name = "Square Mustache"
	icon_state = "facial_chaplin"

/datum/sprite_accessory/facial_hair/selleck
	name = "Selleck Mustache"
	icon_state = "facial_selleck"

/datum/sprite_accessory/facial_hair/neckbeard
	name = "Neckbeard"
	icon_state = "facial_neckbeard"

/datum/sprite_accessory/facial_hair/fullbeard
	name = "Full Beard"
	icon_state = "facial_fullbeard"

/datum/sprite_accessory/facial_hair/longbeard
	name = "Long Beard"
	icon_state = "facial_longbeard"

/datum/sprite_accessory/facial_hair/vlongbeard
	name = "Very Long Beard"
	icon_state = "facial_wise"

/datum/sprite_accessory/facial_hair/elvis
	name = "Elvis Sideburns"
	icon_state = "facial_elvis"

/datum/sprite_accessory/facial_hair/abe
	name = "Abraham Lincoln Beard"
	icon_state = "facial_abe"

/datum/sprite_accessory/facial_hair/chinstrap
	name = "Chinstrap"
	icon_state = "facial_chin"

/datum/sprite_accessory/facial_hair/hip
	name = "Hipster Beard"
	icon_state = "facial_hip"

/datum/sprite_accessory/facial_hair/gt
	name = "Goatee"
	icon_state = "facial_gt"

/datum/sprite_accessory/facial_hair/jensen
	name = "Jensen Beard"
	icon_state = "facial_jensen"

/datum/sprite_accessory/facial_hair/dwarf
	name = "Dwarf Beard"
	icon_state = "facial_dwarf"

/datum/sprite_accessory/facial_hair/fiveoclock
	name = "Five o Clock Shadow"
	icon_state = "facial_fiveoclock"

/datum/sprite_accessory/facial_hair/fu
	name = "Fu Manchu"
	icon_state = "facial_fumanchu"

/datum/sprite_accessory/facial_hair/brokenman
	name = "Broken Man"
	icon_state = "facial_brokenman"


///////////////////////////
// Underwear Definitions //
///////////////////////////
/datum/sprite_accessory/underwear
	icon = 'icons/mob/underwear.dmi'

/datum/sprite_accessory/underwear/nude
	name = "Nude"
	icon_state = null
	gender = NEUTER

/datum/sprite_accessory/underwear/male_white
	name = "Mens White"
	icon_state = "male_white"
	gender = MALE

/datum/sprite_accessory/underwear/male_grey
	name = "Mens Grey"
	icon_state = "male_grey"
	gender = MALE

/datum/sprite_accessory/underwear/male_green
	name = "Mens Green"
	icon_state = "male_green"
	gender = MALE

/datum/sprite_accessory/underwear/male_blue
	name = "Mens Blue"
	icon_state = "male_blue"
	gender = MALE

/datum/sprite_accessory/underwear/male_black
	name = "Mens Black"
	icon_state = "male_black"
	gender = MALE

/datum/sprite_accessory/underwear/male_mankini
	name = "Mankini"
	icon_state = "male_mankini"
	gender = MALE

/datum/sprite_accessory/underwear/male_hearts
	name = "Mens Hearts Boxer"
	icon_state = "male_hearts"
	gender = MALE

/datum/sprite_accessory/underwear/male_blackalt
	name = "Mens Black Boxer"
	icon_state = "male_blackalt"
	gender = MALE

/datum/sprite_accessory/underwear/male_greyalt
	name = "Mens Grey Boxer"
	icon_state = "male_greyalt"
	gender = MALE

/datum/sprite_accessory/underwear/male_stripe
	name = "Mens Striped Boxer"
	icon_state = "male_stripe"
	gender = MALE

/datum/sprite_accessory/underwear/male_commie
	name = "Mens Striped Commie Boxer"
	icon_state = "male_commie"
	gender = MALE

/datum/sprite_accessory/underwear/male_uk
	name = "Mens Striped UK Boxer"
	icon_state = "male_uk"
	gender = MALE

/datum/sprite_accessory/underwear/male_usastripe
	name = "Mens Striped Freedom Boxer"
	icon_state = "male_assblastusa"
	gender = MALE

/datum/sprite_accessory/underwear/male_kinky
	name = "Mens Kinky"
	icon_state = "male_kinky"
	gender = MALE

/datum/sprite_accessory/underwear/male_red
	name = "Mens Red"
	icon_state = "male_red"
	gender = MALE

/datum/sprite_accessory/underwear/female_red
	name = "Ladies Red"
	icon_state = "female_red"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_white
	name = "Ladies White"
	icon_state = "female_white"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_yellow
	name = "Ladies Yellow"
	icon_state = "female_yellow"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_blue
	name = "Ladies Blue"
	icon_state = "female_blue"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_black
	name = "Ladies Black"
	icon_state = "female_black"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_thong
	name = "Ladies Thong"
	icon_state = "female_thong"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_babydoll
	name = "Babydoll"
	icon_state = "female_babydoll"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_babyblue
	name = "Ladies Baby-Blue"
	icon_state = "female_babyblue"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_green
	name = "Ladies Green"
	icon_state = "female_green"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_pink
	name = "Ladies Pink"
	icon_state = "female_pink"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_kinky
	name = "Ladies Kinky"
	icon_state = "female_kinky"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_whitealt
	name = "Ladies White Sport"
	icon_state = "female_whitealt"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_blackalt
	name = "Ladies Black Sport"
	icon_state = "female_blackalt"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_white_neko
	name = "Ladies White Neko"
	icon_state = "female_neko_white"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_black_neko
	name = "Ladies Black Neko"
	icon_state = "female_neko_black"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_usastripe
	name = "Ladies Freedom"
	icon_state = "female_assblastusa"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_uk
	name = "Ladies UK"
	icon_state = "female_uk"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_commie
	name = "Ladies Commie"
	icon_state = "female_commie"
	gender = FEMALE

////////////////////////////
// Undershirt Definitions //
////////////////////////////
/datum/sprite_accessory/undershirt
	icon = 'icons/mob/underwear.dmi'

/datum/sprite_accessory/undershirt/nude
	name = "Nude"
	icon_state = null
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_white
	name = "White Shirt"
	icon_state = "shirt_white"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_black
	name = "Black Shirt"
	icon_state = "shirt_black"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_grey
	name = "Grey Shirt"
	icon_state = "shirt_grey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_white
	name = "White Tank Top"
	icon_state = "tank_white"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_black
	name = "Black Tank Top"
	icon_state = "tank_black"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_grey
	name = "Grey Tank Top"
	icon_state = "tank_grey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/female_midriff
	name = "Midriff Tank Top"
	icon_state = "tank_midriff"
	gender = FEMALE

/datum/sprite_accessory/undershirt/lover
	name = "Lover Shirt"
	icon_state = "lover"
	gender = NEUTER

/datum/sprite_accessory/undershirt/ian
	name = "Blue Ian Shirt"
	icon_state = "ian"
	gender = NEUTER

/datum/sprite_accessory/undershirt/uk
	name = "UK Shirt"
	icon_state = "uk"
	gender = NEUTER

/datum/sprite_accessory/undershirt/usa
	name = "USA Shirt"
	icon_state = "shirt_assblastusa"
	gender = NEUTER

/datum/sprite_accessory/undershirt/ilovent
	name = "I Love NT Shirt"
	icon_state = "ilovent"
	gender = NEUTER

/datum/sprite_accessory/undershirt/peace
	name = "Peace Shirt"
	icon_state = "peace"
	gender = NEUTER

/datum/sprite_accessory/undershirt/mondmondjaja
	name = "Band Shirt"
	icon_state = "band"
	gender = NEUTER

/datum/sprite_accessory/undershirt/pacman
	name = "Pogoman Shirt"
	icon_state = "pogoman"
	gender = NEUTER

/datum/sprite_accessory/undershirt/matroska
	name = "Matroska Shirt"
	icon_state = "matroska"
	gender = NEUTER

/datum/sprite_accessory/undershirt/whiteshortsleeve
	name = "White Short-sleeved Shirt"
	icon_state = "whiteshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/purpleshortsleeve
	name = "Purple Short-sleeved Shirt"
	icon_state = "purpleshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blueshortsleeve
	name = "Blue Short-sleeved Shirt"
	icon_state = "blueshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/greenshortsleeve
	name = "Green Short-sleeved Shirt"
	icon_state = "greenshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blackshortsleeve
	name = "Black Short-sleeved Shirt"
	icon_state = "blackshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blueshirt
	name = "Blue T-Shirt"
	icon_state = "blueshirt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redshirt
	name = "Red T-Shirt"
	icon_state = "redshirt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/yellowshirt
	name = "Yellow T-Shirt"
	icon_state = "yellowshirt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/greenshirt
	name = "Green T-Shirt"
	icon_state = "greenshirt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/bluepolo
	name = "Blue Polo Shirt"
	icon_state = "bluepolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redpolo
	name = "Red Polo Shirt"
	icon_state = "redpolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/whitepolo
	name = "White Polo Shirt"
	icon_state = "whitepolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/grayyellowpolo
	name = "Gray-Yellow Polo Shirt"
	icon_state = "grayyellowpolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redtop
	name = "Red Top"
	icon_state = "redtop"
	gender = FEMALE

/datum/sprite_accessory/undershirt/whitetop
	name = "White Top"
	icon_state = "whitetop"
	gender = FEMALE

/datum/sprite_accessory/undershirt/greenshirtsport
	name = "Green Sports Shirt"
	icon_state = "greenshirtsport"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redshirtsport
	name = "Red Sports Shirt"
	icon_state = "redshirtsport"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blueshirtsport
	name = "Blue Sports Shirt"
	icon_state = "blueshirtsport"
	gender = NEUTER

/datum/sprite_accessory/undershirt/ss13
	name = "SS13 Shirt"
	icon_state = "shirt_ss13"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tankfire
	name = "Fire Tank Top"
	icon_state = "tank_fire"
	gender = NEUTER

/datum/sprite_accessory/undershirt/question
	name = "Question Shirt"
	icon_state = "shirt_question"
	gender = NEUTER

/datum/sprite_accessory/undershirt/skull
	name = "Skull Shirt"
	icon_state = "shirt_skull"
	gender = NEUTER

/datum/sprite_accessory/undershirt/commie
	name = "Commie Shirt"
	icon_state = "shirt_commie"
	gender = NEUTER

/datum/sprite_accessory/undershirt/nano
	name = "Nanotrasen Shirt"
	icon_state = "shirt_nano"
	gender = NEUTER

/datum/sprite_accessory/undershirt/stripe
	name = "Striped Shirt"
	icon_state = "shirt_stripes"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blueshirt
	name = "Blue Shirt"
	icon_state = "shirt_blue"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redshirt
	name = "Red Shirt"
	icon_state = "shirt_red"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_red
	name = "Red Tank Top"
	icon_state = "tank_red"
	gender = NEUTER

/datum/sprite_accessory/undershirt/greenshirt
	name = "Green Shirt"
	icon_state = "shirt_green"
	gender = NEUTER

/datum/sprite_accessory/undershirt/meat
	name = "Meat Shirt"
	icon_state = "shirt_meat"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tiedye
	name = "Tie-dye Shirt"
	icon_state = "shirt_tiedye"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redjersey
	name = "Red Jersey"
	icon_state = "shirt_redjersey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/bluejersey
	name = "Blue Jersey"
	icon_state = "shirt_bluejersey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tankstripe
	name = "Striped Tank Top"
	icon_state = "tank_stripes"
	gender = NEUTER

/datum/sprite_accessory/undershirt/clownshirt
	name = "Clown Shirt"
	icon_state = "shirt_clown"
	gender = NEUTER

/datum/sprite_accessory/undershirt/alienshirt
	name = "Alien Shirt"
	icon_state = "shirt_alien"
	gender = NEUTER



///////////////////////
// Socks Definitions //
///////////////////////
/datum/sprite_accessory/socks
	icon = 'icons/mob/underwear.dmi'

/datum/sprite_accessory/socks/nude
	name = "Nude"
	icon_state = null

/datum/sprite_accessory/socks/white_norm
	name = "Normal White"
	icon_state = "white_norm"

/datum/sprite_accessory/socks/black_norm
	name = "Normal Black"
	icon_state = "black_norm"

/datum/sprite_accessory/socks/white_short
	name = "Short White"
	icon_state = "white_short"

/datum/sprite_accessory/socks/black_short
	name = "Short Black"
	icon_state = "black_short"

/datum/sprite_accessory/socks/white_knee
	name = "Knee-high White"
	icon_state = "white_knee"

/datum/sprite_accessory/socks/black_knee
	name = "Knee-high Black"
	icon_state = "black_knee"

/datum/sprite_accessory/socks/thin_knee
	name = "Knee-high Thin"
	icon_state = "thin_knee"

/datum/sprite_accessory/socks/striped_knee
	name = "Knee-high Striped"
	icon_state = "striped_knee"

/datum/sprite_accessory/socks/rainbow_knee
	name = "Knee-high Rainbow"
	icon_state = "rainbow_knee"

/datum/sprite_accessory/socks/white_thigh
	name = "Thigh-high White"
	icon_state = "white_thigh"

/datum/sprite_accessory/socks/black_thigh
	name = "Thigh-high Black"
	icon_state = "black_thigh"

/datum/sprite_accessory/socks/thin_thigh
	name = "Thigh-high Thin"
	icon_state = "thin_thigh"

/datum/sprite_accessory/socks/striped_thigh
	name = "Thigh-high Striped"
	icon_state = "striped_thigh"

/datum/sprite_accessory/socks/rainbow_thigh
	name = "Thigh-high Rainbow"
	icon_state = "rainbow_thigh"

/datum/sprite_accessory/socks/usa_knee
	name = "Knee-High Freedom Stripes"
	icon_state = "assblastusa_knee"

/datum/sprite_accessory/socks/usa_thigh
	name = "Thigh-high Freedom Stripes"
	icon_state = "assblastusa_thigh"

/datum/sprite_accessory/socks/uk_knee
	name = "Knee-High UK Stripes"
	icon_state = "uk_knee"

/datum/sprite_accessory/socks/uk_thigh
	name = "Thigh-high UK Stripes"
	icon_state = "uk_thigh"

/datum/sprite_accessory/socks/commie_knee
	name = "Knee-High Commie Stripes"
	icon_state = "commie_knee"

/datum/sprite_accessory/socks/commie_thigh
	name = "Thigh-high Commie Stripes"
	icon_state = "commie_thigh"

/datum/sprite_accessory/socks/pantyhose
	name = "Pantyhose"
	icon_state = "pantyhose"

//////////.//////////////////
// MutantParts Definitions //
/////////////////////////////

/datum/sprite_accessory/body_markings
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/body_markings/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/body_markings/dtiger
	name = "Dark Tiger Body"
	icon_state = "dtiger"
	gender_specific = 1

/datum/sprite_accessory/body_markings/ltiger
	name = "Light Tiger Body"
	icon_state = "ltiger"
	gender_specific = 1

/datum/sprite_accessory/body_markings/lbelly
	name = "Light Belly"
	icon_state = "lbelly"
	gender_specific = 1

/datum/sprite_accessory/tails
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/tails_animated
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/tails/lizard/smooth
	name = "Smooth"
	icon_state = "smooth"

/datum/sprite_accessory/tails_animated/lizard/smooth
	name = "Smooth"
	icon_state = "smooth"

/datum/sprite_accessory/tails/lizard/dtiger
	name = "Dark Tiger"
	icon_state = "dtiger"

/datum/sprite_accessory/tails_animated/lizard/dtiger
	name = "Dark Tiger"
	icon_state = "dtiger"

/datum/sprite_accessory/tails/lizard/ltiger
	name = "Light Tiger"
	icon_state = "ltiger"

/datum/sprite_accessory/tails_animated/lizard/ltiger
	name = "Light Tiger"
	icon_state = "ltiger"

/datum/sprite_accessory/tails/lizard/spikes
	name = "Spikes"
	icon_state = "spikes"

/datum/sprite_accessory/tails_animated/lizard/spikes
	name = "Spikes"
	icon_state = "spikes"

/datum/sprite_accessory/tails/human/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/tails_animated/human/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/tails/human/cat
	name = "Cat"
	icon_state = "cat"
	color_src = HAIR

/datum/sprite_accessory/tails_animated/human/cat
	name = "Cat"
	icon_state = "cat"
	color_src = HAIR

/datum/sprite_accessory/snouts
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/snouts/sharp
	name = "Sharp"
	icon_state = "sharp"

/datum/sprite_accessory/snouts/round
	name = "Round"
	icon_state = "round"

/datum/sprite_accessory/snouts/sharplight
	name = "Sharp + Light"
	icon_state = "sharplight"

/datum/sprite_accessory/snouts/roundlight
	name = "Round + Light"
	icon_state = "roundlight"

/datum/sprite_accessory/horns
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/horns/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/horns/simple
	name = "Simple"
	icon_state = "simple"

/datum/sprite_accessory/horns/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/horns/curled
	name = "Curled"
	icon_state = "curled"

/datum/sprite_accessory/horns/ram
	name = "Ram"
	icon_state = "ram"

/datum/sprite_accessory/horns/angler
	name = "Angeler"
	icon_state = "angler"

/datum/sprite_accessory/ears
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/ears/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/ears/cat
	name = "Cat"
	icon_state = "cat"
	hasinner = 1
	color_src = HAIR

/datum/sprite_accessory/wings/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/wings_open
	icon = 'icons/mob/wings.dmi'

/datum/sprite_accessory/wings_open/angel
	name = "Angel"
	icon_state = "angel"
	color_src = 0
	dimension_x = 46
	center = TRUE
	dimension_y = 34

/datum/sprite_accessory/wings
	icon = 'icons/mob/wings.dmi'

/datum/sprite_accessory/wings/angel
	name = "Angel"
	icon_state = "angel"
	color_src = 0
	dimension_x = 46
	center = TRUE
	dimension_y = 34
	locked = TRUE

/datum/sprite_accessory/frills
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/frills/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/frills/simple
	name = "Simple"
	icon_state = "simple"

/datum/sprite_accessory/frills/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/frills/aquatic
	name = "Aquatic"
	icon_state = "aqua"

/datum/sprite_accessory/spines
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/spines_animated
	icon = 'icons/mob/mutant_bodyparts.dmi'

/datum/sprite_accessory/spines/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/spines_animated/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/spines/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/spines_animated/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/spines/shortmeme
	name = "Short + Membrane"
	icon_state = "shortmeme"

/datum/sprite_accessory/spines_animated/shortmeme
	name = "Short + Membrane"
	icon_state = "shortmeme"

/datum/sprite_accessory/spines/long
	name = "Long"
	icon_state = "long"

/datum/sprite_accessory/spines_animated/long
	name = "Long"
	icon_state = "long"

/datum/sprite_accessory/spines/longmeme
	name = "Long + Membrane"
	icon_state = "longmeme"

/datum/sprite_accessory/spines_animated/longmeme
	name = "Long + Membrane"
	icon_state = "longmeme"

/datum/sprite_accessory/spines/aqautic
	name = "Aquatic"
	icon_state = "aqua"

/datum/sprite_accessory/spines_animated/aqautic
	name = "Aquatic"
	icon_state = "aqua"

/datum/sprite_accessory/legs 	//legs are a special case, they aren't actually sprite_accessories but are updated with them.
	icon = null					//These datums exist for selecting legs on preference, and little else

/datum/sprite_accessory/legs/none
	name = "Normal Legs"

/datum/sprite_accessory/legs/digitigrade_lizard
	name = "Digitigrade Legs"
