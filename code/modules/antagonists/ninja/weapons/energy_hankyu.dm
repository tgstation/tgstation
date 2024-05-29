/**
 * # Energy hankyu
 *
 * The space ninja's hankyu.
 *
 * The hankyu that only space ninja spawns with. It's a bow with infinity arrows charging inside itself.
 * Bow have 3 arrow types:
 *		Damage arrow - give damage to target and knockdown it.
 * 		EMP arrow - make emp around arrow hit.
 * 		Repulse arrow - throws everyone away from turf where arrow hit.
 * Also have scope.
 */
#define CHARGE_BASE 3 SECONDS
/obj/item/gun/ballistic/bow/energy_hankyu
	name = "energy hankyu"
	desc = "Hi-Tech energy multi-bow"
	icon_state = "hankyu"
	base_icon_state = "hankyu"
	inhand_icon_state = "hankyu"
	worn_icon_state = "hankyu"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/bow/energy_hankyu
	drawn = TRUE
	slot_flags = null
	w_class = WEIGHT_CLASS_BULKY
	var/datum/effect_system/spark_spread/spark_system
	/// Sound when we pick arrow
	var/charge_sound = 'sound/weapons/gun/bow/cbow_charge.ogg'
	/// Sound alert when somthing going wrong
	var/warning_sound = 'sound/weapons/gun/bow/cbow_warning.ogg'
	/// Sound when we click on bow to get arrows list
	var/choice_arrow_sound = 'sound/weapons/gun/bow/cbow_choice_arrow.ogg'
	/// Time between new arrow can be loaded
	var/charge_time = CHARGE_BASE
	/// When bow has arrow it is charged
	var/charged = FALSE
	/// Recharge timer var. If not null bow don't give you pick new arrow to load
	var/recharge
	/// Picking arrow menu var.
	var/choice_arrow

/obj/item/gun/ballistic/bow/energy_hankyu/Initialize(mapload)
	. = ..()
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	AddComponent(/datum/component/scope, range_modifier = 3)

/obj/item/gun/ballistic/bow/energy_hankyu/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/item/gun/ballistic/bow/energy_hankyu/update_icon_state()
	. = ..()
	update_inhand_icon()
	if(recharge)
		icon_state = "[base_icon_state]_recharge"
	if(charged)
		icon_state = "[base_icon_state]_charged"

/obj/item/gun/ballistic/bow/energy_hankyu/update_overlays()
	. = ..()
	if(!charged)
		return
	if(istype(chambered, /obj/item/ammo_casing/arrow/intangible/damage))
		. += "[base_icon_state]_damage"
	if(istype(chambered, /obj/item/ammo_casing/arrow/intangible/emp))
		. += "[base_icon_state]_emp"
	if(istype(chambered, /obj/item/ammo_casing/arrow/intangible/repulse))
		. += "[base_icon_state]_repulse"

/obj/item/gun/ballistic/bow/energy_hankyu/click_alt(mob/user)
	if(recharge)
		balloon_alert(user, "on recharge!")
		playsound(src, warning_sound, 40, vary = TRUE)
		return
	if(charged)
		chambered = null
		charge_control(FALSE)
	update_appearance()
	return ..()

/obj/item/gun/ballistic/bow/energy_hankyu/drop_arrow()
	return

/obj/item/gun/ballistic/bow/energy_hankyu/fire_gun(atom/target, mob/living/user, flag, params)
	. = ..()
	if(!.)
		return
	if(!charged)
		return
	recharge = addtimer(CALLBACK(src, PROC_REF(recharged)), charge_time)
	charge_control(FALSE)

/obj/item/gun/ballistic/bow/energy_hankyu/attack_self(mob/user)
	if(recharge)
		balloon_alert(user, "on recharge!")
		playsound(src, warning_sound, 40, vary = TRUE)
		return
	if(chambered)
		balloon_alert(user, "already charged!")
		playsound(src, warning_sound, 40, vary = TRUE)
		return
	chambered = pick_arrow(user)
	if(!chambered)
		chambered = null
		charge_control(FALSE)
		return
	update_overlays()
	charge_control(TRUE)
	playsound(src, charge_sound, 40, vary = TRUE)

/// change charged status
/obj/item/gun/ballistic/bow/energy_hankyu/proc/charge_control(switch_charge)
	charged = switch_charge
	update_appearance()

