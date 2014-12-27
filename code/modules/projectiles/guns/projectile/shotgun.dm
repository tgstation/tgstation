/obj/item/weapon/gun/projectile/shotgun
	name = "shotgun"
	desc = "A traditional shotgun with wood furniture and a four-shell capacity underneath."
	icon_state = "shotgun"
	item_state = "shotgun"
	w_class = 4.0
	force = 10
	flags =  CONDUCT
	slot_flags = SLOT_BACK
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/shot
	var/recentpump = 0 // to prevent spammage
	var/pumped = 0

/obj/item/weapon/gun/projectile/shotgun/attackby(var/obj/item/A as obj, mob/user as mob)
	var/num_loaded = magazine.attackby(A, user, 1)
	if(num_loaded)
		user << "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>"
		A.update_icon()
		update_icon()

/obj/item/weapon/gun/projectile/shotgun/process_chamber()
	return ..(0, 0)

/obj/item/weapon/gun/projectile/shotgun/chamber_round()
	return

/obj/item/weapon/gun/projectile/shotgun/can_shoot()
	if(!chambered)
		return 0
	return (chambered.BB ? 1 : 0)

/obj/item/weapon/gun/projectile/shotgun/attack_self(mob/living/user)
	if(recentpump)	return
	pump(user)
	recentpump = 1
	spawn(10)
		recentpump = 0
	return


/obj/item/weapon/gun/projectile/shotgun/proc/pump(mob/M)
	playsound(M, 'sound/weapons/shotgunpump.ogg', 60, 1)
	pumped = 0
	if(chambered)//We have a shell in the chamber
		chambered.loc = get_turf(src)//Eject casing
		chambered.SpinAnimation(5, 1)
		chambered = null
	if(!magazine.ammo_count())	return 0
	var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
	chambered = AC
	update_icon()	//I.E. fix the desc
	return 1

/obj/item/weapon/gun/projectile/shotgun/examine(mob/user)
	..()
	if (chambered)
		user << "A [chambered.BB ? "live" : "spent"] one is in the chamber."

/obj/item/weapon/gun/projectile/shotgun/combat
	name = "combat shotgun"
	desc = "A traditional shotgun with tactical furniture and an eight-shell capacity underneath."
	icon_state = "cshotgun"
	origin_tech = "combat=5;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/shotcom
	w_class = 5

/obj/item/weapon/gun/projectile/shotgun/riot //for spawn in the armory
	name = "riot shotgun"
	desc = "A sturdy shotgun with a longer magazine and a fixed tactical stock designed for non-lethal riot control."
	icon_state = "riotshotgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shotriot
	sawn_desc = "Come with me if you want to live."

/obj/item/weapon/gun/projectile/shotgun/riot/attackby(var/obj/item/A as obj, mob/user as mob)
	..()
	if(istype(A, /obj/item/weapon/circular_saw) || istype(A, /obj/item/weapon/pickaxe/plasmacutter))
		sawoff(user)
	if(istype(A, /obj/item/weapon/melee/energy))
		var/obj/item/weapon/melee/energy/W = A
		if(W.active)
			sawoff(user)

/obj/item/weapon/gun/projectile/revolver/doublebarrel
	name = "double-barreled shotgun"
	desc = "A true classic."
	icon_state = "dshotgun"
	item_state = "shotgun"
	w_class = 4.0
	force = 10
	flags =  CONDUCT
	slot_flags = SLOT_BACK
	origin_tech = "combat=3;materials=1"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/dualshot
	sawn_desc = "Omar's coming!"

/obj/item/weapon/gun/projectile/revolver/doublebarrel/attackby(var/obj/item/A as obj, mob/user as mob)
	..()
	if(istype(A, /obj/item/ammo_box) || istype(A, /obj/item/ammo_casing))
		chamber_round()
	if(istype(A, /obj/item/weapon/melee/energy))
		var/obj/item/weapon/melee/energy/W = A
		if(W.active)
			sawoff(user)
	if(istype(A, /obj/item/weapon/circular_saw) || istype(A, /obj/item/weapon/pickaxe/plasmacutter))
		sawoff(user)

