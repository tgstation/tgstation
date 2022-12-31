/obj/item/clothing/under/bodysash
	name = "assistant sash"
	desc = "A simple assistant sash, slung from shoulder to hip."
	icon = 'icons/obj/clothing/under/beefclothing.dmi'
	worn_icon =  'icons/mob/clothing/under/beefclothing_worn.dmi'
	icon_state = "assistant" // Inventory Icon
	inhand_icon_state = "sash" // In-hand Icon
	can_adjust = FALSE
	body_parts_covered = CHEST

//Captain
/obj/item/clothing/under/bodysash/captain
	name = "captain's sash"
	desc = "A simple assistant sash, slung from shoulder to hip."
	icon_state = "captain_beef"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0, WOUND = 15)
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

//Security
/obj/item/clothing/under/bodysash/security
	name = "security's sash"
	desc = "A \"tactical\" security sash for officers."
	icon_state = "security"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 30, ACID = 30, WOUND = 10)
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/bodysash/security/hos
	name = "head of security's sash"
	desc = "A \"tactical\" security sash for the \"Head of Security\"."
	icon_state = "hos"

/obj/item/clothing/under/bodysash/security/warden
	name = "warden's sash"
	desc = "A \"tactical\" security sash for wardens."
	icon_state = "warden"

/obj/item/clothing/under/bodysash/security/detective
	name = "detective's sash"
	desc = "A sash for someone that mean business."
	icon_state = "detective"

/obj/item/clothing/under/bodysash/security/deputy
	name = "deputy's sash"
	desc = "An awe-inspiring \"tactical\" sash; because safety never takes a holiday."
	icon_state = "deputy"

//Medical
/obj/item/clothing/under/bodysash/medical
	name = "medical's sash"
	desc = "A doctor's sash, It's made of a special fiber that provides minor protection against biohazards.."
	icon_state = "medical"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 0, ACID = 0)

/obj/item/clothing/under/bodysash/medical/cmo
	name = "chief medical officer's sash"
	desc = "It's a sash worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	icon_state = "cmo"

/obj/item/clothing/under/bodysash/medical/chemist
	name = "chemist's sash"
	desc = "A chemist's sash. It's made of a special fiber that gives special protection against biohazards."
	icon_state = "chemist"

/obj/item/clothing/under/bodysash/medical/virologist
	name = "virologist's sash"
	desc = "A virologist's sash. It's made of a special fiber that gives special protection against biohazards."
	icon_state = "virologist"

/obj/item/clothing/under/bodysash/medical/paramedic
	name = "paramedic's sash"
	desc = "A paramedic's sash. It's made of a special fiber that provides minor protection against biohazards."
	icon_state = "paramedic"

//Engineering
/obj/item/clothing/under/bodysash/engineer
	name = "engineer's sash"
	desc = "It's an orange high visibility sash worn by engineers."
	icon_state = "engineer"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 60, ACID = 20)
	resistance_flags = NONE

/obj/item/clothing/under/bodysash/engineer/ce
	name = "chief engineer's sash"
	desc = "It's a high visibility sash given to those engineers insane enough to achieve the rank of \"Chief Engineer\"."
	icon_state = "ce"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 80, ACID = 40)

/obj/item/clothing/under/bodysash/engineer/atmos
	name = "atmospherics technician's sash"
	desc = "It's a sash worn by atmospheric technicians. It has minor protection from fire."
	icon_state = "atmos"

//Science
/obj/item/clothing/under/bodysash/rd
	name = "research director's sash"
	desc = "It's a sash worn by those with the know-how to achieve the position of \"Research Director\". Its fabric provides minor protection from biological contaminants."
	icon_state = "rd"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 10, FIRE = 0, ACID = 35)

/obj/item/clothing/under/bodysash/scientist
	name = "scientist's sash"
	desc = "It's made of a special fiber that provides minor \"protection\" against explosives. It has markings that denote the wearer as a scientist."
	icon_state = "scientist"

/obj/item/clothing/under/bodysash/roboticist
	name = "roboticist's sash"
	desc = "It's a slimming black with reinforced seams; great for industrial work."
	icon_state = "roboticist"
	resistance_flags = NONE

