/obj/item/gun/ballistic
	desc = "Now comes in flavors like GUN. Uses 10mm ammo, for some reason."
	name = "projectile gun"
	icon_state = "pistol"
	w_class = WEIGHT_CLASS_NORMAL

	//sound info vars
	var/unload_sound = ''
	var/unload_sound_volume = 40
	var/unload_sound_vary = TRUE
	var/load_sound = "gun_insert_full_magazine"
	var/load_empty_sound = "gun_insert_empty_magazine"
	var/load_sound_volume = 40
	var/load_sound_vary = TRUE
	var/rack_sound = ''
	var/rack_sound_volume = 60
	var/rack_sound_vary = TRUE
	var/eject_sound = "gun_remove_empty_magazine"
	var/eject_sound_volume = 
	var/eject_sound_vary = TRUE
	var/bolt_drop_sound = ''
	var/bolt_drop_sound_volume = 40

	var/spawnwithmagazine = TRUE
	var/mag_type = /obj/item/ammo_box/magazine/m10mm //Removes the need for max_ammo and caliber info
	var/bolt_type = BOLT_TYPE_STANDARD
	var/bolt_locked = FALSE
	var/bolt_name = "bolt"
	var/obj/item/ammo_box/magazine/magazine
	var/casing_ejector = TRUE //whether the gun ejects the chambered casing
	var/magazine_wording = "magazine"

/obj/item/gun/ballistic/Initialize()
	. = ..()
	if(!spawnwithmagazine)
		update_icon()
		return
	if (!magazine)
		magazine = new mag_type(src)
	chamber_round()
	update_icon()

/obj/item/gun/ballistic/update_icon()
	..()
	if(current_skin)
		icon_state = "[unique_reskin[current_skin]][suppressed ? "-suppressed" : ""][sawn_off ? "-sawn" : ""]"
	else
		icon_state = "[initial(icon_state)][suppressed ? "-suppressed" : ""][sawn_off ? "-sawn" : ""]"


/obj/item/gun/ballistic/process_chamber(empty_chamber = TRUE)
	var/obj/item/ammo_casing/AC = chambered //Find chambered round
	if(istype(AC)) //there's a chambered round
		if(casing_ejector)
			AC.forceMove(drop_location()) //Eject casing onto ground.
			AC.bounce_away(TRUE)
			chambered = null
		else if(empty_chamber)
			chambered = null
	chamber_round()


/obj/item/gun/ballistic/proc/chamber_round()
	if (chambered || !magazine)
		return
	else if (magazine.ammo_count())
		chambered = magazine.get_round()
		chambered.forceMove(src)
	
/obj/item/gun/ballistic/proc/rack()
	if (bolt_type == BOLT_TYPE_OPEN || bolt_type == BOLT_TYPE_NO_BOLT)
		return
	playsound(src, rack_sound, rack_sound_volume, rack_sound_vary)
	to_chat(user, "<span class='notice'>You rack the [bolt_name] of \the [src].</span>")
	if (chambered)
		process_chamber(FALSE)

/obj/item/gun/ballistic/proc/drop_bolt()
	if (bolt_type != BOLT_TYPE_LOCKING)
		return
	playsound(src, bolt_drop_sound, bolt_drop_volume, FALSE)
	to_chat(user, "<span class='notice'>You drop the [bolt_name] of \the [src].</span>")
	chamber_round()
	update_icon()

/obj/item/gun/ballistic/proc/eject_magazine(mob/user)
	if(bolt_type == BOLT_TYPE_OPEN)
		var/obj/item/ammo_casing/AC = chambered
		magazine.give_round(AC)
		chambered = null
	magazine.forceMove(drop_location())
	user.put_in_hands(magazine)
	magazine.update_icon()
	if(magazine.ammo_count())
		playsound(src, load_sound, load_sound_volume, load_sound_vary)
	else
		playsound(src, load_empty_sound, load_sound_volume, load_sound_vary)
	magazine = null
	to_chat(user, "<span class='notice'>You pull the magazine out of \the [src].</span>")

/obj/item/gun/ballistic/can_shoot()
	if(chambered)
		return TRUE
	else
		if(!magazine || !magazine.ammo_count(FALSE))
			return FALSE
		else
			return TRUE