/// recharge bow
/obj/item/gun/ballistic/bow/energy_hankyu/proc/recharged()
	recharge = null
	update_appearance()

/// proc to pick arrow(show radial menu of 3 arrow types)
/obj/item/gun/ballistic/bow/energy_hankyu/proc/pick_arrow(mob/user)
	var/list/allowed_arrows = list(
		"Damage Arrow" = image(icon = 'icons/obj/weapons/bows/arrows.dmi', icon_state = "damage_arrow"),
		"EMP Arrow" = image(icon = 'icons/obj/weapons/bows/arrows.dmi', icon_state = "emp_arrow"),
		"Repulse Arrow" = image(icon = 'icons/obj/weapons/bows/arrows.dmi', icon_state = "repulse_arrow")
		)
	playsound(src, choice_arrow_sound, 40, vary = TRUE)
	choice_arrow = show_radial_menu(user, src, allowed_arrows, tooltips = TRUE)
	if(isnull(choice_arrow))
		return FALSE
	switch(choice_arrow)
		if("Damage Arrow")
			return new /obj/item/ammo_casing/arrow/intangible/damage
		if("EMP Arrow")
			return new /obj/item/ammo_casing/arrow/intangible/emp
		if("Repulse Arrow")
			return new /obj/item/ammo_casing/arrow/intangible/repulse

/obj/item/ammo_box/magazine/internal/bow/energy_hankyu
	name = "energy core"
	ammo_type = /obj/item/ammo_casing/arrow/intangible

#undef CHARGE_BASE

/obj/item/ammo_casing/arrow/intangible
	name = "intangible arrow"
	desc = "a clot of intangible energy"
	projectile_type = /obj/projectile/bullet/arrow/intangible
	reusable = FALSE

/obj/projectile/bullet/arrow/intangible
	name = "intangible arrow"
	desc = "a clot of intangible energy"
	damage = 0

/obj/item/ammo_casing/arrow/intangible/damage
	name = "damage"
	icon_state = "damage_arrow"
	base_icon_state = "damage_arrow"
	projectile_type = /obj/projectile/bullet/arrow/intangible/damage

/obj/projectile/bullet/arrow/intangible/damage
	icon_state = "damage_arrow_projectile"
	damage = 35
	stamina = 40
	knockdown = 2 SECONDS
	drowsy = 15 SECONDS
	jitter = 15 SECONDS
	armour_penetration = 50

/obj/item/ammo_casing/arrow/intangible/emp
	name = "emp"
	icon_state = "emp_arrow"
	base_icon_state = "emp_arrow"
	projectile_type = /obj/projectile/bullet/arrow/intangible/emp

/obj/projectile/bullet/arrow/intangible/emp
	icon_state = "emp_arrow_projectile"
	var/emp_heavy = 1
	var/emp_light = 2

/obj/projectile/bullet/arrow/intangible/emp/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	empulse(target, emp_heavy, emp_light)

/obj/item/ammo_casing/arrow/intangible/repulse
	name = "repulse"
	icon_state = "repulse_arrow"
	base_icon_state = "repulse_arrow"
	projectile_type = /obj/projectile/bullet/arrow/intangible/repulse

/obj/projectile/bullet/arrow/intangible/repulse
	icon_state = "repulse_arrow_projectile"
	var/repulse_range = 1
	var/repulse_knockdown = 6 SECONDS

/obj/projectile/bullet/arrow/intangible/repulse/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	for(var/atom/movable/repulse in view(target, repulse_range))
		var/dir = get_edge_target_turf(target, get_dir(target, get_step_away(repulse, target)))
		if(repulse.anchored)
			continue
		if(get_turf(repulse) == get_turf(target))
			dir = get_edge_target_turf(firer, get_dir(firer, get_step_away(repulse, firer)))
		repulse.safe_throw_at(dir, 4, 2)
		if(isliving(repulse))
			var/mob/living/knockem = repulse
			knockem.Knockdown(repulse_knockdown)
	new /obj/effect/temp_visual/arrow_repulse(get_turf(target))
	playsound(get_turf(target), 'sound/magic/repulse.ogg', 40, vary = TRUE)

/obj/effect/temp_visual/arrow_repulse
	name = "repulse arrow"
	icon = 'icons/effects/effects.dmi'
	icon_state = "arrow_repulse"
	duration = 2 SECONDS
