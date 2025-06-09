/*!
 * Contains the eldritch robes for heretics, a suit of armor that they can make via a ritual
 */

// Eldritch armor. Looks cool, hood lets you cast heretic spells.
/obj/item/clothing/suit/hooded/cultrobes/eldritch
	name = "ominous armor"
	desc = "A ragged, dusty set of robes. Strange eyes line the inside."
	icon_state = "eldritch_armor"
	inhand_icon_state = null
	flags_inv = HIDESHOES | HIDEJUMPSUIT | HIDEBELT
	body_parts_covered = CHEST | GROIN | LEGS | FEET | ARMS
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	clothing_flags = THICKMATERIAL
	transparent_protection = HIDEGLOVES | HIDESUITSTORAGE | HIDEJUMPSUIT | HIDESHOES | HIDENECK
	cold_protection = FULL_BODY
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/gun/ballistic/rifle/lionhunter)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch
	armor_type = /datum/armor/eldritch_armor
	/// Whether the hood is flipped up
	var/hood_up = FALSE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/on_hood_up(obj/item/clothing/head/hooded/hood)
	hood_up = TRUE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/on_hood_down(obj/item/clothing/head/hooded/hood)
	hood_up = FALSE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return
	if(hood_up)
		return

	// Our hood gains the heretic_focus element.
	. += span_notice("Allows you to cast heretic spells while the hood is up.")

/obj/item/clothing/head/hooded/cult_hoodie/eldritch
	name = "ominous hood"
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	icon_state = "eldritch"
	desc = "A torn, dust-caked hood. Strange eyes line the inside."
	flags_inv = HIDEMASK | HIDEEARS | HIDEEYES | HIDEFACE | HIDEHAIR | HIDEFACIALHAIR | HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	flash_protect = FLASH_PROTECTION_WELDER_HYPER_SENSITIVE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	clothing_flags = THICKMATERIAL | SNUG_FIT
	armor_type = /datum/armor/eldritch_armor

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/heretic_focus)

/datum/armor/eldritch_armor
	melee = 50
	bullet = 50
	laser = 50
	energy = 50
	bomb = 35
	bio = 20
	fire = 20
	acid = 20
	wound = 20

//---- Path-Specific Eldritch Robes, First is robes, then is hood
// Ash
/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash
	name = "\improper Scorched Mantle"
	desc = "Left to burn to tatters, what remains is naught but a blackened echo of the mantle of the Watch. \
		Yet the soot-choked folds turn blade and flame from the form within. A brief reprieve before its gaze turns inwards."
	icon_state = "ash_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/ash
	armor_type = /datum/armor/eldritch_armor/ash
	flags_inv = HIDEBELT
	body_parts_covered = FULL_BODY
	heat_protection = FULL_BODY
	max_heat_protection_temperature = 50000
	cold_protection = FULL_BODY
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF | LAVA_PROOF | FREEZE_PROOF
	actions_types = list(/datum/action/item_action/toggle/flames)
	/// If our robes are actively generating flames
	var/flame_generation = FALSE
	/// Cooldown before our robes will create new flames
	COOLDOWN_DECLARE(flame_creation)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/equipped(mob/living/user, slot)
	. = ..()
	if(!(slot_flags & slot))
		user.fire_stack_decay_rate = initial(user.fire_stack_decay_rate)
		if(flame_generation)
			toggle_flames(user)
		return
	user.fire_stack_decay_rate = 0

/datum/action/item_action/toggle/flames
	button_icon = 'icons/effects/magic.dmi'
	button_icon_state = "fireball"

/datum/action/item_action/toggle/flames/do_effect(trigger_flags)
	var/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/item_target = target
	if(!item_target || !istype(item_target))
		return FALSE
	item_target.toggle_flames(owner)

/// Starts/Stops the passive generation of fire stacks on our wearer
/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/proc/toggle_flames(mob/user)
	if(!flame_generation)
		START_PROCESSING(SSobj, src)
		user.balloon_alert(user, "enabled")
	else
		STOP_PROCESSING(SSobj, src)
		user.balloon_alert(user, "disabled")
		if(!isliving(user))
			user.extinguish()
		else
			var/mob/living/living_mob = user
			living_mob.extinguish_mob()
	flame_generation = !flame_generation

