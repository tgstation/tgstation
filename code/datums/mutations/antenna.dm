/datum/mutation/human/antenna
	name = "Antenna"
	desc = "The affected person sprouts an antenna. This is known to allow them to access common radio channels passively."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>You feel an antenna sprout from your forehead.</span>"
	text_lose_indication = "<span class='notice'>Your antenna shrinks back down.</span>"
	instability = 5
	difficulty = 8
	var/obj/item/implant/radio/antenna/linked_radio

/obj/item/implant/radio/antenna
	name = "internal antenna organ"
	desc = "The internal organ part of the antenna. Science has not yet given it a good name."
	icon = 'icons/obj/radio.dmi'//maybe make a unique sprite later. not important
	icon_state = "walkietalkie"

/obj/item/implant/radio/antenna/Initialize(mapload)
	..()
	radio.name = "internal antenna"

/datum/mutation/human/antenna/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	linked_radio = new(owner)
	linked_radio.implant(owner, null, TRUE, TRUE)

/datum/mutation/human/antenna/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	if(linked_radio)
		linked_radio.Destroy()

/datum/mutation/human/antenna/New()
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "antenna", -MUTATIONS_LAYER+1))

/datum/mutation/human/antenna/get_visual_indicator()
	return visual_indicators[type][1]
