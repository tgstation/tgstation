GLOBAL_LIST_INIT(rogue_grab_passive_intents, list(/datum/intent/grab/upgrade))
GLOBAL_LIST_INIT(rogue_grab_creature_intents, list(/datum/intent/grab/move))
GLOBAL_LIST_INIT(rogue_grab_limb_intents, list(/datum/intent/grab/move, /datum/intent/grab/twist, /datum/intent/grab/smash))
GLOBAL_LIST_INIT(rogue_grab_zone_intents, list(
	"head" = list(/datum/intent/grab/move, /datum/intent/grab/twist, /datum/intent/grab/smash),
	"ears" = list(/datum/intent/grab/move, /datum/intent/grab/twist, /datum/intent/grab/smash),
	"nose" = list(/datum/intent/grab/move, /datum/intent/grab/twist, /datum/intent/grab/smash),
	"mouth" = list(/datum/intent/grab/move, /datum/intent/grab/twist, /datum/intent/grab/smash),
	"skull" = list(/datum/intent/grab/move, /datum/intent/grab/smash),
	"r_eye" = list(/datum/intent/grab/move, /datum/intent/grab/smash),
	"l_eye" = list(/datum/intent/grab/move, /datum/intent/grab/smash),
	BODY_ZONE_PRECISE_EYES = list(/datum/intent/grab/move, /datum/intent/grab/smash),
	"neck" = list(/datum/intent/grab/move, /datum/intent/grab/choke, /datum/intent/grab/hostage),
	"chest" = list(/datum/intent/grab/move, /datum/intent/grab/shove),
	"stomach" = list(/datum/intent/grab/move, /datum/intent/grab/shove),
	"groin" = list(/datum/intent/grab/move, /datum/intent/grab/twist, /datum/intent/grab/shove),
	"r_hand" = list(/datum/intent/grab/move, /datum/intent/grab/twist, /datum/intent/grab/smash, /datum/intent/grab/disarm),
	"l_hand" = list(/datum/intent/grab/move, /datum/intent/grab/twist, /datum/intent/grab/smash, /datum/intent/grab/disarm),
))
GLOBAL_LIST_INIT(rogue_zone_names, list(
	"r_eye" = "right eye",
	"l_eye" = "left eye",
	"r_arm" = "right arm",
	"l_arm" = "left arm",
	"r_hand" = "right hand",
	"l_hand" = "left hand",
	"r_leg" = "right leg",
	"l_leg" = "left leg",
	"r_foot" = "right foot",
	"l_foot" = "left foot",
))

/proc/rogue_zone_name(zone)
	return GLOB.rogue_zone_names[zone] || parse_zone(zone)

/proc/rogue_zone_target(zone)
	return check_zone(GLOB.rogue_precise_zone_map[zone] || zone)

/proc/rogue_badluck_message(mob/living/user)
	var/static/list/lines = list("Critical miss!", "Damn! Critical miss!", "No! Critical miss!", "It can't be! Critical miss!", "Bad luck! Critical miss!", "What?! Critical miss!")
	to_chat(user, span_boldwarning(pick(lines)))

/datum/intent/grab
	unarmed = TRUE
	no_attack = TRUE
	canparry = FALSE
	candodge = FALSE
	attack_verb = null
	clickcd = CLICK_CD_GRABBING
	misscost = 2
	releasedrain = 2

/datum/intent/grab/proc/grab_target(obj/item/hand_item/rogue_grab/grip, mob/living/carbon/human/user)
	return FALSE

/datum/intent/grab/proc/grab_place(obj/item/hand_item/rogue_grab/grip, mob/living/carbon/human/user, atom/place)
	return FALSE

/datum/intent/grab/move
	name = "grab move"
	desc = "Drag the one you hold towards the place you click."
	icon_state = "inmove"