/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, flame_creation))
		return
	var/mob/living/wearer = loc
	if(!isliving(wearer))
		STOP_PROCESSING(SSobj, src)
		flame_generation = FALSE
		return
	COOLDOWN_START(src, flame_creation, 5 SECONDS)
	wearer.adjust_fire_stacks(1)
	wearer.fire_stack_decay_rate = 0
	wearer.ignite_mob(TRUE)

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/ash
	name = "\improper Scorched Mantle"
	desc = "Left to burn to tatters, what remains is naught but a blackened echo of the mantle of the Watch. \
		Yet the soot-choked folds turn blade and flame from the form within. A brief reprieve before its gaze turns inwards."
	icon_state = "ash_armor"
	armor_type = /datum/armor/eldritch_armor/ash

/datum/armor/eldritch_armor/ash
	melee = 40
	bullet = 60
	laser = 40
	energy = 40
	bomb = 100
	bio = 20
	fire = 100
	acid = 20
	wound = 20

// Blade
/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade
	name = "\improper Shattered Panoply"
	desc = "The sharpened edges of this ancient suit of armor assert a revelation known to aspirants of battle; \
			a true warrior can not be distinguished from the blade they wield."
	icon_state = "blade_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/blade
	armor_type = /datum/armor/eldritch_armor/blade
	siemens_coefficient = 0

/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/equipped(mob/living/user, slot)
	. = ..()
	if(!(slot_flags & slot))
		user.remove_traits(list(TRAIT_SHOCKIMMUNE, TRAIT_BATON_RESISTANCE), REF(src))
		return
	user.add_traits(list(TRAIT_SHOCKIMMUNE, TRAIT_BATON_RESISTANCE), REF(src))

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/blade
	name = "\improper Shattered Panoply"
	desc = "The sharpened edges of this ancient suit of armor assert a revelation known to aspirants of battle; \
			a true warrior can not be distinguished from the blade they wield."
	icon_state = "blade_armor"
	armor_type = /datum/armor/eldritch_armor/blade
	siemens_coefficient = 0

/datum/armor/eldritch_armor/blade
	melee = 50
	bullet = 50
	laser = 50
	energy = 50
	bomb = 50
	bio = 50
	fire = 50
	acid = 50
	wound = 30

// Cosmic
/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic
	name = "\improper Starwoven Cloak"
	desc = "Gleaming gems conjure forth wisps of power, turning about to illuminate the wearer in a dim radiance. \
			Gazing upon the robe, you cannot help but feel noticed."
	icon_state = "cosmic_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/cosmic
	armor_type = /datum/armor/eldritch_armor/cosmic
	clothing_flags = THICKMATERIAL | STOPSPRESSUREDAMAGE
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	actions_types = list(/datum/action/item_action/toggle/gravity)
	/// If our robes are making us weightless
	var/weightless_enabled = FALSE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/equipped(mob/living/user, slot)
	. = ..()
	if(!(slot_flags & slot) && weightless_enabled)
		toggle_gravity(user)

/datum/action/item_action/toggle/gravity
	button_icon = 'icons/effects/magic.dmi'
	button_icon_state = "magicm"

/datum/action/item_action/toggle/gravity/do_effect(trigger_flags)
	var/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/item_target = target
	if(!item_target || !istype(item_target))
		return FALSE
	item_target.toggle_gravity(owner)

/// Gives us free movement in 0 gravity when enabled
/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/proc/toggle_gravity(mob/living/user)
	if(!weightless_enabled)
		user.add_traits(list(TRAIT_NEGATES_GRAVITY, TRAIT_MOVE_FLYING, TRAIT_FREE_HYPERSPACE_MOVEMENT), REF(src))
		user.balloon_alert(user, "enabled")
	else
		user.remove_traits(list(TRAIT_NEGATES_GRAVITY, TRAIT_MOVE_FLYING, TRAIT_FREE_HYPERSPACE_MOVEMENT), REF(src))
		user.balloon_alert(user, "disabled")
	weightless_enabled = !weightless_enabled

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/cosmic
	name = "\improper Starwoven Hood"
	desc = "Gleaming gems conjure forth wisps of power, turning about to illuminate the wearer in a dim radiance. \
			Gazing upon the robe, you cannot help but feel noticed."
	icon_state = "cosmic_armor"
	armor_type = /datum/armor/eldritch_armor/cosmic
	clothing_flags = THICKMATERIAL | STOPSPRESSUREDAMAGE
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/cosmic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

/datum/armor/eldritch_armor/cosmic
	melee = 20
	bullet = 30
	laser = 60
	energy = 60
	bomb = 35
	bio = 20
	fire = 20
	acid = 20
	wound = 20

// Flesh
/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh
	icon_state = "flesh_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/flesh
	armor_type = /datum/armor/eldritch_armor/flesh

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/flesh
	icon_state = "flesh_armor"
	armor_type = /datum/armor/eldritch_armor/flesh

