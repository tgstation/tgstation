
/*
	Slashing wounds
*/

/datum/wound/slash
	name = "Slashing (Cut) Wound"
	undiagnosed_name = "Cut"
	sound_effect = 'sound/items/weapons/slice.ogg'

/datum/wound/slash/get_self_check_description(self_aware)
	if(!limb.can_bleed())
		return ..()

	switch(severity)
		if(WOUND_SEVERITY_TRIVIAL)
			return span_danger("It's leaking blood from a small [LOWER_TEXT(undiagnosed_name || name)].")
		if(WOUND_SEVERITY_MODERATE)
			return span_warning("It's leaking blood from a [LOWER_TEXT(undiagnosed_name || name)].")
		if(WOUND_SEVERITY_SEVERE)
			return span_boldwarning("It's leaking blood from a serious [LOWER_TEXT(undiagnosed_name || name)]!")
		if(WOUND_SEVERITY_CRITICAL)
			return span_boldwarning("It's leaking blood from a major [LOWER_TEXT(undiagnosed_name || name)]!!")

/datum/wound_pregen_data/flesh_slash
	abstract = TRUE

	required_wounding_type = WOUND_SLASH
	required_limb_biostate = BIO_FLESH

	wound_series = WOUND_SERIES_FLESH_SLASH_BLEED

/datum/wound/slash/flesh
	name = "Slashing (Cut) Flesh Wound"
	threshold_penalty = 5
	processes = TRUE
	treatable_tools = list(TOOL_CAUTERY)
	base_treat_time = 3 SECONDS
	wound_flags = (ACCEPTS_GAUZE|CAN_BE_GRASPED)

	default_scar_file = FLESH_SCAR_FILE

	/// How much blood we start losing when this wound is first applied
	var/initial_flow
	/// When we have less than this amount of flow, either from treatment or clotting, we demote to a lower cut or are healed of the wound
	var/minimum_flow
	/// How much our blood_flow will naturally decrease per second, not only do larger cuts bleed more blood faster, they clot slower (higher number = clot quicker, negative = opening up)
	var/clot_rate

	/// Once the blood flow drops below minimum_flow, we demote it to this type of wound. If there's none, we're all better
	var/demotes_to

	/// A bad system I'm using to track the worst scar we earned (since we can demote, we want the biggest our wound has been, not what it was when it was cured (probably moderate))
	var/datum/scar/highest_scar

/datum/wound/slash/flesh/Destroy()
	highest_scar = null

	return ..()

/datum/wound/slash/flesh/wound_injury(datum/wound/slash/flesh/old_wound = null, attack_direction = null)
	if(old_wound)
		set_blood_flow(max(old_wound.blood_flow, initial_flow))
		if(old_wound.severity > severity && old_wound.highest_scar)
			set_highest_scar(old_wound.highest_scar)
			old_wound.clear_highest_scar()
	else
		set_blood_flow(initial_flow)
		if(limb.can_bleed() && attack_direction && victim.get_blood_volume() > BLOOD_VOLUME_OKAY)
			victim.spray_blood(attack_direction, severity)

	if(!highest_scar)
		var/datum/scar/new_scar = new
		set_highest_scar(new_scar)
		new_scar.generate(limb, src, add_to_scars=FALSE)

	return ..()

/datum/wound/slash/flesh/proc/set_highest_scar(datum/scar/new_scar)
	if(highest_scar)
		UnregisterSignal(highest_scar, COMSIG_QDELETING)
	if(new_scar)
		RegisterSignal(new_scar, COMSIG_QDELETING, PROC_REF(clear_highest_scar))
	highest_scar = new_scar

/datum/wound/slash/flesh/proc/clear_highest_scar(datum/source)
	SIGNAL_HANDLER
	set_highest_scar(null)

/datum/wound/slash/flesh/remove_wound(ignore_limb, replaced, destroying)
	if(!replaced && highest_scar)
		already_scarred = TRUE
		highest_scar.lazy_attach(limb)
	return ..()

