/obj/item/clothing/under/costume
	icon = 'icons/obj/clothing/under/costume.dmi'
	worn_icon = 'icons/mob/clothing/under/costume.dmi'

/obj/item/clothing/under/costume/roman
	name = "\improper Roman armor"
	desc = "Ancient Roman armor. Made of metallic and leather straps."
	icon_state = "roman"
	inhand_icon_state = "armor"
	can_adjust = FALSE
	strip_delay = 100
	resistance_flags = NONE

/obj/item/clothing/under/costume/jabroni
	name = "jabroni outfit"
	desc = "The leather club is two sectors down."
	icon_state = "darkholme"
	inhand_icon_state = "darkholme"
	can_adjust = FALSE

/obj/item/clothing/under/costume/owl
	name = "owl uniform"
	desc = "A soft brown jumpsuit made of synthetic feathers and strong conviction."
	icon_state = "owl"
	can_adjust = FALSE

/obj/item/clothing/under/costume/griffin
	name = "griffon uniform"
	desc = "A soft brown jumpsuit with a white feather collar made of synthetic feathers and a lust for mayhem."
	icon_state = "griffin"
	can_adjust = FALSE

/obj/item/clothing/under/costume/schoolgirl
	name = "blue schoolgirl uniform"
	desc = "It's just like one of my Japanese animes!"
	icon_state = "schoolgirl"
	inhand_icon_state = "schoolgirl"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/costume/schoolgirl/red
	name = "red schoolgirl uniform"
	icon_state = "schoolgirlred"
	inhand_icon_state = "schoolgirlred"

/obj/item/clothing/under/costume/schoolgirl/green
	name = "green schoolgirl uniform"
	icon_state = "schoolgirlgreen"
	inhand_icon_state = "schoolgirlgreen"

/obj/item/clothing/under/costume/schoolgirl/orange
	name = "orange schoolgirl uniform"
	icon_state = "schoolgirlorange"
	inhand_icon_state = "schoolgirlorange"

/obj/item/clothing/under/costume/pirate
	name = "pirate outfit"
	desc = "Yarr."
	icon_state = "pirate"
	inhand_icon_state = "pirate"
	can_adjust = FALSE

/obj/item/clothing/under/costume/soviet
	name = "soviet uniform"
	desc = "For the Motherland!"
	icon_state = "soviet"
	inhand_icon_state = "soviet"
	can_adjust = FALSE

/obj/item/clothing/under/costume/redcoat
	name = "redcoat uniform"
	desc = "Looks old."
	icon_state = "redcoat"
	inhand_icon_state = "redcoat"
	can_adjust = FALSE

/obj/item/clothing/under/costume/kilt
	name = "kilt"
	desc = "Includes shoes and plaid."
	icon_state = "kilt"
	inhand_icon_state = "kilt"
	body_parts_covered = CHEST|GROIN|LEGS|FEET
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/costume/kilt/highlander
	desc = "You're the only one worthy of this kilt."

/obj/item/clothing/under/costume/kilt/highlander/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HIGHLANDER)

/obj/item/clothing/under/costume/gladiator
	name = "gladiator uniform"
	desc = "Are you not entertained? Is that not why you are here?"
	icon_state = "gladiator"
	inhand_icon_state = "gladiator"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE

/obj/item/clothing/under/costume/gladiator/ash_walker
	desc = "This gladiator uniform appears to be covered in ash and fairly dated."
	has_sensor = NO_SENSORS

/obj/item/clothing/under/costume/maid
	name = "maid costume"
	desc = "Maid in China."
	icon_state = "maid"
	inhand_icon_state = "maid"
	body_parts_covered = CHEST|GROIN
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/costume/maid/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/accessory/maidapron/A = new (src)
	attach_accessory(A)

/obj/item/clothing/under/costume/geisha
	name = "geisha suit"
	desc = "Cute space ninja senpai not included."
	icon_state = "geisha"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE

/obj/item/clothing/under/costume/villain
	name = "villain suit"
	desc = "A change of wardrobe is necessary if you ever want to catch a real superhero."
	icon_state = "villain"
	can_adjust = FALSE

/obj/item/clothing/under/costume/sailor
	name = "sailor suit"
	desc = "Skipper's in the wardroom drinkin gin'."
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
	inhand_icon_state = "ysing"
	fitted = NO_FEMALE_UNIFORM

/obj/item/clothing/under/costume/singer/blue
	name = "blue performer's outfit"
	icon_state = "bsing"
	inhand_icon_state = "bsing"
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/costume/mummy
	name = "mummy wrapping"
	desc = "Return the slab or suffer my stale references."
	icon_state = "mummy"
	inhand_icon_state = "mummy"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE

/obj/item/clothing/under/costume/scarecrow
	name = "scarecrow clothes"
	desc = "Perfect camouflage for hiding in botany."
	icon_state = "scarecrow"
	inhand_icon_state = "scarecrow"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE

/obj/item/clothing/under/costume/draculass
	name = "draculass coat"
	desc = "A dress inspired by the ancient \"Victorian\" era."
	icon_state = "draculass"
	inhand_icon_state = "draculass"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/costume/drfreeze
	name = "doctor freeze's jumpsuit"
	desc = "A modified scientist jumpsuit to look extra cool."
	icon_state = "drfreeze"
	inhand_icon_state = "drfreeze"
	can_adjust = FALSE

