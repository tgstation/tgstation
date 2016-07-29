
/obj/structure/closet/secure_closet/chef_personal
	name = "Chef's Locker"
	req_access = list(ACCESS_KITCHEN)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/chef(src)
		//
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/device/radio/headset(src)

/obj/structure/closet/secure_closet/bar
	name = "Booze"
	req_access = list(ACCESS_BAR)


	New()
		..()
		sleep(2)
		new /obj/item/weapon/reagent_containers/food/drinks/beer( src )
		new /obj/item/weapon/reagent_containers/food/drinks/beer( src )
		new /obj/item/weapon/reagent_containers/food/drinks/beer( src )
		new /obj/item/weapon/reagent_containers/food/drinks/beer( src )
		new /obj/item/weapon/reagent_containers/food/drinks/beer( src )
		new /obj/item/weapon/reagent_containers/food/drinks/beer( src )
		new /obj/item/weapon/reagent_containers/food/drinks/beer( src )
		new /obj/item/weapon/reagent_containers/food/drinks/beer( src )
		new /obj/item/weapon/reagent_containers/food/drinks/beer( src )
		new /obj/item/weapon/reagent_containers/food/drinks/beer( src )
		return

/obj/structure/closet/secure_closet/barman_personal
	name = "Barman's Locker"
	req_access = list(ACCESS_BAR)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/bartender(src)
		//
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/device/radio/headset(src)
		new /obj/item/ammo_casing/shotgun/beanbag(BPK)
		new /obj/item/ammo_casing/shotgun/beanbag(BPK)
		new /obj/item/ammo_casing/shotgun/beanbag(BPK)
		new /obj/item/ammo_casing/shotgun/beanbag(BPK)

/obj/structure/closet/secure_closet/hydro_personal
	name = "Botanist's Locker"
	req_access = list(ACCESS_HYDROPONICS)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/hydro
		//
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/device/analyzer/plant_analyzer(src)
		new /obj/item/device/radio/headset(src)

/obj/structure/closet/secure_closet/janitor_personal
	name = "Janitor's Locker"
	req_access = list(ACCESS_JANITOR)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/janitor(src)
		//
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/device/pda/janitor(src)

/obj/structure/closet/secure_closet/lawyer_personal
	name = "Lawyer's Locker"
	req_access = list(ACCESS_LAWYER)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/lawyer(src)
		//
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/device/pda/lawyer(src)
		new /obj/item/device/detective_scanner(src)
		new /obj/item/weapon/storage/briefcase(src)

/obj/structure/closet/secure_closet/librarian_personal
	name = "Librarian's Locker"
	req_access = list(ACCESS_LIBRARY)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/librarian(src)
		//
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/weapon/barcodescanner(src)

/obj/structure/closet/secure_closet/counselor_personal
	name = "Counselor's Locker"
	req_access = list(ACCESS_CHAPEL_OFFICE)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/chaplain(src)
		//
		new /obj/item/weapon/storage/backpack/cultpack (src)
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/weapon/storage/bible(src)
		new /obj/item/device/pda/chaplain(src)
		new /obj/item/device/radio/headset(src)
		new /obj/item/weapon/candlepack(src)
		new /obj/item/weapon/candlepack(src)