/datum/intent/grab/move/grab_place(obj/item/hand_item/rogue_grab/grip, mob/living/carbon/human/user, atom/place)
	if(!isturf(place))
		return FALSE
	user.changeNext_move(CLICK_CD_GRABBING)
	user.Move_Pulled(place)
	return TRUE

/datum/intent/grab/upgrade
	name = "upgrade grab"
	desc = "Tighten the grip, if you overpower them."
	icon_state = "ingrab"

/datum/intent/grab/upgrade/grab_target(obj/item/hand_item/rogue_grab/grip, mob/living/carbon/human/user)
	return user.rogue_grab_upgrade(grip)

/datum/intent/grab/smash
	name = "smash"
	desc = "Smash the limb you hold into the floor, a wall or furniture."
	icon_state = "insmash"

/datum/intent/grab/smash/grab_place(obj/item/hand_item/rogue_grab/grip, mob/living/carbon/human/user, atom/place)
	return user.rogue_grab_smash(grip, place)

/datum/intent/grab/twist
	name = "twist"
	desc = "Twist the limb you hold."
	icon_state = "intwist"

/datum/intent/grab/twist/grab_target(obj/item/hand_item/rogue_grab/grip, mob/living/carbon/human/user)
	return user.rogue_grab_twist(grip)

/datum/intent/grab/choke
	name = "choke"
	desc = "Squeeze the throat you hold; from behind it is a chokehold."
	icon_state = "inchoke"

/datum/intent/grab/choke/grab_target(obj/item/hand_item/rogue_grab/grip, mob/living/carbon/human/user)
	return user.rogue_grab_choke(grip)

/datum/intent/grab/hostage
	name = "hostage"
	desc = "Hold them by the neck; if they move or struggle, the weapon in your other hand strikes."
	icon_state = "inhostage"

/datum/intent/grab/hostage/grab_target(obj/item/hand_item/rogue_grab/grip, mob/living/carbon/human/user)
	return user.rogue_grab_hostage(grip)

/datum/intent/grab/shove
	name = "shove"
	desc = "Throw them to the ground, or pin them there while standing over them."
	icon_state = "intackle"

/datum/intent/grab/shove/grab_target(obj/item/hand_item/rogue_grab/grip, mob/living/carbon/human/user)
	return user.rogue_grab_shove(grip)

/datum/intent/grab/disarm
	name = "disarm"
	desc = "Wrest away what the hand you hold is carrying."
	icon_state = "intake"

/datum/intent/grab/disarm/grab_target(obj/item/hand_item/rogue_grab/grip, mob/living/carbon/human/user)
	return user.rogue_grab_disarm(grip)

/obj/item/hand_item/rogue_grab
	name = "grip"
	desc = "Someone held in a grip."
	icon = ROGUE_HUD_ICON_GRABS
	icon_state = "grabbing"
	w_class = WEIGHT_CLASS_HUGE
	var/mob/living/grabbed
	var/zone = BODY_ZONE_CHEST
	var/holding_hostage = FALSE

/obj/item/hand_item/rogue_grab/Initialize(mapload, mob/living/target, grab_zone)
	. = ..()
	if(!istype(target))
		return INITIALIZE_HINT_QDEL
	grabbed = target
	zone = grab_zone || BODY_ZONE_CHEST
	name = "[target.name]'s [rogue_zone_name(zone)]"
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_grabbed_deleted))

/obj/item/hand_item/rogue_grab/Destroy()
	set_hostage(FALSE)
	var/mob/living/holder = loc
	if(grabbed)
		UnregisterSignal(grabbed, COMSIG_QDELETING)
		if(istype(holder) && holder.pulling == grabbed)
			holder.stop_pulling()
	grabbed = null
	return ..()

/obj/item/hand_item/rogue_grab/dropped(mob/user, silent)
	set_hostage(FALSE)
	if(grabbed && user.pulling == grabbed)
		user.stop_pulling()
	return ..()

