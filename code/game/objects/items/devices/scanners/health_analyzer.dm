// Describes the three modes of scanning available for health analyzers
#define SCANMODE_HEALTH 0
#define SCANMODE_WOUND 1
#define SCANMODE_COUNT 2 // Update this to be the number of scan modes if you add more

/obj/item/healthanalyzer
	name = "health analyzer"
	icon = 'icons/obj/devices/scanner.dmi'
	icon_state = "health"
	inhand_icon_state = "healthanalyzer"
	worn_icon_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "Ручной сканер тела, способный определять жизненно важные показатели объекта. Имеет боковую кнопку для сканирования на наличие химических веществ, а также функцию сканирования ран."
	obj_flags = CONDUCTS_ELECTRICITY
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT *2)
	interaction_flags_click = NEED_LITERACY|NEED_LIGHT|ALLOW_RESTING
	custom_price = PAYCHECK_COMMAND
	sound_vary = TRUE
	pickup_sound = SFX_GENERIC_DEVICE_PICKUP
	drop_sound = SFX_GENERIC_DEVICE_DROP
	/// Verbose/condensed
	var/mode = SCANNER_VERBOSE
	/// HEALTH/WOUND
	var/scanmode = SCANMODE_HEALTH
	/// Advanced health analyzer
	var/advanced = FALSE
	/// If this analyzer will give a bonus to wound treatments apon woundscan.
	var/give_wound_treatment_bonus = FALSE
	var/last_scan_text
	var/scanner_busy = FALSE
	/// Weakref to the last mob scanned by a health analyzer. Used to generate official medical reports.
	var/datum/weakref/last_healthy_scanned

/obj/item/healthanalyzer/Initialize(mapload)
	. = ..()
	register_item_context()

/obj/item/healthanalyzer/examine(mob/user)
	. = ..()
	if(src.mode != SCANNER_NO_MODE)
		. += span_notice("Alt+ЛКМ по [declent_ru(DATIVE)], чтобы переключить отображение повреждений конечностей. Ctrl+shift+ЛКМ чтобы распечатать отчёт.")

/obj/item/healthanalyzer/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user.declent_ru(NOMINATIVE)] начинает анализировать себя при помощи [declent_ru(GENITIVE)]! Дисплей показывает, что [user.ru_p_they()] мёртв!"))
	return BRUTELOSS

/obj/item/healthanalyzer/attack_self(mob/user)
	if(!user.can_read(src) || user.is_blind())
		return

	scanmode = (scanmode + 1) % SCANMODE_COUNT
	switch(scanmode)
		if(SCANMODE_HEALTH)
			to_chat(user, span_notice("Вы переключаете анализатор здоровья на проверку физического состояния."))
		if(SCANMODE_WOUND)
			to_chat(user, span_notice("Вы переключаете анализатор здоровья на отображение дополнительной информации о ранах."))

