// Ratwood's washing on medieval maps (turfs/open/water.dm attack_right(), modules/hotspring/hotspring.dm attack_right(),
// items/soap.dm, rogueitems/broom.dm, modular_azurepeak relaxing_bath.dm). A right click with an empty hand on water or a hot
// spring washes oneself, with something in the hand washes that: a few seconds, then clean, fire put out, cold water cooling a
// hot body and a bath warming a cold one and cooling a hot one. Sewage and blood do not clean; sewage reeks, blood bloodies,
// and a sewer or a bog may leave a leech. In the bathhouse (standing in its water) or on a hot spring the wash is a relaxing soak
// instead: every ten seconds it heals, refills energy, and after a long enough soak lifts a step of night fatigue with dream
// points and a triumph; soap someone scrubbed you with makes the soak quicker, armour spoils it. Soap scrubs a bather in a bath
// or a hot spring; Ratwood's herbal soap cleans as soap does. A broom sweeps dirt away (and gets bloody). The wood bins of
// water are survival/vessels.dm, the water and the hot springs themselves rockhill/swimming.dm.

#define WASH_SOUNDS list('modular_redtard/survival/sound/waterwash1.ogg', 'modular_redtard/survival/sound/waterwash2.ogg')
#define SOAK_SOUNDS list('modular_redtard/rockhill/sound/foley/watermove (1).ogg', 'modular_redtard/rockhill/sound/foley/watermove (2).ogg', 'modular_redtard/survival/sound/waterwash1.ogg', 'modular_redtard/survival/sound/waterwash2.ogg')
#define SWEEP_SOUNDS list('modular_redtard/rockhill/sound/foley/cloth_wipe (1).ogg', 'modular_redtard/rockhill/sound/foley/cloth_wipe (2).ogg', 'modular_redtard/rockhill/sound/foley/cloth_wipe (3).ogg')
/// Mood categories: the sewer's reek (Ratwood sewertouched) and the soap scrub of a bath (Ratwood bath, bathcleaned).
#define SEWER_MOOD "rogue_sewer"
#define BATH_MOOD "rogue_bath"
/// A helmet of this stab armour or more spoils a soak, as body armour does (Ratwood relaxing_bath()).
#define BATH_HELMET_STAB 70

// --- Washing at water

/// Ratwood attack_right() with an empty hand: wash in the water, or soak in a bath one stands in.
/turf/open/water/rockhill/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !rogue_survival_enabled() || !isliving(user))
		return
	var/mob/living/washer = user
	if(washer.stat == STABLE)
		INVOKE_ASYNC(src, PROC_REF(rogue_wash_self), washer)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Ratwood attack_right() with something in the hand: wash it in the water.
/turf/open/water/rockhill/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	if(!rogue_survival_enabled() || user.stat != STABLE)
		return ..()
	INVOKE_ASYNC(src, PROC_REF(rogue_wash_item), tool, user)
	return ITEM_INTERACT_SUCCESS

/// Ratwood attack_right(): a bath soaks whoever stands in it (in the water they stand in); other water washes.
/turf/open/water/rockhill/proc/rogue_wash_self(mob/living/washer)
	playsound(washer, pick(WASH_SOUNDS), 100, FALSE)
	var/turf/open/water/rockhill/pool = washer.loc
	if(rogue_bath && ishuman(washer) && istype(pool) && pool.rogue_bath)
		var/mob/living/carbon/human/bather = washer
		bather.rogue_relaxing_bath(pool)
		return
	washer.visible_message(span_info("[washer] starts to wash in [src]."))
	if(!do_after(washer, rogue_value("wash_time"), src))
		return
	rogue_washed(washer)

/// Ratwood attack_right(): what a wash in this water does to the washer.
/turf/open/water/rockhill/proc/rogue_washed(mob/living/washer)
	if(rogue_wash_in)
		washer.rogue_wash_body()
	playsound(washer, pick(WASH_SOUNDS), 100, FALSE)
	washer.extinguish_mob()
	if(rogue_cooling_water())
		washer.rogue_chill(rogue_value("wash_cooling"), rogue_value("swim_cold_floor"))
	if(rogue_warm_water())
		washer.rogue_soothe(rogue_value("wash_bath_warmth"))
	if(rogue_sewage)
		washer.add_mood_event(SEWER_MOOD, /datum/mood_event/rogue_sewer)
	if(rogue_foul_wash && ishuman(washer) && !HAS_TRAIT(washer, TRAIT_LEECHIMMUNE) && prob(rogue_value("leech_wash_chance")))
		rogue_set_wild_leech(washer, list(BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_HEAD))
	if(rogue_bloody)
		washer.add_blood_DNA(washer.get_blood_dna_list())

