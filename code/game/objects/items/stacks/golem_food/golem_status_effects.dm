/// Abstract holder for golem status effects, you should never have more than one of these active
/datum/status_effect/golem
	id = "golem_status"
	duration = 5 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/golem_status
	show_duration = TRUE
	/// Icon state prefix for overlay to display on golem limbs
	var/overlay_state_prefix
	/// Name of the mineral we ate to get this
	var/mineral_name = ""
	/// Text to display on buff application
	var/applied_fluff = ""
	/// Overlays we have applied to our mob
	var/list/active_overlays = list()
	/// Icon used to represent the alert
	var/alert_icon = 'icons/obj/stack_objects.dmi'
	/// Icon state to display to represent the alert
	var/alert_icon_state = "sheet-monkey"
	/// Tooltip to display when hovering over the alert
	var/alert_desc = "Something went wrong and this tooltip is not displaying correctly."
	/// If we are not a golem what color does the filter glow?
	var/filter_color = LIGHT_COLOR_DEFAULT

/atom/movable/screen/alert/status_effect/golem_status
	name = "Metamorphic %SOMETHING%"
	desc = "You've enjoyed a tasty meal and are now experiencing a bug."
	icon_state = "template"
	/// Overlay we show on top of the template icon
	var/mutable_appearance/mineral_overlay
	/// When we reach this much remaining time we will start animating as a warning
	var/early_expiry_warning = 30 SECONDS
	/// When we reach this much remaining time we will start animating more urgently as a warning
	var/imminent_expiry_warning = 5 SECONDS

/// Set up how the alert ACTUALLY looks, based on the effect applied
/atom/movable/screen/alert/status_effect/golem_status/proc/update_details(buff_time)
	var/datum/status_effect/golem/golem_effect = attached_effect
	if (!istype(golem_effect))
		CRASH("Golem status alert attached to invalid status effect.")
	name = replacetext(name, "%SOMETHING%", golem_effect.mineral_name)
	desc = golem_effect.alert_desc
	mineral_overlay = mutable_appearance(golem_effect.alert_icon, golem_effect.alert_icon_state)
	update_appearance(UPDATE_ICON)

	if (buff_time > early_expiry_warning)
		addtimer(CALLBACK(src, PROC_REF(early_warning)), buff_time - early_expiry_warning, TIMER_DELETE_ME)
	if (buff_time > imminent_expiry_warning)
		addtimer(CALLBACK(src, PROC_REF(imminent_warning)), buff_time - imminent_expiry_warning, TIMER_DELETE_ME)

/// Animate to indicate effect is expiring soon
/atom/movable/screen/alert/status_effect/golem_status/proc/early_warning()
	animate(src, alpha = 75, time = 1 SECONDS, loop = -1)
	animate(alpha = 255, time = 1 SECONDS, loop = -1)

/// Animate to indicate effect is expiring very soon
/atom/movable/screen/alert/status_effect/golem_status/proc/imminent_warning()
	animate(src, alpha = 25, time = 0.5 SECONDS, loop = -1)
	animate(alpha = 200, time = 0.5 SECONDS, loop = -1)

/atom/movable/screen/alert/status_effect/golem_status/update_overlays()
	. = ..()
	. += mineral_overlay

/atom/movable/screen/alert/status_effect/golem_status/Destroy()
	QDEL_NULL(mineral_overlay)
	return ..()

/datum/status_effect/golem/on_apply()
	. = ..()
	if (!ishuman(owner))
		return FALSE
	if (owner.has_status_effect(/datum/status_effect/golem))
		return FALSE
	if (applied_fluff)
		to_chat(owner, span_notice(applied_fluff))
	if (!overlay_state_prefix || !iscarbon(owner))
		return TRUE

	if(isgolem(owner))
		var/mob/living/carbon/golem_owner = owner
		for (var/obj/item/bodypart/part in golem_owner.bodyparts)
			// these overlays won't look good on anything but golem limbs
			if (part.limb_id != SPECIES_GOLEM)
				continue
			var/datum/bodypart_overlay/simple/golem_overlay/overlay = new()
			overlay.add_to_bodypart(overlay_state_prefix, part)
			active_overlays += overlay
		golem_owner.update_body_parts()
	else
		owner.add_filter("[id]_filter", 2, outline_filter("color" = filter_color, "size" = 1.25))
		var/the_filter = owner.get_filter("[id]_filter")
		animate(the_filter, alpha = 0) // start at 0 alpha
		animate(the_filter, alpha = 150, time = 7.5 SECONDS, loop = -1, easing = SINE_EASING) // fade in and out
		animate(alpha = 50, time = 7.5 SECONDS, loop = -1, easing = SINE_EASING)
	return TRUE

