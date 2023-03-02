/datum/story_actor
	/// Name of the actor role
	var/name = "Actor Name"
	/// Ref to the mind that's being the actor
	var/datum/mind/actor_ref //temporarily unused
	/// Ref to the story that we're a part of
	var/datum/story_type/involved_story
	/// Is this a ghost or human actor
	var/ghost_actor = FALSE
	/// An outfit to give the actor, will pick from a list
	var/list/actor_outfits = list()
	/// What to tell the actor, if anything (will not trigger if unchanged)
	var/actor_info = ""
	/// Do we tell the actor that they are in fact an actor or not
	var/inform_player = TRUE
	/// Ref to the actor info button
	var/datum/action/story_participant_info/info_button
	/// Explicit goal of what the actor needs to do, shown in TGUI popup, does not appear if left blank
	var/actor_goal = ""
	/// ID of the actors to group them with, for Z reservation. Leaving unchanged will make all actors spawn together
	var/actor_spawn_id = "default"

/datum/story_actor/Destroy(force, ...)
	actor_ref = null
	involved_story = null
	if(info_button)
		QDEL_NULL(info_button)
	return ..()

/// How to actually spawn the actor
/datum/story_actor/proc/handle_spawning(mob/picked_spawner, datum/story_type/current_story)
	SHOULD_CALL_PARENT(TRUE)
	if(inform_player && picked_spawner.client?.prefs)
		INVOKE_ASYNC(GLOBAL_PROC, /proc/tgui_alert, picked_spawner, "You are a Story Participant! See your chat for more information.", "Story Participation")
	if(actor_info)
		to_chat(picked_spawner, span_boldnotice(actor_info))
	return TRUE

/datum/story_actor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StoryParticipant", name)
		ui.open()

/datum/story_actor/ui_state(mob/user)
	return GLOB.always_state

/datum/story_actor/ui_static_data(mob/user)
	var/list/data = list()
	data["name"] = name
	data["info"] = actor_info
	data["goal"] = actor_goal
	return data

/datum/action/story_participant_info
	name = "Story Participant Information:"
	button_icon_state = "round_end" //placeholder

/datum/action/story_participant_info/New(Target)
	. = ..()
	name += " [target]"

/datum/action/story_participant_info/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	target.ui_interact(owner)

/datum/action/story_participant_info/IsAvailable(feedback = FALSE)
	if(!target)
		stack_trace("[type] was used without a story participant datum!")
		return FALSE
	. = ..()
	if(!.)
		return
	if(!owner.mind)
		return FALSE
	return TRUE

