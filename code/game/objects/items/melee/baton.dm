/obj/item/melee/baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum. Left click to stun, right click to harm."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "classic_baton"
	inhand_icon_state = "classic_baton"
	worn_icon_state = "classic_baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 12 //9 hit crit
	w_class = WEIGHT_CLASS_NORMAL
	wound_bonus = 15

	/// Whether this baton is active or not
	var/active = TRUE
	/// Used interally, you don't want to modify
	var/cooldown_check = 0
	/// Default wait time until can stun again.
	var/cooldown = (4 SECONDS)
	/// The length of the knockdown applied to a struck living, non-cyborg mob.
	var/knockdown_time = (1.5 SECONDS)
	/// If affect_cyborg is TRUE, this is how long we stun cyborgs for on a hit.
	var/stun_time_cyborg = (5 SECONDS)
	/// The length of the knockdown applied to the user on clumsy_check()
	var/clumsy_knockdown_time = 18 SECONDS
	/// How much stamina damage we deal on a successful hit against a living, non-cyborg mob.
	var/stamina_damage = 55
	/// Can we stun cyborgs?
	var/affect_cyborg = FALSE
	/// The path of the default sound to play when we stun something.
	var/on_stun_sound = 'sound/effects/woodhit.ogg'
	/// The volume of the above.
	var/on_stun_volume = 75
	/// Do we animate the "hit" when stunning something?
	var/stun_animation = TRUE
	/// Whether the stun attack is logged. Only relevant for abductor batons, which have different modes.
	var/log_stun_attack = TRUE

	/// The context to show when the baton is active and targetting a living thing
	var/context_living_target_active = "Stun"

	/// The context to show when the baton is active and targetting a living thing in combat mode
	var/context_living_target_active_combat_mode = "Stun"

	/// The context to show when the baton is inactive and targetting a living thing
	var/context_living_target_inactive = "Prod"

	/// The context to show when the baton is inactive and targetting a living thing in combat mode
	var/context_living_target_inactive_combat_mode = "Attack"

	/// The RMB context to show when the baton is active and targetting a living thing
	var/context_living_rmb_active = "Attack"

	/// The RMB context to show when the baton is inactive and targetting a living thing
	var/context_living_rmb_inactive = "Attack"

/obj/item/melee/baton/Initialize(mapload)
	. = ..()
	// Adding an extra break for the sake of presentation
	if(stamina_damage != 0)
		offensive_notes = "\nVarious interviewed security forces report being able to beat criminals into exhaustion with only [span_warning("[CEILING(100 / stamina_damage, 1)] hit\s!")]"

	register_item_context()

/**
 * Ok, think of baton attacks like a melee attack chain:
 *
 * [/baton_attack()] comes first. It checks if the user is clumsy, if the target parried the attack and handles some messages and sounds.
 * * Depending on its return value, it'll either do a normal attack, continue to the next step or stop the attack.
 *
 * [/finalize_baton_attack()] is then called. It handles logging stuff, sound effects and calls baton_effect().
 * * The proc is also called in other situations such as stunbatons right clicking or throw impact. Basically when baton_attack()
 * * checks are either redundant or unnecessary.
 *
 * [/baton_effect()] is third in the line. It knockdowns targets, along other effects called in additional_effects_cyborg() and
 * * additional_effects_non_cyborg().
 *
 * Last but not least [/set_batoned()], which gives the target the IWASBATONED trait with REF(user) as source and then removes it
 * * after a cooldown has passed. Basically, it stops users from cheesing the cooldowns by dual wielding batons.
 *
 * TL;DR: [/baton_attack()] -> [/finalize_baton_attack()] -> [/baton_effect()] -> [/set_batoned()]
 */
/obj/item/melee/baton/attack(mob/living/target, mob/living/user, params)
	add_fingerprint(user)
	var/list/modifiers = params2list(params)
	switch(baton_attack(target, user, modifiers))
		if(BATON_DO_NORMAL_ATTACK)
			return ..()
		if(BATON_ATTACKING)
			finalize_baton_attack(target, user, modifiers)

