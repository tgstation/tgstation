/obj/item/weapon/gun
	name = "gun"
	desc = "Its a gun. It's pretty terrible, though."
	icon = 'icons/obj/gun.dmi'
	icon_state = "detective"
	item_state = "gun"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	starting_materials = list(MAT_IRON = 2000)
	w_type = RECYK_METAL
	w_class = 3.0
	throwforce = 5
	throw_speed = 4
	throw_range = 5
	force = 5.0
	origin_tech = "combat=1"
	attack_verb = list("struck", "hit", "bashed")
	mech_flags = MECH_SCAN_ILLEGAL
	min_harm_label = 20
	harm_label_examine = list("<span class='info'>A label is stuck to the trigger, but it is too small to get in the way.</span>", "<span class='warning'>A label firmly sticks the trigger to the guard!</span>")

	var/fire_sound = 'sound/weapons/Gunshot.ogg'
	var/obj/item/projectile/in_chamber = null
	var/list/caliber //the ammo the gun will accept. Now multiple types (make sure to set them to =1)
	var/silenced = 0
	var/recoil = 0
	var/ejectshell = 1
	var/clumsy_check = 1
	var/tmp/list/mob/living/target //List of who yer targeting.
	var/tmp/lock_time = -100
	var/tmp/mouthshoot = 0 ///To stop people from suiciding twice... >.>
	var/automatic = 0 //Used to determine if you can target multiple people.
	var/tmp/mob/living/last_moved_mob //Used to fire faster at more than one person.
	var/tmp/told_cant_shoot = 0 //So that it doesn't spam them with the fact they cannot hit them.
	var/firerate = 1 	// 0 for one bullet after tarrget moves and aim is lowered,
						//1 for keep shooting until aim is lowered
	var/fire_delay = 2
	var/last_fired = 0

/obj/item/weapon/gun/proc/ready_to_fire()
	if(world.time >= last_fired + fire_delay)
		last_fired = world.time
		return 1
	else
		return 0

/obj/item/weapon/gun/proc/process_chambered()
	return 0

/obj/item/weapon/gun/proc/special_check(var/mob/M) //Placeholder for any special checks, like detective's revolver.
	return 1

/obj/item/weapon/gun/emp_act(severity)
	for(var/obj/O in contents)
		O.emp_act(severity)

/obj/item/weapon/gun/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if(flag)	return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.

		return
	if(istype(target, /obj/machinery/recharger) && istype(src, /obj/item/weapon/gun/energy))	return//Shouldnt flag take care of this?
	if(user && user.client && user.client.gun_mode && !(A in target))
		PreFire(A,user,params, "struggle" = struggle) //They're using the new gun system, locate what they're aiming at.
	else
		Fire(A,user,params, "struggle" = struggle) //Otherwise, fire normally.

/obj/item/weapon/gun/proc/isHandgun()
	return 1

