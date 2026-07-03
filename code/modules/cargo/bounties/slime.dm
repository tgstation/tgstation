/datum/bounty/item/slime
	reward = CARGO_CRATE_VALUE * 6

/datum/bounty/item/slime/New()
	..()
	description = "Научный руководитель Нанотрейзен охотится за редким и экзотическим [name]. За его нахождение полагается награда."
	reward += rand(0, 4) * 500

/datum/bounty/item/slime/green
	name = "зелёным экстрактом слайма"
	wanted_types = list(/obj/item/slime_extract/green = TRUE)

/datum/bounty/item/slime/pink
	name = "розовым экстрактом слайма"
	wanted_types = list(/obj/item/slime_extract/pink = TRUE)

/datum/bounty/item/slime/gold
	name = "золотым экстрактом слайма"
	wanted_types = list(/obj/item/slime_extract/gold = TRUE)

/datum/bounty/item/slime/oil
	name = "масляным экстрактом слайма"
	wanted_types = list(/obj/item/slime_extract/oil = TRUE)

/datum/bounty/item/slime/black
	name = "чёрным экстрактом слайма"
	wanted_types = list(/obj/item/slime_extract/black = TRUE)

/datum/bounty/item/slime/lightpink
	name = "светло-розовым экстрактом слайма"
	wanted_types = list(/obj/item/slime_extract/lightpink = TRUE)

/datum/bounty/item/slime/adamantine
	name = "адамантитовым экстрактом слайма"
	wanted_types = list(/obj/item/slime_extract/adamantine = TRUE)

/datum/bounty/item/slime/rainbow
	name = "радужным экстрактом слайма"
	wanted_types = list(/obj/item/slime_extract/rainbow = TRUE)