/obj/item/healthanalyzer/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE

	var/mob/living/M = interacting_with

	. = ITEM_INTERACT_SUCCESS

	flick("[icon_state]-scan", src) //makes it so that it plays the scan animation upon scanning, including clumsy scanning

	// Clumsiness/brain damage check
	if ((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(50))
		var/turf/scan_turf = get_turf(user)
		user.visible_message(
			span_warning("[user.declent_ru(NOMINATIVE)] анализирует жизненные показатели [scan_turf.declent_ru(GENITIVE)]!"),
			span_notice("Вы глупо пытаетесь проанализировать жизненные показатели [scan_turf.declent_ru(GENITIVE)]!"),
		)

		var/floor_text = "<span class='info'>Анализ результатов для <b>[scan_turf.declent_ru(GENITIVE)]</b> ([round_timestamp()]):</span><br>"
		floor_text += "<span class='info ml-1'>Общее состояние: <i>Неизвестно</i></span><br>"
		floor_text += "<span class='alert ml-1'>У субъекта отсутствует мозг.</span><br>"
		floor_text += "<span class='info ml-1'>Температура тела: [scan_turf?.return_air()?.return_temperature() || "???"]</span><br>"

		if(user.can_read(src) && !user.is_blind())
			to_chat(user, custom_boxed_message("blue_box", floor_text))
		last_scan_text = floor_text
		return

	if(ispodperson(M) && !advanced)
		to_chat(user, span_info("Биологическая структура [M.declent_ru(GENITIVE)] слишком сложна для анализатора здоровья."))
		return

	user.visible_message(span_notice("[user.declent_ru(NOMINATIVE)] анализирует жизненные показатели [M.declent_ru(GENITIVE)]."))
	balloon_alert(user, "анализ жизненных показателей")
	playsound(user.loc, 'sound/items/healthanalyzer.ogg', 50)

	var/readability_check = user.can_read(src) && !user.is_blind()
	switch (scanmode)
		if (SCANMODE_HEALTH)
			last_scan_text = healthscan(user, M, mode, advanced, tochat = readability_check)
			if((M.health / M.maxHealth) > CLEAN_BILL_OF_HEALTH_RATIO)
				last_healthy_scanned = WEAKREF(M)
			else
				last_healthy_scanned = null
		if (SCANMODE_WOUND)
			if(readability_check)
				woundscan(user, M, src)

	add_fingerprint(user)

/obj/item/healthanalyzer/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE
	if(user.can_read(src) && !user.is_blind())
		chemscan(user, interacting_with)
	return ITEM_INTERACT_SUCCESS

/obj/item/healthanalyzer/add_item_context(
	obj/item/source,
	list/context,
	atom/target,
)
	if (!isliving(target))
		return NONE

	switch (scanmode)
		if (SCANMODE_HEALTH)
			context[SCREENTIP_CONTEXT_LMB] = "Сканирование здоровья"
		if (SCANMODE_WOUND)
			context[SCREENTIP_CONTEXT_LMB] = "Сканирование травм"

	context[SCREENTIP_CONTEXT_RMB] = "Сканирование на химикаты"

	return CONTEXTUAL_SCREENTIP_SET

/**
 * healthscan
 * returns a list of everything a health scan should give to a player.
 * Examples of where this is used is Health Analyzer and the Physical Scanner tablet app.
 * Args:
 * user - The person with the scanner
 * target - The person being scanned
 * mode - Uses SCANNER_CONDENSED or SCANNER_VERBOSE to decide whether to give a list of all individual limb damage
 * advanced - Whether it will give more advanced details, such as husk source.
 * tochat - Whether to immediately post the result into the chat of the user, otherwise it will return the results.
 */
/proc/healthscan(mob/user, mob/living/target, mode = SCANNER_VERBOSE, advanced = FALSE, tochat = TRUE)
	if(user.incapacitated)
		return

	// the final list of strings to render
	var/list/render_list = list()

	// Damage specifics
	var/oxy_loss = target.get_oxy_loss()
	var/tox_loss = target.get_tox_loss()
	var/fire_loss = target.get_fire_loss()
	var/brute_loss = target.get_brute_loss()
	var/mob_status = (!target.appears_alive() ? span_alert("<b>Мёртв</b>") : "<b>[round(target.health / target.maxHealth, 0.01) * 100]% здоровья</b>")

	if(HAS_TRAIT(target, TRAIT_FAKEDEATH) && target.stat != DEAD)
		// if we don't appear to actually be in a "dead state", add fake oxyloss
		if(oxy_loss + tox_loss + fire_loss + brute_loss < 200)
			oxy_loss += 200 - (oxy_loss + tox_loss + fire_loss + brute_loss)
			oxy_loss = clamp(oxy_loss, 0, 200)

	render_list += "[span_info("Анализ результатов для <b>[target.declent_ru(GENITIVE)]</b> ([round_timestamp()]):")]<br><span class='info ml-1'>Общее состояние: [mob_status]</span><br>"

	if(!advanced && target.has_reagent(/datum/reagent/inverse/technetium))
		advanced = TRUE

	SEND_SIGNAL(target, COMSIG_LIVING_HEALTHSCAN, render_list, advanced, user, mode, tochat)

	// Husk detection
	if(HAS_TRAIT(target, TRAIT_HUSK))
		if(advanced)
			if(HAS_TRAIT_FROM(target, TRAIT_HUSK, CHANGELING_DRAIN))
				render_list += "<span class='alert ml-1'>Субъект был превращён в хаска [conditional_tooltip("поглощением", "Необратимо. При обычных обстоятельствах оживление возможно только путём пересадки мозга.", tochat)].</span><br>"
			else if(HAS_TRAIT_FROM(target, TRAIT_HUSK, SKELETON_TRAIT))
				render_list += "<span class='alert ml-1'>Субъект был превращён в хаска вследствие значительной потери мягких тканей.</span><br>"
			else if(!HAS_TRAIT_FROM(target, TRAIT_HUSK, BURN)) // prioritize showing unknown causes over burns
				render_list += "<span class='alert ml-1'>Субъект был превращён в хаска по мистическим причинам.</span><br>"
			else
				render_list += "<span class='alert ml-1'>Субъект был превращён в хаска вследствие [conditional_tooltip("сильных ожогов", "Обработайте ожоги и нанесите средство для обработки хасков, например [/datum/reagent/medicine/c2/synthflesh::name].", tochat)].</span><br>"

		else
			render_list += "<span class='alert ml-1'>Субъект был превращён в хаска.</span><br>"

	if(target.get_stamina_loss())
		if(advanced)
			render_list += "<span class='alert ml-1'>Уровень усталости: [target.get_stamina_loss()]%.</span><br>"
		else
			render_list += "<span class='alert ml-1'>Субъект страдает от переутомления.</span><br>"

	// Check for brain - both organic (carbon) and synthetic (cyborg MMI)
	var/has_brain = FALSE
	if(target.get_organ_slot(ORGAN_SLOT_BRAIN))
		has_brain = TRUE
	else if(iscyborg(target))
		var/mob/living/silicon/robot/cyborg_target = target
		if(cyborg_target.mmi?.brain)
			has_brain = TRUE

	if(!has_brain) // kept exclusively for soul purposes
		render_list += "<span class='alert ml-1'>У субъекта отсутствует развитый мозг.</span><br>"

	if(iscarbon(target))
		var/mob/living/carbon/carbontarget = target
		if(LAZYLEN(carbontarget.quirks))
			render_list += "<span class='info ml-1'>Значительные отклонения субъекта: [carbontarget.get_quirk_string(FALSE, CAT_QUIRK_MAJOR_DISABILITY, from_scan = TRUE)].</span><br>"
			if(advanced)
				render_list += "<span class='info ml-1'>Незначительные отклонения субъекта: [carbontarget.get_quirk_string(FALSE, CAT_QUIRK_MINOR_DISABILITY, TRUE)].</span><br>"

	// Body part damage report
	if(iscarbon(target))
		var/mob/living/carbon/carbontarget = target
		var/any_damage = brute_loss > 0 || fire_loss > 0 || oxy_loss > 0 || tox_loss > 0 || fire_loss > 0
		var/any_missing = length(carbontarget.get_missing_limbs())
		var/any_wounded = length(carbontarget.all_wounds)
		var/any_embeds = carbontarget.has_embedded_objects()
		if(any_damage || (mode == SCANNER_VERBOSE && (any_missing || any_wounded || any_embeds)))
			render_list += "<hr>"
			var/dmgreport = "<span class='info ml-1'>Состояние тела:</span>\
							<font face='Verdana'>\
							<table class='ml-2'>\
							<tr>\
							<td style='width:7em;'><font color='#ff0000'><b>Урон:</b></font></td>\
							<td style='width:5em;'><font color='#ff3333'><b>Ушибы</b></font></td>\
							<td style='width:4em;'><font color='#ff9933'><b>Ожоги</b></font></td>\
							<td style='width:4em;'><font color='#00cc66'><b>Токсины</b></font></td>\
							<td style='width:8em;'><font color='#00cccc'><b>Удушье</b></font></td>\
							</tr>\
							<tr>\
							<td><font color='#ff3333'><b>Общий:</b></font></td>\
							<td><font color='#ff3333'><b>[ceil(brute_loss)]</b></font></td>\
							<td><font color='#ff9933'><b>[ceil(fire_loss)]</b></font></td>\
							<td><font color='#00cc66'><b>[ceil(tox_loss)]</b></font></td>\
							<td><font color='#33ccff'><b>[ceil(oxy_loss)]</b></font></td>\
							</tr>"

			if(mode == SCANNER_VERBOSE)
				// Follow same body zone list every time so it's consistent across all humans
				for(var/zone in carbontarget.get_all_limbs())
					var/obj/item/bodypart/limb = carbontarget.get_bodypart(zone)
					if(isnull(limb))
						dmgreport += "<tr>"
						dmgreport += "<td><font color='#cc3333'>[capitalize(parse_zone(zone))]:</font></td>"
						dmgreport += "<td><font color='#cc3333'>-</font></td>"
						dmgreport += "<td><font color='#ff9933'>-</font></td>"
						dmgreport += "</tr>"
						dmgreport += "<tr><td colspan=6><span class='alert ml-2'>&rdsh; Физическая травма: [conditional_tooltip("Ампутирована", "Переприсоединить или заменить хирургическим путем.", tochat)]</span></td></tr>"
						continue
					var/has_any_embeds = LAZYLEN(limb.embedded_objects) >= 1
					var/has_any_wounds = length(limb.wounds) >= 1
					var/is_damaged = limb.burn_dam > 0 || limb.brute_dam > 0
					if(!is_damaged && (zone != BODY_ZONE_CHEST || (tox_loss <= 0 && oxy_loss <= 0)) && !has_any_embeds && !has_any_wounds)
						continue
					dmgreport += "<tr>"
					dmgreport += "<td><font color='#cc3333'>[capitalize((limb.bodytype & BODYTYPE_ROBOTIC) ? limb.name : limb.plaintext_zone)]:</font></td>"
					dmgreport += "<td><font color='#cc3333'>[limb.brute_dam > 0 ? ceil(limb.brute_dam) : "0"]</font></td>"
					dmgreport += "<td><font color='#ff9933'>[limb.burn_dam > 0 ? ceil(limb.burn_dam) : "0"]</font></td>"
					if(zone == BODY_ZONE_CHEST) // tox/oxy is stored in the chest
						dmgreport += "<td><font color='#00cc66'>[tox_loss > 0 ? ceil(tox_loss) : "0"]</font></td>"
						dmgreport += "<td><font color='#33ccff'>[oxy_loss > 0 ? ceil(oxy_loss) : "0"]</font></td>"
					dmgreport += "</tr>"
					if(has_any_embeds)
						var/list/embedded_names = list()
						for(var/obj/item/embed as anything in limb.embedded_objects)
							embedded_names[capitalize(embed.name)] += 1
						for(var/embedded_name in embedded_names)
							var/displayed = embedded_name
							var/embedded_amt = embedded_names[embedded_name]
							if(embedded_amt > 1)
								displayed = "[embedded_amt]x [embedded_name]"
							dmgreport += "<tr><td colspan=6><span class='alert ml-2'>&rdsh; Инородные объекты: [conditional_tooltip(displayed, "Используйте гемостат для извлечения.", tochat)]</span></td></tr>"
					if(has_any_wounds)
						for(var/datum/wound/wound as anything in limb.wounds)
							dmgreport += "<tr><td colspan=6><span class='alert ml-2'>&rdsh; Физическая травма: [conditional_tooltip("[wound.name] ([wound.severity_text()])", wound.treat_text_short, tochat)]</span></td></tr>"

			dmgreport += "</table></font>"
			render_list += dmgreport // tables do not need extra linebreak

	if(ishuman(target))
		var/mob/living/carbon/human/humantarget = target

		// Organ damage, missing organs
		var/render = FALSE
		var/toReport = "<span class='info ml-1'>Состояние органов:</span>\
			<font face='Verdana'>\
			<table class='ml-2'>\
			<tr>\
			<td style='width:8em;'><font color='#ff0000'><b>Орган:</b></font></td>\
			[advanced ? "<td style='width:4em;'><font color='#ff0000'><b>Урон</b></font></td>" : ""]\
			<td style='width:30em;'><font color='#ff0000'><b>Состояние</b></font></td>\
			</tr>"

		var/list/missing_organs = humantarget.get_missing_organs()
		// Follow same order as in the organ_process_order so it's consistent across all humans
		for(var/sorted_slot in GLOB.organ_process_order)
			var/obj/item/organ/organ = humantarget.get_organ_slot(sorted_slot)
			if(isnull(organ))
				if(missing_organs[sorted_slot])
					render = TRUE
					toReport += "<tr><td><font color='#cc3333'>[missing_organs[sorted_slot]]:</font></td>\
						[advanced ? "<td><font color='#ff3333'>-</font></td>" : ""]\
						<td><font color='#cc3333'>Отсутствует</font></td></tr>"
				continue
			if(mode != SCANNER_VERBOSE && !organ.show_on_condensed_scans())
				continue
			var/status = organ.get_status_text(advanced, tochat)
			var/appendix = organ.get_status_appendix(advanced, tochat)
			if(status || appendix)
				status ||= "<font color='#ffcc33'>OK</font>" // otherwise flawless organs have no status reported by default
				render = TRUE
				toReport += "<tr>\
					<td><font color='#cc3333'>[capitalize(organ.name)]:</font></td>\
					[advanced ? "<td><font color='#ff3333'>[organ.damage > 0 ? ceil(organ.damage) : "0"]</font></td>" : ""]\
					<td>[status]</td>\
					</tr>"
				if(appendix)
					toReport += "<tr><td colspan=4><span class='alert ml-2'>&rdsh; [appendix]</span></td></tr>"

		if(render)
			render_list += "<hr>"
			render_list += toReport + "</table></font>" // tables do not need extra linebreak

		// Cybernetics & mutant
		var/mutant = HAS_TRAIT(humantarget, TRAIT_HULK)
		var/list/cyberimps
		for(var/obj/item/organ/target_organ as anything in humantarget.organs)
			if(IS_ROBOTIC_ORGAN(target_organ) && !(target_organ.organ_flags & ORGAN_HIDDEN))
				LAZYADD(cyberimps, target_organ.examine_title(user))
			if(target_organ.organ_flags & ORGAN_MUTANT)
				mutant = TRUE
		if(LAZYLEN(cyberimps))
			if(!render)
				render_list += "<hr>"
			render_list += "<span class='notice ml-1'>Обнаруженные кибернетические модификации:</span><br>"
			render_list += "<span class='notice ml-2'>[english_list(cyberimps, and_text = ", и ")]</span><br>"

		render_list += "<hr>"

		//Genetic stability
		if(advanced && humantarget.has_dna() && humantarget.dna.stability != initial(humantarget.dna.stability))
			render_list += "<span class='info ml-1'>Генетическая стабильность: [humantarget.dna.stability]%.</span><br>"

		//body temperature
		var/datum/species/targetspecies = humantarget.dna.species
		var/disguised = !ishumanbasic(humantarget) && istype(humantarget.head, /obj/item/clothing/head/hooded/human_head) && istype(humantarget.wear_suit, /obj/item/clothing/suit/hooded/bloated_human)
		var/species_name = "[disguised ? "\"[/datum/species/human::name]\"" : targetspecies.name][mutant ? "-мутант" : ""]"

		render_list += "<span class='info ml-1'>Вид: [species_name]</span><br>"
		var/core_temperature_message = "Внутренняя температура тела: [round(humantarget.coretemperature-T0C, 0.1)] &deg;C ([round(humantarget.coretemperature*1.8-459.67,0.1)] &deg;F)"
		if(humantarget.coretemperature >= humantarget.get_body_temp_heat_damage_limit())
			render_list += "<span class='alert ml-1'>☼ [core_temperature_message] ☼</span><br>"
		else if(humantarget.coretemperature <= humantarget.get_body_temp_cold_damage_limit())
			render_list += "<span class='alert ml-1'>❄ [core_temperature_message] ❄</span><br>"
		else
			render_list += "<span class='info ml-1'>[core_temperature_message]</span><br>"

	var/body_temperature_message = "Температура тела: [round(target.bodytemperature-T0C, 0.1)] &deg;C ([round(target.bodytemperature*1.8-459.67,0.1)] &deg;F)"
	if(target.bodytemperature >= target.get_body_temp_heat_damage_limit())
		render_list += "<span class='alert ml-1'>☼ [body_temperature_message] ☼</span><br>"
	else if(target.bodytemperature <= target.get_body_temp_cold_damage_limit())
		render_list += "<span class='alert ml-1'>❄ [body_temperature_message] ❄</span><br>"
	else
		render_list += "<span class='info ml-1'>[body_temperature_message]</span><br>"

	// Blood Level
	var/datum/blood_type/blood_type = target.get_bloodtype()
	if(blood_type)
		var/cached_blood_volume = target.get_blood_volume(apply_modifiers = TRUE)
		var/blood_percent = round((cached_blood_volume / BLOOD_VOLUME_NORMAL) * 100)
		var/blood_type_format
		var/level_format
		if(cached_blood_volume <= BLOOD_VOLUME_SAFE && cached_blood_volume > BLOOD_VOLUME_OKAY)
			level_format = "НИЗКИЙ [blood_percent]%, [cached_blood_volume] сл"
			if (blood_type.restoration_chem)
				level_format = conditional_tooltip(level_format, "Рекомендация: приём [blood_type.restoration_chem::name].", tochat)
		else if(cached_blood_volume <= BLOOD_VOLUME_OKAY)
			level_format = "<b>КРИТИЧЕСКИЙ [blood_percent]%</b>, [cached_blood_volume] сл"
			var/recommendation = list()
			if (blood_type.restoration_chem)
				recommendation += "ввод [blood_type.restoration_chem::name]"
			if (blood_type.restoration_chem == /datum/reagent/iron)
				recommendation += "[/datum/reagent/medicine/salglu_solution::name]"
			if (length(recommendation))
				recommendation += "переливание [blood_type.get_blood_name()]"
			else
				recommendation += "немедленное переливание [blood_type.get_blood_name()]"
			level_format = conditional_tooltip(level_format, "Рекомендация: [english_list(recommendation, and_text = " или ")].", tochat)
		else
			level_format = "[blood_percent]%, [cached_blood_volume] сл"

		if (blood_type.get_type())
			blood_type_format = "группа крови: [blood_type.get_type()]"
			if(tochat && length(blood_type.compatible_types))
				var/list/compatible_types_readable = list()
				for(var/datum/blood_type/comp_blood_type as anything in blood_type.compatible_types)
					compatible_types_readable |= initial(comp_blood_type.name)
				blood_type_format = span_tooltip("Совместимые группы [english_list(compatible_types_readable)].", blood_type_format)

		render_list += "<span class='[cached_blood_volume < BLOOD_VOLUME_SAFE ? "alert" : "info"] ml-1'>Уровень [blood_type.get_blood_name()]: [level_format],</span> <span class='info'>[blood_type_format]</span><br>"

	var/blood_alcohol_content = target.get_blood_alcohol_content()
	if(blood_alcohol_content > 0)
		if(blood_alcohol_content >= 0.24)
			// "Oil alcohol content" is kinda funny if you think about it from a technical standpoint
			render_list += "<span class='alert ml-1'>Содержание алкоголя в [blood_type?.get_blood_name() || "Blood"]: <b>КРИТИЧЕСКИЙ [blood_alcohol_content]%</b></span><br>"
		else
			render_list += "Содержание алкоголя в [blood_type?.get_blood_name() || "Blood"]: [blood_alcohol_content]%</span><br>"

	//Diseases
	var/disease_hr = FALSE
	for(var/datum/disease/disease as anything in target.diseases)
		if(disease.visibility_flags & HIDDEN_SCANNER)
			continue
		if(!disease_hr)
			render_list += "<hr>"
			disease_hr = TRUE
		var/cure_text
		if(istype(disease, /datum/disease/advance))
			var/datum/disease/advance/advanced_disease = disease
			var/remedies = list()
			var/remedy_limit = advanced ? 3 : 2
			for(var/datum/symptom/each_symptom as anything in advanced_disease.symptoms)
				if(!each_symptom.symptom_cure)
					continue
				var/datum/reagent/each_cure = each_symptom.symptom_cure
				if(!each_symptom.neutered && !(each_cure::name in remedies))
					remedies += each_cure::name
				if(length(remedies) >= remedy_limit)
					break
			cure_text = english_list(remedies, nothing_text = "Nothing")
		else
			cure_text = disease.cure_text
		render_list += "<span class='alert ml-1'>\
			<b>Внимание: [disease.form]</b><br>\
			<div class='ml-2'>\
			Название: [disease.name].<br>\
			Распространение: [disease.spread_text].<br>\
			Стадия: [disease.stage]/[disease.max_stages].<br>\
			Возможное лекарство: [cure_text]</div>\
			</span>"

	// Time of death
	if(target.station_timestamp_timeofdeath && !target.appears_alive())
		render_list += "<hr>"
		render_list += "<span class='info ml-1'>Время смерти: [target.station_timestamp_timeofdeath]</span><br>"
		render_list += "<span class='alert ml-1'><b>Субъект умер [DisplayTimeText(round(world.time - target.timeofdeath))] назад.</b></span><br>"

	. = jointext(render_list, "")
	if(tochat)
		to_chat(user, custom_boxed_message("blue_box", .), trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)
	return .

