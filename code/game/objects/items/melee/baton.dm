/obj/item/melee/baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	desc_controls = "Left click to stun, right click to harm."
	icon = 'icons/obj/weapons/baton.dmi'
	icon_state = "classic_baton"
	inhand_icon_state = "classic_baton"
	worn_icon_state = "classic_baton"
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 12 //9 hit crit
	w_class = WEIGHT_CLASS_NORMAL
	wound_bonus = 15
	sound_vary = TRUE

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
	/// How much armor does our baton ignore? This operates as armour penetration, but only applies to the stun attack.
	var/stun_armour_penetration = 15
	/// What armor does our stun attack check before delivering the attack?
	var/armour_type_against_stun = MELEE
	/// Chance of causing force_say() when stunning a human mob
	var/force_say_chance = 33
	/// Can we stun cyborgs?
	var/affect_cyborg = FALSE
	/// The path of the default sound to play when we stun something.
	var/on_stun_sound = 'sound/effects/woodhit.ogg'
	/// The volume of the above.
	var/on_stun_volume = 75
	/// Whether the stun attack is logged. Only relevant for abductor batons, which have different modes.
	var/log_stun_attack = TRUE
	/// Boolean on whether people with chunky fingers can use this baton.
	var/chunky_finger_usable = FALSE
	/// Boolean, if TRUE when we harmbaton someone we will also try to stun if the baton is active / not on cooldown.
	var/stun_on_harmbaton = FALSE

	/// Text shown when trying to stun someone while the baton is on cooldown.
	var/wait_desc = ""

	/// What term do we use to describe our baton being 'ready', or the phrase to use when var/active is TRUE.
	var/activated_word = "ready"

	/// The context to show when the baton is active and targeting a living thing
	var/context_living_target_active = "Stun"

	/// The context to show when the baton is active and targeting a living thing in combat mode
	var/context_living_target_active_combat_mode = "Stun"

	/// The context to show when the baton is inactive and targeting a living thing
	var/context_living_target_inactive = "Prod"

	/// The context to show when the baton is inactive and targeting a living thing in combat mode
	var/context_living_target_inactive_combat_mode = "Attack"

	/// The RMB context to show when the baton is active and targeting a living thing
	var/context_living_rmb_active = "Attack"

	/// The RMB context to show when the baton is inactive and targeting a living thing
	var/context_living_rmb_inactive = "Attack"

/obj/item/melee/baton/Initialize(mapload)
	. = ..()

	register_item_context()

/obj/item/melee/baton/add_weapon_description()
	AddElement(/datum/element/weapon_description, attached_proc = PROC_REF(add_baton_notes))

/obj/item/melee/baton/proc/add_baton_notes()
	var/list/readout = list()

	if(affect_cyborg)
		readout += "It can stun cyborgs for [round((stun_time_cyborg/10), 1)] seconds."

	readout += "\n[active ? "It is currently [span_warning("[activated_word]")], and capable of stunning." : "It is [span_warning("not [activated_word]")], and not capable of stunning."]"

	if(stamina_damage <= 0) // The advanced baton actually does have 0 stamina damage so...yeah.
		readout += "Either it is [span_warning("completely unable to perform a stunning strike")], or it [span_warning("attacks via some unusual method")]."
		return readout.Join("\n")

	readout += "It takes [span_warning("[HITS_TO_CRIT(stamina_damage)] strike\s")] to stun an enemy."

	readout += "\nThe effects of each strike can be mitigated by utilizing [span_warning("[armour_type_against_stun]")] armor."

	readout += "\nIt has a stun armor-piercing capability of [span_warning("[get_stun_penetration_value()]%")]."
	return readout.Join("\n")