/datum/wound/slash/flesh/get_wound_description(mob/user)
	var/obj/item/stack/medical/wrap/current_gauze = LAZYACCESS(limb.applied_items, LIMB_ITEM_GAUZE)
	if(!current_gauze)
		return ..()

	var/list/msg = list("Порезы на [victim.ru_p_them()] [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone] перевязаны [current_gauze.declent_ru(INSTRUMENTAL)]. Перевязка ")
	// how much life we have left in these bandages
	switch(current_gauze.absorption_capacity)
		if(0 to 1.25)
			msg += "почти спала"
		if(1.25 to 2.75)
			msg += "сильно износилась"
		if(2.75 to 4)
			msg += "слегка запачкана кровью"
		if(4 to INFINITY)
			msg += "чиста"
	msg += "[current_gauze.name]!"

	return "<B>[msg.Join()]</B>"

/datum/wound/slash/flesh/receive_damage(wounding_type, wounding_dmg, wound_bonus)
	if (!victim) // if we are dismembered, we can still take damage, its fine to check here
		return

	if(victim.stat != DEAD && wound_bonus != CANT_WOUND && wounding_type == WOUND_SLASH) // can't stab dead bodies to make it bleed faster this way
		adjust_blood_flow(WOUND_SLASH_DAMAGE_FLOW_COEFF * wounding_dmg)

	return ..()

/datum/wound/slash/flesh/drag_bleed_amount()
	// say we have 3 severe cuts with 3 blood flow each, pretty reasonable
	// compare with being at 100 brute damage before, where you bled (brute/100 * 2), = 2 blood per tile
	var/bleed_amt = min(blood_flow * 0.1, 1) // 3 * 3 * 0.1 = 0.9 blood total, less than before! the share here is .3 blood of course.

	if(limb.seep_gauze(bleed_amt * 0.33)) // gauze stops all bleeding from dragging on this limb, but wears the gauze out quicker
		return 0

	return bleed_amt

/datum/wound/slash/flesh/get_bleed_rate_of_change()
	//basically if a species doesn't bleed, the wound is stagnant and will not heal on its own (nor get worse)
	if(!limb.can_bleed())
		return BLOOD_FLOW_STEADY
	if(HAS_TRAIT(victim, TRAIT_BLOOD_FOUNTAIN))
		return BLOOD_FLOW_INCREASING
	if(LAZYACCESS(limb.applied_items, LIMB_ITEM_GAUZE) || clot_rate > 0)
		return BLOOD_FLOW_DECREASING
	if(clot_rate < 0)
		return BLOOD_FLOW_INCREASING

/datum/wound/slash/flesh/handle_process(seconds_per_tick)
	if (!victim || HAS_TRAIT(victim, TRAIT_STASIS))
		return

	// in case the victim has the NOBLOOD trait, the wound will simply not clot on its own
	if(limb.can_bleed())
		if(clot_rate > 0)
			adjust_blood_flow(-clot_rate * seconds_per_tick)
			if(QDELETED(src))
				return

		if(HAS_TRAIT(victim, TRAIT_BLOOD_FOUNTAIN))
			adjust_blood_flow(0.25) // old heparin used to just add +2 bleed stacks per tick, this adds 0.5 bleed flow to all open cuts which is probably even stronger as long as you can cut them first

	var/obj/item/stack/medical/wrap/current_gauze = LAZYACCESS(limb.applied_items, LIMB_ITEM_GAUZE)
	if(current_gauze?.absorption_rate)
		var/gauze_power = current_gauze.absorption_rate
		limb.seep_gauze(gauze_power * seconds_per_tick)
		adjust_blood_flow(-gauze_power * seconds_per_tick)

/* BEWARE, THE BELOW NONSENSE IS MADNESS. bones.dm looks more like what I have in mind and is sufficiently clean, don't pay attention to this messiness */