/obj/item/healthanalyzer/click_ctrl_shift(mob/user)
	. = ..()
	if(!LAZYLEN(last_scan_text))
		balloon_alert(user, "нет анализов!")
		return
	if(scanner_busy)
		balloon_alert(user, "анализатор занят!")
		return
	scanner_busy = TRUE
	balloon_alert(user, "печать отчёта...")
	addtimer(CALLBACK(src, PROC_REF(print_report), user), 2 SECONDS)

/obj/item/healthanalyzer/proc/print_report(mob/user)
	var/obj/item/paper/medical_report/report_paper = new(get_turf(src))

	report_paper.color = "#99ccff"
	report_paper.name = "Отчет сканирования здоровья - [server_timestamp(format = "hh:mm", ic_time = TRUE)]"
	var/report_text = "<center><B>Отчет сканирования здоровья</br>\
		Время сканирования: [UNDERLINED_HTML_TEXT("[server_timestamp(format = "hh:mm", ic_time = TRUE)]", "Время смены: [round_timestamp(format = "hh:mm")]")]</B></center><HR>"
	report_text += last_scan_text

	report_paper.add_raw_text(report_text, advanced_html = TRUE)
	report_paper.update_appearance()

	user.put_in_hands(report_paper)
	balloon_alert(user, "логи очищены")

	resolve_patient_eligibility(report_paper, user)
	report_text = list()
	scanner_busy = FALSE

