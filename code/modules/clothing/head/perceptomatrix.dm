
#define PERCEPTOMATRIX_INACTIVE_FLAGS SNUG_FIT|STACKABLE_HELMET_EXEMPT|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT
#define PERCEPTOMATRIX_ACTIVE_FLAGS PERCEPTOMATRIX_INACTIVE_FLAGS|CASTING_CLOTHES // we love casting spells

/// Helmet which can turn you into a BEAST!! once an anomaly core is inserted
/obj/item/clothing/head/helmet/perceptomatrix
	name = "perceptomatrix helm"
	desc = "This piece of headgear harnesses the energies of a hallucinatory anomaly to create a safe audiovisual replica of -all- external stimuli directly into the cerebral cortex, \
		granting the user effective immunity to both psychic threats, and anything that would affect their perception - be it ear, eye, or even brain damage. \
		It can also violently discharge said energy, inducing hallucinations in others."
	icon_state = "perceptomatrix_helmet_inactive"
	worn_icon_state = "perceptomatrix_helmet_inactive"
	base_icon_state = "perceptomatrix_helmet"
	force = 10
	dog_fashion = null
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	strip_delay = 8 SECONDS
	clothing_flags = PERCEPTOMATRIX_ACTIVE_FLAGS
	clothing_traits = list(
		/* eye/ear protection */
		TRAIT_NOFLASH,
		TRAIT_TRUE_NIGHT_VISION,
		TRAIT_SIGHT_BYPASS,
		TRAIT_EXPANDED_FOV,
		TRAIT_GOOD_HEARING,
		/* mental protection */
		TRAIT_PERCEPTUAL_TRAUMA_BYPASS,
		TRAIT_RDS_SUPPRESSED,
		TRAIT_MADNESS_IMMUNE,
		TRAIT_HALLUCINATION_IMMUNE,
		/* psychic protection */
		TRAIT_NO_MINDSWAP,
		TRAIT_UNCONVERTABLE,
	)
	flags_cover = HEADCOVERSEYES|EARS_COVERED
	flags_inv = HIDEHAIR|HIDEFACE
	flash_protect = FLASH_PROTECTION_WELDER_SENSITIVE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	equip_sound = 'sound/items/handling/helmet/helmet_equip1.ogg'
	pickup_sound = 'sound/items/handling/helmet/helmet_pickup1.ogg'
	drop_sound = 'sound/items/handling/helmet/helmet_drop1.ogg'
	armor_type = /datum/armor/head_helmet_matrix
	actions_types = list(/datum/action/cooldown/spell/pointed/percept_hallucination)

	/// If we have a core or not
	var/core_installed = FALSE
	/// Active components to add onto the mob, deleted and created on core installation/removal
	var/list/active_components = list()

// weaker overall but better against energy
/datum/armor/head_helmet_matrix
	melee = 15
	bullet = 15
	laser = 45
	energy = 60
	bomb = 15
	fire = 50
	acid = 50
	wound = 10

/obj/item/clothing/head/helmet/perceptomatrix/Initialize(mapload)
	. = ..()

	update_appearance(UPDATE_ICON_STATE)
	update_anomaly_state()
	AddComponent(/datum/component/adjust_fishing_difficulty, -7) // PSYCHIC FISHING
	AddComponent(/datum/component/hat_stabilizer, loose_hat = TRUE)

/obj/item/clothing/head/helmet/perceptomatrix/equipped(mob/living/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_HEAD)
		RegisterSignal(user, COMSIG_MOB_BEFORE_SPELL_CAST, PROC_REF(pre_cast_core_check))

/obj/item/clothing/head/helmet/perceptomatrix/dropped(mob/living/user, silent)
	UnregisterSignal(user, COMSIG_MOB_BEFORE_SPELL_CAST)
	..()

// Prevent casting the spell w/o the core.
/obj/item/clothing/head/helmet/perceptomatrix/proc/pre_cast_core_check(mob/caster, datum/action/cooldown/spell/spell)
	SIGNAL_HANDLER
	if((!core_installed) && spell.school == SCHOOL_PSYCHIC)
		to_chat(caster, span_warning("You can't zap minds through [src]'s shielding without a core installed!"))
		return SPELL_CANCEL_CAST

/obj/item/clothing/head/helmet/perceptomatrix/proc/update_anomaly_state()

	// If the core isn't installed, or it's temporarily deactivated, disable special functions.
	if(!core_installed)
		clothing_flags = PERCEPTOMATRIX_INACTIVE_FLAGS
		detach_clothing_traits(clothing_traits)
		QDEL_LIST(active_components)
		RemoveElement(/datum/element/wearable_client_colour, /datum/client_colour/perceptomatrix, ITEM_SLOT_HEAD, forced = TRUE)
		return

	clothing_flags = PERCEPTOMATRIX_ACTIVE_FLAGS
	attach_clothing_traits(initial(clothing_traits))

	// When someone makes TRAIT_DEAF an element, or status effect, or whatever, give this item a way to bypass said deafness.
	// just blocking future instances of deafness isn't what the item is meant to do but there's no proper way to do it otherwise at the moment.
	active_components += AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_HEAD), reduce_amount = 2) // should be same as highest value
	active_components += AddComponent(
		/datum/component/anti_magic, \
		antimagic_flags = MAGIC_RESISTANCE_MIND, \
		inventory_flags = ITEM_SLOT_HEAD, \
	)
	AddElement(/datum/element/wearable_client_colour, /datum/client_colour/perceptomatrix, ITEM_SLOT_HEAD, forced = TRUE)

	update_icon_state()

/obj/item/clothing/head/helmet/perceptomatrix/Destroy(force)
	QDEL_LIST(active_components)
	return ..()

