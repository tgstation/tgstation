/// How much damage proc'ing an RPS interaction does to the loser
#define RPS_DAMAGE 15

/// When an item with this element is used to attack someone else holding an item it's strong or weak against, the person holding the weak item takes big damage and is knocked down
/datum/element/rps
	element_flags = ELEMENT_DETACH | ELEMENT_BESPOKE
	id_arg_index = 2
	/// Attacking someone holding an item in this typepath will proc [/datum/element/rps/proc/strong_attack] against the target
	var/strong_against
	/// Attacking someone holding an item in this typepath will proc [/datum/element/rps/proc/weak_attack] against the user
	var/weak_against

/datum/element/rps/Attach(datum/target, strong_against_path, weak_against_path)
	. = ..()

	if (!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ITEM_ATTACK, .proc/on_item_attack)
	strong_against = strong_against_path
	weak_against = weak_against_path

/datum/element/rps/Detach(datum/source, ...)
	. = ..()

	UnregisterSignal(source, COMSIG_ITEM_ATTACK)

/// Checks if the person we're attacking is holding something we're weak against or strong against, in that order
/datum/element/rps/proc/on_item_attack(datum/source, mob/living/target, mob/living/user, params)
	SIGNAL_HANDLER

	var/obj/item/targeted_weapon = target.is_holding_item_of_type(weak_against)
	if(targeted_weapon)
		INVOKE_ASYNC(src, .proc/weak_attack, source, targeted_weapon, user, target)
		return COMPONENT_SKIP_ATTACK

	targeted_weapon = target.is_holding_item_of_type(strong_against)
	if(targeted_weapon)
		INVOKE_ASYNC(src, .proc/strong_attack, source, targeted_weapon, user, target)
		return COMPONENT_SKIP_ATTACK

/// We attacked a guy holding a rock with scissors (or whatever), they own us
/datum/element/rps/proc/weak_attack(obj/item/attacking_weapon, obj/item/targeted_weapon, mob/living/user, mob/living/target)
	if(!iscarbon(target))
		return

	user.do_attack_animation(target)
	var/womp_word = pick(list("foolishly", "dim-wittedly", "embarrassingly"))

	to_chat(user, span_userdanger("You [womp_word] blunder right into [target]'s [targeted_weapon.name] with your [attacking_weapon.name]!"))
	target.visible_message(span_danger("[user] [womp_word] blunders right into [target]'s [targeted_weapon.name] with [user.p_their()] [attacking_weapon.name]!"), \
		span_userdanger("[user] [womp_word] blunders right into your [targeted_weapon.name] with [user.p_their()] [attacking_weapon.name]!"), \
		ignored_mobs = user, \
		vision_distance = COMBAT_MESSAGE_RANGE)

	playsound(target, attacking_weapon.hitsound, 85, TRUE, -1)
	user.apply_damage(RPS_DAMAGE, targeted_weapon.damtype, sharpness = targeted_weapon.sharpness)
	user.Knockdown(4 SECONDS)

	user.changeNext_move(3 SECONDS)
	log_combat(user, target, "lost in RPS", attacking_weapon)

/// We attacked a guy holding a rock with paper (or whatever), we own them
/datum/element/rps/proc/strong_attack(obj/item/attacking_weapon, obj/item/targeted_weapon, mob/living/user, mob/living/target)
	if(!iscarbon(target))
		return

	user.do_attack_animation(target)
	var/woo_word = pick(list("expertly", "ingeniously", "craftily"))

	to_chat(user, span_boldnicegreen("You [woo_word] outplay [target]'s [targeted_weapon.name] with your [attacking_weapon.name]!"))
	target.visible_message(span_danger("[user] [woo_word] outplays [target]'s [targeted_weapon.name] with [user.p_their()] [attacking_weapon.name]!"), \
		span_userdanger("[user] [woo_word] outplays your [targeted_weapon.name] with [user.p_their()] [attacking_weapon.name]!"), \
		ignored_mobs = user, \
		vision_distance = COMBAT_MESSAGE_RANGE)

	playsound(target, attacking_weapon.hitsound, 85, TRUE, -1)
	target.apply_damage(RPS_DAMAGE, attacking_weapon.damtype, sharpness = attacking_weapon.sharpness)
	target.Knockdown(2 SECONDS)

	user.changeNext_move(3 SECONDS)
	log_combat(user, target, "beat in RPS", attacking_weapon)