/datum/armor/eldritch_armor/flesh
	melee = 60
	bullet = 40
	laser = 30
	energy = 30
	bomb = 35
	bio = 100
	fire = 0
	acid = 100
	wound = 20

// Lock
/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock
	icon_state = "lock_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/lock
	armor_type = /datum/armor/eldritch_armor/lock

/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock/equipped(mob/living/user, slot)
	. = ..()
	if(!(slot_flags & slot))
		user.RemoveElement(/datum/element/digitalcamo)
		user.remove_traits(list(TRAIT_SILENT_FOOTSTEPS, TRAIT_UNKNOWN), REF(src))
		return
	user.AddElement(/datum/element/digitalcamo)
	user.add_traits(list(TRAIT_SILENT_FOOTSTEPS, TRAIT_UNKNOWN), REF(src))

/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock/Destroy()
	if(!ismob(loc))
		return ..()
	var/mob/wearer = loc
	wearer.RemoveElement(/datum/element/digitalcamo)
	wearer.remove_traits(list(TRAIT_SILENT_FOOTSTEPS, TRAIT_UNKNOWN), REF(src))
	return ..()

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/lock
	icon_state = "lock_armor"
	armor_type = /datum/armor/eldritch_armor/lock

/datum/armor/eldritch_armor/lock
	melee = 40
	bullet = 40
	laser = 40
	energy = 40
	bomb = 40
	bio = 40
	fire = 40
	acid = 40
	wound = 40

