//Item for knock/moon heretic sidepath, it can block 5 hits of damage, acts as storage and if the heretic is examined the examiner suffers brain damage and blindness

/obj/item/storage/belt/unfathomable_curio
	name = "Unfathomable Curio"
	desc = "It. It looks backs. It looks past. It looks in. It sees. It hides. It opens."
	icon_state = "unfathomable_curio"
	worn_icon_state = "unfathomable_curio"
	content_overlays = FALSE
	drop_sound = 'sound/items/handling/toolbelt_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbelt_pickup.ogg'
	//Vars used for the shield component
	var/heretic_shield_icon = "unfathomable_shield"
	var/max_charges = 1
	var/recharge_start_delay = 60 SECONDS
	var/charge_increment_delay = 60 SECONDS
	var/charge_recovery = 1

/obj/item/storage/belt/unfathomable_curio/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 21
	atom_storage.set_holdable(list(
		/obj/item/ammo_box/strilka310/lionhunter,
		/obj/item/bodypart, // Bodyparts are often used in rituals.
		/obj/item/clothing/neck/eldritch_amulet,
		/obj/item/clothing/neck/heretic_focus,
		/obj/item/codex_cicatrix,
		/obj/item/eldritch_potion,
		/obj/item/food/grown/poppy, // Used to regain a Living Heart.
		/obj/item/food/grown/harebell, // Used to reroll targets
		/obj/item/melee/rune_carver,
		/obj/item/melee/sickly_blade,
		/obj/item/organ, // Organs are also often used in rituals.
		/obj/item/reagent_containers/cup/beaker/eldritch,
		/obj/item/stack/sheet/glass, // Glass is often used by moon heretics
	))

	AddComponent(/datum/component/shielded, max_charges = max_charges, recharge_start_delay = recharge_start_delay, charge_increment_delay = charge_increment_delay, \
	charge_recovery = charge_recovery, shield_icon = heretic_shield_icon, run_hit_callback = CALLBACK(src, PROC_REF(shield_damaged)))


/obj/item/storage/belt/unfathomable_curio/equipped(mob/user, slot, initial)
	. = ..()
	if(!(slot & slot_flags))
		return

	RegisterSignal(user, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(shield_reaction))

	if(!IS_HERETIC(user))
		to_chat(user, span_warning("The curio wraps around you, and you feel the beating of something dark inside it..."))

/obj/item/storage/belt/unfathomable_curio/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_LIVING_CHECK_BLOCK)

// Here we make sure our curio is only able to block while worn on the belt slot
/obj/item/storage/belt/unfathomable_curio/proc/shield_reaction(mob/living/carbon/human/owner,
	atom/movable/hitby,
	damage = 0,
	attack_text = "the attack",
	attack_type = MELEE_ATTACK,
	armour_penetration = 0,
	damage_type = BRUTE,
)
	SIGNAL_HANDLER

	if(hit_reaction(owner, hitby, attack_text, 0, damage, attack_type) && (owner.belt == src))
		return SUCCESSFUL_BLOCK
	return NONE

// Our on hit effect
/obj/item/storage/belt/unfathomable_curio/proc/shield_damaged(mob/living/carbon/wearer, attack_text, new_current_charges)
	var/list/brain_traumas = list(
		/datum/brain_trauma/severe/mute,
		/datum/brain_trauma/severe/flesh_desire,
		/datum/brain_trauma/severe/eldritch_beauty,
		/datum/brain_trauma/severe/paralysis,
		/datum/brain_trauma/severe/monophobia
	)
	wearer.visible_message(span_danger("[wearer]'s veil makes [attack_text] miss, but the force behind the blow causes it to disperse!"))
	if(IS_HERETIC(wearer))
		return

	to_chat(wearer, span_warning("Laughter echoes in your mind...."))
	wearer.adjustOrganLoss(ORGAN_SLOT_BRAIN, 40)
	wearer.dropItemToGround(src, TRUE)
	wearer.gain_trauma(pick(brain_traumas) ,TRAUMA_RESILIENCE_ABSOLUTE)

/obj/item/storage/belt/unfathomable_curio/examine(mob/living/carbon/user)
	. = ..()
	if(IS_HERETIC(user))
		return

	user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10, 160)
	user.adjust_temp_blindness(5 SECONDS)
	. += span_notice("It. It looked. IT WRAPS ITSELF AROUND ME.")


