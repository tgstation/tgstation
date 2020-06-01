/obj/item/clothing/gloves/diowristbands
	name = "Orange Wristbands"
	desc = "You feel like if you were to put these on you'd have an urge to rant on about futility and uselessness."
	fulp_item = TRUE
	icon = 'icons/Fulpicons/dio_clothing.dmi'
	icon_state = "diobands"
	worn_icon = 'icons/mob/clothing_dio.dmi'

/obj/item/clothing/head/dioband
	name = "Green-heart Headband"
	desc = "Mysterious headband that most certainly belongs to a powerful stand user."
	fulp_item = TRUE
	icon = 'icons/Fulpicons/dio_clothing.dmi'
	icon_state = "dio_headband"
	worn_icon = 'icons/mob/clothing_dio.dmi'
	clothing_flags = SNUG_FIT
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 100)

/obj/item/clothing/shoes/dioshoes
	name = "Fabulous Shoes"
	desc = "Odd-looking shoes that are surprisingly comfortable despite their strange shape."
	fulp_item = TRUE
	icon = 'icons/Fulpicons/dio_clothing.dmi'
	icon_state = "dio_shoes"
	worn_icon = 'icons/mob/clothing_dio.dmi'

/obj/item/clothing/suit/diojacket
	name = "Menacing Jacket"
	desc = "Strange looking jacket that most certainly belongs to a powerful stand user."
	fulp_item = TRUE
	icon = 'icons/Fulpicons/dio_clothing.dmi'
	icon_state = "dio_jacket"
	worn_icon = 'icons/mob/clothing_dio.dmi'
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 100)

/obj/item/clothing/under/costume/diojumpsuit
	name = "Menacing Jumpsuit"
	desc = "Just looking at this makes you want to wry..."
	fulp_item = TRUE
	icon = 'icons/Fulpicons/dio_clothing.dmi'
	icon_state = "dio_jumpsuit"
	worn_icon = 'icons/mob/clothing_dio.dmi'

/datum/outfit/dio_brando
	name = "Dio"
	uniform = /obj/item/clothing/under/costume/diojumpsuit
	suit = /obj/item/clothing/suit/diojacket
	head = /obj/item/clothing/head/dioband
	shoes = /obj/item/clothing/shoes/dioshoes
	gloves = /obj/item/clothing/gloves/diowristbands

