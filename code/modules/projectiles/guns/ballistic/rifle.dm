/obj/item/gun/ballistic/rifle
	name = "Bolt Rifle"
	desc = "Some kind of bolt action rifle. You get the feeling you shouldn't have this."
	icon = 'icons/obj/weapons/guns/wide_guns.dmi'
	icon_state = "sakhno"
	w_class = WEIGHT_CLASS_BULKY
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction
	bolt_wording = "bolt"
	bolt_type = BOLT_TYPE_LOCKING
	semi_auto = FALSE
	internal_magazine = TRUE
	fire_sound = 'sound/weapons/gun/rifle/shot_heavy.ogg'
	fire_sound_volume = 90
	rack_sound = 'sound/weapons/gun/rifle/bolt_out.ogg'
	bolt_drop_sound = 'sound/weapons/gun/rifle/bolt_in.ogg'
	tac_reloads = FALSE

/obj/item/gun/ballistic/rifle/rack(mob/user = null)
	if (bolt_locked == FALSE)
		balloon_alert(user, "bolt opened")
		playsound(src, rack_sound, rack_sound_volume, rack_sound_vary)
		process_chamber(FALSE, FALSE, FALSE)
		bolt_locked = TRUE
		update_appearance()
		return
	drop_bolt(user)

/obj/item/gun/ballistic/rifle/can_shoot()
	if (bolt_locked)
		return FALSE
	return ..()

/obj/item/gun/ballistic/rifle/examine(mob/user)
	. = ..()
	. += "The bolt is [bolt_locked ? "open" : "closed"]."

///////////////////////
// BOLT ACTION RIFLE //
///////////////////////

/obj/item/gun/ballistic/rifle/boltaction
	name = "\improper Sakhno Precision Rifle"
	desc = "A Sakhno Precision Rifle, a bolt action weapon that was (and certainly still is) popular with \
		frontiersmen, cargo runners, private security forces, explorers, and other unsavoury types. This particular \
		pattern of the rifle dates back all the way to 2440."
	sawn_desc = "A sawn-off Sakhno Precision Rifle, popularly known as an \"Obrez\". \
		There was probably a reason it wasn't manufactured this short to begin with. \
		Despite the terrible nature of the modification, the weapon seems otherwise in good condition."

	icon_state = "sakhno"
	inhand_icon_state = "sakhno"
	worn_icon_state = "sakhno"

	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction
	can_bayonet = TRUE
	knife_x_offset = 42
	knife_y_offset = 12
	can_be_sawn_off = TRUE
	weapon_weight = WEAPON_HEAVY
	var/jamming_chance = 20
	var/unjam_chance = 10
	var/jamming_increment = 5
	var/jammed = FALSE
	var/can_jam = FALSE

	SET_BASE_PIXEL(-8, 0)

/obj/item/gun/ballistic/rifle/boltaction/sawoff(mob/user)
	. = ..()
	if(.)
		spread = 36
		can_bayonet = FALSE
		SET_BASE_PIXEL(0, 0)
		update_appearance()

/obj/item/gun/ballistic/rifle/boltaction/attack_self(mob/user)
	if(can_jam)
		if(jammed)
			if(prob(unjam_chance))
				jammed = FALSE
				unjam_chance = 10
			else
				unjam_chance += 10
				balloon_alert(user, "jammed!")
				playsound(user,'sound/weapons/jammed.ogg', 75, TRUE)
				return FALSE
	..()

/obj/item/gun/ballistic/rifle/boltaction/process_fire(mob/user)
	if(can_jam)
		if(chambered.loaded_projectile)
			if(prob(jamming_chance))
				jammed = TRUE
			jamming_chance += jamming_increment
			jamming_chance = clamp (jamming_chance, 0, 100)
	return ..()

/obj/item/gun/ballistic/rifle/boltaction/attackby(obj/item/item, mob/user, params)
	if(!bolt_locked && !istype(item, /obj/item/knife))
		balloon_alert(user, "bolt closed!")
		return

	. = ..()

	if(istype(item, /obj/item/gun_maintenance_supplies))
		if(!can_jam)
			balloon_alert(user, "can't jam!")
			return
		if(do_after(user, 10 SECONDS, target = src))
			user.visible_message(span_notice("[user] finishes maintaining [src]."))
			jamming_chance = initial(jamming_chance)
			qdel(item)

