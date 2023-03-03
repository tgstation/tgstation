/// Actor datums are assigned to players in Stories.
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

// For the purposes of the UI code for prefs, an antagonist datum must exist. We never apply this anywhere however, and shouldn't, because this breaks the concept of Actors.
/datum/antagonist/story_participant
	name = "\improper Story Participant"
	roundend_category = "Story Participant"
	job_rank = ROLE_STORY_PARTICIPANT
	silent = TRUE //greet called by the event
	show_in_antagpanel = FALSE
	prevent_roundtype_conversion = FALSE
	suicide_cry = "FOR ROLEPLAYING!!"
	preview_outfit = /datum/outfit/centcom_inspector
	count_against_dynamic_roll_chance = FALSE

/datum/antagonist/story_participant/get_preview_icon()
	var/icon/final_icon = render_preview_outfit(preview_outfit)
	final_icon.Blend(make_background_story_icon(/datum/outfit/veteran), ICON_UNDERLAY, -8, 0)
	final_icon.Blend(make_background_story_icon(/datum/outfit/middle_management), ICON_UNDERLAY, 8, 0)

	final_icon.Scale(64, 64)

	return finish_preview_icon(final_icon)

/datum/antagonist/story_participant/proc/make_background_story_icon(datum/outfit/story_fit)
	var/mob/living/carbon/human/dummy/consistent/actor = new

	var/icon/story_icon = render_preview_outfit(story_fit, actor)
	story_icon.ChangeOpacity(0.5)
	qdel(actor)

	return story_icon
