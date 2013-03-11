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


