/obj/structure/closet/secure_closet/ert/commander
	name = "\improper ERT commander locker"
	req_access = list(ACCESS_SECURITY)
	icon_state = "capsecure1"
	icon_closed = "capsecure"
	icon_locked = "capsecure1"
	icon_opened = "capsecureopen"
	icon_broken = "capsecurebroken"
	icon_off = "capsecureoff"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/head/helmet/space/ert/commander(src)
		new /obj/item/clothing/suit/space/ert/commander(src)
		new /obj/item/weapon/plastique(src)
		new /obj/item/weapon/storage/belt/security/full(src)
		new /obj/item/weapon/gun/energy/ionrifle(src)
		new /obj/item/weapon/gun/energy/gun/nuclear(src)
		new /obj/item/clothing/glasses/thermal(src)
		new /obj/item/weapon/lighter/zippo(src)
		new /obj/item/weapon/pinpointer(src)
		return

/obj/structure/closet/secure_closet/ert/security
	name = "\improper ERT security locker"
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
		new /obj/item/clothing/head/helmet/space/ert/security(src)
		new /obj/item/clothing/suit/space/ert/security(src)
		new /obj/item/weapon/plastique(src)
		new /obj/item/weapon/storage/belt/security/full(src)
		new /obj/item/weapon/gun/energy/ionrifle(src)
		new /obj/item/weapon/gun/energy/gun/nuclear(src)
		new /obj/item/clothing/glasses/thermal(src)
		return


/obj/structure/closet/secure_closet/ert/engineer
	name = "\improper ERT engineer locker"
	req_access = list(ACCESS_ENGINE)
	icon_state = "secureeng1"
	icon_closed = "secureeng"
	icon_locked = "secureeng1"
	icon_opened = "secureengopen"
	icon_broken = "secureengbroken"
	icon_off = "secureengoff"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/head/helmet/space/ert/engineer(src)
		new /obj/item/clothing/suit/space/ert/engineer(src)
		new /obj/item/weapon/gun/energy/taser(src)
		new /obj/item/weapon/storage/belt/utility/full(src)
		new /obj/item/weapon/storage/backpack/industrial/full(src)
		new /obj/item/device/t_scanner(src)
		new /obj/item/clothing/glasses/meson(src)
		return

/obj/structure/closet/secure_closet/ert/medical
	name = "\improper ERT medical locker"
	req_access = list(ACCESS_MEDICAL)
	icon_state = "securemed1"
	icon_closed = "securemed"
	icon_locked = "securemed1"
	icon_opened = "securemedopen"
	icon_broken = "securemedbroken"
	icon_off = "securemedoff"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/head/helmet/space/ert/medical(src)
		new /obj/item/clothing/suit/space/ert/medical(src)
		new /obj/item/weapon/gun/energy/taser(src)
		new /obj/item/weapon/storage/backpack/medic/full(src)
		new /obj/item/weapon/storage/belt/medical(src)
		new /obj/item/clothing/glasses/hud/health(src)
		return