/obj/item/weapon/gun/proc/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0)//TODO: go over this
	//Exclude lasertag guns from the M_CLUMSY check.
	if(clumsy_check)
		if(istype(user, /mob/living))
			var/mob/living/M = user
			if ((M_CLUMSY in M.mutations) && prob(50))
				to_chat(M, "<span class='danger'>[src] blows up in your face.</span>")
				M.take_organ_damage(0,20)
				M.drop_item(src)
				qdel(src)
				return

	if (!user.IsAdvancedToolUser() || isMoMMI(user) || istype(user, /mob/living/carbon/monkey/diona))
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(istype(user, /mob/living))
		var/mob/living/M = user
		if (M_HULK in M.mutations)
			to_chat(M, "<span class='warning'>Your meaty finger is much too large for the trigger guard!</span>")
			return
	if(ishuman(user))
		var/mob/living/carbon/human/H=user
		if(user.dna && user.dna.mutantrace == "adamantine")
			to_chat(user, "<span class='warning'>Your metal fingers don't fit in the trigger guard!</span>")
			return
		var/datum/organ/external/a_hand = H.get_active_hand_organ()
		if(!a_hand.can_use_advanced_tools())
			to_chat(user, "<span class='warning'>Your [a_hand] doesn't have the dexterity to do this!</span>")
			return

	add_fingerprint(user)

	var/turf/curloc = user.loc
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return

	if(!special_check(user))
		return

	if (!ready_to_fire())
		if (world.time % 3) //to prevent spam
			to_chat(user, "<span class='warning'>[src] is not ready to fire again!")
		return

	if(!process_chambered()) //CHECK
		return click_empty(user)

	if(!in_chamber)
		return
	if(!istype(src, /obj/item/weapon/gun/energy/laser/redtag) && !istype(src, /obj/item/weapon/gun/energy/laser/redtag))
		log_attack("[user.name] ([user.ckey]) fired \the [src] (proj:[in_chamber.name]) at [target] [ismob(target) ? "([target:ckey])" : ""] ([target.x],[target.y],[target.z])[struggle ? " due to being disarmed." :""]" )
	in_chamber.firer = user

	if(user.zone_sel)
		in_chamber.def_zone = user.zone_sel.selecting
	else
		in_chamber.def_zone = "chest"

	if(targloc == curloc)
		user.bullet_act(in_chamber)
		del(in_chamber)
		update_icon()
		return

	if(recoil)
		spawn()
			shake_camera(user, recoil + 1, recoil)
		if(user.locked_to && isobj(user.locked_to) && !user.locked_to.anchored )
			var/direction = get_dir(user,target)
			spawn()
				var/obj/B = user.locked_to
				var/movementdirection = turn(direction,180)
				B.Move(get_step(user,movementdirection), movementdirection)
				sleep(1)
				B.Move(get_step(user,movementdirection), movementdirection)
				sleep(1)
				B.Move(get_step(user,movementdirection), movementdirection)
				sleep(1)
				B.Move(get_step(user,movementdirection), movementdirection)
				sleep(2)
				B.Move(get_step(user,movementdirection), movementdirection)
				sleep(2)
				B.Move(get_step(user,movementdirection), movementdirection)
				sleep(3)
				B.Move(get_step(user,movementdirection), movementdirection)
				sleep(3)
				B.Move(get_step(user,movementdirection), movementdirection)
				sleep(3)
				B.Move(get_step(user,movementdirection), movementdirection)
		if((istype(user.loc, /turf/space)) || (user.areaMaster.has_gravity == 0))
			user.inertia_dir = get_dir(target, user)
			step(user, user.inertia_dir)

	if(silenced)
		playsound(user, fire_sound, 10, 1)
	else
		playsound(user, fire_sound, 50, 1)
		user.visible_message("<span class='warning'>[user] fires [src][reflex ? " by reflex":""]!</span>", \
		"<span class='warning'>You fire [src][reflex ? "by reflex":""]!</span>", \
		"You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")

	in_chamber.original = target
	in_chamber.loc = get_turf(user)
	in_chamber.starting = get_turf(user)
	in_chamber.shot_from = src
	user.delayNextAttack(4) // TODO: Should be delayed per-gun.
	in_chamber.silenced = silenced
	in_chamber.current = curloc
	in_chamber.OnFired()
	in_chamber.yo = targloc.y - curloc.y
	in_chamber.xo = targloc.x - curloc.x
	in_chamber.inaccurate = (istype(user.locked_to, /obj/structure/bed/chair/vehicle))

	if(params)
		var/list/mouse_control = params2list(params)
		if(mouse_control["icon-x"])
			in_chamber.p_x = text2num(mouse_control["icon-x"])
		if(mouse_control["icon-y"])
			in_chamber.p_y = text2num(mouse_control["icon-y"])

	spawn()
		if(in_chamber)
			in_chamber.process()
	sleep(1)
	in_chamber = null

	update_icon()

	if(user.hand)
		user.update_inv_l_hand()
	else
		user.update_inv_r_hand()

/obj/item/weapon/gun/proc/can_fire()
	return process_chambered()

/obj/item/weapon/gun/proc/can_hit(var/mob/living/target as mob, var/mob/living/user as mob)
	return in_chamber.check_fire(target,user)

/obj/item/weapon/gun/proc/click_empty(mob/user = null)
	if (user)
		user.visible_message("*click click*", "<span class='danger'>*click*</span>")
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	else
		src.visible_message("*click click*")
		playsound(get_turf(src), 'sound/weapons/empty.ogg', 100, 1)

/obj/item/weapon/gun/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	//Suicide handling.
	if (M == user && user.zone_sel.selecting == "mouth" && !mouthshoot)
		if(istype(M.wear_mask, /obj/item/clothing/mask/happy))
			to_chat(M, "<span class='sinister'>BUT WHY? I'M SO HAPPY!</span>")
			return
		mouthshoot = 1
		M.visible_message("<span class='warning'>[user] sticks their gun in their mouth, ready to pull the trigger...</span>")
		if(!do_after(user,src, 40))
			M.visible_message("<span class='notice'>[user] decided life was worth living</span>")
			mouthshoot = 0
			return
		if (process_chambered())
			user.visible_message("<span class = 'warning'>[user] pulls the trigger.</span>")
			if(silenced)
				playsound(user, fire_sound, 10, 1)
			else
				playsound(user, fire_sound, 50, 1)
			in_chamber.on_hit(M)
			if (!in_chamber.nodamage)
				user.apply_damage(in_chamber.damage*2.5, in_chamber.damage_type, "head", used_weapon = "Point blank shot in the mouth with \a [in_chamber]")
				user.stat=2 // Just to be sure
				user.death()
			else
				to_chat(user, "<span class = 'notice'>Ow...</span>")
				user.apply_effect(110,AGONY,0)
			del(in_chamber)
			mouthshoot = 0
			return
		else
			click_empty(user)
			mouthshoot = 0
			return

	if (src.process_chambered())
		//Point blank shooting if on harm intent or target we were targeting.
		if(user.a_intent == I_HURT)
			user.visible_message("<span class='danger'> \The [user] fires \the [src] point blank at [M]!</span>")
			in_chamber.damage *= 1.3
			src.Fire(M,user,0,0,1)
			return
		else if(target && M in target)
			src.Fire(M,user,0,0,1) ///Otherwise, shoot!
			return
		else
			return ..() //Allows a player to choose to melee instead of shoot, by being on help intent.
	else
		return ..() //Pistolwhippin'