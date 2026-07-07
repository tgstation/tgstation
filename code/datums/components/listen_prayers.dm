/**
 * A component that allows the attached mind to listen prayers from other mobs.
 * Unlike admins, they cannot smite the person for it, also the prayers are anonymous unless the person says who he's in the message.
 */
/datum/component/listen_prayers
	///A callback called before the prayer is heard. May alter the message or prevent it from being heard if it returns FALSE
	var/datum/callback/pre_prayer_callback
	///This will be affixed to the "deities" that have heard this message.
	var/deity_name
	///The action that the owner can use to ignore the prayers
	var/datum/action/innate/listen_prayers/toggle
	///The description we give to the instance of the listen_prayers toggle.
	var/toggle_desc = "Allows you to listen to prayers"

/datum/component/listen_prayers/Initialize(datum/callback/pre_prayer_callback, deity_name, toggle_desc)
	if(!istype(parent, /datum/mind))
		return COMPONENT_INCOMPATIBLE

	if(pre_prayer_callback)
		src.pre_prayer_callback = pre_prayer_callback
	if(deity_name)
		src.deity_name = deity_name
	if(toggle_desc)
		src.toggle_desc = toggle_desc

/datum/component/listen_prayers/Destroy()
	pre_prayer_callback = null
	return ..()

/datum/component/listen_prayers/RegisterWithParent()
	RegisterSignal(SSdcs, COMSIG_GLOB_SEND_PRAYER, PROC_REF(on_sent_prayer))
	var/datum/mind/mind = parent
	toggle = new(mind)
	if(toggle_desc)
		toggle.desc = toggle_desc
	if(mind.current)
		toggle.Grant(mind.current)

/datum/component/listen_prayers/UnregisterFromParent()
	UnregisterSignal(SSdcs, COMSIG_GLOB_SEND_PRAYER)
	QDEL_NULL(toggle)

/datum/component/listen_prayers/proc/on_sent_prayer(source, mob/praying, message, prayer_type, symbol, list/deities_that_listened)
	SIGNAL_HANDLER
	var/datum/mind/mind = parent
	if(!mind.current || mind.current.stat >= UNCONSCIOUS || !mind.current.client) //You can't hear prayers if unconscious or disconnected
		return
	if(!isliving(praying) || praying.stat == DEAD)
		return FALSE //I don't see any reason in hell to why dead people should be allowed into this. This isn't a knockoff TRAIT_SIXTHSENSE.
	if(praying == mind.current) //Ignore prayers coming from ourselves.
		return
	if(mind.current.client in GLOB.admins) //This is redundant if we're adminning
		return
	if(HAS_MIND_TRAIT(mind.current, TRAIT_DONT_HEAR_PRAYERS))
		return
	var/list/arguments = args.Copy(2)
	if(pre_prayer_callback && !pre_prayer_callback.Invoke(arguments))
		return
	prayer_type = arguments[ARG_PRAYER_TYPE]
	symbol = arguments[ARG_PRAYER_SYMBOL]
	message = "[icon2html(arguments[ARG_PRAYER_SYMBOL], mind.current.client)]<b><font color=[GLOB.prayer_type_to_font_color[prayer_type]]>[prayer_type]: </font></b> [span_notice(arguments[ARG_PRAYER_MSG])]"
	to_chat(mind.current, custom_boxed_message(GLOB.prayer_type_to_message_box[prayer_type], message))
	SEND_SOUND(mind.current, sound('sound/effects/pray.ogg'))
	if(deity_name)
		deities_that_listened += deity_name

///An action to stop hearing prayers on command. Doesn't do a whole lot without the associated component
/datum/action/innate/listen_prayers
	name = "Listen Prayers"
	button_icon = 'icons/hud/actions.dmi'
	button_icon_state = "pray"
	desc = "Allows you to eavesdrop on prayers from the world around you."
	active = TRUE

/datum/action/innate/listen_prayers/Destroy()
	REMOVE_TRAIT(owner, TRAIT_DONT_HEAR_PRAYERS, ACTION_TRAIT)
	return ..()

/datum/action/innate/listen_prayers/is_action_active(atom/movable/screen/movable/action_button/current_button)
	return !HAS_TRAIT_FROM(owner, TRAIT_DONT_HEAR_PRAYERS, ACTION_TRAIT)

/datum/action/innate/listen_prayers/Activate()
	active = TRUE
	REMOVE_TRAIT(owner, TRAIT_DONT_HEAR_PRAYERS, ACTION_TRAIT)
	to_chat(owner, span_green("You are ready to listen to prayers once again."))
	build_all_button_icons(UPDATE_BUTTON_BACKGROUND)

/datum/action/innate/listen_prayers/Deactivate()
	active = FALSE
	ADD_TRAIT(owner, TRAIT_DONT_HEAR_PRAYERS, ACTION_TRAIT)
	to_chat(owner, span_green("You stop listening to prayers."))
	build_all_button_icons(UPDATE_BUTTON_BACKGROUND)
