/datum/outfit/infiltrator
	name = "Syndicate Infiltrator"

	uniform = /obj/item/clothing/under/chameleon
	shoes = /obj/item/clothing/shoes/chameleon/noslip
	gloves = /obj/item/clothing/gloves/chameleon
	back = /obj/item/storage/backpack/chameleon
	ears = /obj/item/device/radio/headset/chameleon
	id = /obj/item/card/id/syndicate
	mask = /obj/item/clothing/mask/chameleon
	backpack_contents = list(/obj/item/storage/box/syndie=1,\
		/obj/item/kitchen/knife/combat/survival=1,\
		/obj/item/gun/ballistic/automatic/pistol=1)

/datum/outfit/infiltrator/post_equip(mob/living/carbon/human/H)
	var/obj/item/device/radio/R = H.ears

	var/obj/item/implant/weapons_auth/W = new/obj/item/implant/weapons_auth(H)
	W.implant(H)
	var/obj/item/implant/explosive/E = new/obj/item/implant/explosive(H)
	E.implant(H)
	var/obj/item/implant/uplink/infiltrator/U = new/obj/item/implant/uplink/infiltrator(H)
	U.implant(H)
	var/obj/item/implanter/radio/syndicate/S = new/obj/item/implanter/radio/syndicate(H)
	S.implant(H)
	H.faction |= ROLE_SYNDICATE
	H.update_icons()