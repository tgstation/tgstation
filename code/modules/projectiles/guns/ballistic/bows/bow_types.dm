
///basic bow, used for medieval sim
/obj/item/gun/ballistic/bow/longbow
	name = "longbow"
	desc = "While pretty finely crafted, surely you can find something better to use in the current year."

///chaplain's divine archer bow
/obj/item/gun/ballistic/bow/divine
	name = "divine bow"
	desc = "Holy armament to pierce the souls of sinners."
	icon_state = "holybow"
	inhand_icon_state = "holybow"
	base_icon_state = "holybow"
	worn_icon_state = "holybow"
	slot_flags = ITEM_SLOT_BACK
	obj_flags = UNIQUE_RENAME
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/bow/holy

/obj/item/ammo_box/magazine/internal/bow/holy
	name = "divine bowstring"
	ammo_type = /obj/item/ammo_casing/arrow/holy

/obj/item/gun/ballistic/bow/divine/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY)
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "You disrupt the magic of %THEEFFECT with %THEWEAPON.", \
		success_forcesay = "BOW-GONE FOUL MAGIKS!!", \
		tip_text = "Clear rune", \
		on_clear_callback = CALLBACK(src, PROC_REF(on_cult_rune_removed)), \
		effects_we_clear = list(/obj/effect/rune, /obj/effect/heretic_rune) \
	)
	AddElement(/datum/element/bane, target_type = /mob/living/basic/revenant, damage_multiplier = 0, added_damage = 25, requires_combat_mode = FALSE)

/obj/item/gun/ballistic/bow/divine/proc/on_cult_rune_removed(obj/effect/target, mob/living/user)
	SIGNAL_HANDLER
	if(!istype(target, /obj/effect/rune))
		return

	var/obj/effect/rune/target_rune = target
	if(target_rune.log_when_erased)
		user.log_message("erased [target_rune.cultist_name] rune using [src]", LOG_GAME)
	SSshuttle.shuttle_purchase_requirements_met[SHUTTLE_UNLOCK_NARNAR] = TRUE

/obj/item/gun/ballistic/bow/divine/with_quiver/Initialize(mapload)
	. = ..()
	new /obj/item/storage/bag/quiver/holy(loc)

#define CHARGE_BASE 2 SECONDS
/obj/item/gun/ballistic/bow/compact
	name = "compact bow"
	desc = "Hi-Tech compact energy multi-bow. \n Alt-click to transform."
	icon_state = "compact_bow"
	base_icon_state = "compact_bow"
	inhand_icon_state = "compact_bow"
	worn_icon_state = "compact_bow"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/bow/compact
	drawn = TRUE
	slot_flags = null
	w_class = WEIGHT_CLASS_NORMAL
	var/on_sound = 'sound/weapons/gun/bow/cbow_on.ogg'
	var/off_sound = 'sound/weapons/gun/bow/cbow_off.ogg'
	var/charge_sound = 'sound/weapons/gun/bow/cbow_charge.ogg'
	var/warning_sound = 'sound/weapons/gun/bow/cbow_warning.ogg'
	var/choice_arrow_sound = 'sound/weapons/gun/bow/cbow_choice_arrow.ogg'
	var/sound_volume = 40
	var/charge_time = CHARGE_BASE
	var/charged = FALSE
	var/compact = TRUE
	var/disassemble = FALSE
	var/damage_arrow_control = ARROW_WIRE_ALRIGHT
	var/emp_arrow_control = ARROW_WIRE_ALRIGHT
	var/repulse_arrow_control = ARROW_WIRE_ALRIGHT
	var/change_arrow_control = ARROW_CHANGE_CONTROL_MANUALLY
	var/recharge
	var/choice_arrow

/obj/item/gun/ballistic/bow/compact/Initialize(mapload)
	. = ..()

	set_wires(new /datum/wires/compact_bow(src))
	AddComponent(/datum/component/scope, range_modifier = 3)