// Moon
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon
	name = "\improper Resplendant Regalia"
	desc = "The confounding nature of this opulent garb turns and twists the sight. \
			The viewer must come to a chilling revelation; \
			what they see is as true as any other face."
	icon_state = "moon_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/moon
	armor_type = /datum/armor/eldritch_armor/moon
	flags_inv = HIDESHOES | HIDEJUMPSUIT | HIDEMUTWINGS
	/// Hud that gets shown to the wearer, gives a rough estimate of their current brain damage
	var/atom/movable/screen/moon_health/health_hud
	/// Boolean if you are brain dead so the sound doesn't spam during the delay
	var/braindead = FALSE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/Destroy()
	if(!ishuman(loc))
		return ..()
	var/mob/living/carbon/human/wearer = loc
	wearer.remove_traits(list(TRAIT_BATON_RESISTANCE, TRAIT_STUNIMMUNE, TRAIT_NEVER_WOUNDED, TRAIT_PACIFISM), REF(src))
	wearer.remove_movespeed_mod_immunities(REF(src), /datum/movespeed_modifier/equipment_speedmod)
	UnregisterSignal(wearer, list(COMSIG_MOB_HUD_CREATED, COMSIG_LIVING_CHECK_BLOCK, COMSIG_LIVING_ADJUST_BRUTE_DAMAGE, COMSIG_LIVING_ADJUST_BURN_DAMAGE, COMSIG_LIVING_ADJUST_OXY_DAMAGE, COMSIG_LIVING_ADJUST_TOX_DAMAGE, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE, COMSIG_MOB_AFTER_APPLY_DAMAGE, COMSIG_LIVING_DEATH))
	var/obj/item/organ/brain/our_brain = wearer.get_organ_slot(ORGAN_SLOT_BRAIN)
	REMOVE_TRAIT(our_brain, TRAIT_BRAIN_DAMAGE_NODEATH, REF(src))
	on_hud_remove(wearer)
	return ..()

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/equipped(mob/living/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(!(slot_flags & slot))
		user.remove_traits(list(TRAIT_BATON_RESISTANCE, TRAIT_STUNIMMUNE, TRAIT_NEVER_WOUNDED, TRAIT_PACIFISM), REF(src))
		user.remove_movespeed_mod_immunities(REF(src), /datum/movespeed_modifier/equipment_speedmod)
		UnregisterSignal(user, list(COMSIG_MOB_HUD_CREATED, COMSIG_LIVING_CHECK_BLOCK, COMSIG_LIVING_ADJUST_BRUTE_DAMAGE, COMSIG_LIVING_ADJUST_BURN_DAMAGE, COMSIG_LIVING_ADJUST_OXY_DAMAGE, COMSIG_LIVING_ADJUST_TOX_DAMAGE, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE, COMSIG_MOB_AFTER_APPLY_DAMAGE, COMSIG_LIVING_DEATH))
		var/obj/item/organ/brain/our_brain = user.get_organ_slot(ORGAN_SLOT_BRAIN)
		REMOVE_TRAIT(our_brain, TRAIT_BRAIN_DAMAGE_NODEATH, REF(src))
		braindead = FALSE
		if(health_hud in user.hud_used.infodisplay)
			on_hud_remove(user)
		return

	// Gives the hud to the wearer, if there's no hud, register the signal to be given on creation
	if(user.hud_used)
		on_hud_created(user)
	else
		RegisterSignal(user, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))

	// Gives the traits and effects
	user.add_movespeed_mod_immunities(REF(src), /datum/movespeed_modifier/equipment_speedmod)
	user.add_traits(list(TRAIT_BATON_RESISTANCE, TRAIT_STUNIMMUNE, TRAIT_NEVER_WOUNDED, TRAIT_PACIFISM), REF(src))
	RegisterSignal(user, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(block_checked))
	RegisterSignals(user, list(COMSIG_LIVING_ADJUST_BRUTE_DAMAGE, COMSIG_LIVING_ADJUST_BURN_DAMAGE, COMSIG_LIVING_ADJUST_OXY_DAMAGE, COMSIG_LIVING_ADJUST_TOX_DAMAGE, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE), PROC_REF(on_damage_adjust))
	RegisterSignal(user, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(on_take_damage))
	RegisterSignal(user, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	var/obj/item/organ/brain/our_brain = user.get_organ_slot(ORGAN_SLOT_BRAIN)
	ADD_TRAIT(our_brain, TRAIT_BRAIN_DAMAGE_NODEATH, REF(src))

/// Gives the health HUD to the wearer
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/on_hud_created(mob/living/carbon/human/wearer)
	SIGNAL_HANDLER
	var/datum/hud/original_hud = wearer.hud_used
	// Remove the old health elements
	var/list/to_remove = list(/atom/movable/screen/stamina, /atom/movable/screen/healths, /atom/movable/screen/healthdoll/human)
	for(var/removing in original_hud.infodisplay)
		if(is_type_in_list(removing, to_remove))
			original_hud.infodisplay -= removing
			QDEL_NULL(removing)
	wearer.mob_mood.unmodify_hud()
	// Add the moon health hud element
	health_hud = new(null, original_hud)
	original_hud.infodisplay += health_hud
	original_hud.show_hud(original_hud.hud_version)
	UnregisterSignal(wearer, COMSIG_MOB_HUD_CREATED)

/// Removes the HUD element from the wearer
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/on_hud_remove(mob/living/carbon/human/wearer)
	var/datum/hud/original_hud = wearer.hud_used
	original_hud.infodisplay -= health_hud
	// Restore the old health elements
	var/atom/movable/screen/stamina/stamina_hud = new(null, original_hud)
	var/atom/movable/screen/healths/old_health_hud = new(null, original_hud)
	var/atom/movable/screen/healthdoll/human/health_doll_hud = new(null, original_hud)
	original_hud.infodisplay += stamina_hud
	original_hud.infodisplay += old_health_hud
	original_hud.infodisplay += health_doll_hud
	wearer.mob_mood.modify_hud()
	original_hud.show_hud(original_hud.hud_version)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/allow_attack_hand_drop(mob/user)
	if(!ishuman(user))
		return ..()
	var/mob/living/carbon/human/wearer = user
	if(wearer.get_organ_loss(ORGAN_SLOT_BRAIN) > 0)
		to_chat(user, span_warning("Brain too damaged to remove!"))
		return FALSE
	return ..()

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	if(!ishuman(user))
		return ..()
	var/mob/living/carbon/human/wearer = user
	if(wearer.get_organ_loss(ORGAN_SLOT_BRAIN) > 0)
		to_chat(user, span_warning("Brain too damaged to remove!"))
		return FALSE
	return ..()

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/block_checked(mob/living/carbon/human/wearer, attacker, damage, attack_text, attack_type, armour_penetration, damage_type)
	SIGNAL_HANDLER
	if(!ishuman(wearer))
		return
	if(damage <= 0)
		return SUCCESSFUL_BLOCK

	wearer.adjustOrganLoss(ORGAN_SLOT_BRAIN, damage)
	if(wearer.get_organ_loss(ORGAN_SLOT_BRAIN) >= 200 && !braindead)
		braindead = TRUE
		playsound(wearer, 'sound/effects/pope_entry.ogg', 100)
		to_chat(wearer, span_bold(span_hypnophrase("A terrible fate has befallen you")))
		addtimer(CALLBACK(src, PROC_REF(kill_wearer), wearer), 5 SECONDS)
	return SUCCESSFUL_BLOCK

/**
 * Handles anything that calls 'adjustBruteLoss()` or any of the other damage types.
 * Negates the damage and applies it as brain damage instead
 * Healing won't be negated
 */
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/on_damage_adjust(mob/living/carbon/human/wearer, type, amount, forced)
	if(amount < 0)
		return
	if(!ishuman(wearer))
		return
	wearer.adjustOrganLoss(ORGAN_SLOT_BRAIN, amount)
	if(wearer.get_organ_loss(ORGAN_SLOT_BRAIN) >= 200 && !braindead)
		braindead = TRUE
		playsound(wearer, 'sound/effects/pope_entry.ogg', 100)
		to_chat(wearer, span_bold(span_hypnophrase("A terrible fate has befallen you")))
		addtimer(CALLBACK(src, PROC_REF(kill_wearer), wearer), 5 SECONDS)
	return COMPONENT_IGNORE_CHANGE

/// Handles anything that calls `apply_damage()`, calculates the damage taken and converts it to brain damage
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/on_take_damage(mob/living/carbon/human/wearer, damage_dealt, damagetype, def_zone, blocked, wound_bonus, bare_wound_bonus, sharpness, attack_direction, attacking_item, wound_clothing)
	SIGNAL_HANDLER
	if(!ishuman(wearer))
		return
	var/total_damage
	total_damage += wearer.getBruteLoss()
	total_damage += wearer.getFireLoss()
	total_damage += wearer.getToxLoss()
	total_damage += wearer.getOxyLoss()
	total_damage += wearer.getStaminaLoss()
	if(!total_damage)
		return
	wearer.setBruteLoss(0, forced = TRUE)
	wearer.setFireLoss(0, forced = TRUE)
	wearer.setToxLoss(0, forced = TRUE)
	wearer.setOxyLoss(0, forced = TRUE)
	wearer.setStaminaLoss(0, forced = TRUE)
	// Convert all damage to brain damage, good luck
	wearer.adjustOrganLoss(ORGAN_SLOT_BRAIN, total_damage)
	if(wearer.get_organ_loss(ORGAN_SLOT_BRAIN) >= 200 && !braindead)
		braindead = TRUE
		wearer.setOrganLoss(ORGAN_SLOT_BRAIN, INFINITY)
		playsound(wearer, 'sound/effects/pope_entry.ogg', 100)
		to_chat(wearer, span_bold(span_hypnophrase("A terrible fate has befallen you")))
		addtimer(CALLBACK(src, PROC_REF(kill_wearer), wearer), 5 SECONDS)

/// Once you reach this point you're completely brain dead, so lets play our effects before you eat shit
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/kill_wearer(mob/living/carbon/human/wearer)
	if(IS_HERETIC(wearer))
		var/datum/action/cooldown/spell/aoe/moon_ringleader/temp_spell = new(wearer)
		temp_spell.cast(wearer)
	var/obj/item/organ/brain/our_brain = wearer.get_organ_slot(ORGAN_SLOT_BRAIN)
	REMOVE_TRAIT(our_brain, TRAIT_BRAIN_DAMAGE_NODEATH, REF(src))
	wearer.death()

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/on_death(mob/wearer)
	SIGNAL_HANDLER
	if(!ishuman(wearer))
		return
	var/mob/living/carbon/human/human_wearer = wearer
	var/obj/item/bodypart/head/to_explode = human_wearer.get_bodypart(BODY_ZONE_HEAD)
	if(!to_explode)
		return
	var/obj/item/organ/brain/brain = human_wearer.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(brain)
		brain.Remove(human_wearer, special = TRUE, movement_flags = NO_ID_TRANSFER)
		brain.zone = BODY_ZONE_CHEST
		brain.Insert(human_wearer, special = TRUE, movement_flags = NO_ID_TRANSFER)
	human_wearer.visible_message(span_warning("[human_wearer]'s head splatters with a sickening crunch!"), ignored_mobs = list(human_wearer))
	new /obj/effect/gibspawner/generic(get_turf(human_wearer), human_wearer)
	to_explode.drop_organs()
	to_explode.dismember(dam_type = BRUTE, silent = TRUE)
	qdel(to_explode)

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/moon
	name = "\improper Resplendant Hood"
	icon_state = "moon_armor"
	armor_type = /datum/armor/eldritch_armor/moon

/datum/armor/eldritch_armor/moon
	melee = 0
	bullet = 0
	laser = 0
	energy = 0
	bomb = 0
	bio = 0
	fire = 0
	acid = 0
	wound = 0

/atom/movable/screen/moon_health
	name = "Health Level"
	icon = 'icons/hud/moon_health_64x64.dmi'
	icon_state = "moon_hud_1"
	base_icon_state = "moon_hud"
	screen_loc = "EAST-1:0, SOUTH+6:16"

/atom/movable/screen/moon_health/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	if(isnull(hud_owner))
		return INITIALIZE_HINT_QDEL
	RegisterSignal(hud_owner.mymob, COMSIG_LIVING_LIFE, PROC_REF(update_health))

/// Changes the icon based on the brain health of the wearer
/atom/movable/screen/moon_health/proc/update_health(datum/source)
	SIGNAL_HANDLER
	if(!ishuman(source))
		return
	var/mob/living/carbon/human/wearer = source
	if(istype(wearer.wear_suit, /obj/item/clothing/suit/hooded/cultrobes/eldritch/moon))
		var/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/robes = wearer.wear_suit
		if(robes.braindead)
			icon_state = base_icon_state + "_6"
			return // Don't update the icon once our "dying" process has begun
	switch(wearer.get_organ_loss(ORGAN_SLOT_BRAIN))
		if(0 to 20)
			icon_state = base_icon_state + "_1"
		if(21 to 50)
			icon_state = base_icon_state + "_2"
		if(51 to 100)
			icon_state = base_icon_state + "_3"
		if(101 to 150)
			icon_state = base_icon_state + "_4"
		if(151 to 189)
			icon_state = base_icon_state + "_5"
		if(190 to INFINITY)
			icon_state = base_icon_state + "_6"

// Rust
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust
	name = "\improper Salvaged Remains"
	desc = "Touching the folds of this plain robe seem to fill you with unease. \
			Even looking fills you with a sense of vertigo. \
			Some pulse threatening to pull you within."
	icon_state = "rust_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust
	armor_type = /datum/armor/eldritch_armor/rust
	/// Grace period timer before the
	COOLDOWN_DECLARE(rust_grace_period)
	/// If our armor is rusted, used to update the sprite
	var/rusted = FALSE
	/// Atom used to animate our overlay
	var/atom/movable/rust_overlay
	/// The mutable that is actually overlayed on the mob
	var/mutable_appearance/rust_appearance
	/// identifier for the overlay
	var/static/overlay_id = 0

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/Initialize(mapload)
	. = ..()
	overlay_id++

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/equipped(mob/living/user, slot)
	. = ..()
	if(!(slot_flags & slot))
		UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED))
		user.vis_contents -= rust_overlay
		rusted = FALSE
		QDEL_NULL(rust_overlay)
		QDEL_NULL(rust_appearance)
		return
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	rust_overlay = new()
	rust_overlay.icon = 'icons/mob/clothing/suits/armor.dmi'
	rust_overlay.render_target = "*rust_overlay_[overlay_id]"
	rust_overlay.vis_flags |= VIS_INHERIT_DIR | VIS_INHERIT_LAYER | VIS_INHERIT_ID
	user.vis_contents += rust_overlay // Should be invisible, we just update the sprite as needed

	rust_appearance = new /mutable_appearance()
	rust_appearance.render_source = "*rust_overlay_[overlay_id]"
	update_appearance(UPDATE_ICON)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/Destroy(force)
	if(!ismob(loc))
		return ..()
	var/mob/wearer = loc
	UnregisterSignal(wearer, list(COMSIG_MOVABLE_MOVED))
	wearer.vis_contents -= rust_overlay
	QDEL_NULL(rust_overlay)
	QDEL_NULL(rust_appearance)
	rusted = FALSE
	return ..()

