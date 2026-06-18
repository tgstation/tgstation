/datum/sprite_accessory/clothing
	abstract_type = /datum/sprite_accessory/clothing
	/// Allows you to specify a greyscale config
	var/greyscale_config
	/// Icon state in the digitigrade template file to use if the wearer is digitigrade.
	/// If null, no special digitigrade handling is done.
	var/digi_icon_state
	/// Color pallete for static colored underwear, like hearts.
	/// Used so greyscale copies can have the same palette.
	var/greyscale_colors = "#FFFFFF#FFFFFF#FFFFFF"
	/// The layer this sprite accessory should render on
	var/layer = BODY_LAYER
	/// What kind of gender shaping this sprite accessory should use (in case your sprite gets a weird missing pixel in the center)
	var/female_sprite_flags = FEMALE_UNIFORM_FULL

/// Override to return a different icon state given a bodytype or physique
/datum/sprite_accessory/clothing/proc/get_icon_state(physique, bodyshape)
	return icon_state

/**
 * Generate an appearance from this clothing datum
 *
 * * color - if this is NOT a statically colored clothing article and NOT gags, uses this color.
 * * physique - physique of the wearer (male or female)
 * * bodyshape - bodyshape of the wearer (humanoid, digitigrade, etc)
 */
/datum/sprite_accessory/clothing/proc/make_appearance(color = COLOR_WHITE, physique = MALE, bodyshape = BODYSHAPE_HUMANOID)
	var/static/list/cached_icons = list()
	var/use_female = physique == FEMALE && female_sprite_flags
	var/use_digi = digi_icon_state && (bodyshape & BODYSHAPE_DIGITIGRADE)
	var/female_sprite_flags_to_use = female_sprite_flags
	var/icon_state_to_use = get_icon_state(physique, bodyshape)
	if(use_digi && female_sprite_flags_to_use)
		female_sprite_flags_to_use = FEMALE_UNIFORM_TOP_ONLY // No bottom gender shaping for the digi legs

	var/key = "[icon_state_to_use]-[greyscale_config || "ng"]-[use_female]-[use_digi]-[greyscale_colors]"
	var/mutable_appearance/result
	if(cached_icons[key]) // it's already cached
		result = mutable_appearance(icon(cached_icons[key]))

	else if(greyscale_config || use_female || use_digi) // icon ops ahead
		var/icon/created = icon(greyscale_config ? SSgreyscale.GetColoredIconByType(greyscale_config, greyscale_colors) : icon, icon_state_to_use)
		if(use_female)
			created = wear_female_version(icon_state_to_use, icon, female_sprite_flags_to_use)
		if(use_digi)
			var/icon/replacement = icon(SSgreyscale.GetColoredIconByType(/datum/greyscale_config/digitigrade_underwear, greyscale_colors), digi_icon_state)
			created = replace_icon_legs(created, replacement)

		cached_icons[key] = fcopy_rsc(created)
		result = mutable_appearance(created)

	else // no caching necessary
		result = mutable_appearance(icon, icon_state_to_use)

	result.layer = -layer
	result.color = use_static ? null : color

	return result


///////////////////////////
// Underwear Definitions //
///////////////////////////

/datum/sprite_accessory/clothing/underwear
	icon = 'icons/mob/clothing/underwear.dmi'
	use_static = FALSE
	em_block = TRUE
	abstract_type = /datum/sprite_accessory/clothing/underwear

//MALE UNDERWEAR
/datum/sprite_accessory/clothing/underwear/nude
	name = "Nude"
	icon_state = null
	gender = NEUTER

/datum/sprite_accessory/clothing/underwear/nude/make_appearance(mob/living/carbon/human/for_who)
	return

/datum/sprite_accessory/clothing/underwear/male_briefs
	name = "Briefs"
	icon_state = "male_briefs"
	gender = MALE

/datum/sprite_accessory/clothing/underwear/male_boxers
	name = "Boxers"
	icon_state = "male_boxers"
	gender = MALE
	digi_icon_state = "boxers"

/datum/sprite_accessory/clothing/underwear/male_stripe
	name = "Striped Boxers"
	icon_state = "male_stripe"
	gender = MALE
	digi_icon_state = "boxers_stripe"

