#define DRUMKIT_ANCHORED_LAYER 5

/datum/instrument/guitar/soundhand_rock
	name = "Soundhand Rock Guitar"
	id = "cshrockgt"
	real_samples = list("36"='modular_bandastation/objects/sounds/guitar/soundhand_rock/c2.ogg',
				"48"='modular_bandastation/objects/sounds/guitar/soundhand_rock/c3.ogg',
				"60"='modular_bandastation/objects/sounds/guitar/soundhand_rock/c4.ogg',
				"72"='modular_bandastation/objects/sounds/guitar/soundhand_rock/c5.ogg')

/datum/instrument/guitar/soundhand_metal
	name = "Soundhand Metal Guitar"
	id = "cshmetalgt"
	real_samples = list("36"='modular_bandastation/objects/sounds/guitar/soundhand_metal/c2.ogg',
				"48"='modular_bandastation/objects/sounds/guitar/soundhand_metal/c3.ogg',
				"60"='modular_bandastation/objects/sounds/guitar/soundhand_metal/c4.ogg',
				"72"='modular_bandastation/objects/sounds/guitar/soundhand_metal/c5.ogg')

/datum/instrument/guitar/soundhand_bass
	name = "Soundhand Bass Guitar"
	id = "cshbassgt"
	real_samples = list("36"='modular_bandastation/objects/sounds/guitar/soundhand_bass/c2.ogg',
				"48"='modular_bandastation/objects/sounds/guitar/soundhand_bass/c3.ogg',
				"60"='modular_bandastation/objects/sounds/guitar/soundhand_bass/c4.ogg',
				"72"='modular_bandastation/objects/sounds/guitar/soundhand_bass/c5.ogg')

/datum/instrument/hardcoded/drums
	name = "Drums"
	id = "drums"
	legacy_instrument_ext = "ogg"
	legacy_instrument_path = "soundhand_drums"

/obj/item/instrument/soundhand_metal_guitar
	name = "Aria's guitar"
	desc = "Тяжелая гитара со встроенными эффектами дисторшена и овердрайва. Эта гитара украшена пламенем в районе корпуса и подписью Арии Вильвен."
	icon_state = "elguitar_fire"
	icon = 'modular_bandastation/objects/icons/obj/items/samurai_guitar.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/samurai_guitar_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/samurai_guitar_righthand.dmi'
	attack_verb_continuous = list("played metal on", "shredded", "crashed", "smashed")
	hitsound = 'sound/items/weapons/stringsmash.ogg'
	allowed_instrument_ids = list("cshmetalgt", "cshrockgt", "csteelgt", "ccleangt","cshbassgt", "cnylongt", "cmutedgt")

/obj/item/instrument/soundhand_metal_guitar/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/obj/item/instrument/soundhand_bass_guitar
	name = "bass guitar"
	desc = "Тяжелая гитара с сокращенным количеством широких струн для извлечения низкочастотных звуков."
	icon_state = "bluegitara"
	icon = 'modular_bandastation/objects/icons/obj/items/samurai_guitar.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/samurai_guitar_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/samurai_guitar_righthand.dmi'
	attack_verb_continuous = list("played metal on", "shredded", "crashed", "smashed")
	hitsound = 'sound/items/weapons/stringsmash.ogg'
	allowed_instrument_ids = list("cshbassgt", "cnylongt", "cmutedgt")

/obj/item/instrument/soundhand_bass_guitar/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/obj/item/instrument/soundhand_rock_guitar
	name = "rock guitar"
	desc = "Тяжелая гитара со встроенными эффектами дисторшена и овердрайва"
	icon_state = "elguitar"
	icon = 'modular_bandastation/objects/icons/obj/items/samurai_guitar.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/samurai_guitar_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/samurai_guitar_righthand.dmi'
	attack_verb_continuous = list("played metal on", "shredded", "crashed", "smashed")
	hitsound = 'sound/items/weapons/stringsmash.ogg'
	allowed_instrument_ids = list("cshmetalgt", "cshrockgt", "csteelgt", "ccleangt")

/obj/item/instrument/soundhand_rock_guitar/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/obj/structure/musician/drumskit
	name = "drum kit"
	desc = "Складная барбанная установка с несколькими томами и тарелками."
	icon = 'modular_bandastation/objects/icons/obj/items/samurai_guitar.dmi'
	icon_state = "drum_red"
	base_icon_state = "drum_red"
	layer = 2.5
	anchored = FALSE
	buckle_lying = FALSE
	can_buckle = TRUE
	buckle_dir = SOUTH
	allowed_instrument_ids = list("drums")
	var/active = FALSE

