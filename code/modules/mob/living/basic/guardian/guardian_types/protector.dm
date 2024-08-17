/// Very durable, and reverses the usual leash dynamic. Can slow down to become extremely durable.
/mob/living/basic/guardian/protector
	guardian_type = GUARDIAN_PROTECTOR
	melee_damage_lower = 15
	melee_damage_upper = 15
	range = 5 // You want this to be low so you can drag them around
	damage_coeff = list(BRUTE = 0.4, BURN = 0.4, TOX = 0.4, STAMINA = 0, OXY = 0.4)
	playstyle_string = span_holoparasite("As a <b>protector</b> type you cause your summoner to leash to you instead of you leashing to them and have two modes; Combat Mode, where you do and take medium damage, and Protection Mode, where you do and take almost no damage, but move slightly slower.")
	creator_name = "Protector"
	creator_desc = "Causes you to teleport to it when out of range, unlike other parasites. Has two modes; Combat, where it does and takes medium damage, and Protection, where it does and takes almost no damage but moves slightly slower."
	creator_icon = "protector"
	toggle_button_type = /atom/movable/screen/guardian/toggle_mode
	/// Action which toggles our shield
	var/datum/action/cooldown/mob_cooldown/protector_shield/shield

/mob/living/basic/guardian/protector/Initialize(mapload, datum/guardian_fluff/theme)
	. = ..()
	shield = new(src)
	shield.Grant(src)

/mob/living/basic/guardian/protector/Destroy()
	QDEL_NULL(shield)
	return ..()

// Invert the order
/mob/living/basic/guardian/protector/leash_to(atom/movable/leashed, atom/movable/leashed_to)
	return ..(leashed_to, leashed)

/mob/living/basic/guardian/protector/unleash()
	qdel(summoner?.GetComponent(/datum/component/leash))

/mob/living/basic/guardian/protector/toggle_modes()
	shield.Trigger()

/mob/living/basic/guardian/protector/ex_act(severity)
	if(severity >= EXPLODE_DEVASTATE)
		adjustBruteLoss(400) //if in protector mode, will do 20 damage and not actually necessarily kill the summoner
		return TRUE
	return ..()

/// Toggle a status effect which makes you slow but defensive
/datum/action/cooldown/mob_cooldown/protector_shield
	name = "Protection Mode"
	desc = "Enter a defensive stance which slows you down and reduces your damage, but makes you almost invincible."
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "shield-old"
	background_icon = 'icons/hud/guardian.dmi'
	background_icon_state = "base"
	cooldown_time = 1 SECONDS
	click_to_activate = FALSE
	owner_has_control = FALSE // Hide it from the user, it's integrated with guardian UI

/datum/action/cooldown/mob_cooldown/protector_shield/Activate(mob/living/target)
	if (!isliving(target))
		return FALSE
	if (target.has_status_effect(/datum/status_effect/protector_shield))
		target.remove_status_effect(/datum/status_effect/protector_shield)
		return
	target.apply_status_effect(/datum/status_effect/protector_shield)
	StartCooldown()
	return TRUE

/// Makes the guardian even more durable, but slower
/datum/status_effect/protector_shield
	id = "guardian_shield"
	alert_type = null
	/// Damage removed in protecting mode.
	var/damage_penalty = 13
	/// Colour for our various overlays.
	var/overlay_colour = COLOR_TEAL
	/// Overlay for our protection shield.
	var/mutable_appearance/shield_overlay
	/// Damage coefficients when shielded
	var/list/shielded_damage = list(BRUTE = 0.05, BURN = 0.05, TOX = 0.05, STAMINA = 0, OXY = 0.05)

/datum/status_effect/protector_shield/on_apply()
	if (isguardian(owner))
		var/mob/living/basic/guardian/guardian_owner = owner
		overlay_colour = guardian_owner.guardian_colour
	shield_overlay = mutable_appearance('icons/effects/effects.dmi', "shield-grey")
	shield_overlay.color = overlay_colour

	owner.melee_damage_lower -= damage_penalty
	owner.melee_damage_upper -= damage_penalty
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/guardian_shield)

	if (isbasicmob(owner)) // Better hope you are or this status is doing basically nothing useful for you
		var/mob/living/basic/basic_owner = owner
		basic_owner.damage_coeff = shielded_damage

	to_chat(owner, span_bolddanger("You enter protection mode."))
	RegisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignals(owner, COMSIG_LIVING_ADJUST_STANDARD_DAMAGE_TYPES, PROC_REF(on_health_changed))
	owner.update_appearance(UPDATE_ICON)
	return TRUE

/datum/status_effect/protector_shield/on_remove()
	owner.melee_damage_lower += damage_penalty
	owner.melee_damage_upper += damage_penalty
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/guardian_shield)

	if (isbasicmob(owner))
		var/mob/living/basic/basic_owner = owner
		basic_owner.damage_coeff = initial(basic_owner.damage_coeff)

	to_chat(owner, span_bolddanger("You return to your normal mode."))
	UnregisterSignal(owner, list(COMSIG_ATOM_UPDATE_OVERLAYS) + COMSIG_LIVING_ADJUST_STANDARD_DAMAGE_TYPES)
	owner.update_appearance(UPDATE_ICON)

/// Show an extra overlay when we're in shield mode
/datum/status_effect/protector_shield/proc/on_update_overlays(atom/source, list/overlays)
	SIGNAL_HANDLER
	overlays += shield_overlay

/// Flash an animation when someone tries to hurt us
/datum/status_effect/protector_shield/proc/on_health_changed(mob/living/our_mob, type, amount, forced)
	SIGNAL_HANDLER
	if (amount <= 0 && !QDELETED(our_mob))
		return
	var/image/flash_overlay = new('icons/effects/effects.dmi', owner, "shield-flash", dir = pick(GLOB.cardinals))
	flash_overlay.color = overlay_colour
	owner.flick_overlay_view(flash_overlay, 0.5 SECONDS)