/datum/status_effect/golem/on_creation(mob/living/new_owner)
	if(!isgolem(new_owner))
		duration *= 0.1
	var/buff_duration = duration
	. = ..()
	if (!.)
		return .
	var/atom/movable/screen/alert/status_effect/golem_status/status_alert = linked_alert
	status_alert?.update_details(buff_time = buff_duration)

/datum/status_effect/golem/on_remove()
	to_chat(owner, span_warning("The effect of the [mineral_name] fades."))
	QDEL_LIST(active_overlays)
	owner.remove_filter("[id]_filter")
	return ..()

/datum/status_effect/golem/get_examine_text()
	return span_notice("[owner.p_Their()] body has been augmented with veins of [mineral_name].")

/// Body part overlays applied by golem status effects
/datum/bodypart_overlay/simple/golem_overlay
	icon = 'icons/mob/human/species/golems.dmi'
	layers = ALL_EXTERNAL_OVERLAYS
	///The bodypart that the overlay is currently applied to
	var/datum/weakref/attached_bodypart

/datum/bodypart_overlay/simple/golem_overlay/proc/add_to_bodypart(prefix, obj/item/bodypart/part)
	icon_state = "[prefix]_[part.body_zone]"
	attached_bodypart = WEAKREF(part)
	part.add_bodypart_overlay(src, update = FALSE)

/datum/bodypart_overlay/simple/golem_overlay/Destroy(force)
	var/obj/item/bodypart/referenced_bodypart = attached_bodypart.resolve()
	if(!referenced_bodypart)
		return ..()
	referenced_bodypart.remove_bodypart_overlay(src)
	return ..()

/// Freezes hunger for the duration
/datum/status_effect/golem/uranium
	overlay_state_prefix = "uranium"
	mineral_name = "uranium"
	applied_fluff = "Glowing crystals sprout from your body. You feel energised!"
	alert_icon_state = "sheet-uranium"
	alert_desc = "Internal radiation is providing all of your nutritional needs."
	filter_color = LIGHT_COLOR_GREEN

/datum/status_effect/golem/uranium/on_apply()
	. = ..()
	if (!.)
		return FALSE
	ADD_TRAIT(owner, TRAIT_NOHUNGER, TRAIT_STATUS_EFFECT(id))
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/golem_hunger)
	owner.remove_status_effect(/datum/status_effect/golem_statued) // Instant fix!
	return TRUE

/datum/status_effect/golem/uranium/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NOHUNGER, TRAIT_STATUS_EFFECT(id))
	return ..()

/// Magic immunity
/datum/status_effect/golem/silver
	overlay_state_prefix = "silver"
	mineral_name = "silver"
	applied_fluff = "Shining plates grace your shoulders. You feel holy!"
	alert_icon_state = "sheet-silver"
	alert_desc = "Your body repels supernatural influences."
	filter_color = LIGHT_COLOR_FAINT_BLUE

/datum/status_effect/golem/silver/on_apply()
	. = ..()
	if (!.)
		return FALSE
	owner.add_traits(list(TRAIT_ANTIMAGIC, TRAIT_HOLY), TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/golem/silver/on_remove()
	owner.remove_traits(list(TRAIT_ANTIMAGIC, TRAIT_HOLY), TRAIT_STATUS_EFFECT(id))
	return ..()

/// What do we multiply our damage by to convert it into power?
#define ENERGY_PER_DAMAGE (0.005 * STANDARD_CELL_CHARGE)
/// Multiplier to apply to burn damage, not 0 so that we can reverse it more easily
#define BURN_MULTIPLIER 0.05

/// Heat immunity, turns heat damage into local power
/datum/status_effect/golem/plasma
	overlay_state_prefix = "plasma"
	mineral_name = "plasma"
	applied_fluff = "Plasma cooling rods sprout from your body. You can take the heat!"
	alert_icon_state = "sheet-plasma"
	alert_desc = "You are protected from high pressure and can convert heat damage into power."
	filter_color = LIGHT_COLOR_PINK

/datum/status_effect/golem/plasma/on_apply()
	. = ..()
	if (!.)
		return FALSE
	owner.add_traits(list(TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTHEAT, TRAIT_ASHSTORM_IMMUNE), TRAIT_STATUS_EFFECT(id))
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_burned))
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.burn_mod *= BURN_MULTIPLIER
	return TRUE

