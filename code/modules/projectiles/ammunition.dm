/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	var/fire_sound = null						//What sound should play when this ammo is fired
	var/caliber = null							//Which kind of guns it can be loaded into
	var/projectile_type = null					//The bullet type to create when New() is called
	var/obj/item/projectile/BB = null 			//The loaded bullet
	var/pellets = 1								//Pellets for spreadshot
	var/variance = 0							//Variance for inaccuracy fundamental to the casing
	var/randomspread = 0						//Randomspread for automatics
	var/delay = 0								//Delay for energy weapons
	var/click_cooldown_override = 0				//Override this to make your gun have a faster fire rate, in tenths of a second. 4 is the default gun cooldown.
	var/firing_effect_type = /obj/effect/overlay/temp/dir_setting/firing_effect	//the visual effect appearing when the ammo is fired.


/obj/item/ammo_casing/New()
	..()
	if(projectile_type)
		BB = new projectile_type(src)
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	setDir(pick(alldirs))
	update_icon()

/obj/item/ammo_casing/update_icon()
	..()
	icon_state = "[initial(icon_state)][BB ? "-live" : ""]"
	desc = "[initial(desc)][BB ? "" : " This one is spent"]"

//proc to magically refill a casing with a new projectile
/obj/item/ammo_casing/proc/newshot() //For energy weapons, syringe gun, shotgun shells and wands (!).
	if(!BB)
		BB = new projectile_type(src)

/obj/item/ammo_casing/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_box))
		var/obj/item/ammo_box/box = I
		if(isturf(loc))
			var/boolets = 0
			for(var/obj/item/ammo_casing/bullet in loc)
				if (box.stored_ammo.len >= box.max_ammo)
					break
				if (bullet.BB)
					if (box.give_round(bullet, 0))
						boolets++
				else
					continue
			if (boolets > 0)
				box.update_icon()
				user << "<span class='notice'>You collect [boolets] shell\s. [box] now contains [box.stored_ammo.len] shell\s.</span>"
			else
				user << "<span class='warning'>You fail to collect anything!</span>"
	else
		return ..()