/obj/item/melee/baton/add_item_context(datum/source, list/context, atom/target, mob/living/user)
	if (isturf(target))
		return NONE

	if (isobj(target))
		context[SCREENTIP_CONTEXT_LMB] = "Attack"
	else
		if (active)
			context[SCREENTIP_CONTEXT_RMB] = context_living_rmb_active

			if (user.combat_mode)
				context[SCREENTIP_CONTEXT_LMB] = context_living_target_active_combat_mode
			else
				context[SCREENTIP_CONTEXT_LMB] = context_living_target_active
		else
			context[SCREENTIP_CONTEXT_RMB] = context_living_rmb_inactive

			if (user.combat_mode)
				context[SCREENTIP_CONTEXT_LMB] = context_living_target_inactive_combat_mode
			else
				context[SCREENTIP_CONTEXT_LMB] = context_living_target_inactive

	return CONTEXTUAL_SCREENTIP_SET

/obj/item/melee/baton/proc/baton_attack(mob/living/target, mob/living/user, modifiers)
	. = BATON_ATTACKING

	if(clumsy_check(user, target))
		return BATON_ATTACK_DONE

	if(!active || LAZYACCESS(modifiers, RIGHT_CLICK))
		return BATON_DO_NORMAL_ATTACK

	if(cooldown_check > world.time)
		var/wait_desc = get_wait_description()
		if (wait_desc)
			to_chat(user, wait_desc)
		return BATON_ATTACK_DONE

	if(check_parried(target, user))
		return BATON_ATTACK_DONE

	if(HAS_TRAIT_FROM(target, TRAIT_IWASBATONED, REF(user))) //no doublebaton abuse anon!
		to_chat(user, span_danger("You fumble and miss [target]!"))
		return BATON_ATTACK_DONE

	if(stun_animation)
		user.do_attack_animation(target)

	var/list/desc

	if(iscyborg(target))
		if(affect_cyborg)
			desc = get_cyborg_stun_description(target, user)
		else
			desc = get_unga_dunga_cyborg_stun_description(target, user)
			playsound(get_turf(src), 'sound/effects/bang.ogg', 10, TRUE) //bonk
			. = BATON_ATTACK_DONE
	else
		desc = get_stun_description(target, user)

	if(desc)
		target.visible_message(desc["visible"], desc["local"])

/obj/item/melee/baton/proc/check_parried(mob/living/carbon/human/human_target, mob/living/user)
	if(!ishuman(human_target))
		return
	if (human_target.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK))
		playsound(human_target, 'sound/weapons/genhit.ogg', 50, TRUE)
		return TRUE
	if(check_martial_counter(human_target, user))
		return TRUE

/obj/item/melee/baton/proc/finalize_baton_attack(mob/living/target, mob/living/user, modifiers, in_attack_chain = TRUE)
	if(!in_attack_chain && HAS_TRAIT_FROM(target, TRAIT_IWASBATONED, REF(user)))
		return BATON_ATTACK_DONE

	cooldown_check = world.time + cooldown
	if(on_stun_sound)
		playsound(get_turf(src), on_stun_sound, on_stun_volume, TRUE, -1)
	if(user)
		target.lastattacker = user.real_name
		target.lastattackerckey = user.ckey
		target.LAssailant = WEAKREF(user)
		if(log_stun_attack)
			log_combat(user, target, "stun attacked", src)
	if(baton_effect(target, user, modifiers) && user)
		set_batoned(target, user, cooldown)

/obj/item/melee/baton/proc/baton_effect(mob/living/target, mob/living/user, modifiers, stun_override)
	var/trait_check = HAS_TRAIT(target, TRAIT_BATON_RESISTANCE)
	if(iscyborg(target))
		if(!affect_cyborg)
			return FALSE
		target.flash_act(affect_silicon = TRUE)
		target.Paralyze((isnull(stun_override) ? stun_time_cyborg : stun_override) * (trait_check ? 0.1 : 1))
		additional_effects_cyborg(target, user)
	else
		target.apply_damage(stamina_damage, STAMINA, BODY_ZONE_CHEST)
		if(!trait_check)
			target.Knockdown((isnull(stun_override) ? knockdown_time : stun_override))
		additional_effects_non_cyborg(target, user)
	return TRUE