/datum/status_effect/golem/plasma/on_remove()
	owner.remove_traits(list(TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTHEAT, TRAIT_ASHSTORM_IMMUNE), TRAIT_STATUS_EFFECT(id))
	UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE)
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.burn_mod /= BURN_MULTIPLIER
	return ..()

/// When we take fire damage (or... technically also cold damage, we don't differentiate), zap a nearby APC
/datum/status_effect/golem/plasma/proc/on_burned(datum/source, damage, damagetype, ...)
	SIGNAL_HANDLER
	if(damagetype != BURN)
		return

	var/obj/machinery/power/energy_accumulator/ground = get_closest_atom(/obj/machinery/power/energy_accumulator, view(4, owner), owner)
	if (ground)
		zap_effect(ground)
		ground.zap_act(damage, ZAP_GENERATES_POWER)
		return
	var/area/our_area = get_area(owner)
	var/obj/machinery/power/apc/our_apc = our_area.apc
	if (!our_apc)
		return
	zap_effect(our_apc)
	our_apc.cell?.give(damage * ENERGY_PER_DAMAGE)

#undef ENERGY_PER_DAMAGE
#undef BURN_MULTIPLIER

/// Shoot a beam at the target atom
/datum/status_effect/golem/plasma/proc/zap_effect(atom/target)
	owner.Beam(target, icon_state = "lightning[rand(1,12)]", time = 0.5 SECONDS)
	playsound(owner, 'sound/effects/magic/lightningshock.ogg', vol = 50, vary = TRUE)

/// Makes you spaceproof
/datum/status_effect/golem/plasteel
	overlay_state_prefix = "iron"
	mineral_name = "plasteel"
	applied_fluff = "Plasteel plates seal you tight. You feel tough!" // Doppler Edit, old code:	applied_fluff = "Plasteel plates seal you tight. You feel insulated!"
	alert_icon_state = "sheet-plasteel"
	alert_desc = "You are sealed against the cold, low pressure environments, and are armored!" // Doppler Edit, old code:	alert_desc = "You are sealed against the cold, and against low pressure environments."
	filter_color = LIGHT_COLOR_DEFAULT

//	 DOPPLER ADDITION START
/datum/movespeed_modifier/status_effect/golem_plasteel
	multiplicative_slowdown = 0.7 // Tank build?
// 	DOPPLER ADDITION END

/datum/status_effect/golem/plasteel/on_apply()
	. = ..()
	if (!.)
		return FALSE
	owner.add_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD), TRAIT_STATUS_EFFECT(id))
	// DOPPLER ADDITION START
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/golem_plasteel, update=TRUE)
	var/mob/living/carbon/human/golem_owner = owner
	golem_owner.physiology.damage_resistance += 15 // Gives them 15 extra damage resist. This totals out to 25. If you shot a golem with a 50 damage round, they'd eat 12.5 damage.
	// DOPPLER ADDITION END
	return TRUE

/datum/status_effect/golem/plasteel/on_remove()
	owner.remove_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD), TRAIT_STATUS_EFFECT(id))
	// DOPPLER ADDITION START
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/golem_plasteel, update=TRUE)
	var/mob/living/carbon/human/golem_owner = owner
	golem_owner.physiology.damage_resistance -= 15 // And God taketh away.
	// DOPPLER ADDITION END
	return ..()

/// Makes you reflect energy projectiles
/datum/status_effect/golem/gold
	overlay_state_prefix = "gold"
	mineral_name = "gold"
	applied_fluff = "Shining plates form across your body. You feel reflective!"
	alert_icon_state = "sheet-gold_2"
	alert_desc = "Your shining body reflects energy weapons."
	filter_color = LIGHT_COLOR_DIM_YELLOW

/datum/status_effect/golem/gold/on_apply()
	. = ..()
	if (!.)
		return FALSE
	owner.flags_ricochet |= RICOCHET_SHINY
	return TRUE

/datum/status_effect/golem/gold/on_remove()
	owner.flags_ricochet &= ~RICOCHET_SHINY
	return ..()

