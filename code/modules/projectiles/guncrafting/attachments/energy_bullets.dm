/obj/item/weapon/gun_attachment/energy_bullet
	gun_type = CUSTOMIZABLE_ENERGY
	uses_overlay = FALSE
	icon_state = "bullet"

/obj/item/weapon/gun_attachment/energy_bullet/focuser
	name = "Energy Focuser"
	desc = "More damage, less range."

/obj/item/weapon/gun_attachment/energy_bullet/focuser/on_fire(var/obj/item/weapon/gun/owner, var/obj/item/projectile/bullet)
	..()
	bullet.range -= 3
	bullet.damage += 10


/obj/item/weapon/gun_attachment/energy_bullet/stunner
	name = "Energy Stunner"
	desc = "Short stun with less damage."

/obj/item/weapon/gun_attachment/energy_bullet/stunner/on_fire(var/obj/item/weapon/gun/owner, var/obj/item/projectile/bullet)
	..()
	bullet.stun += 1
	bullet.weaken += 1
	bullet.stutter += 5
	bullet.jitter += 10
	if(bullet.damage >= 5)
		bullet.damage -= 5
	else
		bullet.damage = 0

/obj/item/weapon/gun_attachment/energy_bullet/disorienter
	name = "Energy Disorienter"
	desc = "Drowsiness, less damage."

/obj/item/weapon/gun_attachment/energy_bullet/disorienter/on_fire(var/obj/item/weapon/gun/owner, var/obj/item/projectile/bullet)
	..()
	bullet.drowsy += 10
	if(bullet.damage >= 5)
		bullet.damage -= 5
	else
		bullet.damage = 0
