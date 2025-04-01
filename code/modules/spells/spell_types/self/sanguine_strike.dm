/// Enchants an item to deal either double damage, or +20 damage, whichever is less, and lifesteals for that amount + steals some blood.
/// multiplication can get a little instakill-y, so capping it at + 20 damage.
/// 10 force weapon doesn't get the cap and gains 10 damage, 20 total
/// 20 force weapon gets the cap of 20 damage added for a total of 40
/// 35 force weapon still gets the cap of 20 for a total of 55 instead of a whopping 70 damage
/// Steals 50 blood if they have enough. Splattercasting has one second of cooldown worth 5 blood, so 50 seconds cooldown of blood added!
/datum/action/cooldown/spell/sanguine_strike
	name = "Sanguine Strike"
	desc = "Enchants your next weapon strike to deal more damage, heal you for damage dealt, and refill blood."
	button_icon_state = "charge"

	sound = 'sound/effects/magic/charge.ogg'
	// makes this spell not take blood from splattercasting
	school = SCHOOL_SANGUINE
	cooldown_time = 60 SECONDS
	cooldown_reduction_per_rank = 10 SECONDS

	invocation = "SHAPSDAY."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	///Original force of the item enchanted.
	var/original_force = 0

/datum/action/cooldown/spell/sanguine_strike/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/sanguine_strike/can_cast_spell(feedback)
	var/obj/item/to_enchant = owner.get_active_held_item() || owner.get_inactive_held_item()
	if(!to_enchant)
		if(feedback)
			to_chat(owner, span_warning("You need to hold something to empower it!"))
		return FALSE
	if(!to_enchant.force)
		if(feedback)
			to_chat(owner, span_warning("[to_enchant] is too weak to empower! Find something that'll hurt someone!"))
		return FALSE
	return ..()

/datum/action/cooldown/spell/sanguine_strike/cast(mob/living/cast_on)
	. = ..()
	// Then charge their main hand item, then charge their offhand item
	var/obj/item/to_enchant = cast_on.get_active_held_item() || cast_on.get_inactive_held_item()
	if(!to_enchant)
		//this shouldn't have passed can_cast_spell, but sanity is needed
		return
	to_chat(cast_on, span_notice("[to_enchant] begins to glow red..."))
	apply_enchantment(to_enchant)
	//true cooldown starts when you use the item or drop it
	StartCooldown(INFINITY)

/datum/action/cooldown/spell/sanguine_strike/proc/apply_enchantment(obj/item/enchanted)
	original_force = enchanted.force
	enchanted.add_filter("sanguine_strike", 2, list("type" = "outline", "color" = "#c41515", "size" = 2))
	enchanted.force = min(enchanted.force * 2, enchanted.force + 20)
	enchanted.AddElement(/datum/element/lifesteal, enchanted.force)
	RegisterSignal(enchanted, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_enchanted_afterattack))
	RegisterSignal(enchanted, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))

/// signal called from attacking with the enchanted item
/datum/action/cooldown/spell/sanguine_strike/proc/on_enchanted_afterattack(obj/item/enchanted, atom/target, mob/user, click_parameters)
	SIGNAL_HANDLER
	end_enchantment(enchanted)
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	if(living_target.blood_volume < BLOOD_VOLUME_SURVIVE)
		return
	playsound(target, 'sound/effects/wounds/crackandbleed.ogg', 100)
	playsound(target, 'sound/effects/magic/charge.ogg', 100)
	var/attack_direction = get_dir(user, living_target)
	if(iscarbon(living_target))
		var/mob/living/carbon/carbon_target = living_target
		carbon_target.spray_blood(attack_direction, 3)
	living_target.blood_volume -= 50
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	//if we blind-added blood volume to the caster, non-vampire wizards could easily kill themselves by using the spell enough
	if(living_user.blood_volume < BLOOD_VOLUME_MAXIMUM)
		living_user.blood_volume += 50

/// signal called from dropping the enchanted item
/datum/action/cooldown/spell/sanguine_strike/proc/on_dropped(obj/item/enchanted, mob/dropper)
	SIGNAL_HANDLER
	to_chat(dropper, span_notice("[enchanted] seems to lose its red glow."))
	end_enchantment(enchanted)

/// ends the enchantment, starting the cooldown (which was frozen until you attacked)
/datum/action/cooldown/spell/sanguine_strike/proc/end_enchantment(obj/item/enchanted)
	UnregisterSignal(enchanted, list(COMSIG_ITEM_AFTERATTACK, COMSIG_ITEM_DROPPED))
	StartCooldown()
	enchanted.remove_filter("sanguine_strike")
	enchanted.force = original_force
	enchanted.RemoveElement(/datum/element/lifesteal, enchanted.force)
