#define INTERNAL_VOLUME 50
#define MAX_FUEL 30
#define FUEL_PER_COAL 30
#define FUEL_CONSUME_INTERVAL 30 SECONDS

#define SMOKE_CONSUME_INTERVAL 1 SECONDS
#define SMOKE_CONSUME_AMOUNT 0.1

#define INHALE_COOLDOWN 5 SECONDS
#define BASE_COUGH_STAMINA_LOSS 5
#define INHALE_STAMINA_LOSS 20

#define BASE_INHALE_VOLUME 3
#define BASE_INHALE_LIMIT 3

#define MAX_FOOD_ITEMS 5

#define RADIAL_CLEAR image(icon = 'modular_bandastation/bar_hookahs/icons/radial.dmi', icon_state = "eject")
#define RADIAL_EXTINGUISH image(icon = 'modular_bandastation/bar_hookahs/icons/radial.dmi', icon_state = "extinguish")
#define RADIAL_BLOW image(icon = 'modular_bandastation/bar_hookahs/icons/radial.dmi', icon_state = "blow")

#define OPTION_CLEAR "Очистить чашу"
#define OPTION_EXTINGUISH "Погасить угли"
#define OPTION_BLOW "Раскурить"

/obj/item/hookah
	name = "hookah"
	desc = "Простой стеклянный водный кальян."
	icon = 'modular_bandastation/bar_hookahs/icons/hookah.dmi'
	icon_state = "hookah"
	max_integrity = 50
	integrity_failure = 0
	inhand_icon_state = "beaker"
	w_class = WEIGHT_CLASS_HUGE

	/// Mouthpiece that belongs to this hookah
	var/obj/item/hookah_mouthpiece/hookah_mouthpiece
	var/fuel = 0
	var/lit = FALSE
	COOLDOWN_DECLARE(fuel_consume_cooldown)
	COOLDOWN_DECLARE(smoke_decrease_cooldown)
	var/particle_type
	var/datum/light_source/glow_light
	/// Food ingridients inside the bowl
	var/list/food_items = list()
	/// How well smoked is this hookah?
	var/smoke_amount = 0

	/// List of food ingridients that are safe to process
	var/static/allowed_ingridients = typecacheof(list(
		/obj/item/food/grown,
		/obj/item/food/cheese,
	))

/obj/item/hookah/add_context(atom/source, list/context, atom/target, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_RMB] = "Взять мундштук"
	context[SCREENTIP_CONTEXT_ALT_RMB] = "Действие"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/hookah/examine()
	. = ..()
	var/list/food_item_list = list()
	for(var/obj/item/food/food_item in food_items)
		food_item_list += food_item.declent_ru(NOMINATIVE)
	. += span_notice("В чаше [english_list(food_item_list, nothing_text = "пусто", and_text = " и ", comma_text = ", ")].")
	if(lit)
		. += span_notice("[capitalize(src.declent_ru(NOMINATIVE))] зажжён.")

/obj/item/hookah/Initialize(mapload)
	. = ..()
	hookah_mouthpiece = new(src, src)
	update_appearance(UPDATE_OVERLAYS)
	create_reagents(INTERNAL_VOLUME, TRANSPARENT)
	register_context()

/obj/item/hookah/update_overlays()
	. = ..()
	if(hookah_mouthpiece in contents)
		. += "pipe"
	if(fuel > 0)
		. += "coal"
	if(lit)
		. += "coal_lit"
		. += emissive_appearance(icon, "lit_overlay", src, alpha = src.alpha)

/obj/item/hookah/proc/return_mouthpiece(obj/item/hookah_mouthpiece/current_mouthpiece)
	if(hookah_mouthpiece != current_mouthpiece)
		return FALSE

	if(hookah_mouthpiece in contents)
		return FALSE

	current_mouthpiece.disconnect()
	current_mouthpiece.forceMove(src)
	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/item/hookah/attack_hand_secondary(mob/user, list/modifiers)
	if(ismob(loc))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(!(hookah_mouthpiece in contents))
		balloon_alert(user, "уже занято!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	take_mouthpiece(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/hookah/proc/take_mouthpiece(mob/user)
	user.put_in_hands(hookah_mouthpiece)
	hookah_mouthpiece.connect_to(user)
	to_chat(user, span_notice("Вы берёте [src.declent_ru(NOMINATIVE)] в руку."))
	update_appearance(UPDATE_OVERLAYS)

/obj/item/hookah/proc/try_light(obj/item/lighter_object, mob/user)
	var/msg = lighter_object.ignition_effect(src, user)
	if(!msg)
		return FALSE

	if(lit)
		to_chat(user, span_warning("[capitalize(src.declent_ru(NOMINATIVE))] уже зажжён!"))
		return FALSE

	if(!fuel)
		to_chat(user, span_warning("В [src.declent_ru(PREPOSITIONAL)] нет углей!"))
		return FALSE

	visible_message(msg)
	ignite()
	return TRUE

/obj/item/hookah/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(tool == hookah_mouthpiece)
		return_mouthpiece(tool)
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/hookah_coals))
		add_coals(user, tool)
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/food))
		add_food(user, tool)
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/reagent_containers))
		add_reagents(user, tool)
		return ITEM_INTERACT_SUCCESS

	if(try_light(tool, user))
		return
	return NONE

