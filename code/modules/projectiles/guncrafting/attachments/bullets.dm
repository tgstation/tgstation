/obj/item/weapon/gun_attachment/bullet
	gun_type = CUSTOMIZABLE_PROJECTILE
	uses_overlay = FALSE
	icon_state = "bullet"

/obj/item/weapon/gun_attachment/bullet/fmj
	name = "Full Metal Jacket Rounds"
	desc = "Higher Damage, reduced range."

/obj/item/weapon/gun_attachment/bullet/fmj/on_fire(var/obj/item/weapon/gun/owner, var/obj/item/projectile/bullet)
	..()
	bullet.range -= 2
	bullet.damage += 5

/obj/item/weapon/gun_attachment/bullet/polonium
	name = "Polonium Rounds"

/obj/item/weapon/gun_attachment/bullet/polonium/on_fire(var/obj/item/weapon/gun/owner, var/obj/item/projectile/bullet)
	..()
	bullet.irradiate += 10
	bullet.damage -= 5

/obj/item/weapon/gun_attachment/bullet/ap
	name = "Armor Piercing Bullets"

/obj/item/weapon/gun_attachment/bullet/ap/on_fire(var/obj/item/weapon/gun/owner, var/obj/item/projectile/bullet)
	..()
	bullet.armour_penetration += 10
	bullet.damage -= 3