/**
 * Checks the mob and the medical report that the scanner is trying to print, checks the traits and statuses of the mob, and then resolves by true or false.
 * Applies traits to the patient if the scanning is eligable to turn in for a bounty, with callbacks to remove after a cooldown.
 */
/obj/item/healthanalyzer/proc/resolve_patient_eligibility(obj/item/paper/medical_report/report_paper, mob/scanner)
	var/mob/living/patient = last_healthy_scanned?.resolve()
	if(!patient)
		return FALSE

	if(scanner == patient)
		return FALSE //You can't just scan yourself.

	if(HAS_TRAIT(patient, TRAIT_RECENTLY_TREATED))
		return FALSE

	report_paper.last_healthy_scanned_mob = last_healthy_scanned
	ADD_TRAIT(patient, TRAIT_RECENTLY_TREATED, ANALYZER_TRAIT)
	addtimer(TRAIT_CALLBACK_REMOVE(patient, RECENTLY_HEALED_COOLDOWN, ANALYZER_TRAIT), RECENTLY_HEALED_COOLDOWN)
	return TRUE

/obj/item/healthanalyzer/proc/clear_treatment(mob/living/target)
	if(!target)
		return
	if(QDELETED(target))
		return
	REMOVE_TRAIT(target, TRAIT_RECENTLY_TREATED, ANALYZER_TRAIT)
	return TRUE

