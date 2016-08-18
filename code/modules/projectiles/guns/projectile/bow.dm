/obj/item/weapon/gun/projectile/bow
	name = "bow"
	desc = "A bow."
	icon_state = "bow_unloaded"
	item_state = "bow_unloaded"
	mag_type = /obj/item/ammo_box/magazine/internal/bow
	flags = HANDSLOW
	var/ready_to_fire = 0
	var/slowdown_when_ready = 1

/obj/item/weapon/gun/projectile/bow/update_icon()
	if(magazine.ammo_count() && !ready_to_fire)
		icon_state = "bow_loaded"
	else if(ready_to_fire)
		icon_state = "bow_firing"
		slowdown = slowdown_when_ready
	else
		icon_state = initial(icon_state)
		slowdown = initial(slowdown)

/obj/item/weapon/gun/projectile/bow/attack_self(mob/user)
	if(!ready_to_fire && magazine.ammo_count())
		ready_to_fire = 1
		update_icon()

/obj/item/weapon/gun/projectile/bow/attackby(obj/item/A, mob/user, params)
	var/num_loaded = magazine.attackby(A, user, params, 1)
	if(num_loaded)
		user << "<span class='notice'>You ready \the [A] into \the [src].</span>"
		update_icon()
		chamber_round()

/obj/item/weapon/gun/projectile/bow/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()

// ammo
/obj/item/ammo_box/magazine/internal/bow
	name = "bow internal magazine"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	caliber = "arrow"
	max_ammo = 1


/obj/item/projectile/bullet/reusable/arrow
	name = "arrow"
	icon_state = "arrow"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	range = 10
	damage = 15
	damage_type = BRUTE

/obj/item/ammo_casing/caseless/arrow
	name = "arrow"
	icon_state = "arrow"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow
	caliber = "arrow"