/// Description for trying to stun when still on cooldown.
/obj/item/melee/baton/proc/get_wait_description()
	return

/// Default message for stunning a living, non-cyborg mob.
/obj/item/melee/baton/proc/get_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visible"] = span_danger("[user] knocks [target] down with [src]!")
	.["local"] = span_userdanger("[user] knocks you down with [src]!")

	return .

/// Default message for stunning a cyborg.
/obj/item/melee/baton/proc/get_cyborg_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visible"] = span_danger("[user] pulses [target]'s sensors with the baton!")
	.["local"] = span_danger("You pulse [target]'s sensors with the baton!")

	return .

/// Default message for trying to stun a cyborg with a baton that can't stun cyborgs.
/obj/item/melee/baton/proc/get_unga_dunga_cyborg_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visible"] = span_danger("[user] tries to knock down [target] with [src], and predictably fails!") //look at this duuuuuude
	.["local"] = span_userdanger("[user] tries to... knock you down with [src]?") //look at the top of his head!

	return .

/// Contains any special effects that we apply to living, non-cyborg mobs we stun. Does not include applying a knockdown, dealing stamina damage, etc.
/obj/item/melee/baton/proc/additional_effects_non_cyborg(mob/living/target, mob/living/user)
	return

/// Contains any special effects that we apply to cyborgs we stun. Does not include flashing the cyborg's screen, hardstunning them, etc.
/obj/item/melee/baton/proc/additional_effects_cyborg(mob/living/target, mob/living/user)
	return

/obj/item/melee/baton/proc/set_batoned(mob/living/target, mob/living/user, cooldown)
	if(!cooldown)
		return
	var/user_ref = REF(user) // avoids harddels.
	ADD_TRAIT(target, TRAIT_IWASBATONED, user_ref)
	addtimer(TRAIT_CALLBACK_REMOVE(target, TRAIT_IWASBATONED, user_ref), cooldown)

/obj/item/melee/baton/proc/clumsy_check(mob/living/user, mob/living/intented_target)
	if(!active || !HAS_TRAIT(user, TRAIT_CLUMSY) || prob(50))
		return FALSE
	user.visible_message(span_danger("[user] accidentally hits [user.p_them()]self over the head with [src]! What a doofus!"), span_userdanger("You accidentally hit yourself over the head with [src]!"))

	if(iscyborg(user))
		if(affect_cyborg)
			user.flash_act(affect_silicon = TRUE)
			user.Paralyze(clumsy_knockdown_time)
			additional_effects_cyborg(user, user) // user is the target here
			if(on_stun_sound)
				playsound(get_turf(src), on_stun_sound, on_stun_volume, TRUE, -1)
		else
			playsound(get_turf(src), 'sound/effects/bang.ogg', 10, TRUE)
	else
		user.Knockdown(clumsy_knockdown_time)
		user.apply_damage(stamina_damage, STAMINA, BODY_ZONE_HEAD)
		additional_effects_non_cyborg(user, user) // user is the target here
		if(on_stun_sound)
			playsound(get_turf(src), on_stun_sound, on_stun_volume, TRUE, -1)

	user.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)

	log_combat(user, user, "accidentally stun attacked [user.p_them()]self due to their clumsiness", src)
	if(stun_animation)
		user.do_attack_animation(user)
	return

/obj/item/conversion_kit
	name = "conversion kit"
	desc = "A strange box containing wood working tools and an instruction paper to turn stun batons into something else."
	icon = 'icons/obj/storage.dmi'
	icon_state = "uk"
	custom_price = PAYCHECK_COMMAND * 4.5

/obj/item/melee/baton/telescopic
	name = "telescopic baton"
	desc = "A compact yet robust personal defense weapon. Can be concealed when folded."
	icon_state = "telebaton"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	inhand_icon_state = null
	attack_verb_continuous = list("hits", "pokes")
	attack_verb_simple = list("hit", "poke")
	worn_icon_state = "tele_baton"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NONE
	force = 0
	bare_wound_bonus = 5
	clumsy_knockdown_time = 15 SECONDS
	active = FALSE

	/// The sound effecte played when our baton is extended.
	var/on_sound = 'sound/weapons/batonextend.ogg'
	/// The inhand iconstate used when our baton is extended.
	var/on_inhand_icon_state = "nullrod"
	/// The force on extension.
	var/active_force = 10

