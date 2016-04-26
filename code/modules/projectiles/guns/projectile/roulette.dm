/obj/item/weapon/gun/projectile/roulette_revolver
	name = "\improper Roulette Revolver"
	desc = "A strange-looking revolver. Its construction appears somewhat slapdash."
	icon_state = "roulette_revolver"
	item_state = "gun"
	origin_tech = "combat=4;materials=4"
	w_class = 2.0
	starting_materials = list(MAT_IRON = 1000)
	w_type = RECYK_METAL
	flags = FPRINT
	siemens_coefficient = 1
	ejectshell = 0
	caliber = null
	ammo_type = null
	fire_sound = null
	recoil = 1
	conventional_firearm = 0
	var/shots_left = 6
	var/infinite = 0
	var/time_since_last_recharge = 0
	var/list/available_projectiles = list()
	var/list/restricted_projectiles = list(
		/obj/item/projectile,
		/obj/item/projectile/energy,
		/obj/item/projectile/hookshot,
		/obj/item/projectile/bullet/blastwave,
		/obj/item/projectile/beam/lightning,
		/obj/item/projectile/beam/lightning/spell,
		/obj/item/projectile/nikita,
		/obj/item/projectile/test,
		/obj/item/projectile/beam/emitter,
		/obj/item/projectile/meteor,
		/obj/item/projectile/spell_projectile,
		/obj/item/projectile/stickybomb,
		/obj/item/projectile/beam/lightlaser,
		/obj/item/projectile/portalgun,
		)

/obj/item/weapon/gun/projectile/roulette_revolver/New()
	..()
	available_projectiles = existing_typesof(/obj/item/projectile)
	processing_objects.Add(src)

/obj/item/weapon/gun/projectile/roulette_revolver/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/weapon/gun/projectile/roulette_revolver/process()
	if(time_since_last_recharge >= 8)
		if(shots_left < 6)
			shots_left++
		time_since_last_recharge = 0
	time_since_last_recharge++

/obj/item/weapon/gun/projectile/roulette_revolver/examine(mob/user)
	..()
	if(!shots_left)
		to_chat(user, "<span class='info'>\The [src] is empty.</span>")
	else
		to_chat(user, "<span class='info'>\The [src] has [shots_left] shots left.</span>")

/obj/item/weapon/gun/projectile/roulette_revolver/proc/choose_projectile()
	var/chosen_projectile = pick(available_projectiles)
	for(var/I in restricted_projectiles)
		if(chosen_projectile == I)
			choose_projectile()
			return
	var/P = new chosen_projectile()
	in_chamber = P
	if(!in_chamber)
		choose_projectile()
		return

/obj/item/weapon/gun/projectile/roulette_revolver/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if(flag)	return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.
		return

	choose_projectile()

	if(!in_chamber || shots_left < 1)
		click_empty(user)
		return

	if(istype(in_chamber, /obj/item/projectile/bullet))
		recoil = 1
	else
		recoil = 0

	if(user && user.client && user.client.gun_mode && !(A in target))
		PreFire(A,user,params, "struggle" = struggle) //They're using the new gun system, locate what they're aiming at.
	else
		var/obj/item/projectile/P = in_chamber
		if(Fire(A,user,params, "struggle" = struggle)) //Otherwise, fire normally.
			user.visible_message("<span class='danger'>[user] fires \a [P.name] from \his [src.name]!</span>","<span class='danger'>You fire \a [P.name] from your [src.name]!</span>")
			if(!infinite)
				shots_left -= 1
		else
			qdel(P)

/obj/item/weapon/gun/projectile/roulette_revolver/infinite
	infinite = 1
