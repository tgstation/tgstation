#define AI_CORE_BRAIN(X) X.braintype == "Android" ? "brain" : "MMI"
#define UPDATE_STATE(new_state) state = new_state; update_appearance(UPDATE_ICON_STATE)
#define CHECK_STATE_CALLBACK(maintained_state) CALLBACK(src, PROC_REF(check_state), maintained_state)

/obj/structure/ai_core/welder_act(mob/living/user, obj/item/tool)
	if(state != CORE_STATE_EMPTY)
		balloon_alert(user, "frame has to be empty!")
		return ITEM_INTERACT_BLOCKING

	if(!tool.tool_start_check(user, 1))
		return ITEM_INTERACT_BLOCKING

	if(!tool.use_tool(src, user, 2 SECONDS, 1, 50, CHECK_STATE_CALLBACK(CORE_STATE_EMPTY)))
		return ITEM_INTERACT_BLOCKING

	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/structure/ai_core/wrench_act(mob/living/user, obj/item/tool)
	if(state >= CORE_STATE_FINISHED)
		set_anchored(TRUE) //teehee
		balloon_alert(user, "can't unanchor!")
		return ITEM_INTERACT_BLOCKING

	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/structure/ai_core/screwdriver_act(mob/living/user, obj/item/tool)
	switch(state)
		if(CORE_STATE_EMPTY)
			balloon_alert(user, "nothing to screw in there!")
			return ITEM_INTERACT_BLOCKING
		if(CORE_STATE_CIRCUIT)
			if(!tool.use_tool(src, user, 0 SECONDS, 0, 50, CHECK_STATE_CALLBACK(CORE_STATE_CIRCUIT)))
				return ITEM_INTERACT_BLOCKING
			balloon_alert(user, "board secured")
			UPDATE_STATE(CORE_STATE_SCREWED)
			return ITEM_INTERACT_SUCCESS
		if(CORE_STATE_SCREWED)
			if(!tool.use_tool(src, user, 0 SECONDS, 0, 50, CHECK_STATE_CALLBACK(CORE_STATE_SCREWED)))
				return ITEM_INTERACT_BLOCKING
			balloon_alert(user, "board unsecured")
			UPDATE_STATE(CORE_STATE_CIRCUIT)
			return ITEM_INTERACT_SUCCESS
		if(CORE_STATE_CABLED)
			balloon_alert(user, "can't reach the board!")
			return ITEM_INTERACT_BLOCKING
		if(CORE_STATE_GLASSED)
			if(!anchored)
				balloon_alert(user, "isn't anchored!")
				return ITEM_INTERACT_BLOCKING
			if(!tool.use_tool(src, user, 0 SECONDS, 0, 50, CHECK_STATE_CALLBACK(CORE_STATE_GLASSED)))
				return ITEM_INTERACT_BLOCKING
			if(suicide_check())
				balloon_alert(user, "processor is completely useless!")
				return ITEM_INTERACT_BLOCKING

			var/atom/movable/alert_source = src
			if(core_mmi.brainmob?.mind)
				alert_source = ai_structure_to_mob() || alert_source
			else
				UPDATE_STATE(CORE_STATE_FINISHED)
			alert_source.balloon_alert(user, "connected monitor[core_mmi?.brainmob?.mind ? " and neural network" : ""]")
			return ITEM_INTERACT_SUCCESS
		if(CORE_STATE_FINISHED)
			if(!core_mmi?.brainmob?.mind || suicide_check())
				balloon_alert(user, "processor is inactive!")
				return ITEM_INTERACT_BLOCKING

			if(!anchored)
				balloon_alert(user, "anchor it first!")
				return ITEM_INTERACT_BLOCKING

			balloon_alert(user, "connecting neural network...")
			if(!tool.use_tool(src, user, 10 SECONDS, 0, 50, CHECK_STATE_CALLBACK(CORE_STATE_FINISHED)))
				return ITEM_INTERACT_BLOCKING

			var/atom/movable/alert_source = ai_structure_to_mob()
			if(!alert_source)
				balloon_alert(user, "processor is inactive!")
				return ITEM_INTERACT_BLOCKING

			alert_source.balloon_alert(user, "connected neural network")
			return ITEM_INTERACT_SUCCESS

