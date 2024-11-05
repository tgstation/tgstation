

/// Belt which can turn you into a beast, once an anomaly core is inserted
/obj/item/clothing/head/helmet/perceptomatrix
	name = "perceptomatrix helm"
	desc = "This piece of headgear harnesses the energies of a hallucinative anomaly to create a safe audiovisual replica of -all- external stimuli directly into the cerebral cortex, \
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
	clothing_flags = SNUG_FIT|STACKABLE_HELMET_EXEMPT|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT | CASTING_CLOTHES // we love casting spells
	clothing_traits = list(
		/* eye/ear protection */
		TRAIT_NOFLASH,
		TRAIT_TRUE_NIGHT_VISION,
		TRAIT_SIGHT_BYPASS,
		TRAIT_EXPANDED_FOV,
		TRAIT_GOOD_HEARING,
		/* mental protection */
		TRAIT_PERCEPTUAL_TRAUMA_BYPASS, //wip
		TRAIT_MADNESS_IMMUNE,
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

	/// Our current transformation action
	var/datum/action/cooldown/spell/shapeshift/polymorph_belt/transform_action
	/// If we have a core or not
	var/core_installed = FALSE
	/// if disabled by spellcasting.
	var/temporarily_deactivated = FALSE
	var/list/active_components

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

	update_icon_state()
	update_anomaly_state()

	// some-fucking-how, RemoveElement fails to find the element in below proc if i try to remove it. so whatever.
	AddElement(/datum/element/wearable_client_colour, /datum/client_colour/perceptomatrix, ITEM_SLOT_HEAD, forced = TRUE)

/obj/item/clothing/head/helmet/perceptomatrix/proc/update_anomaly_state(temporary_update)

	// If argument has value, set temp_deac to it.
	if(!isnull(temporary_update))
		temporarily_deactivated = temporary_update

	// If the core isn't installed, or it's temporarily deactivated, disable special functions.
	if(!core_installed || temporarily_deactivated)
		clothing_flags = initial(clothing_flags) & ~CASTING_CLOTHES
		detach_clothing_traits(clothing_traits)
		QDEL_LIST(active_components)
		return

	clothing_flags = initial(clothing_flags)
	attach_clothing_traits(initial(clothing_traits))

	LAZYADD(active_components, AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_HEAD)))
	LAZYADD(active_components, AddComponent(
		/datum/component/anti_magic, \
		antimagic_flags = MAGIC_RESISTANCE_MIND, \
		inventory_flags = ITEM_SLOT_HEAD, \
	))

	update_icon_state()

/obj/item/clothing/head/helmet/perceptomatrix/Destroy(force)
	QDEL_NULL(transform_action)
	QDEL_NULL(active_components)
	return ..()

/obj/item/clothing/head/helmet/perceptomatrix/examine(mob/user)
	. = ..()
	if (!active)
		. += span_warning("It requires a hallucination anomaly core in order to function.")

/obj/item/clothing/head/helmet/perceptomatrix/item_action_slot_check(slot, mob/user, datum/action/action)
	return slot & ITEM_SLOT_HEAD

/obj/item/clothing/head/helmet/perceptomatrix/update_icon_state()
	icon_state = base_icon_state + (active ? "" : "_inactive")
	worn_icon_state = base_icon_state + (active ? "" : "_inactive")
	return ..()

/obj/item/clothing/head/helmet/perceptomatrix/attackby(obj/item/weapon, mob/user, params)
	if (!istype(weapon, /obj/item/assembly/signaler/anomaly/hallucination))
		return ..()
	balloon_alert(user, "inserting...")
	if (!do_after(user, delay = 3 SECONDS, target = src))
		return
	qdel(weapon)
	update_anomaly_state(active_update = TRUE)
	update_appearance(UPDATE_ICON_STATE)
	playsound(src, 'sound/machines/crate/crate_open.ogg', 50, FALSE)

/// Pre-activated polymorph belt
/obj/item/clothing/head/helmet/perceptomatrix/functioning
	active = TRUE

/datum/action/cooldown/spell/pointed/percept_hallucination
	name = "Hallucinate"
	desc = "Redirect perceptual energies towards a target, staggering them. Temporarily disables the perceptomatrix helmet."
	button_icon_state = "blind"
	ranged_mousepointer = 'icons/effects/mouse_pointers/blind_target.dmi'

	sound = 'sound/items/weapons/emitter2.ogg'
	school = SCHOOL_PSYCHIC
	cooldown_time = 1 SECONDS

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
	/// Helmet the spell's bound to.
	var/obj/item/clothing/head/helmet/perceptomatrix/linked_helmet
	var/datum/effect_system/spark_spread/quantum/spark_sys = new /datum/effect_system/spark_spread/quantum

/datum/action/cooldown/spell/pointed/percept_hallucination/New(Target)
	. = ..()

	linked_helmet = Target

	spark_sys = new /datum/effect_system/spark_spread/quantum


/datum/action/cooldown/spell/pointed/percept_hallucination/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(cast_on))
		return FALSE

	return cast_on

/datum/action/cooldown/spell/pointed/percept_hallucination/cast(mob/living/carbon/human/cast_on)
	. = ..()
	owner.Beam(cast_on, icon_state = "greyscale_lightning", beam_color = COLOR_FADED_PINK, time = 0.5 SECONDS)

	spark_sys.set_up(2, 1, get_turf(owner))
	spark_sys.start()
	spark_sys.set_up(4, 1, get_turf(cast_on))
	spark_sys.start()

	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("You feel psychic energies reflecting off you."))
		to_chat(owner, span_warning("[cast_on] deflects the energy!"))
		return FALSE

	to_chat(cast_on, span_warning("Your brain feels like it's on fire!"))
	cast_on.emote("scream")
	cast_on.set_eye_blur_if_lower(eye_blur_duration)
	cast_on.adjust_staggered(stagger_duration)
	cast_on.apply_status_effect(/datum/status_effect/hallucination, hallucination_duration, \
		hallucination_duration * 0.2, hallucination_duration) // lower/upper hallucination freq. bound

	return TRUE
