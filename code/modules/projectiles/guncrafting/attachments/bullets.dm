/obj/item/weapon/gun_attachment/bullet
	gun_type = CUSTOMIZABLE_PROJECTILE
	uses_overlay = FALSE
	icon_state = "bullet"
	not_okay = /obj/item/weapon/gun_attachment/bullet

/obj/item/weapon/gun_attachment/bullet/fmj
	name = "Full Metal Jacket Rounds"
	desc = "This is for shooting, this is for fun."

/obj/item/weapon/gun_attachment/bullet/fmj/on_fire(var/obj/item/weapon/gun/owner, var/obj/item/projectile/bullet)
	..()
	bullet.range *= 0.5
	bullet.speed *= 2
	bullet.damage *= 2

/obj/item/weapon/gun_attachment/bullet/polonium
	name = "Polonium Rounds"

/obj/item/weapon/gun_attachment/bullet/polonium/on_fire(var/obj/item/weapon/gun/owner, var/obj/item/projectile/bullet)
	..()
	bullet.irradiate += 20
	bullet.damage *= 0.5

/obj/item/weapon/gun_attachment/bullet/ap
	name = "Armor Piercing Bullets"

/obj/item/weapon/gun_attachment/bullet/ap/on_fire(var/obj/item/weapon/gun/owner, var/obj/item/projectile/bullet)
	..()
	bullet.armour_penetration += 10
	bullet.damage *= 0.5