/proc/chemscan(mob/living/user, mob/living/target, reagent_types_to_check = null, tochat = TRUE)
	if(user.incapacitated)
		return

	if(istype(target) && target.reagents)
		var/list/render_list = list() //The master list of readouts, including reagents in the blood/stomach, addictions, quirks, etc.
		var/list/render_block = list() //A second block of readout strings. If this ends up empty after checking stomach/blood contents, we give the "empty" header.

		// Blood reagents
		if(target.reagents.reagent_list.len)
			for(var/r in target.reagents.reagent_list)
				var/datum/reagent/reagent = r
				if(reagent.chemical_flags & REAGENT_INVISIBLE) //Don't show hidden chems on scanners
					continue
				if(reagent_types_to_check)
					if(!istype(reagent, reagent_types_to_check))
						continue
				render_block += "<span class='notice ml-2'>[round(reagent.volume, 0.001)] юнитов [reagent.name][reagent.overdosed ? "</span> - [span_bolddanger("ПЕРЕДОЗИРОВКА")]" : ".</span>"]<br>"

		if(!length(render_block)) //If no VISIBLY DISPLAYED reagents are present, we report as if there is nothing.
			render_list += "<span class='notice ml-1'>Субъект не содержит реагенты в кровотоке.</span><br>"
		else
			render_list += "<span class='notice ml-1'>Субъект содержит следующие реагенты в кровотоке:</span><br>"
			render_list += render_block //Otherwise, we add the header, reagent readouts, and clear the readout block for use on the stomach.
			render_block.Cut()

		// Stomach reagents
		var/obj/item/organ/stomach/belly = target.get_organ_slot(ORGAN_SLOT_STOMACH)
		if(belly)
			if(belly.reagents.reagent_list.len)
				for(var/bile in belly.reagents.reagent_list)
					var/datum/reagent/bit = bile
					if(bit.chemical_flags & REAGENT_INVISIBLE)
						continue
					if(reagent_types_to_check)
						if(!istype(bit, reagent_types_to_check))
							continue
					if(!belly.food_reagents[bit.type])
						render_block += "<span class='notice ml-2'>[round(bit.volume, 0.001)] юнитов [bit.name][bit.overdosed ? "</span> - [span_bolddanger("ПЕРЕДОЗИРОВКА")]" : ".</span>"]<br>"
					else
						var/bit_vol = bit.volume - belly.food_reagents[bit.type]
						if(bit_vol > 0)
							render_block += "<span class='notice ml-2'>[round(bit_vol, 0.001)] юнитов [bit.name][bit.overdosed ? "</span> - [span_bolddanger("ПЕРЕДОЗИРОВКА")]" : ".</span>"]<br>"

			if(!length(render_block))
				render_list += "<span class='notice ml-1'>Субъект не содержит реагенты в желудке.</span><br>"
			else
				render_list += "<span class='notice ml-1'>Субъект содержит следующие реагенты в желудке:</span><br>"
				render_list += render_block

		// Addictions
		if(LAZYLEN(target.mind?.active_addictions))
			render_list += "<span class='boldannounce ml-1'>Субъект зависим от следующих видов наркотиков:</span><br>"
			for(var/datum/addiction/addiction_type as anything in target.mind.active_addictions)
				render_list += "<span class='alert ml-2'>[initial(addiction_type.name)]</span><br>"

		// Special eigenstasium addiction
		if(target.has_status_effect(/datum/status_effect/eigenstasium))
			render_list += "<span class='notice ml-1'>Субъект временно нестабилен. Для уменьшения нарушений в организме рекомендуется использовать стабилизирующий агент.</span><br>"

		// Allergies
		for(var/datum/quirk/quirky as anything in target.quirks)
			if(istype(quirky, /datum/quirk/item_quirk/allergic))
				var/datum/quirk/item_quirk/allergic/allergies_quirk = quirky
				var/allergies = allergies_quirk.allergy_string
				render_list += "<span class='alert ml-1'>У субъекта сильная аллергия на следующие химические вещества:</span><br>"
				render_list += "<span class='alert ml-2'>[allergies]</span><br>"

		// we handled the last <br> so we don't need handholding
		if(tochat)
			to_chat(user, custom_boxed_message("blue_box", jointext(render_list, "")), trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)
		else
			return jointext(render_list, "")