/// Checks if we can actually USE the baton. Impure
/obj/item/melee/baton/proc/can_baton(mob/living/target, mob/living/user)
	PROTECTED_PROC(TRUE)
	if(clumsy_check(user, target))
		return FALSE

	if(!chunky_finger_usable && ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(human_user.check_chunky_fingers() && user.is_holding(src) && !HAS_MIND_TRAIT(user, TRAIT_CHUNKYFINGERS_IGNORE_BATON))
			balloon_alert(human_user, "fingers are too big!")
			return FALSE

	return TRUE

// Stun attack
/obj/item/melee/baton/pre_attack(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(. || !isliving(target))
		return .

	if(!can_baton(target, user))
		return TRUE

	if(!COOLDOWN_FINISHED(src, cooldown_check))
		if(wait_desc)
			balloon_alert(user, wait_desc)
		return TRUE

	if(HAS_TRAIT_FROM(target, TRAIT_IWASBATONED, REF(user))) //no doublebaton abuse anon!
		target.balloon_alert(user, "can't stun yet!")
		return TRUE

	if(active)
		// when we continue to attack, deal 0 (brute) damage (just stun)
		SET_ATTACK_FORCE(attack_modifiers, 0)
		MUTE_ATTACK_HITSOUND(attack_modifiers)
		HIDE_ATTACK_MESSAGES(attack_modifiers)
	return .

// Harm attack
/obj/item/melee/baton/pre_attack_secondary(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(. != SECONDARY_ATTACK_CALL_NORMAL || !isliving(target))
		return .

	if(!can_baton(target, user))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	// call attack, NOT pre_attack
	// (so we go directly to harming)
	return SECONDARY_ATTACK_CONTINUE_CHAIN

// This is where stun gets applied
/obj/item/melee/baton/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	if(!isliving(target) || !active || !COOLDOWN_FINISHED(src, cooldown_check) || HAS_TRAIT_FROM(target, TRAIT_IWASBATONED, REF(user)))
		return
	// worst check in the chain but - right click = harmbaton
	if(LAZYACCESS(modifiers, RIGHT_CLICK) && !stun_on_harmbaton)
		return

	finalize_baton_attack(target, user, modifiers)

	var/list/desc
	if(iscyborg(target))
		desc = get_cyborg_stun_description(target, user)
		if(!affect_cyborg)
			playsound(src, 'sound/effects/bang.ogg', 10, TRUE) //bonk
	else
		desc = get_stun_description(target, user)

	if(desc)
		target.visible_message(desc["visible"], desc["local"], visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE)

/obj/item/melee/baton/apply_fantasy_bonuses(bonus)
	. = ..()
	stamina_damage = modify_fantasy_variable("stamina_damage", stamina_damage, bonus * 4)

/obj/item/melee/baton/remove_fantasy_bonuses(bonus)
	stamina_damage = reset_fantasy_variable("stamina_damage", stamina_damage)
	return ..()

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

/// Wrapper for calling "stun()" and doing relevant vfx/sfx
/obj/item/melee/baton/proc/finalize_baton_attack(mob/living/target, mob/living/user, list/modifiers)
	PROTECTED_PROC(TRUE)
	COOLDOWN_START(src, cooldown_check, cooldown)
	if(on_stun_sound)
		playsound(src, on_stun_sound, on_stun_volume, TRUE, -1)
	if(baton_effect(target, user, modifiers) && user)
		set_batoned(target, user, cooldown)
		log_combat(user, target, "stunned", src.name)

/// The actual "stun()" of the stun baton
/obj/item/melee/baton/proc/baton_effect(mob/living/target, mob/living/user, list/modifiers, stun_override)
	PROTECTED_PROC(TRUE)
	var/trait_check = HAS_TRAIT(target, TRAIT_BATON_RESISTANCE)
	if(iscyborg(target))
		if(!affect_cyborg)
			return FALSE
		target.flash_act(affect_silicon = TRUE)
		target.Paralyze((isnull(stun_override) ? stun_time_cyborg : stun_override) * (trait_check ? 0.1 : 1))
		additional_effects_cyborg(target, user)
	else
		if(ishuman(target))
			var/mob/living/carbon/human/human_target = target
			if(prob(force_say_chance))
				human_target.force_say()
		var/effective_armour_penetration = get_stun_penetration_value()
		var/armour_block = target.run_armor_check(null, armour_type_against_stun, null, null, effective_armour_penetration)
		target.apply_damage(stamina_damage, STAMINA, blocked = armour_block)
		if(!trait_check)
			target.Knockdown((isnull(stun_override) ? knockdown_time : stun_override))
		additional_effects_non_cyborg(target, user)
	SEND_SIGNAL(target, COMSIG_MOB_BATONED, user, src)
	return TRUE

/// Default message for stunning a living, non-cyborg mob.
/obj/item/melee/baton/proc/get_stun_description(mob/living/target, mob/living/user)
	PROTECTED_PROC(TRUE)
	. = list()
	.["visible"] = span_danger("[user] knocks [target] down with [src]!")
	.["local"] = span_userdanger("[user] knocks you down with [src]!")

/// Default message for stunning a cyborg.
/obj/item/melee/baton/proc/get_cyborg_stun_description(mob/living/target, mob/living/user)
	PROTECTED_PROC(TRUE)
	. = list()
	if(affect_cyborg)
		.["visible"] = span_danger("[user] pulses [target]'s sensors with the baton!")
		.["local"] = span_danger("You pulse [target]'s sensors with the baton!")
	else
		.["visible"] = span_danger("[user] tries to knock down [target] with [src], and predictably fails!") //look at this duuuuuude
		.["local"] = span_userdanger("[user] tries to... knock you down with [src]?") //look at the top of his head!

/// Contains any special effects that we apply to living, non-cyborg mobs we stun. Does not include applying a knockdown, dealing stamina damage, etc.
/obj/item/melee/baton/proc/additional_effects_non_cyborg(mob/living/target, mob/living/user)
	PROTECTED_PROC(TRUE)
	return

/// Contains any special effects that we apply to cyborgs we stun. Does not include flashing the cyborg's screen, hardstunning them, etc.
/obj/item/melee/baton/proc/additional_effects_cyborg(mob/living/target, mob/living/user)
	PROTECTED_PROC(TRUE)
	return

/// Used in marking a target as being hit by a baton
/obj/item/melee/baton/proc/set_batoned(mob/living/target, mob/living/user, cooldown)
	PRIVATE_PROC(TRUE)
	if(!cooldown)
		return
	var/user_ref = REF(user) // avoids harddels.
	ADD_TRAIT(target, TRAIT_IWASBATONED, user_ref)
	addtimer(TRAIT_CALLBACK_REMOVE(target, TRAIT_IWASBATONED, user_ref), cooldown)

/obj/item/melee/baton/proc/clumsy_check(mob/living/user, mob/living/intented_target)
	if(!active || !HAS_TRAIT(user, TRAIT_CLUMSY) || prob(50))
		return FALSE
	user.visible_message(span_danger("[user] accidentally hits [user.p_them()]self over the head with [src]! What a doofus!"), span_userdanger("You accidentally hit yourself over the head with [src]!"), visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE)

	if(iscyborg(user))
		if(affect_cyborg)
			user.flash_act(affect_silicon = TRUE)
			user.Paralyze(clumsy_knockdown_time)
			additional_effects_cyborg(user, user) // user is the target here
			if(on_stun_sound)
				playsound(src, on_stun_sound, on_stun_volume, TRUE, -1)
		else
			playsound(src, 'sound/effects/bang.ogg', 10, TRUE)
	else
		//straight up always force say for clumsy humans
		if(ishuman(user))
			var/mob/living/carbon/human/human_user = user
			human_user.force_say()
		user.Knockdown(clumsy_knockdown_time)
		user.apply_damage(stamina_damage, STAMINA)
		additional_effects_non_cyborg(user, user) // user is the target here
		if(on_stun_sound)
			playsound(src, on_stun_sound, on_stun_volume, TRUE, -1)

	user.apply_damage(2 * force, BRUTE, BODY_ZONE_HEAD, attacking_item = src)
	log_combat(user, user, "accidentally stun attacked [user.p_them()]self due to their clumsiness", src)
	user.do_attack_animation(user)

/// Handles the penetration value of our baton, called during baton_effect()
/obj/item/melee/baton/proc/get_stun_penetration_value()
	return stun_armour_penetration

/obj/item/conversion_kit
	name = "conversion kit"
	desc = "A strange box containing wood working tools and an instruction paper to turn stun batons into something else."
	icon = 'icons/obj/storage/box.dmi'
	icon_state = "uk"
	custom_price = PAYCHECK_COMMAND * 4.5

/obj/item/melee/baton/telescopic
	name = "telescopic baton"
	desc = "A compact yet robust personal defense weapon. Can be concealed when folded."
	icon = 'icons/obj/weapons/baton.dmi'
	icon_state = "telebaton"
	icon_angle = -45
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
	exposed_wound_bonus = 5
	clumsy_knockdown_time = 15 SECONDS
	active = FALSE
	activated_word = "extended"
	var/folded_drop_sound = 'sound/items/baton/telescopic_baton_folded_drop.ogg'
	var/folded_pickup_sound = 'sound/items/baton/telescopic_baton_folded_pickup.ogg'
	var/unfolded_drop_sound = 'sound/items/baton/telescopic_baton_unfolded_drop.ogg'
	var/unfolded_pickup_sound = 'sound/items/baton/telescopic_baton_unfolded_pickup.ogg'
	pickup_sound = 'sound/items/baton/telescopic_baton_folded_pickup.ogg'
	drop_sound = 'sound/items/baton/telescopic_baton_folded_drop.ogg'
	sound_vary = TRUE
	/// The sound effecte played when our baton is extended.
	var/on_sound = 'sound/items/weapons/batonextend.ogg'
	/// The inhand iconstate used when our baton is extended.
	var/on_inhand_icon_state = "nullrod"
	/// The force on extension.
	var/active_force = 10

/obj/item/melee/baton/telescopic/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/transforming, \
		force_on = active_force, \
		hitsound_on = hitsound, \
		w_class_on = WEIGHT_CLASS_NORMAL, \
		clumsy_check = FALSE, \
		attack_verb_continuous_on = list("smacks", "strikes", "cracks", "beats"), \
		attack_verb_simple_on = list("smack", "strike", "crack", "beat"), \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/melee/baton/telescopic/additional_effects_non_cyborg(mob/living/target, mob/living/user)
	target.apply_status_effect(/datum/status_effect/dazed)

/obj/item/melee/baton/telescopic/suicide_act(mob/living/user)
	var/mob/living/carbon/human/human_user = user
	var/obj/item/organ/brain/our_brain = human_user.get_organ_by_type(/obj/item/organ/brain)

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
		human_user.organs -= our_brain
		qdel(our_brain)
	new /obj/effect/gibspawner/generic(human_user.drop_location(), human_user)
	return BRUTELOSS

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Gives feedback to the user and makes it show up inhand.
 */
/obj/item/melee/baton/telescopic/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	src.active = active
	inhand_icon_state = active ? on_inhand_icon_state : null // When inactive, there is no inhand icon_state.
	if(user)
		balloon_alert(user, active ? "extended" : "collapsed")
	if(!active)
		drop_sound = folded_drop_sound
		pickup_sound = folded_pickup_sound
	else
		drop_sound = unfolded_drop_sound
		pickup_sound = unfolded_pickup_sound
	playsound(src, on_sound, 50, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/melee/baton/telescopic/bronze
	name = "bronze-capped telescopic baton"
	desc = "A compact yet robust personal defense weapon. Can be concealed when folded. This one is ranked BRONZE, and thus has mediocre penetrative power."
	icon_state = "telebaton_bronze"
	stun_armour_penetration = 20

/obj/item/melee/baton/telescopic/silver
	name = "silver-capped telescopic baton"
	desc = "A compact yet robust personal defense weapon. Can be concealed when folded. This one is ranked SILVER, and thus has decent penetrative power."
	icon_state = "telebaton_silver"
	stun_armour_penetration = 40

/obj/item/melee/baton/telescopic/gold
	name = "gold-capped telescopic baton"
	desc = "A compact yet robust personal defense weapon. Can be concealed when folded. This one is ranked GOLD, and thus has exceptional penetrative power."
	icon_state = "telebaton_gold"
	stun_armour_penetration = 60

/obj/item/melee/baton/telescopic/contractor_baton
	name = "contractor baton"
	desc = "A compact, specialised baton assigned to Syndicate contractors. Applies light electrical shocks to targets."
	icon = 'icons/obj/weapons/baton.dmi'
	icon_state = "contractor_baton"
	worn_icon_state = "contractor_baton"
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NONE
	force = 5
	cooldown = 2.5 SECONDS
	force_say_chance = 80 //very high force say chance because it's funny
	stamina_damage = 85
	stun_armour_penetration = 40
	clumsy_knockdown_time = 24 SECONDS
	affect_cyborg = TRUE
	wait_desc = "still charging!"
	on_stun_sound = 'sound/items/weapons/contractor_baton/contractorbatonhit.ogg'
	unfolded_drop_sound = 'sound/items/baton/contractor_baton_unfolded_pickup.ogg'
	unfolded_pickup_sound = 'sound/items/baton/contractor_baton_unfolded_pickup.ogg'

	on_inhand_icon_state = "contractor_baton_on"
	on_sound = 'sound/items/weapons/contractorbatonextend.ogg'
	active_force = 16

/obj/item/melee/baton/telescopic/contractor_baton/additional_effects_non_cyborg(mob/living/target, mob/living/user)
	. = ..()
	target.set_jitter_if_lower(40 SECONDS)
	target.set_stutter_if_lower(40 SECONDS)

/obj/item/melee/baton/security
	name = "stun baton"
	desc = "A stun baton for incapacitating people with."
	desc_controls = "Left click to stun, right click to harm."
	icon = 'icons/obj/weapons/baton.dmi'
	icon_state = "stunbaton"
	base_icon_state = "stunbaton"
	inhand_icon_state = "stunbaton"
	worn_icon_state = "baton"
	icon_angle = -45
	force = 10
	wound_bonus = 0
	attack_verb_continuous = list("beats")
	attack_verb_simple = list("beat")
	armor_type = /datum/armor/baton_security
	throwforce = 7
	force_say_chance = 50
	stamina_damage = 60
	armour_type_against_stun = ENERGY
	// This value is added to our stun armour penetration when called by get_stun_penetration_value(). For giving some batons extra OOMPH.
	var/additional_stun_armour_penetration = 0
	knockdown_time = 5 SECONDS
	clumsy_knockdown_time = 15 SECONDS
	cooldown = 2.5 SECONDS
	on_stun_sound = 'sound/items/weapons/egloves.ogg'
	on_stun_volume = 50
	active = FALSE
	stun_on_harmbaton = TRUE
	wait_desc = "still charging!"
	activated_word = "activated"
	context_living_rmb_active = "Harmful Stun"
	light_range = 1.5
	light_system = OVERLAY_LIGHT
	light_on = FALSE
	light_color = LIGHT_COLOR_ORANGE
	light_power = 0.5
	var/inactive_drop_sound = 'sound/items/baton/stun_baton_inactive_drop.ogg'
	var/inactive_pickup_sound = 'sound/items/baton/stun_baton_inactive_pickup.ogg'
	var/active_drop_sound = 'sound/items/baton/stun_baton_active_drop.ogg'
	var/active_pickup_sound = 'sound/items/baton/stun_baton_active_pickup.ogg'
	drop_sound = 'sound/items/baton/stun_baton_inactive_drop.ogg'
	pickup_sound = 'sound/items/baton/stun_baton_inactive_pickup.ogg'
	sound_vary = TRUE

	var/throw_stun_chance = 35
	var/obj/item/stock_parts/power_store/cell
	var/preload_cell_type //if not empty the baton starts with this type of cell
	var/cell_hit_cost = STANDARD_CELL_CHARGE
	var/can_remove_cell = TRUE
	var/convertible = TRUE //if it can be converted with a conversion kit
	///Whether or not our inhand changes when active.
	var/active_changes_inhand = TRUE
	///Whether or not our baton visibly changes the inhand sprite based on inserted cell
	var/tip_changes_color = TRUE
	///When set, inhand_icon_state defaults to this instead of base_icon_state
	var/base_inhand_state = null

/datum/armor/baton_security
	bomb = 50
	fire = 80
	acid = 80

/obj/item/melee/baton/security/Initialize(mapload)
	. = ..()
	if(preload_cell_type)
		if(!ispath(preload_cell_type, /obj/item/stock_parts/power_store/cell))
			log_mapping("[src] at [AREACOORD(src)] had an invalid preload_cell_type: [preload_cell_type].")
		else
			cell = new preload_cell_type(src)
	RegisterSignal(src, COMSIG_ATOM_ATTACKBY, PROC_REF(convert))
	update_appearance()

/obj/item/melee/baton/security/get_cell()
	return cell

/obj/item/melee/baton/security/suicide_act(mob/living/user)
	if(cell?.charge && active)
		user.visible_message(span_suicide("[user] is putting the live [name] in [user.p_their()] mouth! It looks like [user.p_theyre()] trying to commit suicide!"))
		finalize_baton_attack(user, user)
		return FIRELOSS
	else
		user.visible_message(span_suicide("[user] is shoving \the [src] down their throat! It looks like [user.p_theyre()] trying to commit suicide!"))
		return OXYLOSS

/obj/item/melee/baton/security/Destroy()
	if(cell)
		QDEL_NULL(cell)
	UnregisterSignal(src, COMSIG_ATOM_ATTACKBY)
	return ..()

/obj/item/melee/baton/security/proc/convert(datum/source, obj/item/item, mob/user)
	SIGNAL_HANDLER

	if(!istype(item, /obj/item/conversion_kit) || !convertible)
		return
	var/turf/source_turf = get_turf(src)
	var/obj/item/melee/baton/baton = new (source_turf)
	baton.alpha = 20
	playsound(source_turf, 'sound/items/tools/drill_use.ogg', 80, TRUE, -1)
	animate(src, alpha = 0, time = 1 SECONDS)
	animate(baton, alpha = 255, time = 1 SECONDS)
	qdel(item)
	qdel(src)

/obj/item/melee/baton/security/on_saboteur(datum/source, disrupt_duration)
	. = ..()
	if(!active)
		return
	turn_off()
	update_appearance()
	return TRUE

/obj/item/melee/baton/security/Exited(atom/movable/mov_content)
	. = ..()
	if(mov_content == cell)
		cell = null
		turn_off()
		update_appearance()

/obj/item/melee/baton/security/update_icon_state()
	var/base_inhand = base_inhand_state || base_icon_state
	if(active)
		icon_state = "[base_icon_state]_active"
		if(active_changes_inhand)
			if(tip_changes_color)
				inhand_icon_state = "[base_inhand]_active_[get_baton_tip_color()]"
			else
				inhand_icon_state = "[base_inhand]_active"
		return ..()
	if(!cell)
		icon_state = "[base_icon_state]_nocell"
		inhand_icon_state = base_inhand
		return ..()
	icon_state = base_icon_state
	inhand_icon_state = base_inhand
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

/obj/item/melee/baton/security/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(item, /obj/item/stock_parts/power_store/cell))
		var/obj/item/stock_parts/power_store/cell/active_cell = item
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
	if(cell?.charge >= cell_hit_cost && !active)
		turn_on(user)
		balloon_alert(user, "turned on")
	else
		turn_off()
		if(!cell)
			balloon_alert(user, "no power source!")
		else if(cell?.charge < cell_hit_cost)
			balloon_alert(user, "out of charge!")
		else
			balloon_alert(user, "turned off")
	add_fingerprint(user)

/// Toggles the stun baton's light
/obj/item/melee/baton/security/proc/toggle_light()
	set_light_color(get_baton_tip_color(TRUE))
	set_light_on(!light_on)
	return

/// Change our baton's top color based on the contained cell.
/obj/item/melee/baton/security/proc/get_baton_tip_color(set_light = FALSE)
	var/tip_type_to_set
	var/tip_light_to_set

	if(cell)
		var/chargepower = cell.maxcharge
		var/zap_value = clamp(chargepower/STANDARD_CELL_CHARGE, 0, 100)
		switch(zap_value)
			if(-INFINITY to 10)
				tip_type_to_set = "orange"
				tip_light_to_set = LIGHT_COLOR_ORANGE
			if(11 to 20)
				tip_type_to_set = "red"
				tip_light_to_set = LIGHT_COLOR_INTENSE_RED
			if(21 to 30)
				tip_type_to_set = "green"
				tip_light_to_set = LIGHT_COLOR_GREEN
			if(31 to INFINITY)
				tip_type_to_set = "blue"
				tip_light_to_set = LIGHT_COLOR_BLUE
	else
		tip_type_to_set = "orange"

	return set_light ? tip_light_to_set : tip_type_to_set

/obj/item/melee/baton/security/proc/turn_on(mob/user)
	active = TRUE
	playsound(src, SFX_SPARKS, 75, TRUE, -1)
	update_appearance()
	toggle_light()
	do_sparks(1, TRUE, src)
	drop_sound = active_drop_sound
	pickup_sound = active_pickup_sound

/obj/item/melee/baton/security/proc/turn_off()
	active = FALSE
	set_light_on(FALSE)
	update_appearance()
	playsound(src, SFX_SPARKS, 75, TRUE, -1)
	drop_sound = inactive_drop_sound
	pickup_sound = inactive_pickup_sound

/obj/item/melee/baton/security/proc/deductcharge(deducted_charge)
	if(!cell)
		return
	//Note this value returned is significant, as it will determine
	//if a stun is applied or not
	. = cell.use(deducted_charge)
	if(active && cell.charge < cell_hit_cost)
		//we're below minimum, turn off
		turn_off()

/obj/item/melee/baton/security/clumsy_check(mob/living/carbon/human/user)
	. = ..()
	if(.)
		SEND_SIGNAL(user, COMSIG_LIVING_MINOR_SHOCK)
		deductcharge(cell_hit_cost)

/obj/item/melee/baton/security/pre_attack(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(. || !isliving(target))
		return .

	if(!active && !user.combat_mode)
		target.visible_message(
			span_warning("[user] prods [target] with [src]. Luckily it was off."),
			span_warning("[user] prods you with [src]. Luckily it was off."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
		)
		return TRUE

	return .

/obj/item/melee/baton/security/baton_effect(mob/living/target, mob/living/user, modifiers, stun_override)
	if(iscyborg(loc))
		var/mob/living/silicon/robot/robot = loc
		if(!robot || !robot.cell || !robot.cell.use(cell_hit_cost))
			return FALSE
	else if(!deductcharge(cell_hit_cost))
		return FALSE
	stun_override = 0 //Avoids knocking people down prematurely.
	return ..()

/obj/item/melee/baton/security/get_stun_penetration_value()
	if(cell)
		var/chargepower = cell.maxcharge
		var/zap_pen = clamp(chargepower/STANDARD_CELL_CHARGE, 0, 100)
		return zap_pen + additional_stun_armour_penetration
	return stun_armour_penetration + additional_stun_armour_penetration

/*
 * After a target is hit, we apply some status effects.
 * After a period of time, we then check to see what stun duration we give.
 */
/obj/item/melee/baton/security/additional_effects_non_cyborg(mob/living/target, mob/living/user)
	target.set_jitter_if_lower(40 SECONDS)
	target.set_confusion_if_lower(10 SECONDS)
	target.set_stutter_if_lower(16 SECONDS)

	SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK)
	addtimer(CALLBACK(src, PROC_REF(apply_stun_effect_end), target), 2 SECONDS)

/// After the initial stun period, we check to see if the target needs to have the stun applied.
/obj/item/melee/baton/security/proc/apply_stun_effect_end(mob/living/target)
	var/trait_check = HAS_TRAIT(target, TRAIT_BATON_RESISTANCE) //var since we check it in out to_chat as well as determine stun duration
	if(!target.IsKnockdown())
		to_chat(target, span_warning("Your muscles seize, making you collapse[trait_check ? ", but your body quickly recovers..." : "!"]"))

	if(!trait_check)
		target.Knockdown(knockdown_time)

/obj/item/melee/baton/security/get_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visible"] = span_danger("[user] stuns [target] with [src]!")
	.["local"] = span_userdanger("[user] stuns you with [src]!")

/obj/item/melee/baton/security/get_cyborg_stun_description(mob/living/target, mob/living/user)
	. = ..()
	if(!affect_cyborg)
		.["visible"] = span_danger("[user] tries to stun [target] with [src], and predictably fails!")
		.["local"] = span_userdanger("[user] tries to... stun you with [src]?")

/obj/item/melee/baton/security/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!. && active && prob(throw_stun_chance) && isliving(hit_atom))
		finalize_baton_attack(hit_atom, throwingdatum?.get_thrower())

/obj/item/melee/baton/security/emp_act(severity)
	. = ..()
	if (!cell)
		return
	if (!(. & EMP_PROTECT_SELF))
		cell.emp_act(severity)

	if (cell.charge >= cell_hit_cost)
		var/scramble_time
		scramble_mode()
		for(var/loops in 1 to rand(6, 12))
			scramble_time = rand(5, 15) / (1 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(scramble_mode)), scramble_time*loops * (1 SECONDS))

/obj/item/melee/baton/security/proc/scramble_mode()
	if (!cell || cell.charge < cell_hit_cost)
		return
	active = !active
	toggle_light()
	do_sparks(1, TRUE, src)
	playsound(src, SFX_SPARKS, 75, TRUE, -1)
	update_appearance()

/obj/item/melee/baton/security/loaded //this one starts with a cell pre-installed.
	preload_cell_type = /obj/item/stock_parts/power_store/cell/high

/obj/item/melee/baton/security/loaded/hos
	preload_cell_type = /obj/item/stock_parts/power_store/cell/super

//Makeshift stun baton. Replacement for stun gloves.
/obj/item/melee/baton/security/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton."
	desc_controls = "Left click to stun, right click to harm."
	icon = 'icons/obj/weapons/spear.dmi'
	icon_state = "stunprod"
	base_icon_state = "stunprod"
	inhand_icon_state = "prod"
	base_inhand_state = "prod"
	worn_icon_state = null
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	force = 3
	throwforce = 5
	cell_hit_cost = STANDARD_CELL_CHARGE * 2
	throw_stun_chance = 10
	slot_flags = ITEM_SLOT_BACK
	convertible = FALSE
	active_changes_inhand = FALSE
	tip_changes_color = FALSE
	var/obj/item/assembly/igniter/sparkler
	///Determines whether or not we can improve the cattleprod into a new type. Prevents turning the cattleprod subtypes into different subtypes, or wasting materials on making it....another version of itself.
	var/can_upgrade = TRUE

/obj/item/melee/baton/security/cattleprod/Initialize(mapload)
	. = ..()
	sparkler = new (src)

/obj/item/melee/baton/security/cattleprod/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)//handles sticking a crystal onto a stunprod to make an improved cattleprod
	if(!istype(item, /obj/item/stack))
		return ..()

	if(!can_upgrade)
		user.visible_message(span_warning("This prod is already improved!"))
		return ..()

	if(cell)
		user.visible_message(span_warning("You can't put the crystal onto the stunprod while it has a power cell installed!"))
		return ..()

	var/our_prod
	if(istype(item, /obj/item/stack/ore/bluespace_crystal))
		var/obj/item/stack/ore/bluespace_crystal/our_crystal = item
		our_crystal.use(1)
		our_prod = /obj/item/melee/baton/security/cattleprod/teleprod

	else if(istype(item, /obj/item/stack/telecrystal))
		var/obj/item/stack/telecrystal/our_crystal = item
		our_crystal.use(1)
		our_prod = /obj/item/melee/baton/security/cattleprod/telecrystalprod
	else
		to_chat(user, span_notice("You don't think \the [item] will do anything to improve \the [src]."))
		return ..()

	to_chat(user, span_notice("You place \the [item] firmly into \the [sparkler]."))
	remove_item_from_storage(user)
	qdel(src)
	var/obj/item/melee/baton/security/cattleprod/brand_new_prod = new our_prod(user.loc)
	user.put_in_hands(brand_new_prod)

/obj/item/melee/baton/security/cattleprod/can_baton(mob/living/target, mob/living/user)
	if(!sparkler.activate())
		return FALSE
	return ..()

/obj/item/melee/baton/security/cattleprod/Destroy()
	if(sparkler)
		QDEL_NULL(sparkler)
	return ..()

/obj/item/melee/baton/security/boomerang
	name = "\improper OZtek Boomerang"
	desc = "A device invented in 2486 for the great Space Emu War by the confederacy of Australicus, these high-tech boomerangs also work exceptionally well at stunning crewmembers. Just be careful to catch it when thrown!"
	throw_speed = 1
	icon = 'icons/obj/weapons/thrown.dmi'
	icon_state = "boomerang"
	base_icon_state = "boomerang"
	inhand_icon_state = "boomerang"
	force = 5
	throwforce = 5
	throw_range = 5
	cell_hit_cost = STANDARD_CELL_CHARGE * 2
	throw_stun_chance = 99  //Have you prayed today?
	convertible = FALSE
	active_changes_inhand = FALSE
	tip_changes_color = FALSE
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT*2, /datum/material/silver = SHEET_MATERIAL_AMOUNT*5, /datum/material/gold = SHEET_MATERIAL_AMOUNT)