/obj/item/melee/baton/telescopic/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/transforming, \
		force_on = active_force, \
		hitsound_on = hitsound, \
		w_class_on = WEIGHT_CLASS_NORMAL, \
		clumsy_check = FALSE, \
		attack_verb_continuous_on = list("smacks", "strikes", "cracks", "beats"), \
		attack_verb_simple_on = list("smack", "strike", "crack", "beat"))
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, .proc/on_transform)

/obj/item/melee/baton/telescopic/suicide_act(mob/user)
	var/mob/living/carbon/human/human_user = user
	var/obj/item/organ/internal/brain/our_brain = human_user.getorgan(/obj/item/organ/internal/brain)

	user.visible_message(span_suicide("[user] stuffs [src] up [user.p_their()] nose and presses the 'extend' button! It looks like [user.p_theyre()] trying to clear [user.p_their()] mind."))
	if(active)
		playsound(src, on_sound, 50, TRUE)
		add_fingerprint(user)
	else
		attack_self(user)

	sleep(0.3 SECONDS)
	if (QDELETED(human_user))
		return
	if(!QDELETED(our_brain))
		human_user.internal_organs -= our_brain
		qdel(our_brain)
	new /obj/effect/gibspawner/generic(human_user.drop_location(), human_user)
	return (BRUTELOSS)

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Gives feedback to the user and makes it show up inhand.
 */
