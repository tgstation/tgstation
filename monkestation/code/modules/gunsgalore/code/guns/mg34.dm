/obj/item/gun/ballistic/automatic/mg34
	name = "\improper MG-4T"
	desc = "A reproduction of the German MG-34 general purpose machine gun, this one is a revision from the 2200's and was one of several thousand distributed to SolFed expedition teams. It has been rechambered to fire 7.92mm Mauser instead of 7.62mm NATO."
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_guns40x32.dmi'
	lefthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_righthand.dmi'
	worn_icon = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_back.dmi'
	icon_state = "mg34"
	base_icon_state = "mg34"
	worn_icon_state = "mg34"
	inhand_icon_state = "mg34"
	fire_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/fire/mg34_fire.ogg'
	rack_sound = 'sound/weapons/gun/l6/l6_rack.ogg'
	suppressed_sound = 'sound/weapons/gun/general/heavy_shot_suppressed.ogg'
	fire_sound_volume = 70
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	spread = 15
	mag_type = /obj/item/ammo_box/magazine/mg34
	can_suppress = FALSE
	fire_delay = 1
	bolt_type = BOLT_TYPE_OPEN
	show_bolt_icon = FALSE
	tac_reloads = FALSE
	var/cover_open = FALSE

/obj/item/gun/ballistic/automatic/mg34/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/automatic_fire, fire_delay)

	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/gun/ballistic/automatic/mg34/examine(mob/user)
	. = ..()
	. += "<b>RMB with an empty hand</b> to [cover_open ? "close" : "open"] the dust cover."
	if(cover_open && magazine)
		. += span_notice("It seems like you could use an <b>empty hand</b> to remove the magazine.")

/obj/item/gun/ballistic/automatic/mg34/attack_hand_secondary(mob/user, list/modifiers)
	if(!user.can_perform_action(src))
		return
	cover_open = !cover_open
	to_chat(user, span_notice("You [cover_open ? "open" : "close"] [src]'s cover."))
	playsound(src, 'sound/weapons/gun/l6/l6_door.ogg', 60, TRUE)
	update_appearance()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/gun/ballistic/automatic/mg34/update_overlays()
	. = ..()
	. += "[base_icon_state]_door_[cover_open ? "open" : "closed"]"

/obj/item/gun/ballistic/automatic/mg34/can_shoot()
	if(cover_open)
		balloon_alert_to_viewers("cover open!")
		return FALSE
	return chambered

/obj/item/gun/ballistic/automatic/mg34/eject_magazine(mob/user, display_message = TRUE, obj/item/ammo_box/magazine/tac_load = null)
	if(!cover_open)
		to_chat(user, span_warning("The cover is closed! Open it before ejecting the magazine!"))
		return
	return ..()

/obj/item/gun/ballistic/automatic/mg34/attackby(obj/item/A, mob/user, params)
	if(!cover_open && istype(A, mag_type))
		to_chat(user, span_warning("[src]'s dust cover prevents a magazine from being fit."))
		return
	..()

/obj/item/ammo_box/magazine/mg34
	name = "mg34 drum (7.92x57mm)"
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_items.dmi'
	icon_state = "mg34_drum"
	ammo_type = /obj/item/ammo_casing/realistic/a792x57
	caliber = "a792x57"
	max_ammo = 75
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/gun/ballistic/automatic/mg34/packapunch //INFINITY GUNNNNNNNN
	name = "\improper MG-34 UBER"
	desc = "Here, there, seems like everywhere. Nasty things are happening, now everyone is scared. Old Jeb Brown the Blacksmith, he saw his mother die. A critter took a bite from her and now she's in the sky. "
	fire_delay = 0.04
	burst_size = 5
	spread = 5
	mag_type = /obj/item/ammo_box/magazine/mg34/packapunch

/obj/item/ammo_box/magazine/mg34/packapunch
	max_ammo = 999
	multiple_sprites = AMMO_BOX_ONE_SPRITE

/obj/item/gun/ballistic/automatic/mg34/packapunch/process_chamber(empty_chamber, from_firing, chamber_next_round)
	. = ..()
	magazine.top_off()

/// BIGGER BROTHER
#define SPREAD_UNDEPLOYED 17
#define SPREAD_DEPLOYED 6
#define HEAT_PER_SHOT 1.5
#define TIME_TO_COOLDOWN (20 SECONDS)
#define BARREL_COOLDOWN_RATE 2

