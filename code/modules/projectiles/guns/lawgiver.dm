#define HI_EX "hi-EX"
#define RAPID "rapid"
#define FLARE "flare"
#define STUN "stun"
#define LASER "laser"

/obj/item/weapon/gun/lawgiver
	desc = "The Lawgiver II. A twenty-five round sidearm with mission-variable voice-programmed ammunition."
	name = "lawgiver"
	icon_state = "lawgiver"
	item_state = "lawgiver"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	origin_tech = "combat=5;materials=5;engineering=5"
	w_class = 3.0
	starting_materials = list(MAT_IRON = 1000)
	w_type = RECYK_METAL
	recoil = 0
	flags = HEAR | FPRINT
	var/obj/item/ammo_storage/magazine/stored_magazine = null
	var/obj/item/ammo_casing/chambered = null
	var/firing_mode = STUN
	fire_delay = 0
	var/projectile_type = "/obj/item/projectile/energy/electrode"
	fire_sound = 'sound/weapons/Taser.ogg'
	var/magazine = null
	var/dna_profile = null
	var/rapidFirecheck = 0
	var/rapidFirechamber = 0
	var/rapidFirestop = 0
	var/rapid_message = 0
	var/damage_multiplier = 1
	var/has_played_alert = 0

/obj/item/weapon/gun/lawgiver/New()
	..()
	magazine = new /obj/item/ammo_storage/magazine/lawgiver
	verbs -= /obj/item/weapon/gun/lawgiver/verb/erase_DNA_sample
	update_icon()

/obj/item/weapon/gun/lawgiver/GetVoice()
	var/the_name = "The [name]"
	return the_name

/obj/item/weapon/gun/lawgiver/equipped(M as mob, hand)
	update_icon()

/obj/item/weapon/gun/lawgiver/update_icon()
	overlays.len = 0
	if(magazine)
		item_state = "[initial(icon_state)]1"
		var/obj/item/ammo_storage/magazine/lawgiver/L = magazine
		var/image/magazine_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)]Mag")
		var/image/ammo_overlay = null
		if(firing_mode == STUN && L.stuncharge)
			ammo_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)][L.stuncharge/20]")
		if(firing_mode == LASER && L.lasercharge)
			ammo_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)][L.lasercharge/20]")
		if(firing_mode == RAPID && L.rapid_ammo_count)
			ammo_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)][L.rapid_ammo_count]")
		if(firing_mode == FLARE && L.flare_ammo_count)
			ammo_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)][L.flare_ammo_count]")
		if(firing_mode == HI_EX && L.hi_ex_ammo_count)
			ammo_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)][L.hi_ex_ammo_count]")
		overlays += magazine_overlay
		overlays += ammo_overlay
	else
		item_state = "[initial(icon_state)]0"

	if (istype(loc,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc
		var/image/DNA_overlay = null
		if(H.l_hand == src || H.r_hand == src)
			if(dna_profile)
				if(dna_profile == H.dna.unique_enzymes)
					DNA_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)]DNAgood")
				else
					DNA_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)]DNAbad")
				overlays += DNA_overlay
		H.update_inv_r_hand()
		H.update_inv_l_hand()


/obj/item/weapon/gun/lawgiver/verb/submit_DNA_sample()
	set name = "Submit DNA sample"
	set category = "Object"
	set src in usr

	var/mob/living/carbon/human/H = loc

	if(!dna_profile)
		dna_profile = H.dna.unique_enzymes
		to_chat(usr, "<span class='notice'>You submit a DNA sample to \the [src].</span>")
		verbs += /obj/item/weapon/gun/lawgiver/verb/erase_DNA_sample
		verbs -= /obj/item/weapon/gun/lawgiver/verb/submit_DNA_sample

/obj/item/weapon/gun/lawgiver/verb/erase_DNA_sample()
	set name = "Erase DNA sample"
	set category = "Object"
	set src in usr

	var/mob/living/carbon/human/H = loc

	if(dna_profile)
		if(dna_profile == H.dna.unique_enzymes)
			dna_profile = null
			to_chat(usr, "<span class='notice'>You erase the DNA profile from \the [src].</span>")
			verbs += /obj/item/weapon/gun/lawgiver/verb/submit_DNA_sample
			verbs -= /obj/item/weapon/gun/lawgiver/verb/erase_DNA_sample
		else
			self_destruct(H)

