/obj/item/gun/ballistic
	/// Does this gun have mag and nomag on mob variance?
	var/alt_icons = FALSE
	/// What the icon state is for the on-back guns
	var/alt_icon_state
	/// Realistic guns that use reliability and dirt
	var/realistic = FALSE
	/// Is it jammed?
	var/jammed = FALSE
	/// How dirty a gun is.
	var/dirt_level = 0
	/// Tied in with how good a gun is, if firing it causes a lot of dirt to form, then change this accordingly.
	var/dirt_modifier = 0.1
	/// Used when calculating if a gun will jam or not.
	var/jam_chance = 0
	/// Used when calculating how long a gun takes to unjam.
	var/unjam_time = 0
	/// Tracking gun base spred.
	var/base_spread = 0
	/// How used this gun is.
	var/durability = 100
	/// How quickly a gun will degrade. 0.1 = 1000 shots. Edit this to change a guns base reliability.
	var/durability_factor = 0.1
	/// How long it takes to reload a magazine.
	var/reload_time = 2 SECONDS


/obj/item/gun/ballistic/Initialize()
	. = ..()
	if(realistic)
		base_spread = spread

/obj/item/gun/ballistic/ComponentInitialize()
	. = ..()
	if(alt_icons)
		AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/gun/ballistic/update_overlays()
	. = ..()
	if(alt_icons)
		if(!magazine)
			if(alt_icon_state)
				inhand_icon_state = "[alt_icon_state]_nomag"
				worn_icon_state = "[alt_icon_state]_nomag"
			else
				inhand_icon_state = "[initial(icon_state)]_nomag"
				worn_icon_state = "[initial(icon_state)]_nomag"
		else
			if(alt_icon_state)
				inhand_icon_state = "[alt_icon_state]"
				worn_icon_state = "[alt_icon_state]"
			else
				inhand_icon_state = "[initial(icon_state)]"
				worn_icon_state = "[initial(icon_state)]"

/obj/item/gun/ballistic/insert_magazine(mob/user, obj/item/ammo_box/magazine/AM, display_message)
	if(reload_time && !HAS_TRAIT(user, TRAIT_INSTANT_RELOAD) && magazine) //This only happens when you're attempting a tactical reload, e.g. there's a mag already inserted.
		to_chat(user, span_notice("You start to insert the magazine into [src]!"))
		if(!do_after(user, reload_time, src))
			to_chat(user, span_danger("You fail to insert the magazine into [src]!"))
			return
	. = ..()

/obj/item/gun/ballistic/assault_rifle
	rack_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/ltrifle_cock.ogg'
	load_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/ltrifle_magin.ogg'
	load_empty_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/ltrifle_magin.ogg'
	eject_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/ltrifle_magout.ogg'
	eject_empty_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/ltrifle_magout.ogg'

/obj/item/gun/ballistic/battle_rifle
	rack_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/batrifle_cock.ogg'
	load_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/batrifle_magin.ogg'
	load_empty_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/batrifle_magin.ogg'
	eject_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/batrifle_magout.ogg'
	eject_empty_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/batrifle_magout.ogg'

/obj/item/gun/ballistic/machine_gun
	rack_sound = 'sound/weapons/gun/l6/l6_rack.ogg'
	load_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/lmg_magin.ogg'
	load_empty_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/lmg_magin.ogg'
	eject_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/lmg_magout.ogg'
	eject_empty_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/lmg_magout.ogg'

/obj/item/gun/ballistic/sniper_rifle
	rack_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/sfrifle_cock.ogg'
	load_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/sfrifle_magin.ogg'
	load_empty_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/sfrifle_magin.ogg'
	eject_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/sfrifle_magout.ogg'
	eject_empty_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/sfrifle_magout.ogg'

/obj/item/gun/ballistic/submachine_gun
	rack_sound = 'sound/weapons/gun/smg/smgrack.ogg'
	load_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/smg_magin.ogg'
	load_empty_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/smg_magin.ogg'
	eject_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/smg_magout.ogg'
	eject_empty_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/interact/smg_magout.ogg'

/obj/item/gun/ballistic/proc/jam(unjam = FALSE, mob/living/user)
	if(unjam && jammed != TRUE)
		unjam_time = clamp((jam_chance*10)/(durability/10), 0, 50)
		jammed = TRUE
		playsound(src, 'sound/effects/stall.ogg', 60, TRUE)
		to_chat(user, span_danger("The [src] jams!"))
		SEND_SIGNAL(src, COMSIG_GUN_JAMMED)
	else if(jammed)
		to_chat(user, "You start to unjam the bolt!")
		if(do_after(user, unjam_time))
			jammed = FALSE
			to_chat(user, span_notice("You unjam the [src]'s bolt."))
			playsound(src, 'sound/weapons/gun/l6/l6_rack.ogg', 60, TRUE)

/obj/item/gun/ballistic/can_trigger_gun(mob/living/user)
	. = ..()
	if(realistic && jammed)
		to_chat(user, span_warning("[src] is jammed!"))
		return FALSE

/obj/item/gun/ballistic/shoot_live_shot(mob/living/user, pointblank, atom/pbtarget, message)
	if(realistic)
		if(jammed)
			return FALSE

		dirt_level += dirt_modifier

		durability = clamp(durability -= durability_factor, 1, 1000)

		jam_chance = dirt_level/5

		spread = base_spread + ((jam_chance / durability)*100)

		switch(FLOOR(durability, 1))
			if(0 to 9)
				if(prob(90))
					jam(user)
					return FALSE
			if(10 to 29)
				if(prob(10))
					jam(user)
					return FALSE
			if(30 to 49)
				if(prob(5))
					jam(user)
					return FALSE

		if(dirt_level > 30 && prob(jam_chance))
			jam(user)
			return FALSE
	. = ..()

