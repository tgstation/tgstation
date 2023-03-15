/proc/spawn_as_dummy(mob/user)
	if(!isobserver(user))
		to_chat(user, "<span class='admin'>You must be a ghost to use this.</span>")
		return
	SSblackbox.record_feedback("tally", "admin_secrets_fun_used", 1, "Spawn as Dummy")
	message_admins("[key_name_admin(usr)] spawned himself as a Test Dummy.")
	var/turf/T = get_turf(usr)
	var/mob/living/carbon/human/dummy/admin_dummy = new(T)
	usr.client.cmd_assume_direct_control(admin_dummy)
	admin_dummy.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(admin_dummy), ITEM_SLOT_ICLOTHING)
	admin_dummy.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(admin_dummy), ITEM_SLOT_FEET)
	admin_dummy.equip_to_slot_or_del(new /obj/item/radio/headset/heads/captain(admin_dummy), ITEM_SLOT_EARS)
	admin_dummy.name = "Admin"
	admin_dummy.real_name = "Admin"
	new /obj/effect/holy(T)
	var/newname = ""
	newname = copytext(sanitize(input(admin_dummy, "Before you step out as an embodied god, what name do you wish for?", "Choose your name.", "Admin") as null|text),1,MAX_NAME_LEN)
	if (!newname)
		newname = "Admin"
	admin_dummy.name = newname
	admin_dummy.real_name = newname