/obj/item/gun/ballistic/automatic/mg34/mg42
	name = "\improper MG-9V GPMG"
	desc = "An updated version of the German Maschinengewehr 42 machine gun chambered in 7.92 Mauser, it has a bipod for better stability when deployed. It is a reproduction manufactured by the Oldarms division of the Armadyne Corporation."
	icon_state = "mg42"
	base_icon_state = "mg42"
	worn_icon_state = "mg42"
	inhand_icon_state = "mg42"
	fire_sound_volume = 100
	fire_delay = 0.5
	fire_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/fire/mg42_fire.ogg'
	mag_type = /obj/item/ammo_box/magazine/mg42
	spread = SPREAD_UNDEPLOYED
	/// If we are resting, the bipod is deployed.
	var/bipod_deployed = FALSE
	/// How hot the barrel is, 0 - 100
	var/barrel_heat = 0
	/// Have we overheated?
	var/overheated = FALSE

/obj/item/gun/ballistic/automatic/mg34/mg42/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_GUN_FIRED, PROC_REF(process_heat))
	START_PROCESSING(SSobj, src)

/obj/item/gun/ballistic/automatic/mg34/mg42/process(seconds_per_tick)
	if(barrel_heat > 0)
		barrel_heat -= BARREL_COOLDOWN_RATE * seconds_per_tick
		update_appearance()

/obj/item/gun/ballistic/automatic/mg34/mg42/examine(mob/user)
	. = ..()
	switch(barrel_heat)
		if(50 to 75)
			. += span_warning("The barrel looks hot.")
		if(75 to INFINITY)
			. += span_warning("The barrel looks moulten!")
	if(overheated)
		. += span_danger("It is heatlocked!")

/obj/item/gun/ballistic/automatic/mg34/mg42/can_shoot()
	if(cover_open)
		balloon_alert_to_viewers("cover open!")
		return FALSE
	if(overheated)
		balloon_alert_to_viewers("overheated!")
		shoot_with_empty_chamber()
		return FALSE
	return chambered

/obj/item/gun/ballistic/automatic/mg34/mg42/pickup(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_LIVING_UPDATED_RESTING, PROC_REF(deploy_bipod))

/obj/item/gun/ballistic/automatic/mg34/mg42/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_LIVING_UPDATED_RESTING)
	bipod_deployed = FALSE
	spread = SPREAD_UNDEPLOYED
	update_appearance()

/obj/item/gun/ballistic/automatic/mg34/mg42/proc/deploy_bipod(datum/datum_source, resting)
	SIGNAL_HANDLER
	if(resting)
		bipod_deployed = TRUE
		spread = SPREAD_DEPLOYED
	else
		bipod_deployed = FALSE
		spread = SPREAD_UNDEPLOYED
	playsound(src, 'modular_skyrat/modules/gunsgalore/sound/guns/fire/mg42_bipod.ogg', 100)
	balloon_alert_to_viewers("bipod [bipod_deployed ? "deployed" : "undeployed"]!")
	update_appearance()

/obj/item/gun/ballistic/automatic/mg34/mg42/proc/process_heat()
	SIGNAL_HANDLER
	if(overheated)
		return
	barrel_heat += HEAT_PER_SHOT
	if(barrel_heat >= 100)
		overheated = TRUE
		playsound(src, 'modular_skyrat/modules/gunsgalore/sound/guns/fire/mg_overheat.ogg', 100)
		addtimer(CALLBACK(src, PROC_REF(reset_overheat)), TIME_TO_COOLDOWN)
	update_appearance()

/obj/item/gun/ballistic/automatic/mg34/mg42/proc/reset_overheat()
	overheated = FALSE
	update_appearance()

/obj/item/gun/ballistic/automatic/mg34/mg42/update_overlays()
	. = ..()
	. += "[base_icon_state]_[bipod_deployed ? "bipod_deployed" : "bipod"]"

	switch(barrel_heat)
		if(50 to 75)
			. += "[base_icon_state]_barrel_hot"
		if(75 to INFINITY)
			. += "[base_icon_state]_barrel_overheat"

#undef SPREAD_UNDEPLOYED
#undef SPREAD_DEPLOYED
#undef HEAT_PER_SHOT
#undef TIME_TO_COOLDOWN
#undef BARREL_COOLDOWN_RATE

/obj/item/ammo_box/magazine/mg42
	name = "mg42 drum (7.92x57mm)"
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/gunsgalore_items.dmi'
	icon_state = "mg42_drum"
	ammo_type = /obj/item/ammo_casing/realistic/a792x57
	caliber = "a792x57"
	max_ammo = 150 // It's a lot, but the gun overheats.
	multiple_sprites = AMMO_BOX_FULL_EMPTY
