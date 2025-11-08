#define AI_CORE_BRAIN(X) X.braintype == "Android" ? "brain" : "MMI"

/obj/structure/ai_core/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

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
		if(tool.tool_behaviour == TOOL_WELDER)
			if(state != CORE_STATE_EMPTY)
				balloon_alert(user, "core must be empty to deconstruct it!")
				return

			if(!tool.tool_start_check(user, amount=1))
				return

			balloon_alert(user, "deconstructing frame...")
			if(tool.use_tool(src, user, 20, volume=50) && state == CORE_STATE_EMPTY)
				balloon_alert(user, "deconstructed frame")
				deconstruct(TRUE)
			return
		else
			if(!user.combat_mode)
				balloon_alert(user, "bolt it down first!")
				return
			else
				return ..()
	else
		switch(state)
			if(CORE_STATE_EMPTY)
				if(istype(tool, /obj/item/circuitboard/aicore))
					if(!user.transferItemToLoc(tool, src))
						return
					playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
					balloon_alert(user, "circuit board inserted")
					update_appearance()
					state = CORE_STATE_CIRCUIT
					circuit = tool
					return
			if(CORE_STATE_CIRCUIT)
				if(tool.tool_behaviour == TOOL_SCREWDRIVER)
					tool.play_tool_sound(src)
					balloon_alert(user, "board screwed into place")
					state = CORE_STATE_SCREWED
					update_appearance()
					return
				if(tool.tool_behaviour == TOOL_CROWBAR)
					tool.play_tool_sound(src)
					balloon_alert(user, "circuit board removed")
					state = CORE_STATE_EMPTY
					circuit.forceMove(loc)
					return
			if(CORE_STATE_SCREWED)
				if(tool.tool_behaviour == TOOL_SCREWDRIVER && circuit)
					tool.play_tool_sound(src)
					balloon_alert(user, "circuit board unfastened")
					state = CORE_STATE_CIRCUIT
					update_appearance()
					return
				if(istype(tool, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/C = tool
					if(C.get_amount() >= 5)
						playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
						balloon_alert(user, "adding cables to frame...")
						if(do_after(user, 2 SECONDS, target = src) && state == CORE_STATE_SCREWED && C.use(5))
							balloon_alert(user, "added cables to frame.")
							state = CORE_STATE_CABLED
							update_appearance()
					else
						balloon_alert(user, "need five lengths of cable!")
					return
			if(CORE_STATE_CABLED)
				if(tool.tool_behaviour == TOOL_WIRECUTTER)
					if(core_mmi)
						balloon_alert(user, "remove the [AI_CORE_BRAIN(core_mmi)] first!")
					else
						tool.play_tool_sound(src)
						balloon_alert(user, "cables removed")
						state = CORE_STATE_SCREWED
						update_appearance()
						new /obj/item/stack/cable_coil(drop_location(), 5)
					return

				if(istype(tool, /obj/item/stack/sheet/rglass))
					if(!core_mmi)
						balloon_alert(user, "add a brain first!")
						return
					var/obj/item/stack/sheet/rglass/G = tool
					if(G.get_amount() >= 2)
						playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
						balloon_alert(user, "adding glass panel...")
						if(do_after(user, 2 SECONDS, target = src) && state == CORE_STATE_CABLED && G.use(2))
							balloon_alert(user, "added glass panel")
							state = CORE_STATE_GLASSED
							update_appearance()
					else
						balloon_alert(user, "need two sheets of reinforced glass!")
					return

				if(istype(tool, /obj/item/ai_module))
					if(!core_mmi)
						balloon_alert(user, "no brain installed!")
						return
					if(!core_mmi.brainmob || !core_mmi.brainmob?.mind || suicide_check())
						balloon_alert(user, "[AI_CORE_BRAIN(core_mmi)] is inactive!")
						return
					if(core_mmi.laws.id != DEFAULT_AI_LAWID)
						balloon_alert(user, "[AI_CORE_BRAIN(core_mmi)] already has set laws!")
						return
					var/obj/item/ai_module/module = tool
					module.install(laws, user)
					return

				if(istype(tool, /obj/item/mmi) && !core_mmi)
					var/obj/item/mmi/M = tool
					if(!M.brain_check(user))
						var/install = tgui_alert(user, "This [AI_CORE_BRAIN(M)] is inactive, would you like to make an inactive AI?", "Installing AI [AI_CORE_BRAIN(M)]", list("Yes", "No"))
						if(install != "Yes")
							return
						if(M.brainmob && HAS_TRAIT(M.brainmob, TRAIT_SUICIDED))
							to_chat(user, span_warning("[M.name] is completely useless!"))
							return
						if(!user.transferItemToLoc(M, src))
							return
						core_mmi = M
						balloon_alert(user, "added [AI_CORE_BRAIN(core_mmi)] to frame")
						update_appearance()
						return

					var/mob/living/brain/B = M.brainmob
					if(!CONFIG_GET(flag/allow_ai) || (is_banned_from(B.ckey, JOB_AI) && !QDELETED(src) && !QDELETED(user) && !QDELETED(M) && !QDELETED(user) && Adjacent(user)))
						if(!QDELETED(M))
							to_chat(user, span_warning("This [M.name] does not seem to fit!"))
						return
					if(!user.transferItemToLoc(M,src))
						return

					core_mmi = M
					balloon_alert(user, "added [AI_CORE_BRAIN(core_mmi)] to frame")
					update_appearance()
					return

				if(tool.tool_behaviour == TOOL_CROWBAR && core_mmi)
					tool.play_tool_sound(src)
					balloon_alert(user, "removed [AI_CORE_BRAIN(core_mmi)]")
					if(remote_ai)
						var/mob/living/silicon/ai/remoted_ai = remote_ai
						remoted_ai.break_core_link()
						if(!IS_MALF_AI(remoted_ai))
							//don't pull back shunted malf AIs
							remoted_ai.death(gibbed = TRUE, drop_mmi = FALSE)
							///the drop_mmi param determines whether the MMI is dropped at their current location
							///which in this case would be somewhere else, so we drop their MMI at the core instead
							remoted_ai.make_mmi_drop_and_transfer(core_mmi, src)
					core_mmi.forceMove(loc) //if they're malf, just drops a blank MMI, or if it's an incomplete shell
					return					//it drops the mmi that was put in before it was finished

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
