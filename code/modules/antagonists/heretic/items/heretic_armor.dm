/*!
 * Contains the eldritch robes for heretics, a suit of armor that they can make via a ritual
 */

// Eldritch armor. Looks cool, hood lets you cast heretic spells.
/obj/item/clothing/suit/hooded/cultrobes/eldritch
	name = "ominous armor"
	desc = "A ragged, dusty set of robes. Strange eyes line the inside."
	icon_state = "armor"
	inhand_icon_state = null
	flags_inv = HIDESHOES | HIDEJUMPSUIT | HIDEBELT
	body_parts_covered = CHEST | GROIN | LEGS | FEET | ARMS
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	clothing_flags = THICKMATERIAL | PLASMAMAN_PREVENT_IGNITION
	transparent_protection = HIDEGLOVES | HIDESUITSTORAGE | HIDEJUMPSUIT | HIDESHOES | HIDENECK
	cold_protection = FULL_BODY
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/gun/ballistic/rifle/lionhunter)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch
	armor_type = /datum/armor/eldritch_armor
	clothing_traits = list(TRAIT_HERETIC_AURA_HIDDEN)
	/// Whether the hood is flipped up
	var/hood_up = FALSE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/equipped(mob/user, slot, initial)
	. = ..()
	if(!(slot_flags & slot))
		return
	if(!IS_HERETIC(user))
		robes_side_effect(user)
		return
	// Heretic equipped the robes? Grant them the effects
	on_robes_gained(user)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/dropped(mob/living/user)
	. = ..()
	on_robes_lost(user)

/// Adds effects to the user when they equip their robes
/obj/item/clothing/suit/hooded/cultrobes/eldritch/proc/on_robes_gained(mob/living/user)
	return

/// Removes any effects that our robes have, returns `TRUE` if the item dropped was not robes
/obj/item/clothing/suit/hooded/cultrobes/eldritch/proc/on_robes_lost(mob/living/user)
	return

/// Applies a punishment to the user when the robes are equipped
/obj/item/clothing/suit/hooded/cultrobes/eldritch/proc/robes_side_effect(mob/living/user)
	SHOULD_NOT_SLEEP(TRUE) // sleep here would fuck over the timing

/obj/item/clothing/suit/hooded/cultrobes/eldritch/proc/is_equipped(mob/wearer)
	return wearer.get_slot_by_item(src) & slot_flags

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
	icon_state = "helmet"
	desc = "A torn, dust-caked hood. Strange eyes line the inside."
	flags_inv = HIDEMASK | HIDEEARS | HIDEEYES | HIDEFACE | HIDEHAIR | HIDEFACIALHAIR | HIDESNOUT
	flags_cover = HEADCOVERSEYES | PEPPERPROOF
	flash_protect = FLASH_PROTECTION_WELDER_HYPER_SENSITIVE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	clothing_flags = THICKMATERIAL | PLASMAMAN_PREVENT_IGNITION | SNUG_FIT
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
// Prevents fire from decaying while worn, also passively generates fire via the toggle
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

/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/on_robes_gained(mob/living/user)
	if(!isliving(user))
		return
	var/mob/living/wearer = user
	wearer.fire_stack_decay_rate = 0

