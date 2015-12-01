/obj/item/weapon/gun/projectile/nagant
	name = "mosin nagant"
	desc = "JOY OF HAVING MOSIN NAGANT RIFLE IS JOY THAT MONEY CANNOT AFFORD. "
	fire_sound = 'sound/weapons/nagant.ogg'
	icon_state = "nagant"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	max_shells = 5
	w_class = 4.0
	force = 10
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BACK
	caliber = list("7.62x55" = 1)
	origin_tech = "combat=4;materials=2"
	ammo_type ="/obj/item/ammo_casing/a762x55"
	var/recentpump = 0 // to prevent spammage
	var/pumped = 0
	var/obj/item/ammo_casing/current_shell = null


	gun_flags = 0

/obj/item/weapon/gun/projectile/nagant/isHandgun()
		return 0

/obj/item/weapon/gun/projectile/nagant/attack_self(mob/living/user as mob)
	if(recentpump)	return
	pump(user)
	recentpump = 1
	spawn(10)
		recentpump = 0
	return

/obj/item/weapon/gun/projectile/nagant/process_chambered()
	if(in_chamber)
		return 1
	else if(current_shell && current_shell.BB)
		in_chamber = current_shell.BB //Load projectile into chamber.
		current_shell.BB.loc = src //Set projectile loc to gun.
		current_shell.BB = null
		current_shell.update_icon()
		return 1
	return 0

/obj/item/weapon/gun/projectile/nagant/proc/pump(mob/M as mob)
	playsound(M, 'sound/weapons/nagantreload.ogg', 100, 1)
	pumped = 0
	if(current_shell)//We have a shell in the chamber
		current_shell.loc = get_turf(src)//Eject casing
		current_shell = null
		if(in_chamber)
			in_chamber = null
	if(!getAmmo())
		return 0
	var/obj/item/ammo_casing/AC = loaded[1] //load next casing.
	loaded -= AC //Remove casing from loaded list.
	current_shell = AC
	update_icon()	//I.E. fix the desc
	return 1

/obj/item/weapon/gun/projectile/nagant/attackby(var/obj/item/A as obj, mob/living/user as mob)
	..()
	if(istype(src, /obj/item/weapon/gun/projectile/nagant/obrez))
		return
	if(istype(A, /obj/item/weapon/circular_saw) || istype(A, /obj/item/weapon/melee/energy) || istype(A, /obj/item/weapon/pickaxe/plasmacutter))
		to_chat(user, "<span class='notice'>You begin to shorten the barrel of \the [src].</span>")
		if(getAmmo())
			user.visible_message("<span class='danger'>Take the ammo out first.</span>", "<span class='danger'>You need to take the ammo out first.</span>")
			return
		if(do_after(user, src, 30))
			var/obj/item/weapon/gun/projectile/nagant/obrez/newObrez = new /obj/item/weapon/gun/projectile/nagant/obrez(get_turf(src))
			for(var/obj/item/ammo_casing/AC in newObrez.loaded)
				newObrez.loaded -= AC
			del(src)
			to_chat(user, "<span class='warning'>You shorten the barrel of \the [src]!</span>")
	return

/obj/item/weapon/gun/projectile/nagant/obrez
	name = "obrez"
	desc = "WHEN YOU SHOW OBREZ TO ENEMY, HE THINKS YOU ARE CRAZED LUNATIC, LIKE KRUSCHEV POUNDING SHOE ON DESK AND SHOUTING ANGRY PLAN TO BURY NATO IN DEEP GRAVE. YOU FIRE WITH FLAME BURSTING LIKE FIRE OF DRAGON, TWISTING BOLT LIKE MANIAC BETWEEN FIRINGS AND EJECTING EMPTY CASE AS BIG AS BEER CAN FROM ACTION."
	fire_sound = 'sound/weapons/obrez.ogg'
	icon_state = "obrez"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	w_class = 3.0
	slot_flags = SLOT_BELT

/obj/item/weapon/gun/projectile/nagant/obrez/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if(flag)	return //we're placing gun on a table or in backpack
	if(current_shell && current_shell.BB)
		//explosion(src.loc,-1,1,2)
		var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(3, 0, get_turf(user)) //no idea what the 0 is
		sparks.start()

		var/turf/target_turf = get_turf(A)
		if(target_turf)
			var/turflist = getline(user, A)
			flame_turf(turflist)

		if(prob(15))
			to_chat(user, "<span class='danger'>[src] flies out of your hands.</span>")
			user.take_organ_damage(0,10)
			user.drop_item(src)
	Fire(A,user,params, "struggle" = struggle)
	return 1

/obj/item/weapon/gun/projectile/nagant/obrez/proc/flame_turf(turflist)
	var/turf/T = turflist[2]
	var/turf/previousturf

	if(length(turflist)>1)
		previousturf = get_turf(src)
	if(previousturf && LinkBlocked(previousturf, T))
		return
	if(!T.density && !istype(T, /turf/space))
		new /obj/fire(T) //add some fire as an effect because low intensity liquid fuel looks weak
		getFromPool(/obj/effect/decal/cleanable/liquid_fuel, T, 0.1, get_dir(T.loc, T)) //spawn some fuel at the turf
		T.hotspot_expose(500,500) //light it on fire
		previousturf = null

	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)
	return
