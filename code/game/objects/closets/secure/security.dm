/obj/structure/closet/secure_closet/captains
	name = "Captain's Closet"
	req_access = list(access_captain)


	New()
		..()
		sleep(2)
		new /obj/item/clothing/suit/armor/captain(src)
		new /obj/item/clothing/head/helmet/cap(src)
		new /obj/item/wardrobe/captain(src)
		new /obj/item/wardrobe/captain(src)
		return



/obj/structure/closet/secure_closet/hop
	name = "Head of Personnel"
	req_access = list(access_hop)


	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/hop(src)
		new /obj/item/wardrobe/hop(src)
		return



/obj/structure/closet/secure_closet/hos
	name = "Head Of Security"
	req_access = list(access_hos)


	New()
		..()
		sleep(2)
		new /obj/item/weapon/storage/lockbox/loyalty(src)
		new /obj/item/weapon/storage/flashbang_kit(src)
		new /obj/item/clothing/under/jensen(src)
		new /obj/item/clothing/suit/armor/hos/jensen(src)
		new /obj/item/clothing/head/helmet/HoS/dermal(src)
		new /obj/item/wardrobe/hos(src)
		new /obj/item/wardrobe/hos(src)
		return



/obj/structure/closet/secure_closet/warden
	name = "Warden's Locker"
	req_access = list(access_armory)


	New()
		..()
		sleep(2)
		new /obj/item/weapon/storage/flashbang_kit(src)
		new /obj/item/wardrobe/warden(src)
		new /obj/item/wardrobe/warden(src)
		new /obj/item/wardrobe/warden(src)
		new /obj/item/wardrobe/warden(src)
		return



/obj/structure/closet/secure_closet/security
	name = "Security Locker"
	req_access = list(access_security)


	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/officer(src)
		new /obj/item/wardrobe/officer(src)
		new /obj/item/wardrobe/officer(src)
		new /obj/item/wardrobe/officer(src)
		new /obj/item/wardrobe/officer(src)
		new /obj/item/wardrobe/officer(src)
		return



/obj/structure/closet/secure_closet/detective
	name = "Detective"
	req_access = list(access_forensics_lockers)
	icon_state = "cabinetdetective"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"


	New()
		..()
		sleep(2)
		new /obj/item/weapon/reagent_containers/food/drinks/dflask(src)
		new /obj/item/weapon/zippo(src)
		new /obj/item/weapon/pepperspray/small(src)
		new /obj/item/wardrobe/detective(src)
		new /obj/item/wardrobe/detective(src)
		new /obj/item/wardrobe/detective(src)
		return



/obj/structure/closet/secure_closet/injection
	name = "Lethal Injections"
	req_access = list(access_hos)


	New()
		..()
		sleep(2)
		new /obj/item/weapon/reagent_containers/ld50_syringe/choral(src)
		new /obj/item/weapon/reagent_containers/ld50_syringe/choral(src)
		return



/obj/structure/closet/secure_closet/brig
	name = "Brig Locker"
	req_access = list(access_brig)
	anchored = 1
	var/id = null

	New()
		new /obj/item/clothing/under/color/orange( src )
		new /obj/item/clothing/shoes/orange( src )
		return



/obj/structure/closet/secure_closet/courtroom
	name = "Courtroom Locker"
	req_access = list(access_court)

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