/obj/structure/musician/drumskit/examine()
	. = ..()
	. += span_notice("Используйте гаечный ключ, чтобы разобрать для транспортировки и собрать для игры.")

/obj/structure/musician/drumskit/Initialize(mapload)
	. = ..()
	song.instrument_range = 15
	RegisterSignal(src, COMSIG_INSTRUMENT_START, PROC_REF(start_playing))
	RegisterSignal(src, COMSIG_INSTRUMENT_END, PROC_REF(stop_playing))

/obj/structure/musician/drumskit/Destroy()
	. = ..()
	UnregisterSignal(src, list(COMSIG_INSTRUMENT_START, COMSIG_INSTRUMENT_END))
	return ..()

/obj/structure/musician/drumskit/atom_break(damage_flag)
	. = ..()
	if(!broken)
		broken = TRUE
		update_icon(UPDATE_ICON_STATE)

/obj/structure/musician/drumskit/proc/start_playing()
	SIGNAL_HANDLER
	active = TRUE
	update_icon(UPDATE_ICON_STATE)

/obj/structure/musician/drumskit/proc/stop_playing()
	SIGNAL_HANDLER
	active = FALSE
	update_icon(UPDATE_ICON_STATE)

/obj/structure/musician/drumskit/ui_interact(mob/user)
	if(!anchored || broken)
		return
	. = ..()

/obj/structure/musician/drumskit/update_icon_state()
	if(broken)
		icon_state = "[base_icon_state]_broken"
		layer = initial(layer)
		return ..()

	if(anchored)
		icon_state = "[base_icon_state][active ? "_active" : null]"
		layer = DRUMKIT_ANCHORED_LAYER

	return ..()

/obj/structure/musician/drumskit/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(tool.tool_behaviour != TOOL_WRENCH)
		return ..()

	pack_to_item(user)

/obj/structure/musician/drumskit/proc/pack_to_item(mob/living/user)
	if(broken)
		to_chat(user, span_warning("Она сломана и не складывается."))
		return TRUE

	if(buckled_mobs && buckled_mobs.len)
		to_chat(user, span_warning("Кто-то сидит за установкой. Сначала отстегните их."))
		return TRUE

	if(active)
		stop_playing()

	anchored = FALSE
	update_icon(UPDATE_ICON_STATE)

	var/turf/T = get_turf(src)
	var/obj/item/instrument/drumskit_folded/I = new /obj/item/instrument/drumskit_folded(T)
	forceMove(I)

	if(ismob(user) && user.put_in_hands(I))
		to_chat(user, span_notice("Вы складываете [name] в чехол и берёте его в руки."))
	else
		to_chat(user, span_notice("Вы складываете [name] в чехол и кладёте рядом."))

	return TRUE

/obj/item/instrument/drumskit_folded
	name = "folded drum kit"
	desc = "Сложенная барабанная установка. Используйте гаечный ключ, чтобы развернуть."
	icon = 'modular_bandastation/objects/icons/obj/items/samurai_guitar.dmi'
	icon_state = "drum_red_unanchored"
	w_class = WEIGHT_CLASS_BULKY
	base_icon_state = "drum_red"
	var/obj/structure/musician/drumskit/linked = null
	allowed_instrument_ids = list("drums")

/obj/item/instrument/drumskit_folded/examine(mob/user)
	. = ..()
	. += span_notice("Гаечным ключом разверните установку на полу рядом с собой.")

/obj/item/instrument/drumskit_folded/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(tool.tool_behaviour != TOOL_WRENCH)
		return ..()

	var/turf/T = get_turf(user) || get_turf(src)
	if(!T)
		to_chat(user, span_warning("Здесь нельзя развернуть установку."))
		return TRUE

	var/obj/structure/musician/drumskit/S
	if(linked && !QDELETED(linked))
		S = linked
	else
		S = new /obj/structure/musician/drumskit(T)
		S.base_icon_state = base_icon_state

	S.forceMove(T)
	S.active = FALSE
	S.broken = FALSE
	S.anchored = TRUE
	S.update_icon(UPDATE_ICON_STATE)

	to_chat(user, span_notice("Вы разворачиваете [S.name] и фиксируете её на полу."))
	qdel(src)
	return TRUE

/obj/item/instrument/drumskit_folded/Destroy()
	if(linked && !QDELETED(linked))
		qdel(linked)
		linked = null
	return ..()

/obj/item/instrument/drumskit_folded/ui_interact(mob/user)
	return

#undef DRUMKIT_ANCHORED_LAYER
