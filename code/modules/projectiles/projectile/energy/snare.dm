/obj/projectile/energy/trap
	name = "energy snare"
	icon_state = "e_snare"
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 3

/obj/projectile/energy/trap/on_hit(atom/target, blocked = FALSE)
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - drop a trap
		new /obj/item/restraints/legcuffs/beartrap/energy(get_turf(loc))
	else if(iscarbon(target))
		var/obj/item/restraints/legcuffs/beartrap/energy/our_trap = new /obj/item/restraints/legcuffs/beartrap/energy(get_turf(target))
		our_trap.spring_trap(null, target)
	. = ..()

/obj/projectile/energy/trap/on_range()
	new /obj/item/restraints/legcuffs/beartrap/energy(loc)
	..()
