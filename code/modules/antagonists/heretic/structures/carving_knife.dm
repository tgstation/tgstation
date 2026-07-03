// The rune carver, a heretic knife that can draw rune traps.
/obj/item/melee/rune_carver
	name = "carving knife"
	desc = "Маленький нож из холодной стали, чистой и совершенной. Его острие способно прорезать сам титан - \
		Но лишь немногие способны вызвать опасности, которые таятся под реальностью."
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "rune_carver"
	icon_angle = -45
	obj_flags = CONDUCTS_ELECTRICITY
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_SMALL
	wound_bonus = 20
	force = 10
	throwforce = 20
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	attack_verb_continuous = list("атакуете", "режете", "рвёте", "пускаете кровь", "разрываете", "рубите", "раздираете")
	attack_verb_simple = list("атакуете", "режете", "рвёте", "пускаете кровь", "разрываете", "рубите", "раздираете")
	actions_types = list(/datum/action/item_action/rune_shatter)
	embed_type = /datum/embedding/rune_carver

	/// Whether we're currently drawing a rune
	var/drawing = FALSE
	/// Max amount of runes that can be drawn
	var/max_rune_amt = 3
	/// A list of weakrefs to all of ourc urrent runes
	var/list/datum/weakref/current_runes = list()
	/// Turfs that you cannot draw carvings on
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/open/space, /turf/open/openspace, /turf/open/lava))
	var/list/alt_continuous = list("протыкаете", "пронзаете", "нанизываете")
	var/list/alt_simple = list("протыкаете", "пронзаете", "нанизываете")

/obj/item/melee/rune_carver/Initialize(mapload)
	. = ..()
	alt_continuous = string_list(alt_continuous)
	alt_simple = string_list(alt_simple)
	AddComponent(/datum/component/alternative_sharpness, SHARP_POINTY, alt_continuous, alt_simple)

/datum/embedding/rune_carver
	ignore_throwspeed_threshold = TRUE
	embed_chance = 75
	jostle_chance = 2
	jostle_pain_mult = 5
	pain_stam_pct = 0.4
	pain_mult = 3
	rip_time = 1.5 SECONDS

/obj/item/melee/rune_carver/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user) && !isobserver(user))
		return

	. += span_notice("Всего было вырезано: <b>[length(current_runes)] / [max_rune_amt]</b>")
	. += span_info("Можно вырезать следующие руны:")
	for(var/obj/structure/trap/eldritch/trap as anything in subtypesof(/obj/structure/trap/eldritch))
		var/potion_string = span_info("\tThe " + initial(trap.name) + " - " + initial(trap.carver_tip))
		. += potion_string

/obj/item/melee/rune_carver/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!IS_HERETIC_OR_MONSTER(user))
		return NONE
	if(!isopenturf(interacting_with) || is_type_in_typecache(interacting_with, blacklisted_turfs))
		return NONE

	INVOKE_ASYNC(src, PROC_REF(try_carve_rune), interacting_with, user)
	return ITEM_INTERACT_SUCCESS

/*
 * Begin trying to carve a rune. Go through a few checks, then call do_carve_rune if successful.
 */
/obj/item/melee/rune_carver/proc/try_carve_rune(turf/open/target_turf, mob/user)
	if(drawing)
		target_turf.balloon_alert(user, "уже вырезаете!")
		return

	if(locate(/obj/structure/trap/eldritch) in range(1, target_turf))
		target_turf.balloon_alert(user, "слишком близко к другой резьбе!")
		return

	for(var/datum/weakref/rune_ref as anything in current_runes)
		if(!rune_ref?.resolve())
			current_runes -= rune_ref

	if(length(current_runes) >= max_rune_amt)
		target_turf.balloon_alert(user, "слишком много резьбы!")
		return

	drawing = TRUE
	do_carve_rune(target_turf, user)
	drawing = FALSE

/*
 * The actual proc that handles selecting the rune to draw and creating it.
 */
/obj/item/melee/rune_carver/proc/do_carve_rune(turf/open/target_turf, mob/user)
	// Assoc list of [name] to [image] for the radial (to show tooltips)
	var/static/list/choices = list()
	// Assoc list of [name] to [path] for after the radial
	var/static/list/names_to_path = list()
	if(!choices.len || !names_to_path.len)
		for(var/obj/structure/trap/eldritch/trap as anything in subtypesof(/obj/structure/trap/eldritch))
			names_to_path[initial(trap.name)] = trap
			choices[initial(trap.name)] = image(icon = initial(trap.icon), icon_state = initial(trap.icon_state))

	var/picked_choice = show_radial_menu(
		user,
		target_turf,
		choices,
		require_near = TRUE,
		tooltips = TRUE,
		)

	if(isnull(picked_choice))
		return

	var/to_make = names_to_path[picked_choice]
	if(!ispath(to_make, /obj/structure/trap/eldritch))
		CRASH("[type] attempted to create a rune of incorrect type! (got: [to_make])")

	target_turf.balloon_alert(user, "вырезание [picked_choice]...")
	user.playsound_local(target_turf, 'sound/items/sheath.ogg', 50, TRUE)
	if(!do_after(user, 5 SECONDS, target = target_turf))
		target_turf.balloon_alert(user, "прервано!")
		return

	target_turf.balloon_alert(user, "[picked_choice] вырезано")
	var/obj/structure/trap/eldritch/new_rune = new to_make(target_turf, user)
	current_runes += WEAKREF(new_rune)

/datum/action/item_action/rune_shatter
	name = "Уничтожение рун"
	desc = "Уничтожает все руны, вырезанные этим клинком."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon_state = "rune_break"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'

/datum/action/item_action/rune_shatter/New(Target)
	. = ..()
	if(!istype(Target, /obj/item/melee/rune_carver))
		qdel(src)
		return

/datum/action/item_action/rune_shatter/Grant(mob/granted)
	if(!IS_HERETIC_OR_MONSTER(granted))
		return

	return ..()

/datum/action/item_action/rune_shatter/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	if(!IS_HERETIC_OR_MONSTER(owner))
		return FALSE
	var/obj/item/melee/rune_carver/target_sword = target
	if(!length(target_sword.current_runes))
		return FALSE

/datum/action/item_action/rune_shatter/do_effect(trigger_flags)
	owner.playsound_local(get_turf(owner), 'sound/effects/magic/blind.ogg', 50, TRUE)
	var/obj/item/melee/rune_carver/target_sword = target
	QDEL_LIST(target_sword.current_runes)
	target_sword.SpinAnimation(5, 1)
	return TRUE

// The actual rune traps the knife draws.
/obj/structure/trap/eldritch
	name = "elder carving"
	desc = "Коллекция неизвестных символов, они напоминают о давно ушедших днях..."
	icon = 'icons/obj/service/hand_of_god_structures.dmi'
	max_integrity = 60
	/// A tip displayed to heretics who examine the rune carver. Explains what the rune does.
	var/carver_tip
	/// Reference to trap owner mob
	var/datum/weakref/owner

/obj/structure/trap/eldritch/Initialize(mapload, new_owner)
	. = ..()
	if(new_owner)
		owner = WEAKREF(new_owner)

/obj/structure/trap/eldritch/on_entered(datum/source, atom/movable/entering_atom)
	if(!isliving(entering_atom))
		return
	var/mob/living/living_mob = entering_atom
	if(WEAKREF(living_mob) == owner)
		return
	if(IS_HERETIC_OR_MONSTER(living_mob))
		return
	return ..()

/obj/structure/trap/eldritch/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/melee/rune_carver) || HAS_TRAIT(tool, TRAIT_NULLROD_ITEM))
		loc.balloon_alert(user, "резьба развеяна")
		playsound(src, 'sound/items/sheath.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, ignore_walls = FALSE)
		qdel(src)
		return ITEM_INTERACT_SUCCESS

	return NONE

/obj/structure/trap/eldritch/alert
	name = "alert carving"
	icon_state = "alert_rune"
	alpha = 10
	time_between_triggers = 5 SECONDS
	sparks = FALSE
	carver_tip = "Почти невидимая руна, которая, если на нее наступить, оповещает резчика о том, кто и где ее вызвал."

/obj/structure/trap/eldritch/alert/trap_effect(mob/living/victim)
	var/mob/living/real_owner = owner?.resolve()
	if(real_owner)
		to_chat(real_owner, span_userdanger("[victim.real_name] has stepped foot on the alert rune in [get_area(src)]!"))
		real_owner.playsound_local(get_turf(real_owner), 'sound/effects/magic/curse.ogg', 50, TRUE)

/obj/structure/trap/eldritch/tentacle
	name = "grasping carving"
	icon_state = "tentacle_rune"
	time_between_triggers = 45 SECONDS
	charges = 1
	carver_tip = "Когда на него наступают, наносит сильный урон по ногам и оглушает жертву на 5 секунд. Имеет 1 заряд."

/obj/structure/trap/eldritch/tentacle/trap_effect(mob/living/victim)
	if(!iscarbon(victim))
		return
	var/mob/living/carbon/carbon_victim = victim
	carbon_victim.Paralyze(5 SECONDS)
	carbon_victim.apply_damage(20, BRUTE, BODY_ZONE_R_LEG)
	carbon_victim.apply_damage(20, BRUTE, BODY_ZONE_L_LEG)
	playsound(src, 'sound/effects/magic/demon_attack1.ogg', 75, TRUE)

/obj/structure/trap/eldritch/mad
	name = "mad carving"
	icon_state = "madness_rune"
	time_between_triggers = 20 SECONDS
	charges = 2
	carver_tip = "При наступлении на жертву наносит большой урон стамине, слепоту и различные заболевания. Имеет 2 заряда."

/obj/structure/trap/eldritch/mad/trap_effect(mob/living/victim)
	if(!iscarbon(victim))
		return
	var/mob/living/carbon/carbon_victim = victim
	carbon_victim.adjust_stamina_loss(80)
	carbon_victim.adjust_silence(20 SECONDS)
	carbon_victim.adjust_stutter(1 MINUTES)
	carbon_victim.adjust_confusion(5 SECONDS)
	carbon_victim.set_jitter_if_lower(20 SECONDS)
	carbon_victim.set_dizzy_if_lower(40 SECONDS)
	carbon_victim.adjust_temp_blindness(4 SECONDS)
	carbon_victim.add_mood_event("gates_of_mansus", /datum/mood_event/gates_of_mansus)
	playsound(src, 'sound/effects/magic/blind.ogg', 75, TRUE)
