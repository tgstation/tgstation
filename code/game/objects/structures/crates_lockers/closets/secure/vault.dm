/obj/structure/closet/secure_closet/vault
	name = "vault locker"
	desc = "For when you absolutely need to keep something safe."
	icon_state = "vault1"
	anchored = 1 //immovable
	icon_closed = "vault"
	icon_locked = "vault1"
	icon_opened = "vaultopen"
	icon_broken = "vaultbroken"
	icon_off = "vaultoff"
	health = 20000

/obj/structure/closet/secure_closet/vault/ex_act(var/severity) //bomb-proof
	switch(severity)
		if(1.0)
			health -= 500
		if(2.0)
			health -= 100
		if(3.0)
			health -= 20
	var/list/bombs = search_contents_for(/obj/item/device/transfer_valve)
	if(!isemptylist(bombs)) //If there's a bomb inside the locker when it's hit with an explosion, the things inside lose their protection
		for(var/obj/O in src)
			O.ex_act(severity)

/obj/structure/closet/secure_closet/vault/emp_act(severity) //EMP-proof
	return

/obj/structure/closet/secure_closet/vault/armory
	name = "\improper Armory vault locker"
	req_access = list(access_armory)

/obj/structure/closet/secure_closet/vault/armory/lawgiver/New()
	..()
	new /obj/item/weapon/storage/lockbox/lawgiver(src)

/obj/structure/closet/secure_closet/vault/vault
	req_access = list(access_heads_vault)

/obj/structure/closet/secure_closet/vault/centcomm
	name = "\improper Centcomm vault locker"
	req_access = list(access_cent_general)

/obj/structure/closet/secure_closet/vault/syndicate
	name = "\improper Syndicate vault locker"
	req_access = list(access_syndicate)

/obj/structure/closet/secure_closet/vault/ert
	name = "\improper ERT vault locker"
	req_access = list(access_cent_ert)