/obj/item/hand_item/rogue_grab/proc/on_grabbed_deleted(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/obj/item/hand_item/rogue_grab/rogue_intents()
	var/mob/living/holder = loc
	if(!istype(holder) || holder.grab_state < GRAB_AGGRESSIVE)
		return GLOB.rogue_grab_passive_intents
	if(!iscarbon(grabbed))
		return GLOB.rogue_grab_creature_intents
	return GLOB.rogue_grab_zone_intents[zone] || GLOB.rogue_grab_limb_intents

/obj/item/hand_item/rogue_grab/attack_self(mob/user, modifiers)
	qdel(src)
	return TRUE

/obj/item/hand_item/rogue_grab/proc/is_chokehold(mob/living/holder)
	return zone == "neck" && holder.grab_state >= GRAB_AGGRESSIVE && grabbed.dir == REVERSE_DIR(get_dir(grabbed, holder))

/obj/item/hand_item/rogue_grab/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!ishuman(user) || QDELETED(grabbed) || user.pulling != grabbed)
		qdel(src)
		return ITEM_INTERACT_BLOCKING
	var/mob/living/carbon/human/grabber = user
	var/datum/intent/grab/intent = grabber.rogue_active_intent()
	if(!istype(intent))
		return ITEM_INTERACT_BLOCKING
	if(interacting_with == grabber)
		if(grabber.combat_mode && rogue_zone_target(zone) == BODY_ZONE_HEAD)
			grabber.rogue_headbutt(src)
		return ITEM_INTERACT_BLOCKING
	if(interacting_with == grabbed)
		grabber.changeNext_move(max(ROGUE_GRAB_ACTION_DELAY - grabber.rogue_stat(ROGUE_STAT_SPEED), CLICK_CD_GRABBING))
		intent.grab_target(src, grabber)
		return ITEM_INTERACT_SUCCESS
	if(isturf(interacting_with) || isstructure(interacting_with))
		intent.grab_place(src, grabber, interacting_with)
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/item/hand_item/rogue_grab/proc/set_hostage(taken)
	if(holding_hostage == taken || (taken && !grabbed))
		return
	holding_hostage = taken
	var/mob/living/holder = loc
	if(taken)
		RegisterSignals(grabbed, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_RESIST), PROC_REF(on_hostage_struggle))
		if(istype(holder))
			RegisterSignal(holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_taker_moved))
		return
	if(grabbed)
		UnregisterSignal(grabbed, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_RESIST))
	if(istype(holder))
		UnregisterSignal(holder, COMSIG_MOVABLE_MOVED)

