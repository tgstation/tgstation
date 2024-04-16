/obj/item/autosurgeon/syndicate/gasharpoon
	starting_organ = /obj/item/organ/internal/cyberimp/arm/gun/gasharpoon

/obj/item/autosurgeon/syndicate/gasharpoon/single_use
	uses = 1

/obj/item/autosurgeon/syndicate/gasharpoon/hidden
	starting_organ = /obj/item/organ/internal/cyberimp/arm/gun/gasharpoon/syndicate

/obj/item/autosurgeon/syndicate/gasharpoon/hidden/single_use
	uses = 1

// The actual gasharpoon to be integrated

/obj/item/organ/internal/cyberimp/arm/gun/gasharpoon
	name = "gasharpoon"
	desc = "A metal gauntlet with a harpoon attatched, powered by gasoline and traditionally used by space-whalers."
	icon = 'icons/obj/devices/syndie_gadget.dmi'
	icon_state = "gasharpoon"
	inhand_icon_state = "gasharpoon"
	items_to_create = list(/obj/item/gun/gasharpoon)

/obj/item/organ/internal/cyberimp/arm/gun/gasharpoon/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/internal/cyberimp/arm/gun/gasharpoon/syndicate
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN

/obj/item/organ/internal/cyberimp/arm/gun/gasharpoon/syndicate/l
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN
	zone = BODY_ZONE_L_ARM

// The actual harpoon stuff below

/obj/item/gun/gasharpoon
	name = "harpoon gun"
	desc = "A heavily modified harpoon gun, it fires brutal rounds of 'Fuck-You' branded harpoons which are automatically synthesized."
	icon = 'icons/obj/devices/syndie_gadget.dmi'
	icon_state = "gasharpoon"
	inhand_icon_state = "gasharpoon"
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 7
	force = 10
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT)
	clumsy_check = FALSE
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	var/time_per_reload = 250
	var/ammo_left = 4
	var/max_ammo = 4
	var/last_reload = 0

/obj/item/gun/gasharpoon/apply_fantasy_bonuses(bonus)
	. = ..()
	max_ammo = modify_fantasy_variable("max_ammo", max_ammo, bonus, minimum = 1)
	time_per_reload = modify_fantasy_variable("time_per_reload", time_per_reload, -bonus * 10)

/obj/item/gun/gasharpoon/remove_fantasy_bonuses(bonus)
	max_ammo = reset_fantasy_variable("max_ammo", max_ammo)
	time_per_reload = reset_fantasy_variable("time_per_reload", time_per_reload)
	return ..()

/obj/item/gun/gasharpoon/Initialize(mapload)
	. = ..()
	chambered = new /obj/item/ammo_casing/gasharpoon(src)
	START_PROCESSING(SSobj, src)

/obj/item/gun/gasharpoon/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/gun/gasharpoon/can_shoot()
	return ammo_left

/obj/item/gun/gasharpoon/handle_chamber()
	if(chambered && !chambered.loaded_projectile && ammo_left)
		chambered.newshot()

/obj/item/gun/gasharpoon/process()
	if(ammo_left >= max_ammo)
		return
	if(world.time < last_reload+time_per_reload)
		return
	to_chat(loc, span_warning("You hear a 'ka-clunk!' as [src] synthesizes a new harpoon."))
	ammo_left++
	if(chambered && !chambered.loaded_projectile)
		chambered.newshot()
	last_reload = world.time

/obj/item/ammo_casing/gasharpoon
	name = "harpoon synthesiser"
	desc = "A high-power spring, linked to an energy-based piercing harpoon synthesiser."
	projectile_type = /obj/projectile/bullet/harpoon/gasharpoon
	firing_effect_type = null

/obj/item/ammo_casing/gasharpoon/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	if(!loaded_projectile)
		return
	if(istype(loc, /obj/item/gun/gasharpoon))
		var/obj/item/gun/gasharpoon/CG = loc
		if(CG.ammo_left <= 0)
			return
		loaded_projectile.name = "harpoon"
		CG.ammo_left--
	return ..()

/obj/projectile/bullet/harpoon/gasharpoon
	damage = 18
	icon_state = "harpoon"
