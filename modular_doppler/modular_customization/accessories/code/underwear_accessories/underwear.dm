/datum/sprite_accessory/underwear
	icon = 'modular_doppler/modular_customization/accessories/icons/underwear/underwear.dmi'
	///Whether the underwear uses a special sprite for digitigrade style (i.e. briefs, not panties). Adds a "_d" suffix to the icon state
	var/has_digitigrade = FALSE
	///Whether this underwear includes a top (Because gender = FEMALE doesn't actually apply here.). Hides breasts, nothing more.
	var/hides_breasts = FALSE

/*
	Adding has_digitigrade to TG stuff
*/
/datum/sprite_accessory/underwear/male_briefs
	has_digitigrade = TRUE

/datum/sprite_accessory/underwear/male_boxers
	has_digitigrade = TRUE

/datum/sprite_accessory/underwear/male_stripe
	has_digitigrade = TRUE

/datum/sprite_accessory/underwear/male_midway
	has_digitigrade = TRUE

/datum/sprite_accessory/underwear/male_longjohns
	has_digitigrade = TRUE

/datum/sprite_accessory/underwear/male_hearts
	has_digitigrade = TRUE

/datum/sprite_accessory/underwear/male_commie
	has_digitigrade = TRUE

/datum/sprite_accessory/underwear/male_usastripe
	has_digitigrade = TRUE

/datum/sprite_accessory/underwear/male_uk
	has_digitigrade = TRUE

/*
	Modular Underwear past here
*/

//Briefs
/datum/sprite_accessory/underwear/male_bee
	name = "Boxers - Bee"
	icon_state = "bee_shorts"
	has_digitigrade = TRUE
	gender = MALE
	use_static = TRUE

/datum/sprite_accessory/underwear/boyshorts
	name = "Boyshorts"
	icon_state = "boyshorts"
	has_digitigrade = TRUE
	gender = FEMALE

/datum/sprite_accessory/underwear/boyshorts_alt
	name = "Boyshorts (Alt)"
	icon_state = "boyshorts_alt"
	gender = FEMALE

//Panties
/datum/sprite_accessory/underwear/panties_basic
	name = "Panties"
	icon_state = "panties"
	gender = FEMALE

/datum/sprite_accessory/underwear/panties_slim
	name = "Panties - Slim"
	icon_state = "panties_slim"
	gender = FEMALE

/datum/sprite_accessory/underwear/panties_thin
	name = "Panties - Thin"
	icon_state = "panties_thin"
	gender = FEMALE

/datum/sprite_accessory/underwear/thong
	name = "Thong"
	icon_state = "thong"
	gender = FEMALE

/datum/sprite_accessory/underwear/thong_babydoll
	name = "Thong (Alt)"
	icon_state = "thong_babydoll"
	gender = FEMALE

/datum/sprite_accessory/underwear/panties_swimsuit
	name = "Panties - Swimsuit"
	icon_state = "panties_swimming"
	gender = FEMALE

/datum/sprite_accessory/underwear/panties_neko
	name = "Panties - Neko"
	icon_state = "panties_neko"
	gender = FEMALE

/datum/sprite_accessory/underwear/striped_panties
	name = "Panties - Striped"
	icon_state = "striped_panties"
	gender = FEMALE

/datum/sprite_accessory/underwear/loincloth
	name = "Loincloth"
	icon_state = "loincloth"

/datum/sprite_accessory/underwear/loincloth_alt
	name = "Shorter Loincloth"
	icon_state = "loincloth_alt"

//Presets
/datum/sprite_accessory/underwear/lizared
	name = "LIZARED Underwear"
	icon_state = "lizared"
	use_static = TRUE

/datum/sprite_accessory/underwear/female_kinky
	name = "Panties - Lingerie"
	icon_state = "panties_kinky"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_commie
	name = "Panties - Commie"
	icon_state = "panties_commie"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_usastripe
	name = "Panties - Freedom"
	icon_state = "panties_assblastusa"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/panties_uk
	name = "Panties - UK"
	icon_state = "panties_uk"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_beekini
	name = "Panties - Bee-kini"
	icon_state = "panties_bee-kini"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/cow
	name = "Panties - Cow"
	icon_state = "panties_cow"
	gender = FEMALE
	use_static = TRUE

//Full-Body Underwear, i.e. swimsuits (Including re-enabling 3 from TG)
//These likely require hides_breasts = TRUE
/datum/sprite_accessory/underwear/swimsuit_onepiece //TG
	name = "One-Piece Swimsuit"
	icon_state = "swim_onepiece"
	gender = FEMALE
	hides_breasts = TRUE

/datum/sprite_accessory/underwear/swimsuit_strapless_onepiece //TG
	name = "Strapless One-Piece Swimsuit"
	icon_state = "swim_strapless_onepiece"
	gender = FEMALE
	hides_breasts = TRUE

/datum/sprite_accessory/underwear/swimsuit_stripe //TG
	name = "Strapless Striped Swimsuit"
	icon_state = "swim_stripe"
	gender = FEMALE
	hides_breasts = TRUE

/datum/sprite_accessory/underwear/swimsuit_red
	name = "One-Piece Swimsuit - Red"
	icon_state = "swimming_red"
	gender = FEMALE
	use_static = TRUE
	hides_breasts = TRUE

/datum/sprite_accessory/underwear/swimsuit
	name = "One-Piece Swimsuit - Black"
	icon_state = "swimming_black"
	gender = FEMALE
	use_static = TRUE
	hides_breasts = TRUE

//Fishnets
/datum/sprite_accessory/underwear/fishnet_lower
	name = "Panties - Fishnet"
	icon_state = "fishnet_lower"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/fishnet_lower/alt
	name = "Panties - Fishnet (Greyscale)"
	icon_state = "fishnet_lower_alt"