/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/on_robes_lost(mob/living/user)
	if(!isliving(user))
		return
	var/mob/living/wearer = user
	wearer.fire_stack_decay_rate = initial(wearer.fire_stack_decay_rate)
	if(flame_generation)
		toggle_flames(wearer)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/robes_side_effect(mob/living/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/victim = user
	var/iteration = 0
	for(var/obj/item/bodypart/limb as anything in victim.bodyparts)
		if(istype(limb, /obj/item/bodypart/head) || istype(limb, /obj/item/bodypart/chest))
			continue
		iteration++
		addtimer(CALLBACK(src, PROC_REF(burn_limbs), limb), 1 SECONDS * iteration)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/proc/burn_limbs(obj/item/bodypart/limb)
	if(QDELETED(limb) || !limb.owner || !is_equipped(limb.owner))
		return
	limb.dismember(BURN)

/datum/action/item_action/toggle/flames
	button_icon = 'icons/effects/magic.dmi'
	button_icon_state = "fireball"

/datum/action/item_action/toggle/flames/do_effect(trigger_flags)
	var/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/item_target = target
	if(!item_target || !istype(item_target))
		return FALSE
	item_target.toggle_flames(owner)

/// Starts/Stops the passive generation of fire stacks on our wearer
/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/proc/toggle_flames(mob/living/user)
	flame_generation = !flame_generation

	if(flame_generation)
		START_PROCESSING(SSobj, src)
	else
		user.extinguish()
		STOP_PROCESSING(SSobj, src)

	user.balloon_alert(user, flame_generation ? "enabled" : "disabled")
	user.fire_stack_decay_rate = flame_generation ? 0 : initial(user.fire_stack_decay_rate)
	// Extinguishes the wearer after they disable the flames

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
	laser = 50
	energy = 50
	bomb = 100
	bio = 20
	fire = 100
	acid = 20
	wound = 20

// Blade
// Is shock-proof and gives you baton resistance
/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade
	name = "\improper Shattered Panoply"
	desc = "The sharpened edges of this ancient suit of armor assert a revelation known to aspirants of battle; \
			a true warrior can not be distinguished from the blade they wield."
	icon_state = "blade_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/blade
	armor_type = /datum/armor/eldritch_armor/blade
	siemens_coefficient = 0
	var/murdering_with_blades = FALSE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/on_robes_gained(mob/living/user)
	. = ..()
	user.add_traits(list(TRAIT_SHOCKIMMUNE, TRAIT_BATON_RESISTANCE), REF(src))

/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/on_robes_lost(mob/user, obj/item/clothing/suit/hooded/cultrobes/eldritch/robes)
	. = ..()
	if(.)
		return
	user.remove_traits(list(TRAIT_SHOCKIMMUNE, TRAIT_BATON_RESISTANCE), REF(src))

/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/robes_side_effect(mob/living/user)
	INVOKE_ASYNC(src, PROC_REF(start_throwing_blades), user)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/proc/start_throwing_blades(mob/living/target)
	if(murdering_with_blades)
		return
	murdering_with_blades = TRUE

	var/delay = 2 SECONDS
	var/knives = 100
	for(var/knife in 1 to knives)
		if(!should_keep_cutting(target))
			break
		addtimer(CALLBACK(src, PROC_REF(cut_em_good), target), delay * knife)
		delay = max(0.5 SECONDS, delay - 0.1 SECONDS)

	murdering_with_blades = FALSE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/proc/should_keep_cutting(mob/living/target)
	if(target.stat == DEAD || !is_equipped(target))
		return FALSE
	return TRUE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/proc/cut_em_good(mob/living/target)
	if(!should_keep_cutting(target))
		return
	var/list/turf/valid_turfs = get_blade_turfs(get_turf(target))
	if(!length(valid_turfs))
		var/mob/living/carbon/carbon_target = target
		if(iscarbon(target))
			var/obj/item/bodypart/limb = pick(carbon_target.bodyparts)
			limb.force_wound_upwards(/datum/wound/slash/flesh/severe)
		return
	throw_blade(pick(valid_turfs), target)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/proc/get_blade_turfs(mob/user)
	var/list/turfs_around_us = get_perimeter(user, 4)
	var/list/valid_turfs = list()
	for(var/turf/open/valid_turf in turfs_around_us)
		if(!valid_turf.is_blocked_turf() && get_angle(valid_turf, user) != 180)
			valid_turfs |= valid_turf
	return valid_turfs

/obj/item/knife/kitchen/magic
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "dio_knife"
	name = "magic knife"
	throwforce = 15
	// most importantly, this ignores shields
	armour_penetration = 200
	pass_flags = ALL

/obj/item/knife/kitchen/magic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/movetype_handler)
	add_traits(list(TRAIT_MOVE_PHASING, TRAIT_MOVE_FLOATING, TRAIT_UNCATCHABLE), INNATE_TRAIT)
	add_filter("dio_knife", 2, list("type" = "outline", "color" = "#ececff", "size" = 1))
	set_embed(/datum/embedding/magic_knife)

