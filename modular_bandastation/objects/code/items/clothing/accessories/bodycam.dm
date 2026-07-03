/datum/action/item_action/bodycam_toggle
	name = "Вкл/выкл нательную камеру"
	button_icon = 'modular_bandastation/objects/icons/obj/clothing/accessories.dmi'
	button_icon_state = "bodycamera"
	desc = "Включить/выключить нательную камеру."

// Accessory with pausable_bodycam comp, can be switched using action, damaged and repaired with a bunch of cables
/obj/item/clothing/accessory/bodycam
	name = "нательная камера"
	desc = "Небольшая нательная камера, подключенная к подсети станции. Активируется только когда камеру смотрят удалённо."
	icon = 'modular_bandastation/objects/icons/obj/clothing/accessories.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/accessories.dmi'
	icon_state = "bodycamera"
	attachment_slot = CHEST
	var/broken = FALSE
	// if false - camera monitor renders nothing
	var/camera_on = TRUE
	var/datum/action/item_action/bodycam_toggle/toggle_action

/obj/item/clothing/accessory/bodycam/accessory_equipped(obj/item/clothing/under/clothes, mob/living/user)
	. = ..()
	if(!isliving(user))
		return
	user.AddComponent(/datum/component/pausable_bodycam, "bodycam", "![user.name] (Нательная камера)", "ss13", FALSE, 0.5 SECONDS, camera_on && !broken)
	toggle_action = new(src)
	toggle_action.Grant(user)
	RegisterSignal(clothes, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp))

/obj/item/clothing/accessory/bodycam/accessory_dropped(obj/item/clothing/under/clothes, mob/living/user)
	UnregisterSignal(clothes, COMSIG_ATOM_EMP_ACT)
	if(toggle_action)
		toggle_action.Remove(user)
		toggle_action = null
	. = ..()
	if(!isliving(user))
		return
	var/datum/component/pausable_bodycam/comp = user.GetComponent(/datum/component/pausable_bodycam)
	if(comp)
		qdel(comp)

/obj/item/clothing/accessory/bodycam/ui_action_click(mob/user, datum/action/source)
	if(broken)
		balloon_alert(user, "сломана!")
		return
	camera_on = !camera_on
	var/datum/component/pausable_bodycam/comp = user?.GetComponent(/datum/component/pausable_bodycam)
	if(comp)
		comp.set_camera_enabled(camera_on)
	balloon_alert(user, camera_on ? "включена" : "выключена")

/obj/item/clothing/accessory/bodycam/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF || broken)
		return
	do_break()

/obj/item/clothing/accessory/bodycam/proc/on_emp(datum/source, severity)
	SIGNAL_HANDLER
	if(broken)
		return
	do_break()
	var/obj/item/clothing/under/uniform = source
	if(istype(uniform))
		var/mob/living/user = uniform.loc
		if(istype(user))
			var/datum/component/pausable_bodycam/comp = user.GetComponent(/datum/component/pausable_bodycam)
			if(comp)
				comp.set_broken(TRUE)
		uniform.update_accessory_overlay()

/obj/item/clothing/accessory/bodycam/proc/do_break()
	broken = TRUE
	icon_state = "bodycamera_broken"
	update_appearance()
	visible_message(span_warning("[src] искрит и гаснет!"))

/obj/item/clothing/accessory/bodycam/proc/repair_with_cable(mob/user, obj/item/stack/cable_coil/cabling)
	if(!broken)
		if(user)
			balloon_alert(user, "не сломана!")
		return FALSE
	if(!cabling.use(1))
		if(user)
			balloon_alert(user, "нужен моток провода!")
		return FALSE
	broken = FALSE
	icon_state = "bodycamera"
	update_appearance()
	var/obj/item/clothing/under/uniform = loc
	var/mob/living/wearer = istype(uniform) ? uniform.loc : null
	if(istype(wearer))
		var/datum/component/pausable_bodycam/comp = wearer.GetComponent(/datum/component/pausable_bodycam)
		if(comp)
			comp.set_broken(FALSE, camera_on)
	if(istype(uniform))
		uniform.update_accessory_overlay()
	return TRUE

/obj/item/clothing/accessory/bodycam/attackby(obj/item/item, mob/user, list/modifiers)
	if(broken && istype(item, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/cabling = item
		if(repair_with_cable(user, cabling))
			return TRUE
	return ..()

/obj/item/clothing/accessory/bodycam/examine(mob/user)
	. = ..()
	if(broken)
		. += span_warning("Сломана. Можно починить заменой проводки.")
	else if(!camera_on)
		. += span_notice("Сейчас выключена.")

/obj/item/clothing/under/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/stack/cable_coil))
		for(var/obj/item/clothing/accessory/bodycam/bc in attached_accessories)
			if(bc.broken && bc.repair_with_cable(user, tool))
				return ITEM_INTERACT_SUCCESS
	return ..()
