

/datum/outfit/echolocator
	name = "Bitrunning Echolocator"
	glasses = /obj/item/clothing/glasses/blindfold
	ears = /obj/item/radio/headset/psyker //Navigating without these is horrible.
	uniform = /obj/item/clothing/under/abductor
	gloves = /obj/item/clothing/gloves/fingerless
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/jacket/trenchcoat
	id = /obj/item/card/id/advanced


/datum/outfit/echolocator/post_equip(mob/living/carbon/human/user, visualsOnly)
	. = ..()
	user.psykerize()


/datum/outfit/bitductor
	name = "Bitrunning Abductor"
	uniform = /obj/item/clothing/under/abductor
	gloves = /obj/item/clothing/gloves/fingerless
	shoes = /obj/item/clothing/shoes/jackboots


/datum/outfit/beachbum_combat
	name = "Beachbum: Island Combat"
	id = /obj/item/card/id/advanced
	l_pocket = null
	r_pocket = null
	shoes = /obj/item/clothing/shoes/sandal
	uniform = /obj/item/clothing/under/pants/jeans


/datum/outfit/beachbum/combat/post_equip(mob/living/carbon/human/bum, visualsOnly)
	. = ..()

	var/list/ranged_weaps = list(
		/obj/item/gun/ballistic/automatic/pistol/deagle,
		/obj/item/gun/ballistic/rifle/boltaction,
		/obj/item/gun/ballistic/automatic/mini_uzi,
	)

	var/list/corresponding_ammo = list(
		/obj/item/ammo_box/magazine/m50,
		/obj/item/ammo_box/strilka310,
		/obj/item/ammo_box/magazine/uzim9mm,
	)

	var/choice = rand(1, 3)
	var/weapon = ranged_weaps[choice]
	var/ammo = corresponding_ammo[choice]

	bum.put_in_active_hand(new weapon)
	bum.equip_to_slot_if_possible(new ammo, ITEM_SLOT_LPOCKET)
	bum.equip_to_slot_if_possible(new ammo, ITEM_SLOT_RPOCKET)

	if(prob(50))
		bum.equip_to_slot_if_possible(new /obj/item/clothing/glasses/sunglasses, ITEM_SLOT_EYES)