/datum/sprite_accessory/clothing/underwear/male_midway
	name = "Midway Boxers"
	icon_state = "male_midway"
	gender = MALE
	digi_icon_state = "midway"

/datum/sprite_accessory/clothing/underwear/male_longjohns
	name = "Long Johns"
	icon_state = "male_longjohns"
	gender = MALE
	digi_icon_state = "longjohns"

/datum/sprite_accessory/clothing/underwear/male_kinky
	name = "Jockstrap"
	icon_state = "male_kinky"
	gender = MALE

/datum/sprite_accessory/clothing/underwear/male_mankini
	name = "Mankini"
	icon_state = "male_mankini"
	gender = MALE

/datum/sprite_accessory/clothing/underwear/male_hearts
	name = "Hearts Boxers"
	icon_state = "male_hearts"
	gender = MALE
	use_static = TRUE
	digi_icon_state = "boxers_stripe_threecolor"
	greyscale_colors = "#D62626#EEEEEE#D62626#"

/datum/sprite_accessory/clothing/underwear/male_commie
	name = "Commie Boxers"
	icon_state = "male_commie"
	gender = MALE
	use_static = TRUE
	digi_icon_state = "boxers_stripe_twocolor"
	greyscale_colors = "#D62626#D1B62C#D62626"

/datum/sprite_accessory/clothing/underwear/male_usastripe
	name = "Freedom Boxers"
	icon_state = "male_assblastusa"
	gender = MALE
	use_static = TRUE
	digi_icon_state = "boxers_stripe_threecolor"
	greyscale_colors = "#D62626#EEEEEE#2E26D6"

/datum/sprite_accessory/clothing/underwear/male_uk
	name = "UK Boxers"
	icon_state = "male_uk"
	gender = MALE
	use_static = TRUE
	digi_icon_state = "boxers_stripe_threecolor"
	greyscale_colors = "#D62626#EEEEEE#2E26D6"

//FEMALE UNDERWEAR
/datum/sprite_accessory/clothing/underwear/female_bikini
	name = "Bikini"
	icon_state = "female_bikini"
	gender = FEMALE

/datum/sprite_accessory/clothing/underwear/female_lace
	name = "Lace Bikini"
	icon_state = "female_lace"
	gender = FEMALE

/datum/sprite_accessory/clothing/underwear/female_bralette
	name = "Bralette w/ Boyshorts"
	icon_state = "female_bralette"
	gender = FEMALE
	digi_icon_state = "short_short"

/datum/sprite_accessory/clothing/underwear/female_sport
	name = "Sports Bra w/ Boyshorts"
	icon_state = "female_sport"
	gender = FEMALE
	digi_icon_state = "short"

/datum/sprite_accessory/clothing/underwear/female_thong
	name = "Thong"
	icon_state = "female_thong"
	gender = FEMALE

/datum/sprite_accessory/clothing/underwear/female_strapless
	name = "Strapless Bikini"
	icon_state = "female_strapless"
	gender = FEMALE

/datum/sprite_accessory/clothing/underwear/female_babydoll
	name = "Babydoll"
	icon_state = "female_babydoll"
	gender = FEMALE

/datum/sprite_accessory/clothing/underwear/swimsuit_onepiece
	name = "One-Piece Swimsuit"
	icon_state = "swim_onepiece"
	gender = FEMALE

/datum/sprite_accessory/clothing/underwear/swimsuit_strapless_onepiece
	name = "Strapless One-Piece Swimsuit"
	icon_state = "swim_strapless_onepiece"
	gender = FEMALE

/datum/sprite_accessory/clothing/underwear/swimsuit_twopiece
	name = "Two-Piece Swimsuit"
	icon_state = "swim_twopiece"
	gender = FEMALE
	digi_icon_state = "short_short"

/datum/sprite_accessory/clothing/underwear/swimsuit_strapless_twopiece
	name = "Strapless Two-Piece Swimsuit"
	icon_state = "swim_strapless_twopiece"
	gender = FEMALE
	digi_icon_state = "short_short"

/datum/sprite_accessory/clothing/underwear/swimsuit_stripe
	name = "Strapless Striped Swimsuit"
	icon_state = "swim_stripe"
	gender = FEMALE