/obj/item/hookah/proc/add_coals(mob/user, obj/item/hookah_coals/coal)
	if(fuel + FUEL_PER_COAL > MAX_FUEL)
		to_chat(user, span_warning("В [src.declent_ru(PREPOSITIONAL)] уже достаточно углей!"))
		return
	fuel += FUEL_PER_COAL
	qdel(coal)
	to_chat(user, span_notice("Вы добавляете угли в [src.declent_ru(NOMINATIVE)]."))

/obj/item/hookah/proc/add_food(mob/user, obj/item/food/food_item)
	if(length(food_items) >= MAX_FOOD_ITEMS)
		to_chat(user, span_warning("В [src.declent_ru(PREPOSITIONAL)] уже достаточно ингридиентов!"))
		return
	food_items += food_item
	food_item.forceMove(src)
	to_chat(user, span_notice("Вы добавляете [food_item.declent_ru(NOMINATIVE)] в [src.declent_ru(NOMINATIVE)]."))

/obj/item/hookah/proc/add_reagents(mob/user, obj/item/reagent_containers/container)
	if(istype(container, /obj/item/reagent_containers/applicator/pill))
		return

	if(!container.reagents.total_volume)
		to_chat(user, span_warning("Внутри [container.declent_ru(GENITIVE)] ничего нет!"))
		return

	var/transferred = container.reagents.trans_to(src, container.amount_per_transfer_from_this)
	if(transferred <= 0)
		to_chat(user, span_warning("В [src.declent_ru(PREPOSITIONAL)] нет места!"))
		return

	user.visible_message(
		span_notice("[user] переливает что-то в [src.declent_ru(NOMINATIVE)]."),
		span_notice("Вы переливаете [transferred] единиц жидкости в [src.declent_ru(NOMINATIVE)].")
	)

/obj/item/hookah/process()
	if(!lit || !fuel)
		return PROCESS_KILL

	if(COOLDOWN_FINISHED(src, fuel_consume_cooldown))
		fuel = max(fuel - 1, 0)
		COOLDOWN_START(src, fuel_consume_cooldown, FUEL_CONSUME_INTERVAL)
		if(fuel <= 0)
			put_out()
			return PROCESS_KILL

	if(COOLDOWN_FINISHED(src, smoke_decrease_cooldown) && (smoke_amount - SMOKE_CONSUME_AMOUNT >= 0))
		smoke_amount -= SMOKE_CONSUME_AMOUNT
		COOLDOWN_START(src, smoke_decrease_cooldown, SMOKE_CONSUME_INTERVAL)

