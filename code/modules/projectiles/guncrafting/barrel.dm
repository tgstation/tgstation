/obj/item/weapon/gun_attachment/barrel
	name = "barrel"
	desc = "Lock, stock, and two smoking barrels."
	var/range = 7
	var/weapon_weight = WEAPON_LIGHT
	var/gun_size = 1
	var/silenced = 0
	not_okay = /obj/item/weapon/gun_attachment/barrel

/obj/item/weapon/gun_attachment/barrel/on_attach(var/obj/item/weapon/gun/owner)
	..()
	owner.w_class = gun_size
	owner.weapon_weight = weapon_weight
	owner.barrel = src
	owner.suppressed = silenced

/obj/item/weapon/gun_attachment/barrel/on_remove(var/obj/item/weapon/gun/owner)
	..()
	owner.w_class = initial(owner.w_class)
	owner.weapon_weight = initial(owner.weapon_weight)
	owner.suppressed = initial(owner.suppressed)
	owner.barrel = null

/obj/item/weapon/gun_attachment/barrel/on_fire(var/obj/item/weapon/gun/owner, var/obj/item/projectile/bullet)
	..()
	bullet.range = range

/obj/item/weapon/gun_attachment/barrel/on_tick(var/obj/item/weapon/gun/owner)
	..()