/datum/sprite_accessory/clothing/underwear/swimsuit_halter
	name = "Halter Swimsuit"
	icon_state = "swim_halter"
	gender = FEMALE

/datum/sprite_accessory/clothing/underwear/female_white_neko
	name = "Neko Bikini (White)"
	icon_state = "female_neko_white"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/clothing/underwear/female_black_neko
	name = "Neko Bikini (Black)"
	icon_state = "female_neko_black"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/clothing/underwear/female_commie
	name = "Commie Bikini"
	icon_state = "female_commie"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/clothing/underwear/female_usastripe
	name = "Freedom Bikini"
	icon_state = "female_assblastusa"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/clothing/underwear/female_uk
	name = "UK Bikini"
	icon_state = "female_uk"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/clothing/underwear/female_kinky
	name = "Lingerie"
	icon_state = "female_kinky"
	gender = FEMALE
	use_static = TRUE

////////////////////////////
// Undershirt Definitions //
////////////////////////////

/datum/sprite_accessory/clothing/undershirt
	icon = 'icons/mob/clothing/underwear.dmi'
	em_block = TRUE
	abstract_type = /datum/sprite_accessory/clothing/undershirt

/datum/sprite_accessory/clothing/undershirt/nude
	name = "Nude"
	icon_state = null
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/nude/make_appearance(mob/living/carbon/human/for_who)
	return

// please make sure they're sorted alphabetically and categorized

/datum/sprite_accessory/clothing/undershirt/bluejersey
	name = "Jersey (Blue)"
	icon_state = "shirt_bluejersey"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/redjersey
	name = "Jersey (Red)"
	icon_state = "shirt_redjersey"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/bluepolo
	name = "Polo Shirt (Blue)"
	icon_state = "bluepolo"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/grayyellowpolo
	name = "Polo Shirt (Gray-Yellow)"
	icon_state = "grayyellowpolo"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/redpolo
	name = "Polo Shirt (Red)"
	icon_state = "redpolo"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/whitepolo
	name = "Polo Shirt (White)"
	icon_state = "whitepolo"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/alienshirt
	name = "Shirt (Alien)"
	icon_state = "shirt_alien"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/mondmondjaja
	name = "Shirt (Band)"
	icon_state = "band"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/shirt_black
	name = "Shirt (Black)"
	icon_state = "shirt_black"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/blueshirt
	name = "Shirt (Blue)"
	icon_state = "shirt_blue"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/clownshirt
	name = "Shirt (Clown)"
	icon_state = "shirt_clown"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/commie
	name = "Shirt (Commie)"
	icon_state = "shirt_commie"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/greenshirt
	name = "Shirt (Green)"
	icon_state = "shirt_green"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/shirt_grey
	name = "Shirt (Grey)"
	icon_state = "shirt_grey"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/ian
	name = "Shirt (Ian)"
	icon_state = "ian"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/ilovent
	name = "Shirt (I Love NT)"
	icon_state = "ilovent"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/lover
	name = "Shirt (Lover)"
	icon_state = "lover"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/matroska
	name = "Shirt (Matroska)"
	icon_state = "matroska"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/meat
	name = "Shirt (Meat)"
	icon_state = "shirt_meat"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/nano
	name = "Shirt (Nanotrasen)"
	icon_state = "shirt_nano"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/peace
	name = "Shirt (Peace)"
	icon_state = "peace"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/pacman
	name = "Shirt (Pogoman)"
	icon_state = "pogoman"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/question
	name = "Shirt (Question)"
	icon_state = "shirt_question"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/redshirt
	name = "Shirt (Red)"
	icon_state = "shirt_red"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/skull
	name = "Shirt (Skull)"
	icon_state = "shirt_skull"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/ss13
	name = "Shirt (SS13)"
	icon_state = "shirt_ss13"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/stripe
	name = "Shirt (Striped)"
	icon_state = "shirt_stripes"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/tiedye
	name = "Shirt (Tie-dye)"
	icon_state = "shirt_tiedye"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/uk
	name = "Shirt (UK)"
	icon_state = "uk"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/usa
	name = "Shirt (USA)"
	icon_state = "shirt_assblastusa"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/shirt_white
	name = "Shirt (White)"
	icon_state = "shirt_white"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/blackshortsleeve
	name = "Short-sleeved Shirt (Black)"
	icon_state = "blackshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/blueshortsleeve
	name = "Short-sleeved Shirt (Blue)"
	icon_state = "blueshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/greenshortsleeve
	name = "Short-sleeved Shirt (Green)"
	icon_state = "greenshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/purpleshortsleeve
	name = "Short-sleeved Shirt (Purple)"
	icon_state = "purpleshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/whiteshortsleeve
	name = "Short-sleeved Shirt (White)"
	icon_state = "whiteshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/sports_bra
	name = "Sports Bra"
	icon_state = "sports_bra"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/sports_bra2
	name = "Sports Bra (Alt)"
	icon_state = "sports_bra_alt"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/blueshirtsport
	name = "Sports Shirt (Blue)"
	icon_state = "blueshirtsport"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/greenshirtsport
	name = "Sports Shirt (Green)"
	icon_state = "greenshirtsport"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/redshirtsport
	name = "Sports Shirt (Red)"
	icon_state = "redshirtsport"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/tank_black
	name = "Tank Top (Black)"
	icon_state = "tank_black"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/tankfire
	name = "Tank Top (Fire)"
	icon_state = "tank_fire"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/tank_grey
	name = "Tank Top (Grey)"
	icon_state = "tank_grey"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/female_midriff
	name = "Tank Top (Midriff)"
	icon_state = "tank_midriff"
	gender = FEMALE

