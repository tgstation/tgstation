/datum/action/changeling/mmi_talk
	name = "MMI Talk"
	desc = "Our decoy brain has been implanted into a Man-Machine Interface. \
		In order to maintain our secrecy, we can speak through the decoy as if a normal brain. \
		The decoy brain will relay speech it hears to you in purple."
	button_icon = 'icons/obj/devices/assemblies.dmi'
	button_icon_state = "mmi_off"
	dna_cost = CHANGELING_POWER_UNOBTAINABLE
	ignores_fakedeath = TRUE // Can be used while fake dead
	req_stat = DEAD // Can be used while real dead too

	/**
	 * Reference to the brain we're talking through.
	 *
	 * Set when created via the ling decoy component.
	 * If the brain ends up being qdelled, this action will also be qdelled, and thus this ref is cleared.
	 */
	VAR_FINAL/obj/item/organ/brain/brain_ref

	/// A map view of the area around the MMI.
	VAR_FINAL/atom/movable/screen/map_view/mmi_view
	/// The background for the MMI map view.
	VAR_FINAL/atom/movable/screen/background/mmi_view_background
	/// The key that the map view uses.
	VAR_FINAL/mmi_view_key
	/// A movement detector that updates the map view when the MMI moves around.
	VAR_FINAL/datum/movement_detector/update_view_tracker

/datum/action/changeling/mmi_talk/Destroy()
	brain_ref = null
	QDEL_NULL(mmi_view)
	QDEL_NULL(mmi_view_background)
	QDEL_NULL(update_view_tracker)
	return ..()

/datum/action/changeling/mmi_talk/Remove(mob/remove_from)
	. = ..()
	SStgui.close_uis(src)

/datum/action/changeling/mmi_talk/can_sting(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	// This generally shouldn't happen, but just in case
	if(isnull(brain_ref))
		stack_trace("[type] can_sting was called with a null brain!")
		return FALSE
	if(!istype(brain_ref.loc, /obj/item/mmi))
		stack_trace("[type] can_sting was called with a brain not located in an MMI!")
		return FALSE
	return TRUE

/datum/action/changeling/mmi_talk/sting_action(mob/living/user, mob/living/target)
	..()
	ui_interact(user)
	return TRUE

/datum/action/changeling/mmi_talk/ui_state(mob/user)
	return GLOB.always_state

/datum/action/changeling/mmi_talk/ui_status(mob/user, datum/ui_state/state)
	if(user != owner)
		return UI_CLOSE
	return ..()

/datum/action/changeling/mmi_talk/ui_static_data(mob/user)
	var/list/data = list()
	data["mmi_view"] = mmi_view_key
	return data

/datum/action/changeling/mmi_talk/ui_interact(mob/user, datum/tgui/ui)
	if(isnull(mmi_view_key))
		// it's worth noting a ling could have multiple of these actions.
		mmi_view_key = "ling_mmi_[REF(src)]_view"
		// Generate background
		mmi_view_background = new()
		mmi_view_background.assigned_map = mmi_view_key
		mmi_view_background.del_on_map_removal = FALSE
		mmi_view_background.fill_rect(1, 1, 5, 5)
		// Generate map view
		mmi_view = new()
		mmi_view.generate_view(mmi_view_key)
		// Generate movement detector (to update the view on MMI movement)
		update_view_tracker = new(brain_ref, CALLBACK(src, PROC_REF(update_mmi_view)))

	// Shows the view to the user foremost
	mmi_view.display_to(user)
	user.client.register_map_obj(mmi_view_background)
	update_mmi_view()
	// Makes the MMI relay heard messages
	if(!HAS_TRAIT_FROM(brain_ref.loc, TRAIT_HEARING_SENSITIVE, REF(src)))
		var/obj/item/mmi/mmi = brain_ref.loc
		mmi.become_hearing_sensitive(REF(src))
		RegisterSignal(mmi, COMSIG_MOVABLE_HEAR, PROC_REF(relay_hearing))
	// Actually open the UI
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LingMMITalk")
		ui.open()

/datum/action/changeling/mmi_talk/ui_close(mob/user)
	var/obj/item/mmi/mmi = brain_ref.loc
	UnregisterSignal(mmi, COMSIG_MOVABLE_HEAR)
	mmi.lose_hearing_sensitivity(REF(src))

/datum/action/changeling/mmi_talk/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return TRUE

	if(action != "send_mmi_message")
		return FALSE

	var/obj/item/mmi/mmi = brain_ref.loc
	if(mmi.brainmob.stat != CONSCIOUS)
		to_chat(usr, span_warning("Our decoy brain is too damaged to speak."))
	else
		// Say will perform input sanitization and such for us
		mmi.brainmob.say(params["message"], sanitize = TRUE)
	return TRUE

/// Used in callbacks to update the map view when the MMI moves.
/datum/action/changeling/mmi_talk/proc/update_mmi_view()
	mmi_view.vis_contents.Cut()
	for(var/turf/visible_turf in view(2, get_turf(brain_ref)))
		mmi_view.vis_contents += visible_turf

/// Signal proc for [COMSIG_MOVABLE_HEAR] to relay stuff the MMI hears to the ling.
/// Not super good, but it works.
/datum/action/changeling/mmi_talk/proc/relay_hearing(obj/item/mmi/source, list/hear_args)
	SIGNAL_HANDLER

	// We can likely already hear them, so do not bother
	if(can_see(owner, hear_args[HEARING_SPEAKER], 7))
		return

	var/list/new_args = hear_args.Copy()
	new_args[HEARING_SPANS] |= "purple"
	new_args[HEARING_RANGE] = INFINITY // so we can hear it from any distance away
	owner.Hear(arglist(new_args))