/obj/item/clothing/head/helmet/perceptomatrix/examine(mob/user)
	. = ..()
	if (!core_installed)
		. += span_warning("It requires a hallucination anomaly core in order to function.")

/obj/item/clothing/head/helmet/perceptomatrix/item_action_slot_check(slot, mob/user, datum/action/action)
	return slot & ITEM_SLOT_HEAD

/obj/item/clothing/head/helmet/perceptomatrix/update_icon_state()
	icon_state = base_icon_state + (core_installed ? "" : "_inactive")
	worn_icon_state = base_icon_state + (core_installed ? "" : "_inactive")
	return ..()

/obj/item/clothing/head/helmet/perceptomatrix/item_interaction(mob/user, obj/item/weapon, params)
	if (!istype(weapon, /obj/item/assembly/signaler/anomaly/hallucination))
		return NONE
	balloon_alert(user, "inserting...")
	if (!do_after(user, delay = 3 SECONDS, target = src))
		return ITEM_INTERACT_BLOCKING
	qdel(weapon)
	core_installed = TRUE
	update_anomaly_state()
	update_appearance(UPDATE_ICON_STATE)
	playsound(src, 'sound/machines/crate/crate_open.ogg', 50, FALSE)
	return ITEM_INTERACT_SUCCESS

/obj/item/clothing/head/helmet/perceptomatrix/functioning
	core_installed = TRUE

/datum/action/cooldown/spell/pointed/percept_hallucination
	name = "Hallucinate"
	desc = "Redirect perceptual energies towards a target, staggering them."
	button_icon_state = "blind"
	ranged_mousepointer = 'icons/effects/mouse_pointers/blind_target.dmi'

	sound = 'sound/items/weapons/emitter2.ogg'
	school = SCHOOL_PSYCHIC
	cooldown_time = 15 SECONDS

	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE_MIND

	active_msg = "You prepare to zap a target with hallucinations..."

	/// The amount of blurriness to apply
	var/eye_blur_duration = 7 SECONDS
	/// The amount of stagger to apply
	var/stagger_duration = 3 SECONDS
	/// The amount of hallucination to apply
	var/hallucination_duration = 25 SECONDS
	/// Spark system
	var/datum/effect_system/spark_spread/quantum/spark_sys

/datum/action/cooldown/spell/pointed/percept_hallucination/New(Target)
	. = ..()

	spark_sys = new /datum/effect_system/spark_spread/quantum

/datum/action/cooldown/spell/pointed/percept_hallucination/Destroy()
	QDEL_NULL(spark_sys)
	return ..()

/datum/action/cooldown/spell/pointed/percept_hallucination/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(ishuman(cast_on))
		return TRUE
	if(istype(cast_on, /obj/item/food/pancakes))
		return TRUE

	return FALSE

/datum/action/cooldown/spell/pointed/percept_hallucination/proc/blows_up_pancakes_with_mind(obj/item/food/pancakes/pancakes)

	owner.visible_message(
		span_userdanger("[owner] blows up [pancakes] with [owner.p_their()] mind!"),
		span_userdanger("You blow up [pancakes] with your mind!")
	)

	for(var/mob/chef in get_hearers_in_view(7, pancakes))
		if(!chef.mind)
			continue
		// if cooked by chef, or if EITHER 5% chance OR its april fools. a || (b || c)
		if(HAS_TRAIT_FROM(pancakes, TRAIT_FOOD_CHEF_MADE, REF(chef.mind)) || (prob(5) || check_holidays(APRIL_FOOLS)))
			chef.say("Ma fuckin' pancakes!")

	playsound(pancakes, 'sound/effects/fuse.ogg', 80)
	animate(pancakes, time = 1, pixel_z = 12, easing = ELASTIC_EASING)
	animate(time = 1, pixel_z = 0, easing = BOUNCE_EASING)
	for(var/i in 1 to 15)
		animate(color = (i % 2) ? "#ffffff": "#ff6739", time = 1, easing = QUAD_EASING, flags = ANIMATION_CONTINUE)

	addtimer(CALLBACK(src, PROC_REF(pancake_explosion), pancakes), 1.5 SECONDS)

/datum/action/cooldown/spell/pointed/percept_hallucination/proc/pancake_explosion(obj/pancakes)
	explosion(pancakes, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 1, flame_range = 2)
	qdel(pancakes)
	StartCooldown()

/datum/action/cooldown/spell/pointed/percept_hallucination/proc/cast_fx(atom/cast_on)
	owner.Beam(cast_on, icon_state = "greyscale_lightning", beam_color = COLOR_FADED_PINK, time = 0.5 SECONDS)

	spark_sys.set_up(2, 1, get_turf(owner))
	spark_sys.start()
	spark_sys.set_up(4, 1, get_turf(cast_on))
	spark_sys.start()

/datum/action/cooldown/spell/pointed/percept_hallucination/cast(mob/living/carbon/human/cast_on)
	. = ..()

	cast_fx(cast_on)

	if(istype(cast_on, /obj/item/food/pancakes))
		blows_up_pancakes_with_mind(cast_on)
		return

	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("You feel psychic energies reflecting off you."))
		to_chat(owner, span_warning("[cast_on] deflects the energy!"))
		return

	to_chat(cast_on, span_warning("Your brain feels like it's on fire!"))
	cast_on.emote("scream")
	cast_on.set_eye_blur_if_lower(eye_blur_duration)
	cast_on.adjust_staggered(stagger_duration)
	cast_on.apply_status_effect(/datum/status_effect/hallucination, hallucination_duration, \
		hallucination_duration * 0.2, hallucination_duration) // lower/upper hallucination freq. bound

	return

#undef PERCEPTOMATRIX_INACTIVE_FLAGS
#undef PERCEPTOMATRIX_ACTIVE_FLAGS
