/obj/item/weapon/gun_attachment/energy_bullet
	gun_type = CUSTOMIZABLE_ENERGY
	uses_overlay = FALSE
	icon_state = "bullet"
	not_okay = /obj/item/weapon/gun_attachment/energy_bullet

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

/obj/item/weapon/gun_attachment/energy_bullet/decloner
	name = "Energy Decloner"
	desc = "Force your enemies into cryogenics.."

/obj/item/weapon/gun_attachment/energy_bullet/decloner/on_fire(var/obj/item/weapon/gun/owner, var/obj/item/projectile/bullet)
	..()
	bullet.damage_type = CLONE
	bullet.damage *= 0.7
	bullet.irradiate = 10

/obj/item/weapon/gun_attachment/energy_bullet/speed
	name = "Energy Speeder"
	desc = "Beep Beep."

/obj/item/weapon/gun_attachment/energy_bullet/speed/on_fire(var/obj/item/weapon/gun/owner, var/obj/item/projectile/bullet)
	..()
	bullet.speed *= 0.5
	bullet.damage *= 0.5
	bullet.spread += 0.3

/obj/item/weapon/gun_attachment/energy_bullet/invert
	name = "Energy Inverter"
	desc = "Heal things."

/obj/item/weapon/gun_attachment/energy_bullet/invert/on_fire(var/obj/item/weapon/gun/owner, var/obj/item/projectile/bullet)
	..()
	bullet.speed = 1
	bullet.damage *= -1
