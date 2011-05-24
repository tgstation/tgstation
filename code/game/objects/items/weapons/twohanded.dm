/*##################################################################
##################### TWO HANDED WEAPONS BE HERE~ -Agouri :3 ########
####################################################################*/

///General Offhand object properties///


////////////FIREAXE!//////////////


/obj/item/weapon/fireaxe/update_icon()  //Currently only here to fuck with the on-mob icons.
	src.icon_state = text("fireaxe[]",src.wielded)
	return

/obj/item/weapon/fireaxe/pickup(mob/user)
	src.wielded = 0
	src.name = "Fire Axe (Unwielded)"


/obj/item/weapon/fireaxe/attack_self(mob/user as mob)
	if( istype(user,/mob/living/carbon/monkey) )
		user << "\red It's too heavy for you to fully wield"
		return

//welp, all is good, now to see if he's trying do twohandedly wield it or unwield it


	..()