/datum/sprite_accessory/clothing/undershirt/tank_red
	name = "Tank Top (Red)"
	icon_state = "tank_red"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/tankstripe
	name = "Tank Top (Striped)"
	icon_state = "tank_stripes"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/tank_white
	name = "Tank Top (White)"
	icon_state = "tank_white"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/redtop
	name = "Top (Red)"
	icon_state = "redtop"
	gender = FEMALE

/datum/sprite_accessory/clothing/undershirt/whitetop
	name = "Top (White)"
	icon_state = "whitetop"
	gender = FEMALE

/datum/sprite_accessory/clothing/undershirt/tshirt_blue
	name = "T-Shirt (Blue)"
	icon_state = "blueshirt"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/tshirt_green
	name = "T-Shirt (Green)"
	icon_state = "greenshirt"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/tshirt_red
	name = "T-Shirt (Red)"
	icon_state = "redshirt"
	gender = NEUTER

/datum/sprite_accessory/clothing/undershirt/yellowshirt
	name = "T-Shirt (Yellow)"
	icon_state = "yellowshirt"
	gender = NEUTER

///////////////////////
// Socks Definitions //
///////////////////////

/datum/sprite_accessory/clothing/socks
	icon = 'icons/mob/clothing/underwear.dmi'
	em_block = TRUE
	abstract_type = /datum/sprite_accessory/clothing/socks

/datum/sprite_accessory/clothing/socks/nude
	name = "Nude"
	icon_state = null

/datum/sprite_accessory/clothing/socks/nude/make_appearance(mob/living/carbon/human/for_who)
	return

// please make sure they're sorted alphabetically and categorized

/datum/sprite_accessory/clothing/socks/ace_knee
	name = "Knee-high (Ace)"
	icon_state = "ace_knee"

/datum/sprite_accessory/clothing/socks/bee_knee
	name = "Knee-high (Bee)"
	icon_state = "bee_knee"

/datum/sprite_accessory/clothing/socks/black_knee
	name = "Knee-high (Black)"
	icon_state = "black_knee"

/datum/sprite_accessory/clothing/socks/commie_knee
	name = "Knee-High (Commie)"
	icon_state = "commie_knee"

/datum/sprite_accessory/clothing/socks/usa_knee
	name = "Knee-High (Freedom)"
	icon_state = "assblastusa_knee"

/datum/sprite_accessory/clothing/socks/rainbow_knee
	name = "Knee-high (Rainbow)"
	icon_state = "rainbow_knee"

/datum/sprite_accessory/clothing/socks/striped_knee
	name = "Knee-high (Striped)"
	icon_state = "striped_knee"

/datum/sprite_accessory/clothing/socks/thin_knee
	name = "Knee-high (Thin)"
	icon_state = "thin_knee"

/datum/sprite_accessory/clothing/socks/trans_knee
	name = "Knee-high (Trans)"
	icon_state = "trans_knee"

