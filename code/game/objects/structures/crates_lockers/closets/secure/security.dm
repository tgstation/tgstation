/obj/structure/closet/secure_closet/captains
	name = "\proper captain's locker"
	req_access = list(access_captain)
	icon_state = "capsecure1"
	icon_closed = "capsecure"
	icon_locked = "capsecure1"
	icon_opened = "capsecureopen"
	icon_broken = "capsecurebroken"
	icon_off = "capsecureoff"

/obj/structure/closet/secure_closet/captains/New()
	..()
	new /obj/item/clothing/suit/hooded/wintercoat/captain(src)
	if(prob(50))
		new /obj/item/weapon/storage/backpack/captain(src)
	else
		new /obj/item/weapon/storage/backpack/satchel_cap(src)
	new /obj/item/weapon/storage/backpack/dufflebag/captain(src)
	new /obj/item/clothing/suit/captunic(src)
	new /obj/item/clothing/under/captainparade(src)
	new /obj/item/clothing/head/caphat/parade(src)
	new /obj/item/clothing/under/rank/captain(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace(src)
	new /obj/item/weapon/cartridge/captain(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/device/radio/headset/heads/captain/alt(src)
	new /obj/item/clothing/gloves/color/captain(src)
	new /obj/item/weapon/gun/energy/gun(src)
	return

/obj/structure/closet/secure_closet/hop
	name = "\proper head of personnel's locker"
	req_access = list(access_hop)
	icon_state = "hopsecure1"
	icon_closed = "hopsecure"
	icon_locked = "hopsecure1"
	icon_opened = "hopsecureopen"
	icon_broken = "hopsecurebroken"
	icon_off = "hopsecureoff"

/obj/structure/closet/secure_closet/hop/New()
	..()
	new /obj/item/clothing/suit/hooded/wintercoat/cargo(src)
	new /obj/item/clothing/under/rank/head_of_personnel(src)
	new /obj/item/clothing/head/hopcap(src)
	new /obj/item/weapon/cartridge/hop(src)
	new /obj/item/device/radio/headset/heads/hop(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/weapon/storage/box/ids(src)
	new /obj/item/weapon/storage/box/ids(src)
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/weapon/gun/energy/gun(src)
	new /obj/item/device/flash/handheld(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/weapon/mining_voucher(src)
	return



/obj/structure/closet/secure_closet/hos
	name = "\proper head of security's locker"
	req_access = list(access_hos)
	icon_state = "hossecure1"
	icon_closed = "hossecure"
	icon_locked = "hossecure1"
	icon_opened = "hossecureopen"
	icon_broken = "hossecurebroken"
	icon_off = "hossecureoff"

/obj/structure/closet/secure_closet/hos/New()
	..()
	new /obj/item/clothing/suit/hooded/wintercoat/security(src)
	new /obj/item/weapon/cartridge/hos(src)
	new /obj/item/device/radio/headset/heads/hos(src)
	new /obj/item/clothing/under/hosparadefem(src)
	new /obj/item/clothing/under/hosparademale(src)
	new /obj/item/clothing/suit/armor/hos(src)
	new /obj/item/clothing/under/rank/head_of_security/alt(src)
	new /obj/item/clothing/head/HoS(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch(src)
	new /obj/item/weapon/storage/lockbox/loyalty(src)
	new /obj/item/weapon/storage/box/flashbangs(src)
	new /obj/item/clothing/mask/gas/sechailer/swat(src)
	new /obj/item/weapon/shield/riot/tele(src)
	new /obj/item/weapon/melee/baton/loaded(src)
	new /obj/item/weapon/gun/energy/gun/advtaser(src)
	new /obj/item/weapon/storage/belt/security/full(src)
	return


/obj/structure/closet/secure_closet/warden
	name = "\proper warden's locker"
	req_access = list(access_armory)
	icon_state = "wardensecure1"
	icon_closed = "wardensecure"
	icon_locked = "wardensecure1"
	icon_opened = "wardensecureopen"
	icon_broken = "wardensecurebroken"
	icon_off = "wardensecureoff"


/obj/structure/closet/secure_closet/warden/New()
	..()
	new /obj/item/device/radio/headset/headset_sec(src)
	new /obj/item/clothing/suit/armor/vest/warden/(src)
	new /obj/item/clothing/head/warden(src)
	new /obj/item/clothing/head/beret/sec/navywarden(src)
	new /obj/item/clothing/suit/armor/vest/warden/alt(src)
	new /obj/item/clothing/under/rank/warden/navyblue(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/weapon/storage/box/flashbangs(src)
	new /obj/item/weapon/storage/box/zipties(src)
	new /obj/item/weapon/reagent_containers/spray/pepper(src)
	new /obj/item/weapon/melee/baton/loaded(src)
	new /obj/item/weapon/gun/energy/gun/advtaser(src)
	new /obj/item/weapon/storage/belt/security/full(src)
	return



/obj/structure/closet/secure_closet/security
	name = "security officer's locker"
	req_access = list(access_security)
	icon_state = "sec1"
	icon_closed = "sec"
	icon_locked = "sec1"
	icon_opened = "secopen"
	icon_broken = "secbroken"
	icon_off = "secoff"

/obj/structure/closet/secure_closet/security/New()
	..()
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/device/radio/headset/headset_sec/alt(src)
	new /obj/item/clothing/head/beret/sec(src)
	new /obj/item/clothing/head/soft/sec(src)
	new /obj/item/weapon/reagent_containers/spray/pepper(src)
	new /obj/item/device/flash/handheld(src)
	new /obj/item/weapon/grenade/flashbang(src)
	new /obj/item/weapon/storage/belt/security/full(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	return


/obj/structure/closet/secure_closet/security/sec

/obj/structure/closet/secure_closet/security/sec/New()
	new /obj/item/weapon/melee/baton/loaded(src)
	..()
	return

/obj/structure/closet/secure_closet/security/cargo

/obj/structure/closet/secure_closet/security/cargo/New()
	new /obj/item/clothing/tie/armband/cargo(src)
	new /obj/item/device/encryptionkey/headset_cargo(src)
	..()
	return

/obj/structure/closet/secure_closet/security/engine

/obj/structure/closet/secure_closet/security/engine/New()
	new /obj/item/clothing/tie/armband/engine(src)
	new /obj/item/device/encryptionkey/headset_eng(src)
	..()
	return

/obj/structure/closet/secure_closet/security/science

/obj/structure/closet/secure_closet/security/science/New()
	new /obj/item/clothing/tie/armband/science(src)
	new /obj/item/device/encryptionkey/headset_sci(src)
	..()
	return

/obj/structure/closet/secure_closet/security/med

/obj/structure/closet/secure_closet/security/med/New()
	new /obj/item/clothing/tie/armband/medblue(src)
	new /obj/item/device/encryptionkey/headset_med(src)
	..()
	return


/obj/structure/closet/secure_closet/detective
	name = "\proper detective's cabinet"
	req_access = list(access_forensics_lockers)
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"

/obj/structure/closet/secure_closet/detective/New()
	..()
	new /obj/item/clothing/under/rank/det(src)
	new /obj/item/clothing/suit/det_suit(src)
	new /obj/item/clothing/head/det_hat(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/under/rank/det/grey(src)
	new /obj/item/clothing/tie/waistcoat(src)
	new /obj/item/clothing/suit/det_suit/grey(src)
	new /obj/item/clothing/head/fedora(src)
	new /obj/item/clothing/shoes/laceup(src)
	new /obj/item/weapon/storage/box/evidence(src)
	new /obj/item/weapon/clipboard(src)
	new /obj/item/device/radio/headset/headset_sec/alt(src)
	new /obj/item/device/detective_scanner(src)
	new /obj/item/clothing/suit/armor/vest/det_suit(src)
	new /obj/item/ammo_box/c38(src)
	new /obj/item/ammo_box/c38(src)
	new /obj/item/weapon/storage/belt/holster(src)
	new /obj/item/weapon/gun/projectile/revolver/detective(src)
	return

/obj/structure/closet/secure_closet/detective/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened

/obj/structure/closet/secure_closet/injection
	name = "lethal injections"
	req_access = list(access_hos)

/obj/structure/closet/secure_closet/injection/New()
	..()
	new /obj/item/weapon/reagent_containers/syringe/lethal/choral(src)
	new /obj/item/weapon/reagent_containers/syringe/lethal/choral(src)
	new /obj/item/weapon/reagent_containers/syringe/lethal/choral(src)
	new /obj/item/weapon/reagent_containers/syringe/lethal/choral(src)
	new /obj/item/weapon/reagent_containers/syringe/lethal/choral(src)


/obj/structure/closet/secure_closet/brig
	name = "brig locker"
	req_access = list(access_brig)
	anchored = 1
	var/id = null

/obj/structure/closet/secure_closet/brig/New()
	new /obj/item/clothing/under/rank/prisoner( src )
	new /obj/item/clothing/shoes/sneakers/orange( src )
	return



/obj/structure/closet/secure_closet/courtroom
	name = "courtroom locker"
	req_access = list(access_court)

/obj/structure/closet/secure_closet/courtroom/New()
	..()
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/weapon/paper/Court (src)
	new /obj/item/weapon/paper/Court (src)
	new /obj/item/weapon/paper/Court (src)
	new /obj/item/weapon/pen (src)
	new /obj/item/clothing/suit/judgerobe (src)
	new /obj/item/clothing/head/powdered_wig (src)
	new /obj/item/weapon/storage/briefcase(src)
	return

/obj/structure/closet/secure_closet/wall
	name = "wall locker"
	req_access = list(access_security)
	icon_state = "wall-locker1"
	density = 1
	icon_closed = "wall-locker"
	icon_locked = "wall-locker1"
	icon_opened = "wall-lockeropen"
	icon_broken = "wall-lockerbroken"
	icon_off = "wall-lockeroff"

	//too small to put a man in
	large = 0

/obj/structure/closet/secure_closet/wall/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened
