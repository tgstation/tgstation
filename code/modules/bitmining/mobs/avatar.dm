/**
 * ### An avatar for the virtual domain.
 * Provides a link to the owner's body.
 */
/mob/living/carbon/human/avatar
	job = "Bit Avatar"
	/// Stores the help text datum
	var/datum/avatar_help_text/help_datum
	/// The pilot of this avatar. This changes on connection.
	var/mob/living/carbon/human/pilot
	/// The netchair currently hosting this avatar. Need this to cleanup server refs
	var/obj/structure/netchair/connected_netchair

/mob/living/carbon/human/avatar/New(loc, netchair, help_text)
	. = ..()
	src.connected_netchair = netchair
	help_datum = new(help_text)
	var/datum/action/avatar_domain_info/action = new(help_datum)
	action.Grant(src)

/mob/living/carbon/human/avatar/proc/connect(mob/living/carbon/human/pilot)
	playsound(src, 'sound/magic/repulse.ogg', 30, 2)
	pilot.mind.transfer_to(src, TRUE)
	src.pilot = pilot

	RegisterSignal(src, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damage))
	RegisterSignals(src, list(
		COMSIG_LIVING_DEATH,
		COMSIG_LIVING_GIBBED,
		COMSIG_QSERVER_DISCONNECT
		),
		PROC_REF(disconnect),
		TRUE
	)
	RegisterSignals(pilot, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOVABLE_UNBUCKLE,
		COMSIG_LIVING_STATUS_UNCONSCIOUS,
		COMSIG_LIVING_DEATH
		),
		PROC_REF(disconnect),
		TRUE
	)

/// Disconnects the avatar and returns the mind to the pilot.
/mob/living/carbon/human/avatar/proc/disconnect(forced = FALSE)
	SIGNAL_HANDLER

	if(QDELETED(pilot))
		dust()
		return

	playsound_local(src, 'sound/magic/blind.ogg', 30, 2)
	mind.transfer_to(pilot)

	UnregisterSignal(src, COMSIG_MOB_APPLY_DAMAGE)
	UnregisterSignal(src, COMSIG_LIVING_DEATH)
	UnregisterSignal(src, COMSIG_LIVING_GIBBED)
	UnregisterSignal(src, COMSIG_QSERVER_DISCONNECT)
	UnregisterSignal(pilot, COMSIG_LIVING_STATUS_UNCONSCIOUS)
	UnregisterSignal(pilot, COMSIG_LIVING_DEATH)
	UnregisterSignal(pilot, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(pilot, COMSIG_MOVABLE_UNBUCKLE)

	connected_netchair.disconnect_occupant()

	if(!forced || pilot.stat == DEAD)
		return

	connected_netchair.disconnect_avatar()

	pilot.flash_act()
	pilot.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
	INVOKE_ASYNC(pilot, PROC_REF(emote), "scream")
	pilot.do_jitter_animation(200)
	to_chat(pilot, span_danger("You've been forcefully disconnected from your avatar! Your thoughts feel scrambled!"))

/// Injures the pilot of this avatar.
/mob/living/carbon/human/avatar/proc/on_damage(mob/target, damage, damage_type, def_zone)
	SIGNAL_HANDLER

	if(QDELETED(pilot) || damage_type == STAMINA || damage_type == OXY)
		return

	if(damage > 15)
		pilot.do_jitter_animation(damage)

	if(damage > 30 && prob(30))
		INVOKE_ASYNC(pilot, PROC_REF(emote), "scream")

	pilot.apply_damage(damage, damage_type, def_zone, forced = TRUE)

 /// A datum that stores an information action for the avatar.
/datum/avatar_help_text
	/// Text to display in the window
	var/help_text

/datum/avatar_help_text/New(help_text)
	src.help_text = help_text

/datum/avatar_help_text/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AvatarHelp")
		ui.open()

/datum/avatar_help_text/ui_state(mob/user)
	return GLOB.always_state

/datum/avatar_help_text/ui_static_data(mob/user)
	var/list/data = list()

	data["help_text"] = help_text

	return data

/// Displays information about the current virtual domain.
/datum/action/avatar_domain_info
	name = "Open Virtual Domain Information"
	button_icon_state = "round_end"
	show_to_observers = FALSE

/datum/action/avatar_domain_info/New(Target)
	. = ..()
	name = "Open Domain Information"

/datum/action/avatar_domain_info/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	target.ui_interact(owner)
