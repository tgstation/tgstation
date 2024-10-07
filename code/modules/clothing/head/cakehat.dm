/obj/item/clothing/head/utility/hardhat/cakehat
	name = "cakehat"
	desc = "You put the cake on your head. Brilliant."
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "hardhat0_cakehat"
	inhand_icon_state = "hardhat0_cakehat"
	hat_type = "cakehat"
	lefthand_file = 'icons/mob/inhands/clothing/hats_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/hats_righthand.dmi'
	armor_type = /datum/armor/none
	light_system = OVERLAY_LIGHT
	light_range = 2 //luminosity when on
	light_power = 1.3
	light_color = "#FF964E"
	flags_cover = HEADCOVERSEYES
	heat = 999
	wound_bonus = 10
	bare_wound_bonus = 5
	dog_fashion = /datum/dog_fashion/head
	hitsound = 'sound/items/weapons/tap.ogg'
	var/hitsound_on = 'sound/items/weapons/sear.ogg' //so we can differentiate between cakehat and energyhat
	var/hitsound_off = 'sound/items/weapons/tap.ogg'
	var/force_on = 15
	var/throwforce_on = 15
	var/damtype_on = BURN

/obj/item/clothing/head/utility/hardhat/cakehat/process()
	var/turf/location = loc
	if(ishuman(location))
		var/mob/living/carbon/human/wearer = location
		if(wearer.is_holding(src) || wearer.head == src)
			location = wearer.loc

	if(isturf(location))
		location.hotspot_expose(700, 1)

/obj/item/clothing/head/utility/hardhat/cakehat/turn_on(mob/living/user)
	..()
	force = force_on
	throwforce = throwforce_on
	damtype = damtype_on
	hitsound = hitsound_on
	START_PROCESSING(SSobj, src)

/obj/item/clothing/head/utility/hardhat/cakehat/turn_off(mob/living/user)
	..()
	force = 0
	throwforce = 0
	damtype = BRUTE
	hitsound = hitsound_off
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/head/utility/hardhat/cakehat/get_temperature()
	return on * heat

/obj/item/clothing/head/utility/hardhat/cakehat/energycake
	name = "energy cake"
	desc = "You put the energy sword on your cake. Brilliant."
	icon_state = "hardhat1_energycake"
	inhand_icon_state = "hardhat0_energycake"
	hat_type = "energycake"
	hitsound = 'sound/items/weapons/tap.ogg'
	hitsound_on = 'sound/items/weapons/blade1.ogg'
	hitsound_off = 'sound/items/weapons/tap.ogg'
	damtype_on = BRUTE
	force_on = 18 //same as epen (but much more obvious)
	light_range = 3 //ditto
	heat = 0

/obj/item/clothing/head/utility/hardhat/cakehat/energycake/Initialize(mapload)
	. = ..()
	//the compiled icon state is how it appears when it's on.
	//That's how we want it to show on orbies (little virtual PDA pets).
	//However we should reset their appearance on runtime.
	update_appearance(UPDATE_ICON_STATE)

/obj/item/clothing/head/utility/hardhat/cakehat/energycake/turn_on(mob/living/user)
	playsound(src, 'sound/items/weapons/saberon.ogg', 5, TRUE)
	to_chat(user, span_warning("You turn on \the [src]."))
	return ..()

/obj/item/clothing/head/utility/hardhat/cakehat/energycake/turn_off(mob/living/user)
	playsound(src, 'sound/items/weapons/saberoff.ogg', 5, TRUE)
	to_chat(user, span_warning("You turn off \the [src]."))
	return ..()
