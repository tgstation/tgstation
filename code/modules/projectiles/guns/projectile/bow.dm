/obj/item/weapon/gun/projectile/bow
	name = "bow"
	desc = "A sturdy bow made out of wood and reinforced with iron."
	icon_state = "bow_unloaded"
	item_state = "bow"
	var/icon_state_loaded = "bow_loaded"
	var/icon_state_firing = "bow_firing"
	var/item_state_loaded = "bow"
	var/item_state_firing = "bow"
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/bow
	flags = HANDSLOW
	weapon_weight = WEAPON_HEAVY
	var/draw_sound = 'sound/weapons/draw_bow.ogg'
	var/ready_to_fire = 0
	var/slowdown_when_ready = 2
	var/draw_time = 10

/obj/item/weapon/gun/projectile/bow/update_icon()
	if(ready_to_fire)
		icon_state = icon_state_firing
		item_state = item_state_firing
		slowdown = slowdown_when_ready
	else if(magazine.ammo_count() && !ready_to_fire)
		icon_state = icon_state_loaded
		item_state = item_state_loaded
		slowdown = initial(slowdown)
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)
		slowdown = initial(slowdown)

/obj/item/weapon/gun/projectile/bow/dropped(mob/user)
	if(magazine && magazine.ammo_count())
		magazine.empty_magazine()
		ready_to_fire = FALSE
		update_icon()

/obj/item/weapon/gun/projectile/bow/attack_self(mob/living/user)
	if(!ready_to_fire && magazine.ammo_count())
		spawn(draw_time)
		ready_to_fire = TRUE
		playsound(user, draw_sound, 100, 1)
		update_icon()
	else
		spawn(draw_time)
		ready_to_fire = FALSE
		update_icon()

/obj/item/weapon/gun/projectile/bow/attackby(obj/item/A, mob/user, params)
	var/num_loaded = magazine.attackby(A, user, params, 1)
	if(num_loaded)
		user << "<span class='notice'>You ready \the [A] into \the [src].</span>"
		update_icon()
		chamber_round()

/obj/item/weapon/gun/projectile/bow/can_shoot()
	. = ..()
	if(!ready_to_fire)
		return FALSE

/obj/item/weapon/gun/projectile/bow/shoot_with_empty_chamber(mob/living/user as mob|obj)
	return

/obj/item/weapon/gun/projectile/bow/process_chamber(eject_casing = 0, empty_chamber = 1)
	. = ..()
	ready_to_fire = FALSE
	update_icon()

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
	damage = 25
	damage_type = BRUTE

/obj/item/ammo_casing/caseless/arrow
	name = "arrow"
	desc = "Stab, stab, stab."
	icon_state = "arrow"
	force = 10
	sharpness = IS_SHARP
	projectile_type = /obj/item/projectile/bullet/reusable/arrow
	caliber = "arrow"

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

/obj/item/weapon/storage/backpack/quiver/proc/arrow_count()
	var/count = 0
	for(var/obj/item/ammo_casing/caseless/arrow/A in src)
		count++
	return count

/obj/item/weapon/gun/projectile/bow/hardlight
	name = "hardlight chargebow"
	desc = "A modern take on an ancient weapon, this weapon shoots charged hardlight arrows at high velocities, allowing much higher effective range than a simple medieval varient."
	icon_state = "bow_hardlight_unloaded"
	item_state = "bow_hardlight"
	icon_state_loaded = "bow_hardlight_loaded"
	icon_state_firing = "bow_hardlight_firing"
	item_state_loaded = "bow_hardlight"
	item_state_firing = "bow_hardlight"
	fire_sound = 'sound/weapons/plasma_cutter.ogg'		//Will gladly use better sound effects
	mag_type = /obj/item/ammo_box/magazine/internal/bow/hardlight
	draw_sound = 'sound/weapons/draw_bow2.ogg'
	slowdown_when_ready = 1
	draw_time = 5

/obj/item/ammo_box/magazine/internal/bow/hardlight
	name = "bow hardlight magazine"
	ammo_type = /obj/item/ammo_casing/caseless/arrow/hardlight

/obj/item/projectile/bullet/reusable/arrow/hardlight
	name = "hardlight arrow"
	icon_state = "arrow_hardlight"
	ammo_type = /obj/item/ammo_casing/caseless/arrow/hardlight
	range = 20
	damage = 20
	damage_type = BRUTE
	dropped = 1

/obj/item/ammo_casing/caseless/arrow/hardlight
	name = "hardlight arrow"
	desc = "An arrow made out of hardlight."
	icon_state = "arrow_hardlight"
	force = 7
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/hardlight

/obj/item/projectile/bullet/reusable/arrow/hardlight2
	name = "hardlight arrow"
	range = 20
	damage = 10
	damage_type = BURN
	flag = "laser"
	dropped = 1

/obj/item/weapon/storage/backpack/quiver/hardlight
	name = "hardlight quiver"
	desc = "A sophiscated quiver for holding hardlight arrows that slowly regenerates them."
	icon_state = "quiver_hardlight"
	item_state = "quiver_hardlight"
	storage_slots = 10
	can_hold = list(
		/obj/item/ammo_casing/caseless/arrow/hardlight
		)
	var/charge_delay = 5
	var/charge_tick = 0

/obj/item/weapon/storage/backpack/quiver/hardlight/New()
	..()
	for(var/i in 1 to storage_slots)
		new /obj/item/ammo_casing/caseless/arrow/hardlight(src)
	START_PROCESSING(SSobj, src)

/obj/item/weapon/storage/backpack/quiver/hardlight/process()
	charge_tick++
	if(charge_tick >= charge_delay)
		if(arrow_count() < storage_slots)
			new /obj/item/ammo_casing/caseless/arrow/hardlight(src)
		charge_tick = 0

/obj/item/projectile/bullet/reusable/arrow/hardlight/on_hit(atom/target, blocked = 0)
	..()
	var/obj/item/projectile/bullet/reusable/arrow/hardlight2/A = new /obj/item/projectile/bullet/reusable/arrow/hardlight2(src.loc)
	A.Bump(target, 1)

/obj/item/ammo_casing/caseless/arrow/hardlight/Dropped()
	addtimer(src, "Destroy", 200)