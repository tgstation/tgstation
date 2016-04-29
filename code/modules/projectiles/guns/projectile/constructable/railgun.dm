#define MEGAWATT 1000000
#define TEN_MEGAWATTS 10000000
#define HUNDRED_MEGAWATTS 100000000
#define GIGAWATT 1000000000

/obj/item/weapon/gun/projectile/railgun
	name = "railgun"
	desc = "A weapon that uses the Lorentz force to propel an armature carrying a projectile to incredible velocities."
	icon = 'icons/obj/gun.dmi'
	icon_state = "railgun"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	item_state = null
	w_class = 4.0
	force = 10
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BACK | SLOT_BELT
	origin_tech = "materials=1;engineering=1;combat=1;power=1"
	ejectshell = 0
	caliber = null
	ammo_type = null
	fire_sound = 'sound/weapons/railgun_lowpower.ogg'
	conventional_firearm = 0
	var/rails = null //The internal rail assembly
	var/rails_secure = 0
	var/rod_loaded = 0
	var/capacitor = null
	var/percentage = 100
	var/strength = 0

/obj/item/weapon/gun/projectile/railgun/Destroy()
	if(capacitor)
		qdel(capacitor)
		capacitor = null
	if(rails)
		qdel(rails)
		rails = null
	..()

/obj/item/weapon/gun/projectile/railgun/attack_self(mob/user as mob)
	if(!capacitor)
		return

	var/obj/item/weapon/stock_parts/capacitor/C = capacitor
	C.forceMove(user.loc)
	user.put_in_hands(C)
	capacitor = null
	to_chat(user, "You remove \the [C] from the capacitor bank of \the [src].")

	update_icon()
	update_verbs()

/obj/item/weapon/gun/projectile/railgun/update_icon()
	overlays.len = 0

	if(rod_loaded)
		var/image/rod = image('icons/obj/weaponsmithing.dmi', src, "railgun_rod_overlay")
		overlays += rod
	if(capacitor)
		var/obj/item/weapon/stock_parts/capacitor/C = capacitor
		if(istype(C, /obj/item/weapon/stock_parts/capacitor/adv/super))
			var/image/capacitor = image('icons/obj/weaponsmithing.dmi', src, "railgun_capacitor_adv_super_overlay")
			overlays += capacitor
		else if(istype(C, /obj/item/weapon/stock_parts/capacitor/adv))
			var/image/capacitor = image('icons/obj/weaponsmithing.dmi', src, "railgun_capacitor_adv_overlay")
			overlays += capacitor
		else
			var/image/capacitor = image('icons/obj/weaponsmithing.dmi', src, "railgun_capacitor_overlay")
			overlays += capacitor

/obj/item/weapon/gun/projectile/railgun/proc/update_verbs()
	if(rod_loaded)
		verbs += /obj/item/weapon/gun/projectile/railgun/verb/remove_rod
	else
		verbs -= /obj/item/weapon/gun/projectile/railgun/verb/remove_rod

	if(capacitor)
		verbs += /obj/item/weapon/gun/projectile/railgun/verb/remove_capacitor
	else
		verbs -= /obj/item/weapon/gun/projectile/railgun/verb/remove_capacitor

	if(rails && !rails_secure)
		verbs += /obj/item/weapon/gun/projectile/railgun/verb/remove_rails
	else
		verbs -= /obj/item/weapon/gun/projectile/railgun/verb/remove_rails

/obj/item/weapon/gun/projectile/railgun/verb/remove_rod()
	set name = "Unload railgun"
	set category = "Object"
	set src in range(0)

	if(usr.isUnconscious())
		to_chat(usr, "You can't do that while unconscious.")
		return

	if(!rod_loaded)
		return

	var/obj/item/stack/rods/R = new(null)
	R.forceMove(usr.loc)
	usr.put_in_hands(R)
	rod_loaded = 0
	to_chat(usr, "You remove \the [R] from the barrel of \the [src].")

	update_icon()
	update_verbs()

/obj/item/weapon/gun/projectile/railgun/verb/remove_capacitor()
	set name = "Unload capacitor bank"
	set category = "Object"
	set src in range(0)

	if(usr.isUnconscious())
		to_chat(usr, "You can't do that while unconscious.")
		return

	if(!capacitor)
		return

	var/obj/item/weapon/stock_parts/capacitor/C = capacitor
	C.forceMove(usr.loc)
	usr.put_in_hands(C)
	capacitor = null
	to_chat(usr, "You remove \the [C] from the capacitor bank of \the [src].")

	update_icon()
	update_verbs()