/obj/item/hookah/click_alt_secondary(mob/user)
	if(!ishuman(user))
		return CLICK_ACTION_BLOCKING
	var/list/hookah_radial_options = list()
	if(lit)
		hookah_radial_options[OPTION_EXTINGUISH] = RADIAL_EXTINGUISH

	if((length(food_items) || reagents.total_volume) && lit)
		hookah_radial_options[OPTION_BLOW] = RADIAL_BLOW

	if(length(food_items) || reagents.total_volume)
		hookah_radial_options[OPTION_CLEAR] = RADIAL_CLEAR

	var/choice = show_radial_menu(user, src, hookah_radial_options, require_near = TRUE)

	if(!choice)
		return CLICK_ACTION_BLOCKING

	switch(choice)
		if(OPTION_EXTINGUISH)
			if(!lit)
				return CLICK_ACTION_BLOCKING

			to_chat(user, span_notice("Вы начинаете тушить [src.declent_ru(NOMINATIVE)]..."))
			if(!do_after(user, 2 SECONDS, src))
				return CLICK_ACTION_BLOCKING

			put_out()
			return CLICK_ACTION_SUCCESS

		if(OPTION_BLOW)
			if(!lit)
				return CLICK_ACTION_BLOCKING

			if(!length(food_items) && !reagents.total_volume)
				to_chat(user, span_warning("В [src.declent_ru(PREPOSITIONAL)] нет ингридиентов!"))
				return CLICK_ACTION_BLOCKING

			var/mob/living/living_user = user
			if(!(hookah_mouthpiece in living_user.held_items))
				return CLICK_ACTION_BLOCKING

			user.visible_message(span_notice("[user] глубоко затягивается..."), span_notice("Вы делаете глубокую затяжку..."))
			if(!do_after(user, 5 SECONDS, src))
				return CLICK_ACTION_BLOCKING

			hookah_mouthpiece.inhale_smoke(living_user, BASE_INHALE_VOLUME * 2, TRUE)
			return CLICK_ACTION_SUCCESS

		if(OPTION_CLEAR)
			if(!do_after(user, 2 SECONDS, src))
				return CLICK_ACTION_BLOCKING

			reagents.clear_reagents()
			to_chat(user, span_notice("Вы очищаете чашу [src.declent_ru(GENITIVE)]."))
			return CLICK_ACTION_SUCCESS

/obj/item/hookah/proc/ignite()
	particle_type = /particles/smoke/cig/big
	add_shared_particles(particle_type)
	lit = TRUE
	START_PROCESSING(SSmachines, src)
	visible_message(span_notice("Угли внутри [src.declent_ru(GENITIVE)] медленно багровеют."))
	update_appearance()
	set_light(2, 1, LIGHT_COLOR_ORANGE)
	smoke_amount = 30
	COOLDOWN_START(src, fuel_consume_cooldown, FUEL_CONSUME_INTERVAL)
	COOLDOWN_START(src, smoke_decrease_cooldown, SMOKE_CONSUME_INTERVAL)

/obj/item/hookah/proc/put_out()
	lit = FALSE
	visible_message(span_notice("Угли внутри [src.declent_ru(GENITIVE)] возвращают свой привычный цвет."))
	update_appearance()
	if(!fuel)
		STOP_PROCESSING(SSmachines, src)
	stop_smoke()
	set_light(0)
	smoke_amount = 0

/obj/item/hookah/proc/stop_smoke()
	if(particle_type)
		remove_shared_particles(particle_type)
		particle_type = null

/obj/item/hookah/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(QDELETED(src))
		return
	atom_destruction()

/obj/item/hookah/atom_destruction(damage_flag)
	fuel = 0
	new /obj/item/shard(get_turf(src))
	if(reagents.total_volume)
		reagents.expose(get_turf(src), TOUCH)

	for(var/obj/item/food/some_food in food_items)
		var/turf/drop_loc = get_turf(src)
		var/obj/item/food/food_item = some_food
		if(food_item.reagents.total_volume)
			food_item.reagents.expose(drop_loc, TOUCH)
		qdel(food_item)

	if(hookah_mouthpiece)
		qdel(hookah_mouthpiece)

	QDEL_LIST(food_items)
	visible_message(span_warning("[capitalize(src.declent_ru(NOMINATIVE))] с треском разлетается на осколки!"))
	playsound(src, SFX_SHATTER, 50)
	return ..()

/obj/item/hookah/pickup(mob/user)
	. = ..()
	if(hookah_mouthpiece && !(hookah_mouthpiece in contents))
		return_mouthpiece(hookah_mouthpiece)
		to_chat(user, span_notice("Мундштук возвращается в [src.declent_ru(NOMINATIVE)]."))

/obj/item/hookah/Destroy()
	stop_smoke()

	QDEL_LIST(food_items)
	if(hookah_mouthpiece)
		hookah_mouthpiece.source_hookah = null
		hookah_mouthpiece.disconnect()
		QDEL_NULL(hookah_mouthpiece)

	set_light(0)
	return ..()

/obj/item/hookah_mouthpiece
	name = "mouthpiece"
	desc = "Мундштук, выполненный из какого-то лёгкого металла. На его ручке что-то выгравировано."
	icon = 'modular_bandastation/bar_hookahs/icons/hookah.dmi'
	icon_state = "mouthpiece"
	w_class = WEIGHT_CLASS_BULKY
	var/obj/item/hookah/source_hookah
	var/datum/beam/beam
	var/atom/attached_to
	COOLDOWN_DECLARE(inhale_cooldown)
	var/particle_type