/obj/item/hand_item/rogue_grab/proc/on_hostage_struggle(datum/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/taker = loc
	set_hostage(FALSE)
	if(!istype(taker))
		return
	var/obj/item/weapon = taker.get_active_held_item()
	if(!weapon || weapon == src)
		weapon = taker.get_inactive_held_item()
	if(!weapon || weapon == src || !weapon.force)
		return
	taker.visible_message(span_danger("[taker] attacks [grabbed] reflexively!"))
	INVOKE_ASYNC(weapon, TYPE_PROC_REF(/obj/item, melee_attack_chain), taker, grabbed)

/obj/item/hand_item/rogue_grab/proc/on_taker_moved(datum/source)
	SIGNAL_HANDLER
	set_hostage(FALSE)
	to_chat(source, span_danger("I need to stand still to keep my hostage!"))

/datum/element/rogue_combat/proc/on_start_pull(mob/living/carbon/human/source, atom/movable/pulled, state, force)
	SIGNAL_HANDLER
	if(!isliving(pulled) || pulled == source)
		return
	for(var/obj/item/hand_item/rogue_grab/grip in source.held_items)
		if(grip.grabbed == pulled)
			return
	var/obj/item/hand_item/rogue_grab/grip = new(source, pulled, source.rogue_precise_zone())
	if(!source.put_in_hands(grip))
		qdel(grip)
		return
	source.rogue_refresh_intents()

/datum/element/rogue_combat/proc/on_stop_pull(mob/living/carbon/human/source, atom/movable/old_pulling)
	SIGNAL_HANDLER
	for(var/obj/item/hand_item/rogue_grab/grip in source.held_items)
		if(!QDELETED(grip))
			qdel(grip)
	source.rogue_refresh_intents()

/datum/element/rogue_combat/proc/on_grab_state(mob/living/carbon/human/source, new_state)
	SIGNAL_HANDLER
	source.rogue_refresh_intents()

/mob/living/carbon/human/proc/rogue_unarmed_damage()
	var/obj/item/clothing/gloves/worn_gloves = gloves
	return rogue_formula_value(ROGUE_FORMULA_UNARMED_DAMAGE, list("strength" = rogue_stat(ROGUE_STAT_STRENGTH), "civilized" = HAS_TRAIT(src, TRAIT_CIVILIZEDBARBARIAN), "gloves" = istype(worn_gloves) ? worn_gloves.unarmed_bonus : 0))

/obj/item/clothing/gloves
	/// Flat bare-handed damage added after strength (Ratwood gloves, bandages and knuckles after the Azure Peak unarmed rework).
	var/unarmed_bonus = 0

/obj/item/clothing/gloves/examine(mob/user)
	. = ..()
	if(unarmed_bonus > 0)
		. += span_notice("Unarmed damage bonus: +[unarmed_bonus] (flat, applied after strength scaling).")

/mob/living/carbon/human/proc/rogue_grab_modifier(mob/living/target, obj/item/hand_item/rogue_grab/grip)
	var/modifier = target.has_status_effect(/datum/status_effect/rogue_compliance) ? ROGUE_GRAB_COMPLIANT_MODIFIER : 1
	if(HAS_TRAIT(target, TRAIT_RESTRAINED))
		modifier += ROGUE_GRAB_RESTRAINED_BONUS
	if(target.body_position == LYING_DOWN && body_position == STANDING_UP)
		modifier += ROGUE_GRAB_PRONE_BONUS
	if(combat_mode && !target.combat_mode)
		modifier += ROGUE_GRAB_COMBAT_BONUS
	else if(!combat_mode && target.combat_mode)
		modifier -= ROGUE_GRAB_COMBAT_BONUS
	if(grip?.is_chokehold(src))
		modifier += ROGUE_GRAB_CHOKEHOLD_BONUS
	return modifier

/mob/living/carbon/human/proc/rogue_grab_values(mob/living/target, obj/item/hand_item/rogue_grab/grip)
	return list(
		"strength_diff" = rogue_stat(ROGUE_STAT_STRENGTH) - target.rogue_stat(ROGUE_STAT_STRENGTH),
		"skill_diff" = rogue_skill_rank(/datum/attribute/skill/combat/wrestling) - target.rogue_skill_rank(/datum/attribute/skill/combat/wrestling),
		"noise" = rand(-5, 5),
		"modifier" = rogue_grab_modifier(target, grip),
	)

/mob/living/carbon/human/proc/rogue_grab_struggle(mob/living/target)
	target.visible_message(span_warning("[src] struggles with [target]!"), span_warning("[src] struggles to restrain me!"), span_hear("I hear aggressive shuffling!"), null, src)
	to_chat(src, span_warning("I struggle with [target]!"))
	playsound(target, ROGUE_GRAB_STRUGGLE_SOUND, 100, FALSE, -1)
	Immobilize(ROGUE_GRAB_STRUGGLE_USER)
	changeNext_move(ROGUE_GRAB_STRUGGLE_USER)
	target.Immobilize(ROGUE_GRAB_STRUGGLE_TARGET)
	target.changeNext_move(ROGUE_GRAB_STRUGGLE_TARGET)

/mob/living/carbon/human/proc/rogue_grab_bad_luck(chance)
	if(!rogue_badluck(chance))
		return FALSE
	rogue_badluck_message(src)
	stop_pulling()
	return TRUE

/mob/living/carbon/human/proc/rogue_grab_upgrade(obj/item/hand_item/rogue_grab/grip)
	var/mob/living/target = grip.grabbed
	if(!(target.status_flags & CANPUSH) || HAS_TRAIT(target, TRAIT_PUSHIMMUNE))
		to_chat(src, span_warning("I can't get a grip!"))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_GRABIMMUNE) && target.combat_mode)
		to_chat(src, span_warning("Can't get a grip on this one!"))
		return FALSE
	adjust_stamina_loss(rand(ROGUE_GRAB_UPGRADE_COST_MIN, ROGUE_GRAB_UPGRADE_COST_MAX))
	var/certain = target.stat != STABLE || HAS_TRAIT(target, TRAIT_RESTRAINED) || target.has_status_effect(/datum/status_effect/rogue_compliance)
	if(!certain)
		if(rogue_badluck(10))
			rogue_badluck_message(src)
			return FALSE
		if(!prob(rogue_formula_value(ROGUE_FORMULA_GRAB_CHANCE, rogue_grab_values(target, grip))))
			rogue_grab_struggle(target)
			if(rogue_badluck(5))
				rogue_badluck_message(src)
				stop_pulling()
			return FALSE
	playsound(target, ROGUE_GRAB_SOUND, 100, FALSE, -1)
	target.grippedby(src, instant = TRUE)
	rogue_mark_in_combat()
	return TRUE