/obj/item/gun/ballistic/bow/compact/update_icon_state()
	. = ..()
	inhand_icon_state = icon_state = compact ? "[base_icon_state]" : "[base_icon_state]_relised"
	update_inhand_icon()
	if(recharge)
		icon_state = "[base_icon_state]_recharge"
	if(charged)
		icon_state = "[base_icon_state]_charged"
	if(disassemble)
		icon_state = "[base_icon_state]_disassemble"

/obj/item/gun/ballistic/bow/compact/update_overlays()
	. = ..()
	if(charged)
		if(istype(chambered, /obj/item/ammo_casing/arrow/intangible/standart))
			. += "[base_icon_state]_standart"
		if(istype(chambered, /obj/item/ammo_casing/arrow/intangible/emp))
			. += "[base_icon_state]_emp"
		if(istype(chambered, /obj/item/ammo_casing/arrow/intangible/repulse))
			. += "[base_icon_state]_repulse"

/obj/item/gun/ballistic/bow/compact/AltClick(mob/user)
	if(disassemble)
		src.balloon_alert(user, "intarface error")
		playsound(src, warning_sound, sound_volume, vary = TRUE)
		return
	if(recharge)
		src.balloon_alert(user, "on recharge!")
		playsound(src, warning_sound, sound_volume, vary = TRUE)
		return
	if(charged)
		chambered = null
		charge_control(FALSE)
	else
		compact = !compact
		if(compact)
			w_class = WEIGHT_CLASS_NORMAL
			playsound(src, off_sound, sound_volume, vary = TRUE)
		if(!compact)
			w_class = WEIGHT_CLASS_BULKY
			playsound(src, on_sound, sound_volume, vary = TRUE)
		update_appearance()
	. = ..()

/obj/item/gun/ballistic/bow/compact/drop_arrow()
	return

/obj/item/gun/ballistic/bow/compact/fire_gun(atom/target, mob/living/user, flag, params)
	. = ..()
	if(.)
		if(charged)
			recharge = addtimer(CALLBACK(src, PROC_REF(recharged)), charge_time)
			charge_control(FALSE)

/obj/item/gun/ballistic/bow/compact/screwdriver_act(mob/living/user, obj/item/I)
	if(charged)
		src.balloon_alert(user, "already charged!")
		playsound(src, warning_sound, sound_volume, vary = TRUE)
		return
	if(compact)
		src.balloon_alert(user, "open it first!")
		playsound(src, warning_sound, sound_volume, vary = TRUE)
		return
	disassemble = !disassemble
	to_chat(user, span_notice("[disassemble ? "you unscrewed the bow control" : "you turned on the bow control"]"))
	I.play_tool_sound(src, 25)
	update_appearance()

/obj/item/gun/ballistic/bow/compact/wirecutter_act(mob/living/user, obj/item/I)
	wires.interact(user)

/obj/item/gun/ballistic/bow/compact/multitool_act(mob/living/user, obj/item/tool)
	wires.interact(user)

/obj/item/gun/ballistic/bow/compact/attack_self(mob/user)
	if(compact)
		return
	if((damage_arrow_control == ARROW_WIRE_CUT) && (emp_arrow_control == ARROW_WIRE_CUT) && (repulse_arrow_control == ARROW_WIRE_CUT))
		src.balloon_alert(user, "!FATAL ERROR!")
		playsound(src, warning_sound, sound_volume, vary = TRUE)
		return
	if(disassemble)
		src.balloon_alert(user, "intarface error")
		playsound(src, warning_sound, sound_volume, vary = TRUE)
		return
	if(recharge)
		src.balloon_alert(user, "on recharge!")
		playsound(src, warning_sound, sound_volume, vary = TRUE)
		return
	if(isnull(chambered))
		charge_time = CHARGE_BASE - (((3-damage_arrow_control-emp_arrow_control-repulse_arrow_control)/2) SECONDS)
		chambered = pick_arrow(user)
		if(chambered)
			update_overlays()
			charge_control(TRUE)
			playsound(src, charge_sound, sound_volume, vary = TRUE)
		else
			chambered = null
			charge_control(FALSE)
			return
	else
		src.balloon_alert(user, "already charged!")
		playsound(src, warning_sound, sound_volume, vary = TRUE)