/turf/open/water/rockhill/proc/rogue_wash_item(obj/item/tool, mob/living/washer)
	playsound(washer, pick(WASH_SOUNDS), 100, FALSE)
	washer.visible_message(span_info("[washer] starts to wash [tool] in [src]."))
	if(!do_after(washer, rogue_value("wash_time"), src) || QDELETED(tool) || !washer.is_holding(tool))
		return
	rogue_item_washed(tool, washer)

/// Ratwood attack_right(): what a wash in this water does to the thing washed.
/turf/open/water/rockhill/proc/rogue_item_washed(obj/item/tool, mob/living/washer)
	if(rogue_wash_in)
		tool.wash(CLEAN_SCRUB)
	if(rogue_bloody)
		tool.add_blood_DNA(washer.get_blood_dna_list())
	washer.update_held_items()
	playsound(washer, pick(WASH_SOUNDS), 100, FALSE)

/// Ratwood wash_atom(CLEAN_STRONG) of a washer: clean, and rid of the sewer's reek.
/mob/living/proc/rogue_wash_body()
	wash(CLEAN_SCRUB)
	clear_mood_event(SEWER_MOOD)

/// Ratwood: warm water warms a cold body and cools a hot one, towards the normal (TG's own limits stand for Ratwood's wider ones).
/mob/living/proc/rogue_soothe(amount)
	if(bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT)
		rogue_warm(amount, BODYTEMP_NORMAL)
	else if(bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		rogue_chill(amount, BODYTEMP_NORMAL)

// --- Washing at a hot spring

/obj/structure/hotspring/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !rogue_survival_enabled() || !isliving(user))
		return
	var/mob/living/washer = user
	if(washer.stat == STABLE)
		INVOKE_ASYNC(src, PROC_REF(rogue_wash_self), washer)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/hotspring/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	if(!rogue_survival_enabled() || user.stat != STABLE)
		return ..()
	INVOKE_ASYNC(src, PROC_REF(rogue_wash_item), tool, user)
	return ITEM_INTERACT_SUCCESS

/// Ratwood hotspring attack_right(): one standing in a spring soaks in it; one beside it washes.
/obj/structure/hotspring/proc/rogue_wash_self(mob/living/washer)
	playsound(washer, pick(WASH_SOUNDS), 100, FALSE)
	var/obj/structure/hotspring/pool = locate() in get_turf(washer)
	if(ishuman(washer) && pool)
		var/mob/living/carbon/human/bather = washer
		bather.rogue_relaxing_bath(pool)
		return
	washer.visible_message(span_info("[washer] starts to wash in [src]."))
	if(!do_after(washer, rogue_value("wash_time"), src))
		return
	rogue_washed(washer)

/obj/structure/hotspring/proc/rogue_washed(mob/living/washer)
	washer.rogue_wash_body()
	playsound(washer, pick(WASH_SOUNDS), 100, FALSE)
	washer.rogue_soothe(rogue_value("wash_bath_warmth"))

/obj/structure/hotspring/proc/rogue_wash_item(obj/item/tool, mob/living/washer)
	playsound(washer, pick(WASH_SOUNDS), 100, FALSE)
	washer.visible_message(span_info("[washer] starts to wash [tool] in [src]."))
	if(!do_after(washer, rogue_value("wash_time"), src) || QDELETED(tool) || !washer.is_holding(tool))
		return
	tool.wash(CLEAN_SCRUB)
	washer.update_held_items()
	playsound(washer, pick(WASH_SOUNDS), 100, FALSE)

// --- The relaxing bath (Azure Peak relaxing_bath.dm, as Ratwood has it)

