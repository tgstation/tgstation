/obj/item/gun/energy/event_horizon
	name = "\improper Event Horizon anti-existential beam rifle"
	desc = "The deranged minds of Nanotrasen, in their great hubris and spite, have birthed forth the definitive conclusion to the arms race. Weaponized black holes, and a platform to deliver them.\
		To look upon this existential maleficence is to know that the pursuit of profit has consigned all life to this pathetic conclusion; the destruction of reality itself."
	icon = 'icons/obj/weapons/guns/energy.dmi'
	icon_state = "esniper"
	inhand_icon_state = null
	worn_icon_state = null
	fire_sound = 'sound/items/weapons/beam_sniper.ogg'
	slot_flags = ITEM_SLOT_BACK
	force = 20 //This is maybe the sanest part of this weapon.
	custom_materials = null
	recoil = 2
	ammo_x_offset = 3
	ammo_y_offset = 3
	modifystate = FALSE
	charge_sections = 1
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(/obj/item/ammo_casing/energy/event_horizon)
	selfcharge = TRUE
	self_charge_amount = STANDARD_ENERGY_GUN_SELF_CHARGE_RATE * 10

/obj/item/gun/energy/event_horizon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 4)

/obj/item/gun/energy/event_horizon/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)

	if(!HAS_TRAIT(user, TRAIT_USER_SCOPED))
		balloon_alert(user, "must be scoped!")
		return

	. = ..()
	message_admins("[ADMIN_LOOKUPFLW(user)] has fired an anti-existential beam at [ADMIN_VERBOSEJMP(user)].")

/obj/item/ammo_casing/energy/event_horizon
	projectile_type = /obj/projectile/beam/event_horizon
	select_name = "doomsday"
	e_cost = LASER_SHOTS(1, STANDARD_CELL_CHARGE)
	fire_sound = 'sound/items/weapons/beam_sniper.ogg'

/obj/projectile/beam/event_horizon
	name = "anti-existential beam"
	icon_state = null
	hitsound = 'sound/effects/explosion/explosion3.ogg'
	damage = 100 // Does it matter?
	damage_type = BURN
	armor_flag = ENERGY
	range = 150
	jitter = 20 SECONDS
	hitscan = TRUE
	tracer_type = /obj/effect/projectile/tracer/tracer/beam_rifle

/obj/projectile/beam/event_horizon/on_hit(atom/target, blocked, pierce_hit)
	. = ..()

	// Where we droppin' boys?
	var/turf/rift_loc = get_turf(target)

	// Spawn our temporary rift, then activate it.
	var/obj/reality_tear/temporary/tear = new(rift_loc)
	tear.start_disaster()
	message_admins("[ADMIN_LOOKUPFLW(target)] has been hit by an anti-existential beam at [ADMIN_VERBOSEJMP(rift_loc)], creating a singularity.")