/// Makes you hard to see
/datum/status_effect/golem/diamond
	overlay_state_prefix = "diamond"
	mineral_name = "diamonds"
	applied_fluff = "Sparkling gems bend light around you. You feel stealthy!"
	tick_interval = 0.25 SECONDS
	alert_icon_state = "sheet-diamond"
	alert_desc = "Light is bending around you, making you hard to see while still and faster while moving."
	filter_color = LIGHT_COLOR_ELECTRIC_CYAN
	/// Alpha to remove per second while stood still
	var/alpha_per_tick = 20
	/// Alpha to apply while moving
	var/moving_alpha = 200
	/// List of arms we have updated
	var/list/modified_arms

/datum/status_effect/golem/diamond/on_apply()
	. = ..()
	if (!.)
		return FALSE
	RegisterSignals(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_THROW, COMSIG_MOB_ATTACK_HAND, COMSIG_MOB_ITEM_ATTACK), PROC_REF(on_reveal))
	owner.alpha = moving_alpha
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/light_speed)

	var/mob/living/carbon/carbon_owner = owner
	for (var/obj/item/bodypart/arm/arm in carbon_owner.bodyparts)
		set_arm_fluff(arm)
	return TRUE

/datum/status_effect/golem/diamond/tick(delta_time, times_fired)
	owner.alpha = max(owner.alpha - alpha_per_tick, 0)

/// Reset alpha to starting value
/datum/status_effect/golem/diamond/proc/on_reveal()
	SIGNAL_HANDLER
	owner.alpha = moving_alpha

/// Make our arm do slashing effects
/datum/status_effect/golem/diamond/proc/set_arm_fluff(obj/item/bodypart/arm/arm)
	arm.unarmed_attack_verbs = list("slash")
	arm.grappled_attack_verb = "lacerate"
	arm.unarmed_attack_effect = ATTACK_EFFECT_CLAW
	arm.unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
	arm.unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'
	RegisterSignal(arm, COMSIG_QDELETING, PROC_REF(on_arm_destroyed))
	LAZYADD(modified_arms, arm)

/datum/status_effect/golem/diamond/on_remove()
	owner.alpha = initial(owner.alpha)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/light_speed)
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_THROW, COMSIG_MOB_ATTACK_HAND, COMSIG_MOB_ITEM_ATTACK))
	for (var/obj/item/bodypart/arm/arm as anything in modified_arms)
		reset_arm_fluff(arm)
	LAZYCLEARLIST(modified_arms)
	return ..()

/// Make our arm do whatever it originally did
/datum/status_effect/golem/diamond/proc/reset_arm_fluff(obj/item/bodypart/arm/arm)
	if (!arm)
		return
	arm.unarmed_attack_verbs = initial(arm.unarmed_attack_verbs)
	arm.unarmed_attack_effect = initial(arm.unarmed_attack_effect)
	arm.unarmed_attack_sound = initial(arm.unarmed_attack_sound)
	arm.unarmed_miss_sound = initial(arm.unarmed_miss_sound)
	UnregisterSignal(arm, COMSIG_QDELETING)

/// Remove references to deleted arms
/datum/status_effect/golem/diamond/proc/on_arm_destroyed(obj/item/bodypart/arm/arm)
	SIGNAL_HANDLER
	modified_arms -= arm

/// Makes you tougher
/datum/status_effect/golem/titanium
	overlay_state_prefix = "platinum"
	mineral_name = "titanium"
	applied_fluff = "Titanium rings burst from your arms. You feel ready to take on the world!"
	alert_icon_state = "sheet-titanium"
	alert_desc = "You are more resistant to physical blows, and pack more of a punch yourself."
	filter_color = LIGHT_COLOR_HALOGEN
	/// Amount to reduce brute damage by
	var/brute_modifier = 0.7
	/// How much extra damage do we do with our fists?
	var/damage_increase = 3
	/// Deal this much extra damage to mining mobs, most of which take 0 unarmed damage usually
	var/mining_bonus = 30
	/// List of arms we have updated
	var/list/modified_arms

/datum/status_effect/golem/titanium/on_apply()
	. = ..()
	if (!.)
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	RegisterSignal(human_owner, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_punched))
	human_owner.physiology.brute_mod *= brute_modifier
	for (var/obj/item/bodypart/arm/arm in human_owner.bodyparts)
		buff_arm(arm)

/// Give mining mobs an extra slap
/datum/status_effect/golem/titanium/proc/on_punched(mob/living/puncher, atom/punchee, proximity)
	SIGNAL_HANDLER
	if (!proximity || !isliving(punchee))
		return NONE
	var/mob/living/victim = punchee
	if (victim.body_position == LYING_DOWN || (!(FACTION_MINING in victim.faction) && !(FACTION_BOSS in victim.faction)))
		return NONE
	victim.apply_damage(mining_bonus, BRUTE)

