/obj/item/clothing/under/costume
	icon = 'icons/obj/clothing/under/costume.dmi'
	worn_icon = 'icons/mob/clothing/under/costume.dmi'

/obj/item/clothing/under/costume/roman
	name = "\improper Roman armor"
	desc = "Ancient Roman armor. Made of metallic and leather straps."
	icon_state = "roman"
	inhand_icon_state = "armor"
	can_adjust = FALSE
	strip_delay = 10 SECONDS
	resistance_flags = NONE

/obj/item/clothing/under/costume/jabroni
	name = "jabroni outfit"
	desc = "The leather club is two sectors down."
	icon_state = "darkholme"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/owl
	name = "owl uniform"
	desc = "A soft brown jumpsuit made of synthetic feathers and strong conviction."
	icon_state = "owl"
	inhand_icon_state = "owl"
	can_adjust = FALSE

/obj/item/clothing/under/costume/griffin
	name = "griffon uniform"
	desc = "A soft brown jumpsuit with a white feather collar made of synthetic feathers and a lust for mayhem."
	icon_state = "griffin"
	can_adjust = FALSE

/obj/item/clothing/under/costume/seifuku
	name = "schoolgirl uniform"
	desc = "It's just like one of my Japanese animes!"
	greyscale_colors = "#942737#4A518D#EBEBEB"
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/seifuku"
	post_init_icon_state = "seifuku"
	greyscale_config_inhand_left = /datum/greyscale_config/seifuku_inhands_left
	greyscale_config_inhand_right = /datum/greyscale_config/seifuku_inhands_right
	inhand_icon_state = "seifuku"
	greyscale_config = /datum/greyscale_config/seifuku
	greyscale_config_worn = /datum/greyscale_config/seifuku/worn
	flags_1 = IS_PLAYER_COLORABLE_1
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alternate_worn_layer = UNDER_SUIT_LAYER

/obj/item/clothing/under/costume/seifuku/red
	icon_state = "/obj/item/clothing/under/costume/seifuku/red"
	greyscale_colors = "#3F4453#BB2E2E#EBEBEB"

/obj/item/clothing/under/costume/seifuku/teal
	icon_state = "/obj/item/clothing/under/costume/seifuku/teal"
	greyscale_colors = "#942737#2BA396#EBEBEB"

/obj/item/clothing/under/costume/seifuku/tan
	icon_state = "/obj/item/clothing/under/costume/seifuku/tan"
	greyscale_colors = "#87502E#B9A56A#EBEBEB"

/obj/item/clothing/under/costume/pirate
	name = "pirate outfit"
	desc = "Yarr."
	icon_state = "pirate"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/soviet
	name = "soviet uniform"
	desc = "For the Motherland!"
	icon_state = "soviet"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/redcoat
	name = "redcoat uniform"
	desc = "Looks old."
	icon_state = "redcoat"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/kilt
	name = "kilt"
	desc = "Includes shoes and plaid."
	icon_state = "kilt"
	inhand_icon_state = "kilt"
	body_parts_covered = CHEST|GROIN|LEGS|FEET
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	can_adjust = FALSE

/obj/item/clothing/under/costume/kilt/highlander
	desc = "You're the only one worthy of this kilt."

/obj/item/clothing/under/costume/kilt/highlander/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HIGHLANDER_TRAIT)

/obj/item/clothing/under/costume/gladiator
	name = "gladiator uniform"
	desc = "Are you not entertained? Is that not why you are here?"
	icon_state = "gladiator"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = NO_FEMALE_UNIFORM
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	can_adjust = FALSE
	resistance_flags = NONE

/obj/item/clothing/under/costume/gladiator/ash_walker
	desc = "This gladiator uniform appears to be covered in ash and fairly dated."
	has_sensor = NO_SENSORS

