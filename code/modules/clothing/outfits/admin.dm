
/datum/outfit/space
	name = "Standard Space Gear"

	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/sneakers/black
	suit = /obj/item/clothing/suit/space
	head = /obj/item/clothing/head/helmet/space
	back = /obj/item/tank/jetpack/oxygen
	mask = /obj/item/clothing/mask/breath

/datum/outfit/debug //Debug objs plus hardsuit
	name = "Debug outfit"
	uniform = /obj/item/clothing/under/misc/patriotsuit
	suit = /obj/item/clothing/suit/space/hardsuit/syndi/elite/debug
	glasses = /obj/item/clothing/glasses/debug
	ears = /obj/item/radio/headset/headset_cent/commander
	mask = /obj/item/clothing/mask/gas/welding/up
	gloves = /obj/item/clothing/gloves/combat
	belt = /obj/item/storage/belt/utility/chief/full
	shoes = /obj/item/clothing/shoes/magboots/advance
	id = /obj/item/card/id/advanced/debug
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/storage/backpack/holding
	box = /obj/item/storage/box/debugtools
	internals_slot = ITEM_SLOT_SUITSTORE
	backpack_contents = list(
		/obj/item/melee/transforming/energy/axe=1,\
		/obj/item/storage/part_replacer/bluespace/tier4=1,\
		/obj/item/gun/magic/wand/resurrection/debug=1,\
		/obj/item/gun/magic/wand/death/debug=1,\
		/obj/item/debug/human_spawner=1,\
		/obj/item/debug/omnitool=1
		)

/datum/outfit/debug/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()

/datum/outfit/admin //for admeem shenanigans and testing things that arent related to equipment, not a subtype of debug just in case debug changes things
	name = "Admin outfit"
	uniform = /obj/item/clothing/under/misc/patriotsuit
	suit = /obj/item/clothing/suit/space/hardsuit/syndi/elite/admin
	glasses = /obj/item/clothing/glasses/debug
	ears = /obj/item/radio/headset/headset_cent/commander
	mask = /obj/item/clothing/mask/gas/welding/up
	gloves = /obj/item/clothing/gloves/combat
	belt = /obj/item/storage/belt/utility/chief/full
	shoes = /obj/item/clothing/shoes/magboots/advance
	id = /obj/item/card/id/advanced/debug
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/storage/backpack/holding
	box = /obj/item/storage/box/debugtools
	internals_slot = ITEM_SLOT_SUITSTORE
	backpack_contents = list(
		/obj/item/melee/transforming/energy/axe=1,\
		/obj/item/storage/part_replacer/bluespace/tier4=1,\
		/obj/item/gun/magic/wand/resurrection/debug=1,\
		/obj/item/gun/magic/wand/death/debug=1,\
		/obj/item/debug/human_spawner=1,\
		/obj/item/debug/omnitool=1,\
		/obj/item/storage/box/stabilized=1
		)

/datum/outfit/admin/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()

/datum/outfit/tunnel_clown
	name = "Tunnel Clown"

	uniform = /obj/item/clothing/under/rank/civilian/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	gloves = /obj/item/clothing/gloves/color/black
	mask = /obj/item/clothing/mask/gas/clown_hat
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	suit = /obj/item/clothing/suit/hooded/chaplain_hoodie
	l_pocket = /obj/item/food/grown/banana
	r_pocket = /obj/item/bikehorn
	id = /obj/item/card/id/advanced/gold
	l_hand = /obj/item/fireaxe
	id_trim = /datum/id_trim/tunnel_clown

/datum/outfit/tunnel_clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()

/datum/outfit/psycho
	name = "Masked Killer"

	uniform = /obj/item/clothing/under/misc/overalls
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/latex
	mask = /obj/item/clothing/mask/surgical
	head = /obj/item/clothing/head/welding
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	suit = /obj/item/clothing/suit/apron
	l_pocket = /obj/item/kitchen/knife
	r_pocket = /obj/item/scalpel
	l_hand = /obj/item/fireaxe

/datum/outfit/psycho/post_equip(mob/living/carbon/human/H)
	for(var/obj/item/carried_item in H.get_equipped_items(TRUE))
		carried_item.add_mob_blood(H)//Oh yes, there will be blood...
	for(var/obj/item/I in H.held_items)
		I.add_mob_blood(H)
	H.regenerate_icons()

/datum/outfit/assassin
	name = "Assassin"

	uniform = /obj/item/clothing/under/suit/black
	shoes = /obj/item/clothing/shoes/sneakers/black
	gloves = /obj/item/clothing/gloves/color/black
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/sunglasses
	l_pocket = /obj/item/melee/transforming/energy/sword/saber
	l_hand = /obj/item/storage/secure/briefcase
	id = /obj/item/card/id/advanced/chameleon/black
	belt = /obj/item/pda/heads
	id_trim = /datum/id_trim/reaper_assassin

/datum/outfit/assassin/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	var/obj/item/clothing/under/U = H.w_uniform
	U.attach_accessory(new /obj/item/clothing/accessory/waistcoat(H))

	if(visualsOnly)
		return

	//Could use a type
	var/obj/item/storage/secure/briefcase/sec_briefcase = H.get_item_for_held_index(1)
	for(var/obj/item/briefcase_item in sec_briefcase)
		qdel(briefcase_item)
	for(var/i = 3 to 0 step -1)
		SEND_SIGNAL(sec_briefcase, COMSIG_TRY_STORAGE_INSERT, new /obj/item/stack/spacecash/c1000, null, TRUE, TRUE)
	SEND_SIGNAL(sec_briefcase, COMSIG_TRY_STORAGE_INSERT, new /obj/item/gun/energy/kinetic_accelerator/crossbow, null, TRUE, TRUE)
	SEND_SIGNAL(sec_briefcase, COMSIG_TRY_STORAGE_INSERT, new /obj/item/gun/ballistic/revolver/mateba, null, TRUE, TRUE)
	SEND_SIGNAL(sec_briefcase, COMSIG_TRY_STORAGE_INSERT, new /obj/item/ammo_box/a357, null, TRUE, TRUE)
	SEND_SIGNAL(sec_briefcase, COMSIG_TRY_STORAGE_INSERT, new /obj/item/grenade/c4/x4, null, TRUE, TRUE)

	var/obj/item/pda/heads/pda = H.belt
	pda.owner = H.real_name
	pda.ownjob = "Reaper"
	pda.update_label()

	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()

/datum/outfit/mobster
	name = "Mobster"

	uniform = /obj/item/clothing/under/suit/black_really
	head = /obj/item/clothing/head/fedora
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/black
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/sunglasses
	l_hand = /obj/item/gun/ballistic/automatic/tommygun
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/mobster

/datum/outfit/mobster/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()