/obj/item/gun/ballistic/rifle/boltaction/blow_up(mob/user)
	. = FALSE
	if(chambered?.loaded_projectile)
		process_fire(user, user, FALSE)
		. = TRUE

/obj/item/gun/ballistic/rifle/boltaction/harpoon
	name = "ballistic harpoon gun"
	desc = "A weapon favored by carp hunters, but just as infamously employed by agents of the Animal Rights Consortium against human aggressors. Because it's ironic."
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "speargun"
	inhand_icon_state = "speargun"
	worn_icon_state = "speargun"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/harpoon
	fire_sound = 'sound/weapons/gun/sniper/shot.ogg'
	can_be_sawn_off = FALSE

	SET_BASE_PIXEL(0, 0)

/obj/item/gun/ballistic/rifle/boltaction/surplus
	name = "\improper Sakhno M2442 Army"
	desc = "A modification of the Sakhno Precision Rifle, \"Sakhno M2442 Army\" is stamped into the side. \
		It is unknown what army this pattern of rifle was made for or if it was ever even used by an army \
		of any sort. What you can discern, however, is that its previous owner did not treat the weapon well. \
		For some reason, there's moisture all through the internals."
	sawn_desc = "A sawn-off Sakhno Precision Rifle, popularly known as an \"Obrez\". \
		\"Sakhno M2442 Army\" is stamped into the side of it. \
		There was probably a reason it wasn't manufactured this short to begin with. \
		Cutting the weapon down seems to have not helped with the moisture problem."
	icon_state = "sakhno_tactifucked"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/surplus
	can_jam = TRUE

/obj/item/gun/ballistic/rifle/boltaction/prime
	name = "\improper Sakhno-Zhihao Sporting Rifle"
	desc = "An upgrade and modernisation of the original Sakhno rifle, made with such wonders as \
		modern materials, a scope, and other impressive technological advancements that, to be honest, \
		were already around when the original weapon was designed. Surprisingly for a rifle of this type, \
		the scope actually has magnification, rather than being decorative."
	icon_state = "zhihao"
	inhand_icon_state = "zhihao"
	worn_icon_state = "zhihao"
	can_be_sawn_off = TRUE
	sawn_desc = "A sawn-off Sakhno-Zhihao Sporting Rifle... Doing this was a sin, I hope you're happy. \
		You are now probably one of the few people in the universe to ever hold an \"Obrez Moderna\". \
		All you had to do was take an allen wrench to the stock to take it off. But no, you just had to \
		go for the saw."

/obj/item/gun/ballistic/rifle/boltaction/prime/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 1.5)

/obj/item/gun/ballistic/rifle/boltaction/prime/sawoff(mob/user)
	. = ..()
	if(.)
		name = "\improper Obrez Moderna" // wear it loud and proud

/obj/item/gun/ballistic/rifle/boltaction/pipegun
	name = "pipegun"
	desc = "An excellent weapon for flushing out tunnel rats and enemy assistants, but its rifling leaves much to be desired."
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "musket"
	inhand_icon_state = "musket"
	worn_icon_state = "musket"
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	fire_sound = 'sound/weapons/gun/sniper/shot.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/pipegun
	initial_caliber = CALIBER_SHOTGUN
	alternative_caliber = CALIBER_STRILKA310
	initial_fire_sound = 'sound/weapons/gun/sniper/shot.ogg'
	alternative_fire_sound = 'sound/weapons/gun/shotgun/shot.ogg'
	can_modify_ammo = TRUE
	can_bayonet = TRUE
	knife_y_offset = 11
	can_be_sawn_off = FALSE
	projectile_damage_multiplier = 0.75

	SET_BASE_PIXEL(0, 0)

/obj/item/gun/ballistic/rifle/boltaction/pipegun/handle_chamber()
	. = ..()
	do_sparks(1, TRUE, src)

/obj/item/gun/ballistic/rifle/boltaction/pipegun/prime
	name = "regal pipegun"
	desc = "Older, territorial assistants typically possess more valuable loot."
	icon_state = "musket_prime"
	inhand_icon_state = "musket_prime"
	worn_icon_state = "musket_prime"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/pipegun/prime
	projectile_damage_multiplier = 1

