/obj/projectile/energy/net
	name = "energy netting"
	icon_state = "e_netting"
	damage = 10
	damage_type = STAMINA
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 10

/obj/projectile/energy/net/Initialize(mapload)
	. = ..()
	SpinAnimation()

/obj/projectile/energy/net/on_hit(atom/target, blocked = 0, pierce_hit)
	var/obj/item/dragnet_beacon/destination_beacon = null
	var/obj/item/gun/energy/e_gun/dragnet/our_dragnet = fired_from
	if(our_dragnet && istype(our_dragnet))
		destination_beacon = our_dragnet.linked_beacon

	if(isliving(target))
		var/turf/Tloc = get_turf(target)
		if(!locate(/obj/effect/nettingportal) in Tloc)
			new /obj/effect/nettingportal(Tloc, destination_beacon)
	. = ..()

/obj/projectile/energy/net/on_range()
	do_sparks(1, TRUE, src)
	. = ..()

/obj/effect/nettingportal
	name = "DRAGnet teleportation field"
	desc = "A field of bluespace energy, locking on to teleport a target."
	icon = 'icons/effects/effects.dmi'
	icon_state = "dragnetfield"
	light_range = 3
	anchored = TRUE

/obj/effect/nettingportal/Initialize(mapload, destination_beacon)
	. = ..()
	var/obj/item/dragnet_beacon/teletarget = destination_beacon
	addtimer(CALLBACK(src, PROC_REF(pop), teletarget), 3 SECONDS)

/obj/effect/nettingportal/proc/pop(teletarget)
	if(teletarget)
		for(var/mob/living/living_mob in get_turf(src))
			do_teleport(living_mob, get_turf(teletarget), 1, channel = TELEPORT_CHANNEL_BLUESPACE) //Teleport what's in the tile to the beacon
	else
		for(var/mob/living/living_mob in get_turf(src))
			do_teleport(living_mob, get_turf(living_mob), 15, channel = TELEPORT_CHANNEL_BLUESPACE) //Otherwise it just warps you off somewhere.

	qdel(src)

/obj/effect/nettingportal/singularity_act()
	return

/obj/effect/nettingportal/singularity_pull()
	return

/obj/item/dragnet_beacon
	name = "\improper DRAGnet beacon"
	desc = "Can be synced with a DRAGnet to set it as a designated teleporting point."
	icon = 'icons/obj/devices/tracker.dmi'
	icon_state = "dragnet_beacon"
	inhand_icon_state = "beacon"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'

/obj/item/dragnet_beacon/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/gun/energy/e_gun/dragnet))
		var/obj/item/gun/energy/e_gun/dragnet/dragnet_to_link = tool
		dragnet_to_link.linked_beacon = src
		balloon_alert(user, "beacon synced")

/obj/projectile/energy/trap
	name = "energy snare"
	icon_state = "e_snare"
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 4

/obj/projectile/energy/trap/on_hit(atom/target, blocked = 0, pierce_hit)
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - drop a trap
		new/obj/item/restraints/legcuffs/beartrap/energy(get_turf(loc))
	else if(iscarbon(target))
		var/obj/item/restraints/legcuffs/beartrap/B = new /obj/item/restraints/legcuffs/beartrap/energy(get_turf(target))
		B.spring_trap(target)
	. = ..()

/obj/projectile/energy/trap/on_range()
	new /obj/item/restraints/legcuffs/beartrap/energy(loc)
	..()

/obj/projectile/energy/trap/cyborg
	name = "Energy Bola"
	icon_state = "e_snare"
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 10

/obj/projectile/energy/trap/cyborg/on_hit(atom/target, blocked = 0, pierce_hit)
	if(!ismob(target) || blocked >= 100)
		do_sparks(1, TRUE, src)
		qdel(src)
	if(iscarbon(target))
		var/obj/item/restraints/legcuffs/beartrap/B = new /obj/item/restraints/legcuffs/beartrap/energy/cyborg(get_turf(target))
		B.spring_trap(target)
	QDEL_IN(src, 10)
	. = ..()

/obj/projectile/energy/trap/cyborg/on_range()
	do_sparks(1, TRUE, src)
	qdel(src)
