/obj/item/compression_kit
	name = "bluespace compression kit"
	desc = "An illegally modified BSRPED, capable of reducing the size of most items."
	icon = 'monkestation/icons/obj/tools.dmi'
	icon_state = "compression_kit"
	inhand_icon_state = "BS_RPED"
	worn_icon_state = "RPED"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	var/charges = 5

/obj/item/compression_kit/examine(mob/user)
	. = ..()
	. += span_notice("It has [charges] charges left. Recharge with bluespace crystals.")

/obj/item/compression_kit/proc/sparks()
	var/datum/effect_system/spark_spread/spark_spread = new /datum/effect_system/spark_spread
	spark_spread.set_up(5, TRUE, get_turf(src))
	spark_spread.start()

/obj/item/compression_kit/afterattack(obj/item/target, mob/user, proximity)
	. = ..()
	if(!proximity || !target || !istype(target))
		return
	else if(charges == 0)
		playsound(get_turf(src), 'sound/machines/buzz-two.ogg', vol = 50, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
		to_chat(user, span_warning("The bluespace compression kit is out of charges! Recharge it with bluespace crystals."))
		return
	var/pre_compress = SEND_SIGNAL(target, COMSIG_ITEM_PRE_COMPRESS, user, src)
	if(pre_compress & COMPONENT_STOP_COMPRESSION)
		if(!(pre_compress & COMPONENT_HANDLED_MESSAGE))
			to_chat(user, span_warning("[src] is unable to compress [target]!"))
		return
	if(target.w_class <= WEIGHT_CLASS_TINY)
		playsound(get_turf(src), 'sound/machines/buzz-two.ogg', vol = 50, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
		to_chat(user, span_warning("[target] cannot be compressed smaller!"))
		return
	playsound(get_turf(src), 'sound/weapons/flash.ogg', vol = 50, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	user.visible_message(span_warning("[user] is compressing [target] with [src]!"), vision_distance = COMBAT_MESSAGE_RANGE)
	if(do_after(user, 4 SECONDS, target, interaction_key = "[type]") && charges > 0 && target.w_class > WEIGHT_CLASS_TINY)
		playsound(get_turf(src), 'sound/weapons/emitter2.ogg', vol = 50, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
		sparks()
		flash_lighting_fx(range = 3, power = 3, color = LIGHT_COLOR_CYAN)
		if(!target.adjust_weight_class(-1))
			to_chat(user, span_bolddanger("Bluespace compression has encountered a critical error and stopped working, please report this your superiors."))
			return
		SEND_SIGNAL(target, COMSIG_ITEM_COMPRESSED, user, src)
		charges -= 1
		to_chat(user, span_boldnotice("You successfully compress [target]! [src] now has [charges] charges."))

/obj/item/compression_kit/attackby(obj/item/stack/bs, mob/user, params)
	. = ..()
	var/static/list/bs_typecache = typecacheof(list(/obj/item/stack/ore/bluespace_crystal, /obj/item/stack/sheet/bluespace_crystal))
	if(is_type_in_typecache(bs, bs_typecache) && bs.use(1))
		charges += 2
		to_chat(user, span_notice("You insert [bs] into [src]. It now has [charges] charges."))

/obj/item/compression_kit/attackby_storage_insert(datum/storage, atom/storage_holder, mob/user)
	. = ..()
	if(HAS_TRAIT(storage_holder, TRAIT_BYPASS_COMPRESS_CHECK))
		return FALSE
