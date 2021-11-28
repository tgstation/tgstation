/obj/item/clothing/head/hardhat/cakehat
	name = "cakehat"
	desc = "You put the cake on your head. Brilliant."
	icon_state = "hardhat0_cakehat"
	inhand_icon_state = "hardhat0_cakehat"
	hat_type = "cakehat"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	hitsound = 'sound/weapons/tap.ogg'
	var/hitsound_on = 'sound/weapons/sear.ogg' //so we can differentiate between cakehat and energyhat
	var/hitsound_off = 'sound/weapons/tap.ogg'
	var/force_on = 15
	var/throwforce_on = 15
	var/damtype_on = BURN
	flags_inv = HIDEEARS|HIDEHAIR
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	light_range = 2 //luminosity when on
	light_system = MOVABLE_LIGHT
	flags_cover = HEADCOVERSEYES
	heat = 999

	dog_fashion = /datum/dog_fashion/head

/obj/item/clothing/head/hardhat/cakehat/process()
	var/turf/location = src.loc
	if(ishuman(location))
		var/mob/living/carbon/human/wearer = location
		if(wearer.is_holding(src) || wearer.head == src)
			location = wearer.loc

	if(isturf(location))
		location.hotspot_expose(700, 1)

/obj/item/clothing/head/hardhat/cakehat/turn_on(mob/living/user)
	..()
	force = force_on
	throwforce = throwforce_on
	damtype = damtype_on
	hitsound = hitsound_on
	START_PROCESSING(SSobj, src)

/obj/item/clothing/head/hardhat/cakehat/turn_off(mob/living/user)
	..()
	force = 0
	throwforce = 0
	damtype = BRUTE
	hitsound = hitsound_off
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/head/hardhat/cakehat/get_temperature()
	return on * heat

/obj/item/clothing/head/hardhat/cakehat/energycake
	name = "energy cake"
	desc = "You put the energy sword on your cake. Brilliant."
	icon_state = "hardhat0_energycake"
	inhand_icon_state = "hardhat0_energycake"
	hat_type = "energycake"
	hitsound = 'sound/weapons/tap.ogg'
	hitsound_on = 'sound/weapons/blade1.ogg'
	hitsound_off = 'sound/weapons/tap.ogg'
	damtype_on = BRUTE
	force_on = 18 //same as epen (but much more obvious)
	light_range = 3 //ditto
	heat = 0

/obj/item/clothing/head/hardhat/cakehat/energycake/turn_on(mob/living/user)
	playsound(user, 'sound/weapons/saberon.ogg', 5, TRUE)
	to_chat(user, span_warning("You turn on \the [src]."))
	..()

/obj/item/clothing/head/hardhat/cakehat/energycake/turn_off(mob/living/user)
	playsound(user, 'sound/weapons/saberoff.ogg', 5, TRUE)
	to_chat(user, span_warning("You turn off \the [src]."))
	..()