/obj/item/healthanalyzer/click_alt(mob/user)
	if(mode == SCANNER_NO_MODE)
		return CLICK_ACTION_BLOCKING

	mode = !mode
	to_chat(user, mode == SCANNER_VERBOSE ? "Теперь сканер показывает конкретные повреждения конечностей." : "Сканер больше не показывает повреждения конечностей.")
	return CLICK_ACTION_SUCCESS

/obj/item/healthanalyzer/advanced
	name = "advanced health analyzer"
	icon_state = "health_adv"
	desc = "Ручной сканер тела, способный с высокой точностью определять жизненно важные показатели субъекта."
	advanced = TRUE

#define AID_EMOTION_NEUTRAL "neutral"
#define AID_EMOTION_HAPPY "happy"
#define AID_EMOTION_WARN "warn"
#define AID_EMOTION_ANGRY "angry"
#define AID_EMOTION_SAD "sad"

/// Displays wounds with extended information on their status vs medscanners
/proc/woundscan(mob/user, mob/living/carbon/patient, obj/item/healthanalyzer/scanner, simple_scan = FALSE)
	if(!istype(patient) || user.incapacitated)
		return

	var/render_list = ""
	var/advised = FALSE
	for(var/limb in patient.get_wounded_bodyparts())
		var/obj/item/bodypart/wounded_part = limb
		render_list += "<span class='alert ml-1'><b>ВНИМАНИЕ: Физическ[LAZYLEN(wounded_part.wounds) > 1? "ие травмы обнаружены" : "ая травма обнаружена"]  в [wounded_part.declent_ru(PREPOSITIONAL)]</b>"
		for(var/limb_wound in wounded_part.wounds)
			var/datum/wound/current_wound = limb_wound
			render_list += "<div class='ml-2'>[simple_scan ? current_wound.get_simple_scanner_description() : current_wound.get_scanner_description()]</div><br>"
			if (scanner.give_wound_treatment_bonus)
				ADD_TRAIT(current_wound, TRAIT_WOUND_SCANNED, ANALYZER_TRAIT)
				if(!advised)
					to_chat(user, span_notice("Вы замечаете, как над вами появляются яркие голографические изображения [(length(wounded_part.wounds) || length(patient.get_wounded_bodyparts()) ) > 1 ? "различных ран" : "ран"]. Похоже, они содержат полезную информацию, которая должна облегчить лечение!"))
					advised = TRUE
		render_list += "</span>"

	if(render_list == "")
		if(simple_scan)
			var/obj/item/healthanalyzer/simple/simple_scanner = scanner
			// Only emit the cheerful scanner message if this scan came from a scanner
			playsound(simple_scanner, 'sound/machines/ping.ogg', 50, FALSE)
			to_chat(user, span_notice("[capitalize(simple_scanner.declent_ru(NOMINATIVE))] радостно пикает и на короткое время показывает смайлик с несколькими восклицательными знаками! Он рад сообщить, что [patient] не имеет ран!"))
			simple_scanner.show_emotion(AID_EMOTION_HAPPY)
		to_chat(user, "<span class='notice ml-1'>У субъекта не обнаружено ранений.</span>")
	else
		to_chat(user, custom_boxed_message("blue_box", jointext(render_list, "")), type = MESSAGE_TYPE_INFO)
		if(simple_scan)
			var/obj/item/healthanalyzer/simple/simple_scanner = scanner
			simple_scanner.show_emotion(AID_EMOTION_WARN)
			playsound(simple_scanner, 'sound/machines/beep/twobeep.ogg', 50, FALSE)


