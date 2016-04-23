/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's an immobile card-locked storage unit."
	locked = 1
	icon_state = "secure"
	health = 200
	secure = 1

/obj/structure/closet/secure_closet/examine(mob/user)
	..()
	user << "<span class='italicnotice'>Alt-click it to toggle the lock.</span>"
