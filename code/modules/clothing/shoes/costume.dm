/obj/item/clothing/shoes/roman
	name = "roman sandals"
	desc = "Sandals with buckled leather straps on it."
	icon_state = "roman"
	inhand_icon_state = "wizshoe"
	strip_delay = 100
	equip_delay_other = 100
	armor_type = /datum/armor/shoes_roman
	can_be_tied = FALSE

/obj/item/clothing/shoes/griffin
	name = "griffon boots"
	desc = "A pair of costume boots fashioned after bird talons."
	icon_state = "griffinboots"
	inhand_icon_state = null
	lace_time = 8 SECONDS

/datum/armor/shoes_roman
	bio = 10

/obj/item/clothing/shoes/griffin/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/shoes)

/obj/item/clothing/shoes/singery
	name = "yellow performer's boots"
	desc = "These boots were made for dancing."
	icon_state = "ysing"
	equip_delay_other = 50

/obj/item/clothing/shoes/singerb
	name = "blue performer's boots"
	desc = "These boots were made for dancing."
	icon_state = "bsing"
	equip_delay_other = 50

/obj/item/clothing/shoes/bronze
	name = "bronze boots"
	desc = "A giant, clunky pair of shoes crudely made out of bronze. Why would anyone wear these?"
	icon = 'icons/obj/clothing/shoes.dmi'
	icon_state = "clockwork_treads"
	can_be_tied = FALSE

/obj/item/clothing/shoes/bronze/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/machines/clockcult/integration_cog_install.ogg' = 1, 'sound/magic/clockwork/fellowship_armory.ogg' = 1), 50, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)

/obj/item/clothing/shoes/cookflops
	desc = "All this talk of antags, greytiding, and griefing... I just wanna grill for god's sake!"
	name = "grilling sandals"
	icon_state = "cookflops"
	inhand_icon_state = "cookflops"
	can_be_tied = FALSE
	species_exception = list(/datum/species/golem)

/obj/item/clothing/shoes/jackbros
	name = "frosty boots"
	desc = "For when you're stepping on up to the plate."
	icon_state = "JackFrostShoes"
	inhand_icon_state = null

/obj/item/clothing/shoes/swagshoes
	name = "swag shoes"
	desc = "They got me for my foams!"
	icon_state = "SwagShoes"
	inhand_icon_state = null

/obj/item/clothing/shoes/glow
	name = "glow shoes"
	desc = "t3h c00L3st sh03z j00'LL 3v3r f1nd."
	icon_state = "glow_shoes"
	inhand_icon_state = null

/obj/item/clothing/shoes/jackbros
	name = "frosty boots"
	desc = "For when you're stepping on up to the plate."
	icon_state = "JackFrostShoes"
	inhand_icon_state = null

/obj/item/clothing/shoes/saints
	name = "saints sneakers"
	desc = "Officially branded Saints sneakers. Incredibly valuable!"
	icon_state = "saints_shoes"
	inhand_icon_state = null

/obj/item/clothing/shoes/jester_shoes
	name = "jester shoes"
	desc = "Shoes that jingle with every step!!"
	icon_state = "green_jester_shoes"
	inhand_icon_state = null

/obj/item/clothing/shoes/jester_shoes/Initialize(mapload)
	. = ..()

	LoadComponent(/datum/component/squeak, list('sound/effects/jingle.ogg' = 1), 50, falloff_exponent = 20, step_delay_override = 0)

/obj/item/clothing/shoes/ducky_shoes
	name = "ducky shoes"
	desc = "I got boots, that go *quack quack quack quack quack."
	icon_state = "ducky_shoes"
	inhand_icon_state = "ducky_shoes"

/obj/item/clothing/shoes/ducky_shoes/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/shoes)
	LoadComponent(/datum/component/squeak, list('sound/effects/quack.ogg' = 1), 50, falloff_exponent = 20)

/obj/item/clothing/shoes/ducky_shoes/equipped(mob/living/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_FEET)
		user.AddElement(/datum/element/waddling)

/obj/item/clothing/shoes/ducky_shoes/dropped(mob/living/user)
	. = ..()
	user.RemoveElement(/datum/element/waddling)
