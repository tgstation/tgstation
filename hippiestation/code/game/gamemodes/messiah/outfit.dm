/datum/outfit/jesus
	name = "Space Jesus"
	uniform = /obj/item/clothing/under/rank/chef/spacejesus
	suit = /obj/item/clothing/suit/hippie/jesus/spacejesus
	shoes = /obj/item/clothing/shoes/sandal/spacejesus
	ears = /obj/item/device/radio/headset
	head = /obj/item/clothing/head/hippie/halo/spacejesus
	suit_store = /obj/item/weapon/storage/book/bible

/datum/outfit/jesus/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	
	H.skin_tone = "latino"
	H.hair_color = "754"
	H.facial_hair_color = "754"
	H.eye_color = "49a"
	H.hair_style = "Long Fringe"
	H.facial_hair_style = "Full Beard"
	H.socks = "Nude"

	H.regenerate_icons()
	if(visualsOnly)
		return

	//Conversion preventative measures
	var/obj/item/weapon/implant/mindshield/imp = new(H)
	H.implants += imp
	imp.imp_in = H
	H.sec_hud_set_implants()
	H.mind.isholy = TRUE // Ability to use Chaplain stuff, like the Bible
	H.mind.hasSoul = FALSE //Removes the ability to sell one's soul to a devil

	H.grant_all_languages(omnitongue=TRUE)

	H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/jesus_btw(null))
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock/jesus(null))
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/jesus_ascend(null))
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/jesus_deconvert(null))
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/jesus_revive(null))


/obj/item/clothing/head/hippie/halo
	name = "Halo"
	icon_state = "halo"
	desc = "The holiest of all headwear."
	alternate_worn_layer = BELOW_MOB_LAYER

/obj/item/clothing/head/hippie/halo/spacejesus
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags = NODROP

/obj/item/clothing/suit/hippie/jesus
	name = "Messiah Robes"
	desc = "They seem very holy."
	icon_state = "jesus"
	allowed = list(/obj/item/weapon/storage/book/bible)

/obj/item/clothing/suit/hippie/jesus/spacejesus
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags = NODROP

/obj/item/clothing/under/rank/chef/spacejesus
	name = "Sacred Jumpsuit"
	desc = "It seems very holy."
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags = NODROP

/obj/item/clothing/shoes/sandal/spacejesus
	name = "Holy Sandals"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags = NODROP
