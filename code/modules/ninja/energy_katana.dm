/obj/item/weapon/katana/energy
	name = "energy blade"
	desc = "a blade infused with a strong energy"
	icon_state = "blade"
	item_state = "blade"
	force = 40
	throwforce = 20

/obj/item/weapon/katana/energy/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!user || !target)
		return

	if(proximity_flag)
		target.emag_act()
		user.visible_message("<span class='danger'>[user] masterfully slices [target]!</span>", "<span class='notice'>You masterfully slice [target]!</span>")
		playsound(user, "sparks", 50, 1)
		playsound(user, 'sound/weapons/blade1.ogg', 50, 1)