/obj/item/gun/ballistic/attackby(obj/item/A, mob/user, params)
	..()
	if (istype(A, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = A
		if (!magazine && istype(AM, mag_type))
			if(user.transferItemToLoc(AM, src))
				magazine = AM
				to_chat(user, "<span class='notice'>You load a new [magazine_wording] into \the [src].</span>")
				playsound(src, load_empty_sound, load_sound_volume, load_sound_vary)
				A.update_icon()
				update_icon()
				return TRUE
			else
				to_chat(user, "<span class='warning'>You cannot seem to get \the [src] out of your hands!</span>")
				return
		else if (magazine)
			to_chat(user, "<span class='notice'>There's already a [magazine_wording] in \the [src].</span>")
	if(istype(A, /obj/item/suppressor))
		var/obj/item/suppressor/S = A
		if(!can_suppress)
			to_chat(user, "<span class='warning'>You can't seem to figure out how to fit [S] on [src]!</span>")
			return
		if(!user.is_holding(src))
			to_chat(user, "<span class='notice'>You need be holding [src] to fit [S] to it!</span>")
			return
		if(suppressed)
			to_chat(user, "<span class='warning'>[src] already has a suppressor!</span>")
			return
		if(user.transferItemToLoc(A, src))
			to_chat(user, "<span class='notice'>You screw [S] onto [src].</span>")
			install_suppressor(A)
			return
	return 0

/obj/item/gun/ballistic/proc/install_suppressor(obj/item/suppressor/S)
	// this proc assumes that the suppressor is already inside src
	suppressed = S
	w_class += S.w_class //so pistols do not fit in pockets when suppressed
	update_icon()

/obj/item/gun/ballistic/AltClick(mob/user)
	if(loc == user)
		if(suppressed && can_unsuppress)
			var/obj/item/suppressor/S = suppressed
			if(!user.is_holding(src))
				return ..()
			to_chat(user, "<span class='notice'>You unscrew [suppressed] from [src]</span>")
			user.put_in_hands(suppressed)
			w_class -= S.w_class
			suppressed = null
			update_icon()
			return

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/gun/ballistic/attack_hand(mob/user)
	if(loc == user)
		if(magazine)
			eject_magazine(mob/user)
	return ..()

/obj/item/gun/ballistic/attack_self(mob/living/user)
	var/obj/item/ammo_casing/AC = chambered //Find chambered round
	if(bolt_type == BOLT_TYPE_LOCKING && bolt_locked)
		drop_bolt()
		return
	if(bolt_type == BOLT_TYPE_NO_BOLT)
		return
	if(magazine)
		if(magazine.ammo_count())
			eject_magazine(user)
			return
	rack()	
	return


/obj/item/gun/ballistic/examine(mob/user)
	..()
	to_chat(user, "It has [get_ammo()] round\s remaining.")
	if (suppressor)
		to_chat(user, "It has a suppressor attached that can be removed with alt+click.")

/obj/item/gun/ballistic/proc/get_ammo(countchambered = TRUE)
	var/boolets = 0 //mature var names for mature people
	if (chambered && countchambered)
		boolets++
	if (magazine)
		boolets += magazine.ammo_count()
	return boolets

#define BRAINS_BLOWN_THROW_RANGE 3
#define BRAINS_BLOWN_THROW_SPEED 1
/obj/item/gun/ballistic/suicide_act(mob/user)
	var/obj/item/organ/brain/B = user.getorganslot(ORGAN_SLOT_BRAIN)
	if (B && chambered && chambered.BB && can_trigger_gun(user) && !chambered.BB.nodamage)
		user.visible_message("<span class='suicide'>[user] is putting the barrel of [src] in [user.p_their()] mouth.  It looks like [user.p_theyre()] trying to commit suicide!</span>")
		sleep(25)
		if(user.is_holding(src))
			var/turf/T = get_turf(user)
			process_fire(user, user, FALSE, null, BODY_ZONE_HEAD)
			user.visible_message("<span class='suicide'>[user] blows [user.p_their()] brain[user.p_s()] out with [src]!</span>")
			var/turf/target = get_ranged_target_turf(user, turn(user.dir, 180), BRAINS_BLOWN_THROW_RANGE)
			B.Remove(user)
			B.forceMove(T)
			var/datum/callback/gibspawner = CALLBACK(GLOBAL_PROC, /proc/spawn_atom_to_turf, /obj/effect/gibspawner/generic, B, 1, FALSE, user)
			B.throw_at(target, BRAINS_BLOWN_THROW_RANGE, BRAINS_BLOWN_THROW_SPEED, callback=gibspawner)
			return(BRUTELOSS)
		else
			user.visible_message("<span class='suicide'>[user] panics and starts choking to death!</span>")
			return(OXYLOSS)
	else
		user.visible_message("<span class='suicide'>[user] is pretending to blow [user.p_their()] brain[user.p_s()] out with [src]! It looks like [user.p_theyre()] trying to commit suicide!</b></span>")
		playsound(src, dry_fire_sound, 30, TRUE)
		return (OXYLOSS)
#undef BRAINS_BLOWN_THROW_SPEED
#undef BRAINS_BLOWN_THROW_RANGE



/obj/item/gun/ballistic/proc/sawoff(mob/user)
	if(sawn_off)
		to_chat(user, "<span class='warning'>\The [src] is already shortened!</span>")
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("[user] begins to shorten \the [src].", "<span class='notice'>You begin to shorten \the [src]...</span>")

	//if there's any live ammo inside the gun, makes it go off
	if(blow_up(user))
		user.visible_message("<span class='danger'>\The [src] goes off!</span>", "<span class='danger'>\The [src] goes off in your face!</span>")
		return

	if(do_after(user, 30, target = src))
		if(sawn_off)
			return
		user.visible_message("[user] shortens \the [src]!", "<span class='notice'>You shorten \the [src].</span>")
		name = "sawn-off [src.name]"
		desc = sawn_desc
		w_class = WEIGHT_CLASS_NORMAL
		item_state = "gun"
		slot_flags &= ~ITEM_SLOT_BACK	//you can't sling it on your back
		slot_flags |= ITEM_SLOT_BELT		//but you can wear it on your belt (poorly concealed under a trenchcoat, ideally)
		sawn_off = TRUE
		update_icon()
		return 1

// Sawing guns related proc
/obj/item/gun/ballistic/proc/blow_up(mob/user)
	. = 0
	for(var/obj/item/ammo_casing/AC in magazine.stored_ammo)
		if(AC.BB)
			process_fire(user, user, FALSE)
			. = 1


/obj/item/suppressor
	name = "suppressor"
	desc = "A nigh-universal syndicate small-arms suppressor for maximum espionage."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "suppressor"
	w_class = WEIGHT_CLASS_TINY


/obj/item/suppressor/specialoffer
	name = "cheap suppressor"
	desc = "A foreign knock-off suppressor, it feels flimsy, cheap, and brittle. Still fits most weapons."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "suppressor"
