#define CHARGE_LEVEL_NONE 0
#define CHARGE_LEVEL_LOW 1
#define CHARGE_LEVEL_MEDIUM 2
#define CHARGE_LEVEL_HIGH 3
#define CHARGE_LEVEL_OVERCHARGE 4

/obj/item/melee/sabre/vibroblade
	name = "vibroblade"
	desc = "Виброклинок воинов Раскинта. Микрогенератор ультразвука в рукояти позволяет лезвию вибрировать \
		с огромной частотой, что позволяет при его достаточной зарядке наносить глубокие раны даже ударами по касательной."
	icon = 'modular_bandastation/weapon/icons/melee/sword.dmi'
	icon_state = "vibroblade"
	inhand_icon_state = "vibroblade"
	lefthand_file = 'modular_bandastation/weapon/icons/melee/inhands/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/melee/inhands/righthand.dmi'
	force = 20
	armour_penetration = 75
	block_chance = 50
	throwforce = 15
	throw_range = 5
	var/charge_level = CHARGE_LEVEL_NONE
	var/max_charge_level = CHARGE_LEVEL_OVERCHARGE
	/// How long does it take to reach next level of charge.
	var/charge_time = 4 SECONDS
	/// TRUE if the item keeps charge only when is held in hands. FALSE if the item always keeps charge.
	var/hold_to_be_charged = TRUE
	/// Body parts that can be cut off.
	var/static/list/cutoff_candidates = list(
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_PRECISE_R_FOOT,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_PRECISE_R_HAND,
	)

/obj/item/melee/sabre/vibroblade/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_POST_THROW, PROC_REF(thrown))

/obj/item/melee/sabre/vibroblade/Destroy()
	. = ..()
	UnregisterSignal(src, COMSIG_MOVABLE_POST_THROW)

/obj/item/melee/sabre/vibroblade/update_icon_state()
	icon_state = "[initial(icon_state)][charge_level > CHARGE_LEVEL_NONE ? "_[charge_level]" : ""]"
	return ..()

/obj/item/melee/sabre/vibroblade/examine(mob/user)
	. = ..()
	. += span_notice("Используйте [declent_ru(ACCUSATIVE)] в руке, чтобы повысить уровень заряда.")
	if(charge_level == CHARGE_LEVEL_NONE)
		. += span_notice("[capitalize(declent_ru(NOMINATIVE))] не заряжен.")
		return

	. += span_notice("[capitalize(declent_ru(NOMINATIVE))] заряжен на [(charge_level / max_charge_level)*100]%.")
	. += charge_level == max_charge_level \
		? span_danger("Следующий удар будет крайне травмирующим!") \
		: span_warning("Следующий удар будет усиленным!")

/obj/item/melee/sabre/vibroblade/attack_self(mob/living/user, modifiers)
	if(charge_level >= max_charge_level)
		user.visible_message(
			span_notice("[user.name] пытается зарядить [declent_ru(ACCUSATIVE)], но кнопка на рукояти не поддается!"),
			span_notice("Вы пытаетесь нажать на кнопку зарядки [declent_ru(ACCUSATIVE)], но она заблокирована.")
		)
		return FALSE

	user.visible_message(
		span_notice("[user.name] нажимает на кнопку зарядки [declent_ru(ACCUSATIVE)]..."),
		span_notice("Вы нажимаете на кнопку зарядки [declent_ru(ACCUSATIVE)], заряжая микрогенератор...")
	)

	if(!do_after(user, charge_time, target = src))
		return
	playsound(loc, 'sound/effects/sparks/sparks3.ogg', vol = 10, vary = TRUE)
	do_sparks(1, TRUE, src)
	set_charge_level(charge_level + 1)

/obj/item/melee/sabre/vibroblade/afterattack(mob/living/carbon/target, mob/user, click_parameters)
	if(charge_level == CHARGE_LEVEL_HIGH)
		target.Knockdown(1.5 SECONDS)
	else if(charge_level == CHARGE_LEVEL_OVERCHARGE && ishuman(target) && (user.zone_selected in cutoff_candidates))
		var/obj/item/bodypart/target_bodypart = target.get_bodypart(check_zone(user.zone_selected))
		if(target_bodypart)
			target_bodypart.dismember(TRUE)
			user.visible_message(
				span_danger("[user] изящно и непринужденно отсекает [target_bodypart] [target]!"),
				span_danger("Вы искусно отсекаете [target_bodypart] [target]!")
			)

	set_charge_level(CHARGE_LEVEL_NONE)

/obj/item/melee/sabre/vibroblade/pre_attack(atom/A, mob/living/user, params)
	. = ..()
	force = initial(force) * get_damage_factor()

/obj/item/melee/sabre/vibroblade/suicide_act(mob/living/user)
	var/obj/item/bodypart/head = user.get_bodypart(BODY_ZONE_HEAD)
	user.visible_message(span_suicide("[user] прижимает лезвие [declent_ru(GENITIVE)] к своей шее и нажимает на кнопку зарядки микрогенератора. \
		Кажется, это попытка самоубийства!"))
	user.say("Слава Вечной Империи!")
	head.dismember()
	set_charge_level(CHARGE_LEVEL_NONE)
	return BRUTELOSS

/obj/item/melee/sabre/vibroblade/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	set_charge_level(CHARGE_LEVEL_NONE)

/obj/item/melee/sabre/vibroblade/equipped(mob/user, slot, initial)
	. = ..()
	if(hold_to_be_charged && slot != ITEM_SLOT_HANDS)
		set_charge_level(CHARGE_LEVEL_NONE)

