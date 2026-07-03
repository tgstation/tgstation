/obj/item/autosurgeon
	name = "autosurgeon"
	desc = "Устройство, которое устанавливает орган, имплант или скилл-чип в пользователя без необходимости хирургического вмешательства. \
		У него есть гнездо для установки импланта или органа, и гнездо для отвертки, чтобы доставать случайно вставленные вещи."
	icon = 'icons/obj/devices/tool.dmi'
	icon_state = "autosurgeon"
	inhand_icon_state = "nothing"
	w_class = WEIGHT_CLASS_SMALL

	/// How many times you can use the autosurgeon before it becomes useless
	var/uses = INFINITY
	/// What organ will the autosurgeon sub-type will start with. ie, CMO autosurgeon start with a medi-hud.
	var/starting_organ
	/// The organ currently loaded in the autosurgeon, ready to be implanted.
	var/obj/item/organ/stored_organ
	/// The list of organs and their children we allow into the autosurgeon. An empty list means no whitelist.
	var/list/organ_whitelist = list()
	/// The percentage modifier for how fast you can use the autosurgeon to implant other people.
	var/surgery_speed = 1
	/// The overlay that shows when the autosurgeon has an organ inside of it.
	var/loaded_overlay = "autosurgeon_loaded_overlay"

/obj/item/autosurgeon/attack_self_tk(mob/user)
	return //stops TK fuckery

/obj/item/autosurgeon/Initialize(mapload)
	. = ..()
	if(starting_organ)
		load_organ(new starting_organ(src))

/obj/item/autosurgeon/update_overlays()
	. = ..()
	if(stored_organ)
		. += loaded_overlay
		. += emissive_appearance(icon, loaded_overlay, src)

/obj/item/autosurgeon/proc/load_organ(obj/item/organ/loaded_organ, mob/living/user)
	if(user)
		if(stored_organ)
			to_chat(user, span_alert("[capitalize(declent_ru(NOMINATIVE))] уже содержит имплант."))
			return

		if(uses <= 0)
			to_chat(user, span_alert("[capitalize(declent_ru(NOMINATIVE))] достигает предела использования и не может загружать новые импланты."))
			return

		if(organ_whitelist.len)
			var/organ_whitelisted
			for(var/whitelisted_organ in organ_whitelist)
				if(istype(loaded_organ, whitelisted_organ))
					organ_whitelisted = TRUE
					break
			if(!organ_whitelisted)
				to_chat(user, span_alert("[capitalize(declent_ru(NOMINATIVE))] несовместим[genderize_decode(name, "", "а", "о", "ы")] с [loaded_organ.declent_ru(INSTRUMENTAL)]."))
				return

		if(!user.transferItemToLoc(loaded_organ, src))
			to_chat(user, span_alert("[capitalize(loaded_organ.declent_ru(NOMINATIVE))] застревает в вашей руке!"))
			return

	stored_organ = loaded_organ
	loaded_organ.forceMove(src)

	name = "[initial(name)] ([stored_organ.name])" //to tell you the organ type, like "suspicious autosurgeon (Reviver implant)"
	update_appearance()

/obj/item/autosurgeon/proc/use_autosurgeon(mob/living/target, mob/living/user, implant_time)
	if(!stored_organ)
		to_chat(user, span_alert("[capitalize(declent_ru(NOMINATIVE))] в данный момент не хранит имплантов."))
		return

	if(uses <= 0)
		to_chat(user, span_alert("[capitalize(declent_ru(NOMINATIVE))] не имеет больше зарядов. Устройства сложены и не могут быть реактивированны."))
		return

	if(implant_time)
		user.visible_message(
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] собирается использовать [declent_ru(ACCUSATIVE)] на [target.declent_ru(PREPOSITIONAL)]."),
			span_notice("Вы собираетесь использовать [declent_ru(ACCUSATIVE)] на [target.declent_ru(PREPOSITIONAL)]."),
		)
		if(!do_after(user, (implant_time * surgery_speed), target))
			return

	if(target != user)
		log_combat(user, target, "autosurgeon implanted [stored_organ] into", "[src]", "in [AREACOORD(target)]")
		user.visible_message(span_notice("[capitalize(user.declent_ru(NOMINATIVE))] нажимает на кнопку на [declent_ru(PREPOSITIONAL)], и тот врезается в тело [target.declent_ru(GENITIVE)]."), span_notice("Вы нажимаете на кнопку на [declent_ru(PREPOSITIONAL)], и тот врезается в тело [target.declent_ru(GENITIVE)]."))
	else
		user.visible_message(
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] нажимает на кнопку на [declent_ru(PREPOSITIONAL)], и тот врезается в [user.ru_p_theirs()] тело."),
			span_notice("Вы нажимаете на кнопку на [declent_ru(PREPOSITIONAL)], и тот врезается в ваше тело."),
		)

	if (stored_organ.valid_zones && user.get_held_index_of_item(src))
		var/list/checked_zones = list(user.zone_selected)
		if (IS_RIGHT_INDEX(user.get_held_index_of_item(src)))
			checked_zones += list(BODY_ZONE_R_ARM, BODY_ZONE_R_LEG)
		else
			checked_zones += list(BODY_ZONE_L_ARM, BODY_ZONE_L_LEG)

		for (var/check_zone in checked_zones)
			if (stored_organ.valid_zones[check_zone])
				stored_organ.swap_zone(check_zone)
				break

	if (!stored_organ.Insert(target)) // insert stored organ into the user
		balloon_alert(user, "insertion failed!")
		return

	stored_organ = null
	name = initial(name) //get rid of the organ in the name
	playsound(target.loc, 'sound/items/weapons/circsawhit.ogg', 50, vary = TRUE)
	update_appearance()

	uses--
	if(uses <= 0)
		desc = "[initial(desc)] Выглядит, словно не имеет больше зарядов."

