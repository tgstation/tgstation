/obj/item/melee/baton/nt_cane
	name = "fancy cane"
	desc = "Трость со специальной гравировкой. Кажется, она хорошо подходит для защиты от нападающих..."
	icon = 'modular_bandastation/weapon/icons/melee/baton.dmi'
	icon_state = "cane_nt"
	lefthand_file = 'modular_bandastation/weapon/icons/melee/inhands/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/melee/inhands/righthand.dmi'
	inhand_icon_state = "cane_nt"

/datum/action/item_action/toggle_nt_cane_safety
	name = "toggle safety"
	desc = "Переключает предохранитель на вашей трости. Требуется держать в активной руке для активации."

/obj/item/melee/baton/nt_cane/gun
	desc = "Трость со специальной гравировкой. Кажется, она хорошо подходит для защиты от нападающих... \n\
			Под указательным пальцем на рукоятке есть небольшая кнопка.\n\
			В верхней части рукояти имеется отверстие для чего-то ценного."
	var/load_sound = 'sound/effects/clock_tick.ogg'
	var/shot_sound = 'sound/items/weapons/effects/ric1.ogg'
	var/safety_on = TRUE
	var/diamond_loaded = FALSE
	var/projectile_type = /obj/projectile/bullet/nt_cane_diamond
	actions_types = list(/datum/action/item_action/toggle_nt_cane_safety)
	action_slots = ALL
	COOLDOWN_DECLARE(safety_toggle_cooldown)
	COOLDOWN_DECLARE(fire_cooldown)

/obj/item/melee/baton/nt_cane/gun/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)

	if(safety_on)
		return ..()

	if(try_fire_diamond(target, user))
		return

	if(user && target && !user.Adjacent(target))
		user.balloon_alert(user, "нет заряда!")
		return
	return ..()

/obj/item/melee/baton/nt_cane/gun/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/toggle_nt_cane_safety))
		toggle_safety(user)
		return
	return ..()

/obj/item/melee/baton/nt_cane/gun/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(try_fire_diamond(interacting_with, user))
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/item/melee/baton/nt_cane/gun/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)
	if(try_load_diamond(item, user))
		return
	return ..()

/obj/item/melee/baton/nt_cane/gun/examine(mob/user)
	. = ..()
	. += "предохранитель: [safety_on ? "включен" : "выключен"]."
	. += "заряд: [diamond_loaded ? "есть" : "отсутствует"]."

/obj/item/melee/baton/nt_cane/gun/proc/try_load_diamond(obj/item/item, mob/user)
	if(diamond_loaded)
		user?.balloon_alert(user, "уже заряжена!")
		return TRUE

	if(istype(item, /obj/item/stack/sheet/mineral/diamond))
		var/obj/item/stack/stack_item = item

		if(stack_item.use(1))
			diamond_loaded = TRUE
		if(load_sound)
			playsound(src, load_sound, 50, TRUE)
		user.balloon_alert(user, "заряжено")
		update_item_action_buttons()
		return TRUE

	return FALSE

/obj/item/melee/baton/nt_cane/gun/proc/try_fire_diamond(atom/target, mob/living/user)
	if(safety_on || !diamond_loaded)
		return FALSE
	if(!target || QDELETED(target) || !user || QDELETED(user))
		return TRUE
	if(target in user.contents)
		return TRUE

	if(!COOLDOWN_FINISHED(src, fire_cooldown))
		user.balloon_alert(user, "перезарядка!")
		return TRUE

	COOLDOWN_START(src, fire_cooldown, 1.5 SECONDS)
	diamond_loaded = FALSE
	fire_projectile(projectile_type, target, shot_sound, user, ignore_targets = list(user))
	update_item_action_buttons()
	return TRUE

/obj/item/melee/baton/nt_cane/gun/proc/toggle_safety(mob/user)
	if(!user)
		return FALSE
	if(user.get_active_held_item() != src)
		user.balloon_alert(user, "возьмите в активную руку!")
		return FALSE

	if(!COOLDOWN_FINISHED(src, safety_toggle_cooldown))
		user.balloon_alert(user, "перезарядка!")
		return FALSE
	COOLDOWN_START(src, safety_toggle_cooldown, 3 SECONDS)

	safety_on = !safety_on
	user.balloon_alert(user, "предохранитель: [safety_on ? "включен" : "выключен"].")
	add_fingerprint(user)
	update_item_action_buttons()
	INVOKE_ASYNC(src, PROC_REF(play_safety_sound), user)
	return TRUE

/obj/item/melee/baton/nt_cane/gun/proc/play_safety_sound(mob/user)
	for(var/i in 1 to 3)
		if(QDELETED(src))
			return

		sleep(0.25 SECONDS)
		playsound(user || src, 'sound/items/modsuit/atrocinator_step.ogg', 50, TRUE)
		sleep(0.25 SECONDS)

/obj/item/melee/baton/security/loaded/ert
	preload_cell_type = /obj/item/stock_parts/power_store/cell/hyper
