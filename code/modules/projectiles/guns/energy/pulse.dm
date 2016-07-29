<<<<<<< HEAD
/obj/item/weapon/gun/energy/pulse
	name = "pulse rifle"
	desc = "A heavy-duty, multifaceted energy rifle with three modes. Preferred by front-line combat personnel."
	icon_state = "pulse"
	item_state = null
	w_class = 4
	force = 10
	flags =  CONDUCT
	slot_flags = SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/laser/pulse, /obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser)
	cell_type = "/obj/item/weapon/stock_parts/cell/pulse"

/obj/item/weapon/gun/energy/pulse/emp_act(severity)
	return

/obj/item/weapon/gun/energy/pulse/prize
	pin = /obj/item/device/firing_pin

/obj/item/weapon/gun/energy/pulse/prize/New()
	. = ..()
	poi_list |= src
	var/msg = "A pulse rifle prize has been created at ([x],[y],[z] - (\
	<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>\
	JMP</a>)"

	message_admins(msg)
	log_game(msg)

	notify_ghosts("Someone won a pulse rifle as a prize!", source = src,
		action = NOTIFY_ORBIT)

/obj/item/weapon/gun/energy/pulse/prize/Destroy()
	poi_list -= src
	. = ..()

/obj/item/weapon/gun/energy/pulse/loyalpin
	pin = /obj/item/device/firing_pin/implant/mindshield

/obj/item/weapon/gun/energy/pulse/carbine
	name = "pulse carbine"
	desc = "A compact variant of the pulse rifle with less firepower but easier storage."
	w_class = 3
	slot_flags = SLOT_BELT
	icon_state = "pulse_carbine"
	item_state = "pulse"
	cell_type = "/obj/item/weapon/stock_parts/cell/pulse/carbine"
	can_flashlight = 1
	flight_x_offset = 18
	flight_y_offset = 12

/obj/item/weapon/gun/energy/pulse/carbine/loyalpin
	pin = /obj/item/device/firing_pin/implant/mindshield

/obj/item/weapon/gun/energy/pulse/pistol
	name = "pulse pistol"
	desc = "A pulse rifle in an easily concealed handgun package with low capacity."
	w_class = 2
	slot_flags = SLOT_BELT
	icon_state = "pulse_pistol"
	item_state = "gun"
	cell_type = "/obj/item/weapon/stock_parts/cell/pulse/pistol"
	can_charge = 0

/obj/item/weapon/gun/energy/pulse/pistol/loyalpin
	pin = /obj/item/device/firing_pin/implant/mindshield

/obj/item/weapon/gun/energy/pulse/destroyer
	name = "pulse destroyer"
	desc = "A heavy-duty energy rifle built for pure destruction."
	cell_type = "/obj/item/weapon/stock_parts/cell/infinite"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/pulse)

/obj/item/weapon/gun/energy/pulse/destroyer/attack_self(mob/living/user)
	user << "<span class='danger'>[src.name] has three settings, and they are all DESTROY.</span>"

/obj/item/weapon/gun/energy/pulse/pistol/m1911
	name = "\improper M1911-P"
	desc = "A compact pulse core in a classic handgun frame for Nanotrasen officers. It's not the size of the gun, it's the size of the hole it puts through people."
	icon_state = "m1911"
	item_state = "gun"
	cell_type = "/obj/item/weapon/stock_parts/cell/infinite"
=======
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