/datum/sprite_accessory/clothing/socks/uk_knee
	name = "Knee-High (UK)"
	icon_state = "uk_knee"

/datum/sprite_accessory/clothing/socks/white_knee
	name = "Knee-high (White)"
	icon_state = "white_knee"

/datum/sprite_accessory/clothing/socks/fishnet_knee
	name = "Knee-high (Fishnet)"
	icon_state = "fishnet_knee"

/datum/sprite_accessory/clothing/socks/black_norm
	name = "Normal (Black)"
	icon_state = "black_norm"

/datum/sprite_accessory/clothing/socks/white_norm
	name = "Normal (White)"
	icon_state = "white_norm"

/datum/sprite_accessory/clothing/socks/pantyhose
	name = "Pantyhose"
	icon_state = "pantyhose"

/datum/sprite_accessory/clothing/socks/black_short
	name = "Short (Black)"
	icon_state = "black_short"

/datum/sprite_accessory/clothing/socks/white_short
	name = "Short (White)"
	icon_state = "white_short"

/datum/sprite_accessory/clothing/socks/stockings_blue
	name = "Stockings (Blue)"
	icon_state = "stockings_blue"

/datum/sprite_accessory/clothing/socks/stockings_cyan
	name = "Stockings (Cyan)"
	icon_state = "stockings_cyan"

/datum/sprite_accessory/clothing/socks/stockings_dpink
	name = "Stockings (Dark Pink)"
	icon_state = "stockings_dpink"

/datum/sprite_accessory/clothing/socks/stockings_green
	name = "Stockings (Green)"
	icon_state = "stockings_green"

/datum/sprite_accessory/clothing/socks/stockings_orange
	name = "Stockings (Orange)"
	icon_state = "stockings_orange"

/datum/sprite_accessory/clothing/socks/stockings_programmer
	name = "Stockings (Programmer)"
	icon_state = "stockings_lpink"

/datum/sprite_accessory/clothing/socks/stockings_purple
	name = "Stockings (Purple)"
	icon_state = "stockings_purple"

/datum/sprite_accessory/clothing/socks/stockings_yellow
	name = "Stockings (Yellow)"
	icon_state = "stockings_yellow"

/datum/sprite_accessory/clothing/socks/stockings_fishnet
	name = "Stockings (Fishnet)"
	icon_state = "fishnet_full"

/datum/sprite_accessory/clothing/socks/ace_thigh
	name = "Thigh-high (Ace)"
	icon_state = "ace_thigh"

/datum/sprite_accessory/clothing/socks/bee_thigh
	name = "Thigh-high (Bee)"
	icon_state = "bee_thigh"

/datum/sprite_accessory/clothing/socks/black_thigh
	name = "Thigh-high (Black)"
	icon_state = "black_thigh"

/datum/sprite_accessory/clothing/socks/commie_thigh
	name = "Thigh-high (Commie)"
	icon_state = "commie_thigh"

/datum/sprite_accessory/clothing/socks/usa_thigh
	name = "Thigh-high (Freedom)"
	icon_state = "assblastusa_thigh"

/datum/sprite_accessory/clothing/socks/rainbow_thigh
	name = "Thigh-high (Rainbow)"
	icon_state = "rainbow_thigh"

/datum/sprite_accessory/clothing/socks/striped_thigh
	name = "Thigh-high (Striped)"
	icon_state = "striped_thigh"

/datum/sprite_accessory/clothing/socks/thin_thigh
	name = "Thigh-high (Thin)"
	icon_state = "thin_thigh"

/datum/sprite_accessory/clothing/socks/trans_thigh
	name = "Thigh-high (Trans)"
	icon_state = "trans_thigh"

/datum/sprite_accessory/clothing/socks/uk_thigh
	name = "Thigh-high (UK)"
	icon_state = "uk_thigh"

/datum/sprite_accessory/clothing/socks/white_thigh
	name = "Thigh-high (White)"
	icon_state = "white_thigh"

/datum/sprite_accessory/clothing/socks/fishnet_thigh
	name = "Thigh-high (Fishnet)"
	icon_state = "fishnet_thigh"

/datum/sprite_accessory/clothing/socks/thocks
	name = "Thocks"
	icon_state = "thocks"