/obj/item/gun/ballistic/AltClick(mob/user)
	if(realistic)
		if(!user.canUseTopic(src))
			return
		if(jammed)
			jam(TRUE, user)
			return
	if(!internal_magazine && magazine && user.Adjacent(src))
		eject_magazine(user)
	. = ..()

/obj/item/gun/ballistic/examine(mob/user)
	. = ..()
	if(realistic)
		switch(FLOOR(dirt_level, 1))
			if(0 to 10)
				. += "It looks clean."
			if(11 to 30)
				. += "It looks slightly dirty."
			if(31 to 50)
				. += "It looks dirty."
			if(51 to 70)
				. += "It looks very dirty."
			else
				. += span_warning("It is filthy!")

		switch(FLOOR(durability, 1))
			if(0 to 9)
				. += span_warning("<b>It is falling apart!</b>")
			if(10 to 29)
				. += span_warning("It looks battle scarred!")
			if(30 to 49)
				. += "It looks well worn."
			if(50 to 69)
				. += "It has minimal wear."
			else
				. += "It looks factory new."

		if(jammed)
			. += span_warning("<b>It is jammed, alt+click it to unjam it!</b>")
		else if(durability < 10)
			. += span_warning("<b>It is barely functioning!</b>")
		else
			. += "It is functioning normally."

/obj/item/gun/ballistic/attackby(obj/item/A, mob/user, params)
	. = ..()
	if(realistic)
		if(istype(A, /obj/item/stack/sheet/cloth))
			var/obj/item/stack/sheet/cloth/C = A
			if(!dirt_level)
				to_chat(user, "The [src] is already spotless!")
			else
				if(C.amount < 5)
					to_chat(user, "There's not enough [C] to clean the gun with!")
				else
					to_chat(user, span_notice("You start cleaning the [src]."))
					if(do_after(user, 20 SECONDS))
						dirt_level -= 35
						if(dirt_level < 0)
							dirt_level = 0
						C.use(5)
						to_chat(user, span_notice("You clean the [src], improving it's reliability!"))
		if(istype(A, /obj/item/gun_maintenance_supplies))
			to_chat(user, span_notice("You start maintaining the [src]."))
			if(do_after(user, 10 SECONDS, target = src))
				user.visible_message(span_notice("[user] finishes maintenance of [src]."))
				dirt_level = 0
				qdel(A)

//CRATES

//all that shit
/obj/structure/closet/crate/secure/weapon/ww2
	name = "ww2 weapons crate"
	desc = "A secure weapons crate. Looks like it's from the old-era world war 2."
	icon_state = "weaponcrate"

/obj/structure/closet/crate/secure/weapon/ww2/PopulateContents()
	. = ..()
	new /obj/item/gun/ballistic/automatic/battle_rifle/fg42(src)
	new /obj/item/ammo_box/magazine/fg42(src)
	new /obj/item/gun/ballistic/automatic/assault_rifle/akm(src)
	new /obj/item/ammo_box/magazine/akm(src)
	new /obj/item/gun/ballistic/automatic/assault_rifle/m16(src)
	new /obj/item/ammo_box/magazine/m16(src)
	new /obj/item/gun/ballistic/automatic/mg34(src)
	new /obj/item/ammo_box/magazine/mg34(src)
	new /obj/item/gun/ballistic/automatic/submachine_gun/mp40(src)
	new /obj/item/ammo_box/magazine/mp40(src)
	new /obj/item/gun/ballistic/automatic/assault_rifle/stg(src)
	new /obj/item/ammo_box/magazine/stg(src)
	new /obj/item/gun/ballistic/automatic/submachine_gun/ppsh(src)
	new /obj/item/ammo_box/magazine/ppsh(src)
	new /obj/item/gun/ballistic/automatic/submachine_gun/pps(src)
	new /obj/item/ammo_box/magazine/pps(src)

/obj/structure/closet/crate/secure/weapon/ww2
	name = "modern weapons crate"
	desc = "A secure weapons crate. Looks like it's from the 25th century."
	icon_state = "weaponcrate"

/obj/structure/closet/crate/secure/weapon/ww2/PopulateContents()
	. = ..()
	new /obj/item/gun/ballistic/automatic/battle_rifle/fg42/modern(src)
	new /obj/item/ammo_box/magazine/fg42(src)
	new /obj/item/gun/ballistic/automatic/assault_rifle/akm/modern(src)
	new /obj/item/ammo_box/magazine/akm(src)
	new /obj/item/gun/ballistic/automatic/assault_rifle/m16/modern(src)
	new /obj/item/ammo_box/magazine/m16(src)
	new /obj/item/gun/ballistic/automatic/submachine_gun/mp40/modern(src)
	new /obj/item/ammo_box/magazine/mp40(src)
	new /obj/item/gun/ballistic/automatic/assault_rifle/stg/modern(src)
	new /obj/item/ammo_box/magazine/stg(src)
	new /obj/item/gun/ballistic/automatic/submachine_gun/ppsh/modern(src)
	new /obj/item/ammo_box/magazine/ppsh(src)

/obj/effect/temp_visual/dir_setting/firing_effect
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_FIRE
