/datum/outfit/vr
	name = "Basic VR"

	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/vr
	uniform = /obj/item/clothing/under/color/random
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/sneakers/black

/datum/outfit/vr/pre_equip(mob/living/carbon/human/H)
	H.dna.species.pre_equip_species_outfit(null, H)

/datum/outfit/vr/syndicate
	name = "Syndicate VR Operative - Basic"

	id = /obj/item/card/id/advanced/chameleon/black
	id_trim = /datum/id_trim/vr/operative
	uniform = /obj/item/clothing/under/syndicate
	back = /obj/item/storage/backpack
	box = /obj/item/storage/box/survival/syndie
	belt = /obj/item/gun/ballistic/automatic/pistol/clandestine
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat
	l_pocket = /obj/item/paper/fluff/vr/fluke_ops
	r_pocket = /obj/item/pen/edagger

/datum/outfit/vr/syndicate/post_equip(mob/living/carbon/human/H)
	. = ..()
	var/obj/item/uplink/U = new /obj/item/uplink/nuclear_restricted(H, H.key, 80)
	H.equip_to_storage(U, ITEM_SLOT_BACK, indirect_action = TRUE, del_on_fail = TRUE)
	var/obj/item/implant/weapons_auth/W = new/obj/item/implant/weapons_auth(H)
	W.implant(H)
	var/obj/item/implant/explosive/E = new/obj/item/implant/explosive(H)
	E.implant(H)
	H.faction |= ROLE_SYNDICATE
	H.update_icons()

/obj/item/paper/fluff/vr/fluke_ops
	name = "Where is my uplink?"
	default_raw_text = "Use the radio in your backpack."
