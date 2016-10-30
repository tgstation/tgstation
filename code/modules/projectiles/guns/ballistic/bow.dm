/obj/item/weapon/gun/ballistic/bow
	name = "bow"
	desc = "A sturdy bow made out of wood and reinforced with iron."
	icon_state = "bow_unloaded"
	item_state = "bow"
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/bow
	flags = HANDSLOW
	weapon_weight = WEAPON_HEAVY
	casing_ejector = 0
	var/draw_sound = 'sound/weapons/draw_bow.ogg'
	var/ready_to_fire = 0
	var/slowdown_when_ready = 2

/obj/item/weapon/gun/ballistic/bow/update_icon()
	if(magazine.ammo_count() && !ready_to_fire)
		icon_state = "bow_loaded"
	else if(ready_to_fire)
		icon_state = "bow_firing"
		slowdown = slowdown_when_ready
	else
		icon_state = initial(icon_state)
		slowdown = initial(slowdown)

/obj/item/weapon/gun/ballistic/bow/dropped(mob/user)
	if(magazine && magazine.ammo_count())
		magazine.empty_magazine()
		ready_to_fire = FALSE
		update_icon()

/obj/item/weapon/gun/ballistic/bow/attack_self(mob/living/user)
	if(!ready_to_fire && magazine.ammo_count())
		ready_to_fire = TRUE
		playsound(user, draw_sound, 100, 1)
		update_icon()
	else
		ready_to_fire = FALSE
		update_icon()

/obj/item/weapon/gun/ballistic/bow/attackby(obj/item/A, mob/user, params)
	var/num_loaded = magazine.attackby(A, user, params, 1)
	if(num_loaded)
		user << "<span class='notice'>You ready \the [A] into \the [src].</span>"
		update_icon()
		chamber_round()

/obj/item/weapon/gun/ballistic/bow/can_shoot()
	. = ..()
	if(!ready_to_fire)
		return FALSE

/obj/item/weapon/gun/ballistic/bow/shoot_with_empty_chamber(mob/living/user as mob|obj)
	return

/obj/item/weapon/gun/ballistic/bow/process_chamber(empty_chamber = 1)
	. = ..()
	ready_to_fire = FALSE
	update_icon()


//quiver
/obj/item/weapon/storage/backpack/quiver
	name = "quiver"
	desc = "A quiver for holding arrows."
	icon_state = "quiver"
	item_state = "quiver"
	storage_slots = 20
	can_hold = list(
		/obj/item/ammo_casing/caseless/arrow
		)

/obj/item/weapon/storage/backpack/quiver/full/New()
	..()
	for(var/i in 1 to storage_slots)
		new /obj/item/ammo_casing/caseless/arrow(src)