/*
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Checks if our armor values should be increased on the new turf
 */
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/turf/mover_turf = get_turf(source)
	if(HAS_TRAIT(mover_turf, TRAIT_RUSTY))
		armor_type = /datum/armor/eldritch_armor/rust/on_rust
		ADD_TRAIT(source, TRAIT_PIERCEIMMUNE, REF(src))
		COOLDOWN_RESET(src, rust_grace_period)
		if(rusted) // Already rusted, don't update overlay
			return
		rusted = TRUE
		update_rust()
	else
		if(!rusted) // Already unrusted, don't update overlay
			return
		// Start the timer for the first time we step off rust
		if(!COOLDOWN_STARTED(src, rust_grace_period))
			COOLDOWN_START(src, rust_grace_period, 1 SECONDS)
			return
		if(!COOLDOWN_FINISHED(src, rust_grace_period))
			return

		// *Actually* remove the effects after our grace period expires.
		// Keep in mind since we call updates `on_move` this means you can technically stand still to keep the benefits.
		COOLDOWN_RESET(src, rust_grace_period)
		armor_type = /datum/armor/eldritch_armor/rust
		REMOVE_TRAIT(source, TRAIT_PIERCEIMMUNE, REF(src))
		rusted = FALSE
		update_rust()

/// Updates the icon of our overlay and applies the animation
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/update_rust()
	// Animation + Update the overlay sprite on our armor
	if(rusted)
		rust_overlay.icon_state = "[worn_icon_state]" + "_overlay"
		flick("[worn_icon_state]"+"_on", rust_overlay)
	else
		rust_overlay.icon_state = null
		flick("[worn_icon_state]"+"_off", rust_overlay)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/worn_overlays(mutable_appearance/standing, isinhands)
	. = ..()
	// Should basically catch toggling the hood on/off while standing on rust
	if(rusted)
		rust_overlay.icon_state = "[worn_icon_state]" + "_overlay"
	else
		rust_overlay.icon_state = null
	. += rust_appearance

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust
	name = "\improper Salvaged Remains"
	desc = "Touching the folds of this plain robe seem to fill you with unease. \
			Even looking fills you with a sense of vertigo. \
			Some pulse threatening to pull you within."
	icon_state = "rust_armor"
	armor_type = /datum/armor/eldritch_armor/rust

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust/equipped(mob/living/user, slot)
	. = ..()
	if(!(slot_flags & slot))
		UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED))
		return
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/*
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Checks if our armor values should be increased on the new turf
 */
