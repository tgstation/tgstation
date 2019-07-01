/obj/item/gun/ballistic
	desc = "Now comes in flavors like GUN. Uses 10mm ammo, for some reason."
	name = "projectile gun"
	icon_state = "pistol"
	w_class = WEIGHT_CLASS_NORMAL

	//sound info vars
	var/load_sound = "gun_insert_full_magazine"
	var/load_empty_sound = "gun_insert_empty_magazine"
	var/load_sound_volume = 40
	var/load_sound_vary = TRUE
	var/rack_sound = "gun_slide_lock"
	var/rack_sound_volume = 60
	var/rack_sound_vary = TRUE
	var/lock_back_sound = "sound/weapons/pistollock.ogg"
	var/lock_back_sound_volume = 60
	var/lock_back_sound_vary = TRUE
	var/eject_sound = "gun_remove_empty_magazine"
	var/eject_empty_sound = "gun_remove_full_magazine"
	var/eject_sound_volume = 40
	var/eject_sound_vary = TRUE
	var/bolt_drop_sound = 'sound/weapons/gun_chamber_round.ogg'
	var/bolt_drop_sound_volume = 60
	var/empty_alarm_sound = 'sound/weapons/smg_empty_alarm.ogg'
	var/empty_alarm_volume = 70
	var/empty_alarm_vary = TRUE

	var/spawnwithmagazine = TRUE
	var/mag_type = /obj/item/ammo_box/magazine/m10mm //Removes the need for max_ammo and caliber info
	var/mag_display = FALSE //Whether the sprite has a visible magazine or not
	var/mag_display_ammo = FALSE //Whether the sprite has a visible ammo display or not
	var/empty_indicator = FALSE //Whether the sprite has an indicator for being empty or not.
	var/empty_alarm = FALSE //Whether the gun alarms when empty or not.
	var/special_mags = FALSE //Whether the gun supports multiple special mag types
	var/alarmed = FALSE
	//Four bolt types:
	//BOLT_TYPE_STANDARD: Gun has a bolt, it stays closed while not cycling. The gun must be racked to have a bullet chambered when a mag is inserted.
	//Example: c20, shotguns, m90
	//BOLT_TYPE_OPEN: Gun has a bolt, it is open when ready to fire. The gun can never have a chambered bullet with no magazine, but the bolt stays ready when a mag is removed.
	//Example: Some SMGs, the L6
	//BOLT_TYPE_NO_BOLT: Gun has no moving bolt mechanism, it cannot be racked. Also dumps the entire contents when emptied instead of a magazine.
	//Example: Break action shotguns, revolvers
	//BOLT_TYPE_LOCKING: Gun has a bolt, it locks back when empty. It can be released to chamber a round if a magazine is in.
	//Example: Pistols with a slide lock, some SMGs
	var/bolt_type = BOLT_TYPE_STANDARD
	var/bolt_locked = FALSE //Used for locking bolt and open bolt guns. Set a bit differently for the two but prevents firing when true for both.
	var/bolt_wording = "bolt" //bolt, slide, etc.
	var/semi_auto = TRUE //Whether the gun has to be racked each shot or not.
	var/obj/item/ammo_box/magazine/magazine
	var/casing_ejector = TRUE //whether the gun ejects the chambered casing
	var/internal_magazine = FALSE //Whether the gun has an internal magazine or a detatchable one. Overridden by BOLT_TYPE_NO_BOLT.
	var/magazine_wording = "magazine"
	var/cartridge_wording = "bullet"
	var/rack_delay = 5
	var/recent_rack = 0
	var/tac_reloads = TRUE //Snowflake mechanic no more.
	var/can_be_sawn_off  = FALSE

/obj/item/gun/ballistic/Initialize()
	. = ..()
	if (!spawnwithmagazine)
		bolt_locked = TRUE
		update_icon()
		return
	if (!magazine)
		magazine = new mag_type(src)
	chamber_round()
	update_icon()

