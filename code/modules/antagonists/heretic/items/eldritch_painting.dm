// The basic eldritch painting
/obj/item/wallframe/painting/eldritch
	name = "The Blank Canvas: A Study in Default Subtypes"
	desc = "Картина невозможного, созданная невозможной краской. Ей не место в этой реальности."
	icon = 'icons/obj/signs.dmi'
	resistance_flags = FLAMMABLE
	flags_1 = NONE
	icon_state = "eldritch_painting_debug"
	result_path = /obj/structure/sign/painting/eldritch
	pixel_shift = 30

/obj/structure/sign/painting/eldritch
	name = "The Blank Canvas: A Study in Default Subtypes"
	desc = "Картина невозможного, созданная невозможной краской. Ей не место в этой реальности."
	icon = 'icons/obj/signs.dmi'
	icon_state = "eldritch_painting_debug"
	custom_materials = list(/datum/material/wood =SHEET_MATERIAL_AMOUNT)
	resistance_flags = FLAMMABLE
	buildable_sign = FALSE
	// The list of canvas types accepted by this frame, set to zero here
	accepted_canvas_types = list()
	// Set to false since we don't want this to persist
	persistence_id = FALSE
	/// The trauma the painting applies
	var/applied_status_effect = /datum/status_effect/eldritch_painting
	/// The text that shows up when you cross the paintings path
	var/text_to_display = "Some things should not be seen by mortal eyes..."
	/// The range of the paintings effect
	var/range = 7

/obj/structure/sign/painting/eldritch/Initialize(mapload)
	. = ..()
	if(ispath(applied_status_effect))
		var/static/list/connections = list(COMSIG_ATOM_ENTERED = PROC_REF(apply_status_effect))
		AddComponent(/datum/component/connect_range, tracked = src, connections = connections, range = range, works_in_containers = FALSE)

/obj/structure/sign/painting/eldritch/proc/apply_status_effect(datum/source, mob/living/carbon/viewer)
	SIGNAL_HANDLER
	if(!isliving(viewer) || !can_see(viewer, src, range))
		return
	if(isnull(viewer.mind) || isnull(viewer.mob_mood) || viewer.stat != CONSCIOUS || viewer.is_blind())
		return
	if(viewer.has_status_effect(applied_status_effect))
		return
	if(IS_HERETIC(viewer))
		return
	if(viewer.can_block_magic(MAGIC_RESISTANCE_MOON))
		return
	if(viewer.reagents.has_reagent(/datum/reagent/water/holywater))
		return
	to_chat(viewer, span_notice(text_to_display))
	viewer.apply_status_effect(applied_status_effect)
	INVOKE_ASYNC(viewer, TYPE_PROC_REF(/mob, emote), "scream")
	to_chat(viewer, span_hypnophrase("Когда вы смотрите на картину, вам разум постигает ее правду!"))

/obj/structure/sign/painting/eldritch/wirecutter_act(mob/living/user, obj/item/I)
	if(!user.can_block_magic(MAGIC_RESISTANCE_MOON))
		user.add_mood_event("ripped_eldritch_painting", /datum/mood_event/eldritch_painting)
		to_chat(user, span_hypnophrase("Смех отдается эхом в вашем разуме..."))
	qdel(src)
	return ITEM_INTERACT_SUCCESS

// On examine eldritch paintings give a trait so their effects can not be spammed
/obj/structure/sign/painting/eldritch/examine(mob/user)
	. = ..()
	if(!iscarbon(user))
		return
	if(HAS_TRAIT(user, TRAIT_ELDRITCH_PAINTING_EXAMINE))
		return

	ADD_TRAIT(user, TRAIT_ELDRITCH_PAINTING_EXAMINE, REF(src))
	addtimer(TRAIT_CALLBACK_REMOVE(user, TRAIT_ELDRITCH_PAINTING_EXAMINE, REF(src)), 3 MINUTES)
	addtimer(CALLBACK(src, PROC_REF(examine_effects), user), 0.2 SECONDS)

/obj/structure/sign/painting/eldritch/proc/examine_effects(mob/living/carbon/examiner)
	if(IS_HERETIC(examiner))
		to_chat(examiner, span_notice("Какая захватывающая картина!"))
	else
		to_chat(examiner, span_notice("Странноватая картина."))

// The Sister and He Who Wept eldritch painting
/obj/item/wallframe/painting/eldritch/weeping
	name = "The sister and He Who Wept"
	desc = "Прекрасная картина, изображающая раскошную даму, сидящую рядом с НИМ, ОН ПЛАЧЕТ, Я УВИЖУ ЕГО СНОВА."
	icon_state = "eldritch_painting_weeping"
	result_path = /obj/structure/sign/painting/eldritch/weeping

