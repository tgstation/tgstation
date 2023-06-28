/obj/item/clothing/gloves/color/plasmaman
	desc = "Covers up those scandalous boney hands."
	name = "plasma envirogloves"
	icon_state = "plasmaman"
	greyscale_colors = "#913b00"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor_type = /datum/armor/color_plasmaman

/datum/armor/color_plasmaman
	bio = 100
	fire = 95
	acid = 95

/obj/item/clothing/gloves/color/plasmaman/black
	name = "black envirogloves"
	icon_state = "blackplasma"
	greyscale_colors = "#2f2e31"

/obj/item/clothing/gloves/color/plasmaman/plasmanitrile
	name = "nitrile envirogloves"
	desc = "Pricy nitrile gloves made for plasmamen."
	icon_state = "nitrile"
	greyscale_colors = "#913b00"
	clothing_traits = list(TRAIT_QUICKER_CARRY, TRAIT_FASTMED)

/obj/item/clothing/gloves/color/plasmaman/white
	name = "white envirogloves"
	icon_state = "whiteplasma"
	greyscale_colors = "#ffffff"

/obj/item/clothing/gloves/color/plasmaman/robot
	name = "roboticist envirogloves"
	icon_state = "robotplasma"
	greyscale_colors = "#932500"

/obj/item/clothing/gloves/color/plasmaman/janny
	name = "janitor envirogloves"
	icon_state = "jannyplasma"
	greyscale_colors = "#883391"

/obj/item/clothing/gloves/color/plasmaman/cargo
	name = "cargo envirogloves"
	icon_state = "cargoplasma"
	greyscale_colors = "#bb9042"

/obj/item/clothing/gloves/color/plasmaman/engineer
	name = "engineering envirogloves"
	icon_state = "engieplasma"
	greyscale_colors = "#d75600"
	siemens_coefficient = 0

/obj/item/clothing/gloves/color/plasmaman/atmos
	name = "atmos envirogloves"
	icon_state = "atmosplasma"
	greyscale_colors = "#00a5ff"

/obj/item/clothing/gloves/color/plasmaman/explorer
	name = "explorer envirogloves"
	icon_state = "explorerplasma"
	greyscale_colors = "#47453d"

/obj/item/clothing/gloves/color/plasmaman/botanic_leather
	name = "botany envirogloves"
	desc = "These leather gloves protect your boney hands against thorns, barbs, prickles, spikes and other harmful objects of floral origin."
	icon_state = "botanyplasma"
	greyscale_colors = "#3164ff"
	clothing_traits = list(TRAIT_PLANT_SAFE)

/obj/item/clothing/gloves/color/plasmaman/prototype
	name = "prototype envirogloves"
	icon_state = "protoplasma"
	greyscale_colors = "#911801"

/obj/item/clothing/gloves/color/plasmaman/clown
	name = "clown envirogloves"
	icon_state = "clownplasma"
	greyscale_colors = "#ff0000"

/obj/item/clothing/gloves/color/plasmaman/head_of_personnel
	name = "head of personnel's envirogloves"
	desc = "Covers up those scandalous, bony hands. Appears to be an attempt at making a replica of the captain's gloves."
	icon_state = "hopplasma"
	inhand_icon_state = null
	greyscale_colors = null

/obj/item/clothing/gloves/color/plasmaman/chief_engineer
	name = "chief engineer's envirogloves"
	icon_state = "ceplasma"
	greyscale_colors = "#45ff00"
	siemens_coefficient = 0

/obj/item/clothing/gloves/color/plasmaman/research_director
	name = "research director's envirogloves"
	icon_state = "rdplasma"
	greyscale_colors = "#64008a"

/obj/item/clothing/gloves/color/plasmaman/centcom_commander
	name = "CentCom commander envirogloves"
	icon_state = "commanderplasma"
	greyscale_colors = "#009100"

/obj/item/clothing/gloves/color/plasmaman/centcom_official
	name = "CentCom official envirogloves"
	icon_state = "officialplasma"
	greyscale_colors = "#10af77"

/obj/item/clothing/gloves/color/plasmaman/centcom_intern
	name = "CentCom intern envirogloves"
	icon_state = "internplasma"
	greyscale_colors = "#00974b"

/obj/item/clothing/gloves/color/plasmaman/radio
	name = "translation envirogloves"
	desc = "Allows the less vocally-capable plasmamen to use sign language over comms."
	icon_state = "radio_gplasma"
	inhand_icon_state = null
	greyscale_colors = null
	worn_icon_state = "radio_g"
	clothing_traits = list(TRAIT_CAN_SIGN_ON_COMMS)
