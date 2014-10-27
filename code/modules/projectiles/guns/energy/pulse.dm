/obj/item/weapon/gun/energy/pulse_rifle
	name = "pulse rifle"
	desc = "A heavy-duty, multifaceted energy rifle with three modes. Preferred by front-line combat personnel."
	icon_state = "pulse"
	item_state_icon = null
	w_class = 4.0
	force = 10
	flags =  CONDUCT
	slot_flags = SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/laser/pulse, /obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser)
	cell_type = "/obj/item/weapon/stock_parts/cell/super"


/obj/item/weapon/gun/energy/pulse_rifle/attack_self(mob/living/user as mob)
	select_fire(user)

/obj/item/weapon/gun/energy/pulse_rifle/destroyer
	name = "pulse destroyer"
	desc = "A heavy-duty energy rifle built for pure destruction."
	cell_type = "/obj/item/weapon/stock_parts/cell/infinite"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/pulse)

/obj/item/weapon/gun/energy/pulse_rifle/destroyer/attack_self(mob/living/user as mob)
	user << "<span class='danger'>[src.name] has three settings, and they are all DESTROY.</span>"



/obj/item/weapon/gun/energy/pulse_rifle/M1911
	name = "m1911-P"
	desc = "A compact pulse core in a classic handgun frame for Nanotrasen officers. It's not the size of the gun, it's the size of the hole it puts through people."
	icon_state = "m1911-p"
	cell_type = "/obj/item/weapon/stock_parts/cell/infinite"