/obj/item/knife/kitchen/magic/get_demolition_modifier(obj/target)
	if(!ismob(target))
		return 100
	return ..()

/datum/embedding/magic_knife

	embed_chance = 150
	fall_chance = 0
	impact_pain_mult = 0
	ignore_throwspeed_threshold = TRUE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/proc/throw_blade(turf/target_turf, mob/user)
	var/obj/item/knife/kitchen/magic/knife = new(target_turf)
	knife.alpha = 0
	knife.throw_at()

	var/matrix/transform = matrix(knife.transform)
	var/angle = get_angle(target_turf, user)
	transform.Turn(angle)
	var/appear_delay = 0.5 SECONDS
	var/throw_delay = 1 SECONDS
	var/delete_delay = 10 SECONDS
	addtimer(CALLBACK(knife, TYPE_PROC_REF(/atom/movable, throw_at), user, 50, 5, null, FALSE), throw_delay)
	animate(knife, transform = transform, time = throw_delay, ANIMATION_PARALLEL)
	animate(knife, alpha = 255, time = appear_delay, ANIMATION_PARALLEL)
	animate(alpha = 0, time = delete_delay)
	QDEL_IN(knife, delete_delay + appear_delay + throw_delay)

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
	wound = 50

// Cosmic
// Allows you to toggle gravity for yourself at will
/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic
	name = "\improper Starwoven Cloak"
	desc = "Gleaming gems conjure forth wisps of power, turning about to illuminate the wearer in a dim radiance. \
			Gazing upon the robe, you cannot help but feel noticed."
	icon_state = "cosmic_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/cosmic
	armor_type = /datum/armor/eldritch_armor/cosmic
	clothing_flags = THICKMATERIAL | PLASMAMAN_PREVENT_IGNITION | STOPSPRESSUREDAMAGE
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	actions_types = list(/datum/action/item_action/toggle/gravity)
	/// If our robes are making us weightless
	var/weightless_enabled = FALSE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

// Removes your antigravity if you lose the robes
/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/on_robes_lost(mob/user, obj/item/clothing/suit/hooded/cultrobes/eldritch/robes)
	if(.)
		return
	if(weightless_enabled)
		toggle_gravity(user)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/robes_side_effect(mob/living/user)
	var/obj/item/organ/brain/victim_brain = user.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(!victim_brain)
		return

	victim_brain.gain_trauma(/datum/brain_trauma/magic/stalker/cosmic, TRAUMA_RESILIENCE_MAGIC)

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
	clothing_flags = THICKMATERIAL | PLASMAMAN_PREVENT_IGNITION | STOPSPRESSUREDAMAGE
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
// Emits a healing aura that affects any heretic summons (excluding the heretic himself)
/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh
	name = "Writhing Embrace"
	desc = "A rotten carcass, or perhaps several, twisted into fleshy polyps, knotted intestines and cracked bone. \
			How one 'wears' this baffles reasonable understanding. It moves when it believes itself unobserved."
	icon_state = "flesh_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/flesh
	armor_type = /datum/armor/eldritch_armor/flesh
	/// The aura healing component. Used to delete it when taken off.
	var/datum/component/healing_aura