/datum/wound/slash/flesh/check_grab_treatments(obj/item/tool, mob/user)
	if(istype(tool, /obj/item/gun/energy/laser))
		return TRUE
	if(tool.get_temperature() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST) // if we're using something hot but not a cautery, we need to be aggro grabbing them first, so we don't try treating someone we're eswording
		return TRUE
	return FALSE

/datum/wound/slash/flesh/treat(obj/item/tool, mob/user)
	if(istype(tool, /obj/item/gun/energy/laser))
		las_cauterize(tool, user)
	else if(tool.tool_behaviour == TOOL_CAUTERY || tool.get_temperature() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		tool_cauterize(tool, user)

/datum/wound/slash/flesh/try_handling(mob/living/user)
	if(user.pulling != victim || !HAS_TRAIT(user, TRAIT_WOUND_LICKER) || !victim.try_inject(user, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE))
		return FALSE
	if(!isnull(user.hud_used?.screen_objects[HUD_MOB_ZONE_SELECTOR]) && user.zone_selected != limb.body_zone)
		return FALSE

	if(DOING_INTERACTION_WITH_TARGET(user, victim))
		to_chat(user, span_warning("Вы уже взаимодействуете с [victim.declent_ru(INSTRUMENTAL)]!"))
		return
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		if(carbon_user.is_mouth_covered())
			to_chat(user, span_warning("Ваш рот закрыт, вы не можете лизать раны [victim.declent_ru(GENITIVE)]!"))
			return
		if(!carbon_user.get_organ_slot(ORGAN_SLOT_TONGUE))
			to_chat(user, span_warning("Вы не можете лизать раны без языка!")) // f in chat
			return

	lick_wounds(user)
	return TRUE

/// if a felinid is licking this cut to reduce bleeding
/datum/wound/slash/flesh/proc/lick_wounds(mob/living/carbon/human/user)
	// transmission is one way patient -> felinid since google said cat saliva is antiseptic or whatever, and also because felinids are already risking getting beaten for this even without people suspecting they're spreading a deathvirus
	for(var/datum/disease/iter_disease as anything in victim.diseases)
		if(iter_disease.spread_flags & (DISEASE_SPREAD_SPECIAL | DISEASE_SPREAD_NON_CONTAGIOUS))
			continue
		user.ForceContractDisease(iter_disease)

	user.visible_message(span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает лизать раны на [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone] у [victim.declent_ru(GENITIVE)]."), span_notice("Вы начинаете лизать раны на [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone] у [victim.declent_ru(GENITIVE)]..."), ignored_mobs=victim)
	to_chat(victim, span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает лизать раны на вашей [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone]."))
	if(!do_after(user, base_treat_time, target = victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return

	user.visible_message(span_notice("[capitalize(user.declent_ru(NOMINATIVE))] лижет раны на [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone] у [victim.declent_ru(GENITIVE)]."), span_notice("Вы лижете некоторые из ран на [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone] у [victim.declent_ru(GENITIVE)]"), ignored_mobs=victim)
	to_chat(victim, span_green("[capitalize(user.declent_ru(NOMINATIVE))] лижет раны на вашей [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone]!"))
	var/mob/victim_stored = victim
	adjust_blood_flow(-0.5)

	if(blood_flow > minimum_flow)
		try_handling(user)
	else if(demotes_to)
		to_chat(user, span_green("Вы успешно снижаете тяжесть порезов у [user == victim_stored ? "себя" : victim_stored.declent_ru(GENITIVE)]."))

/datum/wound/slash/flesh/adjust_blood_flow(adjust_by, minimum)
	. = ..()
	if(blood_flow > WOUND_MAX_BLOODFLOW)
		blood_flow = WOUND_MAX_BLOODFLOW
	if(blood_flow < minimum_flow && !QDELETED(src))
		if(demotes_to)
			replace_wound(new demotes_to)
		else
			to_chat(victim, span_green("Порез на вашей [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone] [!limb.can_bleed() ? "закрылся" : "перестал кровоточить"]!"))
			qdel(src)

/datum/wound/slash/flesh/on_xadone(power)
	. = ..()
	adjust_blood_flow(-0.03 * power) // i think it's like a minimum of 3 power, so .09 blood_flow reduction per tick is pretty good for 0 effort

/datum/wound/slash/flesh/on_synthflesh(reac_volume)
	. = ..()
	adjust_blood_flow(-0.075 * reac_volume) // 20u * 0.075 = -1.5 blood flow, pretty good for how little effort it is

/// If someone's putting a laser gun up to our cut to cauterize it
/datum/wound/slash/flesh/proc/las_cauterize(obj/item/gun/energy/laser/lasgun, mob/user)
	var/self_penalty_mult = (user == victim ? 1.25 : 1)
	user.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] начинает направлять [lasgun.declent_ru(ACCUSATIVE)] на рану на [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone] у [victim.declent_ru(GENITIVE)]..."), span_userdanger("Вы начинаете направлять [lasgun.declent_ru(ACCUSATIVE)] на [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone] у [user == victim ? "вас" : "[victim.declent_ru(GENITIVE)]"] ..."))
	if(!do_after(user, base_treat_time  * self_penalty_mult, target = victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return
	var/damage = lasgun.chambered.loaded_projectile.damage
	lasgun.chambered.loaded_projectile.wound_bonus -= 30
	lasgun.chambered.loaded_projectile.damage *= self_penalty_mult
	if(!lasgun.process_fire(victim, victim, TRUE, null, limb.body_zone))
		return
	victim.emote("scream")
	victim.visible_message(span_warning("Порезы на [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone] у [victim.declent_ru(GENITIVE)] заживают!"))
	adjust_blood_flow(-1 * (damage / (5 * self_penalty_mult))) // 20 / 5 = 4 bloodflow removed, p good

/// If someone is using either a cautery tool or something with heat to cauterize this cut
/datum/wound/slash/flesh/proc/tool_cauterize(obj/item/I, mob/user)
	var/improv_penalty_mult = (I.tool_behaviour == TOOL_CAUTERY ? 1 : 1.25) // 25% longer and less effective if you don't use a real cautery
	var/self_penalty_mult = (user == victim ? 1.5 : 1) // 50% longer and less effective if you do it to yourself

	var/treatment_delay = base_treat_time * self_penalty_mult * improv_penalty_mult

	if(HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		treatment_delay *= 0.5
		user.visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] начинает опытно прижигать [limb.ru_plaintext_zone[ACCUSATIVE] || limb.plaintext_zone] у [victim.declent_ru(GENITIVE)] с помощью [I.declent_ru(GENITIVE)]..."), span_warning("Вы начинаете прижигать [limb.ru_plaintext_zone[ACCUSATIVE] || limb.plaintext_zone] у [user == victim ? "вас" : "[victim.declent_ru(GENITIVE)]"] с помощью [I.declent_ru(GENITIVE)], держа в голове показатели сканера..."))
	else
		user.visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] начинает прижигать [limb.ru_plaintext_zone[ACCUSATIVE] || limb.plaintext_zone] у [victim.declent_ru(GENITIVE)] с помощью [I.declent_ru(GENITIVE)]..."), span_warning("Вы начинаете прижигать [limb.ru_plaintext_zone[ACCUSATIVE] || limb.plaintext_zone] у [user == victim ? "вас" : "[victim.declent_ru(GENITIVE)]"] с помощью [I.declent_ru(GENITIVE)]..."))

	playsound(user, 'sound/items/handling/surgery/cautery1.ogg', 75, TRUE)

	if(!do_after(user, treatment_delay, target = victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return

	playsound(user, 'sound/items/handling/surgery/cautery2.ogg', 75, TRUE)

	var/bleeding_wording = (limb.can_bleed() ? "bleeding" : "cuts")
	user.visible_message(span_green("[user] cauterizes some of the [bleeding_wording] on [victim]."), span_green("You cauterize some of the [bleeding_wording] on [victim]."))
	victim.apply_damage(2 + severity, BURN, limb, wound_bonus = CANT_WOUND)
	if(prob(30))
		victim.emote("scream")
	var/blood_cauterized = (0.6 / (self_penalty_mult * improv_penalty_mult))
	var/mob/victim_stored = victim
	adjust_blood_flow(-blood_cauterized)

	if(blood_flow > minimum_flow)
		try_treating(I, user)

	else if(demotes_to)
		to_chat(user, span_green("Вы успешно снижаете тяжесть порезов у [user == victim_stored ? "себя" : victim_stored.declent_ru(GENITIVE)]."))

/datum/wound/slash/get_limb_examine_description()
	return span_warning("Кожа на этой конечности выглядит сильно порезанной.")

/datum/wound/slash/flesh/moderate
	name = "Легкий порез"
	desc = "Кожа пациента сильно соскоблена, что приводит к умеренной потере крови."
	treat_text = "Наложите повязку или сделайте шов на ране. \
		Затем обеспечьте питание и период отдыха."
	treat_text_short = "Наложите повязку или сделайте шов."
	examine_desc = "имеет открытую рану"
	occur_text = "разрезается, начиная медленно кровоточить"
	sound_effect = 'sound/effects/wounds/blood1.ogg'
	severity = WOUND_SEVERITY_MODERATE
	initial_flow = 1.75
	minimum_flow = 0.5
	clot_rate = 0.04
	series_threshold_penalty = 10
	status_effect_type = /datum/status_effect/wound/slash/flesh/moderate
	scar_keyword = "slashmoderate"

	simple_treat_text = "<b>Наложение повязки</b> на рану уменьшит кровопотерю, поможет ране быстрее заживать самостоятельно и ускорит период восстановления крови. Саму рану можно медленно <b>зашить</b>."
	homemade_treat_text = "<b>Чай</b> стимулирует естественные лечебные системы организма, немного ускоряя свёртывание. Также рану можно промыть в раковине или душе. Другие средства не нужны."

/datum/wound/slash/flesh/moderate/update_descriptions()
	if(!limb.can_bleed())
		occur_text = "покрывается заметными разрезами"

/datum/wound_pregen_data/flesh_slash/abrasion
	abstract = FALSE

	wound_path_to_generate = /datum/wound/slash/flesh/moderate

	threshold_minimum = 20

/datum/wound/slash/flesh/severe
	name = "Открытый разрез"
	desc = "Кожа пациента разорвана, что вызывает значительную потерю крови."
	treat_text = "Быстро наложите повязку или зашейте рану, \
		или воспользуйтесь средствами для остановки крови или прижиганием. \
		После этого рекомендуется принимать добавки железа или соляно-глюкозные растворы, а также отдохнуть."
	treat_text_short = "Примените повязку, швы, средства для свертывания крови или прижигание."
	examine_desc = "имеет серьезный порез"
	occur_text = "разрывается, и вены начинают брызгать кровью"
	sound_effect = 'sound/effects/wounds/blood2.ogg'
	severity = WOUND_SEVERITY_SEVERE
	initial_flow = 2.75
	minimum_flow = 2
	clot_rate = 0.02
	series_threshold_penalty = 25
	demotes_to = /datum/wound/slash/flesh/moderate
	status_effect_type = /datum/status_effect/wound/slash/flesh/severe
	scar_keyword = "slashsevere"
	surgery_states = SURGERY_SKIN_CUT | SURGERY_VESSELS_UNCLAMPED

	simple_treat_text = "<b>Наложение повязки</b> на рану является важным и уменьшит потерю крови. После этого рану можно <b>зашить</b>, желательно, чтобы пациент отдыхал и/или держал свою рану."
	homemade_treat_text = "Простыни можно разорвать, чтобы сделать <b>самодельный бинт</b>. <b>Мука, соль и соленая вода</b>, нанесенные на кожу, помогут, но чистая поваренная соль НЕ рекомендуется. Падение на землю и удерживание раны снизит кровотечение."

/datum/wound_pregen_data/flesh_slash/laceration
	abstract = FALSE

	wound_path_to_generate = /datum/wound/slash/flesh/severe

	threshold_minimum = 50

/datum/wound/slash/flesh/severe/update_descriptions()
	if(!limb.can_bleed())
		occur_text = "обнажает глубокий разрез"

/datum/wound/slash/flesh/critical
	name = "Авульсивный разрез"
	desc = "Кожа пациента полностью разорвана, что приводит к значительной потере ткани. Экстремальная потеря крови приведет к быстрой смерти без вмешательства."
	treat_text = "Быстро наложите повязку или зашейте рану, \
		или воспользуйтесь средствами для остановки крови или прижиганием. \
		Следует провести контроль за ресангинацией."
	treat_text_short = "Примените повязку, швы, средства для свертывания крови или прижигание."
	examine_desc = "рвется до кости, брызгая кровью"
	occur_text = "разрывается, брызгая кровью"
	sound_effect = 'sound/effects/wounds/blood3.ogg'
	severity = WOUND_SEVERITY_CRITICAL
	initial_flow = 3.75
	minimum_flow = 3.5
	clot_rate = -0.012 // critical cuts actively get worse instead of better
	threshold_penalty = 15
	demotes_to = /datum/wound/slash/flesh/severe
	status_effect_type = /datum/status_effect/wound/slash/flesh/critical
	scar_keyword = "slashcritical"
	surgery_states = SURGERY_SKIN_OPEN | SURGERY_VESSELS_UNCLAMPED
	wound_flags = (ACCEPTS_GAUZE | MANGLES_EXTERIOR | CAN_BE_GRASPED)
	simple_treat_text = "<b>Наложение повязки</b> на рану является важным, как и немедленное обращение за помощью - <b>Смерть</b> наступит, если лечение будет задержано, так как нехватка <b>кислорода</b> убивает пациента, поэтому <b>пища, железо и солево-глюкозный раствор</b> всегда рекомендуется после лечения. Эта рана не заживет сама по себе."
	homemade_treat_text = "Простыни можно порвать, чтобы сделать <b>самодельный бинт</b>. <b>Мука, соль и соленая вода</b>, нанесенные на кожу, помогут. Падение на землю и удерживание раны снизит кровотечение."

/datum/wound/slash/flesh/critical/update_descriptions()
	if (!limb.can_bleed())
		occur_text = "раскрывается огромной зияющей раной"

/datum/wound_pregen_data/flesh_slash/avulsion
	abstract = FALSE

	wound_path_to_generate = /datum/wound/slash/flesh/critical
	threshold_minimum = 80

/datum/wound/slash/flesh/moderate/many_cuts
	name = "Многочисленные небольшие резаные раны"
	desc = "Кожа пациента покрыта многочисленными небольшими порезами и ссадинами, что приводит к умеренной потере крови."
	examine_desc = "имеет множество мелких порезов"
	occur_text = "разрезается множество раз, оставляя много маленьких ссадин"

/datum/wound_pregen_data/flesh_slash/abrasion/cuts
	abstract = FALSE
	can_be_randomly_generated = FALSE

	wound_path_to_generate = /datum/wound/slash/flesh/moderate/many_cuts

// Subtype for cleave (heretic spell)
/datum/wound/slash/flesh/critical/cleave
	name = "Горячий глубокий порез"
	examine_desc = "разорвана, фонтанируя кровью"
	clot_rate = 0.01

/datum/wound/slash/flesh/critical/cleave/update_descriptions()
	if(!limb.can_bleed())
		occur_text = "широко раскрывается"

/datum/wound_pregen_data/flesh_slash/avulsion/clear
	abstract = FALSE
	can_be_randomly_generated = FALSE

	wound_path_to_generate = /datum/wound/slash/flesh/critical/cleave
