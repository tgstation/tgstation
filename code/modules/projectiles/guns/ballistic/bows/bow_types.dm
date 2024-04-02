
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

#define CHARGE_TIME 1.5 SECONDS
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
	force = 26
	var/on_sound = 'sound/weapons/gun/bow/cbow_on.ogg'
	var/off_sound = 'sound/weapons/gun/bow/cbow_off.ogg'
	var/charge_sound = 'sound/weapons/gun/bow/cbow_charge.ogg'
	var/warning_sound = 'sound/weapons/gun/bow/cbow_warning.ogg'
	var/choice_arrow_sound = 'sound/weapons/gun/bow/cbow_choice_arrow.ogg'
	var/sound_volume = 40
	var/charged = FALSE
	var/compact = TRUE
	var/recharge
	var/choice_arrow

/obj/item/gun/ballistic/bow/compact/update_icon_state()
	. = ..()
	inhand_icon_state = icon_state = compact ? "[base_icon_state]" : "[base_icon_state]_relised"
	update_inhand_icon()
	if(recharge)
		icon_state = "[base_icon_state]_recharge"
	if(charged)
		icon_state = "[base_icon_state]_charged"

/obj/item/gun/ballistic/bow/compact/update_overlays()
	. = ..()
	if(charged)
		switch(chambered.type)
			if(/obj/item/ammo_casing/arrow/intangible/standart)
				. += "[base_icon_state]_standart"
			if(/obj/item/ammo_casing/arrow/intangible/emp)
				. += "[base_icon_state]_emp"
			if(/obj/item/ammo_casing/arrow/intangible/repulse)
				. += "[base_icon_state]_repulse"

/obj/item/gun/ballistic/bow/compact/AltClick(mob/user)
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

/obj/item/gun/ballistic/bow/compact/attack_self(mob/user)
	if(compact)
		return
	if(recharge)
		src.balloon_alert(user, "on recharge!")
		playsound(src, warning_sound, sound_volume, vary = TRUE)
		return
	if(isnull(chambered))
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

/obj/item/gun/ballistic/bow/compact/afterattack(atom/target, mob/living/user, flag, params, passthrough)
	if(charged)
		recharge = addtimer(CALLBACK(src, PROC_REF(recharged)), CHARGE_TIME)
		charge_control(FALSE)
	. = ..()

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
	choice_arrow = show_radial_menu(user, src, allowed_arrows, tooltips = TRUE)
	if(isnull(choice_arrow))
		return FALSE
	if(compact)
		return FALSE
	switch(choice_arrow)
		if("Damage Arrow")
			return new /obj/item/ammo_casing/arrow/intangible/standart
		if("EMP Arrow")
			return new /obj/item/ammo_casing/arrow/intangible/emp
		if("Repulse Arrow")
			return new /obj/item/ammo_casing/arrow/intangible/repulse

/obj/item/ammo_box/magazine/internal/bow/compact
	name = "compact core"
	ammo_type = /obj/item/ammo_casing/arrow/intangible

#undef CHARGE_TIME