/obj/item/gun/ballistic/bow/compact/proc/invalid_arrow(mob/user)
	src.balloon_alert(user, "unknown arrow type")
	playsound(src, warning_sound, sound_volume, vary = TRUE)

/obj/item/gun/ballistic/bow/compact/proc/charge_control(switch_charge)
	charged = switch_charge
	update_appearance()

/obj/item/gun/ballistic/bow/compact/proc/recharged()
	recharge = null
	update_appearance()

/obj/item/gun/ballistic/bow/compact/proc/pick_arrow(mob/user)
	var/list/allowed_arrows = list(
		"Damage Arrow" = image(icon = 'icons/obj/weapons/bows/arrows.dmi', icon_state = "intangible_standart"),
		"EMP Arrow" = image(icon = 'icons/obj/weapons/bows/arrows.dmi', icon_state = "intangible_emp"),
		"Repulse Arrow" = image(icon = 'icons/obj/weapons/bows/arrows.dmi', icon_state = "intangible_repulse")
		)
	playsound(src, choice_arrow_sound, sound_volume, vary = TRUE)
	if(change_arrow_control == ARROW_CHANGE_CONTROL_MANUALLY)
		choice_arrow = show_radial_menu(user, src, allowed_arrows, tooltips = TRUE)
	else
		switch(change_arrow_control)
			if(ARROW_CHANGE_CONTROL_DAMAGE)
				choice_arrow = "Damage Arrow"
			if(ARROW_CHANGE_CONTROL_EMP)
				choice_arrow = "EMP Arrow"
			if(ARROW_CHANGE_CONTROL_REPULSE)
				choice_arrow = "Repulse Arrow"
			if(ARROW_CHANGE_CONTROL_RANDOM)
				switch(rand(1, ARROW_CHANGE_CONTROL_MAX_ALLOWED_ARROWS-1))
					if(ARROW_CHANGE_CONTROL_DAMAGE)
						choice_arrow = "Damage Arrow"
					if(ARROW_CHANGE_CONTROL_EMP)
						choice_arrow = "EMP Arrow"
					if(ARROW_CHANGE_CONTROL_REPULSE)
						choice_arrow = "Repulse Arrow"
	if(isnull(choice_arrow))
		return FALSE
	if(compact)
		return FALSE
	if(disassemble)
		return FALSE
	switch(choice_arrow)
		if("Damage Arrow")
			if(damage_arrow_control < ARROW_WIRE_ALRIGHT)
				invalid_arrow(user)
				return FALSE
			if(damage_arrow_control > ARROW_WIRE_ALRIGHT)
				return new /obj/item/ammo_casing/arrow/intangible/standart/pulsed
			else
				return new /obj/item/ammo_casing/arrow/intangible/standart
		if("EMP Arrow")
			if(emp_arrow_control < ARROW_WIRE_ALRIGHT)
				invalid_arrow(user)
				return FALSE
			if(emp_arrow_control > ARROW_WIRE_ALRIGHT)
				return new /obj/item/ammo_casing/arrow/intangible/emp/pulsed
			else
				return new /obj/item/ammo_casing/arrow/intangible/emp
		if("Repulse Arrow")
			if(repulse_arrow_control < ARROW_WIRE_ALRIGHT)
				invalid_arrow(user)
				return FALSE
			if(repulse_arrow_control > ARROW_WIRE_ALRIGHT)
				return new /obj/item/ammo_casing/arrow/intangible/repulse/pulsed
			else
				return new /obj/item/ammo_casing/arrow/intangible/repulse

/obj/item/ammo_box/magazine/internal/bow/compact
	name = "compact core"
	ammo_type = /obj/item/ammo_casing/arrow/intangible

#undef CHARGE_BASE