/obj/item/weapon/gun/projectile/revolver/doublebarrel/attack_self(mob/living/user as mob)
	var/num_unloaded = 0
	while (get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		chambered = null
		CB.loc = get_turf(src.loc)
		CB.update_icon()
		num_unloaded++
	if (num_unloaded)
		user << "<span class = 'notice'>You break open \the [src] and unload [num_unloaded] shell\s.</span>"
	else
		user << "<span class='notice'>[src] is empty.</span>"


// IMPROVISED SHOTGUN //

/obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised
	name = "improvised shotgun"
	desc = "Essentially a tube that aims shotgun shells."
	icon_state = "ishotgun"
	item_state = "shotgun"
	w_class = 4.0
	force = 10
	origin_tech = "combat=2;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/improvised
	sawn_desc = "I'm just here for the gasoline."

/obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised/attackby(var/obj/item/A as obj, mob/user as mob)
	..()
	if(istype(A, /obj/item/stack/cable_coil) && !sawn_state)
		var/obj/item/stack/cable_coil/C = A
		if(C.use(10))
			flags =  CONDUCT
			slot_flags = SLOT_BACK
			icon_state = "ishotgunsling"
			user << "<span class='notice'>You tie the lengths of cable to the shotgun, making a sling.</span>"
			update_icon()
		else
			user << "<span class='warning'>You need at least ten lengths of cable if you want to make a sling.</span>"
			return

//Sawing guns related procs
/obj/item/weapon/gun/projectile/proc/blow_up(mob/user as mob)
	. = 0
	for(var/obj/item/ammo_casing/AC in magazine.stored_ammo)
		if(AC.BB)
			process_fire(user, user)
			. = 1

/obj/item/weapon/gun/projectile/shotgun/blow_up(mob/user as mob)
	. = 0
	if(chambered && chambered.BB)
		process_fire(user, user,0)
		. = 1
	for(var/obj/item/ammo_casing/AC in magazine.stored_ammo)
		if(AC.BB)
			chambered = AC
			process_fire(user, user,0)
			. = 1

/obj/item/weapon/gun/projectile/proc/sawoff(mob/user as mob)
	if(sawn_state == SAWN_OFF)
		user << "<span class='notice'>\The [src] is already shorten.</span>"
		return

	if(sawn_state == SAWN_SAWING)
		return

	user.visible_message("<span class='notice'>[user] begin to shorten \the [src].</span>", "<span class='notice'>You begin to shorten \the [src].</span>")

	//if there's any live ammo inside the gun, makes it go off
	if(blow_up(user))
		user.visible_message("<span class='danger'>\The [src] goes off!</span>", "<span class='danger'>\The [src] goes off in your face!</span>")
		return

	sawn_state = SAWN_SAWING

	if(do_after(user, 30))
		name = "sawn-off [src.name]"
		desc = sawn_desc
		icon_state = initial(icon_state) + "-sawn"
		w_class = 3.0
		item_state = "gun"
		slot_flags &= ~SLOT_BACK	//you can't sling it on your back
		slot_flags |= SLOT_BELT		//but you can wear it on your belt (poorly concealed under a trenchcoat, ideally)
		sawn_state = SAWN_OFF
		user.visible_message("<span class='warning'>[user] shorten \the [src]!</span>", "<span class='warning'>You shorten \the [src]!</span>")
		update_icon()
		return
	else
		sawn_state = SAWN_INTACT


/obj/item/weapon/gun/projectile/automatic/shotgun/bulldog
	name = "syndicate shotgun"
	desc = "A compact, mag-fed burst-fire shotgun for combat in narrow corridors, nicknamed 'Bulldog' by boarding parties. Compatible only with specialized 8-round drum magazines."
	icon_state = "bulldog"
	item_state = "bulldog"
	w_class = 3.0
	origin_tech = "combat=5;materials=4;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m12g
	fire_sound = 'sound/weapons/Gunshot.ogg'
	can_suppress = 0
	burst_size = 2
	fire_delay = 1
/obj/item/weapon/gun/projectile/automatic/shotgun/bulldog/New()
	..()
	update_icon()
	return
/obj/item/weapon/gun/projectile/automatic/shotgun/bulldog/proc/update_magazine()
	if(magazine)
		src.overlays = 0
		overlays += "[magazine.icon_state]"
		return
/obj/item/weapon/gun/projectile/automatic/shotgun/bulldog/update_icon()
	src.overlays = 0
	update_magazine()
	icon_state = "bulldog[chambered ? "" : "-e"]"
	return
/obj/item/weapon/gun/projectile/automatic/shotgun/bulldog/afterattack()
	..()
	empty_alarm()
	return