/obj/structure/ai_core/crowbar_act(mob/living/user, obj/item/tool)
	switch(state)
		if(CORE_STATE_EMPTY)
			balloon_alert(user, "nothing to pry out!")
			return ITEM_INTERACT_BLOCKING
		if(CORE_STATE_CIRCUIT)
			if(!tool.use_tool(src, user, 0 SECONDS, 0, 50, CHECK_STATE_CALLBACK(CORE_STATE_CIRCUIT)))
				return ITEM_INTERACT_BLOCKING

			circuit.forceMove(drop_location())
			UPDATE_STATE(CORE_STATE_EMPTY)
			return ITEM_INTERACT_SUCCESS
		if(CORE_STATE_SCREWED)
			balloon_alert(user, "won't budge!")
			return ITEM_INTERACT_BLOCKING
		if(CORE_STATE_CABLED)
			if(!core_mmi)
				balloon_alert(user, "nothing to pry out!")
				return ITEM_INTERACT_BLOCKING
			if(!tool.use_tool(src, user, 0 SECONDS, 0, 50, CHECK_STATE_CALLBACK(CORE_STATE_CABLED)) || !core_mmi)
				return ITEM_INTERACT_BLOCKING

			core_mmi.forceMove(drop_location())
			UPDATE_STATE(CORE_STATE_CABLED)
			return ITEM_INTERACT_SUCCESS
		if(CORE_STATE_GLASSED)
			if(!tool.use_tool(src, user, 0 SECONDS, 0, 50, CHECK_STATE_CALLBACK(CORE_STATE_GLASSED)))
				return ITEM_INTERACT_BLOCKING

			new /obj/item/stack/sheet/rglass(drop_location(), 2)
			UPDATE_STATE(CORE_STATE_CABLED)
			return ITEM_INTERACT_SUCCESS
		if(CORE_STATE_FINISHED)
			balloon_alert(user, "display is on!")
			return ITEM_INTERACT_SUCCESS

/obj/structure/ai_core/wirecutter_act(mob/living/user, obj/item/tool)
	switch(state)
		if(CORE_STATE_EMPTY to CORE_STATE_CIRCUIT)
			balloon_alert(user, "nothing to cut!")
			return ITEM_INTERACT_BLOCKING
		if(CORE_STATE_CABLED)
			if(core_mmi)
				balloon_alert(user, "[AI_CORE_BRAIN(core_mmi)] in the way!")
				return ITEM_INTERACT_BLOCKING

			if(!tool.use_tool(src, user, 0 SECONDS, 0, 50, CHECK_STATE_CALLBACK(CORE_STATE_CABLED)) || core_mmi)
				return ITEM_INTERACT_BLOCKING

			new /obj/item/stack/cable_coil(drop_location(), 5)
			UPDATE_STATE(CORE_STATE_SCREWED)
			return ITEM_INTERACT_SUCCESS
		if(CORE_STATE_GLASSED)
			balloon_alert(user, "nothing left to cut!")
			return ITEM_INTERACT_BLOCKING
		if(CORE_STATE_FINISHED)
			if(!tool.use_tool(src, user, 0 SECONDS, 0, 50, CHECK_STATE_CALLBACK(CORE_STATE_FINISHED)))
				return ITEM_INTERACT_BLOCKING

			UPDATE_STATE(CORE_STATE_GLASSED)
			return ITEM_INTERACT_SUCCESS

/// Handles the interaction chain the same as item_interaction. Exists to isolate construction behaviour from other item behaviour.
/obj/structure/ai_core/proc/construction_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/circuitboard/aicore))
		return install_board(user, tool) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

	if(istype(tool, /obj/item/stack/cable_coil))
		return add_cabling(user, tool) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

	if(istype(tool, /obj/item/mmi))
		return install_mmi(user, tool) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING
	if(istype(tool, /obj/item/ai_module))
		return update_laws(user, tool) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING
	if(istype(tool, /obj/item/stack/sheet/rglass))
		return install_glass(user, tool) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

	return NONE

