/obj/item/gun/ballistic/automatic/smart_machine_gun
	name = "\improper M63A4 \"Smartgun\""
	desc = "A weapon with a blistering rate of fire, so heavy that it needs to be mounted on a modsuit to wield. \
	It's equipped with IFF technology, allowing the bullets to intentionally miss friendly targets."
	icon = 'modular_skyrat/modules/marines/icons/items/guns.dmi'
	lefthand_file = 'modular_skyrat/modules/marines/icons/mobs/guns_l.dmi'
	righthand_file = 'modular_skyrat/modules/marines/icons/mobs/guns_r.dmi'
	worn_icon = 'modular_skyrat/modules/marines/icons/mobs/mod_modules.dmi'
	icon_state = "smartgun"
	worn_icon_state = "module_smartgun_off" // just in case. You shouldn't be able to do this, though
	inhand_icon_state = "smartgun"
	fire_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/fire/mg34_fire.ogg'
	rack_sound = 'sound/weapons/gun/l6/l6_rack.ogg'
	suppressed_sound = 'sound/weapons/gun/general/heavy_shot_suppressed.ogg'
	fire_sound_volume = 70
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	spread = 18
	mag_type = /obj/item/ammo_box/magazine/smartgun_drum
	can_suppress = FALSE
	fire_delay = 0.15
	bolt_type = BOLT_TYPE_OPEN
	show_bolt_icon = FALSE
	tac_reloads = FALSE
	burst_size = 1
	actions_types = list()
	pin = /obj/item/firing_pin/implant/mindshield
	mag_display_ammo = FALSE
	mag_display = FALSE
	fire_sound_volume = 30
	/// If the gun's dustcover is open or not
	var/cover_open = FALSE
	/// Factions that the gun cannot shoot under any circumstances
	var/list/iff_factions = list("ert")

/obj/item/gun/ballistic/automatic/smart_machine_gun/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/automatic_fire, fire_delay)

	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/gun/ballistic/automatic/smart_machine_gun/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/ballistic/automatic/smart_machine_gun/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	. = ..()
	if(chambered)
		SEND_SIGNAL(chambered, COMSIG_CHAMBERED_BULLET_FIRE, iff_factions)

/obj/item/gun/ballistic/automatic/smart_machine_gun/examine(mob/user)
	. = ..()
	. += "<b>RMB with an empty hand</b> to [cover_open ? "close" : "open"] the dust cover."
	if(cover_open && magazine)
		. += span_notice("It seems like you could use an <b>empty hand</b> to remove the magazine.")

/obj/item/gun/ballistic/automatic/smart_machine_gun/attack_hand_secondary(mob/user, list/modifiers)
	if(!user.can_perform_action(src))
		return
	cover_open = !cover_open
	to_chat(user, span_notice("You [cover_open ? "open" : "close"] [src]'s cover."))
	playsound(src, 'sound/weapons/gun/l6/l6_door.ogg', 60, TRUE)
	update_appearance()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/gun/ballistic/automatic/smart_machine_gun/can_shoot()
	if(cover_open)
		balloon_alert_to_viewers("cover open!")
		return FALSE
	return chambered

/obj/item/gun/ballistic/automatic/smart_machine_gun/eject_magazine(mob/user, display_message = TRUE, obj/item/ammo_box/magazine/tac_load = null)
	if(!cover_open)
		to_chat(user, span_warning("The cover is closed! Open it before ejecting the magazine!"))
		return
	return ..()

/obj/item/gun/ballistic/automatic/smart_machine_gun/attackby(obj/item/attack_item, mob/user, params)
	if(!cover_open && istype(attack_item, mag_type))
		to_chat(user, span_warning("[src]'s dust cover prevents a magazine from being fit."))
		return
	..()

/obj/item/gun/ballistic/automatic/smart_machine_gun/update_overlays()
	. = ..()
	. += "[base_icon_state]_door_open"

/obj/item/gun/ballistic/automatic/smart_machine_gun/unrestricted
	pin = /obj/item/firing_pin
// Magazine itself

/obj/item/ammo_box/magazine/smartgun_drum
	name = "smartgun drum (10x28mm caseless)"
	icon = 'modular_skyrat/modules/marines/icons/items/ammo.dmi'
	icon_state = "smartgun_drum"
	ammo_type = /obj/item/ammo_casing/smart/a10x28
	caliber = "a10x28"
	max_ammo = 500
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_NORMAL

// Smart ammo casings

/obj/item/ammo_casing/smart
	icon = 'modular_skyrat/modules/gunsgalore/icons/ammo/ammo.dmi'

/obj/item/ammo_casing/smart/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_CHAMBERED_BULLET_FIRE, PROC_REF(iff_transfer))

/obj/item/ammo_casing/smart/proc/iff_transfer(datum/source, list/iff_factions)
	SIGNAL_HANDLER

	if(istype(loaded_projectile, /obj/projectile/bullet/smart))
		var/obj/projectile/bullet/smart/smart_proj = loaded_projectile
		smart_proj.ignored_factions = iff_factions.Copy()

/obj/item/ammo_casing/smart
	firing_effect_type = null
	is_cased_ammo = FALSE

/obj/item/ammo_casing/smart/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/caseless)

/obj/item/ammo_casing/smart/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, atom/fired_from)
	if (!..()) //failed firing
		return FALSE
	if(istype(fired_from, /obj/item/gun))
		var/obj/item/gun/shot_from = fired_from
		if(shot_from.chambered == src)
			shot_from.chambered = null //Nuke it. Nuke it now.
	qdel(src)
	return TRUE

/obj/item/ammo_casing/smart/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)]"

/obj/item/ammo_casing/smart/a10x28
	name = "10x28mm bullet"
	desc = "A 10x28m caseless bullet."
	icon_state = "792x57-casing"
	caliber = "a10x28"
	projectile_type = /obj/projectile/bullet/smart/a10x28

// Smart bullets

/obj/projectile/bullet/smart
	ignore_direct_target = TRUE

/obj/projectile/bullet/smart/a10x28 // utter peashooter, but it has 6000rpm
	name = "10x28mm bullet"
	damage = 6
	wound_bonus = -5
	wound_falloff_tile = 1