/obj/item/healthanalyzer/simple
	name = "wound analyzer"
	icon_state = "first_aid"
	desc = "Полезный, защищённый от детей и, что самое важное, очень дешёвый медицинский сканер MeLo-Tech используется для диагностики травм и назначения лечения при серьёзных ранениях. Хотя может показаться, что он не даёт никакой информации, кроме того, есть ли у вас в теле зияющая дыра, он накладывает на рану временное голографическое изображение с информацией, которая гарантированно удвоит эффективность и скорость лечения."
	mode = SCANNER_NO_MODE
	give_wound_treatment_bonus = TRUE

	/// Cooldown for when the analyzer will allow you to ask it for encouragement. Don't get greedy!
	var/next_encouragement
	/// The analyzer's current emotion. Affects the sprite overlays and if it's going to prick you for being greedy or not.
	var/emotion = AID_EMOTION_NEUTRAL
	/// Encouragements to play when attack_selfing
	var/list/encouragements = list("на короткое время появляется счастливое лицо, которое безучастно смотрит на вас", "на короткое время появляется вращающееся нарисованное сердце", "на экране появляется воодушевляющее сообщение о здоровом питании и физических упражнениях", \
			"напоминает вам, что каждый старается изо всех сил", "выводит на экран сообщение с пожеланием удачи", "выражает искреннюю благодарность за ваш интерес к оказанию первой помощи", "официально освобождает вас от всех ваших грехов")
	/// How often one can ask for encouragement
	var/patience = 10 SECONDS
	/// What do we scan for, only used in descriptions
	var/scan_for_what = "серьёзные увечья"

/obj/item/healthanalyzer/simple/attack_self(mob/user)
	if(next_encouragement < world.time)
		playsound(src, 'sound/machines/ping.ogg', 50, FALSE)
		to_chat(user, span_notice("[capitalize(declent_ru(NOMINATIVE))] издает радостный звуковой сигнал и [pick(encouragements)]!"))
		next_encouragement = world.time + 10 SECONDS
		show_emotion(AID_EMOTION_HAPPY)
	else if(emotion != AID_EMOTION_ANGRY)
		greed_warning(user)
	else
		violence(user)

/obj/item/healthanalyzer/simple/proc/greed_warning(mob/user)
	to_chat(user, span_warning("На экране [declent_ru(GENITIVE)] появляется лицо пугающе высокого разрешения, упрекающее вас за то, что вы просите слишком настойчиво."))
	show_emotion(AID_EMOTION_ANGRY)

/obj/item/healthanalyzer/simple/proc/violence(mob/user)
	playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 50, FALSE)
	if(isliving(user))
		var/mob/living/L = user
		to_chat(L, span_warning("[capitalize(declent_ru(NOMINATIVE))] разочарованно жужжит и колет вас за жадность. Ай!"))
		flick(icon_state + "_pinprick", src)
		violence_damage(user)
		user.dropItemToGround(src)
		show_emotion(AID_EMOTION_HAPPY)

/obj/item/healthanalyzer/simple/proc/violence_damage(mob/living/user)
	user.adjust_brute_loss(4)

/obj/item/healthanalyzer/simple/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE
	if(!user.can_read(src) || user.is_blind())
		return ITEM_INTERACT_BLOCKING

	add_fingerprint(user)
	user.visible_message(
		span_notice("[user] сканирует [interacting_with.declent_ru(ACCUSATIVE)] на [scan_for_what]."),
		span_notice("Вы сканируете [interacting_with.declent_ru(ACCUSATIVE)] на [scan_for_what]."),
	)

	if(!iscarbon(interacting_with))
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 30, TRUE)
		to_chat(user, span_notice("[capitalize(declent_ru(NOMINATIVE))] издает печальное жужжание и на короткое время показывает грустное лицо, показывая, что не может выполнить сканирование [interacting_with]."))
		show_emotion(AI_EMOTION_SAD)
		return ITEM_INTERACT_BLOCKING

	do_the_scan(interacting_with, user)
	flick(icon_state + "_pinprick", src)
	update_appearance(UPDATE_OVERLAYS)
	return ITEM_INTERACT_SUCCESS

/obj/item/healthanalyzer/simple/proc/do_the_scan(mob/living/carbon/scanning, mob/living/user)
	woundscan(user, scanning, src, simple_scan = TRUE)

/obj/item/healthanalyzer/simple/update_overlays()
	. = ..()
	switch(emotion)
		if(AID_EMOTION_HAPPY)
			. += mutable_appearance(icon, "+no_wounds")
		if(AID_EMOTION_WARN)
			. += mutable_appearance(icon, "+wound_warn")
		if(AID_EMOTION_ANGRY)
			. += mutable_appearance(icon, "+angry")
		if(AID_EMOTION_SAD)
			. += mutable_appearance(icon, "+fail_scan")