/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/turf/mover_turf = get_turf(source)
	if(HAS_TRAIT(mover_turf, TRAIT_RUSTY))
		armor_type = /datum/armor/eldritch_armor/rust/on_rust
	else
		armor_type = initial(armor_type)

/datum/armor/eldritch_armor/rust
	melee = 30
	bullet = 30
	laser = 30
	energy = 30
	bomb = 50
	bio = 30
	fire = 0
	acid = 0
	wound = 30

/datum/armor/eldritch_armor/rust/on_rust
	melee = 60
	bullet = 60
	laser = 60
	energy = 60
	bomb = 100
	bio = 60
	fire = 0
	acid = 0
	wound = 60

// Void
/obj/item/clothing/suit/hooded/cultrobes/eldritch/void
	name = "\improper Hollow Weave"
	desc = "At first, the empty canvas of this robe seems to shimmer with a faint, cold light. \
			Yet upon tracking the shape of the folds more carefully, it is better to describe it as the absence of such a thing."
	icon_state = "void_armor"
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/void
	armor_type = /datum/armor/eldritch_armor/void
	/// Cooldown before we can go back into stealth
	COOLDOWN_DECLARE(stealth_cooldown)
	/// Timer before our stealth runs out
	var/stealth_timer

/obj/item/clothing/suit/hooded/cultrobes/eldritch/void/equipped(mob/living/user, slot)
	. = ..()
	if((slot_flags & slot) || !timeleft(stealth_timer))
		return
	deltimer(stealth_timer)
	end_stealth(user)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/void/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type, damage_type)
	. = ..()
	if(!COOLDOWN_FINISHED(src, stealth_cooldown))
		return
	COOLDOWN_START(src, stealth_cooldown, 20 SECONDS)
	stealth_timer = addtimer(CALLBACK(src, PROC_REF(end_stealth), owner), 5 SECONDS, TIMER_STOPPABLE)
	owner.alpha = 0
	return TRUE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/void/proc/end_stealth(mob/living/carbon/human/owner)
	animate(owner, time = 1 SECONDS, alpha = initial(owner.alpha))

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/void
	name = "\improper Hollow Weave"
	desc = "At first, the empty canvas of this robe seems to shimmer with a faint, cold light. \
			Yet upon tracking the shape of the folds more carefully, it is better to describe it as the absence of such a thing."
	icon_state = "void_armor"
	armor_type = /datum/armor/eldritch_armor/void

