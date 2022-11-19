/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's a card-locked storage unit."
	locked = TRUE
	icon_state = "secure"
	max_integrity = 250
	armor = list(MELEE = 30, BULLET = 50, LASER = 50, ENERGY = 100, BOMB = 0, BIO = 0, FIRE = 80, ACID = 80)
	secure = TRUE
	damage_deflection = 20

/obj/structure/closet/secure_closet/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_GREY_TIDE, PROC_REF(grey_tide))

/obj/structure/closet/secure_closet/Destroy()
	. = ..()
	UnregisterSignal(src, COMSIG_GREY_TIDE)

/obj/structure/closet/secure_closet/proc/grey_tide()
	locked = FALSE
	update_appearance()