/obj/item/clothing/under/costume/maid
	name = "maid costume"
	desc = "Maid in China."
	greyscale_colors = "#494955#EEEEEE"
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/maid"
	post_init_icon_state = "maid"
	greyscale_config = /datum/greyscale_config/maid
	greyscale_config_worn = /datum/greyscale_config/maid/worn
	greyscale_config_inhand_left = /datum/greyscale_config/maid_inhands_left
	greyscale_config_inhand_right = /datum/greyscale_config/maid_inhands_right
	inhand_icon_state = "maid"
	flags_1 = IS_PLAYER_COLORABLE_1
	body_parts_covered = CHEST|GROIN
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	alternate_worn_layer = UNDER_SUIT_LAYER
	can_adjust = FALSE

/obj/item/clothing/under/costume/geisha
	name = "geisha suit"
	desc = "Cute space ninja senpai not included."
	icon_state = "geisha"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE

/obj/item/clothing/under/costume/yukata
	name = "black yukata"
	desc = "A comfortable black cotton yukata inspired by traditional designs, perfect for a non-formal setting."
	icon_state = "yukata1"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/costume/yukata/green
	name = "green yukata"
	desc = "A comfortable green cotton yukata inspired by traditional designs, perfect for a non-formal setting."
	icon_state = "yukata2"

/obj/item/clothing/under/costume/yukata/white
	name = "white yukata"
	desc = "A comfortable white cotton yukata inspired by traditional designs, perfect for a non-formal setting."
	icon_state = "yukata3"

/obj/item/clothing/under/costume/kimono
	name = "black kimono"
	desc = "A luxurious black silk kimono with traditional flair, ideal for elegant festive occasions."
	icon_state = "kimono1"
	inhand_icon_state = "yukata1"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/costume/kimono/red
	name = "red kimono"
	desc = "A luxurious red silk kimono with traditional flair, ideal for elegant festive occasions."
	icon_state = "kimono2"
	inhand_icon_state = "kimono2"

/obj/item/clothing/under/costume/kimono/purple
	name = "purple kimono"
	desc = "A luxurious purple silk kimono with traditional flair, ideal for elegant festive occasions."
	icon_state = "kimono3"
	inhand_icon_state = "kimono3"

/obj/item/clothing/under/costume/villain
	name = "villain suit"
	desc = "A change of wardrobe is necessary if you ever want to catch a real superhero."
	icon_state = "villain"
	can_adjust = FALSE

/obj/item/clothing/under/costume/sailor
	name = "sailor suit"
	desc = "Skipper's in the wardroom drinkin' gin."
	icon_state = "sailor"
	inhand_icon_state = "b_suit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/singer
	desc = "Just looking at this makes you want to sing."
	body_parts_covered = CHEST|GROIN|ARMS
	alternate_worn_layer = ABOVE_SHOES_LAYER
	can_adjust = FALSE

/obj/item/clothing/under/costume/singer/yellow
	name = "yellow performer's outfit"
	icon_state = "ysing"
	inhand_icon_state = null
	female_sprite_flags = NO_FEMALE_UNIFORM

/obj/item/clothing/under/costume/singer/blue
	name = "blue performer's outfit"
	icon_state = "bsing"
	inhand_icon_state = null
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/costume/mummy
	name = "mummy wrapping"
	desc = "Return the slab or suffer my stale references."
	icon_state = "mummy"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE

/obj/item/clothing/under/costume/scarecrow
	name = "scarecrow clothes"
	desc = "Perfect camouflage for hiding in botany."
	icon_state = "scarecrow"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE

/obj/item/clothing/under/costume/draculass
	name = "draculass coat"
	desc = "A dress inspired by the ancient \"Victorian\" era."
	icon_state = "draculass"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	can_adjust = FALSE

/obj/item/clothing/under/costume/drfreeze
	name = "doctor freeze's jumpsuit"
	desc = "A modified scientist jumpsuit to look extra cool."
	icon_state = "drfreeze"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/lobster
	name = "foam lobster suit"
	desc = "Who beheaded the college mascot?"
	icon_state = "lobster"
	inhand_icon_state = null
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE

/obj/item/clothing/under/costume/gondola
	name = "gondola hide suit"
	desc = "Now you're cooking."
	icon_state = "gondola"
	inhand_icon_state = "lb_suit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/skeleton
	name = "skeleton jumpsuit"
	desc = "A black jumpsuit with a white bone pattern printed on it. Spooky!"
	icon_state = "skeleton"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE

/obj/item/clothing/under/costume/mech_suit
	name = "mech pilot's suit"
	desc = "A mech pilot's suit. Might make your butt look big."
	icon_state = "red_mech_suit"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	female_sprite_flags = NO_FEMALE_UNIFORM
	alternate_worn_layer = GLOVES_LAYER //covers hands but gloves can go over it. This is how these things work in my head.
	can_adjust = FALSE

	unique_reskin = list(
						"Red" = "red_mech_suit",
						"White" = "white_mech_suit",
						"Blue" = "blue_mech_suit",
						"Black" = "black_mech_suit",
						)


/obj/item/clothing/under/costume/russian_officer
	name = "\improper Russian officer's uniform"
	desc = "The latest in fashionable russian outfits."
	icon = 'icons/obj/clothing/under/security.dmi'
	icon_state = "hostanclothes"
	inhand_icon_state = null
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	alt_covers_chest = TRUE
	armor_type = /datum/armor/clothing_under/costume_russian_officer
	strip_delay = 5 SECONDS
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	can_adjust = FALSE

/datum/armor/clothing_under/costume_russian_officer
	melee = 10
	fire = 30
	acid = 30

/obj/item/clothing/under/costume/buttondown
	gender = PLURAL
	female_sprite_flags = NO_FEMALE_UNIFORM
	custom_price = PAYCHECK_CREW
	icon = 'icons/obj/clothing/under/shorts_pants_shirts.dmi'
	worn_icon = 'icons/mob/clothing/under/shorts_pants_shirts.dmi'
	species_exception = list(/datum/species/golem)
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/costume/buttondown/slacks
	name = "button-down shirt with slacks"
	desc = "A fancy button-down shirt with slacks."
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/buttondown/slacks"
	post_init_icon_state = "buttondown_slacks"
	greyscale_config = /datum/greyscale_config/buttondown_slacks
	greyscale_config_worn = /datum/greyscale_config/buttondown_slacks/worn
	greyscale_colors = "#EEEEEE#EE8E2E#222227#D8D39C"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/costume/buttondown/slacks/service //preset one to be a formal white shirt and black pants
	icon_state = "/obj/item/clothing/under/costume/buttondown/slacks/service"
	greyscale_colors = "#EEEEEE#CBDBFC#17171B#222227"

/obj/item/clothing/under/costume/buttondown/shorts
	name = "button-down shirt with shorts"
	desc = "A fancy button-down shirt with shorts."
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/buttondown/shorts"
	post_init_icon_state = "buttondown_shorts"
	greyscale_config = /datum/greyscale_config/buttondown_shorts
	greyscale_config_worn = /datum/greyscale_config/buttondown_shorts/worn
	greyscale_colors = "#EEEEEE#EE8E2E#222227#D8D39C"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/costume/buttondown/skirt
	name = "button-down shirt with skirt"
	desc = "A fancy button-down shirt with skirt."
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/buttondown/skirt"
	post_init_icon_state = "buttondown_skirt"
	greyscale_config = /datum/greyscale_config/buttondown_skirt
	greyscale_config_worn = /datum/greyscale_config/buttondown_skirt/worn
	greyscale_colors = "#EEEEEE#EE8E2E#222227#D8D39C"
	body_parts_covered = CHEST|GROIN|ARMS
	flags_1 = IS_PLAYER_COLORABLE_1
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/costume/buttondown/skirt/service //preset one to be a formal white shirt and black skirt
	icon_state = "/obj/item/clothing/under/costume/buttondown/skirt/service"
	greyscale_colors = "#EEEEEE#CBDBFC#17171B#222227"