/obj/item/hookah_mouthpiece/Initialize(mapload, obj/item/hookah/hookah)
	. = ..()
	if(hookah)
		source_hookah = hookah
	else
		stack_trace("Hookah mouthpiece created without hookah!")
		return INITIALIZE_HINT_QDEL

/obj/item/hookah_mouthpiece/proc/connect_to(mob/living_mob)
	if(!source_hookah || !living_mob)
		return FALSE

	attached_to = living_mob
	beam = source_hookah.Beam(
		living_mob,
		icon = 'icons/effects/beam.dmi',
		icon_state = "1-full",
		beam_color = COLOR_BLACK,
		layer = BELOW_MOB_LAYER,
		override_origin_pixel_y = 0,
	)

	RegisterSignal(living_mob, COMSIG_MOVABLE_MOVED, PROC_REF(check_distance))
	return TRUE

/obj/item/hookah_mouthpiece/proc/disconnect()
	if(attached_to)
		UnregisterSignal(attached_to, COMSIG_MOVABLE_MOVED)
		attached_to = null
	QDEL_NULL(beam)

/obj/item/hookah_mouthpiece/proc/check_distance()
	if(!source_hookah || !attached_to)
		return

	if((get_dist(source_hookah, attached_to) <= 1) && isturf(attached_to.loc))
		return

	if(ismob(attached_to))
		var/mob/user = attached_to
		user.dropItemToGround(src)
		to_chat(user, span_warning("Вы отпускаете [source_hookah.declent_ru(NOMINATIVE)]."))
	disconnect()

/obj/item/hookah_mouthpiece/Destroy()
	if(source_hookah)
		source_hookah.stop_smoke()
		source_hookah.hookah_mouthpiece = null
	disconnect()
	return ..()

/obj/item/hookah_mouthpiece/dropped(mob/user)
	. = ..()
	if(source_hookah)
		source_hookah.return_mouthpiece(src)

/obj/item/hookah_mouthpiece/attack_self(mob/user)
	if(!source_hookah?.lit || !ishuman(user))
		return ..()
	start_inhale(user)

/obj/item/hookah_mouthpiece/attack(mob/living/target_mob, mob/living/user)
	if(target_mob == user && source_hookah.lit)
		start_inhale(target_mob)
		return
	return ..()

/obj/item/hookah_mouthpiece/proc/start_inhale(mob/living/carbon/human/living_user)
	living_user.visible_message(span_notice("[living_user] затягивается из [src.declent_ru(GENITIVE)]."), span_notice("Вы затягиваетесь..."))
	if(!do_after(living_user, 2 SECONDS, src))
		return
	inhale_smoke(living_user, BASE_INHALE_VOLUME)