/// Ratwood relaxing_bath(): a soak every ten seconds while the bather stays where they settled.
/mob/living/carbon/human/proc/rogue_relaxing_bath(atom/pool)
	var/turf/spot = loc
	playsound(src, pick(SOAK_SOUNDS), 100, FALSE)
	visible_message(span_info("[src] begins to soak in [pool]."), span_info("I settle into the water, beginning to soak."), span_hear("Someone sloshes idly in some water."))
	if(rogue_fatigue_stage())
		to_chat(src, span_green("I am taking a relaxing bath. It will remove this tiring feeling I suffer from."))
	else
		to_chat(src, span_green("I am taking a relaxing bath."))
	var/list/soak = list("count" = 0, "first" = TRUE, "rested" = FALSE)
	var/strength = (istype(rogue_patron, /datum/patron/divine/eora) || istype(rogue_patron, /datum/patron/inhumen/baotha)) ? rogue_value("bath_heal_blessed") : rogue_value("bath_heal")
	while(do_after(src, max(rogue_value("bath_soak_time"), 1), pool))
		if(QDELETED(pool) || loc != spot)
			to_chat(src, span_warning("I move away from the water, ending my bath."))
			return
		if(!rogue_bath_soak(soak, strength))
			return

/// One soak of the bath: the first washes off the grime; each settles the body's warmth, heals, refills energy and counts
/// towards the rest - twice or thrice with soap scrubbed in, one less (none without soap) in armour. A long enough soak lifts a
/// step of night fatigue, with dream points and a triumph; the last step ends the bath's rest. FALSE ends the bath.
/mob/living/carbon/human/proc/rogue_bath_soak(list/soak, strength)
	if(soak["first"])
		rogue_wash_body()
		visible_message(span_info("[src] washes off the grime."), span_info("The warm water cleanses me."))
		soak["first"] = FALSE
	rogue_soothe(rogue_value("wash_bath_warmth"))
	var/gained = 1
	var/soapy = FALSE
	var/datum/mood_event/soaped = mob_mood?.mood_events[BATH_MOOD]
	if(istype(soaped, /datum/mood_event/rogue_bath/scrubbed))
		gained += 2
		soapy = TRUE
	else if(istype(soaped, /datum/mood_event/rogue_bath))
		gained += 1
		soapy = TRUE
	if(rogue_bath_overdressed())
		gained -= 1
		if(prob(10))
			to_chat(src, span_warning("I'm not getting the most out of this with my outer clothes on."))
		if(!soapy)
			to_chat(src, span_warning("I'm not getting anything out of this. I should at least remove my armor and my helmet, or use some soap."))
			return FALSE
	soak["count"] += gained
	if(prob(30))
		playsound(src, pick(SOAK_SOUNDS), 50, FALSE)
	apply_status_effect(/datum/status_effect/rogue_miracle_heal, strength)
	if(rogue_energy < rogue_max_energy)
		rogue_energy_add(rogue_value("bath_energy"))
	if(soak["count"] < rogue_value("bath_soak_goal") || soak["rested"])
		return TRUE
	var/datum/component/rogue_dreams/dreams = GetComponent(/datum/component/rogue_dreams)
	if(!dreams?.tiredness)
		return TRUE
	if(dreams.tiredness == 1)
		to_chat(src, span_green("I feel completely refreshed from my soak!"))
		visible_message(span_info("[src] looks completely refreshed, the exhaustion lifting from [p_them()]."))
		soak["rested"] = TRUE
	else
		to_chat(src, span_green("I feel pretty refreshed... just a little bit more."))
		visible_message(span_info("[src] looks more refreshed than before, some exhaustion lifting from [p_them()]."))
		soak["count"] = rogue_value("bath_soak_restart")
	rogue_bath_rests(dreams)
	return TRUE

/// Ratwood remove_sleep_depravation() of a bath: a step of fatigue goes, with dream points but no dream, and a triumph.
/mob/living/carbon/human/proc/rogue_bath_rests(datum/component/rogue_dreams/dreams)
	dreams.tiredness = max(dreams.tiredness - 1, 0)
	dreams.points += rogue_value("bath_dream_points")
	dreams.rogue_sync_fatigue()
	if(ckey)
		rogue_adjust_triumphs(ckey, rogue_value("bath_triumphs"))

