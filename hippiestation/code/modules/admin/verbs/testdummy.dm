/obj/item/weapon/card/id/admin
	name = "Admin ID"
	desc = "Magic card that opens everything."
	icon_state = "fingerprint1"
	registered_name = "Admin"
	assignment = "General"

/obj/item/weapon/card/id/admin/New()
	access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()+get_ert_access("commander")
	..()

/proc/spawntestdummy(var/mob/usr)
	SSblackbox.inc("admin_secrets_fun_used",1)
	SSblackbox.add_details("admin_secrets_fun_used","TD")
	message_admins("[key_name_admin(usr)] spawned himself as a Test Dummy.")
	var/turf/T = get_turf(usr)
	var/mob/living/carbon/human/dummy/D = new /mob/living/carbon/human/dummy(T)
	usr.client.cmd_assume_direct_control(D)
	D.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(D), slot_w_uniform)
	D.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(D), slot_shoes)
	D.equip_to_slot_or_del(new /obj/item/weapon/card/id/admin(D), slot_wear_id)
	D.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(D), slot_ears)
	D.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(D), slot_back)
	D.equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(D.back), slot_in_backpack)
	D.name = "Admin"
	D.real_name = "Admin"
	var/newname = ""
	newname = copytext(sanitize(input(D, "Before you step out as an embodied god, what name do you wish for?", "Choose your name.", "Admin") as null|text),1,MAX_NAME_LEN)
	if (!newname)
		newname = "Admin"
	D.name = newname
	D.real_name = newname