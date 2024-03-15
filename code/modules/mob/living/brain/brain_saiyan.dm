/// The Saiyan brain contains knowledge of powerful martial arts
/obj/item/organ/internal/brain/saiyan
	name = "saiyan brain"
	desc = "The brain of a mighty saiyan warrior. Guess they don't work out at the library..."
	brain_size = 0.5
	/// What buttons did we give out
	var/list/granted_abilities = list()

/obj/item/organ/internal/brain/saiyan/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/ki_blast/blast = new(organ_owner)
	blast.Grant(organ_owner)
	granted_abilities += blast

	var/datum/action/cooldown/mob_cooldown/saiyan_flight/flight = new(organ_owner)
	flight.Grant(organ_owner)
	granted_abilities += flight

/obj/item/organ/internal/brain/saiyan/on_mob_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	QDEL_LIST(granted_abilities)

/// Shoot power from your hands, wow
/datum/action/cooldown/mob_cooldown/ki_blast
	name = "Ki Blast"
	desc = "Channel your ki into your hands and out into the world as rapid projectiles. Drains your fighting spirit."
	button_icon = 'icons/obj/weapons/guns/projectiles.dmi'
	button_icon_state = "pulse1"
	background_icon_state = "bg_demon"
	click_to_activate = FALSE
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED

/datum/action/cooldown/mob_cooldown/ki_blast/Activate(atom/target)
	var/mob/living/mob_caster = target
	if (!istype(mob_caster))
		return FALSE
	var/obj/item/gun/ki_blast/ki_gun = new(mob_caster.loc)
	if (!mob_caster.put_in_hands(ki_gun, del_on_fail = TRUE))
		mob_caster.balloon_alert(mob_caster, "no free hands!")
	return TRUE

/obj/item/gun/ki_blast
	name = "concentrated ki"
	desc = "The power of your lifeforce converted into a deadly weapon. Fire it at someone."
	fire_sound = 'sound/magic/wand_teleport.ogg'
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "pulse1"
	inhand_icon_state = "arcane_barrage"
	base_icon_state = "arcane_barrage"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	slot_flags = null
	item_flags = NEEDS_PERMIT | DROPDEL | ABSTRACT | NOBLUDGEON
	flags_1 = NONE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/gun/ki_blast/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.15 SECONDS)
	chambered = new /obj/item/ammo_casing/ki(src)

/obj/item/gun/ki_blast/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	. = ..()
	if (!.)
		return FALSE
	user.apply_damage(3, STAMINA)
	return TRUE

/obj/item/gun/ki_blast/handle_chamber(empty_chamber, from_firing, chamber_next_round)
	chambered.newshot()

/obj/item/ammo_casing/ki
	slot_flags = null
	projectile_type = /obj/projectile/ki
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/blue

/obj/projectile/ki
	name = "ki blast"
	icon_state = "pulse1_bl"
	damage = 3
	damage_type = BRUTE
	hitsound = 'sound/weapons/sear_disabler.ogg'
	hitsound_wall = 'sound/weapons/sear_disabler.ogg'

/// Saiyans can fly
/datum/action/cooldown/mob_cooldown/saiyan_flight
	name = "Flight"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "flight"
	background_icon_state = "bg_demon"
	desc = "Focus your energy and lift into the air, or alternately stop doing that if you are doing it already."
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_IMMOBILE|AB_CHECK_INCAPACITATED|AB_CHECK_LYING
	click_to_activate = FALSE
	cooldown_time = 3 SECONDS

/datum/action/cooldown/mob_cooldown/saiyan_flight/Activate(atom/target)
	var/mob/living/mob_caster = target
	if (!istype(mob_caster))
		return FALSE

	StartCooldown()
	if(!HAS_TRAIT_FROM(mob_caster, TRAIT_MOVE_FLYING, REF(src)))
		mob_caster.balloon_alert(mob_caster, "flying")
		ADD_TRAIT(mob_caster, TRAIT_MOVE_FLYING, REF(src))
		passtable_on(mob_caster, REF(src))
		return TRUE

	mob_caster.balloon_alert(mob_caster, "landed")
	REMOVE_TRAIT(mob_caster, TRAIT_MOVE_FLYING, REF(src))
	passtable_off(mob_caster, REF(src))
	return TRUE
