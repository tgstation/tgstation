/obj/item/weapon/gun/energy/pulse_rifle
	name = "\improper Pulse Rifle"
	desc = "A heavy-duty, pulse-based energy weapon, preferred by front-line combat personnel."
	icon_state = "pulse"
	item_state = "pulse100"
	force = 10
	fire_sound = 'pulse.ogg'
	charge_cost = 200
	projectile_type = "/obj/item/projectile/beam/pulse"
	cell_type = "/obj/item/weapon/cell/super"
	automatic = 1
	var/mode = 2


	attack_self(mob/living/user as mob)
		if(..())
			switch(mode)
				if(2)
					mode = 0
					charge_cost = 100
					fire_sound = 'Taser.ogg'
					user << "\red [src] is now set to stun."
					projectile_type = "/obj/item/projectile/energy/electrode"
				if(0)
					mode = 1
					charge_cost = 100
					fire_sound = 'Laser.ogg'
					user << "\red [src] is now set to kill."
					projectile_type = "/obj/item/projectile/beam"
				if(1)
					mode = 2
					charge_cost = 200
					fire_sound = 'pulse.ogg'
					user << "\red [src] is now set to DESTROY."
					projectile_type = "/obj/item/projectile/beam/pulse"
		return


/obj/item/weapon/gun/energy/pulse_rifle/destroyer
	name = "\improper Pulse Destroyer"
	desc = "A heavy-duty, pulse-based energy weapon."
	cell_type = "/obj/item/weapon/cell/infinite"

	attack_self(mob/living/user as mob)
		if(..())
			user << "\red [src] has three settings, and they are all DESTROY."



/obj/item/weapon/gun/energy/pulse_rifle/M1911
	name = "\improper M1911-P"
	desc = "It's not the size of the gun, it's the size of the hole it puts through people."
	icon_state = "m1911-p"
	item_state = "gun"
	cell_type = "/obj/item/weapon/cell/infinite"