/obj/item/gun/ballistic/update_icon()
	if (QDELETED(src))
		return
	..()
	if(current_skin)
		icon_state = "[unique_reskin[current_skin]][sawn_off ? "_sawn" : ""]"
	else
		icon_state = "[initial(icon_state)][sawn_off ? "_sawn" : ""]"
	cut_overlays()
	if (bolt_type == BOLT_TYPE_LOCKING)
		add_overlay("[icon_state]_bolt[bolt_locked ? "_locked" : ""]")
	if (bolt_type == BOLT_TYPE_OPEN && bolt_locked)
		add_overlay("[icon_state]_bolt")
	if (suppressed)
		add_overlay("[icon_state]_suppressor")
	if(!chambered && empty_indicator)
		add_overlay("[icon_state]_empty")
	if (magazine)
		if (special_mags)
			add_overlay("[icon_state]_mag_[initial(magazine.icon_state)]")
			if (!magazine.ammo_count())
				add_overlay("[icon_state]_mag_empty")
		else
			add_overlay("[icon_state]_mag")
			var/capacity_number = 0
			switch(get_ammo() / magazine.max_ammo)
				if(0.2 to 0.39)
					capacity_number = 20
				if(0.4 to 0.59)
					capacity_number = 40
				if(0.6 to 0.79)
					capacity_number = 60
				if(0.8 to 0.99)
					capacity_number = 80
				if(1.0)
					capacity_number = 100
			if (capacity_number)
				add_overlay("[icon_state]_mag_[capacity_number]")


/obj/item/gun/ballistic/process_chamber(empty_chamber = TRUE, from_firing = TRUE, chamber_next_round = TRUE)
	if(!semi_auto && from_firing)
		return
	var/obj/item/ammo_casing/AC = chambered //Find chambered round
	if(istype(AC)) //there's a chambered round
		if(casing_ejector || !from_firing)
			AC.forceMove(drop_location()) //Eject casing onto ground.
			AC.bounce_away(TRUE)
			chambered = null
		else if(empty_chamber)
			chambered = null
	if (chamber_next_round && (magazine?.max_ammo > 1))
		chamber_round()

/obj/item/gun/ballistic/proc/chamber_round(keep_bullet = FALSE)
	if (chambered || !magazine)
		return
	if (magazine.ammo_count())
		chambered = magazine.get_round(keep_bullet || bolt_type == BOLT_TYPE_NO_BOLT)
		if (bolt_type != BOLT_TYPE_OPEN)
			chambered.forceMove(src)

/obj/item/gun/ballistic/proc/rack(mob/user = null)
	if (bolt_type == BOLT_TYPE_NO_BOLT) //If there's no bolt, nothing to rack
		return
	if (bolt_type == BOLT_TYPE_OPEN)
		if(!bolt_locked)	//If it's an open bolt, racking again would do nothing
			if (user)
				to_chat(user, "<span class='notice'>\The [src]'s [bolt_wording] is already cocked!</span>")
			return
		bolt_locked = FALSE
	if (user)
		to_chat(user, "<span class='notice'>You rack the [bolt_wording] of \the [src].</span>")
	process_chamber(!chambered, FALSE)
	if (bolt_type == BOLT_TYPE_LOCKING && !chambered)
		bolt_locked = TRUE
		playsound(src, lock_back_sound, lock_back_sound_volume, lock_back_sound_vary)
	else
		playsound(src, rack_sound, rack_sound_volume, rack_sound_vary)
	update_icon()

/obj/item/gun/ballistic/proc/drop_bolt(mob/user = null)
	playsound(src, bolt_drop_sound, bolt_drop_sound_volume, FALSE)
	if (user)
		to_chat(user, "<span class='notice'>You drop the [bolt_wording] of \the [src].</span>")
	chamber_round()
	bolt_locked = FALSE
	update_icon()

/obj/item/gun/ballistic/proc/insert_magazine(mob/user, obj/item/ammo_box/magazine/AM, display_message = TRUE)
	if(!istype(AM, mag_type))
		to_chat(user, "<span class='warning'>\The [AM] doesn't seem to fit into \the [src]...</span>")
		return FALSE
	if(user.transferItemToLoc(AM, src))
		magazine = AM
		if (display_message)
			to_chat(user, "<span class='notice'>You load a new [magazine_wording] into \the [src].</span>")
		playsound(src, load_empty_sound, load_sound_volume, load_sound_vary)
		if (bolt_type == BOLT_TYPE_OPEN && !bolt_locked)
			chamber_round(TRUE)
		update_icon()
		return TRUE
	else
		to_chat(user, "<span class='warning'>You cannot seem to get \the [src] out of your hands!</span>")
		return FALSE