/obj/structure/sign/painting/eldritch/weeping
	name = "The sister and He Who Wept"
	desc = "Прекрасное произведение искусства, изображающее прекрасную даму и ЕГО, ОН ПЛАЧЕТ, Я УВИЖУ ЕГО СНОВА. Можно уничтожить кусачками."
	icon_state = "eldritch_painting_weeping"
	applied_status_effect = /datum/status_effect/eldritch_painting/weeping
	text_to_display = "О, какое искусство! Она такая прекрасная, а он... ОН ПЛАЧЕТ!!!"

/obj/structure/sign/painting/eldritch/weeping/examine_effects(mob/living/carbon/examiner)
	if(!IS_HERETIC(examiner))
		to_chat(examiner, span_hypnophrase("Передохни, пока что..."))
		examiner.mob_mood.mood_events.Remove("eldritch_weeping")
		examiner.add_mood_event("weeping_withdrawal", /datum/mood_event/eldritch_painting/weeping_withdrawal)
		return

	to_chat(examiner, span_notice("О, какое искусство! Один только взгляд на него проясняет ваши мысли."))
	examiner.remove_status_effect(/datum/status_effect/hallucination)
	examiner.add_mood_event("heretic_eldritch_painting", /datum/mood_event/eldritch_painting/weeping_heretic)

// The First Desire painting, using a lot of the painting/eldritch framework
/obj/item/wallframe/painting/eldritch/desire
	name = "The First Desire"
	desc = "Картина, изображающая блюдо с плотью, от одного только взгляда на нее сводит желудок и пенится рот."
	icon_state = "eldritch_painting_desire"
	result_path = /obj/structure/sign/painting/eldritch/desire

/obj/structure/sign/painting/eldritch/desire
	name = "The First Desire"
	desc = "Картина, изображающая блюдо с плотью, от одного только взгляда на нее сводит желудок и пенится рот. Можно уничтожить кусачками."
	icon_state = "eldritch_painting_desire"
	applied_status_effect = /datum/status_effect/eldritch_painting/desire
	text_to_display = "Какое произведение, от одного взгляда на него хочется есть..."

// The special examine interaction for this painting
/obj/structure/sign/painting/eldritch/desire/examine_effects(mob/living/carbon/examiner)
	if(!IS_HERETIC(examiner))
		// Gives them some nutrition
		examiner.adjust_nutrition(50)
		to_chat(examiner, span_warning("Вы чувствуете жгучую боль в животе!"))
		examiner.adjust_organ_loss(ORGAN_SLOT_STOMACH, 5)
		to_chat(examiner, span_notice("Вы чувствуете себя менее голодным."))
		to_chat(examiner, span_warning("Вам следует запастись сырым мясом и органами, прежде чем вы снова проголодаетесь."))
		examiner.add_mood_event("respite_eldritch_hunger", /datum/mood_event/eldritch_painting/desire_examine)
		return

	// A list made of the organs and bodyparts the heretic can get
	var/static/list/random_bodypart_or_organ = list(
		/obj/item/organ/brain,
		/obj/item/organ/lungs,
		/obj/item/organ/eyes,
		/obj/item/organ/ears,
		/obj/item/organ/heart,
		/obj/item/organ/liver,
		/obj/item/organ/stomach,
		/obj/item/organ/appendix,
		/obj/item/bodypart/arm/left,
		/obj/item/bodypart/arm/right,
		/obj/item/bodypart/leg/left,
		/obj/item/bodypart/leg/right
	)
	var/organ_or_bodypart_to_spawn = pick(random_bodypart_or_organ)
	new organ_or_bodypart_to_spawn(drop_location())
	to_chat(examiner, span_notice("Кусок плоти выползает из картины и падает на пол."))
	to_chat(examiner, span_warning("Пустота кричит!"))
	// Adds a negative mood event to our heretic
	examiner.add_mood_event("heretic_eldritch_hunger", /datum/mood_event/eldritch_painting/desire_heretic)

// Great chaparral over rolling hills, this one doesn't have the sensor type
/obj/item/wallframe/painting/eldritch/vines
	name = "Great chaparral over rolling hills"
	desc = "Картина, изображающая массивные заросли, которые, кажется, пытаются пролезть сковзь рамку."
	icon_state = "eldritch_painting_vines"
	result_path = /obj/structure/sign/painting/eldritch/vines

/obj/structure/sign/painting/eldritch/vines
	name = "Great chaparral over rolling hills"
	desc = "Картина, изображающая массивные заросли, которые, кажется, пытаются пролезть сковзь рамку. Можно уничтожить кусачками."
	icon_state = "eldritch_painting_vines"
	applied_status_effect = null
	// A static list of 5 pretty strong mutations, simple to expand for any admins
	var/list/mutations = list(
		/datum/spacevine_mutation/aggressive_spread,
		/datum/spacevine_mutation/fire_proof,
		/datum/spacevine_mutation/hardened,
		/datum/spacevine_mutation/thorns,
		/datum/spacevine_mutation/toxicity,
	)
	// Poppy and harebell are used in heretic rituals
	var/list/items_to_spawn = list(
		/obj/item/food/grown/poppy,
		/obj/item/food/grown/harebell,
	)

