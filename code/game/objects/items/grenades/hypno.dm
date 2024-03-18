/obj/item/grenade/hypnotic
	name = "flashbang"
	desc = "A modified flashbang which uses hypnotic flashes and mind-altering soundwaves to induce an instant trance upon detonation. \
		It seems you can set an hypnotic phrase that's uttered when triggered"
	icon_state = "flashbang"
	inhand_icon_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	var/flashbang_range = 7
	///hypno text that is said when the grenade is triggered
	var/hypno_text
	verb_say = "beeps"
	verb_ask = "inquires"
	verb_yell = "blares"
	verb_exclaim = "bleeps"

/obj/item/grenade/hypnotic/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/grenade/hypnotic/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_RMB] = "Set Hypno Text"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/grenade/hypnotic/apply_grenade_fantasy_bonuses(quality)
	flashbang_range = modify_fantasy_variable("flashbang_range", flashbang_range, quality)

/obj/item/grenade/hypnotic/remove_grenade_fantasy_bonuses(quality)
	flashbang_range = reset_fantasy_variable("flashbang_range", flashbang_range)

/obj/item/grenade/hypnotic/attack_self_secondary(mob/user, modifiers)
	. = ..()
	input_hypnotic_text(user)

/obj/item/grenade/hypnotic/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	input_hypnotic_text(user)

/obj/item/grenade/hypnotic/proc/input_hypnotic_text(mob/user)
	var/hypno_text_input = tgui_input_text(user, "Enter a hypnotic command.", "Hypnotic Command Phrase", TRUE)
	if(!hypno_text_input)
		return
	if(is_ic_filtered(hypno_text_input))
		to_chat(user, span_warning("Error: Hypnotic commmand contains invalid text."))
		return
	var/list/soft_filter_result = is_soft_ooc_filtered(hypno_text_input)
	if(soft_filter_result)
		if(tgui_alert(user,"Your command contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to use it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term for an Hypnotic command. Command: \"[html_encode(hypno_text_input)]\"")
		log_admin_private("[key_name(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term for an Hypnotic command. Command: \"[hypno_text_input]\"")
	hypno_text = hypno_text_input

/obj/item/grenade/hypnotic/detonate(mob/living/lanced_by)
	. = ..()
	if(!.)
		return

	update_mob()
	var/flashbang_turf = get_turf(src)
	if(!flashbang_turf)
		return
	do_sparks(rand(5, 9), FALSE, src)
	playsound(flashbang_turf, 'sound/effects/screech.ogg', 100, TRUE, 8, 0.9)
	new /obj/effect/dummy/lighting_obj (flashbang_turf, flashbang_range + 2, 4, LIGHT_COLOR_PURPLE, 2)
	for(var/mob/living/living_mob in get_hearers_in_view(flashbang_range, flashbang_turf))
		bang(get_turf(living_mob), living_mob)
	if(hypno_text) //Sanity check if it's hypno text is null
		say(hypno_text)
	qdel(src)

/obj/item/grenade/hypnotic/proc/bang(turf/turf, mob/living/living_mob)
	if(living_mob.stat == DEAD) //They're dead!
		return
	var/distance = max(0, get_dist(get_turf(src), turf))

	//Bang
	var/hypno_sound = FALSE

	//Hearing protection check
	if(iscarbon(living_mob))
		var/mob/living/carbon/target = living_mob
		var/list/reflist = list(1)
		SEND_SIGNAL(target, COMSIG_CARBON_SOUNDBANG, reflist)
		var/intensity = reflist[1]
		var/ear_safety = target.get_ear_protection()
		var/effect_amount = intensity - ear_safety
		if(effect_amount > 0)
			hypno_sound = TRUE

	if(!distance || loc == living_mob || loc == living_mob.loc)
		living_mob.Paralyze(10)
		living_mob.Knockdown(100)
		to_chat(living_mob, span_hypnophrase("The sound echoes in your brain..."))
		living_mob.adjust_hallucinations(100 SECONDS)

	else
		if(distance <= 1)
			living_mob.Paralyze(5)
			living_mob.Knockdown(30)
		if(hypno_sound)
			to_chat(living_mob, span_hypnophrase("The sound echoes in your brain..."))
			living_mob.adjust_hallucinations(100 SECONDS)

	//Flash
	if(living_mob.flash_act(affect_silicon = 1))
		living_mob.Paralyze(max(10/max(1, distance), 5))
		living_mob.Knockdown(max(100/max(1, distance), 40))
		if(iscarbon(living_mob))
			var/mob/living/carbon/target = living_mob
			if(target.hypnosis_vulnerable()) //The sound causes the necessary conditions unless the target has mindshield or hearing protection
				target.apply_status_effect(/datum/status_effect/trance, 100, TRUE)
			else
				to_chat(target, span_hypnophrase("The light is so pretty..."))
				target.adjust_drowsiness_up_to(20 SECONDS, 40 SECONDS)
				target.adjust_confusion_up_to(10 SECONDS, 20 SECONDS)
				target.adjust_dizzy_up_to(20 SECONDS, 40 SECONDS)