/obj/item/melee/baton/telescopic/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	src.active = active
	inhand_icon_state = active ? on_inhand_icon_state : null // When inactive, there is no inhand icon_state.
	balloon_alert(user, active ? "extended" : "collapsed")
	playsound(user ? user : src, on_sound, 50, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/melee/baton/telescopic/contractor_baton
	name = "contractor baton"
	desc = "A compact, specialised baton assigned to Syndicate contractors. Applies light electrical shocks to targets."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "contractor_baton"
	worn_icon_state = "contractor_baton"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NONE
	force = 5
	cooldown = 2.5 SECONDS
	stamina_damage = 85
	clumsy_knockdown_time = 24 SECONDS
	affect_cyborg = TRUE
	on_stun_sound = 'sound/effects/contractorbatonhit.ogg'

	on_inhand_icon_state = "contractor_baton_on"
	on_sound = 'sound/weapons/contractorbatonextend.ogg'
	active_force = 16

/obj/item/melee/baton/telescopic/contractor_baton/get_wait_description()
	return span_danger("The baton is still charging!")

/obj/item/melee/baton/telescopic/contractor_baton/additional_effects_non_cyborg(mob/living/target, mob/living/user)
	target.set_timed_status_effect(40 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
	target.adjust_timed_status_effect(40 SECONDS, /datum/status_effect/speech/stutter)

/obj/item/melee/baton/security
	name = "stun baton"
	desc = "A stun baton for incapacitating people with. Left click to stun, right click to harm."

	icon_state = "stunbaton"
	inhand_icon_state = "baton"
	worn_icon_state = "baton"

	force = 10
	wound_bonus = 0
	attack_verb_continuous = list("beats")
	attack_verb_simple = list("beat")

	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 50, BIO = 0, FIRE = 80, ACID = 80)

	throwforce = 7
	stamina_damage = 60
	knockdown_time = 5 SECONDS
	clumsy_knockdown_time = 15 SECONDS
	cooldown = 2.5 SECONDS
	on_stun_sound = 'sound/weapons/egloves.ogg'
	on_stun_volume = 50
	active = FALSE

	context_living_rmb_active = "Harmful Stun"

	var/throw_stun_chance = 35
	var/obj/item/stock_parts/cell/cell
	var/preload_cell_type //if not empty the baton starts with this type of cell
	var/cell_hit_cost = 1000
	var/can_remove_cell = TRUE
	var/convertible = TRUE //if it can be converted with a conversion kit

/obj/item/melee/baton/security/Initialize(mapload)
	. = ..()
	if(preload_cell_type)
		if(!ispath(preload_cell_type, /obj/item/stock_parts/cell))
			log_mapping("[src] at [AREACOORD(src)] had an invalid preload_cell_type: [preload_cell_type].")
		else
			cell = new preload_cell_type(src)
	RegisterSignal(src, COMSIG_PARENT_ATTACKBY, .proc/convert)
	update_appearance()

/obj/item/melee/baton/security/get_cell()
	return cell

/obj/item/melee/baton/security/suicide_act(mob/user)
	if(cell?.charge && active)
		user.visible_message(span_suicide("[user] is putting the live [name] in [user.p_their()] mouth! It looks like [user.p_theyre()] trying to commit suicide!"))
		. = (FIRELOSS)
		attack(user, user)
	else
		user.visible_message(span_suicide("[user] is shoving the [name] down their throat! It looks like [user.p_theyre()] trying to commit suicide!"))
		. = (OXYLOSS)

/obj/item/melee/baton/security/Destroy()
	if(cell)
		QDEL_NULL(cell)
	UnregisterSignal(src, COMSIG_PARENT_ATTACKBY)
	return ..()

/obj/item/melee/baton/security/proc/convert(datum/source, obj/item/item, mob/user)
	SIGNAL_HANDLER

	if(!istype(item, /obj/item/conversion_kit) || !convertible)
		return
	var/turf/source_turf = get_turf(src)
	var/obj/item/melee/baton/baton = new (source_turf)
	baton.alpha = 20
	playsound(source_turf, 'sound/items/drill_use.ogg', 80, TRUE, -1)
	animate(src, alpha = 0, time = 1 SECONDS)
	animate(baton, alpha = 255, time = 1 SECONDS)
	qdel(item)
	qdel(src)

/obj/item/melee/baton/security/Exited(atom/movable/mov_content)
	. = ..()
	if(mov_content == cell)
		cell.update_appearance()
		cell = null
		active = FALSE
		update_appearance()

/obj/item/melee/baton/security/update_icon_state()
	if(active)
		icon_state = "[initial(icon_state)]_active"
		return ..()
	if(!cell)
		icon_state = "[initial(icon_state)]_nocell"
		return ..()
	icon_state = "[initial(icon_state)]"
	return ..()

/obj/item/melee/baton/security/examine(mob/user)
	. = ..()
	if(cell)
		. += span_notice("\The [src] is [round(cell.percent())]% charged.")
	else
		. += span_warning("\The [src] does not have a power source installed.")

/obj/item/melee/baton/security/screwdriver_act(mob/living/user, obj/item/tool)
	if(tryremovecell(user))
		tool.play_tool_sound(src)
	return TRUE

/obj/item/melee/baton/security/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/active_cell = item
		if(cell)
			to_chat(user, span_warning("[src] already has a cell!"))
		else
			if(active_cell.maxcharge < cell_hit_cost)
				to_chat(user, span_notice("[src] requires a higher capacity cell."))
				return
			if(!user.transferItemToLoc(item, src))
				return
			cell = item
			to_chat(user, span_notice("You install a cell in [src]."))
			update_appearance()
	else
		return ..()

/obj/item/melee/baton/security/proc/tryremovecell(mob/user)
	if(cell && can_remove_cell)
		cell.forceMove(drop_location())
		to_chat(user, span_notice("You remove the cell from [src]."))
		return TRUE
	return FALSE

/obj/item/melee/baton/security/attack_self(mob/user)
	if(cell?.charge >= cell_hit_cost)
		active = !active
		balloon_alert(user, "turned [active ? "on" : "off"]")
		playsound(src, SFX_SPARKS, 75, TRUE, -1)
	else
		active = FALSE
		if(!cell)
			balloon_alert(user, "no power source!")
		else
			balloon_alert(user, "out of charge!")
	update_appearance()
	add_fingerprint(user)

/obj/item/melee/baton/security/proc/deductcharge(deducted_charge)
	if(!cell)
		return
	//Note this value returned is significant, as it will determine
	//if a stun is applied or not
	. = cell.use(deducted_charge)
	if(active && cell.charge < cell_hit_cost)
		//we're below minimum, turn off
		active = FALSE
		update_appearance()
		playsound(src, SFX_SPARKS, 75, TRUE, -1)

/obj/item/melee/baton/security/clumsy_check(mob/living/carbon/human/user)
	. = ..()
	if(.)
		SEND_SIGNAL(user, COMSIG_LIVING_MINOR_SHOCK)
		deductcharge(cell_hit_cost)

/// Handles prodding targets with turned off stunbatons and right clicking stun'n'bash
/obj/item/melee/baton/security/baton_attack(mob/living/target, mob/living/user, modifiers)
	. = ..()
	if(. != BATON_DO_NORMAL_ATTACK)
		return
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(active && cooldown_check <= world.time && !check_parried(target, user))
			finalize_baton_attack(target, user, modifiers, in_attack_chain = FALSE)
	else if(!user.combat_mode)
		target.visible_message(span_warning("[user] prods [target] with [src]. Luckily it was off."), \
			span_warning("[user] prods you with [src]. Luckily it was off."))
		return BATON_ATTACK_DONE

/obj/item/melee/baton/security/baton_effect(mob/living/target, mob/living/user, modifiers, stun_override)
	if(iscyborg(loc))
		var/mob/living/silicon/robot/robot = loc
		if(!robot || !robot.cell || !robot.cell.use(cell_hit_cost))
			return FALSE
	else if(!deductcharge(cell_hit_cost))
		return FALSE
	stun_override = 0 //Avoids knocking people down prematurely.
	return ..()

/*
 * After a target is hit, we apply some status effects.
 * After a period of time, we then check to see what stun duration we give.
 */
/obj/item/melee/baton/security/additional_effects_non_cyborg(mob/living/target, mob/living/user)
	target.set_timed_status_effect(40 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
	target.set_timed_status_effect(10 SECONDS, /datum/status_effect/confusion, only_if_higher = TRUE)
	target.set_timed_status_effect(16 SECONDS, /datum/status_effect/speech/stutter, only_if_higher = TRUE)

	SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK)
	addtimer(CALLBACK(src, .proc/apply_stun_effect_end, target), 2 SECONDS)

/// After the initial stun period, we check to see if the target needs to have the stun applied.
/obj/item/melee/baton/security/proc/apply_stun_effect_end(mob/living/target)
	var/trait_check = HAS_TRAIT(target, TRAIT_BATON_RESISTANCE) //var since we check it in out to_chat as well as determine stun duration
	if(!target.IsKnockdown())
		to_chat(target, span_warning("Your muscles seize, making you collapse[trait_check ? ", but your body quickly recovers..." : "!"]"))

	target.Knockdown(knockdown_time * (trait_check ? 0.1 : 1))

/obj/item/melee/baton/security/get_wait_description()
	return span_danger("The baton is still charging!")

/obj/item/melee/baton/security/get_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visible"] = span_danger("[user] stuns [target] with [src]!")
	.["local"] = span_userdanger("[user] stuns you with [src]!")

/obj/item/melee/baton/security/get_unga_dunga_cyborg_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visible"] = span_danger("[user] tries to stun [target] with [src], and predictably fails!")
	.["local"] = span_userdanger("[target] tries to... stun you with [src]?")

/obj/item/melee/baton/security/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(active && prob(throw_stun_chance) && isliving(hit_atom))
		finalize_baton_attack(hit_atom, thrownby?.resolve(), in_attack_chain = FALSE)

/obj/item/melee/baton/security/emp_act(severity)
	. = ..()
	if (!cell)
		return
	if (!(. & EMP_PROTECT_SELF))
		deductcharge(1000 / severity)
	if (cell.charge >= cell_hit_cost)
		var/scramble_time
		scramble_mode()
		for(var/loops in 1 to rand(6, 12))
			scramble_time = rand(5, 15) / (1 SECONDS)
			addtimer(CALLBACK(src, .proc/scramble_mode), scramble_time*loops * (1 SECONDS))

/obj/item/melee/baton/security/proc/scramble_mode()
	if (!cell || cell.charge < cell_hit_cost)
		return
	active = !active
	playsound(src, SFX_SPARKS, 75, TRUE, -1)
	update_appearance()

/obj/item/melee/baton/security/loaded //this one starts with a cell pre-installed.
	preload_cell_type = /obj/item/stock_parts/cell/high

//Makeshift stun baton. Replacement for stun gloves.
/obj/item/melee/baton/security/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton. Left click to stun, right click to harm."
	icon_state = "stunprod"
	inhand_icon_state = "prod"
	worn_icon_state = null
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	force = 3
	throwforce = 5
	cell_hit_cost = 2000
	throw_stun_chance = 10
	slot_flags = ITEM_SLOT_BACK
	convertible = FALSE
	var/obj/item/assembly/igniter/sparkler

/obj/item/melee/baton/security/cattleprod/Initialize(mapload)
	. = ..()
	sparkler = new (src)

/obj/item/melee/baton/security/cattleprod/attackby(obj/item/item, mob/user, params)//handles sticking a crystal onto a stunprod to make a teleprod
	if(!istype(item, /obj/item/stack/ore/bluespace_crystal))
		return ..()
	if(!cell)
		var/obj/item/stack/ore/bluespace_crystal/crystal = item
		var/obj/item/melee/baton/security/cattleprod/teleprod/prod = new
		remove_item_from_storage(user)
		qdel(src)
		crystal.use(1)
		user.put_in_hands(prod)
		to_chat(user, span_notice("You place the bluespace crystal firmly into the igniter."))
	else
		user.visible_message(span_warning("You can't put the crystal onto the stunprod while it has a power cell installed!"))

/obj/item/melee/baton/security/cattleprod/baton_effect()
	if(!sparkler.activate())
		return BATON_ATTACK_DONE
	return ..()

/obj/item/melee/baton/security/cattleprod/Destroy()
	if(sparkler)
		QDEL_NULL(sparkler)
	return ..()

/obj/item/melee/baton/security/boomerang
	name = "\improper OZtek Boomerang"
	desc = "A device invented in 2486 for the great Space Emu War by the confederacy of Australicus, these high-tech boomerangs also work exceptionally well at stunning crewmembers. Just be careful to catch it when thrown!"
	throw_speed = 1
	icon_state = "boomerang"
	inhand_icon_state = "boomerang"
	force = 5
	throwforce = 5
	throw_range = 5
	cell_hit_cost = 2000
	throw_stun_chance = 99  //Have you prayed today?
	convertible = FALSE
	custom_materials = list(/datum/material/iron = 10000, /datum/material/glass = 4000, /datum/material/silver = 10000, /datum/material/gold = 2000)

/obj/item/melee/baton/security/boomerang/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/boomerang, throw_range+2, TRUE)