/obj/item/melee/baton/security/boomerang/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/boomerang, throw_range + 2, TRUE)

/obj/item/melee/baton/security/boomerang/loaded //Same as above, comes with a cell.
	preload_cell_type = /obj/item/stock_parts/power_store/cell/high

/obj/item/melee/baton/security/cattleprod/teleprod
	name = "teleprod"
	desc = "A prod with a bluespace crystal on the end. The crystal doesn't look too fun to touch."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "teleprod"
	base_icon_state = "teleprod"
	inhand_icon_state = "teleprod"
	slot_flags = null
	can_upgrade = FALSE

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

/obj/item/melee/baton/security/cattleprod/telecrystalprod
	name = "snatcherprod"
	desc = "A prod with a telecrystal on the end. It sparks with a desire for theft and subversion."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "telecrystalprod"
	base_icon_state = "telecrystalprod"
	inhand_icon_state = "telecrystalprod"
	slot_flags = null
	throw_stun_chance = 50 //I think it'd be funny
	can_upgrade = FALSE

/obj/item/melee/baton/security/cattleprod/telecrystalprod/clumsy_check(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	do_teleport(src, get_turf(user), 50, channel = TELEPORT_CHANNEL_BLUESPACE) //Wait, where did it go?

/obj/item/melee/baton/security/cattleprod/telecrystalprod/baton_effect(mob/living/target, mob/living/user, modifiers, stun_override)
	. = ..()
	if(!.)
		return
	var/obj/item/stuff_in_hand = target.get_active_held_item()
	if(!user || !stuff_in_hand || !target.temporarilyRemoveItemFromInventory(stuff_in_hand))
		return
	if(user.put_in_inactive_hand(stuff_in_hand))
		stuff_in_hand.loc.visible_message(span_warning("[stuff_in_hand] suddenly appears in [user]'s hand!"))
	else
		stuff_in_hand.forceMove(user.drop_location())
		stuff_in_hand.loc.visible_message(span_warning("[stuff_in_hand] suddenly appears!"))


/obj/item/melee/baton/nunchaku
	name = "Syndie Fitness Nunchuks"
	desc = "The most common fitness equipment in the entire syndicate, titanium rods weigh strictly 13 pounds"
	desc_controls = "Left click to stun, right click to harm. Throw mode counterattack any melee/throwable attacks."
	icon_state = "nunchaku"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	inhand_icon_state = "nunchaku"
	worn_icon_state = "nunchaku"
	attack_verb_continuous = list("beats", "whips", "smashes", "punishes")
	attack_verb_simple = list("beat", "whip", "smash", "punish")
	hitsound = 'sound/items/weapons/chainhit.ogg'
	block_sound = 'sound/items/weapons/block_shield.ogg'
	slot_flags = ITEM_SLOT_BELT
	cooldown = CLICK_CD_MELEE
	knockdown_time = 0.25 SECONDS
	demolition_mod = 1.5
	stamina_damage = 30 // 4 hit stamcrit
	stun_armour_penetration = 30 // bronze-silver telescopic
	force = 16 // 7 hit crit
	exposed_wound_bonus = 5

/obj/item/melee/baton/nunchaku/proc/randomize_state()
	icon_state = pick(list("nunchaku", "nunchaku_x", "nunchaku_y"))
	update_appearance()

/obj/item/melee/baton/nunchaku/after_throw(datum/callback/callback)
	. = ..()
	randomize_state()

/obj/item/melee/baton/nunchaku/afterattack(atom/target, mob/user, click_parameters)
	. = ..()
	randomize_state()

/obj/item/melee/baton/nunchaku/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type, damage_type)
	if(attack_type == PROJECTILE_ATTACK || !owner.throw_mode)
		return ..()

	randomize_state()

	// blocks any melee/throwable attacks
	owner.adjustStaminaLoss(5)
	final_block_chance = 100

	// counterattack at melee
	if(attack_type in list(MELEE_ATTACK, UNARMED_ATTACK, LEAP_ATTACK))
		var/mob/living/attacker = GET_ASSAILANT(hitby)
		playsound(src, pick(list('sound/items/weapons/cqchit2.ogg', 'sound/items/weapons/cqchit1.ogg')), 70, FALSE)
		melee_attack_chain(owner, attacker, LEFT_CLICK)

	return ..()