/obj/item/hookah_mouthpiece/proc/inhale_smoke(target_mob, amount, skip_calculations = FALSE)
	var/is_safe = TRUE
	var/mob/living/living_user = target_mob
	if(HAS_TRAIT(living_user, TRAIT_NOBREATH))
		to_chat(living_user, span_warning("Вы не можете сделать и вдоха!"))
		return

	if(!source_hookah?.reagents)
		return

	var/datum/reagents/these_reagents = source_hookah.reagents
	for(var/obj/item/food/some_food_item in source_hookah.food_items)
		if(!some_food_item.reagents)
			qdel(some_food_item)
			continue

		if(!is_type_in_typecache(some_food_item, source_hookah.allowed_ingridients))
			is_safe = FALSE

		some_food_item.reagents.trans_to(these_reagents, amount / length(source_hookah.food_items))
		if(!some_food_item.reagents.total_volume)
			source_hookah.food_items -= some_food_item
			qdel(some_food_item)

	if(!is_safe)
		make_black_smoke(living_user, source_hookah.loc, these_reagents)
		return

	if(!source_hookah || !source_hookah.reagents.total_volume)
		to_chat(living_user, span_warning("В [src.declent_ru(GENITIVE)] нет жидкости!"))
		return

	var/smoke_efficiency = min(source_hookah.smoke_amount, 100) / 100
	var/amount_to_transfer = skip_calculations ? amount : amount * smoke_efficiency
	var/amount_to_waste = amount - amount_to_transfer
	var/transferred = these_reagents.trans_to(living_user, amount_to_transfer, methods = INHALE)

	playsound(src, 'sound/effects/bubbles/bubbles.ogg', 20)
	if(transferred)
		to_chat(living_user, span_notice("Вы вдыхаете дым из [src.declent_ru(GENITIVE)]."))
		living_user.add_mood_event("smoked", /datum/mood_event/smoked)

		if(!COOLDOWN_FINISHED(src, inhale_cooldown) || transferred > BASE_INHALE_LIMIT)
			living_user.visible_message(span_warning(pick("[living_user] закашливается!", "[living_user] морщится, откашливаясь.", "[living_user] задыхается!")), span_warning(pick("Голова кружится...", "Вы закашливаетесь, морщась от острого покалывания в горле.", "Вы задыхаетесь!")))
			living_user.emote("cough")
			living_user.adjust_stamina_loss(BASE_COUGH_STAMINA_LOSS * (transferred / BASE_INHALE_LIMIT))

		switch(smoke_efficiency * 100)
			if(-INFINITY to 20)
				to_chat(living_user, span_warning("Ваше горло словно обжигает..."))
				living_user.emote("cough")
			if(20 to 40)
				to_chat(living_user, span_notice("Слегка горчит."))
			if(40 to 80)
				to_chat(living_user, span_notice("Довольно приятный вкус..."))
			else
				to_chat(living_user, span_notice("Неплохой дымок."))

		COOLDOWN_START(src, inhale_cooldown, INHALE_COOLDOWN)
		source_hookah.smoke_amount = min(source_hookah.smoke_amount + rand(amount * 2, amount), 100)
		addtimer(CALLBACK(src, PROC_REF(delayed_puff), living_user, amount_to_waste), 1 SECONDS)

/obj/item/hookah_mouthpiece/proc/make_black_smoke(mob/living_user, location, datum/reagents/some_reagents)
	do_chem_smoke(2, null, location, carry = some_reagents)
	QDEL_LIST(source_hookah.food_items)
	some_reagents.clear_reagents()
	to_chat(living_user, span_warning("Вы чувствуете резкий неприятный запах!"))
	living_user.dropItemToGround(src)
	living_user.emote("cough")

	if(!ishuman(living_user))
		return

	var/mob/living/carbon/human/human_user = living_user
	human_user.adjust_stamina_loss(BASE_COUGH_STAMINA_LOSS * 4)

/obj/item/hookah_mouthpiece/proc/delayed_puff(mob/user, amount)
	do_chem_smoke(amount / 5, null, user.loc, carry = source_hookah.reagents, amount = amount * 0.2, smoke_type = /datum/effect_system/fluid_spread/smoke/chem/quick)

/obj/item/hookah_coals
	name = "hookah coals"
	desc = "Плотные угольки, филигранно обработанные до состояния кубика."
	icon = 'modular_bandastation/bar_hookahs/icons/hookah.dmi'
	icon_state = "coals"
	custom_premium_price = PAYCHECK_CREW * 1.5
	w_class = WEIGHT_CLASS_SMALL

/obj/item/hookah_coals/examine()
	. = ..()
	. += span_info("В кучке три кубика.")

/obj/machinery/vending/cigarette/Initialize(mapload)
	premium += list(
		/obj/item/hookah_coals = 3,
	)
	. = ..()

/datum/supply_pack/misc/hookah_kit
	name = "Набор для кальяна"
	desc = "Комплект для любителей подымить и культурно расслабиться."
	cost = 200
	contains = list(
		/obj/item/hookah,
		/obj/item/hookah_coals = 3
	)
	crate_name = "ящик с набором для кальяна"

#undef INTERNAL_VOLUME
#undef MAX_FUEL
#undef FUEL_PER_COAL
#undef FUEL_CONSUME_INTERVAL
#undef SMOKE_CONSUME_INTERVAL
#undef SMOKE_CONSUME_AMOUNT
#undef INHALE_COOLDOWN
#undef BASE_COUGH_STAMINA_LOSS
#undef INHALE_STAMINA_LOSS
#undef BASE_INHALE_VOLUME
#undef BASE_INHALE_LIMIT
#undef MAX_FOOD_ITEMS
#undef RADIAL_CLEAR
#undef RADIAL_EXTINGUISH
#undef RADIAL_BLOW
#undef OPTION_CLEAR
#undef OPTION_EXTINGUISH
#undef OPTION_BLOW
