/// A ranged guardian can fling shards of glass at people very very quickly. It can also enter a long-range scouting mode.
/mob/living/basic/guardian/ranged
	guardian_type = GUARDIAN_RANGED
	combat_mode = FALSE
	friendly_verb_continuous = "quietly assesses"
	friendly_verb_simple = "quietly assess"
	melee_damage_lower = 10
	melee_damage_upper = 10
	damage_coeff = list(BRUTE = 0.9, BURN = 0.9, TOX = 0.9, STAMINA = 0, OXY = 0.9)
	range = 13
	playstyle_string = span_holoparasite("As a <b>ranged</b> type, you have only light damage resistance, but are capable of spraying shards of crystal at incredibly high speed. You can also deploy surveillance snares to monitor enemy movement. Finally, you can switch to scout mode, in which you can't attack, but can move without limit.")
	creator_name = "Ranged"
	creator_desc = "Has two modes. Ranged; which fires a constant stream of weak, armor-ignoring projectiles. Scout; where it cannot attack, but can move through walls and is quite hard to see. Can lay surveillance snares, which alert it when crossed, in either mode."
	creator_icon = "ranged"
	see_invisible = SEE_INVISIBLE_LIVING
	toggle_button_type = /atom/movable/screen/guardian/toggle_mode

/mob/living/basic/guardian/ranged/Initialize(mapload, datum/guardian_fluff/theme)
	. = ..()
	AddComponent(\
		/datum/component/ranged_attacks,\
		projectile_type = /obj/projectile/guardian,\
		projectile_sound = 'sound/effects/hit_on_shattered_glass.ogg',\
		cooldown_time = 0.1 SECONDS, \
	)
	AddComponent(/datum/component/ranged_mob_full_auto, autofire_shot_delay = 0.1 SECONDS)
	var/datum/action/cooldown/mob_cooldown/guardian_alarm_snare/snare = new (src)
	snare.Grant(src)

/mob/living/basic/guardian/ranged/toggle_modes()
	if(is_deployed() && !isnull(summoner))
		balloon_alert(src, "must not be manifested!")
		return
	if (has_status_effect(/datum/status_effect/guardian_scout_mode))
		remove_status_effect(/datum/status_effect/guardian_scout_mode)
		return
	apply_status_effect(/datum/status_effect/guardian_scout_mode)

/mob/living/basic/guardian/ranged/toggle_light()
	var/msg
	switch(lighting_cutoff)
		if (LIGHTING_CUTOFF_VISIBLE)
			lighting_cutoff_red = 10
			lighting_cutoff_green = 10
			lighting_cutoff_blue = 15
			msg = "You activate your night vision."
		if (LIGHTING_CUTOFF_MEDIUM)
			lighting_cutoff_red = 25
			lighting_cutoff_green = 25
			lighting_cutoff_blue = 35
			msg = "You increase your night vision."
		if (LIGHTING_CUTOFF_HIGH)
			lighting_cutoff_red = 35
			lighting_cutoff_green = 35
			lighting_cutoff_blue = 50
			msg = "You maximize your night vision."
		else
			lighting_cutoff_red = 0
			lighting_cutoff_green = 0
			lighting_cutoff_blue = 0
			msg = "You deactivate your night vision."
	sync_lighting_plane_cutoff()
	to_chat(src, span_notice(msg))

/// Become an incorporeal scout
/datum/status_effect/guardian_scout_mode
	id = "guardian_scout"
	alert_type = null

/datum/status_effect/guardian_scout_mode/on_apply()
	animate(owner, alpha = 45, time = 0.5 SECONDS)
	RegisterSignal(owner, COMSIG_GUARDIAN_MANIFESTED, PROC_REF(on_manifest))
	RegisterSignal(owner, COMSIG_GUARDIAN_RECALLED, PROC_REF(on_recall))
	RegisterSignal(owner, COMSIG_MOB_CLICKON, PROC_REF(on_click))
	RegisterSignal(owner, COMSIG_BASICMOB_PRE_ATTACK_RANGED, PROC_REF(on_ranged_attack))

	var/mob/living/basic/guardian/guardian_mob = owner
	guardian_mob.unleash()
	to_chat(owner, span_bolddanger("You enter scouting mode."))
	return TRUE

/datum/status_effect/guardian_scout_mode/on_remove()
	animate(owner, alpha = initial(owner.alpha), time = 0.5 SECONDS)
	UnregisterSignal(owner, list(
		COMSIG_BASICMOB_PRE_ATTACK_RANGED,
		COMSIG_GUARDIAN_MANIFESTED,
		COMSIG_GUARDIAN_RECALLED,
		COMSIG_MOB_CLICKON,
	))
	to_chat(owner, span_bolddanger("You return to your normal mode."))
	var/mob/living/basic/guardian/guardian_mob = owner
	guardian_mob.leash_to(owner, guardian_mob.summoner)

