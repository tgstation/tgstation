#define MINOR_INSANITY_PEN 5
#define MAJOR_INSANITY_PEN 10

/datum/component/mood
	var/mood //Real happiness
	var/sanity = SANITY_NEUTRAL //Current sanity
	var/shown_mood //Shown happiness, this is what others can see when they try to examine you, prevents antag checking by noticing traitors are always very happy.
	var/mood_level = 5 //To track what stage of moodies they're on
	var/sanity_level = 2 //To track what stage of sanity they're on
	var/mood_modifier = 1 //Modifier to allow certain mobs to be less affected by moodlets
	var/list/datum/mood_event/mood_events = list()
	var/insanity_effect = 0 //is the owner being punished for low mood? If so, how much?
	var/atom/movable/screen/mood/screen_obj

/datum/component/mood/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	START_PROCESSING(SSmood, src)

	RegisterSignal(parent, COMSIG_ADD_MOOD_EVENT, .proc/add_event)
	RegisterSignal(parent, COMSIG_CLEAR_MOOD_EVENT, .proc/clear_event)
	RegisterSignal(parent, COMSIG_ENTER_AREA, .proc/check_area_mood)
	RegisterSignal(parent, COMSIG_LIVING_REVIVE, .proc/on_revive)
	RegisterSignal(parent, COMSIG_MOB_HUD_CREATED, .proc/modify_hud)
	RegisterSignal(parent, COMSIG_JOB_RECEIVED, .proc/register_job_signals)
	RegisterSignal(parent, COMSIG_VOID_MASK_ACT, .proc/direct_sanity_drain)
	RegisterSignal(parent, COMSIG_ON_CARBON_SLIP, .proc/on_slip)

	var/mob/living/owner = parent
	owner.become_area_sensitive(MOOD_COMPONENT_TRAIT)
	if(owner.hud_used)
		modify_hud()
		var/datum/hud/hud = owner.hud_used
		hud.show_hud(hud.hud_version)

/datum/component/mood/Destroy()
	STOP_PROCESSING(SSmood, src)
	var/atom/movable/movable_parent = parent
	movable_parent.lose_area_sensitivity(MOOD_COMPONENT_TRAIT)
	unmodify_hud()
	return ..()

/datum/component/mood/proc/register_job_signals(datum/source, job)
	SIGNAL_HANDLER

	if(job in list(JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST, JOB_ROBOTICIST, JOB_GENETICIST))
		RegisterSignal(parent, COMSIG_ADD_MOOD_EVENT_RND, .proc/add_event) //Mood events that are only for RnD members

/datum/component/mood/proc/print_mood(mob/user)
	var/msg = "[span_info("*---------*\n<EM>My current mental status:</EM>")]\n"
	msg += span_notice("My current sanity: ") //Long term
	switch(sanity)
		if(SANITY_GREAT to INFINITY)
			msg += "[span_nicegreen("My mind feels like a temple!")]\n"
		if(SANITY_NEUTRAL to SANITY_GREAT)
			msg += "[span_nicegreen("I have been feeling great lately!")]\n"
		if(SANITY_DISTURBED to SANITY_NEUTRAL)
			msg += "[span_nicegreen("I have felt quite decent lately.")]\n"
		if(SANITY_UNSTABLE to SANITY_DISTURBED)
			msg += "[span_warning("I'm feeling a little bit unhinged...")]\n"
		if(SANITY_CRAZY to SANITY_UNSTABLE)
			msg += "[span_boldwarning("I'm freaking out!!")]\n"
		if(SANITY_INSANE to SANITY_CRAZY)
			msg += "[span_boldwarning("AHAHAHAHAHAHAHAHAHAH!!")]\n"

	msg += span_notice("My current mood: ") //Short term
	switch(mood_level)
		if(1)
			msg += "[span_boldwarning("I wish I was dead!")]\n"
		if(2)
			msg += "[span_boldwarning("I feel terrible...")]\n"
		if(3)
			msg += "[span_boldwarning("I feel very upset.")]\n"
		if(4)
			msg += "[span_boldwarning("I'm a bit sad.")]\n"
		if(5)
			msg += "[span_nicegreen("I'm alright.")]\n"
		if(6)
			msg += "[span_nicegreen("I feel pretty okay.")]\n"
		if(7)
			msg += "[span_nicegreen("I feel pretty good.")]\n"
		if(8)
			msg += "[span_nicegreen("I feel amazing!")]\n"
		if(9)
			msg += "[span_nicegreen("I love life!")]\n"

	msg += "[span_notice("Moodlets:")]\n"//All moodlets
	if(mood_events.len)
		for(var/i in mood_events)
			var/datum/mood_event/event = mood_events[i]
			msg += event.description
	else
		msg += "[span_nicegreen("I don't have much of a reaction to anything right now.")]\n"
	to_chat(user, msg)

