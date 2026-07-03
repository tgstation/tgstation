/obj/item/gun
	obj_flags = UNIQUE_RENAME

/obj/item/gun/ballistic/shotgun
	obj_flags = UNIQUE_RENAME

/obj/item/gun/ballistic
	recoil = 1

/obj/item/gun/ballistic/revolver
	recoil = 0.5

/obj/item/gun/ballistic/revolver/c38
	recoil = 0.3

/obj/item/gun/ballistic/automatic/pistol
	recoil = 0.2

/obj/item/gun/ballistic/automatic/pistol/clandestine
	recoil = 0.3

/obj/item/gun/ballistic/automatic/pistol/deagle
	recoil = 1.2

/obj/item/gun/ballistic/automatic/smartgun
	recoil = 0.2

/obj/item/gun/ballistic/automatic/ar
	recoil = 0.3
	accepted_magazine_type = /obj/item/ammo_box/magazine/c223
	spawn_magazine_type = /obj/item/ammo_box/magazine/c223

/obj/item/gun/ballistic/automatic/proto
	recoil = 0.2

/obj/item/gun/ballistic/automatic/battle_rifle
	recoil = 0.3

/obj/item/gun/ballistic/automatic/wt550
	recoil = 0.3

/obj/item/gun/ballistic/automatic/m90
	recoil = 0.3

/obj/item/gun/ballistic/automatic/c20r
	recoil = 0.2

/obj/item/gun/ballistic/automatic/proto
	recoil = 0.2

/obj/item/gun/ballistic/automatic/laser
	recoil = 0

/obj/item/gun/ballistic/automatic/l6_saw
	recoil = 0.5

/obj/item/gun/ballistic/automatic/gyropistol
	recoil = 0.1

/obj/item/gun/ballistic/automatic/shotgun/bulldog
	recoil = 0.5

/obj/item/gun/ballistic/automatic/bow
	recoil = 0

/obj/item/gun/ballistic/automatic/pistol/toy
	recoil = 0

/obj/item/gun/ballistic/automatic/toy
	recoil = 0

/obj/item/gun/ballistic/shotgun/toy
	recoil = 0

/obj/item/gun/ballistic/automatic/c20r/toy
	recoil = 0

/obj/item/gun/ballistic/automatic/l6_saw/toy
	recoil = 0

/obj/item/gun/ballistic/shotgun/riot/lethal
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/riot/lethal

/obj/item/ammo_box/magazine/internal/shot/riot/lethal
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/milspec
	max_ammo = 6

// Prevents gun sizes from changing due to suppressors
/obj/item/gun/ballistic/install_suppressor(obj/item/suppressor/new_suppressor)
	. = ..()
	w_class -= suppressor.w_class

// Prevents gun sizes from changing due to suppressors
/obj/item/gun/ballistic/clear_suppressor()
	w_class = initial(w_class)
	return ..()

/obj/item/firing_pin/alert_level
	name = "alert level firing pin"
	var/desired_minimum_alert = SEC_LEVEL_GREEN

/obj/item/firing_pin/alert_level/blue
	desired_minimum_alert = SEC_LEVEL_BLUE
	desc = "Небольшое устройство аутентификации, которое вставляется в спусковой механизм оружия для обеспечения его работоспособности. Данное устройство настроено на стрельбу только при синем уровне тревоги или выше."
	fail_message = "низкий уровень тревоги!"

/obj/item/firing_pin/alert_level/pin_auth(mob/living/user)
	return (SSsecurity_level.current_security_level.number_level >= desired_minimum_alert)