/obj/item/autosurgeon/attack_self(mob/user)//when the object it used...
	use_autosurgeon(user, user)

/obj/item/autosurgeon/attack(mob/living/target, mob/living/user, list/modifiers, list/attack_modifiers)
	add_fingerprint(user)
	use_autosurgeon(target, user, 8 SECONDS)

/obj/item/autosurgeon/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(isorgan(tool))
		load_organ(tool, user)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/autosurgeon/screwdriver_act(mob/living/user, obj/item/screwtool)
	if(..())
		return TRUE
	if(!stored_organ)
		to_chat(user, span_warning("Внутри [declent_ru(GENITIVE)] нет имплантов!"))
	else
		var/atom/drop_loc = user.drop_location()
		for(var/atom/movable/stored_implant as anything in src)
			stored_implant.forceMove(drop_loc)
			to_chat(user, span_notice("Вы убираете [stored_organ.declent_ru(ACCUSATIVE)] из [declent_ru(GENITIVE)]."))
			stored_organ = null

		screwtool.play_tool_sound(src)
		uses--
		if(uses <= 0)
			desc = "[initial(desc)] Выглядит, словно не имеет больше зарядов."
		update_appearance(UPDATE_ICON)
	return TRUE

/obj/item/autosurgeon/medical_hud
	desc = "Одноразовый автохирург, который содержит имплант MedHUD. Отверткой можно достать имплант, но нельзя вставить обратно."
	uses = 1
	starting_organ = /obj/item/organ/cyberimp/eyes/hud/medical

/obj/item/autosurgeon/syndicate
	name = "suspicious autosurgeon"
	icon_state = "autosurgeon_syndicate"
	surgery_speed = 0.75
	loaded_overlay = "autosurgeon_syndicate_loaded_overlay"

/obj/item/autosurgeon/syndicate/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/autosurgeon/syndicate/laser_arm
	desc = "Одноразовый автохирург, который содержит аугментацию боевого лазера в руку. Отверткой можно достать имплант, но нельзя вставить обратно."
	uses = 1
	starting_organ = /obj/item/organ/cyberimp/arm/toolkit/gun/laser

/obj/item/autosurgeon/syndicate/thermal_eyes
	starting_organ = /obj/item/organ/eyes/robotic/thermals

/obj/item/autosurgeon/syndicate/thermal_eyes/single_use
	uses = 1

/obj/item/autosurgeon/syndicate/xray_eyes
	starting_organ = /obj/item/organ/eyes/robotic/xray

/obj/item/autosurgeon/syndicate/xray_eyes/single_use
	uses = 1

/obj/item/autosurgeon/syndicate/anti_stun
	starting_organ = /obj/item/organ/cyberimp/brain/anti_stun

/obj/item/autosurgeon/syndicate/anti_stun/single_use
	uses = 1

/obj/item/autosurgeon/syndicate/reviver
	starting_organ = /obj/item/organ/cyberimp/chest/reviver

/obj/item/autosurgeon/syndicate/reviver/single_use
	uses = 1

/obj/item/autosurgeon/syndicate/commsagent
	desc = "Устройство, которое автоматически - и болезненно - вставляет импланты. Выглядит так, словно кто-то специально \
	модифицировал его, чтобы оно вставляло только... языки. Пугающе."
	starting_organ = /obj/item/organ/tongue

/obj/item/autosurgeon/syndicate/commsagent/Initialize(mapload)
	. = ..()
	organ_whitelist += /obj/item/organ/tongue

/obj/item/autosurgeon/syndicate/emaggedsurgerytoolset
	starting_organ = /obj/item/organ/cyberimp/arm/toolkit/surgery/emagged

/obj/item/autosurgeon/syndicate/emaggedsurgerytoolset/single_use
	uses = 1

/obj/item/autosurgeon/syndicate/contraband_sechud
	desc = "Содержит контрабандный имплант SecHUD, который нельзя обнаружить анализаторами здоровья."
	uses = 1
	starting_organ = /obj/item/organ/cyberimp/eyes/hud/security/syndicate