/obj/item/gun/ballistic/proc/eject_magazine(mob/user, display_message = TRUE, obj/item/ammo_box/magazine/tac_load = null)
	if(bolt_type == BOLT_TYPE_OPEN)
		chambered = null
	if (magazine.ammo_count())
		playsound(src, load_sound, load_sound_volume, load_sound_vary)
	else
		playsound(src, load_empty_sound, load_sound_volume, load_sound_vary)
	magazine.forceMove(drop_location())
	var/obj/item/ammo_box/magazine/old_mag = magazine
	if (tac_load)
		if (insert_magazine(user, tac_load, FALSE))
			to_chat(user, "<span class='notice'>You perform a tactical reload on \the [src].</span>")
		else
			to_chat(user, "<span class='warning'>You dropped the old [magazine_wording], but the new one doesn't fit. How embarassing.</span>")
			magazine = null
	else
		magazine = null
	user.put_in_hands(old_mag)
	old_mag.update_icon()
	if (display_message)
		to_chat(user, "<span class='notice'>You pull the [magazine_wording] out of \the [src].</span>")
	update_icon()

/obj/item/gun/ballistic/can_shoot()
	return chambered

/obj/item/gun/ballistic/attackby(obj/item/A, mob/user, params)
	. = ..()
	if (.)
		return
	if (!internal_magazine && istype(A, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = A
		if (!magazine)
			insert_magazine(user, AM)
		else
			if (tac_reloads)
				eject_magazine(user, FALSE, AM)
			else
				to_chat(user, "<span class='notice'>There's already a [magazine_wording] in \the [src].</span>")
		return
	if (istype(A, /obj/item/ammo_casing) || istype(A, /obj/item/ammo_box))
		if (bolt_type == BOLT_TYPE_NO_BOLT || internal_magazine)
			if (chambered && !chambered.BB)
				chambered.forceMove(drop_location())
				chambered = null
			var/num_loaded = magazine.attackby(A, user, params, TRUE)
			if (num_loaded)
				to_chat(user, "<span class='notice'>You load [num_loaded] [cartridge_wording]\s into \the [src].</span>")
				playsound(src, load_sound, load_sound_volume, load_sound_vary)
				if (chambered == null && bolt_type == BOLT_TYPE_NO_BOLT)
					chamber_round()
				A.update_icon()
				update_icon()
			return
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
			to_chat(user, "<span class='notice'>You screw \the [S] onto \the [src].</span>")
			install_suppressor(A)
			return
	if (can_be_sawn_off)
		if (sawoff(user, A))
			return
	return FALSE

/obj/item/gun/ballistic/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if (sawn_off)
		bonus_spread += SAWN_OFF_ACC_PENALTY
	. = ..()

/obj/item/gun/ballistic/proc/install_suppressor(obj/item/suppressor/S)
	// this proc assumes that the suppressor is already inside src
	suppressed = S
	w_class += S.w_class //so pistols do not fit in pockets when suppressed
	update_icon()

/obj/item/gun/ballistic/AltClick(mob/user)
	if (unique_reskin && !current_skin && user.canUseTopic(src, BE_CLOSE, NO_DEXTERY))
		reskin_obj(user)
		return
	if(loc == user)
		if(suppressed && can_unsuppress)
			var/obj/item/suppressor/S = suppressed
			if(!user.is_holding(src))
				return ..()
			to_chat(user, "<span class='notice'>You unscrew \the [suppressed] from \the [src].</span>")
			user.put_in_hands(suppressed)
			w_class -= S.w_class
			suppressed = null
			update_icon()
			return

/obj/item/gun/ballistic/proc/prefire_empty_checks()
	if (!chambered && !get_ammo())
		if (bolt_type == BOLT_TYPE_OPEN && !bolt_locked)
			bolt_locked = TRUE
			playsound(src, bolt_drop_sound, bolt_drop_sound_volume)
			update_icon()


/obj/item/gun/ballistic/proc/postfire_empty_checks()
	if (!chambered && !get_ammo())
		if (!alarmed && empty_alarm)
			playsound(src, empty_alarm_sound, empty_alarm_volume, empty_alarm_vary)
			alarmed = TRUE
			update_icon()
		if (bolt_type == BOLT_TYPE_LOCKING)
			bolt_locked = TRUE
			update_icon()

/obj/item/gun/ballistic/afterattack()
	prefire_empty_checks()
	. = ..() //The gun actually firing
	postfire_empty_checks()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/gun/ballistic/attack_hand(mob/user)
	if(!internal_magazine && loc == user && user.is_holding(src) && magazine)
		eject_magazine(user)
		return
	return ..()

/obj/item/gun/ballistic/attack_self(mob/living/user)
	if(!internal_magazine && magazine)
		if(!magazine.ammo_count())
			eject_magazine(user)
			return
	if(bolt_type == BOLT_TYPE_NO_BOLT)
		chambered = null
		var/num_unloaded = 0
		for(var/obj/item/ammo_casing/CB in get_ammo_list(FALSE, TRUE))
			CB.forceMove(drop_location())
			CB.bounce_away(FALSE, NONE)
			num_unloaded++
		if (num_unloaded)
			to_chat(user, "<span class='notice'>You unload [num_unloaded] [cartridge_wording]\s from [src].</span>")
			playsound(user, eject_sound, eject_sound_volume, eject_sound_vary)
			update_icon()
		else
			to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return
	if(bolt_type == BOLT_TYPE_LOCKING && bolt_locked)
		drop_bolt(user)
		return
	if (recent_rack > world.time)
		return
	recent_rack = world.time + rack_delay
	rack(user)
	return


/obj/item/gun/ballistic/examine(mob/user)
	. = ..()
	var/count_chambered = !(bolt_type == BOLT_TYPE_NO_BOLT || bolt_type == BOLT_TYPE_OPEN)
	. += "It has [get_ammo(count_chambered)] round\s remaining."
	if (!chambered)
		. += "It does not seem to have a round chambered."
	if (bolt_locked)
		. += "The [bolt_wording] is locked back and needs to be released before firing."
	if (suppressed)
		. += "It has a suppressor attached that can be removed with <b>alt+click</b>."

/obj/item/gun/ballistic/proc/get_ammo(countchambered = TRUE)
	var/boolets = 0 //mature var names for mature people
	if (chambered && countchambered)
		boolets++
	if (magazine)
		boolets += magazine.ammo_count()
	return boolets

/obj/item/gun/ballistic/proc/get_ammo_list(countchambered = TRUE, drop_all = FALSE)
	var/list/rounds = list()
	if(chambered && countchambered)
		rounds.Add(chambered)
		if(drop_all)
			chambered = null
	rounds.Add(magazine.ammo_list(drop_all))
	return rounds

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

GLOBAL_LIST_INIT(gun_saw_types, typecacheof(list(
	/obj/item/circular_saw,
	/obj/item/gun/energy/plasmacutter,
	/obj/item/melee/transforming/energy,
	/obj/item/twohanded/required/chainsaw,
	/obj/item/nullrod/claymore/chainsaw_sword,
	/obj/item/nullrod/chainsaw,
	/obj/item/mounted_chainsaw)))

/obj/item/gun/ballistic/proc/sawoff(mob/user, obj/item/saw)
	if(!saw.is_sharp() || !is_type_in_typecache(saw, GLOB.gun_saw_types)) //needs to be sharp. Otherwise turned off eswords can cut this.
		return
	if(sawn_off)
		to_chat(user, "<span class='warning'>\The [src] is already shortened!</span>")
		return
	if(bayonet)
		to_chat(user, "<span class='warning'>You cannot saw-off \the [src] with \the [bayonet] attached!</span>")
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
		recoil = SAWN_OFF_RECOIL
		sawn_off = TRUE
		update_icon()
		return TRUE

// Sawing guns related proc
/obj/item/gun/ballistic/proc/blow_up(mob/user)
	. = FALSE
	for(var/obj/item/ammo_casing/AC in magazine.stored_ammo)
		if(AC.BB)
			process_fire(user, user, FALSE)
			. = TRUE


/obj/item/suppressor
	name = "suppressor"
	desc = "A syndicate small-arms suppressor for maximum espionage."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "suppressor"
	w_class = WEIGHT_CLASS_TINY


/obj/item/suppressor/specialoffer
	name = "cheap suppressor"
	desc = "A foreign knock-off suppressor, it feels flimsy, cheap, and brittle. Still fits most weapons."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "suppressor"