/// MAGICAL BOLT ACTIONS + ARCANE BARRAGE? ///

/obj/item/gun/ballistic/rifle/enchanted
	name = "enchanted bolt action rifle"
	desc = "Careful not to lose your head."
	icon_state = "enchanted_rifle"
	inhand_icon_state = "enchanted_rifle"
	worn_icon_state = "enchanted_rifle"
	slot_flags = ITEM_SLOT_BACK
	var/guns_left = 30
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/enchanted
	can_be_sawn_off = FALSE

	SET_BASE_PIXEL(-8, 0)

/obj/item/gun/ballistic/rifle/enchanted/dropped()
	. = ..()
	guns_left = 0
	magazine = null
	chambered = null

/obj/item/gun/ballistic/rifle/enchanted/proc/discard_gun(mob/living/user)
	user.throw_item(pick(oview(7,get_turf(user))))

/obj/item/gun/ballistic/rifle/enchanted/attack_self()
	return

/obj/item/gun/ballistic/rifle/enchanted/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	. = ..()
	if(!.)
		return
	if(guns_left)
		var/obj/item/gun/ballistic/rifle/enchanted/gun = new type
		gun.guns_left = guns_left - 1
		discard_gun(user)
		user.swap_hand()
		user.put_in_hands(gun)
	else
		user.dropItemToGround(src, TRUE)

// SNIPER //

/obj/item/gun/ballistic/rifle/sniper_rifle
	name = "anti-materiel sniper rifle"
	desc = "A boltaction anti-materiel rifle, utilizing .50 BMG cartridges. While technically outdated in modern arms markets, it still works exceptionally well as \
		an anti-personnel rifle. In particular, the employment of modern armored MODsuits utilizing advanced armor plating has given this weapon a new home on the battlefield. \
		It is also able to be suppressed....somehow."
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "sniper"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	weapon_weight = WEAPON_HEAVY
	inhand_icon_state = "sniper"
	worn_icon_state = null
	fire_sound = 'sound/weapons/gun/sniper/shot.ogg'
	fire_sound_volume = 90
	load_sound = 'sound/weapons/gun/sniper/mag_insert.ogg'
	rack_sound = 'sound/weapons/gun/sniper/rack.ogg'
	suppressed_sound = 'sound/weapons/gun/general/heavy_shot_suppressed.ogg'
	recoil = 2
	accepted_magazine_type = /obj/item/ammo_box/magazine/sniper_rounds
	internal_magazine = FALSE
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BACK
	mag_display = TRUE
	tac_reloads = TRUE
	rack_delay = 1 SECONDS
	can_suppress = TRUE
	can_unsuppress = TRUE
	suppressor_x_offset = 3
	suppressor_y_offset = 3

/obj/item/gun/ballistic/rifle/sniper_rifle/examine(mob/user)
	. = ..()
	. += span_warning("<b>It seems to have a warning label:</b> Do NOT, under any circumstances, attempt to 'quickscope' with this rifle.")

/obj/item/gun/ballistic/rifle/sniper_rifle/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 4) //enough range to at least make extremely good use of the penetrator rounds

/obj/item/gun/ballistic/rifle/sniper_rifle/reset_semicd()
	. = ..()
	if(suppressed)
		playsound(src, 'sound/machines/eject.ogg', 25, TRUE, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
	else
		playsound(src, 'sound/machines/eject.ogg', 50, TRUE)

/obj/item/gun/ballistic/rifle/sniper_rifle/syndicate
	desc = "A boltaction anti-materiel rifle, utilizing .50 BMG cartridges. While technically outdated in modern arms markets, it still works exceptionally well as \
		an anti-personnel rifle. In particular, the employment of modern armored MODsuits utilizing advanced armor plating has given this weapon a new home on the battlefield. \
		It is also able to be suppressed....somehow. This one seems to have a little picture of someone in a blood-red MODsuit stenciled on it, pointing at a green floppy disk. \
		Who knows what that might mean."
	pin = /obj/item/firing_pin/implant/pindicate