/// Restore incorporeal move when we become corporeal, yes I know that suonds silly
/datum/status_effect/guardian_scout_mode/proc/on_manifest()
	SIGNAL_HANDLER
	owner.incorporeal_move = INCORPOREAL_MOVE_BASIC

/// Stop having incorporeal move when we recall so that we can't move
/datum/status_effect/guardian_scout_mode/proc/on_recall()
	SIGNAL_HANDLER
	owner.incorporeal_move = FALSE

/// While this is active we can't click anything
/datum/status_effect/guardian_scout_mode/proc/on_click()
	SIGNAL_HANDLER
	return COMSIG_MOB_CANCEL_CLICKON

/// We can't do any ranged attacks while in scout mode.
/datum/status_effect/guardian_scout_mode/proc/on_ranged_attack()
	SIGNAL_HANDLER
	owner.balloon_alert(owner, "need to be in ranged mode!")
	return COMPONENT_CANCEL_RANGED_ATTACK

/// Place an invisible trap which alerts the guardian when it is crossed
/datum/action/cooldown/mob_cooldown/guardian_alarm_snare
	name = "Surveillance Snare"
	desc = "Place an invisible snare which will alert you when it is crossed."
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "eye"
	background_icon = 'icons/hud/guardian.dmi'
	background_icon_state = "base"
	cooldown_time = 2 SECONDS
	melee_cooldown_time = 0
	click_to_activate = FALSE
	/// How many snares can we have?
	var/maximum_snares = 5
	/// What snares have we already placed?
	var/list/placed_snares = list()

/datum/action/cooldown/mob_cooldown/guardian_alarm_snare/Activate(atom/target)
	StartCooldown(360 SECONDS)

	if (length(placed_snares) >= maximum_snares)
		var/picked_snare = tgui_input_list(owner, "Choose a snare to replace.", "Remove Snare", sort_names(placed_snares))
		if(isnull(picked_snare))
			return FALSE
		qdel(picked_snare)
	if (length(placed_snares) >= maximum_snares)
		StartCooldown(0)
		return FALSE

	owner.balloon_alert(owner, "snare deployed") // We need feedback because they are invisible
	var/turf/snare_loc = get_turf(owner)
	var/obj/effect/abstract/surveillance_snare/new_snare = new(snare_loc, owner)
	new_snare.assign_owner(owner)
	RegisterSignal(new_snare, COMSIG_QDELETING, PROC_REF(on_snare_deleted))
	placed_snares += new_snare

	StartCooldown()
	return TRUE

/// When a snare is deleted remove it from tracking
/datum/action/cooldown/mob_cooldown/guardian_alarm_snare/proc/on_snare_deleted(atom/snare)
	SIGNAL_HANDLER
	placed_snares -= snare


/// An invisible marker placed by a ranged guardian, alerts the owner when crossed
/obj/effect/abstract/surveillance_snare
	name = "surveillance snare"
	desc = "This thing is invisible, how are you examining it?"
	invisibility = INVISIBILITY_ABSTRACT
	/// Who do we notify when someone steps on us?
	var/mob/living/owner

/obj/effect/abstract/surveillance_snare/Initialize(mapload, spawning_guardian)
	. = ..()
	name = "[get_area(src)] snare ([rand(1, 1000)])"
	var/static/list/loc_connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_entered))
	AddElement(/datum/element/connect_loc, loc_connections)

/// Set up crossed notification
/obj/effect/abstract/surveillance_snare/proc/assign_owner(mob/living/new_owner)
	if (isnull(new_owner))
		qdel(src)
		return
	owner = new_owner
	RegisterSignal(owner, COMSIG_QDELETING, PROC_REF(owner_destroyed))

/// When crossed notify our owner
/obj/effect/abstract/surveillance_snare/proc/on_entered(atom/source, crossed_object)
	SIGNAL_HANDLER
	if (isnull(owner))
		qdel(src)
		return
	if (!isliving(crossed_object) || crossed_object == owner)
		return
	var/mob/living/basic/guardian/guardian_owner = owner
	if (isguardian(owner) && crossed_object == guardian_owner.summoner || guardian_owner.shares_summoner(crossed_object))
		return

	var/send_message = span_bolddanger("[crossed_object] has crossed [name].")
	if (!isguardian(owner) || isnull(guardian_owner.summoner))
		to_chat(owner, send_message)
		return

	to_chat(guardian_owner.summoner, send_message)
	var/list/guardians = guardian_owner.summoner.get_all_linked_holoparasites()
	for(var/guardian in guardians)
		to_chat(guardian, send_message)

/// If the person who placed us doesn't exist we might as well die
/obj/effect/abstract/surveillance_snare/proc/owner_destroyed()
	SIGNAL_HANDLER
	owner = null
	qdel(src)


/// The glass shards we throw as a guardian. They have low damage because you can fire them very very quickly.
/obj/projectile/guardian
	name = "crystal spray"
	icon_state = "guardian"
	damage = 5
	damage_type = BRUTE
	armour_penetration = 100