/obj/structure/sign/painting/eldritch/vines/Initialize(mapload)
	. = ..()
	new /datum/spacevine_controller(get_turf(src), mutations, 0, 10)

/obj/structure/sign/painting/eldritch/vines/examine_effects(mob/living/carbon/examiner)
	. = ..()
	if(!IS_HERETIC(examiner))
		new /datum/spacevine_controller(get_turf(examiner), mutations, 0, 10)
		to_chat(examiner, span_hypnophrase("Заросли пролезают сквозь рамку, и вы вдруг обнаруживаете под собой лианы..."))
		to_chat(examiner, span_notice("Ты чувствуешь, как что-то корчится вокруг тебя!"))
		return

	var/item_to_spawn = pick(items_to_spawn)
	to_chat(examiner, span_notice("На мгновение вы замираете, глядя на хаотичные узоры, которые создают лианы."))
	to_chat(examiner, span_notice("Вы чувствуете, как жизнь сгущается и расцветает под вами."))
	new item_to_spawn(examiner.drop_location())
	examiner.add_mood_event("heretic_vines", /datum/mood_event/eldritch_painting/heretic_vines)


// Lady out of gates, gives a brain trauma causing the person to scratch themselves
/obj/item/wallframe/painting/eldritch/beauty
	name = "\improper Lady of the Gate"
	desc = "Картина с изображением потустороннего существа. Его тонкая кожа цвета фарфора плотно натянута на странную костную структуру. Оно обладает странной красотой."
	icon_state = "eldritch_painting_beauty"
	result_path = /obj/structure/sign/painting/eldritch/beauty

/obj/structure/sign/painting/eldritch/beauty
	name = "\improper Lady of the Gate"
	desc = "Картина с изображением потустороннего существа. Его тонкая кожа цвета фарфора плотно натянута на странную костную структуру. Оно обладает странной красотой."
	icon_state = "eldritch_painting_beauty"
	applied_status_effect = /datum/status_effect/eldritch_painting/beauty
	text_to_display = "Ее плоть сияет в бледном свете, и моя тоже бы могла... Если бы не все эти недостатки..."
	/// List of reagents to add to heretics on examine, set to mutadone by default to remove mutations
	var/list/reagents_to_add = list(/datum/reagent/medicine/mutadone = 5)

// The special examine interaction for this painting
/obj/structure/sign/painting/eldritch/beauty/examine_effects(mob/living/carbon/examiner)
	. = ..()
	if(!examiner.has_dna())
		return

	if(!IS_HERETIC(examiner))
		to_chat(examiner, span_hypnophrase("Вы еще недостаточно чисты."))
		examiner.easy_random_mutate(NEGATIVE + MINOR_NEGATIVE)
		return

	to_chat(examiner, span_notice("Ваши недостатки исчезают."))
	examiner.reagents.add_reagent_list(reagents_to_add)

// Climb over the rusted mountain, gives a brain trauma causing the person to randomly rust tiles beneath them
/obj/item/wallframe/painting/eldritch/rust
	name = "\improper Master of the Rusted Mountain"
	desc = "Картина, изображающая странное существо, взбирающееся на гору цвета ржавчины. Работа кистью неестественна и нервирующая."
	icon_state = "eldritch_painting_rust"
	result_path = /obj/structure/sign/painting/eldritch/rust

/obj/structure/sign/painting/eldritch/rust
	name = "\improper Master of the Rusted Mountain"
	desc = "Картина, изображающая странное существо, взбирающееся на гору цвета ржавчины. Работа кистью неестественна и нервирующая. Снимается кусачками."
	icon_state = "eldritch_painting_rust"
	applied_status_effect = /datum/status_effect/eldritch_painting/rusting
	text_to_display = "Ржавчина разрушается. Мастер поднимается. Он зовет. Ты отвечаешь..."

// The special examine interaction for this painting
/obj/structure/sign/painting/eldritch/rust/examine_effects(mob/living/carbon/examiner)
	. = ..()

	if(!IS_HERETIC(examiner))
		to_chat(examiner, span_hypnophrase("Вы чувствуете ржавчину. Гниль."))
		examiner.add_mood_event("rusted_examine", /datum/mood_event/eldritch_painting/rust_examine)
		return

	to_chat(examiner, span_notice("Картина наполняет вас решимостью!"))
	examiner.add_mood_event("rusted_examine", /datum/mood_event/eldritch_painting/rust_heretic_examine)
