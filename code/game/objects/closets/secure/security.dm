/obj/structure/closet/secure_closet/captains
	name = "Captain's Locker"
	req_access = list(ACCESS_CAPTAIN)
	icon_state = "capsecure1"
	icon_closed = "capsecure"
	icon_locked = "capsecure1"
	icon_opened = "capsecureopen"
	icon_broken = "capsecurebroken"
	icon_off = "capsecureoff"

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/captain(src)
		//
		new /obj/item/device/pda/captain(src)
		new /obj/item/weapon/storage/id_kit(src)
		new /obj/item/clothing/suit/armor/captain(src)
		new /obj/item/clothing/head/caphat(src)
		new /obj/item/clothing/glasses/sunglasses(src)
		new /obj/item/clothing/suit/armor/vest(src)
		new /obj/item/weapon/cartridge/captain(src)
		new /obj/item/clothing/head/helmet/swat(src)
		new /obj/item/device/radio/headset/heads/captain(src)
		new /obj/item/weapon/reagent_containers/food/drinks/flask(src)
		new /obj/item/weapon/gun/energy/gun(src)
		return



/obj/structure/closet/secure_closet/hop
	name = "Head of Personnel's Locker"
	req_access = list(ACCESS_HOP)
	icon_state = "hopsecure1"
	icon_closed = "hopsecure"
	icon_locked = "hopsecure1"
	icon_opened = "hopsecureopen"
	icon_broken = "hopsecurebroken"
	icon_off = "hopsecureoff"

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/hop(src)
		//
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/device/pda/heads/hop(src)
		new /obj/item/weapon/cartridge/hop(src)
		new /obj/item/device/radio/headset/heads/hop(src)
		new /obj/item/weapon/storage/id_kit(src)
		new /obj/item/weapon/gun/energy/gun(src)
		new /obj/item/device/flash(src)
		new /obj/item/clothing/suit/armor/vest(src)
		new /obj/item/clothing/head/helmet(src)
		new /obj/item/clothing/glasses/sunglasses(src)
		return



/obj/structure/closet/secure_closet/hos
	name = "Head of Security's Locker"
	req_access = list(ACCESS_HOS)
	icon_state = "hossecure1"
	icon_closed = "hossecure"
	icon_locked = "hossecure1"
	icon_opened = "hossecureopen"
	icon_broken = "hossecurebroken"
	icon_off = "hossecureoff"

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/hos(src)
		//
		var/obj/item/weapon/storage/backpack/security/BPK = new /obj/item/weapon/storage/backpack/security(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/device/flash(B)
		new /obj/item/device/pda/heads/hos(src)
		new /obj/item/weapon/cartridge/hos(src)
		new /obj/item/clothing/glasses/sunglasses/sechud(src)
		new /obj/item/weapon/storage/flashbang_kit(src)
		new /obj/item/weapon/storage/lockbox/loyalty(src)
		new /obj/item/weapon/melee/baton(src)
		new /obj/item/weapon/gun/energy/gun(src)
		return

/obj/structure/closet/secure_closet/warden
	name = "Warden's Locker"
	req_access = list(ACCESS_ARMORY)
	icon_state = "wardensecure1"
	icon_closed = "wardensecure"
	icon_locked = "wardensecure1"
	icon_opened = "wardensecureopen"
	icon_broken = "wardensecurebroken"
	icon_off = "wardensecureoff"


	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/warden(src)
		//
		var/obj/item/weapon/storage/backpack/security/BPK = new /obj/item/weapon/storage/backpack/security(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/device/flash(B)
		new /obj/item/device/pda/security(src)
		new /obj/item/clothing/suit/armor/vest(src)
//		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/device/radio/headset/headset_sec(src)
		new /obj/item/weapon/storage/flashbang_kit(src)
		new /obj/item/weapon/melee/baton(src)
		new /obj/item/weapon/gun/energy/taser(src)
		new /obj/item/clothing/glasses/sunglasses/sechud(src)
		return



/obj/structure/closet/secure_closet/security
	name = "Security Officer's Locker"
	req_access = list(ACCESS_SECURITY)
	icon_state = "sec1"
	icon_closed = "sec"
	icon_locked = "sec1"
	icon_opened = "secopen"
	icon_broken = "secbroken"
	icon_off = "secoff"

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/officer(src)
		new /obj/item/wardrobe/officer(src)
		//
		var/obj/item/weapon/storage/backpack/security/BPK = new /obj/item/weapon/storage/backpack/security(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/taperoll/police(src)
		new /obj/item/clothing/suit/armor/vest(src)
		new /obj/item/clothing/suit/storage/gearharness(src)
		new /obj/item/clothing/head/helmet(src)
//		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/device/pda/security(src)
		new /obj/item/device/radio/headset/headset_sec(src)
		new /obj/item/weapon/storage/belt/security(src)
		new /obj/item/device/flash(src)
		new /obj/item/weapon/pepperspray(src)
		new /obj/item/weapon/flashbang(src)
		new /obj/item/weapon/melee/baton(src)
		new /obj/item/clothing/glasses/sunglasses/sechud(src)
		return



/obj/structure/closet/secure_closet/detective
	name = "Detective's Cabinet"
	req_access = list(ACCESS_FORENSICS_LOCKERS)
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/detective(src)
		//
		var/obj/item/weapon/storage/backpack/security/BPK = new /obj/item/weapon/storage/backpack/security(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		var/obj/item/weapon/clipboard/C = new(B)
		new /obj/item/weapon/pen(C)
		new /obj/item/weapon/clipboard/notebook(src)
		new /obj/item/device/detective_scanner(src)
		new /obj/item/taperoll/police(src)
		new /obj/item/weapon/storage/box/evidence(src)
		new /obj/item/device/pda/detective(src)
		new /obj/item/device/radio/headset/headset_sec(src)
		new /obj/item/weapon/cartridge/detective(src)
		//
		new /obj/item/weapon/reagent_containers/food/drinks/dflask(src)
		new /obj/item/weapon/lighter/zippo(B)
		new /obj/item/weapon/pepperspray/small(src)
		return



/obj/structure/closet/secure_closet/injection
	name = "Lethal Injections"
	req_access = list(ACCESS_HOS)


	New()
		..()
		sleep(2)
		new /obj/item/weapon/reagent_containers/ld50_syringe/choral(src)
		new /obj/item/weapon/reagent_containers/ld50_syringe/choral(src)
		return



/obj/structure/closet/secure_closet/brig
	name = "Brig Locker"
	req_access = list(ACCESS_BRIG)
	anchored = 1
	var/id = null

	New()
		new /obj/item/clothing/under/color/orange( src )
		new /obj/item/clothing/shoes/orange( src )
		return



/obj/structure/closet/secure_closet/courtroom
	name = "Courtroom Locker"
	req_access = list(ACCESS_COURT)

	New()
		..()
		sleep(2)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/weapon/paper/Court (src)
		new /obj/item/weapon/paper/Court (src)
		new /obj/item/weapon/paper/Court (src)
		new /obj/item/weapon/pen (src)
		new /obj/item/clothing/suit/judgerobe (src)
		new /obj/item/clothing/head/powdered_wig (src)
		new /obj/item/weapon/storage/briefcase(src)
		return