/datum/armor/eldritch_armor/void
	melee = 40
	bullet = 40
	laser = 50
	energy = 50
	bomb = 40
	bio = 40
	fire = 40
	acid = 40
	wound = 40

// Void cloak. Turns invisible with the hood up, lets you hide stuff.
/obj/item/clothing/head/hooded/cult_hoodie/void
	name = "void hood"
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	desc = "Black like tar, reflecting no light. Runic symbols line the outside. \
		With each flash you lose comprehension of what you are seeing."
	icon_state = "void_cloak"
	flags_inv = NONE
	flags_cover = NONE
	armor_type = /datum/armor/cult_hoodie_void

/datum/armor/cult_hoodie_void
	melee = 30
	bullet = 30
	laser = 30
	energy = 30
	bomb = 15
	wound = 10

/obj/item/clothing/head/hooded/cult_hoodie/void/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_NO_STRIP, TRAIT_EXAMINE_SKIP), INNATE_TRAIT)

/obj/item/clothing/suit/hooded/cultrobes/void
	name = "void cloak"
	desc = "Black like tar, reflecting no light. Runic symbols line the outside. \
		With each flash you lose comprehension of what you are seeing."
	icon_state = "void_cloak"
	inhand_icon_state = null
	allowed = list(/obj/item/melee/sickly_blade)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/void
	flags_inv = NONE
	body_parts_covered = CHEST|GROIN|ARMS
	// slightly worse than normal cult robes
	armor_type = /datum/armor/cultrobes_void
	alternative_mode = TRUE
	/// Whether the hood is flipped up
	var/hood_up = FALSE

