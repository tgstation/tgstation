/obj/item/gun/energy/e_gun/advtaser/mounted
	name = "mounted taser"
	desc = "An arm mounted dual-mode weapon that fires electrodes and disabler shots."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "taser"
	inhand_icon_state = "armcannonstun4"
	display_empty = FALSE
	force = 5
	selfcharge = 1
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL // Has no trigger at all, uses neural signals instead

/obj/item/gun/energy/e_gun/advtaser/mounted/add_seclight_point()
	return

/obj/item/gun/energy/laser/mounted
	name = "mounted laser"
	desc = "An arm mounted cannon that fires lethal lasers."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "laser_cyborg"
	inhand_icon_state = "armcannonlase"
	force = 5
	selfcharge = 1
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/gun/energy/laser/mounted/examine(mob/user)
	. = ..()
	. += span_notice("[src] can copy other gun projectiles by using a gun on it, and reset back to the default with [EXAMINE_HINT("right-click.")]")

/obj/item/gun/energy/laser/mounted/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	user.balloon_alert(user, "projectile reset")
	ammo_type = /obj/item/gun/energy/laser/mounted::ammo_type
	burst_size = initial(burst_size)
	burst_delay = initial(burst_delay)
	update_ammo_types()
	QDEL_NULL(chambered)
	recharge_newshot(TRUE)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/gun/energy/laser/mounted/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/gun/energy))
		return ..()
	user.balloon_alert(user, "projectile copied")
	var/obj/item/gun/energy/energy_gun = tool
	ammo_type = list(energy_gun.ammo_type[energy_gun.select])
	fire_sound = energy_gun.fire_sound
	burst_size = energy_gun.burst_size
	burst_delay = energy_gun.burst_delay
	fire_delay = energy_gun.fire_delay
	QDEL_NULL(chambered)
	recharge_newshot(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/item/gun/energy/laser/mounted/add_deep_lore()
	return
