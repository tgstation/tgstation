// Ye old forbidden book, the Codex Cicatrix.
/obj/item/codex_cicatrix
	name = "Codex Cicatrix"
	desc = "Этот тяжелый том полон загадочных каракулей и невозможных диаграмм. \
	Согласно легенде, его можно расшифровать, чтобы раскрыть секреты завесы между мирами."
	icon = 'icons/obj/antags/eldritch.dmi'
	base_icon_state = "book"
	icon_state = "book"
	worn_icon_state = "book"
	w_class = WEIGHT_CLASS_SMALL
	/// Helps determine the icon state of this item when it's used on self.
	var/book_open = FALSE
	/// How fast we can drain influences
	var/drain_speed = 5 SECONDS
	/// How fast we can draw runes
	var/draw_speed = 8 SECONDS

/obj/item/codex_cicatrix/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "Вы убираете %THEEFFECT.", \
		tip_text = "Очистить руну", \
		on_clear_callback = CALLBACK(src, PROC_REF(after_clear_rune)), \
		effects_we_clear = list(/obj/effect/heretic_rune))

/// Callback for effect_remover component after a rune is deleted
/obj/item/codex_cicatrix/proc/after_clear_rune(obj/effect/target, mob/living/user)
	new /obj/effect/temp_visual/drawing_heretic_rune/fail(target.loc, target.greyscale_colors)

/obj/item/codex_cicatrix/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return

	. += span_notice("Может быть использован на разломах для получения дополнительных очков знаний.")
	. += span_notice("Упрощает начертание или удаление рун трансмутации.")
	. += span_notice("Также, может быть использован как фокусировка, когда находится в руках, но рекомендуется более специализированный для этого предмет, так как этот может выпасть во время боя.")

/obj/item/codex_cicatrix/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return

	if(book_open)
		close_animation()
		RemoveElement(/datum/element/heretic_focus)
		update_weight_class(WEIGHT_CLASS_SMALL)
	else
		open_animation()
		AddElement(/datum/element/heretic_focus)
		update_weight_class(WEIGHT_CLASS_NORMAL)

/obj/item/codex_cicatrix/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	if(!heretic_datum)
		return NONE
	if(isopenturf(interacting_with))
		var/obj/effect/heretic_influence/influence = locate(/obj/effect/heretic_influence) in interacting_with
		if(!influence?.drain_influence_with_codex(user, src))
			heretic_datum.try_draw_rune(user, interacting_with, drawing_time = draw_speed)
		return ITEM_INTERACT_BLOCKING
	return NONE

/// Plays a little animation that shows the book opening and closing.
/obj/item/codex_cicatrix/proc/open_animation()
	icon_state = "[base_icon_state]_open"
	flick("[base_icon_state]_opening", src)
	book_open = TRUE

/// Plays a closing animation and resets the icon state.
/obj/item/codex_cicatrix/proc/close_animation()
	icon_state = base_icon_state
	flick("[base_icon_state]_closing", src)
	book_open = FALSE

// Upgraded version of the codex cicatrix that allows us to cast curses
/obj/item/codex_cicatrix/morbus // I'm morbing all over
	name = "Codex Morbus"
	desc = "Омерзительная, истрёпанная книга, покрытая отдельно моргающими глазами, смотрящими на вас. Вы даже не представляете, как держать ЭТО - и откровенно говоря, не уверены что вам это хочется."
	base_icon_state = "book_morbus"
	icon_state = "book_morbus"
	drain_speed = 2.5 SECONDS
	draw_speed = 5 SECONDS
	/// List of mobs we've cursed with transmutation. When the codex is destroyed all those curses become undone
	var/list/transmuted_victims = list()

/obj/item/codex_cicatrix/morbus/examine(mob/user)
	. = ..()
	if(IS_HERETIC(user))
		. += span_info("Можно использовать для наложения проклятия с кровью жертвы в другой вашей руке, щёлкнув правой кнопкой мыши по руне.")
		return
	. += span_danger("Глаза перестают моргать. Они смотрят прямо на тебя. Их взгляд обжигает...")
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	to_chat(human_user, span_userdanger("Ваш разум пылает, когда вы смотрите на страницы!"))
	human_user.adjust_organ_loss(ORGAN_SLOT_BRAIN, 10, 190)
	human_user.add_mood_event("gates_of_mansus", /datum/mood_event/gates_of_mansus)

/obj/item/codex_cicatrix/morbus/examine_more(mob/user)
	. = ..() // XANTODO - Add a summary of each curse to the description so that the curser knows what will happen the cursee

/obj/item/codex_cicatrix/morbus/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/effect/heretic_rune/big))
		return NONE

	var/list/curse_list = list()
	for(var/datum/heretic_knowledge/curse/curses as anything in subtypesof(/datum/heretic_knowledge/curse))
		curse_list[curses.name] = curses
	var/selected_curse = tgui_input_list(user, "Наложить любое проклятие", "Выберите проклятие!", curse_list, timeout = 0)
	if(!selected_curse)
		return NONE

	if(!user.Adjacent(interacting_with))
		return NONE

	var/atom/held_offhand = user.get_inactive_held_item()
	if(!held_offhand)
		user.balloon_alert(user, "нет катализатора!")
		return
	var/blood_samples = list()
	for(var/blood in GET_ATOM_BLOOD_DNA(held_offhand))
		blood_samples[blood] = 1
	for(var/datum/reagent/blood/usable_reagent as anything in held_offhand.reagents?.reagent_list)
		if(!istype(usable_reagent, /datum/reagent/blood))
			continue
		blood_samples += usable_reagent.data["blood_DNA"]
	if(isnull(blood_samples))
		user.balloon_alert(user, "нет крови!")
		return ITEM_INTERACT_BLOCKING

	var/curse_type = curse_list[selected_curse]
	var/datum/heretic_knowledge/curse/to_cast = new curse_type
	to_cast.recipe_snowflake_check(user, list(held_offhand), loc = get_turf(user))
	to_cast.on_finished_recipe(user, list(src, held_offhand), loc = get_turf(user))
	return ITEM_INTERACT_SUCCESS

/obj/item/codex_cicatrix/morbus/atom_destruction(damage_flag)
	for(var/datum/weakref/to_uncurse_ref as anything in transmuted_victims)
		var/mob/to_uncurse = to_uncurse_ref.resolve()
		if(!to_uncurse || !ismob(to_uncurse))
			continue
		var/datum/heretic_knowledge/curse/transmutation/to_undo = new()
		to_undo.uncurse(to_uncurse)
		transmuted_victims -= to_uncurse_ref
	return ..()