/mob/living/carbon/human/proc/rogue_grab_choke(obj/item/hand_item/rogue_grab/grip)
	var/mob/living/carbon/target = grip.grabbed
	if(HAS_TRAIT(src, TRAIT_PACIFISM))
		to_chat(src, span_warning("I don't want to harm [target]!"))
		return FALSE
	if(buckled)
		to_chat(src, span_warning("I can't do this while buckled!"))
		return FALSE
	if(!iscarbon(target) || grab_state < GRAB_AGGRESSIVE || rogue_grab_bad_luck(2))
		return FALSE
	changeNext_move(CLICK_CD_GRABBING)
	adjust_stamina_loss(rand(ROGUE_GRAB_CHOKE_COST_MIN, ROGUE_GRAB_CHOKE_COST_MAX))
	if(target.get_all_covered_flags() & NECK)
		to_chat(src, span_warning("I can't reach [target]'s throat!"))
		return FALSE
	if(prob(ROGUE_GRAB_CHOKE_EMOTE_CHANCE))
		target.emote("choke")
	var/chokehold = grip.is_chokehold(src)
	target.adjust_oxy_loss(rogue_formula_value(ROGUE_FORMULA_CHOKE_DAMAGE, list(
		"strength" = rogue_stat(ROGUE_STAT_STRENGTH),
		"chokehold" = chokehold,
		"held_back" = target.pulling == src && target.grab_state >= GRAB_AGGRESSIVE,
	)))
	var/verb = pick("chokes", "strangles")
	target.visible_message(span_danger("[src] [verb] [target][chokehold ? " with a chokehold" : ""]!"), span_userdanger("[src] [verb] me[chokehold ? " with a chokehold" : ""]!"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE, src)
	to_chat(src, span_danger("I [verb == "chokes" ? "choke" : "strangle"] [target][chokehold ? " with a chokehold" : ""]!"))
	log_combat(src, target, "choked")
	rogue_mark_in_combat()
	return TRUE

/mob/living/carbon/human/proc/rogue_grab_twist(obj/item/hand_item/rogue_grab/grip)
	var/mob/living/carbon/target = grip.grabbed
	if(HAS_TRAIT(src, TRAIT_PACIFISM))
		to_chat(src, span_warning("I don't want to harm [target]!"))
		return FALSE
	if(buckled)
		to_chat(src, span_warning("I can't do this while buckled!"))
		return FALSE
	if(!iscarbon(target) || grab_state < GRAB_AGGRESSIVE || rogue_grab_bad_luck(2))
		return FALSE
	adjust_stamina_loss(rand(ROGUE_GRAB_TWIST_COST_MIN, ROGUE_GRAB_TWIST_COST_MAX))
	playsound(target, pick('modular_redtard/rockhill/sound/combat/hits/blunt/genblunt (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/blunt/genblunt (2).ogg', 'modular_redtard/rockhill/sound/combat/hits/blunt/genblunt (3).ogg'), 100, FALSE, -1)
	target.apply_damage(rogue_unarmed_damage(), BRUTE, rogue_zone_target(grip.zone))
	var/part = rogue_zone_name(grip.zone)
	target.visible_message(span_danger("[src] twists [target]'s [part]!"), span_userdanger("[src] twists my [part]!"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE, src)
	to_chat(src, span_warning("I twist [target]'s [part]."))
	log_combat(src, target, "twisted the [part] of")
	rogue_mark_in_combat()
	return TRUE

/mob/living/carbon/human/proc/rogue_grab_smash(obj/item/hand_item/rogue_grab/grip, atom/place)
	var/mob/living/carbon/target = grip.grabbed
	if(body_position != STANDING_UP)
		to_chat(src, span_warning("I must stand.."))
		return FALSE
	if(!iscarbon(target) || grab_state < GRAB_AGGRESSIVE || !target.Adjacent(place))
		return FALSE
	if(isopenturf(place) && target.body_position != LYING_DOWN)
		return FALSE
	if(isclosedturf(place) && target.body_position != STANDING_UP)
		return FALSE
	if(rogue_grab_bad_luck(4))
		return FALSE
	changeNext_move(CLICK_CD_GRABBING)
	var/damage = rogue_formula_value(ROGUE_FORMULA_GRAB_SMASH_DAMAGE, list("punch" = rogue_unarmed_damage(), "unarmed" = rogue_skill_rank(/datum/attribute/skill/combat/unarmed)))
	target.apply_damage(damage, BRUTE, rogue_zone_target(grip.zone))
	playsound(target, pick('modular_redtard/rockhill/sound/combat/hits/smashlimb (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/smashlimb (2).ogg', 'modular_redtard/rockhill/sound/combat/hits/smashlimb (3).ogg'), 100, FALSE, -1)
	var/part = rogue_zone_name(grip.zone)
	target.visible_message(span_danger("[src] smashes [target]'s [part] into [place]!"), span_userdanger("[src] smashes my [part] into [place]!"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE, src)
	to_chat(src, span_warning("I smash [target]'s [part] against [place]."))
	log_combat(src, target, "smashed the [part] of")
	rogue_mark_in_combat()
	return TRUE

/mob/living/proc/rogue_pin_hold(stun_amount, immobilize_amount)
	var/stun_before = AmountStun()
	var/immobilize_before = AmountImmobilized()
	Stun(stun_amount)
	Immobilize(immobilize_amount)
	return list(AmountStun() - stun_before, AmountImmobilized() - immobilize_before)

/mob/living/proc/rogue_release_pin(list/held)
	if(!held)
		return
	if(held[1] > 0)
		SetStun(max(0, AmountStun() - held[1]))
	if(held[2] > 0)
		SetImmobilized(max(0, AmountImmobilized() - held[2]))

/mob/living/carbon/human/proc/rogue_grab_shove(obj/item/hand_item/rogue_grab/grip)
	var/mob/living/target = grip.grabbed
	if(buckled)
		to_chat(src, span_warning("I can't do this while buckled!"))
		return FALSE
	if(rogue_grab_bad_luck(4))
		return FALSE
	if(body_position != STANDING_UP)
		to_chat(src, span_warning("I must stand.."))
		return FALSE
	var/list/values = rogue_grab_values(target, grip)
	if(target.body_position == LYING_DOWN)
		if(loc != target.loc)
			to_chat(src, span_warning("I must be above them."))
			return FALSE
		return rogue_grab_pin(grip, values)
	adjust_stamina_loss(rand(ROGUE_GRAB_SHOVE_COST_MIN, ROGUE_GRAB_SHOVE_COST_MAX))
	if(target.has_status_effect(/datum/status_effect/rogue_compliance) || prob(rogue_formula_value(ROGUE_FORMULA_GRAB_CHANCE, values)))
		target.visible_message(span_danger("[src] shoves [target] to the ground!"), span_userdanger("[src] shoves me to the ground!"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE)
		target.Knockdown(max(ROGUE_GRAB_KNOCKDOWN_BASE + values["skill_diff"] * ROGUE_GRAB_KNOCKDOWN_PER_SKILL, 1))
		log_combat(src, target, "shoved down")
	else
		target.visible_message(span_warning("[src] tries to shove [target]!"), span_danger("[src] tries to shove me!"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE)
	rogue_mark_in_combat()
	return TRUE

/mob/living/carbon/human/proc/rogue_grab_pin(obj/item/hand_item/rogue_grab/grip, list/values)
	var/mob/living/target = grip.grabbed
	var/pin_time = rogue_formula_value(ROGUE_FORMULA_GRAB_PIN_TIME, values)
	var/pins = 0
	var/list/held
	adjust_stamina_loss(rand(ROGUE_GRAB_PIN_COST_MIN, ROGUE_GRAB_PIN_COST_MAX))
	held = target.rogue_pin_hold(pin_time - ROGUE_GRAB_PIN_FIRST_CUT, pin_time)
	target.visible_message(span_danger("[src] pins [target] to the ground!"), span_userdanger("[src] pins me to the ground!"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE)
	log_combat(src, target, "pinned")
	rogue_mark_in_combat()
	while(target.IsStun())
		if(!do_after(src, pin_time + 1, target = target) || QDELETED(grip) || pulling != target || target.body_position != LYING_DOWN)
			break
		pins += ROGUE_GRAB_PIN_DECAY
		held = target.rogue_pin_hold(pin_time - pins, pin_time)
		adjust_stamina_loss(rand(ROGUE_GRAB_PIN_COST_MIN, ROGUE_GRAB_PIN_COST_MAX) + abs(values["skill_diff"]) + pin_time * ROGUE_GRAB_PIN_COST_TIME_FACTOR)
		target.visible_message(span_danger("[src] keeps [target] pinned to the ground!"))
	target.rogue_release_pin(held)
	return TRUE

/mob/living/carbon/human/proc/rogue_grab_disarm(obj/item/hand_item/rogue_grab/grip)
	var/mob/living/target = grip.grabbed
	if(rogue_grab_bad_luck(4))
		return FALSE
	var/obj/item/held_item = target.get_item_for_held_index(grip.zone == "l_hand" ? LEFT_HANDS : RIGHT_HANDS)
	adjust_stamina_loss(rand(ROGUE_GRAB_DISARM_COST_MIN, ROGUE_GRAB_DISARM_COST_MAX))
	if(!held_item)
		to_chat(src, span_warning("They aren't holding anything in that hand!"))
		return FALSE
	var/list/values = rogue_grab_values(target, grip)
	values -= "noise"
	values["weapon_skill"] = target.rogue_weapon_rank(held_item, null)
	values["wielded"] = held_item.rogue_wielded
	var/chance = rogue_formula_value(ROGUE_FORMULA_GRAB_DISARM_CHANCE, values)
	rogue_mark_in_combat()
	if(prob(chance))
		target.dropItemToGround(held_item)
		stop_pulling()
		put_in_active_hand(held_item)
		target.visible_message(span_danger("[src] takes [held_item] from [target]'s hand!"), span_userdanger("[src] takes [held_item] from my hand!"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE)
		changeNext_move(ROGUE_GRAB_DISARM_CLICK)
		playsound(target, 'sound/items/weapons/thudswoosh.ogg', 100, FALSE, -1)
		log_combat(src, target, "took [held_item] from")
		return TRUE
	if(prob(chance + ROGUE_GRAB_DISARM_DROP_BONUS))
		target.dropItemToGround(held_item)
		target.visible_message(span_danger("[src] disarms [target] of [held_item]!"), span_userdanger("[src] disarms me of [held_item]!"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE)
		target.Stun(ROGUE_GRAB_DISARM_STUN)
		log_combat(src, target, "disarmed [held_item] from")
		return TRUE
	Immobilize(ROGUE_GRAB_STRUGGLE_TARGET)
	target.Immobilize(ROGUE_GRAB_STRUGGLE_TARGET)
	target.visible_message(span_notice("[src] struggles to disarm [target]!"))
	playsound(target, ROGUE_GRAB_STRUGGLE_SOUND, 100, FALSE, -1)
	return FALSE

/mob/living/carbon/human/proc/rogue_grab_hostage(obj/item/hand_item/rogue_grab/grip)
	var/mob/living/carbon/human/target = grip.grabbed
	if(buckled)
		to_chat(src, span_warning("I can't do this while buckled!"))
		return FALSE
	if(!ishuman(target) || grab_state < GRAB_AGGRESSIVE || !combat_mode || rogue_grab_bad_luck(4))
		return FALSE
	if(target.combat_mode)
		to_chat(src, span_warning("[target] is too prepared for combat to be taken hostage."))
		return FALSE
	grip.set_hostage(TRUE)
	swap_hand(get_inactive_hand_index())
	to_chat(src, span_warning("I take [target] hostage."))
	to_chat(target, span_danger("[src] takes me hostage!"))
	log_combat(src, target, "took hostage")
	return TRUE

/mob/living/carbon/human/proc/rogue_headbutt(obj/item/hand_item/rogue_grab/grip)
	var/mob/living/carbon/target = grip.grabbed
	if(!iscarbon(target))
		return FALSE
	changeNext_move(CLICK_CD_RESIST)
	var/damage = rogue_unarmed_damage()
	playsound(target, pick('modular_redtard/rockhill/sound/combat/hits/blunt/genblunt (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/blunt/genblunt (2).ogg', 'modular_redtard/rockhill/sound/combat/hits/blunt/genblunt (3).ogg'), 100, FALSE, -1)
	target.apply_damage(damage * ROGUE_GRAB_HEADBUTT_TARGET_FACTOR, BRUTE, BODY_ZONE_HEAD)
	apply_damage(damage, BRUTE, BODY_ZONE_HEAD)
	target.stop_pulling()
	target.Immobilize(ROGUE_GRAB_HEADBUTT_TARGET_HOLD)
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		human_target.rogue_off_balance(ROGUE_GRAB_HEADBUTT_TARGET_HOLD)
	Immobilize(ROGUE_GRAB_HEADBUTT_USER_HOLD)
	target.visible_message(span_danger("[src] headbutts [target]!"), span_userdanger("[src] headbutts me!"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE, src)
	to_chat(src, span_warning("I headbutt [target]."))
	log_combat(src, target, "headbutted")
	rogue_mark_in_combat()
	return TRUE

/// Grabbing oneself (TG's self_grasp, /mob/living/carbon/grabbedby() with the grabber as the target): TG lets one grasp only a
/// bleeding or wounded limb and says nothing otherwise, Ratwood any limb of one's own (grippedby(): instant on oneself). The
/// grasp still staunches the bleeding when there is any.
/obj/item/bodypart/can_be_grasped()
	return ..() || (owner && rogue_combat_enabled())
