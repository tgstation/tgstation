#define PROJECTILE_TYPE_ENERGY "energy" //Lasers, beams, etc.
#define PROJECTILE_TYPE_SOLID "solid" //Bullets and physical projectiles

/*

//////////////////
// MOUNTED GUNS //
//////////////////

Large guns controlled remotely by buttons, consoles, etc. Alternatively, just throw a switch on the gun to fire it.
Basic types just fire a single projectile.
More advanced types can have things like cooldowns, reloading, etc.
Made for use on shuttles or maybe admin stuff.

*/

/obj/machinery/mounted_gun
	name = "mounted gun"
	desc = "You should never see this."
	icon = 'icons/obj/machines/lasers.dmi'
	icon_state = "seed_off"
	anchored = 1
	use_power = 0
	density = 1
	var/can_manually_fire = FALSE //If you can just click on the mounted gun itself to set it off.
	var/fire_type = PROJECTILE_TYPE_ENERGY //See defines at top of file. The physical properties of the projectile fired. Used for certain actions.
	var/projectile_type = /obj/item/projectile/beam //The actual projectile subtype the gun fires. This MUST be a subtype of /obj/item/projectile.
	var/use_ammo = FALSE //If the mounted gun uses ammunition. The gun will not fire when it is out of ammo.
	var/ammo_left = 0 //The amount of shots the gun can fire before running out. If the gun doesn't use ammo, this will never change.
	var/max_ammo = 5 //The maximum ammunition the gun can contain at any time.
	var/ammo_restock_type = /obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola //The type of object used to reload the gun's ammunition.
	var/fire_delay = 5 //The amount of time between shots before the gun can be fired again
	var/fire_message = "<span class='warning'>The mounted gun goes off!</span>" //The message displayed when the gun fires.
	var/fire_sound = 'sound/weapons/Laser.ogg' //The sound played when the gun fires.
	var/fire_fail_message = "<span class='warning'>The mounted gun is out of power!</span>" //The message displayed when the gun fails to fire
	var/fire_fail_sound = 'sound/weapons/empty.ogg' //The sound played when the gun fails to fire
	var/last_fired_time = 0 //The time the gun was last fired
	var/can_rotate = FALSE //If the gun is rotatable

/obj/machinery/mounted_gun/proc/fire_projectile()
	if(last_fired_time  + fire_delay > world.time)
		return 0
	if(use_ammo)
		if(!ammo_left) //No ammunition left, fail the fire
			visible_message(fire_fail_message)
			playsound(src, fire_fail_sound, 50, 1)
			return 0
		else
			ammo_left--
	visible_message(fire_message)
	playsound(src, fire_sound, 50, 1)
	var/obj/item/projectile/A = new projectile_type(get_turf(src)) //Spawn the projectile itself
	//Copypasta from emitter code
	switch(dir)
		if(NORTH)
			A.yo = 20
			A.xo = 0
		if(EAST)
			A.yo = 0
			A.xo = 20
		if(WEST)
			A.yo = 0
			A.xo = -20
		else
			A.yo = -20
			A.xo = 0
	A.starting = get_turf(src)
	A.fire()
	last_fired_time = world.time
	return 1

/obj/machinery/mounted_gun/attack_hand(mob/user)
	if(can_manually_fire)
		fire_projectile()
		return 1
	..()

/obj/machinery/mounted_gun/attackby(obj/item/I, mob/user, params)
	if(istype(I, ammo_restock_type))
		if(ammo_left >= max_ammo)
			user << "<span class='warning'>[src] is already fully loaded!</span>"
			return 0
		user.drop_item()
		switch(fire_type)
			if(PROJECTILE_TYPE_ENERGY)
				user.visible_message("<span class='notice'>[user] recharges [src] using [I].</span>", "<span class='notice'>You recharge [src] with [I].</span>")
			if(PROJECTILE_TYPE_SOLID)
				user.visible_message("<span class='notice'>[user] refills [src]'s ammo using [I].</span>", "<span class='notice'>You refill [src]'s ammunition with [I].</span>")
		ammo_left++ //Each object restores a single shot's worth of ammo
		qdel(I)
		return 1
	..()

/obj/machinery/mounted_gun/proc/rotate(var/new_dir)
	if(!can_rotate || !new_dir || dir == new_dir)
		return 0
	visible_message("<span class='warning'>[src] whirs quietly as it rotates to a new position.</span>")
	playsound(src, 'sound/effects/bin_open.ogg', 10, 1)
	dir = new_dir

/obj/machinery/mounted_gun/high_explosive
	name = "40mm cannon"
	desc = "A large piece of hardware designed to fire 40mm grenades at subsonic speeds."
	icon = 'icons/obj/turrets.dmi'
	icon_state = "gun_turret"
	fire_type = PROJECTILE_TYPE_SOLID
	projectile_type = /obj/item/projectile/bullet/a40mm
	use_ammo = TRUE
	ammo_left = 10 //Start out fully loaded
	max_ammo = 10
	ammo_restock_type = /obj/item/ammo_casing/a40mm
	fire_delay = 30 //3 seconds
	fire_message = "<span class='warning'>The cannon discharges a grenade in a blast of smoke!</span>"
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	fire_fail_message = "<span class='warning'>The cannon is out of grenades!</span>"
	can_rotate = 1

#undef PROJECTILE_TYPE_ENERGY
#undef PROJECTILE_TYPE_SOLID