/obj/item/weapon/gun/projectile/railgun/verb/remove_rails()
	set name = "Remove rail assembly"
	set category = "Object"
	set src in range(0)

	if(usr.isUnconscious())
		to_chat(usr, "You can't do that while unconscious.")
		return

	if(!rails)
		return

	var/obj/item/weapon/rail_assembly/R = rails
	R.forceMove(usr.loc)
	usr.put_in_hands(R)
	rails = null
	to_chat(usr, "You remove \the [R] from the barrel of \the [src].")

	update_icon()
	update_verbs()

/obj/item/weapon/gun/projectile/railgun/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/rail_assembly))
		if(rails)
			to_chat(user, "There is already a set of rails in \the [src].")
			return
		if(!user.drop_item(W, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
			return 1
		to_chat(user, "You insert \the [W] into the barrel of \the [src].")
		rails = W

	else if(isscrewdriver(W))
		if(rails)
			if(rails_secure)
				to_chat(user, "You loosen the rail assembly within \the [src].")
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
			else
				to_chat(user, "You tighten the rail assembly inside \the [src].")
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
			rails_secure = !rails_secure

	else if(istype(W, /obj/item/stack/rods))
		if(!rails)
			to_chat(user, "\The [src] needs a set of rails before it can hold a rod.")
			return
		if(!rails_secure)
			to_chat(user, "\The [src]'s rails need to be secured before they can hold a rod.")
			return
		if(rod_loaded)
			to_chat(user, "There is already a rod in the barrel of \the [src].")
			return
		to_chat(user, "You load a rod into the barrel of \the [src].")
		var/obj/item/stack/rods/R = W
		rod_loaded = 1
		R.use(1)

	else if(istype(W, /obj/item/weapon/stock_parts/capacitor))
		if(capacitor)
			to_chat(user, "There is already a capacitor in the capacitor bank of \the [src].")
			return
		if(!user.drop_item(W, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
			return 1
		to_chat(user, "You insert \the [W] into the capacitor bank of \the [src].")
		capacitor = W

	update_icon()
	update_verbs()

/obj/item/weapon/gun/projectile/railgun/examine(mob/user)
	..()
	if(capacitor)
		var/obj/item/weapon/stock_parts/capacitor/C = capacitor
		to_chat(user, "<span class='info'>There is \a [C] in the capacitor bank.</span>")
		if(C.stored_charge > 0)
			to_chat(user, "<span class='notice'>\The [C] is charged to [C.stored_charge]W.</span>")
		else
			to_chat(user, "<span class='warning'>\The [C] is not charged.</span>")
	if(rod_loaded)
		to_chat(user, "<span class='info'>There is \a metal rod loaded into the barrel.</span>")
	if(!rails)
		to_chat(user, "<span class='warning'>\The [src] is missing a set of rails.</span>")
	if(!rails_secure && rails)
		to_chat(user, "<span class='warning'>\The rail assembly inside \the [src] is unsecured.</span>")

/obj/item/weapon/gun/projectile/railgun/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if (istype(A, /obj/item/weapon/storage/backpack ))
		return

	else if (A.loc == user.loc)
		return

	else if (A.loc == user)
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	if(!capacitor || !rod_loaded)
		click_empty(user)
		return
	else if(capacitor)
		var/obj/item/weapon/stock_parts/capacitor/C = capacitor
		if(C.stored_charge <=0)
			click_empty(user)
			return
	if(flag)	return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.
		return

	calculate_strength(A,user,params, "struggle" = struggle)

/obj/item/weapon/gun/projectile/railgun/proc/calculate_strength(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if(!capacitor || !rod_loaded)
		return

	var/obj/item/weapon/stock_parts/capacitor/C = capacitor
	var/shot_charge = round(C.stored_charge * (percentage/100))
	C.stored_charge -= shot_charge
	if(shot_charge < MEGAWATT)
		strength = 0
		throw_rod(A,user)
	else if(shot_charge >= MEGAWATT && shot_charge < (MEGAWATT * 5))
		strength = 10
	else if(shot_charge >= (MEGAWATT * 5) && shot_charge < (MEGAWATT * 10))
		strength = 20
	else if(shot_charge >= (MEGAWATT * 10) && shot_charge < (MEGAWATT * 25))
		strength = 25
	else if(shot_charge >= (MEGAWATT * 25) && shot_charge < (MEGAWATT * 50))
		strength = 30
	else if(shot_charge >= (MEGAWATT * 50) && shot_charge < (MEGAWATT * 70))
		strength = 35
	else if(shot_charge >= (MEGAWATT * 70) && shot_charge < (MEGAWATT * 85))
		strength = 40
	else if(shot_charge >= (MEGAWATT * 85) && shot_charge < (MEGAWATT * 100))
		strength = 45
	else if(shot_charge >= (HUNDRED_MEGAWATTS * 1) && shot_charge < (HUNDRED_MEGAWATTS * 2))
		strength = 50
	else if(shot_charge >= (HUNDRED_MEGAWATTS * 2) && shot_charge < (HUNDRED_MEGAWATTS * 3))
		strength = 60
	else if(shot_charge >= (HUNDRED_MEGAWATTS * 3) && shot_charge < (HUNDRED_MEGAWATTS * 4))
		strength = 75
	else if(shot_charge >= (HUNDRED_MEGAWATTS * 4) && shot_charge < (HUNDRED_MEGAWATTS * 5))
		strength = 90
	else if(shot_charge >= (HUNDRED_MEGAWATTS * 5) && shot_charge < (HUNDRED_MEGAWATTS * 6))
		strength = 101
	else if(shot_charge >= (HUNDRED_MEGAWATTS * 6) && shot_charge < (HUNDRED_MEGAWATTS * 7))
		strength = 110
	else if(shot_charge >= (HUNDRED_MEGAWATTS * 7) && shot_charge < (HUNDRED_MEGAWATTS * 8))
		strength = 120
	else if(shot_charge >= (HUNDRED_MEGAWATTS * 8) && shot_charge < (HUNDRED_MEGAWATTS * 9))
		strength = 135
	else if(shot_charge >= (HUNDRED_MEGAWATTS * 9) && shot_charge < (GIGAWATT))
		strength = 150
	else if(shot_charge == GIGAWATT)
		strength = 200

	if(strength)
		var/obj/item/projectile/bullet/APS/B = new(null)
		B.damage = strength
		B.kill_count += strength
		if(strength >= 50)
			B.stun = 3
			B.weaken = 3
			B.stutter = 3
		if(strength >= 101)
			fire_sound = 'sound/weapons/railgun_highpower.ogg'
			B.penetration = (20 + (strength - 100))
			if(strength == 101)
				B.penetration -= 1
			B.superspeed = 1
		else if(strength == 90)
			B.penetration = 10
		in_chamber = B
		if(Fire(A,user,params, "struggle" = struggle))
			rod_loaded = 0
			var/obj/item/weapon/rail_assembly/R = rails
			if(strength == 200)
				to_chat(user, "<span class='warning'>\The [R] inside \the [src] melts!</span>")
				to_chat(user, "<span class='warning'>\The [C] inside \the [src]'s capacitor bank melts!</span>")
				rails = null
				rails_secure = 0
				qdel(R)
				capacitor = null
				qdel(C)
			else
				R.durability -= strength
				if(R.durability <= 0)
					to_chat(user, "<span class='warning'>\The [R] inside \the [src] [strength > 100 ? "shatters under" : "finally fractures from"] the stress!</span>")
					rails = null
					rails_secure = 0
					qdel(R)
			fire_sound = initial(fire_sound)
		else
			qdel(B)
			in_chamber = null

		update_icon()
		update_verbs()

/obj/item/weapon/gun/projectile/railgun/proc/throw_rod(atom/target as mob|obj|turf|area, mob/living/user as mob|obj)
	add_fingerprint(user)

	var/turf/curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return

	var/obj/item/object = new /obj/item/stack/rods(get_turf(user.loc))
	var/speed = 6

	var/distance = 10

	user.visible_message("<span class='danger'>[user] fires \the [src] and launches \the [object] at [target]!</span>","<span class='danger'>You fire \the [src] and launch \the [object] at [target]!</span>")
	log_attack("[user.name] ([user.ckey]) fired \the [src] (proj:[object.name]) at [target] [ismob(target) ? "([target:ckey])" : ""] ([target.x],[target.y],[target.z])" )

	object.forceMove(user.loc)
	object.throw_at(target,distance,speed)
	rod_loaded = 0

#undef MEGAWATT
#undef TEN_MEGAWATTS
#undef HUNDRED_MEGAWATTS
#undef GIGAWATT