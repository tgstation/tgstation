

#define RAVAGER_OUTLINE_EFFECT "ravager_endure_outline"

/mob/living/carbon/alien/adult/nova/ravager
	name = "alien ravager"
	desc = "An alien with angry red chitin, with equally intimidating looking blade-like claws in place of normal hands. That sharp tail looks like it'd probably hurt."
	caste = "ravager"
	maxHealth = 350
	health = 350
	icon_state = "alienravager"
	melee_damage_lower = 30
	melee_damage_upper = 35

/mob/living/carbon/alien/adult/nova/ravager/Initialize(mapload)
	. = ..()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/spell/aoe/repulse/xeno/nova_tailsweep/slicing,
		/datum/action/cooldown/alien/nova/literally_too_angry_to_die,
		/datum/action/cooldown/mob_cooldown/charge/triple_charge/ravager,
	)
	grant_actions_by_list(innate_actions)

	REMOVE_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/carbon/alien/adult/nova/ravager/create_internal_organs()
	organs += new /obj/item/organ/internal/alien/plasmavessel
	..()

/datum/action/cooldown/mob_cooldown/charge/triple_charge/ravager
	name = "Triple Charge Attack"
	desc = "Allows you to charge thrice at a location, trampling any in your path."
	cooldown_time = 30 SECONDS
	charge_delay = 0.3 SECONDS
	charge_distance = 7
	charge_past = 3
	destroy_objects = FALSE
	charge_damage = 25
	button_icon = 'monkestation/code/modules/blueshift/icons/xeno_actions.dmi'
	button_icon_state = "ravager_charge"
	unset_after_click = TRUE

/datum/action/cooldown/mob_cooldown/charge/triple_charge/ravager/do_charge_indicator(atom/charger, atom/charge_target)
	playsound(charger, 'monkestation/code/modules/blueshift/sounds/alien_roar2.ogg', 100, TRUE, 8, 0.9)

/datum/action/cooldown/mob_cooldown/charge/triple_charge/ravager/Activate(atom/target_atom)
	. = ..()
	return TRUE

/datum/action/cooldown/spell/aoe/repulse/xeno/nova_tailsweep/slicing
	name = "Slicing Tail Sweep"
	desc = "Throw back attackers with a swipe of your tail, slicing them with its sharpened tip."

	aoe_radius = 2

	button_icon_state = "slice_tail"

	sparkle_path = /obj/effect/temp_visual/dir_setting/tailsweep/ravager

	sound = 'monkestation/code/modules/blueshift/sounds/alien_tail_swipe.ogg' //The defender's tail sound isn't changed because its big and heavy, this isn't

	impact_sound = 'monkestation/code/modules/blueshift/sounds/weapons/bloodyslice.ogg'
	impact_damage = 40
	impact_sharpness = SHARP_EDGED

/obj/effect/temp_visual/dir_setting/tailsweep/ravager
	icon = 'monkestation/code/modules/blueshift/icons/xeno_actions.dmi'
	icon_state = "slice_tail_anim"

/datum/action/cooldown/alien/nova/literally_too_angry_to_die
	name = "Endure"
	desc = "Imbue your body with unimaginable amounts of rage (and plasma) to allow yourself to ignore all pain for a short time."
	button_icon_state = "literally_too_angry"
	plasma_cost = 250 //This requires full plasma to do, so there can be some time between armstrong moments
	/// If the endure ability is currently active or not
	var/endure_active = FALSE
	/// How long the endure ability should last when activated
	var/endure_duration = 20 SECONDS

/datum/action/cooldown/alien/nova/literally_too_angry_to_die/Activate()
	. = ..()
	if(endure_active)
		owner.balloon_alert(owner, "already enduring")
		return FALSE
	owner.balloon_alert(owner, "endure began")
	playsound(owner, 'monkestation/code/modules/blueshift/sounds/alien_roar1.ogg', 100, TRUE, 8, 0.9)
	to_chat(owner, span_danger("We numb our ability to feel pain, allowing us to fight until the very last for the next [endure_duration/10] seconds."))
	addtimer(CALLBACK(src, PROC_REF(endure_deactivate)), endure_duration)
	owner.add_filter(RAVAGER_OUTLINE_EFFECT, 4, outline_filter(1, COLOR_RED_LIGHT))
	ADD_TRAIT(owner, TRAIT_STUNIMMUNE, TRAIT_XENO_ABILITY_GIVEN)
	ADD_TRAIT(owner, TRAIT_NOSOFTCRIT, TRAIT_XENO_ABILITY_GIVEN)
	ADD_TRAIT(owner, TRAIT_NOHARDCRIT, TRAIT_XENO_ABILITY_GIVEN)
	endure_active = TRUE
	return TRUE

/datum/action/cooldown/alien/nova/literally_too_angry_to_die/proc/endure_deactivate()
	endure_active = FALSE
	owner.balloon_alert(owner, "endure ended")
	owner.remove_filter(RAVAGER_OUTLINE_EFFECT)
	REMOVE_TRAIT(owner, TRAIT_STUNIMMUNE, TRAIT_XENO_ABILITY_GIVEN)
	REMOVE_TRAIT(owner, TRAIT_NOSOFTCRIT, TRAIT_XENO_ABILITY_GIVEN)
	REMOVE_TRAIT(owner, TRAIT_NOHARDCRIT, TRAIT_XENO_ABILITY_GIVEN)

#undef RAVAGER_OUTLINE_EFFECT
