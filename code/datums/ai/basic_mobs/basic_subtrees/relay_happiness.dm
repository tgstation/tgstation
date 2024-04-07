/datum/ai_planning_subtree/express_happiness
    operational_datums = list(/datum/component/happiness)
    ///the key storing our happiness value
	var/happiness_key = BB_BASIC_HAPPINESS
    ///when do we express extreme happiness
    var/high_happiness_threshold = 0.7
    ///when do we express moderate happiness
    var/moderate_happiness_threshold = 0.5
    ///list of emotions we relay when happy
    var/static/list/happy_emotions = list(
        "celebrates happily!"
        "dances around in excitement!"
    )
    var/static/list/moderate_emotions = list(
        "looks satisfied."
        "trots around."
    )
    var/static/list/depressed_emotions = list(
        "looks depressed..."
        "turns its back and sulks..."
        "looks towards the floor in dissapointment..."
    )

/datum/ai_planning_subtree/express_happiness/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
    if(!SPT_PROB(5, seconds_per_tick))
        return
	var/high_happiness = controller.blackboard[BB_HIGH_HAPPINESS_THRESHOLD] ? controller.blackboard[BB_HIGH_HAPPINESS_THRESHOLD] : high_happiness_threshold
    var/moderate_happiness = controller.blackboard[BB_MODERATE_HAPPINESS_THRESHOLD] ? controller.blackboard[BB_MODERATE_HAPPINESS_THRESHOLD] : moderate_happiness_threshold
    var/happiness_value = controller.blackboard[happiness_key]
    if(isnull(happiness_value))
        return 
    var/list/final_list
    switch(happiness_value)
        if(high_happiness to INFINITY)
            final_list = happy_emotions
        if(moderate_happiness to high_happiness)
            final_list = moderate_emotions
        else
            final_list = depressed_emotions
    if(!length(final_list))
        return    
    controller.queue_behavior(/datum/ai_behavior/perform_emote, pick(final_list))
	return