/// Make the targeted arm big and strong
/datum/status_effect/golem/titanium/proc/buff_arm(obj/item/bodypart/arm/arm)
	arm.unarmed_damage_low += damage_increase
	arm.unarmed_damage_high += damage_increase
	RegisterSignal(arm, COMSIG_QDELETING, PROC_REF(on_arm_destroyed))
	LAZYADD(modified_arms, arm)

/datum/status_effect/golem/titanium/on_remove()
	var/mob/living/carbon/human/human_owner = owner
	UnregisterSignal(human_owner, COMSIG_LIVING_UNARMED_ATTACK)
	human_owner.physiology.brute_mod /= brute_modifier
	for (var/obj/item/bodypart/arm/arm as anything in modified_arms)
		debuff_arm(arm)
	LAZYCLEARLIST(modified_arms)
	return ..()

/// Make the targeted arm small and weak
/datum/status_effect/golem/titanium/proc/debuff_arm(obj/item/bodypart/arm/arm)
	if (!arm)
		return
	arm.unarmed_damage_low -= damage_increase
	arm.unarmed_damage_high -= damage_increase
	UnregisterSignal(arm, COMSIG_QDELETING)

/// Remove references to deleted arms
/datum/status_effect/golem/titanium/proc/on_arm_destroyed(obj/item/bodypart/arm/arm)
	SIGNAL_HANDLER
	modified_arms -= arm

/// Makes you slippery
/datum/status_effect/golem/bananium
	overlay_state_prefix = "banana"
	mineral_name = "bananium"
	applied_fluff = "Bananium veins ooze from your crags. You feel a little funny!"
	alert_icon_state = "sheet-bananium"
	alert_desc = "You feel kind of funny."
	filter_color = LIGHT_COLOR_BRIGHT_YELLOW
	/// The slipperiness component which we have applied
	var/datum/component/slippery/slipperiness

/datum/status_effect/golem/bananium/on_apply()
	. = ..()
	if (!.)
		return
	owner.AddElementTrait(TRAIT_WADDLING, TRAIT_STATUS_EFFECT(id), /datum/element/waddling)
	ADD_TRAIT(owner, TRAIT_NO_SLIP_WATER, TRAIT_STATUS_EFFECT(id))
	slipperiness = owner.AddComponent(\
		/datum/component/slippery,\
		knockdown = 12 SECONDS,\
		lube_flags = NO_SLIP_WHEN_WALKING,\
		can_slip_callback = CALLBACK(src, PROC_REF(try_slip)),\
	)

/// Only slip people when we're down on the ground
/datum/status_effect/golem/bananium/proc/try_slip(mob/living/slipper, mob/living/slippee)
	return owner.body_position == LYING_DOWN

/datum/status_effect/golem/bananium/on_remove()
	owner.remove_traits(list(TRAIT_WADDLING, TRAIT_NO_SLIP_WATER), TRAIT_STATUS_EFFECT(id))
	QDEL_NULL(slipperiness)
	return ..()

#define LIGHTBULB_FILTER "filter_lightbulb_glow"

/// Lights up the golem, NOT using the golem subtype because it is not exclusive with other status effects
/datum/status_effect/golem_lightbulb
	id = "golem_lightbulb"
	status_type = STATUS_EFFECT_REFRESH
	duration = 2 MINUTES
	alert_type = null
	var/glow_range = 3
	var/glow_power = 1
	var/glow_color = LIGHT_COLOR_DEFAULT
	var/obj/effect/dummy/lighting_obj/moblight/lightbulb

/datum/status_effect/golem_lightbulb/on_creation(mob/living/new_owner, ...)
	if(!isgolem(new_owner))
		duration *= 0.3
	return ..()

/datum/status_effect/golem_lightbulb/on_apply()
	. = ..()
	if (!.)
		return
	to_chat(owner, span_notice("You start to emit a healthy glow."))
	lightbulb = owner.mob_light(glow_range, glow_power, glow_color)
	owner.add_filter(LIGHTBULB_FILTER, 2, list("type" = "outline", "color" = glow_color, "alpha" = 60, "size" = 1))

/datum/status_effect/golem_lightbulb/on_remove()
	QDEL_NULL(lightbulb)
	owner.remove_filter(LIGHTBULB_FILTER)
	to_chat(owner, span_warning("Your glow fades."))
	return ..()

#undef LIGHTBULB_FILTER
