/datum/outfit/bunny_waiter
	name = "Bunny Waiter"
	uniform = /obj/item/clothing/under/costume/playbunny
	suit = /obj/item/clothing/suit/jacket/tailcoat
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/heels
	head = /obj/item/clothing/head/playbunnyears
	neck = /obj/item/clothing/neck/tie/bunnytie/tied
	ears = /obj/item/radio/headset/headset_srv
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/bartender
	r_pocket = /obj/item/reagent_containers/cup/rag
	l_pocket = /obj/item/toy/cards/deck
	l_hand = /obj/item/storage/bag/tray
	undershirt = "Nude"

/datum/outfit/bunny_waiter/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()
	return ..()

/datum/outfit/bunny_waiter/syndicate
	name = "Syndicate Bunny Assassin"
	uniform = /obj/item/clothing/under/syndicate/syndibunny
	suit = /obj/item/clothing/suit/jacket/tailcoat/syndicate
	shoes = /obj/item/clothing/shoes/heels/syndicate
	neck = /obj/item/clothing/neck/tie/bunnytie/syndicate/tied
	ears = /obj/item/radio/headset/syndicate
	id = /obj/item/card/id/advanced/chameleon
	suit_store = /obj/item/gun/ballistic/automatic/pistol/suppressed
	l_pocket = /obj/item/toy/cards/deck/syndicate

/datum/outfit/bunny_waiter/british_waiter
	name = "Bunny Waiter (British)"
	uniform = /obj/item/clothing/under/costume/playbunny/british
	suit = /obj/item/clothing/suit/jacket/tailcoat/british
	shoes = /obj/item/clothing/shoes/heels/blue
	head = /obj/item/clothing/head/playbunnyears/british
	neck = /obj/item/clothing/neck/tie/bunnytie/blue

/datum/outfit/bunny_waiter/communist_waiter
	name = "Bunny Waiter (Communist)"
	uniform = /obj/item/clothing/under/costume/playbunny/communist
	suit = /obj/item/clothing/suit/jacket/tailcoat/communist
	shoes = /obj/item/clothing/shoes/heels/red
	head = /obj/item/clothing/head/playbunnyears/communist
	neck = /obj/item/clothing/neck/tie/bunnytie/communist

/datum/outfit/bunny_waiter/usa_waiter
	name = "Bunny Waiter (USA)"
	uniform = /obj/item/clothing/under/costume/playbunny/usa
	suit = /obj/item/clothing/suit/jacket/tailcoat/usa
	shoes = /obj/item/clothing/shoes/heels/red
	head = /obj/item/clothing/head/playbunnyears/usa
	neck = /obj/item/clothing/neck/tie/bunnytie/blue

/datum/outfit/wizard/bunny_magician
	name = "Bunny Magician"
	uniform = /obj/item/clothing/under/costume/playbunny/magician
	suit = /obj/item/clothing/suit/wizrobe/magician
	back = /obj/item/storage/backpack/satchel/leather
	head = /obj/item/clothing/head/wizard/magician
	shoes = /obj/item/clothing/shoes/heels/magician
	neck = /obj/item/clothing/neck/tie/bunnytie/magician/tied
	l_hand = /obj/item/gun/magic/wand/nothing
	l_pocket = /obj/item/toy/cards/deck/tarot
	undershirt = "Nude"

/datum/outfit/centcom/centcom_bunny
	name = "Bunny Waiter (CentCom)"
	uniform = /obj/item/clothing/under/costume/playbunny/centcom
	back = /obj/item/storage/backpack/satchel/leather
	box = /obj/item/storage/box/survival
	suit = /obj/item/clothing/suit/jacket/tailcoat/centcom
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/heels/centcom
	head = /obj/item/clothing/head/playbunnyears/centcom
	neck = /obj/item/clothing/neck/tie/bunnytie/centcom/tied
	ears = /obj/item/radio/headset/headset_cent
	id = /obj/item/card/id/advanced/centcom
	r_pocket = /obj/item/reagent_containers/cup/rag
	suit_store = /obj/item/toy/cards/deck
	l_hand = /obj/item/storage/bag/tray
	undershirt = "Nude"

/datum/outfit/centcom/centcom_bunny/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()
	return ..()