/obj/item/melee/baton/security/boomerang/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!active)
		return ..()
	var/caught = hit_atom.hitby(src, skipcatch = FALSE, hitpush = FALSE, throwingdatum = throwingdatum)
	var/mob/thrown_by = thrownby?.resolve()
	if(isliving(hit_atom) && !iscyborg(hit_atom) && !caught && prob(throw_stun_chance))//if they are a living creature and they didn't catch it
		finalize_baton_attack(hit_atom, thrown_by, in_attack_chain = FALSE)

/obj/item/melee/baton/security/boomerang/loaded //Same as above, comes with a cell.
	preload_cell_type = /obj/item/stock_parts/cell/high

/obj/item/melee/baton/security/cattleprod/teleprod
	name = "teleprod"
	desc = "A prod with a bluespace crystal on the end. The crystal doesn't look too fun to touch."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "teleprod"
	inhand_icon_state = "teleprod"
	slot_flags = null

/obj/item/melee/baton/security/cattleprod/teleprod/clumsy_check(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	do_teleport(user, get_turf(user), 50, channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/item/melee/baton/security/cattleprod/teleprod/baton_effect(mob/living/target, mob/living/user, modifiers, stun_override)
	. = ..()
	if(!. || target.move_resist >= MOVE_FORCE_OVERPOWERING)
		return
	do_teleport(target, get_turf(target), 15, channel = TELEPORT_CHANNEL_BLUESPACE)
