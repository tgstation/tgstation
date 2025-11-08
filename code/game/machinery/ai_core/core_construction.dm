#define AI_CORE_BRAIN(X) X.braintype == "Android" ? "brain" : "MMI"
#define UPDATE_STATE(new_state) state = new_state; update_appearance(UPDATE_ICON_STATE)
#define CHECK_STATE_CALLBACK(maintained_state) CALLBACK(src, PROC_REF(check_state), maintained_state)

/obj/structure/ai_core/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(state == CORE_STATE_FINISHED)
		if(!core_mmi)
			balloon_alert(user, "no brain installed!")
			return ITEM_INTERACT_SUCCESS
		else if(!core_mmi.brainmob?.mind || suicide_check())
			balloon_alert(user, "brain is inactive!")
			return ITEM_INTERACT_SUCCESS
		else
			balloon_alert(user, "connecting neural network...")
			if(!tool.use_tool(src, user, 10 SECONDS))
				return ITEM_INTERACT_SUCCESS
			if(!ai_structure_to_mob())
				return ITEM_INTERACT_SUCCESS
			balloon_alert(user, "connected neural network")
			return ITEM_INTERACT_SUCCESS

/obj/structure/ai_core/attackby(obj/item/tool, mob/living/user, list/modifiers, list/attack_modifiers)
	if(remote_ai)
		to_chat(remote_ai, span_danger("CORE TAMPERING DETECTED!"))
	if(!anchored)
		if(!user.combat_mode)
			balloon_alert(user, "bolt it down first!")
			return
		else
			return ..()
	else
		switch(state)
			if(CORE_STATE_GLASSED)
				if(tool.tool_behaviour == TOOL_CROWBAR)
					tool.play_tool_sound(src)
					balloon_alert(user, "removed glass panel")
					state = CORE_STATE_CABLED
					update_appearance()
					new /obj/item/stack/sheet/rglass(loc, 2)
					return

				if(tool.tool_behaviour == TOOL_SCREWDRIVER)
					if(suicide_check())
						to_chat(user, span_warning("The brain installed is completely useless."))
						return
					tool.play_tool_sound(src)

					var/atom/alert_source = src
					if(core_mmi.brainmob?.mind)
						alert_source = ai_structure_to_mob() || alert_source
					else
						state = CORE_STATE_FINISHED
						update_appearance()
					alert_source.balloon_alert(user, "connected monitor[core_mmi?.brainmob?.mind ? " and neural network" : ""]")
					return

			if(CORE_STATE_FINISHED)
				if(istype(tool, /obj/item/aicard))
					return //handled by /obj/structure/ai_core/transfer_ai()

				if(tool.tool_behaviour == TOOL_WIRECUTTER)
					tool.play_tool_sound(src)
					balloon_alert(user, "disconnected monitor")
					state = CORE_STATE_GLASSED
					update_appearance()
					return
	return ..()

/obj/structure/ai_core/welder_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE

	if(state != CORE_STATE_EMPTY)
		balloon_alert(user, "too much stuff!")
		return ITEM_INTERACT_BLOCKING

	if(!tool.tool_start_check(user, 1))
		balloon_alert(user, "[tool] won't work!")
		return ITEM_INTERACT_BLOCKING

	if(!tool.use_tool(src, user, 2 SECONDS, 1, 50, CHECK_STATE_CALLBACK(CORE_STATE_EMPTY)))
		return ITEM_INTERACT_BLOCKING

	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/structure/ai_core/wrench_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE

	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/structure/ai_core/screwdriver_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE

	switch(state)
		if(CORE_STATE_EMPTY)
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


/obj/structure/ai_core/crowbar_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE

	switch(state)
		if(CORE_STATE_EMPTY)
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
				return ITEM_INTERACT_BLOCKING

			if(!tool.use_tool(src, user, 0 SECONDS, 0, 50, CHECK_STATE_CALLBACK(CORE_STATE_CABLED)) || !core_mmi)
				return ITEM_INTERACT_BLOCKING
			if(remote_ai)
				var/mob/living/silicon/ai/remoted_ai = remote_ai
				remoted_ai.break_core_link()
				if(!IS_MALF_AI(remoted_ai))	//don't pull back shunted malf AIs
					remoted_ai.death(gibbed = TRUE, drop_mmi = FALSE)
					///the drop_mmi param determines whether the MMI is dropped at their current location
					///which in this case would be somewhere else, so we drop their MMI at the core instead
					remoted_ai.make_mmi_drop_and_transfer(core_mmi, src)

			core_mmi.forceMove(drop_location())
			UPDATE_STATE(CORE_STATE_CABLED)
			return ITEM_INTERACT_SUCCESS

/obj/structure/ai_core/wirecutter_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE

	switch(state)
		if(CORE_STATE_EMPTY to CORE_STATE_CIRCUIT)
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
		balloon_alert(user, "not enough cable!")
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
		if(mmi.brainmob && HAS_TRAIT(mmi.brainmob, TRAIT_SUICIDED))
			balloon_alert(user, "[mmi] is useless!")
			return FALSE
	else
		var/mob/living/brain/mmi_brainmob = mmi.brainmob
		if(!CONFIG_GET(flag/allow_ai) || (is_banned_from(mmi_brainmob.ckey, JOB_AI) && !QDELETED(src) && !QDELETED(user) && !QDELETED(mmi) && !QDELETED(user) && Adjacent(user)))
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
		balloon_alert(user, "not enough [glass.name]!")
		return FALSE

	// playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE
	if(!glass.use_tool(src, user, 2 SECONDS, 2, 50, CHECK_STATE_CALLBACK(CORE_STATE_CABLED)) || !core_mmi)
		return FALSE

	// playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	UPDATE_STATE(CORE_STATE_GLASSED)
	return TRUE

#undef AI_CORE_BRAIN