/// Ratwood relaxing_bath(): body armour, or a helmet that stops a stab, keeps the water off.
/mob/living/carbon/human/proc/rogue_bath_overdressed()
	if(wear_suit)
		return TRUE
	var/obj/item/clothing/helmet = head
	if(!istype(helmet))
		return FALSE
	var/datum/rogue_armor/armor = helmet.get_rogue_armor()
	return armor?.stab > BATH_HELMET_STAB

// --- Soap (Ratwood items/soap.dm)

/// A bather Ratwood's soap scrubs: someone standing in a bath or a hot spring.
/proc/rogue_soap_bather(atom/target)
	if(!rogue_survival_enabled() || !ishuman(target))
		return FALSE
	var/turf/spot = get_turf(target)
	return istype(spot, /turf/open/water/bath) || (locate(/obj/structure/hotspring) in spot)

/// Ratwood soap attack(): a few seconds of scrubbing a bather clean; a fabled lover leaves them feeling immaculate, anyone else
/// a bit cleaner - and either makes their soak count more.
/obj/item/proc/rogue_soap_scrub(mob/living/carbon/human/bather, mob/living/user)
	user.visible_message(span_info("[user] begins washing [bather] with [src]."))
	if(!do_after(user, rogue_value("soap_scrub_time"), bather))
		return FALSE
	rogue_soap_scrubbed(bather, user)
	return TRUE

/obj/item/proc/rogue_soap_scrubbed(mob/living/carbon/human/bather, mob/living/user)
	bather.wash(CLEAN_WASH)
	if(HAS_TRAIT(user, TRAIT_GOODLOVER))
		user.visible_message(span_info("[user] expertly cleans and soothes [bather] with [src]."))
		to_chat(bather, span_green("I feel so relaxed and clean!"))
		bather.add_mood_event(BATH_MOOD, /datum/mood_event/rogue_bath/scrubbed)
	else
		user.visible_message(span_info("[user] tries [user.p_their()] best to scrub [bather] with [src]."))
		to_chat(bather, span_warning("That's a bit nicer, I guess."))
		bather.add_mood_event(BATH_MOOD, /datum/mood_event/rogue_bath)

/// TG soap on someone in a bath or a hot spring scrubs them as Ratwood's soap does, instead of cleaning them as a floor.
/obj/item/soap/should_clean(datum/cleaning_source, atom/atom_to_clean, mob/living/cleaner)
	if(!rogue_soap_bather(atom_to_clean) || !isliving(cleaner))
		return ..()
	INVOKE_ASYNC(src, PROC_REF(rogue_tg_soap_scrub), atom_to_clean, cleaner)
	return CLEAN_BLOCKED

/obj/item/soap/proc/rogue_tg_soap_scrub(mob/living/carbon/human/bather, mob/living/user)
	if(rogue_soap_scrub(bather, user))
		decreaseUses(src, bather, user, TRUE)

/// Ratwood's herbal soap is Ratwood soap: it cleans what it is used on as soap does (TG's cleaner, at Ratwood's speed), slips
/// the unwary, scrubs bathers, and crumbles when used up.
/obj/item/soap/bath
	/// Ratwood uses: cleanings left.
	var/rogue_uses = 0

/obj/item/soap/bath/Initialize(mapload)
	. = ..()
	rogue_uses = rogue_value("soap_uses")
	AddComponent(/datum/component/slippery, rogue_value("soap_slip"), NO_SLIP_WHEN_WALKING)
	AddComponent(/datum/component/cleaner, rogue_value("soap_clean_time"), 0.1, pre_clean_callback = CALLBACK(src, PROC_REF(rogue_soap_check)), on_cleaned_callback = CALLBACK(src, PROC_REF(rogue_soap_used)))

/obj/item/soap/bath/examine(mob/user)
	. = ..()
	var/left = rogue_uses / max(rogue_value("soap_uses"), 1)
	if(left >= 1)
		. += span_notice("It looks freshly-made.")
	else if(left > 0.75)
		. += span_notice("It's seen some light use, but it's still pretty fresh.")
	else if(left > 0.5)
		. += span_notice("It's started to get a little smaller than it used to be, but it'll definitely still last for a while.")
	else if(left > 0.3)
		. += span_notice("It's past its prime, but it's definitely still good.")
	else if(left > 0.15)
		. += span_notice("It's dissolved quite a bit, but there's still some life to it.")
	else
		. += span_notice("There's just a tiny bit left of what it used to be; You're not sure it'll last much longer.")