/datum/armor/cultrobes_void
	melee = 30
	bullet = 30
	laser = 30
	energy = 30
	bomb = 15
	wound = 10

/obj/item/clothing/suit/hooded/cultrobes/void/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/void_cloak)
	make_visible()
	ADD_TRAIT(src, TRAIT_CONTRABAND_BLOCKER, INNATE_TRAIT)

/obj/item/clothing/suit/hooded/cultrobes/void/on_hood_up(obj/item/clothing/head/hooded/hood)
	hood_up = TRUE

/obj/item/clothing/suit/hooded/cultrobes/void/on_hood_down(obj/item/clothing/head/hooded/hood)
	hood_up = FALSE

/obj/item/clothing/suit/hooded/cultrobes/void/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_OCLOTHING)
		RegisterSignal(user, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(hide_item))
		RegisterSignal(user, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(show_item))

/obj/item/clothing/suit/hooded/cultrobes/void/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, list(COMSIG_MOB_UNEQUIPPED_ITEM, COMSIG_MOB_EQUIPPED_ITEM))

/obj/item/clothing/suit/hooded/cultrobes/void/proc/hide_item(datum/source, obj/item/item, slot)
	SIGNAL_HANDLER
	if(slot & ITEM_SLOT_SUITSTORE)
		item.add_traits(list(TRAIT_NO_STRIP, TRAIT_NO_WORN_ICON, TRAIT_EXAMINE_SKIP), REF(src))

/obj/item/clothing/suit/hooded/cultrobes/void/proc/show_item(datum/source, obj/item/item, slot)
	SIGNAL_HANDLER
	item.remove_traits(list(TRAIT_NO_STRIP, TRAIT_NO_WORN_ICON, TRAIT_EXAMINE_SKIP), REF(src))

/obj/item/clothing/suit/hooded/cultrobes/void/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user) || !hood_up)
		return

	// Let examiners know this works as a focus only if the hood is down
	. += span_notice("Allows you to cast heretic spells while the hood is down.")
	. += span_notice("Is space worthy as long as the hood is down.")

/obj/item/clothing/suit/hooded/cultrobes/void/on_hood_down(obj/item/clothing/head/hooded/hood)
	make_visible()
	return ..()

/obj/item/clothing/suit/hooded/cultrobes/void/can_create_hood()
	if(!isliving(loc))
		CRASH("[src] attempted to make a hood on a non-living thing: [loc]")
	var/mob/living/wearer = loc
	if(IS_HERETIC_OR_MONSTER(wearer))
		return TRUE

	loc.balloon_alert(loc, "can't get the hood up!")
	return FALSE

/obj/item/clothing/suit/hooded/cultrobes/void/on_hood_created(obj/item/clothing/head/hooded/hood)
	. = ..()
	make_invisible()

/// Makes our cloak "invisible". Not the wearer, the cloak itself.
/obj/item/clothing/suit/hooded/cultrobes/void/proc/make_invisible()
	add_traits(list(TRAIT_NO_STRIP, TRAIT_EXAMINE_SKIP), REF(src))
	RemoveElement(/datum/element/heretic_focus)

	if(isliving(loc))
		loc.remove_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD), REF(src))
		REMOVE_TRAIT(loc, TRAIT_RESISTLOWPRESSURE, REF(src))
		loc.balloon_alert(loc, "cloak hidden")
		loc.visible_message(span_notice("Light shifts around [loc], making the cloak around them invisible!"))

/// Makes our cloak "visible" again.
/obj/item/clothing/suit/hooded/cultrobes/void/proc/make_visible()
	remove_traits(list(TRAIT_NO_STRIP, TRAIT_EXAMINE_SKIP), REF(src))
	AddElement(/datum/element/heretic_focus)

	if(isliving(loc))
		loc.add_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD), REF(src))
		loc.balloon_alert(loc, "cloak revealed")
		loc.visible_message(span_notice("A kaleidoscope of colours collapses around [loc], a cloak appearing suddenly around their person!"))
