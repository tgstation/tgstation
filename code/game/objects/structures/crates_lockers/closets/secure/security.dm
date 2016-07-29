<<<<<<< HEAD
/obj/structure/closet/secure_closet/captains
	name = "\proper captain's locker"
	req_access = list(access_captain)
	icon_state = "cap"

/obj/structure/closet/secure_closet/captains/New()
	..()
	new /obj/item/clothing/suit/hooded/wintercoat/captain(src)
	if(prob(50))
		new /obj/item/weapon/storage/backpack/captain(src)
	else
		new /obj/item/weapon/storage/backpack/satchel/cap(src)
	new /obj/item/clothing/suit/cloak/cap(src)
	new /obj/item/weapon/storage/backpack/dufflebag/captain(src)
	new /obj/item/clothing/suit/captunic(src)
	new /obj/item/clothing/under/captainparade(src)
	new /obj/item/clothing/head/caphat/parade(src)
	new /obj/item/clothing/under/rank/captain(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/alt(src)
	new /obj/item/weapon/cartridge/captain(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/weapon/storage/box/silver_ids(src)
	new /obj/item/device/radio/headset/heads/captain/alt(src)
	new /obj/item/device/radio/headset/heads/captain(src)
	new /obj/item/clothing/glasses/sunglasses/gar/supergar(src)
	new /obj/item/clothing/gloves/color/captain(src)
	new /obj/item/weapon/restraints/handcuffs/cable/zipties(src)
	new /obj/item/weapon/storage/belt/rapier(src)
	new /obj/item/weapon/gun/energy/gun(src)
	new /obj/item/weapon/door_remote/captain(src)

/obj/structure/closet/secure_closet/hop
	name = "\proper head of personnel's locker"
	req_access = list(access_hop)
	icon_state = "hop"

/obj/structure/closet/secure_closet/hop/New()
	..()
	new /obj/item/clothing/under/rank/head_of_personnel(src)
	new /obj/item/clothing/head/hopcap(src)
	new /obj/item/weapon/cartridge/hop(src)
	new /obj/item/device/radio/headset/heads/hop(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/weapon/storage/box/ids(src)
	new /obj/item/weapon/storage/box/ids(src)
	new /obj/item/device/megaphone/command(src)
	new /obj/item/clothing/suit/armor/vest/alt(src)
	new /obj/item/device/assembly/flash/handheld(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/weapon/restraints/handcuffs/cable/zipties(src)
	new /obj/item/weapon/gun/energy/gun(src)
	new /obj/item/clothing/tie/petcollar(src)
	new /obj/item/weapon/door_remote/civillian(src)

/obj/structure/closet/secure_closet/hos
	name = "\proper head of security's locker"
	req_access = list(access_hos)
	icon_state = "hos"

/obj/structure/closet/secure_closet/hos/New()
	..()
	new /obj/item/clothing/suit/cloak/hos(src)
	new /obj/item/weapon/cartridge/hos(src)
	new /obj/item/device/radio/headset/heads/hos(src)
	new /obj/item/clothing/under/hosparadefem(src)
	new /obj/item/clothing/under/hosparademale(src)
	new /obj/item/clothing/suit/armor/vest/leather(src)
	new /obj/item/clothing/suit/armor/hos(src)
	new /obj/item/clothing/under/rank/head_of_security/alt(src)
	new /obj/item/clothing/head/HoS(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/gars/supergars(src)
	new /obj/item/device/megaphone/sec(src)
	new /obj/item/weapon/holosign_creator/security(src)
	new /obj/item/weapon/storage/lockbox/loyalty(src)
	new /obj/item/clothing/mask/gas/sechailer/swat(src)
	new /obj/item/weapon/storage/box/flashbangs(src)
	new /obj/item/weapon/shield/riot/tele(src)
	new /obj/item/weapon/storage/belt/security/full(src)
	new /obj/item/weapon/gun/energy/gun/hos(src)
	new /obj/item/device/flashlight/seclite(src)
	new /obj/item/weapon/pinpointer(src)

/obj/structure/closet/secure_closet/warden
	name = "\proper warden's locker"
	req_access = list(access_armory)
	icon_state = "warden"

/obj/structure/closet/secure_closet/warden/New()
	..()
	new /obj/item/device/radio/headset/headset_sec(src)
	new /obj/item/clothing/suit/armor/vest/warden(src)
	new /obj/item/clothing/head/warden(src)
	new /obj/item/clothing/head/beret/sec/navywarden(src)
	new /obj/item/clothing/suit/armor/vest/warden/alt(src)
	new /obj/item/clothing/under/rank/warden/navyblue(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/weapon/holosign_creator/security(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/weapon/storage/box/zipties(src)
	new /obj/item/weapon/storage/box/flashbangs(src)
	new /obj/item/weapon/storage/belt/security/full(src)
	new /obj/item/device/flashlight/seclite(src)
	new /obj/item/clothing/gloves/krav_maga/sec(src)
	new /obj/item/weapon/door_remote/head_of_security(src)

/obj/structure/closet/secure_closet/security
	name = "security officer's locker"
	req_access = list(access_security)
	icon_state = "sec"

/obj/structure/closet/secure_closet/security/New()
	..()
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/clothing/head/helmet/sec(src)
	new /obj/item/device/radio/headset/headset_sec(src)
	new /obj/item/device/radio/headset/headset_sec/alt(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/device/flashlight/seclite(src)

/obj/structure/closet/secure_closet/security/sec

/obj/structure/closet/secure_closet/security/sec/New()
	..()
	new /obj/item/weapon/storage/belt/security/full(src)

/obj/structure/closet/secure_closet/security/cargo

/obj/structure/closet/secure_closet/security/cargo/New()
	..()
	new /obj/item/clothing/tie/armband/cargo(src)
	new /obj/item/device/encryptionkey/headset_cargo(src)

/obj/structure/closet/secure_closet/security/engine

/obj/structure/closet/secure_closet/security/engine/New()
	..()
	new /obj/item/clothing/tie/armband/engine(src)
	new /obj/item/device/encryptionkey/headset_eng(src)

/obj/structure/closet/secure_closet/security/science

/obj/structure/closet/secure_closet/security/science/New()
	..()
	new /obj/item/clothing/tie/armband/science(src)
	new /obj/item/device/encryptionkey/headset_sci(src)

/obj/structure/closet/secure_closet/security/med

/obj/structure/closet/secure_closet/security/med/New()
	..()
	new /obj/item/clothing/tie/armband/medblue(src)
	new /obj/item/device/encryptionkey/headset_med(src)

/obj/structure/closet/secure_closet/detective
	name = "\proper detective's cabinet"
	req_access = list(access_forensics_lockers)
	icon_state = "cabinet"
	burn_state = FLAMMABLE
	burntime = 20

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
	new /obj/item/device/radio/headset/headset_sec(src)
	new /obj/item/device/detective_scanner(src)
	new /obj/item/weapon/holosign_creator/security(src)
	new /obj/item/weapon/reagent_containers/spray/pepper(src)
	new /obj/item/clothing/suit/armor/vest/det_suit(src)
	new /obj/item/ammo_box/c38(src)
	new /obj/item/ammo_box/c38(src)
	new /obj/item/weapon/storage/belt/holster(src)
	new /obj/item/weapon/gun/projectile/revolver/detective(src)

/obj/structure/closet/secure_closet/injection
	name = "lethal injections"
	req_access = list(access_hos)

/obj/structure/closet/secure_closet/injection/New()
	..()
	for(var/i in 1 to 5)
		new /obj/item/weapon/reagent_containers/syringe/lethal/execution(src)

/obj/structure/closet/secure_closet/brig
	name = "brig locker"
	req_access = list(access_brig)
	anchored = 1
	var/id = null

/obj/structure/closet/secure_closet/brig/New()
	..()
	new /obj/item/clothing/under/rank/prisoner( src )
	new /obj/item/clothing/shoes/sneakers/orange( src )

/obj/structure/closet/secure_closet/courtroom
	name = "courtroom locker"
	req_access = list(access_court)

/obj/structure/closet/secure_closet/courtroom/New()
	..()
	new /obj/item/clothing/shoes/sneakers/brown(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/paper/Court (src)
	new /obj/item/weapon/pen (src)
	new /obj/item/clothing/suit/judgerobe (src)
	new /obj/item/clothing/head/powdered_wig (src)
	new /obj/item/weapon/storage/briefcase(src)

/obj/structure/closet/secure_closet/armory1
	name = "armory armor locker"
	req_access = list(access_armory)
	icon_state = "armory"

/obj/structure/closet/secure_closet/armory1/New()
	..()
	new /obj/item/clothing/suit/armor/laserproof(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/suit/armor/riot(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/head/helmet/riot(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/shield/riot(src)

/obj/structure/closet/secure_closet/armory2
	name = "armory ballistics locker"
	req_access = list(access_armory)
	icon_state = "armory"

/obj/structure/closet/secure_closet/armory2/New()
	..()
	new /obj/item/weapon/storage/box/firingpins(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/storage/box/rubbershot(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/gun/projectile/shotgun/riot(src)

/obj/structure/closet/secure_closet/armory3
	name = "armory energy gun locker"
	req_access = list(access_armory)
	icon_state = "armory"

/obj/structure/closet/secure_closet/armory3/New()
	..()
	new /obj/item/weapon/storage/box/firingpins(src)
	new /obj/item/weapon/gun/energy/ionrifle(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/gun/energy/gun(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/gun/energy/laser(src)

/obj/structure/closet/secure_closet/tac
	name = "armory tac locker"
	req_access = list(access_armory)
	icon_state = "tac"

/obj/structure/closet/secure_closet/tac/New()
	..()
	new /obj/item/weapon/gun/projectile/automatic/wt550(src)
	new /obj/item/clothing/head/helmet/alt(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/clothing/suit/armor/bulletproof(src)

/obj/structure/closet/secure_closet/lethalshots
	name = "shotgun lethal rounds"
	req_access = list(access_armory)
	icon_state = "tac"

/obj/structure/closet/secure_closet/lethalshots/New()
	..()
	for(var/i in 1 to 3)
		new /obj/item/weapon/storage/box/lethalshot(src)
=======
/obj/structure/closet/secure_closet/captains
	name = "Captain's Locker"
	req_access = list(access_captain)
	icon_state = "capsecure1"
	icon_closed = "capsecure"
	icon_locked = "capsecure1"
	icon_opened = "capsecureopen"
	icon_broken = "capsecurebroken"
	icon_off = "capsecureoff"

	New()
		..()
		sleep(2)
		if(prob(50))
			new /obj/item/weapon/storage/backpack/captain(src)
		else
			new /obj/item/weapon/storage/backpack/satchel_cap(src)
		new /obj/item/clothing/suit/captunic(src)
		new /obj/item/clothing/suit/storage/capjacket(src)
		new /obj/item/clothing/head/helmet/cap(src)
		new /obj/item/clothing/under/rank/captain(src)
		new /obj/item/clothing/suit/armor/vest(src)
		new /obj/item/weapon/cartridge/captain(src)
		new /obj/item/clothing/head/helmet/tactical/swat(src)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/device/radio/headset/heads/captain(src)
		new /obj/item/clothing/gloves/captain(src)
		new /obj/item/weapon/gun/energy/gun(src)
		new /obj/item/clothing/suit/armor/captain(src)
		new /obj/item/weapon/melee/telebaton(src)
		new /obj/item/clothing/under/dress/dress_cap(src)
		new /obj/item/device/gps/secure(src)
		return



/obj/structure/closet/secure_closet/hop
	name = "Head of Personnel's Locker"
	req_access = list(access_hop)
	icon_state = "hopsecure1"
	icon_closed = "hopsecure"
	icon_locked = "hopsecure1"
	icon_opened = "hopsecureopen"
	icon_broken = "hopsecurebroken"
	icon_off = "hopsecureoff"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/glasses/sunglasses(src)
		new /obj/item/clothing/suit/storage/Hop_Coat(src)
		new /obj/item/clothing/head/helmet/hopcap(src)
		new /obj/item/weapon/cartridge/hop(src)
		new /obj/item/device/radio/headset/heads/hop(src)
		new /obj/item/weapon/storage/box/ids(src)
		new /obj/item/weapon/storage/box/ids(src)
		new /obj/item/weapon/gun/energy/gun(src)
		new /obj/item/device/flash(src)
		new /obj/item/device/gps/secure(src)
		return

/obj/structure/closet/secure_closet/hop2
	name = "Head of Personnel's Attire"
	req_access = list(access_hop)
	icon_state = "hopsecure1"
	icon_closed = "hopsecure"
	icon_locked = "hopsecure1"
	icon_opened = "hopsecureopen"
	icon_broken = "hopsecurebroken"
	icon_off = "hopsecureoff"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/under/rank/head_of_personnel(src)
		new /obj/item/clothing/under/dress/dress_hop(src)
		new /obj/item/clothing/under/dress/dress_hr(src)
		new /obj/item/clothing/under/lawyer/female(src)
		new /obj/item/clothing/under/lawyer/black(src)
		new /obj/item/clothing/under/lawyer/red(src)
		new /obj/item/clothing/under/lawyer/oldman(src)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/clothing/shoes/black(src)
		new /obj/item/clothing/shoes/leather(src)
		new /obj/item/clothing/shoes/white(src)
		return



/obj/structure/closet/secure_closet/hos
	name = "Head of Security's Locker"
	req_access = list(access_hos)
	icon_state = "hossecure1"
	icon_closed = "hossecure"
	icon_locked = "hossecure1"
	icon_opened = "hossecureopen"
	icon_broken = "hossecurebroken"
	icon_off = "hossecureoff"

	New()
		..()
		sleep(2)
		if(prob(50))
			new /obj/item/weapon/storage/backpack/security(src)
		else
			new /obj/item/weapon/storage/backpack/satchel_sec(src)
		new /obj/item/clothing/head/helmet/tactical/HoS(src)
		new /obj/item/device/flashlight/tactical(src)
		new /obj/item/clothing/accessory/holster/knife/boot/preloaded(src)
		new /obj/item/clothing/suit/armor/vest(src)
		new /obj/item/clothing/under/rank/head_of_security/jensen(src)
		new /obj/item/clothing/suit/armor/hos/jensen(src)
		new /obj/item/clothing/head/helmet/tactical/HoS/dermal(src)
		new /obj/item/weapon/cartridge/hos(src)
		new /obj/item/device/detective_scanner(src)
		new /obj/item/device/radio/headset/heads/hos(src)
		new /obj/item/clothing/glasses/sunglasses/sechud(src)
		new /obj/item/weapon/shield/riot(src)
		new /obj/item/weapon/storage/lockbox/loyalty(src)
		new /obj/item/weapon/storage/box/flashbangs(src)
		new /obj/item/weapon/storage/belt/security(src)
		new /obj/item/device/flash(src)
		new /obj/item/weapon/melee/baton/loaded(src)
		new /obj/item/weapon/gun/energy/gun(src)
		new /obj/item/clothing/accessory/holster/handgun/waist(src)
		new /obj/item/weapon/melee/telebaton(src)
		new /obj/item/device/gps/secure(src)
		return



/obj/structure/closet/secure_closet/warden
	name = "Warden's Locker"
	req_access = list(access_armory)
	icon_state = "wardensecure1"
	icon_closed = "wardensecure"
	icon_locked = "wardensecure1"
	icon_opened = "wardensecureopen"
	icon_broken = "wardensecurebroken"
	icon_off = "wardensecureoff"


	New()
		..()
		sleep(2)
		if(prob(50))
			new /obj/item/weapon/storage/backpack/security(src)
		else
			new /obj/item/weapon/storage/backpack/satchel_sec(src)
		new /obj/item/clothing/suit/armor/vest/security(src)
		new /obj/item/clothing/under/rank/warden(src)
		new /obj/item/clothing/suit/armor/vest/warden(src)
		new /obj/item/clothing/head/helmet/tactical/warden(src)
		new /obj/item/device/flashlight/tactical(src)
//		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/device/radio/headset/headset_sec(src)
		new /obj/item/clothing/glasses/sunglasses/sechud(src)
		new /obj/item/weapon/storage/box/flashbangs(src)
		new /obj/item/weapon/storage/belt/security(src)
		new /obj/item/weapon/reagent_containers/spray/pepper(src)
		new /obj/item/weapon/melee/baton/loaded(src)
		new /obj/item/weapon/gun/energy/taser(src)
		new /obj/item/weapon/storage/box/bolas(src)
		new /obj/item/weapon/batteringram(src)
		new /obj/item/device/gps/secure(src)
		return



/obj/structure/closet/secure_closet/security
	name = "Security Officer's Locker"
	req_access = list(access_security)
	icon_state = "sec1"
	icon_closed = "sec"
	icon_locked = "sec1"
	icon_opened = "secopen"
	icon_broken = "secbroken"
	icon_off = "secoff"

	New()
		..()
		sleep(2)
		if(prob(50))
			new /obj/item/weapon/storage/backpack/security(src)
		else
			new /obj/item/weapon/storage/backpack/satchel_sec(src)
		new /obj/item/clothing/suit/armor/vest/security(src)
		new /obj/item/clothing/head/helmet/tactical/sec/preattached(src)
		new /obj/item/clothing/accessory/holster/knife/boot/preloaded(src)
//		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/device/radio/headset/headset_sec(src)
		new /obj/item/weapon/storage/belt/security(src)
		new /obj/item/device/flash(src)
		new /obj/item/weapon/reagent_containers/spray/pepper(src)
		new /obj/item/weapon/grenade/flashbang(src)
		new /obj/item/weapon/melee/baton/loaded(src)
		new /obj/item/weapon/gun/energy/taser(src)
		new /obj/item/clothing/glasses/sunglasses/sechud(src)
		new /obj/item/taperoll/police(src)
		new /obj/item/device/hailer(src) //wonder if vg would spam this
		new /obj/item/clothing/gloves/black(src)
		new /obj/item/device/gps/secure(src)
		return


/obj/structure/closet/secure_closet/security/cargo

	New()
		..()
		new /obj/item/clothing/accessory/armband/cargo(src)
		new /obj/item/device/encryptionkey/headset_cargo(src)
		return

/obj/structure/closet/secure_closet/security/engine

	New()
		..()
		new /obj/item/clothing/accessory/armband/engine(src)
		new /obj/item/device/encryptionkey/headset_eng(src)
		return

/obj/structure/closet/secure_closet/security/science

	New()
		..()
		new /obj/item/clothing/accessory/armband/science(src)
		new /obj/item/device/encryptionkey/headset_sci(src)
		return

/obj/structure/closet/secure_closet/security/med

	New()
		..()
		new /obj/item/clothing/accessory/armband/medgreen(src)
		new /obj/item/device/encryptionkey/headset_med(src)
		return


/obj/structure/closet/secure_closet/detective
	name = "Detective's Cabinet"
	req_access = list(access_forensics_lockers)
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/under/det(src)
		new /obj/item/clothing/suit/storage/det_suit(src)
		new /obj/item/clothing/suit/storage/forensics/blue(src)
		new /obj/item/clothing/suit/storage/forensics/red(src)
		new /obj/item/clothing/gloves/black(src)
		new /obj/item/clothing/head/det_hat(src)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/weapon/storage/box/evidence(src)
		new /obj/item/device/radio/headset/headset_sec(src)
		new /obj/item/device/detective_scanner(src)
		new /obj/item/clothing/suit/armor/det_suit(src)
		new /obj/item/ammo_storage/speedloader/c38(src)
		new /obj/item/ammo_storage/box/c38(src)
		new /obj/item/ammo_storage/box/c38(src)
		new /obj/item/weapon/gun/projectile/detective(src)
		new /obj/item/clothing/accessory/holster/handgun/wornout(src)
		new /obj/item/device/gps/secure(src)
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
	name = "Lethal Injections"
	req_access = list(access_captain)


	New()
		..()
		sleep(2)
		new /obj/item/weapon/reagent_containers/syringe/giant/chloral(src)
		new /obj/item/weapon/reagent_containers/syringe/giant/chloral(src)
		return



/obj/structure/closet/secure_closet/brig
	name = "Brig Locker"
	req_access = list(access_brig)
	anchored = 1
	var/id_tag = null

	New()
		..()
		new /obj/item/clothing/under/color/prisoner(src)
		new /obj/item/clothing/shoes/orange(src)
		return



/obj/structure/closet/secure_closet/courtroom
	name = "Courtroom Locker"
	req_access = list(access_court)

	New()
		..()
		sleep(2)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/weapon/paper/Court(src)
		new /obj/item/weapon/paper/Court(src)
		new /obj/item/weapon/paper/Court(src)
		new /obj/item/weapon/pen (src)
		new /obj/item/clothing/suit/judgerobe(src)
		new /obj/item/clothing/head/powdered_wig(src)
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