/// The cleaner's check before a cleaning: a bather is scrubbed instead; anything else is cleaned as TG's soap cleans it.
/obj/item/soap/bath/proc/rogue_soap_check(datum/cleaning_source, atom/atom_to_clean, mob/living/cleaner)
	if(rogue_soap_bather(atom_to_clean) && isliving(cleaner))
		INVOKE_ASYNC(src, PROC_REF(rogue_herbal_scrub), atom_to_clean, cleaner)
		return CLEAN_BLOCKED
	. = CLEAN_ALLOWED
	if(!check_allowed_items(atom_to_clean))
		. |= CLEAN_NO_XP|CLEAN_NO_WASH

/obj/item/soap/bath/proc/rogue_herbal_scrub(mob/living/carbon/human/bather, mob/living/user)
	if(rogue_soap_scrub(bather, user))
		rogue_soap_used(src, bather, user, TRUE)

/// Ratwood decreaseUses(): every cleaning wears the soap down until it crumbles.
/obj/item/soap/bath/proc/rogue_soap_used(datum/source, atom/target, mob/living/user, clean_succeeded)
	if(!clean_succeeded)
		return
	rogue_uses--
	if(rogue_uses > 0)
		return
	if(user)
		to_chat(user, span_warning("[src] crumbles into tiny bits!"))
	qdel(src)

// --- The broom (Ratwood rogueitems/broom.dm)

/// Ratwood attack_turf() and attack_obj() with the use intent: a few seconds of sweeping the dirt off a floor.
/obj/item/broom/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!rogue_survival_enabled() || !istype(user.rogue_active_intent(), /datum/intent/use))
		return ..()
	var/turf/spot = isturf(interacting_with) ? interacting_with : null
	if(!spot && istype(interacting_with, /obj/effect/decal/cleanable))
		spot = interacting_with.loc
	if(!isturf(spot) || istype(spot, /turf/open/water))
		return ..()
	INVOKE_ASYNC(src, PROC_REF(rogue_sweep), spot, user)
	return ITEM_INTERACT_SUCCESS

/obj/item/broom/proc/rogue_sweep(turf/spot, mob/living/user)
	if(!do_after(user, rogue_value("broom_sweep_time"), spot))
		return
	rogue_swept(spot, user)

/// Ratwood: the dirt is swept away; blood is not, it soaks into the broom.
/obj/item/broom/proc/rogue_swept(turf/spot, mob/living/user)
	var/swept = FALSE
	for(var/obj/effect/decal/cleanable/dirt/dirt in spot)
		qdel(dirt)
		swept = TRUE
	if(swept)
		user.visible_message(span_notice("[user] sweeps \the [spot]."), span_notice("I sweep \the [spot]."))
		playsound(user, pick(SWEEP_SOUNDS), 100, TRUE)
	for(var/obj/effect/decal/cleanable/blood/blood in spot)
		add_blood_DNA(GET_ATOM_BLOOD_DNA(blood))
		break
	return swept

// --- Moods of washing (Ratwood stress events)

/datum/mood_event/rogue_sewer
	description = "Putrid stinking water!"
	mood_change = -2 * ROGUE_STRESS_TO_MOOD
	timeout = 5 MINUTES

/datum/mood_event/rogue_bath
	description = "I'm just a bit cleaner."
	mood_change = 1 * ROGUE_STRESS_TO_MOOD
	timeout = 10 MINUTES

/datum/mood_event/rogue_bath/scrubbed
	description = "I feel immaculate!"
	mood_change = 3 * ROGUE_STRESS_TO_MOOD
	timeout = 20 MINUTES

#undef WASH_SOUNDS
#undef SOAK_SOUNDS
#undef SWEEP_SOUNDS
#undef SEWER_MOOD
#undef BATH_MOOD
#undef BATH_HELMET_STAB
