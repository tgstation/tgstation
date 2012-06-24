/*
CONTAINS:
WIRE
TILES

*/


// WIRES

/obj/item/weapon/wire/proc/update()
	if (src.amount > 1)
		src.icon_state = "spool_wire"
		src.desc = text("This is just spool of regular insulated wire. It consists of about [] unit\s of wire.", src.amount)
	else
		src.icon_state = "item_wire"
		src.desc = "This is just a simple piece of regular insulated wire."
	return

/obj/item/weapon/wire/attack_self(mob/user as mob)
	if (src.laying)
		src.laying = 0
		user << "\blue You're done laying wire!"
	else
		user << "\blue You are not using this to lay wire..."
	return

/obj/item/weapon/wire/attack(mob/M as mob, mob/user as mob)
	if(hasorgans(M))
		var/datum/organ/external/S = M:organs[user.zone_sel.selecting]
		if(!(S.status & ROBOT) || user.a_intent != "help")
			return ..()
		if(S.brute_dam)
			S.heal_damage(0,15,0,1)
			if(user != M)
				user.visible_message("\red You repair some burn damage on \the [M]'s [S.display_name]",\
				"\red \The [user] repairs some burn damage on \the [M]'s [S.display_name] with \the [src]",\
				"You wires being cut.")
			else
				user.visible_message("\red You repair some burn damage on your [S.display_name]",\
				"\red \The [user] repairs some burn damage on their [S.display_name] with \the [src]",\
				"You wires being cut.")
		else
			user << "Nothing to fix!"
	else
		return ..()