/obj/item/weapon/gun/lawgiver/proc/self_destruct(mob/user)
	var/req_access = list(access_security)
	if(can_access(user.GetAccess(),req_access))
		say("ERROR: DNA PROFILE DOES NOT MATCH")
		return
	say("UNAUTHORIZED ACCESS DETECTED")
	explosion(user, -1, 0, 2)
	qdel(src)

/obj/item/weapon/gun/lawgiver/proc/LoadMag(var/obj/item/ammo_storage/magazine/AM, var/mob/user)
	if(istype(AM, /obj/item/ammo_storage/magazine/lawgiver) && !magazine)
		if(user)
			user.drop_item(AM, src)
			to_chat(user, "<span class='notice'>You load the magazine into \the [src].</span>")
		magazine = AM
		AM.update_icon()
		update_icon()
		return 1
	return 0

/obj/item/weapon/gun/lawgiver/proc/RemoveMag(var/mob/user)
	if(magazine)
		var/obj/item/ammo_storage/magazine/lawgiver/L = magazine
		L.loc = get_turf(src.loc)
		if(user)
			user.put_in_hands(L)
			to_chat(user, "<span class='notice'>You pull the magazine out of \the [src]!</span>")
		L.update_icon()
		magazine = null
		update_icon()
		return 1
	return 0

/obj/item/weapon/gun/lawgiver/Hear(message, atom/movable/speaker, var/datum/language/speaking, raw_message, radio_freq)
	if(speaker == src)
		return
	if(speaker == loc && !radio_freq && dna_profile)
		var/mob/living/carbon/human/H = loc
		if(dna_profile == H.dna.unique_enzymes)
			recoil = 0
			if((findtext(message, "stun")) || (findtext(message, "taser")))
				firing_mode = STUN
				fire_sound = 'sound/weapons/Taser.ogg'
				projectile_type = "/obj/item/projectile/energy/electrode"
				fire_delay = 0
				sleep(3)
				say("STUN")
			else if((findtext(message, "laser")) || (findtext(message, "lethal")) || (findtext(message, "beam")))
				firing_mode = LASER
				fire_sound = 'sound/weapons/lasercannonfire.ogg'
				projectile_type = "/obj/item/projectile/beam/heavylaser"
				fire_delay = 5
				sleep(3)
				say("LASER")
			else if((findtext(message, "rapid")) || (findtext(message, "automatic")))
				firing_mode = RAPID
				fire_sound = 'sound/weapons/Gunshot_c20.ogg'
				projectile_type = "/obj/item/projectile/bullet/midbullet/lawgiver"
				fire_delay = 0
				rapid_message = 0
				recoil = 1
				sleep(3)
				say("RAPID FIRE")
			else if((findtext(message, "flare")) || (findtext(message, "incendiary")))
				firing_mode = FLARE
				fire_sound = 'sound/weapons/shotgun.ogg'
				projectile_type = "/obj/item/projectile/flare"
				fire_delay = 5
				recoil = 1
				sleep(3)
				say("FLARE")
			else if((findtext(message, "hi ex")) || (findtext(message, "hi-ex")) || (findtext(message, "explosive")) || (findtext(message, "rocket")))
				firing_mode = HI_EX
				fire_sound = 'sound/weapons/elecfire.ogg'
				projectile_type = "/obj/item/projectile/bullet/gyro"
				fire_delay = 4
				recoil = 1
				sleep(3)
				say("HI-EX")
			update_icon()

/obj/item/weapon/gun/lawgiver/proc/rapidFire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0) //Burst fires don't work well except by calling Fire() multiple times
	rapidFirecheck = 1
	for (var/i = 1; i <= 3; i++)
		if(!rapidFirestop)
			Fire(target, user, params, reflex, struggle)
	rapidFirecheck = 0
	rapidFirechamber = 0
	rapidFirestop = 0
	rapid_message = 0