///Called after moodevent/s have been added/removed.
/datum/component/mood/proc/update_mood()
	mood = 0
	shown_mood = 0
	for(var/i in mood_events)
		var/datum/mood_event/event = mood_events[i]
		mood += event.mood_change
		if(!event.hidden)
			shown_mood += event.mood_change
	mood *= mood_modifier
	shown_mood *= mood_modifier

	switch(mood)
		if(-INFINITY to MOOD_LEVEL_SAD4)
			mood_level = 1
		if(MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
			mood_level = 2
		if(MOOD_LEVEL_SAD3 to MOOD_LEVEL_SAD2)
			mood_level = 3
		if(MOOD_LEVEL_SAD2 to MOOD_LEVEL_SAD1)
			mood_level = 4
		if(MOOD_LEVEL_SAD1 to MOOD_LEVEL_HAPPY1)
			mood_level = 5
		if(MOOD_LEVEL_HAPPY1 to MOOD_LEVEL_HAPPY2)
			mood_level = 6
		if(MOOD_LEVEL_HAPPY2 to MOOD_LEVEL_HAPPY3)
			mood_level = 7
		if(MOOD_LEVEL_HAPPY3 to MOOD_LEVEL_HAPPY4)
			mood_level = 8
		if(MOOD_LEVEL_HAPPY4 to INFINITY)
			mood_level = 9
	update_mood_icon()


/datum/component/mood/proc/update_mood_icon()
	var/mob/living/owner = parent
	if(!(owner.client || owner.hud_used))
		return
	screen_obj.cut_overlays()
	screen_obj.color = initial(screen_obj.color)
	//lets see if we have any special icons to show instead of the normal mood levels
	var/list/conflicting_moodies = list()
	var/highest_absolute_mood = 0
	for(var/i in mood_events) //adds overlays and sees which special icons need to vie for which one gets the icon_state
		var/datum/mood_event/event = mood_events[i]
		if(!event.special_screen_obj)
			continue
		if(!event.special_screen_replace)
			screen_obj.add_overlay(event.special_screen_obj)
		else
			conflicting_moodies += event
			var/absmood = abs(event.mood_change)
			if(absmood > highest_absolute_mood)
				highest_absolute_mood = absmood

	switch(sanity_level)
		if(1)
			screen_obj.color = "#2eeb9a"
		if(2)
			screen_obj.color = "#86d656"
		if(3)
			screen_obj.color = "#4b96c4"
		if(4)
			screen_obj.color = "#dfa65b"
		if(5)
			screen_obj.color = "#f38943"
		if(6)
			screen_obj.color = "#f15d36"

	if(!conflicting_moodies.len) //no special icons- go to the normal icon states
		screen_obj.icon_state = "mood[mood_level]"
		return

	for(var/i in conflicting_moodies)
		var/datum/mood_event/event = i
		if(abs(event.mood_change) == highest_absolute_mood)
			screen_obj.icon_state = "[event.special_screen_obj]"
			break

///Called on SSmood process
/datum/component/mood/process(delta_time)
	var/mob/living/moody_fellow = parent
	if(moody_fellow.stat == DEAD)
		return //updating sanity during death leads to people getting revived and being completely insane for simply being dead for a long time
	switch(mood_level)
		if(1)
			setSanity(sanity-0.3*delta_time, SANITY_INSANE)
		if(2)
			setSanity(sanity-0.15*delta_time, SANITY_INSANE)
		if(3)
			setSanity(sanity-0.1*delta_time, SANITY_CRAZY)
		if(4)
			setSanity(sanity-0.05*delta_time, SANITY_UNSTABLE)
		if(5)
			setSanity(sanity, SANITY_UNSTABLE) //This makes sure that mood gets increased should you be below the minimum.
		if(6)
			setSanity(sanity+0.2*delta_time, SANITY_UNSTABLE)
		if(7)
			setSanity(sanity+0.3*delta_time, SANITY_UNSTABLE)
		if(8)
			setSanity(sanity+0.4*delta_time, SANITY_NEUTRAL, SANITY_MAXIMUM)
		if(9)
			setSanity(sanity+0.6*delta_time, SANITY_NEUTRAL, SANITY_MAXIMUM)
	HandleNutrition()

	// 0.416% is 15 successes / 3600 seconds. Calculated with 2 minute
	// mood runtime, so 50% average uptime across the hour.
	if(HAS_TRAIT(parent, TRAIT_DEPRESSION) && DT_PROB(0.416, delta_time))
		add_event(null, "depression_mild", /datum/mood_event/depression_mild)

	if(HAS_TRAIT(parent, TRAIT_JOLLY) && DT_PROB(0.416, delta_time))
		add_event(null, "jolly", /datum/mood_event/jolly)




///Sets sanity to the specified amount and applies effects.
/datum/component/mood/proc/setSanity(amount, minimum=SANITY_INSANE, maximum=SANITY_GREAT, override = FALSE)
	// If we're out of the acceptable minimum-maximum range move back towards it in steps of 0.7
	// If the new amount would move towards the acceptable range faster then use it instead
	if(amount < minimum)
		amount += clamp(minimum - amount, 0, 0.7)
	if((!override && HAS_TRAIT(parent, TRAIT_UNSTABLE)) || amount > maximum)
		amount = min(sanity, amount)
	if(amount == sanity) //Prevents stuff from flicking around.
		return
	sanity = amount
	var/mob/living/master = parent
	SEND_SIGNAL(master, COMSIG_CARBON_SANITY_UPDATE, amount)
	switch(sanity)
		if(SANITY_INSANE to SANITY_CRAZY)
			setInsanityEffect(MAJOR_INSANITY_PEN)
			master.add_movespeed_modifier(/datum/movespeed_modifier/sanity/insane)
			master.add_actionspeed_modifier(/datum/actionspeed_modifier/low_sanity)
			sanity_level = 6
		if(SANITY_CRAZY to SANITY_UNSTABLE)
			setInsanityEffect(MINOR_INSANITY_PEN)
			master.add_movespeed_modifier(/datum/movespeed_modifier/sanity/crazy)
			master.add_actionspeed_modifier(/datum/actionspeed_modifier/low_sanity)
			sanity_level = 5
		if(SANITY_UNSTABLE to SANITY_DISTURBED)
			setInsanityEffect(0)
			master.add_movespeed_modifier(/datum/movespeed_modifier/sanity/disturbed)
			master.add_actionspeed_modifier(/datum/actionspeed_modifier/low_sanity)
			sanity_level = 4
		if(SANITY_DISTURBED to SANITY_NEUTRAL)
			setInsanityEffect(0)
			master.remove_movespeed_modifier(MOVESPEED_ID_SANITY)
			master.remove_actionspeed_modifier(ACTIONSPEED_ID_SANITY)
			sanity_level = 3
		if(SANITY_NEUTRAL+1 to SANITY_GREAT+1) //shitty hack but +1 to prevent it from responding to super small differences
			setInsanityEffect(0)
			master.remove_movespeed_modifier(MOVESPEED_ID_SANITY)
			master.add_actionspeed_modifier(/datum/actionspeed_modifier/high_sanity)
			sanity_level = 2
		if(SANITY_GREAT+1 to INFINITY)
			setInsanityEffect(0)
			master.remove_movespeed_modifier(MOVESPEED_ID_SANITY)
			master.add_actionspeed_modifier(/datum/actionspeed_modifier/high_sanity)
			sanity_level = 1
	update_mood_icon()

/datum/component/mood/proc/setInsanityEffect(newval)
	if(newval == insanity_effect)
		return
	var/mob/living/master = parent
	master.crit_threshold = (master.crit_threshold - insanity_effect) + newval
	insanity_effect = newval

/datum/component/mood/proc/add_event(datum/source, category, type, ...) //Category will override any events in the same category, should be unique unless the event is based on the same thing like hunger.
	SIGNAL_HANDLER

	var/datum/mood_event/the_event
	if(!ispath(type, /datum/mood_event))
		return
	if(!istext(category))
		category = REF(category)
	if(mood_events[category])
		the_event = mood_events[category]
		if(the_event.type != type)
			clear_event(null, category)
		else
			if(the_event.timeout)
				addtimer(CALLBACK(src, .proc/clear_event, null, category), the_event.timeout, TIMER_UNIQUE|TIMER_OVERRIDE)
			return //Don't have to update the event.
	var/list/params = args.Copy(4)
	params.Insert(1, parent)
	the_event = new type(arglist(params))

	mood_events[category] = the_event
	the_event.category = category
	update_mood()

	if(the_event.timeout)
		addtimer(CALLBACK(src, .proc/clear_event, null, category), the_event.timeout, TIMER_UNIQUE|TIMER_OVERRIDE)

/datum/component/mood/proc/clear_event(datum/source, category)
	SIGNAL_HANDLER

	if(!istext(category))
		category = REF(category)
	var/datum/mood_event/event = mood_events[category]
	if(!event)
		return

	mood_events -= category
	qdel(event)
	update_mood()

/datum/component/mood/proc/remove_temp_moods() //Removes all temp moods
	for(var/i in mood_events)
		var/datum/mood_event/moodlet = mood_events[i]
		if(!moodlet || !moodlet.timeout)
			continue
		mood_events -= moodlet.category
		qdel(moodlet)
	update_mood()


/datum/component/mood/proc/modify_hud(datum/source)
	SIGNAL_HANDLER

	var/mob/living/owner = parent
	var/datum/hud/hud = owner.hud_used
	screen_obj = new
	screen_obj.color = "#4b96c4"
	hud.infodisplay += screen_obj
	RegisterSignal(hud, COMSIG_PARENT_QDELETING, .proc/unmodify_hud)
	RegisterSignal(screen_obj, COMSIG_CLICK, .proc/hud_click)

/datum/component/mood/proc/unmodify_hud(datum/source)
	SIGNAL_HANDLER

	if(!screen_obj)
		return
	var/mob/living/owner = parent
	var/datum/hud/hud = owner.hud_used
	if(hud?.infodisplay)
		hud.infodisplay -= screen_obj
	QDEL_NULL(screen_obj)

/datum/component/mood/proc/hud_click(datum/source, location, control, params, mob/user)
	SIGNAL_HANDLER

	if(user != parent)
		return
	print_mood(user)

/datum/component/mood/proc/HandleNutrition()
	var/mob/living/L = parent
	if(HAS_TRAIT(L, TRAIT_NOHUNGER))
		return FALSE //no mood events for nutrition
	switch(L.nutrition)
		if(NUTRITION_LEVEL_FULL to INFINITY)
			if (!HAS_TRAIT(L, TRAIT_VORACIOUS))
				add_event(null, "nutrition", /datum/mood_event/fat)
			else
				add_event(null, "nutrition", /datum/mood_event/wellfed) // round and full
		if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
			add_event(null, "nutrition", /datum/mood_event/wellfed)
		if( NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
			add_event(null, "nutrition", /datum/mood_event/fed)
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			clear_event(null, "nutrition")
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			add_event(null, "nutrition", /datum/mood_event/hungry)
		if(0 to NUTRITION_LEVEL_STARVING)
			add_event(null, "nutrition", /datum/mood_event/starving)

/datum/component/mood/proc/check_area_mood(datum/source, area/A)
	SIGNAL_HANDLER

	update_beauty(A)
	if(A.mood_bonus && (!A.mood_trait || HAS_TRAIT(source, A.mood_trait)))
		add_event(null, "area", /datum/mood_event/area, A.mood_bonus, A.mood_message)
	else
		clear_event(null, "area")

/datum/component/mood/proc/update_beauty(area/A)
	if(A.outdoors) //if we're outside, we don't care.
		clear_event(null, "area_beauty")
		return FALSE
	if(HAS_TRAIT(parent, TRAIT_SNOB))
		switch(A.beauty)
			if(-INFINITY to BEAUTY_LEVEL_HORRID)
				add_event(null, "area_beauty", /datum/mood_event/horridroom)
				return
			if(BEAUTY_LEVEL_HORRID to BEAUTY_LEVEL_BAD)
				add_event(null, "area_beauty", /datum/mood_event/badroom)
				return
	switch(A.beauty)
		if(BEAUTY_LEVEL_BAD to BEAUTY_LEVEL_DECENT)
			clear_event(null, "area_beauty")
		if(BEAUTY_LEVEL_DECENT to BEAUTY_LEVEL_GOOD)
			add_event(null, "area_beauty", /datum/mood_event/decentroom)
		if(BEAUTY_LEVEL_GOOD to BEAUTY_LEVEL_GREAT)
			add_event(null, "area_beauty", /datum/mood_event/goodroom)
		if(BEAUTY_LEVEL_GREAT to INFINITY)
			add_event(null, "area_beauty", /datum/mood_event/greatroom)

///Called when parent is ahealed.
/datum/component/mood/proc/on_revive(datum/source, full_heal)
	SIGNAL_HANDLER

	if(!full_heal)
		return
	remove_temp_moods()
	setSanity(initial(sanity), override = TRUE)


///Causes direct drain of someone's sanity, call it with a numerical value corresponding how badly you want to hurt their sanity
/datum/component/mood/proc/direct_sanity_drain(datum/source, amount)
	SIGNAL_HANDLER
	setSanity(sanity + amount, override = TRUE)

///Called when parent slips.
/datum/component/mood/proc/on_slip(datum/source)
	SIGNAL_HANDLER

	add_event(null, "slipped", /datum/mood_event/slipped)


/datum/component/mood/proc/HandleAddictions()
	if(!iscarbon(parent))
		return

	var/mob/living/carbon/affected_carbon = parent

	if(sanity < SANITY_GREAT) ///Sanity is low, stay addicted.
		return

	for(var/addiction_type in affected_carbon.mind.addiction_points)
		var/datum/addiction/addiction_to_remove = SSaddiction.all_addictions[type]
		affected_carbon.mind.remove_addiction_points(type, addiction_to_remove.high_sanity_addiction_loss) //If true was returned, we lost the addiction!

#undef MINOR_INSANITY_PEN
#undef MAJOR_INSANITY_PEN

