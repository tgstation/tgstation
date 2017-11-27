/obj/item/clothing/mask/muzzle
	name = "muzzle"
	desc = "To stop that awful noise."
	icon_state = "muzzle"
	item_state = "blindfold"
	flags_cover = MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.90
	equip_delay_other = 20

/obj/item/clothing/mask/muzzle/attack_paw(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.wear_mask)
			to_chat(user, "<span class='warning'>You need help taking this off!</span>")
			return
	..()

/obj/item/clothing/mask/surgical
	name = "sterile mask"
	desc = "A sterile mask designed to help prevent the spread of diseases."
	icon_state = "sterile"
	item_state = "sterile"
	w_class = WEIGHT_CLASS_TINY
	flags_inv = HIDEFACE
	flags_cover = MASKCOVERSMOUTH
	visor_flags_inv = HIDEFACE
	visor_flags_cover = MASKCOVERSMOUTH
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 25, rad = 0, fire = 0, acid = 0)
	actions_types = list(/datum/action/item_action/adjust)

/obj/item/clothing/mask/surgical/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/fakemoustache
	name = "fake moustache"
	desc = "Warning: moustache is fake."
	icon_state = "fake-moustache"
	flags_inv = HIDEFACE

/obj/item/clothing/mask/joy
	name = "joy mask"
	desc = "Express your happiness or hide your sorrows with this laughing face with crying tears of joy cutout."
	icon_state = "joy"

/obj/item/clothing/mask/pig
	name = "pig mask"
	desc = "A rubber pig mask."
	icon_state = "pig"
	item_state = "pig"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/toggle_voice_box)
	var/voicechange = 0

/obj/item/clothing/mask/pig/attack_self(mob/user)
	voicechange = !voicechange
	to_chat(user, "<span class='notice'>You turn the voice box [voicechange ? "on" : "off"]!</span>")

/obj/item/clothing/mask/pig/speechModification(message)
	if(voicechange)
		message = pick("Oink!","Squeeeeeeee!","Oink Oink!")
	return message

/obj/item/clothing/mask/spig //needs to be different otherwise you could turn the speedmodification off and on
	name = "Pig face"
	desc = "It looks like a mask, but closer inspection reveals it's melded onto this persons face!" //It's only ever going to be attached to your face.
	icon_state = "pig"
	item_state = "pig"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	w_class = WEIGHT_CLASS_SMALL
	var/voicechange = 1

/obj/item/clothing/mask/spig/speechModification(message)
	if(voicechange)
		message = pick("Oink!","Squeeeeeeee!","Oink Oink!")
	return message

/obj/item/clothing/mask/cowmask
	name = "Cowface"
	desc = "It looks like a mask, but closer inspection reveals it's melded onto this persons face!"
	icon = 'icons/mob/mask.dmi'
	icon_state = "cowmask"
	item_state = "cowmask"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	w_class = WEIGHT_CLASS_SMALL
	var/voicechange = 1

/obj/item/clothing/mask/cowmask/speechModification(message)
	if(voicechange)
		message = pick("Moooooooo!","Moo!","Moooo!")
	return message

/obj/item/clothing/mask/horsehead
	name = "horse head mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a horse."
	icon_state = "horsehead"
	item_state = "horsehead"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDEEYES|HIDEEARS
	w_class = WEIGHT_CLASS_SMALL
	var/voicechange = 1

/obj/item/clothing/mask/horsehead/speechModification(message)
	if(voicechange)
		message = pick("NEEIIGGGHHHH!", "NEEEIIIIGHH!", "NEIIIGGHH!", "HAAWWWWW!", "HAAAWWW!")
	return message

/obj/item/clothing/mask/rat
	name = "rat mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a rat."
	icon_state = "rat"
	item_state = "rat"
	flags_inv = HIDEFACE
	flags_cover = MASKCOVERSMOUTH

/obj/item/clothing/mask/rat/fox
	name = "fox mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a fox."
	icon_state = "fox"
	item_state = "fox"

/obj/item/clothing/mask/rat/bee
	name = "bee mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a bee."
	icon_state = "bee"
	item_state = "bee"

/obj/item/clothing/mask/rat/bear
	name = "bear mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a bear."
	icon_state = "bear"
	item_state = "bear"

/obj/item/clothing/mask/rat/bat
	name = "bat mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a bat."
	icon_state = "bat"
	item_state = "bat"

/obj/item/clothing/mask/rat/raven
	name = "raven mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a raven."
	icon_state = "raven"
	item_state = "raven"

/obj/item/clothing/mask/rat/jackal
	name = "jackal mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a jackal."
	icon_state = "jackal"
	item_state = "jackal"

/obj/item/clothing/mask/rat/tribal
	name = "tribal mask"
	desc = "A mask carved out of wood, detailed carefully by hand."
	icon_state = "bumba"
	item_state = "bumba"

/obj/item/clothing/mask/bandana
	name = "botany bandana"
	desc = "A fine bandana with nanotech lining and a hydroponics pattern."
	w_class = WEIGHT_CLASS_TINY
	flags_cover = MASKCOVERSMOUTH
	flags_inv = HIDEFACE|HIDEFACIALHAIR
	visor_flags_inv = HIDEFACE|HIDEFACIALHAIR
	visor_flags_cover = MASKCOVERSMOUTH
	slot_flags = SLOT_MASK
	adjusted_flags = SLOT_HEAD
	icon_state = "bandbotany"

/obj/item/clothing/mask/bandana/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/bandana/red
	name = "red bandana"
	desc = "A fine red bandana with nanotech lining."
	icon_state = "bandred"

/obj/item/clothing/mask/bandana/blue
	name = "blue bandana"
	desc = "A fine blue bandana with nanotech lining."
	icon_state = "bandblue"

/obj/item/clothing/mask/bandana/green
	name = "green bandana"
	desc = "A fine green bandana with nanotech lining."
	icon_state = "bandgreen"

/obj/item/clothing/mask/bandana/gold
	name = "gold bandana"
	desc = "A fine gold bandana with nanotech lining."
	icon_state = "bandgold"

/obj/item/clothing/mask/bandana/black
	name = "black bandana"
	desc = "A fine black bandana with nanotech lining."
	icon_state = "bandblack"

/obj/item/clothing/mask/bandana/skull
	name = "skull bandana"
	desc = "A fine black bandana with nanotech lining and a skull emblem."
	icon_state = "bandskull"