/obj/item/weapon/gun/lawgiver/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0) //Overriding this due to introducing the DNA check, and the fact that the round is to be chambered only just before it is fired
	if(dna_profile)
		if(dna_profile != user.dna.unique_enzymes)
			self_destruct(user)
			return
	else
		click_empty(user)
		say("PLEASE REGISTER A DNA SAMPLE")
		return

	if(firing_mode == RAPID && !rapidFirecheck)
		rapidFire(target, user, params, reflex, struggle)
		return

	if (!ready_to_fire())
		if (world.time % 3) //to prevent spam
			to_chat(user, "<span class='warning'>[src] is not ready to fire again!")
		return

	if(firing_mode == RAPID && !rapidFirechamber)
		in_chamber = null
		if(!chamber_round())
			rapidFirestop = 1
			return click_empty(user)
		rapidFirechamber = 1

	else if(firing_mode == RAPID && rapidFirechamber)
		in_chamber = new projectile_type(src)

	else if(firing_mode != RAPID)
		in_chamber = null
		if(!chamber_round())
			return click_empty(user)

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

	in_chamber.damage *= damage_multiplier

	add_fingerprint(user)

	var/turf/curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return

	if(!special_check(user))
		return

	if(!in_chamber)
		return
	log_attack("[user.name] ([user.ckey]) fired \the [src] (proj:[in_chamber.name]) at [target] [ismob(target) ? "([target:ckey])" : ""] ([target.x],[target.y],[target.z])[struggle ? " due to being disarmed." :""]" )
	in_chamber.firer = user
	in_chamber.def_zone = user.zone_sel.selecting
	if(targloc == curloc)
		user.bullet_act(in_chamber)
		del(in_chamber)
		update_icon()
		return

	if((firing_mode == RAPID && !rapid_message) || (firing_mode != RAPID)) //On rapid mode, only shake once per burst.
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

	playsound(user, fire_sound, 50, 1)
	if(!rapid_message)
		user.visible_message("<span class='warning'>[user] fires [src][reflex ? " by reflex":""]!</span>", \
		"<span class='warning'>You fire [src][reflex ? "by reflex":""]!</span>", \
		"You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")
		if(firing_mode == RAPID)
			rapid_message = 1

	in_chamber.original = target
	in_chamber.loc = get_turf(user)
	in_chamber.starting = get_turf(user)
	in_chamber.shot_from = src
	user.delayNextAttack(fire_delay)
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

	if(firing_mode == RAPID)
		var/obj/item/ammo_casing/a12mm/A = new /obj/item/ammo_casing/a12mm(user.loc)
		A.BB = null
		A.update_icon()
	if(firing_mode == HI_EX)
		var/obj/item/ammo_casing/a75/A = new /obj/item/ammo_casing/a75(user.loc)
		A.BB = null
		A.update_icon()

/obj/item/weapon/gun/lawgiver/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
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
		if(dna_profile)
			if(dna_profile != user.dna.unique_enzymes)
				self_destruct(user)
				return
		else
			user.visible_message("<span class = 'warning'>[user] pulls the trigger.</span>")
			click_empty(user)
			say("PLEASE REGISTER A DNA SAMPLE")
			return
		if (chamber_round())
			user.visible_message("<span class = 'warning'>[user] pulls the trigger.</span>")
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

	if (can_shoot())
		//Point blank shooting if on harm intent or target we were targeting.
		if(user.a_intent == I_HURT)
			user.visible_message("<span class='danger'> \The [user] fires \the [src] point blank at [M]!</span>")
			damage_multiplier = 1.3
			src.Fire(M,user,0,0,1)
			damage_multiplier = 1
			return
		else if(target && M in target)
			src.Fire(M,user,0,0,1)
			return
		else
			return ..()
	else
		return ..()

/obj/item/weapon/gun/lawgiver/proc/chamber_round()
	if(in_chamber || !magazine)
		return 0
	else
		var/obj/item/ammo_storage/magazine/lawgiver/L = magazine
		switch(firing_mode)
			if(STUN)
				if(L.stuncharge >= 20)
					if(in_chamber)	return 1
					if(!projectile_type)	return 0
					in_chamber = new projectile_type(src)
					L.stuncharge -= 20
					return 1
				else
					return 0
			if(LASER)
				if(L.lasercharge >= 20)
					if(in_chamber)	return 1
					if(!projectile_type)	return 0
					in_chamber = new projectile_type(src)
					L.lasercharge -= 20
					return 1
				else
					return 0
			if(RAPID)
				if(L.rapid_ammo_count >= 1)
					if(in_chamber)	return 1
					if(!projectile_type)	return 0
					in_chamber = new projectile_type(src)
					L.rapid_ammo_count -= 1
					return 1
				else
					return 0
			if(FLARE)
				if(L.flare_ammo_count >= 1)
					if(in_chamber)	return 1
					if(!projectile_type)	return 0
					in_chamber = new projectile_type(src)
					L.flare_ammo_count -= 1
					return 1
				else
					return 0
			if(HI_EX)
				if(L.hi_ex_ammo_count >= 1)
					if(in_chamber)	return 1
					if(!projectile_type)	return 0
					in_chamber = new projectile_type(src)
					L.hi_ex_ammo_count -= 1
					return 1
				else
					return 0
	return 0