/obj/item/clothing/under/bodysash/geneticist
	name = "geneticist's sash"
	desc = "A geneticist's sash. It's made of a special fiber that gives special protection against biohazards."
	icon_state = "geneticist"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 0, ACID = 0)

//Supply/Civilian
/obj/item/clothing/under/bodysash/hop
	name = "head of personnel's sash"
	desc = "It's a sash worn by someone who works in the position of \"Head of Personnel\"."
	icon_state = "hop"

/obj/item/clothing/under/bodysash/qm
	name = "quarter master's sash"
	desc = "It's a sash worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm"

/obj/item/clothing/under/bodysash/cargo
	name = "cargo technician's sash"
	desc = "Saaaaashes! They're comfy and easy to wear!"
	icon_state = "cargo"

/obj/item/clothing/under/bodysash/miner
	name = "shaft miner's sash"
	desc = "It's a snappy sash. It is very dirty."
	icon_state = "miner"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 80, ACID = 0, WOUND = 10)
	resistance_flags = NONE

/obj/item/clothing/under/bodysash/clown
	name = "clown's sash"
	desc = "<i>'HONK!'</i>"
	icon_state = "clown"

/obj/item/clothing/under/bodysash/clown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg' = 1), 50, falloff_exponent = 20)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CLOWN, CELL_VIRUS_TABLE_GENERIC, rand(2,3), 0)

/obj/item/clothing/under/bodysash/mime
	name = "mime's sash"
	desc = "A not very colorful sash"
	icon_state = "mime"

/obj/item/clothing/under/bodysash/prisoner
	name = "prisoner's sash"
	desc = "It's standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "prisoner"
	has_sensor = LOCKED_SENSORS
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/bodysash/cook
	name = "cook's sash"
	desc = "A sash which is given only to the most <b>hardcore</b> cooks in space."
	icon_state = "cook"

/obj/item/clothing/under/bodysash/bartender
	name = "bartender's sash"
	desc = "A simple bartender sash without any flair, slung from shoulder to hip."
	icon_state = "bartender"

/obj/item/clothing/under/bodysash/chaplain
	name = "chaplain's sash"
	desc = "A simple religious sash, slung from shoulder to hip."
	icon_state = "chaplain"

/obj/item/clothing/under/bodysash/curator
	name = "curator's sash"
	desc = "A simple librarian sash, slung from shoulder to hip."
	icon_state = "curator"

/obj/item/clothing/under/bodysash/lawyer
	name = "lawyer's sash"
	desc = "A simple lawyer sash, slung from shoulder to hip."
	icon_state = "lawyer"

/obj/item/clothing/under/bodysash/botanist
	name = "botanist's sash"
	desc = "It's a sash designed to protect against minor plant-related hazards."
	icon_state = "botanist"

/obj/item/clothing/under/bodysash/janitor
	name = "janitor's sash"
	desc = "A janitor sash, slung from shoulder to hip. It has minor protection from biohazards."
	icon_state = "janitor"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 0, ACID = 0)

/obj/item/clothing/under/bodysash/psychologist
	name = "psychologist's sash"
	desc = "A simple psychologist sash, slung from shoulder to hip."
	icon_state = "psychologist"

//CentCom
/obj/item/clothing/under/bodysash/centcom
	name = "centcom's sash"
	desc = "It's a sash worn by CentCom's highest-tier Commanders."
	icon_state = "centcom"

/obj/item/clothing/under/bodysash/official
	name = "official's sash"
	desc = "A casual, yet refined green sash, used by CentCom Officials. It has a fragrance of aloe."
	icon_state = "official"

/obj/item/clothing/under/bodysash/intern
	name = "intern's sash"
	desc = "It's a sash worn by those interning for CentCom."
	icon_state = "intern"

/obj/item/clothing/under/bodysash/civilian
	name = "civilian's sash"
	desc = "A simple civilian sash, slung from shoulder to hip."
	icon_state = "civilian"

///Misc
/obj/item/clothing/under/bodysash/russia
	name = "Russian sash"
	desc = "A simple Russian sash, slung from shoulder to hip."
	icon_state = "russia"
