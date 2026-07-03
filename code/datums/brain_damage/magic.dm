//Magical traumas, caused by spells and curses.
//Blurs the line between the victim's imagination and reality
//Unlike regular traumas this can affect the victim's body and surroundings

/datum/brain_trauma/magic
	abstract_type = /datum/brain_trauma/magic
	resilience = TRAUMA_RESILIENCE_LOBOTOMY

/datum/brain_trauma/magic/lumiphobia
	name = "Люмифобия"
	desc = "У пациента необъяснимая побочная реакция на свет."
	scan_desc = "светочувствительность"
	symptoms = "Испытывает сильный дискомфорт и выраженные негативные реакции при воздействии ярких источников света, \
		и готов предпринимать значительные усилия, чтобы избегать освещённых зон. \
		Такая чувствительность может приводить к раздражению кожи, похожему на сильный солнечный ожог."
	gain_text = span_warning("Вы чувствуете тягу к темноте.")
	lose_text = span_notice("Свет больше не беспокоит вас.")
	/// Cooldown to prevent warning spam
	COOLDOWN_DECLARE(damage_warning_cooldown)
	var/next_damage_warning = 0

/datum/brain_trauma/magic/lumiphobia/on_life(seconds_per_tick)
	..()
	var/turf/T = owner.loc
	if(!istype(T))
		return

	if(T.get_lumcount() <= SHADOW_SPECIES_LIGHT_THRESHOLD) //if there's enough light, start dying
		return

	if(COOLDOWN_FINISHED(src, damage_warning_cooldown))
		to_chat(owner, span_warning("<b>Свет обжигает вас!</b>"))
		COOLDOWN_START(src, damage_warning_cooldown, 10 SECONDS)
	owner.take_overall_damage(burn = 1.5 * seconds_per_tick)

/datum/brain_trauma/magic/poltergeist
	name = "Полтергейст"
	desc = "Пациент, похоже, подвергается нападению невидимой агрессивной сущности."
	scan_desc = "паранормальная активность"
	symptoms = "Испытывает частые и ничем не спровоцированные физические нарушения в непосредственной близости, \
		например, предметы могут быть брошены или перемещены без какой-либо очевидной причины."
	gain_text = span_warning("Вы чувствуете ненавистное присутствие рядом с собой.")
	lose_text = span_notice("Вы чувствуете, как ненавистное присутствие исчезает.")

/datum/brain_trauma/magic/poltergeist/on_life(seconds_per_tick)
	..()
	if(!SPT_PROB(2, seconds_per_tick))
		return

	var/most_violent = -1 //So it can pick up items with 0 throwforce if there's nothing else
	var/obj/item/throwing
	for(var/obj/item/I in view(5, get_turf(owner)))
		if(I.anchored)
			continue
		if(I.throwforce > most_violent)
			most_violent = I.throwforce
			throwing = I
	if(throwing)
		throwing.throw_at(owner, 8, 2)

/datum/brain_trauma/magic/antimagic
	name = "Атаумазия"
	desc = "Пациент совершенно невосприимчив к магическим силам."
	scan_desc = "таумическая пустота"
	symptoms = "Проявляет полную невосприимчивость к эффектам, необъяснимым с точки зрения традиционной науки, \
		таким как способности, демонстрируемые членами Федерации магов."
	gain_text = span_notice("Вы понимаете, что магия не может быть реальной.")
	lose_text = span_notice("Вы понимаете, что магия может быть реальной.")

/datum/brain_trauma/magic/antimagic/on_gain()
	ADD_TRAIT(owner, TRAIT_ANTIMAGIC, TRAUMA_TRAIT)
	. = ..()

/datum/brain_trauma/magic/antimagic/on_lose()
	REMOVE_TRAIT(owner, TRAIT_ANTIMAGIC, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/magic/stalker
	name = "Преследующий призрак"
	desc = "Пациента преследует призрак, видимый только ему."
	scan_desc = "экстрасенсорная паранойя"
	symptoms = "Испытывает неотступное ощущение, будто за ним наблюдают или его преследует невидимая сущность, \
		что приводит к повышенной тревожности, паранойе и периодическим галлюцинациям призрачной фигуры поблизости. \
		В крайних случаях это может даже приводить к физическому вреду, наносимому пациенту, по-видимому, невидимой силой."
	gain_text = span_warning("Вы чувствуете себя так, словно что-то хочет убить вас...")
	lose_text = span_notice("Вы больше не чувствуете, что кто-то смотрит вам в спину.")
	/// Type of stalker that is chasing us
	var/stalker_type = /obj/effect/client_image_holder/stalker_phantom
	/// Reference to the stalker that is chasing us
	var/obj/effect/client_image_holder/stalker_phantom/stalker
	/// Plays a sound when the stalker is near their victim
	var/close_stalker = FALSE

/datum/brain_trauma/magic/stalker/Destroy()
	QDEL_NULL(stalker)
	return ..()

/datum/brain_trauma/magic/stalker/on_gain()
	create_stalker()
	return ..()

/datum/brain_trauma/magic/stalker/proc/create_stalker()
	var/turf/stalker_source = locate(owner.x + pick(-12, 12), owner.y + pick(-12, 12), owner.z) //random corner
	stalker = new stalker_type(stalker_source, owner)

/datum/brain_trauma/magic/stalker/on_lose()
	QDEL_NULL(stalker)
	return ..()

/datum/brain_trauma/magic/stalker/on_life(seconds_per_tick)
	// Dead and unconscious people are not interesting to the psychic stalker.
	if(owner.stat != CONSCIOUS)
		return

	// Not even nullspace will keep it at bay.
	if(!stalker || !stalker.loc || stalker.z != owner.z)
		qdel(stalker)
		create_stalker()

	if(get_dist(owner, stalker) <= 1)
		playsound(owner, 'sound/effects/magic/demon_attack1.ogg', 50)
		owner.visible_message(span_warning("[declent_ru(owner, GENITIVE)] разорвало на части невидимыми когтями!"), span_userdanger("Призрачные когти разрывают ваше тело на части!"))
		owner.take_bodypart_damage(rand(20, 45), wound_bonus=CANT_WOUND)
	else if(SPT_PROB(30, seconds_per_tick))
		stalker.forceMove(get_step_towards(stalker, owner))
	if(get_dist(owner, stalker) <= 8)
		if(!close_stalker)
			var/sound/slowbeat = sound('sound/effects/health/slowbeat.ogg', repeat = TRUE)
			owner.playsound_local(owner, slowbeat, 40, 0, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
			close_stalker = TRUE
	else
		if(close_stalker)
			owner.stop_sound_channel(CHANNEL_HEARTBEAT)
			close_stalker = FALSE
	..()

/obj/effect/client_image_holder/stalker_phantom
	name = "???"
	desc = "Оно приближается..."
	image_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	image_state = "curseblob"

// Heretic subtype that replaces the ghost guy with a stargazer
/datum/brain_trauma/magic/stalker/cosmic
	stalker_type = /obj/effect/client_image_holder/stalker_phantom/cosmic
	random_gain = FALSE
	known_trauma = FALSE

/obj/effect/client_image_holder/stalker_phantom/cosmic
	image_icon = 'icons/mob/nonhuman-player/96x96eldritch_mobs.dmi'
	image_state = "star_gazer"
