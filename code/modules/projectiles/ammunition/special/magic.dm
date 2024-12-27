/obj/item/ammo_casing/magic
	name = "magic casing"
	desc = "I didn't even know magic needed ammo..."
	slot_flags = null
	projectile_type = /obj/projectile/magic
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/magic
	newtonian_force = 0.5

/obj/item/ammo_casing/magic/change
	projectile_type = /obj/projectile/magic/change

/obj/item/ammo_casing/magic/change/ready_proj(atom/target, mob/living/user, quiet, zone_override = "", atom/fired_from)
	if (!loaded_projectile)
		return

	// If we were fired by a Staff of Change, we can try to inherent their preset vars for our wabbajack
	var/obj/item/gun/magic/staff/change/change_staff = fired_from
	var/obj/projectile/magic/change/change_projectile = loaded_projectile
	if(istype(change_staff) && istype(change_projectile))
		change_projectile.set_wabbajack_effect = change_staff.preset_wabbajack_type
		change_projectile.set_wabbajack_changeflags = change_staff.preset_wabbajack_changeflag

	return ..()

/obj/item/ammo_casing/magic/animate
	projectile_type = /obj/projectile/magic/animate

/obj/item/ammo_casing/magic/heal
	projectile_type = /obj/projectile/magic/resurrection
	harmful = FALSE

/obj/item/ammo_casing/magic/death
	projectile_type = /obj/projectile/magic/death

/obj/item/ammo_casing/magic/teleport
	projectile_type = /obj/projectile/magic/teleport
	harmful = FALSE

/obj/item/ammo_casing/magic/safety
	projectile_type = /obj/projectile/magic/safety
	harmful = FALSE

/obj/item/ammo_casing/magic/door
	projectile_type = /obj/projectile/magic/door
	harmful = FALSE

/obj/item/ammo_casing/magic/fireball
	projectile_type = /obj/projectile/magic/fireball

/obj/item/ammo_casing/magic/chaos
	projectile_type = /obj/projectile/magic

/obj/item/ammo_casing/magic/spellblade
	projectile_type = /obj/projectile/magic/spellblade

/obj/item/ammo_casing/magic/arcane_barrage
	projectile_type = /obj/projectile/magic/arcane_barrage

/obj/item/ammo_casing/magic/honk
	projectile_type = /obj/projectile/bullet/honker

/obj/item/ammo_casing/magic/locker
	projectile_type = /obj/projectile/magic/locker

/obj/item/ammo_casing/magic/flying
	projectile_type = /obj/projectile/magic/flying

/obj/item/ammo_casing/magic/bounty
	projectile_type = /obj/projectile/magic/bounty

/obj/item/ammo_casing/magic/antimagic
	projectile_type = /obj/projectile/magic/antimagic

/obj/item/ammo_casing/magic/babel
	projectile_type = /obj/projectile/magic/babel

/obj/item/ammo_casing/magic/necropotence
	projectile_type = /obj/projectile/magic/necropotence

/obj/item/ammo_casing/magic/wipe
	projectile_type = /obj/projectile/magic/wipe

/obj/item/ammo_casing/magic/nothing
	projectile_type = /obj/projectile/magic/nothing
	harmful = FALSE

/obj/item/ammo_casing/magic/shrink
	projectile_type = /obj/projectile/magic/shrink

/obj/item/ammo_casing/magic/shrink/wand
	projectile_type = /obj/projectile/magic/shrink/wand
