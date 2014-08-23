//Due to how large this one is it gets its own file
/*
Chaplain
*/

//CHAPLAIN SETUP MOVED TO /items/weapons/storage/book.dm!

/datum/job/chaplain
	title = "Chaplain"
	flag = CHAPLAIN
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"

	default_pda = /obj/item/device/pda/chaplain

	access = list(access_morgue, access_chapel_office, access_crematorium, access_maint_tunnels)
	minimal_access = list(access_morgue, access_chapel_office, access_crematorium)

/datum/job/chaplain/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chaplain(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(H), slot_shoes)
	var/obj/item/weapon/storage/book/bible/B = new /obj/item/weapon/storage/book/bible/booze
	H.put_in_hands(B)
	
	spawn(0)
		B.attack_self(H)

