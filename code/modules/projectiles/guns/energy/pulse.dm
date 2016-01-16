/obj/item/weapon/gun/energy/pulse_rifle
	name = "pulse rifle"
	desc = "A heavy-duty, pulse-based energy weapon, preferred by front-line combat personnel."
	icon_state = "pulse"
	item_state = null	//so the human update icon uses the icon_state instead.
	force = 10
	fire_sound = 'sound/weapons/pulse.ogg'
	charge_cost = 200
	projectile_type = "/obj/item/projectile/beam/pulse"
	cell_type = "/obj/item/weapon/cell/super"
	var/mode = 2
	fire_delay = 2

	attack_self(mob/living/user as mob)
		switch(mode)
			if(2)
				mode = 0
				charge_cost = 100
				fire_sound = 'sound/weapons/Taser.ogg'
				to_chat(user, "<span class='warning'>[src.name] is now set to stun.</span>")
				projectile_type = "/obj/item/projectile/energy/electrode"
			if(0)
				mode = 1
				charge_cost = 100
				fire_sound = 'sound/weapons/Laser.ogg'
				to_chat(user, "<span class='warning'>[src.name] is now set to kill.</span>")
				projectile_type = "/obj/item/projectile/beam"
			if(1)
				mode = 2
				charge_cost = 200
				fire_sound = 'sound/weapons/pulse.ogg'
				to_chat(user, "<span class='warning'>[src.name] is now set to DESTROY.</span>")
				projectile_type = "/obj/item/projectile/beam/pulse"
		return

	isHandgun()
		return 0

/obj/item/weapon/gun/energy/pulse_rifle/cyborg/process_chambered()
	if(in_chamber)
		return 1
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			R.cell.use(charge_cost)
			in_chamber = new/obj/item/projectile/beam(src)
			return 1
	return 0


/obj/item/weapon/gun/energy/pulse_rifle/destroyer
	name = "pulse destroyer"
	desc = "A heavy-duty, pulse-based energy weapon."
	cell_type = "/obj/item/weapon/cell/infinite"

	attack_self(mob/living/user as mob)
		to_chat(user, "<span class='warning'>[src.name] has three settings, and they are all DESTROY.</span>")



/obj/item/weapon/gun/energy/pulse_rifle/M1911
	name = "m1911-P"
	desc = "It's not the size of the gun, it's the size of the hole it puts through people."
	icon_state = "m1911-p"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	cell_type = "/obj/item/weapon/cell/infinite"

	isHandgun()
		return 1