/// Sets a new emotion display on the scanner, and resets back to neutral in a moment
/obj/item/healthanalyzer/simple/proc/show_emotion(new_emotion)
	emotion = new_emotion
	update_appearance(UPDATE_OVERLAYS)
	if (emotion != AID_EMOTION_NEUTRAL)
		addtimer(CALLBACK(src, PROC_REF(reset_emotions), AID_EMOTION_NEUTRAL), 2 SECONDS)

// Resets visible emotion back to neutral
/obj/item/healthanalyzer/simple/proc/reset_emotions()
	emotion = AID_EMOTION_NEUTRAL
	update_appearance(UPDATE_OVERLAYS)

/obj/item/healthanalyzer/simple/miner
	name = "mining wound analyzer"
	icon_state = "miner_aid"
	desc = "Полезный, защищённый от детей и, что самое важное, очень дешёвый медицинский сканер MeLo-Tech, который используется для диагностики травм и назначения лечения при серьёзных ранениях. Хотя может показаться, что он не так уж информативен, ведь он может лишь сказать, есть ли у вас в теле зияющая дыра или нет, он накладывает на рану временное голографическое изображение с информацией, которая гарантированно удвоит эффективность и скорость лечения. У этого сканера крутая эстетичная антенна, которая на самом деле ничего не делает!"

/obj/item/healthanalyzer/simple/disease
	name = "disease state analyzer"
	desc = "Ещё один из сомнительно полезных медико‑научных сканеров компании MeLo-Tech — анализатор заболеваний. В наши дни они встречаются довольно редко: NT выяснила, что оснащение больниц самым дешёвым пандемическим оборудованием привело к чрезмерным человеческим потерям, что оказалось невыгодным. Ходят слухи, что встроенный ИИ завидует успеху анализатора первой помощи."
	icon_state = "disease_aid"
	mode = SCANNER_NO_MODE
	encouragements = list("мотивирует вас принимать лекарства", "на короткое время появляется вращающееся нарисованное сердце", "успокаивает вас относительно вашего состояния", \
			"напоминает вам, что каждый старается изо всех сил", "выводит на экран сообщение с пожеланием удачи", "отображает сообщение о том, как оно гордится тем, что вы заботитесь о себе.", "официально освобождает вас от всех ваших грехов")
	patience = 20 SECONDS
	scan_for_what = "болезни"

/obj/item/healthanalyzer/simple/disease/violence_damage(mob/living/user)
	user.adjust_brute_loss(1)
	user.reagents.add_reagent(/datum/reagent/toxin, rand(1, 3))

/obj/item/healthanalyzer/simple/disease/do_the_scan(mob/living/carbon/scanning, mob/living/user)
	diseasescan(user, scanning, src)

/obj/item/healthanalyzer/simple/disease/update_overlays()
	. = ..()
	switch(emotion)
		if(AID_EMOTION_HAPPY)
			. += mutable_appearance(icon, "+not_infected")
		if(AID_EMOTION_WARN)
			. += mutable_appearance(icon, "+infected")
		if(AID_EMOTION_ANGRY)
			. += mutable_appearance(icon, "+rancurous")
		if(AID_EMOTION_SAD)
			. += mutable_appearance(icon, "+unknown_scan")
	if(emotion != AID_EMOTION_NEUTRAL)
		addtimer(CALLBACK(src, PROC_REF(reset_emotions)), 4 SECONDS) // longer on purpose

/// Checks the individual for any diseases that are visible to the scanner, and displays the diseases in the attacked to the attacker.
/proc/diseasescan(mob/user, mob/living/carbon/patient, obj/item/healthanalyzer/simple/scanner)
	if(!istype(patient) || user.incapacitated)
		return

	var/list/render = list()
	for(var/datum/disease/disease as anything in patient.diseases)
		if(!(disease.visibility_flags & HIDDEN_SCANNER))
			var/disease_cure = disease.cure_text
			if(istype(disease, /datum/disease/advance))
				var/datum/disease/advance/advanced_disease = disease
				for(var/datum/symptom/each_symptom as anything in advanced_disease.symptoms)
					if(!each_symptom.neutered && each_symptom.symptom_cure)
						var/datum/reagent/each_cure = each_symptom.symptom_cure
						disease_cure = each_cure::name
						break // We only get one
			render += "<span class='alert ml-1'><b>Внимание: [disease.form]</b><br>\
			<div class='ml-2'>Имя: [disease.name].<br>Распространение: [disease.spread_text].<br>Стадия: [disease.stage]/[disease.max_stages].<br>Возможное лекарство: [disease_cure]</div>\
			</span>"

	if(!length(render))
		playsound(scanner, 'sound/machines/ping.ogg', 50, FALSE)
		to_chat(user, span_notice("[capitalize(scanner.declent_ru(NOMINATIVE))] радостно пикает и на короткое время показывает смайлик с несколькими восклицательными знаками! Он рад сообщить, что [patient] не имеет болезней!"))
		scanner.emotion = AID_EMOTION_HAPPY
	else
		to_chat(user, span_notice(render.Join("")))
		scanner.emotion = AID_EMOTION_WARN
		playsound(scanner, 'sound/machines/beep/twobeep.ogg', 50, FALSE)

/obj/item/paper/medical_report
	color = "#99ccff"
	desc = "Официальный медицинский документ о состоянии здоровья, сформированный компьютеризированным медицинским сканером."
	/// A reference to a mob's weakref that was last scanned by the medical scanner.
	var/datum/weakref/last_healthy_scanned_mob

/obj/item/paper/medical_report/examine(mob/user)
	. = ..()
	if(last_healthy_scanned_mob)
		. += span_notice("Данный медицинский отчёт действителен для медицинских вознаграждений.")


#undef SCANMODE_HEALTH
#undef SCANMODE_WOUND
#undef SCANMODE_COUNT

#undef AID_EMOTION_NEUTRAL
#undef AID_EMOTION_HAPPY
#undef AID_EMOTION_WARN
#undef AID_EMOTION_ANGRY
#undef AID_EMOTION_SAD
