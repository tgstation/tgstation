//should never be outside a mech without an admin
/obj/item/mecha_parts/mecha_equipment/weapon/clock
	name = "clock mech weapon"
	color = rgb(190, 135, 0)
	icon_state = "mecha_laser"
	equipment_flags = NOT_ABLE_TO_REMOVE_FROM_MECHA
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/clock/bow_single_shot
	name = "Energy Concentrator"
	desc = "A strange device that concentrates energy into \"arrows\"."
	projectile = /obj/projectile/energy/clockbolt
	equip_cooldown = 1 SECONDS
	energy_drain = 5

/obj/item/mecha_parts/mecha_equipment/weapon/clock/steam_cannon
	name = "Steam Cannon"
	desc = "A large tube that shoots pressurized steam."
	projectile = /obj/projectile/steam_cloud
	equip_cooldown = 5 SECONDS
	energy_drain = 20

/obj/item/mecha_parts/mecha_equipment/repair_droid/clock
	name = "Clockwork Repair Droid"
	desc = "A small device that constantly re-adjusts any out of place gears in a mech."
	color = rgb(190, 135, 0)
	energy_drain = 0 //we will see if an energy drain is needed
	equipment_flags = NOT_ABLE_TO_REMOVE_FROM_MECHA
	health_boost = 1 //should really just buff the normal repair droid up to this, its really bad right now
	repairable_damage = list(MECHA_INT_FIRE, MECHA_INT_CONTROL_LOST)

/obj/item/mecha_parts/mecha_equipment/armor/clock
	name = "Clockwork Armor Booster"
	desc = "A large clump of gears that somehow help protect a mech against all forms of attack."
	color = rgb(190, 135, 0)
	equipment_flags = NOT_ABLE_TO_REMOVE_FROM_MECHA
	icon_state = "mecha_abooster_proj"
	iconstate_name = "range"
	protect_name = "Clockwork Armor"
	armor_mod = /datum/armor/mecha_equipment_mixed_boost

/datum/armor/mecha_equipment_mixed_boost
	bullet = 10
	laser = 10
	melee = 15

/obj/projectile/steam_cloud
	name = "Steam Cloud"
	alpha = 0
	range = 8
	pass_flags = PASSGRILLE | PASSTABLE | PASSMOB | PASSSTRUCTURE
	damage = 0
	damage_type = BURN

//max 10 items and 10 mobs thrown
#define MAX_THROWN_THINGS 10
/obj/projectile/steam_cloud/Move(atom/newloc, direct, glide_size_override, update_dir)
	. = ..()

	var/turf/current_turf = get_turf(src)
	if(!current_turf)
		return

	new /obj/effect/temp_visual/steam(current_turf)
	var/turf/throw_at_turf = get_turf_in_angle(Angle, current_turf, 7)
	//basic tracker vars, anti lag to make sure we dont try and throw 100 things at the same time
	var/thrown_items = 0
	var/thrown_mobs = 0

	for(var/atom/movable/current_thrown in current_turf)
		if(thrown_items > MAX_THROWN_THINGS && thrown_mobs > MAX_THROWN_THINGS)
			break
		if(current_thrown.anchored || current_thrown.throwing)
			continue

		if(isitem(current_thrown))
			if(thrown_items > MAX_THROWN_THINGS)
				continue
			var/obj/item/thrown_item = current_thrown
			thrown_items++
			thrown_item.throw_at(throw_at_turf, 8, 2, null)
		else if(isliving(current_thrown))
			var/mob/living/thrown_mob = current_thrown
			if(IS_CLOCK(thrown_mob))
				continue
			thrown_mob.apply_damage((IS_CULTIST(thrown_mob) ? 30 : 20), BURN, wound_bonus = 30)
			if(thrown_mobs > MAX_THROWN_THINGS)
				continue
			thrown_mob.throw_at(throw_at_turf, 8, 2, null, TRUE, force = MOVE_FORCE_OVERPOWERING, gentle = TRUE)
			thrown_mobs++

#undef MAX_THROWN_THINGS
