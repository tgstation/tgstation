/obj/structure/walllocker
	name = "Wall Locker"
	icon = 'icons/obj/lockwall.dmi'
	icon_state = "emerg"
	var/list/spawnitems = list()
	anchored = 1
	var/amount = 3 // spawns each items X times.
/obj/structure/walllocker/attack_hand(mob/user as mob)
	if (istype(user, /mob/living/silicon/ai))	//Added by Strumpetplaya - AI shouldn't be able to
		return									//activate emergency lockers.  This fixes that.  (Does this make sense, the AI can't call attack_hand, can it? --Mloc)
	if(!amount)
		usr << "It's empty.."
		return
	if(amount)
		for(var/path in spawnitems)
			new path(src.loc)
		amount--
	return
/obj/structure/walllocker/emerglocker
	name = "Emergency Locker"
	spawnitems = list(/obj/item/weapon/tank/emergency_oxygen,/obj/item/clothing/mask/breath,/obj/item/weapon/crowbar)
/obj/structure/walllocker/emerglocker/north
	pixel_y = 32
	dir = SOUTH
/obj/structure/walllocker/emerglocker/south
	pixel_y = -32
	dir = NORTH
/obj/structure/walllocker/emerglocker/west
	pixel_x = -32
	dir = WEST
/obj/structure/walllocker/emerglocker/east
	pixel_x = 32
	dir = EAST