/obj/structure/closet/secure_closet/ertCom
	name = "commander's closet"
	desc = "Emergency Response Team equipment locker."
	req_access = list(access_cent_captain)
	icon_state = "capsecure1"
	icon_closed = "capsecure"
	icon_locked = "capsecure1"
	icon_opened = "capsecureopen"
	icon_broken = "capsecurebroken"
	icon_off = "capsecureoff"

/obj/structure/closet/secure_closet/ertCom/New()
	..()
	new /obj/item/weapon/storage/firstaid/regular(src)
	new /obj/item/weapon/storage/box/handcuffs(src)
	new /obj/item/device/aicard(src)
	new /obj/item/weapon/melee/baton/loaded(src)
	new /obj/item/device/flash/handheld(src)
	if(prob(50))
		new /obj/item/ammo_box/magazine/m50(src)
		new /obj/item/ammo_box/magazine/m50(src)
		new /obj/item/weapon/gun/projectile/automatic/pistol/deagle(src)
	else
		new /obj/item/ammo_box/a357(src)
		new /obj/item/ammo_box/a357(src)
		new /obj/item/weapon/gun/projectile/revolver/mateba(src)
	return

/obj/structure/closet/secure_closet/ertSec
	name = "security closet"
	desc = "Emergency Response Team equipment locker."
	req_access = list(access_cent_specops)
	icon_state = "hossecure1"
	icon_closed = "hossecure"
	icon_locked = "hossecure1"
	icon_opened = "hossecureopen"
	icon_broken = "hossecurebroken"
	icon_off = "hossecureoff"

/obj/structure/closet/secure_closet/ertSec/New()
	..()
	new /obj/item/weapon/storage/box/flashbangs(src)
	new /obj/item/weapon/storage/box/teargas(src)
	new /obj/item/weapon/storage/box/flashes(src)
	new /obj/item/weapon/storage/box/handcuffs(src)
	new /obj/item/weapon/melee/baton/loaded(src)
	new /obj/item/weapon/shield/riot/tele(src)
	return

/obj/structure/closet/secure_closet/ertMed
	name = "medical closet"
	desc = "Emergency Response Team equipment locker."
	req_access = list(access_cent_medical)
	icon_state = "cmosecure1"
	icon_closed = "cmosecure"
	icon_locked = "cmosecure1"
	icon_opened = "cmosecureopen"
	icon_broken = "cmosecurebroken"
	icon_off = "cmosecureoff"

/obj/structure/closet/secure_closet/ertMed/New()
	..()
	new /obj/item/weapon/storage/firstaid/o2(src)
	new /obj/item/weapon/storage/firstaid/toxin(src)
	new /obj/item/weapon/storage/firstaid/fire(src)
	new /obj/item/weapon/storage/firstaid/brute(src)
	new /obj/item/weapon/storage/firstaid/regular(src)
	new /obj/item/weapon/melee/baton/loaded(src)
	new /obj/item/weapon/defibrillator/compact/combat(src)
	new /obj/machinery/bot/medbot(src)
	return

/obj/structure/closet/secure_closet/ertEngi
	name = "engineer closet"
	desc = "Emergency Response Team equipment locker."
	req_access = list(access_cent_storage)
	icon_state = "securece1"
	icon_closed = "securece"
	icon_locked = "securece1"
	icon_opened = "secureceopen"
	icon_broken = "securecebroken"
	icon_off = "secureceoff"

/obj/structure/closet/secure_closet/ertEngi/New()
	..()
	new /obj/item/stack/sheet/plasteel(src, 50)
	new /obj/item/stack/sheet/metal(src, 50)
	new /obj/item/stack/sheet/glass(src, 50)
	new /obj/item/clothing/shoes/magboots(src)
	new /obj/item/weapon/storage/box/metalfoam(src)
	new /obj/item/weapon/melee/baton/loaded(src)
	new /obj/item/weapon/rcd_ammo/large(src)
	new /obj/item/weapon/rcd_ammo/large(src)
	new /obj/item/weapon/rcd_ammo/large(src)
	return