/obj/item/weapon/gun/lawgiver/proc/can_shoot() //Only made so that firing point-blank can run its checks without chambering a round, since rounds are chambered in Fire()
	if(!magazine)
		return 0
	else
		var/obj/item/ammo_storage/magazine/lawgiver/L = magazine
		switch(firing_mode)
			if(STUN)
				if(L.stuncharge >= 20)
					if(in_chamber)	return 1
					if(!projectile_type)	return 0
					return 1
				else
					return 0
			if(LASER)
				if(L.lasercharge >= 20)
					if(in_chamber)	return 1
					if(!projectile_type)	return 0
					return 1
				else
					return 0
			if(RAPID)
				if(L.rapid_ammo_count >= 1)
					if(in_chamber)	return 1
					if(!projectile_type)	return 0
					return 1
				else
					return 0
			if(FLARE)
				if(L.flare_ammo_count >= 1)
					if(in_chamber)	return 1
					if(!projectile_type)	return 0
					return 1
				else
					return 0
			if(HI_EX)
				if(L.hi_ex_ammo_count >= 1)
					if(in_chamber)	return 1
					if(!projectile_type)	return 0
					return 1
				else
					return 0
	return 0

/obj/item/weapon/gun/lawgiver/attackby(var/obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/ammo_storage/magazine/lawgiver))
		var/obj/item/ammo_storage/magazine/lawgiver/AM = A
		if(!magazine)
			LoadMag(AM, user)
		else
			to_chat(user, "<span class='rose'>There is already a magazine loaded in \the [src]!</span>")
	else if (istype(A, /obj/item/ammo_storage/magazine))
		to_chat(user, "<span class='rose'>You can't load \the [src] with that kind of magazine!</span>")

/obj/item/weapon/gun/lawgiver/attack_self(mob/user as mob)
	if (target)
		return ..()
	if (magazine)
		RemoveMag(user)
	else
		to_chat(user, "<span class='warning'>There's no magazine loaded in \the [src]!</span>")

/obj/item/weapon/gun/lawgiver/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag, struggle = 0)
	..()
	if(magazine)
		var/obj/item/ammo_storage/magazine/lawgiver/L = magazine
		if(magazine && !countAmmo(L) && !has_played_alert)
			playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
			has_played_alert = 1
	return

/obj/item/weapon/gun/lawgiver/examine(mob/user)
	..()
	getAmmo(user)

/obj/item/weapon/gun/lawgiver/proc/getAmmo(mob/user)
	if (magazine)
		var/obj/item/ammo_storage/magazine/lawgiver/L = magazine
		to_chat(user, "<span class='info'>It has enough energy for [L.stuncharge/20] stun shot\s left.</span>")
		to_chat(user, "<span class='info'>It has enough energy for [L.lasercharge/20] laser shot\s left.</span>")
		to_chat(user, "<span class='info'>It has [L.rapid_ammo_count] rapid fire round\s remaining.</span>")
		to_chat(user, "<span class='info'>It has [L.flare_ammo_count] flare round\s remaining.</span>")
		to_chat(user, "<span class='info'>It has [L.hi_ex_ammo_count] hi-EX round\s remaining.</span>")

/obj/item/weapon/gun/lawgiver/proc/countAmmo(var/obj/item/A)
	var/obj/item/ammo_storage/magazine/lawgiver/L = A
	if (L.stuncharge == 0 && L.lasercharge == 0 && L.rapid_ammo_count == 0 && L.flare_ammo_count == 0 && L.hi_ex_ammo_count == 0)
		return 0
	else
		has_played_alert = 0
		return 1

#undef HI_EX
#undef RAPID
#undef FLARE
#undef STUN
#undef LASER