/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh/on_robes_gained(mob/living/user)
	healing_aura = user.AddComponent( \
		/datum/component/aura_healing, \
		range = 15, \
		brute_heal = 3, \
		burn_heal = 3, \
		blood_heal = 3, \
		suffocation_heal = 3, \
		stamina_heal = 15, \
		simple_heal = 3, \
		requires_visibility = FALSE, \
		limit_to_trait = TRAIT_HERETIC_SUMMON, \
		healing_color = COLOR_RED, \
		self_heal = FALSE, \
	)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh/on_robes_lost(mob/user, obj/item/clothing/suit/hooded/cultrobes/eldritch/robes)
	QDEL_NULL(healing_aura)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh/robes_side_effect(mob/living/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/victim = user
	var/iteration = 0
	for(var/obj/item/bodypart/limb as anything in victim.bodyparts)
		iteration++
		addtimer(CALLBACK(limb, TYPE_PROC_REF(/obj/item/bodypart, force_wound_upwards), /datum/wound/slash/flesh/critical), 1 SECONDS * iteration)

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/flesh
	icon_state = "flesh_armor"
	armor_type = /datum/armor/eldritch_armor/flesh
	clothing_traits = list(TRAIT_MEDICAL_HUD)

/datum/armor/eldritch_armor/flesh
	melee = 70
	bullet = 40
	laser = 30
	energy = 30
	bomb = 35
	bio = 100
	fire = 0
	acid = 100
	wound = 20

// Lock
// Gives you digital camo, silences your footsteps and makes you un-examineable
/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock
	name = "Shifting Guise"
	icon_state = "lock_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/lock
	armor_type = /datum/armor/eldritch_armor/lock
	flags_inv = parent_type::flags_inv | HIDEMUTWINGS

/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock/on_robes_gained(mob/living/user)
	user.AddElement(/datum/element/digitalcamo)
	user.add_traits(list(TRAIT_SILENT_FOOTSTEPS, TRAIT_UNKNOWN_APPEARANCE, TRAIT_UNKNOWN_VOICE), REF(src))

/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock/on_robes_lost(mob/user, obj/item/clothing/suit/hooded/cultrobes/eldritch/robes)
	user.RemoveElement(/datum/element/digitalcamo)
	user.remove_traits(list(TRAIT_SILENT_FOOTSTEPS, TRAIT_UNKNOWN_APPEARANCE, TRAIT_UNKNOWN_VOICE), REF(src))

/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock/robes_side_effect(mob/living/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/victim = user
	var/list/things = victim.get_equipped_items(ALL)
	var/turf/our_turf = get_turf(victim)
	var/list/turf/nearby_turfs = RANGE_TURFS(5, our_turf) - our_turf
	for(var/obj/item/to_throw in things)
		if(user.dropItemToGround(to_throw))
			to_throw.safe_throw_at(pick(nearby_turfs), 2, 1, spin = TRUE)

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
// Converts all damage into brain damage, nullifying the attack in the process
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon
	name = "\improper Resplendant Regalia"
	desc = "The confounding nature of this opulent garb turns and twists the sight. \
			The viewer must come to a chilling revelation; \
			what they see is as true as any other face."
	icon_state = "moon_armor"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/moon
	armor_type = /datum/armor/eldritch_armor/moon
	flags_inv = HIDESHOES | HIDEJUMPSUIT | HIDEMUTWINGS
	clothing_traits = list(
		TRAIT_HERETIC_AURA_HIDDEN,
		TRAIT_BATON_RESISTANCE,
		TRAIT_STUNIMMUNE,
		TRAIT_NEVER_WOUNDED,
		TRAIT_PACIFISM,
		TRAIT_NOHUNGER
	)
	/// Hud that gets shown to the wearer, gives a rough estimate of their current brain damage
	var/atom/movable/screen/moon_health/health_hud
	/// Boolean if you are brain dead so the sound doesn't spam during the delay
	var/braindead = FALSE
	//---- Messages that get sent when someone wearing the moon robes is attacked
	/// Visible message that nearby people see
	var/static/list/visible_message_list = list(
		"%USER seems to hardly register that they have been harmed by %ATTACKER, not even flinching naturally.",
		"Though wounded, %USER seems oblivious to %ATTACKER.",
		"You hear %USER laughing. But they have not made a single sound, even when struck by %ATTACKER.",
	)
	/// Message sent to the wearer who got attacked
	var/static/list/self_message_list = list(
		"Your body ripples as still water freshly disturbed. The sensation is exquisite, and you have %ATTACKER to thank.",
		"A bell tolls. %ATTACKER has struck the hour and you tick to that tune.",
		//"You are needed in [area name]. You need to be there. %ATTACKER might want you to stay, but you are needed in [area name].",
		//"You see %ATTACKER strike a [name of animal]. The face of the beast is a mirror of your own. How strange.",
		"%ATTACKER bumps you and you spill your tea. It's fine. You've plenty of cups.",
		"You hear a roaring crash. The waves hit the boat. The sea is vast and dark. You see %ATTACKER striking the water, cursing its master.",
		"Sequins scatter into the air around %ATTACKER. The sequins...",
		"You notice that a button has popped off your collar. How did that happen? Maybe %ATTACKER is to blame.",
		"%ATTACKER isn't very funny, and you're struggling to see the punchline.",
	)
	/// Message sent to blind people nearby
	var/static/list/blind_message_list = list(
		"You hear echoing laughter.",
		"You hear a distance chorus.",
		"You hear the sound of bells and whistles.",
		"You hear the clack of a tambourine.",
	)
	/// List of all signals registered, used for cleanup
	var/signal_registered = list()
	/// damage modifier to all incoming damage, which is also converted to brain damage
	var/damage_modifier = 1.15

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/equipped(mob/user, slot, initial)
	. = ..()
	if(!ishuman(user) || !(slot_flags & slot))
		return
	var/mob/living/carbon/human/human_user = user
	// Gives the hud to the wearer, if there's no hud, register the signal to be given on creation
	if(human_user.hud_used)
		on_hud_created(human_user)
	else
		RegisterSignal(human_user, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))
		signal_registered += COMSIG_MOB_HUD_CREATED

	human_user.add_movespeed_mod_immunities(REF(src), /datum/movespeed_modifier/equipment_speedmod)
	RegisterSignal(human_user, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(on_apply_modifiers))
	signal_registered += COMSIG_MOB_APPLY_DAMAGE_MODIFIERS

	// adjust ignores damage modifiers so we listen to them separately
	var/list/damage_adjust_signals = list(
		COMSIG_LIVING_ADJUST_BRUTE_DAMAGE,
		COMSIG_LIVING_ADJUST_BURN_DAMAGE,
		COMSIG_LIVING_ADJUST_OXY_DAMAGE,
		COMSIG_LIVING_ADJUST_TOX_DAMAGE,
		COMSIG_LIVING_ADJUST_STAMINA_DAMAGE
	)

	RegisterSignals(human_user, damage_adjust_signals, PROC_REF(adjust_damage))
	signal_registered += damage_adjust_signals

	RegisterSignal(human_user, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	signal_registered += COMSIG_LIVING_DEATH

	RegisterSignal(human_user, COMSIG_SEND_ITEM_ATTACK_MESSAGE_CARBON, PROC_REF(item_attack_response))
	signal_registered += COMSIG_SEND_ITEM_ATTACK_MESSAGE_CARBON

	var/obj/item/organ/brain/our_brain = human_user.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(!our_brain)
		return
	ADD_TRAIT(our_brain, TRAIT_BRAIN_DAMAGE_NODEATH, REF(src))
	START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/dropped(mob/living/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/wearer = user
	UnregisterSignal(wearer, signal_registered)
	signal_registered = list()

	wearer.remove_movespeed_mod_immunities(REF(src), /datum/movespeed_modifier/equipment_speedmod)
	var/obj/item/organ/brain/our_brain = wearer.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(our_brain)
		REMOVE_TRAIT(our_brain, TRAIT_BRAIN_DAMAGE_NODEATH, REF(src))
	braindead = FALSE
	if(health_hud in user.hud_used.infodisplay)
		on_hud_remove(user)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/on_apply_modifiers(mob/living/user, damage_mods, damage, damagetype, def_zone, sharpness, attack_direction, attacking_item)
	SIGNAL_HANDLER
	if(braindead)
		return
	damage_mods += 0
	handle_damage(user, damage)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/adjust_damage(mob/living/user, type, amount, forced)
	SIGNAL_HANDLER
	handle_damage(user, amount)
	return COMPONENT_IGNORE_CHANGE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/handle_damage(mob/living/user, damage)
	user.adjust_organ_loss(ORGAN_SLOT_BRAIN, damage * damage_modifier)
	check_braindeath(user)

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
	signal_registered -= COMSIG_MOB_HUD_CREATED

/// Removes the HUD element from the wearer
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/on_hud_remove(mob/living/carbon/human/wearer)
	var/datum/hud/original_hud = wearer.hud_used
	original_hud.infodisplay -= health_hud
	QDEL_NULL(health_hud)
	// Restore the old health elements
	var/atom/movable/screen/stamina/stamina_hud = new(null, original_hud)
	var/atom/movable/screen/healths/old_health_hud = new(null, original_hud)
	var/atom/movable/screen/healthdoll/human/health_doll_hud = new(null, original_hud)
	original_hud.infodisplay += stamina_hud
	original_hud.infodisplay += old_health_hud
	original_hud.infodisplay += health_doll_hud
	wearer.mob_mood.modify_hud()
	original_hud.show_hud(original_hud.hud_version)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/can_mob_unequip(mob/user)
	if(!ishuman(user))
		return ..()
	var/mob/living/carbon/human/wearer = user
	if(wearer.get_organ_loss(ORGAN_SLOT_BRAIN) > 0)
		wearer.balloon_alert(user, "can't strip, brain damaged!")
		return FALSE
	return ..()

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/item_attack_response(mob/living/victim, obj/item/weapon, mob/living/attacker)
	SIGNAL_HANDLER
	var/visible_message = pick(visible_message_list)
	visible_message = replacetext(visible_message, "%USER", victim.get_visible_name())
	visible_message = replacetext(visible_message, "%ATTACKER", attacker.get_visible_name())

	var/self_message = pick(self_message_list)
	self_message = replacetext(self_message_list, "%ATTACKER", attacker.get_visible_name())

	var/blind_message = pick(blind_message_list)
	victim.visible_message(span_danger(visible_message), span_userdanger(self_message), span_danger(blind_message))
	return SIGNAL_MESSAGE_MODIFIED

/// Once you reach this point you're completely brain dead, so lets play our effects before you eat shit
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/kill_wearer(mob/living/carbon/human/wearer)
	if(IS_HERETIC(wearer))
		var/datum/action/cooldown/spell/aoe/moon_ringleader/temp_spell = new(wearer)
		temp_spell.cast(wearer)
		qdel(temp_spell)
	var/obj/item/organ/brain/our_brain = wearer.get_organ_slot(ORGAN_SLOT_BRAIN)
	REMOVE_TRAIT(our_brain, TRAIT_BRAIN_DAMAGE_NODEATH, REF(src))
	wearer.death()

/// Blows up your head when you die
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/on_death(mob/wearer)
	SIGNAL_HANDLER
	if(!ishuman(wearer))
		return
	var/mob/living/carbon/human/human_wearer = wearer
	var/obj/item/bodypart/head/to_explode = human_wearer.get_bodypart(BODY_ZONE_HEAD)
	if(!to_explode)
		return
	human_wearer.visible_message(span_warning("[human_wearer]'s head splatters with a sickening crunch!"), ignored_mobs = list(human_wearer))
	new /obj/effect/gibspawner/generic(get_turf(human_wearer), human_wearer)
	to_explode.dismember(dam_type = BRUTE, silent = TRUE)
	to_explode.drop_organs()
	qdel(to_explode)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/process(seconds_per_tick)
	var/mob/living/carbon/human/wearer = loc
	if(!istype(wearer) || wearer.wear_suit != src || wearer.stat == DEAD)
		return ..()
	if(!IS_HERETIC_OR_MONSTER(wearer))
		wearer.adjust_organ_loss(ORGAN_SLOT_BRAIN, 20)
	var/brain_damage = wearer.get_organ_loss(ORGAN_SLOT_BRAIN)
	var/emote_rng = 0
	var/list/emote_list = list()
	switch(brain_damage)
		if(0)
			emote_rng = 0
			emote_list = list()
		if(1 to 30)
			emote_rng = 20
			emote_list = list("laugh")
		if(31 to 60)
			emote_rng = 40
			emote_list = list("laugh", "smile")
		if(61 to 100)
			emote_rng = 60
			emote_list = list("laugh", "smile", "cough")
		if(101 to 150)
			emote_rng = 80
			emote_list = list("laugh", "smile", "cough", "gasp")
		if(151 to 200)
			emote_rng = 100
			emote_list = list("laugh", "smile", "cough", "gasp", "scream")
	if(!prob(emote_rng))
		return
	for(var/perform in emote_list)
		wearer.emote("[perform]")
	check_braindeath(wearer)

/// Checks if you are brain dead, starts the dying process once you've reached it
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/check_braindeath(mob/living/carbon/human/wearer)
	var/obj/item/organ/brain/our_brain = wearer.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(braindead || our_brain.damage < our_brain.maxHealth)
		return

	braindead = TRUE
	wearer.set_organ_loss(ORGAN_SLOT_BRAIN, INFINITY)
	playsound(wearer, 'sound/effects/pope_entry.ogg', 50)
	to_chat(wearer, span_bold(span_hypnophrase("A terrible fate has befallen you.")))
	addtimer(CALLBACK(src, PROC_REF(kill_wearer), wearer), 5 SECONDS)

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
	if(isnull(hud_owner) || !ishuman(hud_owner.mymob))
		return INITIALIZE_HINT_QDEL
	var/mob/living/carbon/human/wearer = hud_owner.mymob
	var/obj/item/organ/brain/our_brain = wearer.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(!our_brain)
		return INITIALIZE_HINT_QDEL
	update_health(our_brain)
	RegisterSignal(our_brain, COMSIG_ORGAN_ADJUST_DAMAGE, PROC_REF(update_health))

/// Changes the icon based on the brain health of the wearer
/atom/movable/screen/moon_health/proc/update_health(obj/item/organ/brain, damage_amount, maximum, required_organ_flag)
	SIGNAL_HANDLER
	if(!brain.owner || !ishuman(brain.owner))
		qdel(src)
		return
	var/mob/living/carbon/human/wearer = brain.owner
	if(istype(wearer.wear_suit, /obj/item/clothing/suit/hooded/cultrobes/eldritch/moon))
		var/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/robes = wearer.wear_suit
		if(robes.braindead)
			icon_state = base_icon_state + "_6"
			return // Don't update the icon once our "dying" process has begun
	switch(brain.damage)
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
// Gains more armor while standing on top of rust. Has an animated overlay
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
	/// Overlay for the armor object
	var/image/object_overlay
	/// Overlay for the hood object
	var/image/hood_object_overlay

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/Initialize(mapload)
	. = ..()
	overlay_id++
	if(!object_overlay)
		object_overlay = image(icon, icon_state = "rust_armor_overlay")
	if(!hood_object_overlay)
		hood_object_overlay = image('icons/obj/clothing/head/helmet.dmi', icon_state = "rust_armor_overlay")

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/on_robes_gained(mob/living/user)
	. = ..()
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	rust_overlay = new()
	rust_overlay.icon = 'icons/mob/clothing/suits/armor.dmi'
	rust_overlay.render_target = "*rust_overlay_[overlay_id]"
	rust_overlay.vis_flags |= VIS_INHERIT_DIR | VIS_INHERIT_LAYER | VIS_INHERIT_ID
	user.vis_contents += rust_overlay // Should be invisible, we just update the sprite as needed

	rust_appearance = new /mutable_appearance()
	rust_appearance.render_source = "*rust_overlay_[overlay_id]"
	update_appearance(UPDATE_ICON)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/on_robes_lost(mob/user, obj/item/clothing/suit/hooded/cultrobes/eldritch/robes)
	. = ..()
	if(.)
		return
	UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED))
	user.vis_contents -= rust_overlay
	rusted = FALSE
	set_armor(/datum/armor/eldritch_armor/rust)

	REMOVE_TRAIT(user, TRAIT_PIERCEIMMUNE, REF(src))
	cut_overlay(object_overlay)
	QDEL_NULL(rust_overlay)
	QDEL_NULL(rust_appearance)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/robes_side_effect(mob/living/user)
	. = ..()
	if(!iscarbon(user))
		return
	var/mob/living/carbon/victim = user
	var/list/organ_list = victim.organs
	if(!length(organ_list))
		return

	var/iteration = 0
	var/organs_to_puke = rand(1, 3)
	for(var/obj/item/organ/to_puke as anything in organ_list)
		if(iteration > organs_to_puke)
			break
		iteration++
		addtimer(CALLBACK(src, PROC_REF(vomit_your_guts_out), victim), 1 SECONDS * iteration)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/vomit_your_guts_out(mob/living/carbon/victim)
	if(QDELETED(victim) || !is_equipped(victim))
		return
	victim.vomit(MOB_VOMIT_BLOOD | MOB_VOMIT_MESSAGE | MOB_VOMIT_HARM | MOB_VOMIT_FORCE)
	victim.spew_organ(rand(4, 6))

/*
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Checks if our armor values should be increased on the new turf
 */
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/turf/mover_turf = get_turf(source)
	if(HAS_TRAIT(mover_turf, TRAIT_RUSTY))
		set_armor(/datum/armor/eldritch_armor/rust/on_rust)

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
		set_armor(/datum/armor/eldritch_armor/rust)
		REMOVE_TRAIT(source, TRAIT_PIERCEIMMUNE, REF(src))
		rusted = FALSE
		update_rust()

/// Updates the icon of our overlay and applies the animation
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/update_rust()
	// Animation + Update the overlay sprite on our armor
	if(!rusted)
		rust_overlay?.icon_state = null
		flick("[worn_icon_state]"+"_off", rust_overlay)
		cut_overlay(object_overlay)
		hood?.cut_overlay(hood_object_overlay)
		return
	rust_overlay?.icon_state = "[worn_icon_state]" + "_overlay"
	flick("[worn_icon_state]"+"_on", rust_overlay)
	add_overlay(object_overlay)
	hood?.add_overlay(hood_object_overlay)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/worn_overlays(mutable_appearance/standing, isinhands)
	. = ..()
	// Should basically catch toggling the hood on/off while standing on rust
	if(rusted)
		rust_overlay?.icon_state = "[worn_icon_state]" + "_overlay"
	else
		rust_overlay?.icon_state = null
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
		set_armor(/datum/armor/eldritch_armor/rust/on_rust)
	else
		set_armor(/datum/armor/eldritch_armor/rust)

/datum/armor/eldritch_armor/rust
	melee = 30
	bullet = 30
	laser = 30
	energy = 30
	bomb = 50
	bio = 30
	fire = 30
	acid = 30
	wound = 30

/datum/armor/eldritch_armor/rust/on_rust
	melee = 60
	bullet = 60
	laser = 60
	energy = 60
	bomb = 100
	bio = 60
	fire = 60
	acid = 60
	wound = 60

// Void
// Gives you a short stealth when you are hit
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

/obj/item/clothing/suit/hooded/cultrobes/eldritch/void/on_robes_lost(mob/user, obj/item/clothing/suit/hooded/cultrobes/eldritch/robes)
	. = ..()
	if(. || !timeleft(stealth_timer))
		return
	// Remove from stealth when you lose the robes
	deltimer(stealth_timer)
	end_stealth(user)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/void/robes_side_effect(mob/living/user)
	. = ..()
	user.adjust_bodytemperature(-INFINITY)
	ADD_TRAIT(user, TRAIT_HYPOTHERMIC, REF(src))
	if(!isliving(user))
		return
	var/mob/living/victim = user
	victim.apply_status_effect(/datum/status_effect/frozenstasis/irresistable)

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