/obj/item/clothing/under/costume/lobster
	name = "foam lobster suit"
	desc = "Who beheaded the college mascot?"
	icon_state = "lobster"
	inhand_icon_state = "lobster"
	fitted = NO_FEMALE_UNIFORM
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
	inhand_icon_state = "skeleton"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE

/obj/item/clothing/under/costume/mech_suit
	name = "red mech pilot's suit"
	desc = "A red mech pilot's suit. Might make your butt look big."
	icon_state = "red_mech_suit"
	inhand_icon_state = "red_mech_suit"
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	fitted = NO_FEMALE_UNIFORM
	alternate_worn_layer = GLOVES_LAYER //covers hands but gloves can go over it. This is how these things work in my head.
	can_adjust = FALSE

/obj/item/clothing/under/costume/mech_suit/white
	name = "white mech pilot's suit"
	desc = "A white mech pilot's suit. Very fetching."
	icon_state = "white_mech_suit"
	inhand_icon_state = "white_mech_suit"

/obj/item/clothing/under/costume/mech_suit/blue
	name = "blue mech pilot's suit"
	desc = "A blue mech pilot's suit. For the more reluctant mech pilots."
	icon_state = "blue_mech_suit"
	inhand_icon_state = "blue_mech_suit"

/obj/item/clothing/under/costume/russian_officer
	name = "\improper Russian officer's uniform"
	desc = "The latest in fashionable russian outfits."
	icon = 'icons/obj/clothing/under/security.dmi'
	icon_state = "hostanclothes"
	inhand_icon_state = "hostanclothes"
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	alt_covers_chest = TRUE
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 30, ACID = 30)
	strip_delay = 50
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	can_adjust = FALSE

/obj/item/clothing/under/costume/jackbros
	name = "jack bros outfit"
	desc = "For when it's time to hee some hos."
	icon_state = "JackFrostUniform"
	inhand_icon_state = "JackFrostUniform"
	can_adjust = FALSE

/obj/item/clothing/under/costume/yakuza
	name = "tojo clan pants"
	desc = "For those long nights under the traffic cone."
	icon_state = "MajimaPants"
	inhand_icon_state = "MajimaPants"
	can_adjust = FALSE

/obj/item/clothing/under/costume/dutch
	name = "dutch's suit"
	desc = "You can feel a <b>god damn plan</b> coming on."
	icon_state = "DutchUniform"
	inhand_icon_state = "DutchUniform"
	can_adjust = FALSE

/obj/item/clothing/under/costume/irs
	name = "internal revenue service outfit"
	icon_state = "irs_jumpsuit"
	inhand_icon_state = "irs_jumpsuit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/osi
	name = "O.S.I. jumpsuit"
	icon_state = "osi_jumpsuit"
	inhand_icon_state = "osi_jumpsuit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/tmc
	name = "Lost MC clothing"
	icon_state = "tmc_jumpsuit"
	inhand_icon_state = "tmc_jumpsuit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/pg
	name = "powder ganger prison jumpsuit"
	icon_state = "pg_jumpsuit"
	inhand_icon_state = "pg_jumpsuit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/driscoll
	name = "O'Driscoll outfit"
	icon_state = "driscoll_jumpsuit"
	inhand_icon_state = "driscoll_jumpsuit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/deckers
	name = "deckers outfit"
	icon_state = "decker_jumpsuit"
	inhand_icon_state = "decker_jumpsuit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/morningstar
	name = "Morningstar suit"
	icon_state = "morningstar_jumpsuit"
	inhand_icon_state = "morningstar_jumpsuit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/saints
	name = "Saints outfit"
	icon_state = "saints_jumpsuit"
	inhand_icon_state = "saints_jumpsuit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/phantom
	name = "Phantom Thief outfit"
	icon_state = "phantom_jumpsuit"
	inhand_icon_state = "phantom_jumpsuit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/allies
	name = "allies tanktop"
	icon_state = "allies_uniform"
	inhand_icon_state = "allies_uniform"
	can_adjust = FALSE

/obj/item/clothing/under/costume/soviet_families
	name = "soviet conscript uniform"
	icon_state = "soviet_uniform"
	inhand_icon_state = "soviet_uniform"
	can_adjust = FALSE

/obj/item/clothing/under/costume/yuri
	name = "yuri initiate jumpsuit"
	icon_state = "yuri_uniform"
	inhand_icon_state = "yuri_uniform"
	can_adjust = FALSE

/obj/item/clothing/under/costume/sybil_slickers
	name = "sybil slickers uniform"
	icon_state = "football_blue"
	inhand_icon_state = "football_blue"
	can_adjust = FALSE

/obj/item/clothing/under/costume/basil_boys
	name = "basil boys uniform"
	icon_state = "football_red"
	inhand_icon_state = "football_red"
	can_adjust = FALSE

/obj/item/clothing/under/costume/swagoutfit
	name = "Swag outfit"
	desc = "Why don't you go secure some bitches?"
	icon_state = "SwagOutfit"
	inhand_icon_state = "SwagOutfit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/referee
	name = "referee uniform"
	desc = "A standard black and white striped uniform to signal authority."
	icon_state = "referee"
	inhand_icon_state = "referee"
	can_adjust = FALSE
