/obj/item/projectile/flare
	name = "flare"
	icon_state = "flareround"
	damage = 15 //bit weak, but since the syndie version sets them on fire (probably) it's balanced
	damage_type = BURN
	var/embed = 1
	var/obj/shotloc = null //Where the flare was shot from (stored to  be retrieved when the projectile dies)
	flag = "bullet"
	l_color = "#AA0033"
	luminosity = 5


/obj/item/projectile/flare/New()
	shotloc = get_turf(shot_from)
	..()

/obj/item/projectile/flare/Bump()
	..()
	if(src)
		var/newloc = get_step(src.loc, get_dir(src.loc, shotloc)) //basically puts it back one tile in its movement
		var/obj/item/device/flashlight/flare/newflare = new(newloc)
		newflare.Light() //to get the thing lit
		qdel(src)

/*
/obj/item/projectile/flare/on_hit(var/atom/hit)
	..()
	qdel(src) // to stop the flare spawning on death when it does damage
*/