/obj/item/melee/sabre/vibroblade/dropped(mob/user, silent)
	. = ..()
	if(hold_to_be_charged && !silent)
		set_charge_level(CHARGE_LEVEL_NONE)

/obj/item/melee/sabre/vibroblade/proc/thrown(datum/thrownthing/thrown_thing, spin)
	SIGNAL_HANDLER
	if(hold_to_be_charged)
		set_charge_level(CHARGE_LEVEL_NONE)

/obj/item/melee/sabre/vibroblade/proc/get_damage_factor()
	return 1 + 0.25 * clamp(charge_level, CHARGE_LEVEL_NONE, max_charge_level)

/obj/item/melee/sabre/vibroblade/proc/set_charge_level(charge_level)
	src.charge_level = charge_level
	force = initial(force) * get_damage_factor()
	update_icon(UPDATE_ICON_STATE)

/obj/item/melee/sabre/vibroblade/emperor_guard
	name = "emperor guard vibroblade"
	desc = "Виброклинок гвардейцев Императора. Микрогенератор ультразвука в рукояти позволяет лезвию вибрировать \
		с огромной частотой, что позволяет при его достаточной зарядке наносить глубокие раны даже ударами по касательной. \
		Воины Куи'кверр-Кэтиш обучаются мастерству ближнего боя с детства, поэтому в их руках он особо опасен и жесток. \
		Каждый будущий гвардеец добывает свой клинок в ритуальном бою, и его сохранность есть вопрос жизни и смерти владельца."
	icon_state = "vibroblade_elite"
	inhand_icon_state = "vibroblade_elite"
	force = 25
	charge_time = 2 SECONDS
	hold_to_be_charged = FALSE

/obj/item/melee/sabre/vibroblade/emperor_guard/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF)

#undef CHARGE_LEVEL_NONE
#undef CHARGE_LEVEL_LOW
#undef CHARGE_LEVEL_MEDIUM
#undef CHARGE_LEVEL_HIGH
#undef CHARGE_LEVEL_OVERCHARGE


/obj/item/storage/belt/vibroblade
	name = "vibroblade sheath"
	desc = "Ножны для вибромеча."
	icon = 'modular_bandastation/weapon/icons/melee/sheath.dmi'
	worn_icon = 'modular_bandastation/weapon/icons/melee/sheath_onmob.dmi'
	lefthand_file = 'modular_bandastation/weapon/icons/melee/inhands/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/melee/inhands/righthand.dmi'
	icon_state = "vibroblade_sheath"
	worn_icon_state = "vibroblade_sheath"
	inhand_icon_state = "vibroblade_sheath"
	storage_type = /datum/storage/vibroblade

/datum/storage/vibroblade
	max_slots = 1
	do_rustle = FALSE
	max_specific_storage = WEIGHT_CLASS_BULKY
	click_alt_open = FALSE

/obj/item/storage/belt/vibroblade/examine(mob/user)
	. = ..()
	if(length(contents))
		. += span_notice("Alt-click it to quickly draw the blade.")

/obj/item/storage/belt/vibroblade/click_alt(mob/user)
	if(length(contents))
		var/obj/item/I = contents[1]
		user.visible_message(span_notice("[user] takes [I] out of [src]."), span_notice("You take [I] out of [src]."))
		user.put_in_hands(I)
		update_appearance()
	else
		balloon_alert(user, "it's empty!")
	return CLICK_ACTION_SUCCESS

/obj/item/storage/belt/vibroblade/update_icon_state()
	icon_state = initial(inhand_icon_state)
	inhand_icon_state = initial(inhand_icon_state)
	worn_icon_state = initial(worn_icon_state)
	if(contents.len)
		icon_state += "-sabre"
		inhand_icon_state += "-sabre"
		worn_icon_state += "-sabre"
	return ..()

/obj/item/storage/belt/vibroblade/PopulateContents()
	new /obj/item/melee/sabre/vibroblade(src)

/obj/item/storage/belt/vibroblade_guard
	name = "guard vibroblade sheath"
	desc = "Ножны для гвардейского вибромеча."
	icon = 'modular_bandastation/weapon/icons/melee/sheath.dmi'
	worn_icon = 'modular_bandastation/weapon/icons/melee/sheath_onmob.dmi'
	lefthand_file = 'modular_bandastation/weapon/icons/melee/inhands/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/melee/inhands/righthand.dmi'
	icon_state = "vibroblade_guard_sheath"
	worn_icon_state = "vibroblade_guard_sheath"
	inhand_icon_state = "vibroblade_guard_sheath"
	storage_type = /datum/storage/vibroblade

/obj/item/storage/belt/vibroblade_guard/examine(mob/user)
	. = ..()
	if(length(contents))
		. += span_notice("Alt-click it to quickly draw the blade.")

/obj/item/storage/belt/vibroblade_guard/click_alt(mob/user)
	if(length(contents))
		var/obj/item/I = contents[1]
		user.visible_message(span_notice("[user] takes [I] out of [src]."), span_notice("You take [I] out of [src]."))
		user.put_in_hands(I)
		update_appearance()
	else
		balloon_alert(user, "it's empty!")
	return CLICK_ACTION_SUCCESS

/obj/item/storage/belt/vibroblade_guard/update_icon_state()
	icon_state = initial(inhand_icon_state)
	inhand_icon_state = initial(inhand_icon_state)
	worn_icon_state = initial(worn_icon_state)
	if(length(contents))
		icon_state += "-sabre"
		inhand_icon_state += "-sabre"
		worn_icon_state += "-sabre"
	return ..()

/obj/item/storage/belt/vibroblade_guard/PopulateContents()
	new /obj/item/melee/sabre/vibroblade/emperor_guard(src)