/obj/item/clothing/under/costume/jackbros
	name = "jack bros outfit"
	desc = "For when it's time to hee some hos."
	icon_state = "JackFrostUniform"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/deckers
	name = "deckers outfit"
	icon_state = "decker_jumpsuit"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/football_suit
	name = "football uniform"
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/football_suit"
	post_init_icon_state = "football_suit"
	can_adjust = FALSE
	greyscale_config = /datum/greyscale_config/football_suit
	greyscale_config_worn = /datum/greyscale_config/football_suit/worn
	greyscale_colors = "#D74722"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/costume/swagoutfit
	name = "Swag outfit"
	desc = "Why don't you go secure some bitches?"
	icon_state = "SwagOutfit"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/referee
	name = "referee uniform"
	desc = "A standard black and white striped uniform to signal authority."
	icon_state = "referee"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/joker
	name = "comedian suit"
	desc = "The worst part of having a mental illness is people expect you to behave as if you don't."
	icon_state = "joker"
	can_adjust = FALSE

/obj/item/clothing/under/costume/yuri
	name = "yuri initiate jumpsuit"
	icon_state = "yuri_uniform"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/dutch
	name = "dutch's suit"
	desc = "You can feel a <b>god damn plan</b> coming on."
	icon_state = "DutchUniform"
	inhand_icon_state = null
	can_adjust = FALSE

// For the nuke-ops cowboy fit. Sadly no Lone Ranger fit & I don't wanna bloat costume files further.
/obj/item/clothing/under/costume/dutch/syndicate
	desc = "You can feel a <b>god damn plan</b> coming on, and the armor lining in this suit'll do wonders in makin' it work."
	armor_type = /datum/armor/clothing_under/syndicate

/obj/item/clothing/under/costume/osi
	name = "O.S.I. jumpsuit"
	icon_state = "osi_jumpsuit"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/tmc
	name = "Lost MC clothing"
	icon_state = "tmc_jumpsuit"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/gi
	name = "martial gi"
	desc = "Assistant, nukie, whatever. You can beat anyone; it's called hard work!"
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/gi"
	post_init_icon_state = "martial_arts_gi"
	greyscale_config = /datum/greyscale_config/gi
	greyscale_config_worn = /datum/greyscale_config/gi/worn
	greyscale_colors = "#f1eeee#000000"
	flags_1 = IS_PLAYER_COLORABLE_1
	inhand_icon_state = null
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE

/obj/item/clothing/under/costume/gi/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/gags_recolorable)
	update_icon(UPDATE_OVERLAYS)

/obj/item/clothing/under/costume/gi/goku
	name = "sacred gi"
	desc = "Created by a man who touched the hearts and lives of many."
	icon_state = "/obj/item/clothing/under/costume/gi/goku"
	post_init_icon_state = "martial_arts_gi_goku"
	greyscale_colors = "#f89925#3e6dd7"

/obj/item/clothing/under/costume/traditional
	name = "traditional suit"
	desc = "A full, vibrantly coloured suit. Likely with traditional purposes. Maybe the colours represent a family, clan, or rank, who knows."
	icon_state = "tradition"
	inhand_icon_state = null
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE

/obj/item/clothing/under/costume/loincloth
	name = "leather loincloth"
	desc = "Just a piece of leather to cover private areas. Itchy to the touch. Whoever made this must have been desperate, or savage."
	icon_state = "loincloth"
	inhand_icon_state = null
	body_parts_covered = GROIN
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/costume/henchmen
	name = "henchmen jumpsuit"
	desc = "A very gaudy jumpsuit for a proper Henchman. Guild regulations, you understand."
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	worn_icon = 'icons/mob/clothing/under/syndicate.dmi'
	icon_state = "henchmen"
	inhand_icon_state = null
	can_adjust = FALSE
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS|HEAD
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEEARS|HIDEEYES|HIDEHAIR

/obj/item/clothing/under/costume/gamberson
	name = "re-enactor's gambeson"
	desc = "A colorful set of clothes made to look like a medieval gambeson."
	icon_state = "gamberson"
	inhand_icon_state = null
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE

/obj/item/clothing/under/costume/gamberson/military
	name = "swordsman's gambeson"
	desc = "A padded medieval gambeson. Has enough woolen layers to dull a strike from any small weapon."
	armor_type = /datum/armor/clothing_under/rank_security
	has_sensor = NO_SENSORS