/obj/structure/ai_core/proc/install_board(mob/living/user, obj/item/circuitboard/aicore/circuit)
	if(state != CORE_STATE_EMPTY)
		return FALSE
	if(!user.transferItemToLoc(circuit, src))
		return FALSE

	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	src.circuit = circuit
	UPDATE_STATE(CORE_STATE_CIRCUIT)
	return TRUE

/obj/structure/ai_core/proc/add_cabling(mob/living/user, obj/item/stack/cable_coil/cable)
	if(state != CORE_STATE_SCREWED)
		return FALSE

	if(cable.get_amount() < 5)
		balloon_alert(user, "not enough [cable::name]!")
		return FALSE

	balloon_alert(user, "adding cable...")
	if(!cable.use_tool(src, user, 2 SECONDS, 5, 50, CHECK_STATE_CALLBACK(CORE_STATE_SCREWED)))
		return FALSE

	UPDATE_STATE(CORE_STATE_CABLED)
	return TRUE

/obj/structure/ai_core/proc/install_mmi(mob/living/user, obj/item/mmi/mmi)
	if(state != CORE_STATE_CABLED)
		return FALSE

	if(!mmi.brain_check(user))
		var/wants_install = (tgui_alert(user, "This [AI_CORE_BRAIN(mmi)] is inactive, would you like to make an inactive AI?", "Installing AI [AI_CORE_BRAIN(mmi)]", list("Yes", "No")) == "Yes")
		if(!wants_install)
			return FALSE
		if(QDELETED(src) || QDELETED(user) || QDELETED(mmi) || !user.is_holding(mmi) || !Adjacent(user))
			return FALSE
		if(mmi.brainmob && HAS_TRAIT(mmi.brainmob, TRAIT_SUICIDED))
			balloon_alert(user, "[AI_CORE_BRAIN(mmi)] is useless!")
			return FALSE
	else
		var/mob/living/brain/mmi_brainmob = mmi.brainmob
		if(!CONFIG_GET(flag/allow_ai) || (mmi_brainmob && is_banned_from(mmi_brainmob.ckey, JOB_AI)))
			if(!QDELETED(src) && !QDELETED(user) && !QDELETED(mmi) && user.is_holding(mmi) && Adjacent(user))
				balloon_alert(user, "[mmi] won't fit!")
			return FALSE

	if(state != CORE_STATE_CABLED)
		return FALSE
	if(!user.transferItemToLoc(mmi, src))
		return FALSE

	core_mmi = mmi
	UPDATE_STATE(CORE_STATE_CABLED)
	return TRUE

/obj/structure/ai_core/proc/update_laws(mob/living/user, obj/item/ai_module/module)
	if(!core_mmi)
		balloon_alert(user, "no brain installed!")
		return FALSE
	if(!core_mmi.brainmob || !core_mmi.brainmob?.mind || suicide_check())
		balloon_alert(user, "[AI_CORE_BRAIN(core_mmi)] is inactive!")
		return FALSE
	if(core_mmi.laws.id != DEFAULT_AI_LAWID)
		balloon_alert(user, "[AI_CORE_BRAIN(core_mmi)] already has set laws!")
		return FALSE

	module.install(laws, user)
	return TRUE

/obj/structure/ai_core/proc/install_glass(mob/living/user, obj/item/stack/sheet/rglass/glass)
	if(state != CORE_STATE_CABLED)
		return FALSE

	if(!core_mmi)
		balloon_alert(user, "needs a processor!")
		return FALSE
	if(glass.get_amount() < 2)
		balloon_alert(user, "not enough [glass::name]!")
		return FALSE

	if(!glass.use_tool(src, user, 2 SECONDS, 2, 50, CHECK_STATE_CALLBACK(CORE_STATE_CABLED)) || !core_mmi)
		return FALSE

	UPDATE_STATE(CORE_STATE_GLASSED)
	return TRUE

#undef CHECK_STATE_CALLBACK
#undef UPDATE_STATE
#undef AI_CORE_BRAIN
