#define AI_CORE_BRAIN(X) X.braintype == "Android" ? "brain" : "MMI"

/obj/structure/ai_core
	density = TRUE
	anchored = FALSE
	name = "\improper AI core"
	icon = 'icons/mob/silicon/ai.dmi'
	icon_state = "0"
	desc = "The framework for an artificial intelligence core."
	max_integrity = 500
	var/state = EMPTY_CORE
	var/datum/ai_laws/laws
	var/obj/item/circuitboard/aicore/circuit
	var/obj/item/mmi/core_mmi

/obj/structure/ai_core/Initialize(mapload)
	. = ..()
	laws = new
	laws.set_laws_config()

/obj/structure/ai_core/examine(mob/user)
	. = ..()
	if(!anchored)
		if(state != EMPTY_CORE)
			. += span_notice("It has some <b>bolts</b> that could be tightened.")
		else
			. += span_notice("It has some <b>bolts</b> that could be tightened. The frame can be <b>melted</b> down.")
	else
		switch(state)
			if(EMPTY_CORE)
				. += span_notice("There is a <b>slot</b> for a circuit board, its <b>bolts</b> can be loosened.")
			if(CIRCUIT_CORE)
				. += span_notice("The circuit board can be <b>screwed</b> into place or <b>pried</b> out.")
			if(SCREWED_CORE)
				. += span_notice("The frame can be <b>wired</b>, the circuit board can be <b>unfastened</b>.")
			if(CABLED_CORE)
				if(!core_mmi)
					. += span_notice("There are wires which could be hooked up to an <b>MMI or positronic brain</b>, or <b>cut</b>.")
				else
					var/accept_laws = TRUE
					if(core_mmi.laws.id != DEFAULT_AI_LAWID || !core_mmi.brainmob || !core_mmi.brainmob?.mind)
						accept_laws = FALSE
					. += span_notice("There is a <b>slot</b> for a reinforced glass panel, the [AI_CORE_BRAIN(core_mmi)] could be <b>pried</b> out.[accept_laws ? " A law module can be <b>swiped</b> across." : ""]")
			if(GLASS_CORE)
				. += span_notice("The monitor [core_mmi?.brainmob?.mind && !suicide_check() ? "and neural interface " : ""]can be <b>screwed</b> in, the panel can be <b>pried</b> out.")
			if(AI_READY_CORE)
				. += span_notice("The monitor's connection can be <b>cut</b>[core_mmi?.brainmob?.mind && !suicide_check() ? " the neural interface can be <b>screwed</b> in." : "."]")

/obj/structure/ai_core/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == circuit)
		circuit = null
		if((state != GLASS_CORE) && (state != AI_READY_CORE))
			state = EMPTY_CORE
			update_appearance()
	if(gone == core_mmi)
		core_mmi = null
		update_appearance()

/obj/structure/ai_core/Destroy()
	QDEL_NULL(circuit)
	QDEL_NULL(core_mmi)
	QDEL_NULL(laws)
	return ..()

/obj/structure/ai_core/deactivated
	icon_state = "ai-empty"
	anchored = TRUE
	state = AI_READY_CORE

/obj/structure/ai_core/deactivated/Initialize(mapload, skip_mmi_creation = FALSE, posibrain = FALSE)
	. = ..()
	circuit = new(src)
	if(skip_mmi_creation)
		return
	if(posibrain)
		core_mmi = new/obj/item/mmi/posibrain(src, /* autoping = */ FALSE)
	else
		core_mmi = new(src)
		core_mmi.brain = new(core_mmi)
		core_mmi.update_appearance()

/obj/structure/ai_core/latejoin_inactive
	name = "networked AI core"
	desc = "This AI core is connected by bluespace transmitters to NTNet, allowing for an AI personality to be downloaded to it on the fly mid-shift."
	icon_state = "ai-empty"
	anchored = TRUE
	state = AI_READY_CORE
	var/available = TRUE
	var/safety_checks = TRUE
	var/active = TRUE

/obj/structure/ai_core/latejoin_inactive/Initialize(mapload)
	. = ..()
	circuit = new(src)
	core_mmi = new(src)
	core_mmi.brain = new(core_mmi)
	core_mmi.update_appearance()
	GLOB.latejoin_ai_cores += src

/obj/structure/ai_core/latejoin_inactive/Destroy()
	GLOB.latejoin_ai_cores -= src
	return ..()

/obj/structure/ai_core/latejoin_inactive/examine(mob/user)
	. = ..()
	. += "Its transmitter seems to be <b>[active? "on" : "off"]</b>."
	. += span_notice("You could [active? "deactivate" : "activate"] it with a multitool.")

/obj/structure/ai_core/latejoin_inactive/proc/is_available() //If people still manage to use this feature to spawn-kill AI latejoins ahelp them.
	if(!available)
		return FALSE
	if(!safety_checks)
		return TRUE
	if(!active)
		return FALSE
	var/turf/T = get_turf(src)
	var/area/A = get_area(src)
	if(!(A.area_flags & BLOBS_ALLOWED))
		return FALSE
	if(!A.power_equip)
		return FALSE
	if(!SSmapping.level_trait(T.z,ZTRAIT_STATION))
		return FALSE
	if(!isfloorturf(T))
		return FALSE
	return TRUE

/obj/structure/ai_core/latejoin_inactive/attackby(obj/item/P, mob/user, params)
	if(P.tool_behaviour == TOOL_MULTITOOL)
		active = !active
		to_chat(user, span_notice("You [active? "activate" : "deactivate"] \the [src]'s transmitters."))
		return
	return ..()

/obj/structure/ai_core/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/structure/ai_core/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(state == AI_READY_CORE)
		if(!core_mmi)
			balloon_alert(user, "no brain installed!")
			return TOOL_ACT_TOOLTYPE_SUCCESS
		else if(!core_mmi.brainmob?.mind || suicide_check())
			balloon_alert(user, "brain is inactive!")
			return TOOL_ACT_TOOLTYPE_SUCCESS
		else
			balloon_alert(user, "connecting neural network...")
			if(!tool.use_tool(src, user, 10 SECONDS))
				return TOOL_ACT_TOOLTYPE_SUCCESS
			if(!ai_structure_to_mob())
				return TOOL_ACT_TOOLTYPE_SUCCESS
			balloon_alert(user, "connected neural network")
			return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/structure/ai_core/attackby(obj/item/P, mob/living/user, params)
	if(!anchored)
		if(P.tool_behaviour == TOOL_WELDER)
			if(state != EMPTY_CORE)
				balloon_alert(user, "core must be empty to deconstruct it!")
				return

			if(!P.tool_start_check(user, amount=1))
				return

			balloon_alert(user, "deconstructing frame...")
			if(P.use_tool(src, user, 20, volume=50) && state == EMPTY_CORE)
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
			if(EMPTY_CORE)
				if(istype(P, /obj/item/circuitboard/aicore))
					if(!user.transferItemToLoc(P, src))
						return
					playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
					balloon_alert(user, "circuit board inserted")
					update_appearance()
					state = CIRCUIT_CORE
					circuit = P
					return
			if(CIRCUIT_CORE)
				if(P.tool_behaviour == TOOL_SCREWDRIVER)
					P.play_tool_sound(src)
					balloon_alert(user, "board screwed into place")
					state = SCREWED_CORE
					update_appearance()
					return
				if(P.tool_behaviour == TOOL_CROWBAR)
					P.play_tool_sound(src)
					balloon_alert(user, "circuit board removed")
					state = EMPTY_CORE
					circuit.forceMove(loc)
					return
			if(SCREWED_CORE)
				if(P.tool_behaviour == TOOL_SCREWDRIVER && circuit)
					P.play_tool_sound(src)
					balloon_alert(user, "circuit board unfastened")
					state = CIRCUIT_CORE
					update_appearance()
					return
				if(istype(P, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/C = P
					if(C.get_amount() >= 5)
						playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
						balloon_alert(user, "adding cables to frame...")
						if(do_after(user, 20, target = src) && state == SCREWED_CORE && C.use(5))
							balloon_alert(user, "added cables to frame.")
							state = CABLED_CORE
							update_appearance()
					else
						balloon_alert(user, "need five lengths of cable!")
					return
			if(CABLED_CORE)
				if(P.tool_behaviour == TOOL_WIRECUTTER)
					if(core_mmi)
						balloon_alert(user, "remove the [AI_CORE_BRAIN(core_mmi)] first!")
					else
						P.play_tool_sound(src)
						balloon_alert(user, "cables removed")
						state = SCREWED_CORE
						update_appearance()
						new /obj/item/stack/cable_coil(drop_location(), 5)
					return

				if(istype(P, /obj/item/stack/sheet/rglass))
					if(!core_mmi)
						balloon_alert(user, "add a brain first!")
						return
					var/obj/item/stack/sheet/rglass/G = P
					if(G.get_amount() >= 2)
						playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
						balloon_alert(user, "adding glass panel...")
						if(do_after(user, 20, target = src) && state == CABLED_CORE && G.use(2))
							balloon_alert(user, "added glass panel")
							state = GLASS_CORE
							update_appearance()
					else
						balloon_alert(user, "need two sheets of reinforced glass!")
					return

				if(istype(P, /obj/item/ai_module))
					if(!core_mmi)
						balloon_alert(user, "no brain installed!")
						return
					if(!core_mmi.brainmob || !core_mmi.brainmob?.mind || suicide_check())
						balloon_alert(user, "[AI_CORE_BRAIN(core_mmi)] is inactive!")
						return
					if(core_mmi.laws.id != DEFAULT_AI_LAWID)
						balloon_alert(user, "[AI_CORE_BRAIN(core_mmi)] already has set laws!")
						return
					var/obj/item/ai_module/module = P
					module.install(laws, user)
					return

				if(istype(P, /obj/item/mmi) && !core_mmi)
					var/obj/item/mmi/M = P
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

				if(P.tool_behaviour == TOOL_CROWBAR && core_mmi)
					P.play_tool_sound(src)
					balloon_alert(user, "removed [AI_CORE_BRAIN(core_mmi)]")
					core_mmi.forceMove(loc)
					return

			if(GLASS_CORE)
				if(P.tool_behaviour == TOOL_CROWBAR)
					P.play_tool_sound(src)
					balloon_alert(user, "removed glass panel")
					state = CABLED_CORE
					update_appearance()
					new /obj/item/stack/sheet/rglass(loc, 2)
					return

				if(P.tool_behaviour == TOOL_SCREWDRIVER)
					if(suicide_check())
						to_chat(user, span_warning("The brain installed is completely useless."))
						return
					P.play_tool_sound(src)
					balloon_alert(user, "connected monitor[core_mmi?.brainmob?.mind ? " and neural network" : ""]")
					if(core_mmi.brainmob?.mind)
						ai_structure_to_mob()
					else
						state = AI_READY_CORE
						update_appearance()
					return

			if(AI_READY_CORE)
				if(istype(P, /obj/item/aicard))
					return //handled by /obj/structure/ai_core/transfer_ai()

				if(P.tool_behaviour == TOOL_WIRECUTTER)
					P.play_tool_sound(src)
					balloon_alert(user, "disconnected monitor")
					state = GLASS_CORE
					update_appearance()
					return
	return ..()

/obj/structure/ai_core/proc/ai_structure_to_mob()
	var/mob/living/brain/the_brainmob = core_mmi.brainmob
	if(!the_brainmob.mind || suicide_check())
		return FALSE
	the_brainmob.mind.remove_antags_for_borging()
	if(!the_brainmob.mind.has_ever_been_ai)
		SSblackbox.record_feedback("amount", "ais_created", 1)
	var/mob/living/silicon/ai/ai_mob = null

	if(core_mmi.overrides_aicore_laws)
		ai_mob = new /mob/living/silicon/ai(loc, core_mmi.laws, the_brainmob)
		core_mmi.laws = null //MMI's law datum is being donated, so we need the MMI to let it go or the GC will eat it
	else
		ai_mob = new /mob/living/silicon/ai(loc, laws, the_brainmob)
		laws = null //we're giving the new AI this datum, so let's not delete it when we qdel(src) 5 lines from now

	var/datum/antagonist/malf_ai/malf_datum = IS_MALF_AI(ai_mob)
	if(malf_datum)
		malf_datum.add_law_zero()

	if(core_mmi.force_replace_ai_name)
		ai_mob.fully_replace_character_name(ai_mob.name, core_mmi.replacement_ai_name())
	if(core_mmi.braintype == "Android")
		ai_mob.posibrain_inside = TRUE
	deadchat_broadcast(" has been brought online at <b>[get_area_name(ai_mob, format_text = TRUE)]</b>.", span_name("[ai_mob]"), follow_target = ai_mob, message_type = DEADCHAT_ANNOUNCEMENT)
	qdel(src)
	return TRUE

/obj/structure/ai_core/update_icon_state()
	switch(state)
		if(EMPTY_CORE)
			icon_state = "0"
		if(CIRCUIT_CORE)
			icon_state = "1"
		if(SCREWED_CORE)
			icon_state = "2"
		if(CABLED_CORE)
			if(core_mmi)
				icon_state = "3b"
			else
				icon_state = "3"
		if(GLASS_CORE)
			icon_state = "4"
		if(AI_READY_CORE)
			icon_state = "ai-empty"
	return ..()

/obj/structure/ai_core/deconstruct(disassembled = TRUE)
	if(state >= GLASS_CORE)
		new /obj/item/stack/sheet/rglass(loc, 2)
	if(state >= CABLED_CORE)
		new /obj/item/stack/cable_coil(loc, 5)
	if(circuit)
		circuit.forceMove(loc)
		circuit = null
	new /obj/item/stack/sheet/plasteel(loc, 4)
	qdel(src)

/// Quick proc to call to see if the brainmob inside of us has suicided. Returns TRUE if we have, FALSE in any other scenario.
/obj/structure/ai_core/proc/suicide_check()
	if(isnull(core_mmi) || isnull(core_mmi.brainmob))
		return FALSE
	return HAS_TRAIT(core_mmi.brainmob, TRAIT_SUICIDED)

/*
This is a good place for AI-related object verbs so I'm sticking it here.
If adding stuff to this, don't forget that an AI need to cancel_camera() whenever it physically moves to a different location.
That prevents a few funky behaviors.
*/
//The type of interaction, the player performing the operation, the AI itself, and the card object, if any.


/atom/proc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	SHOULD_CALL_PARENT(TRUE)
	if(istype(card))
		if(card.flush)
			to_chat(user, span_alert("ERROR: AI flush is in progress, cannot execute transfer protocol."))
			return FALSE
	return TRUE

/obj/structure/ai_core/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(state != AI_READY_CORE || !..())
		return
	if(core_mmi && core_mmi.brainmob)
		if(core_mmi.brainmob.mind)
			to_chat(user, span_warning("[src] already contains an active mind!"))
			return
		else if(suicide_check())
			to_chat(user, span_warning("[AI_CORE_BRAIN(core_mmi)] installed in [src] is completely useless!"))
			return
	//Transferring a carded AI to a core.
	if(interaction == AI_TRANS_FROM_CARD)
		AI.control_disabled = FALSE
		AI.radio_enabled = TRUE
		AI.forceMove(loc) // to replace the terminal.
		to_chat(AI, span_notice("You have been uploaded to a stationary terminal. Remote device connection restored."))
		to_chat(user, "[span_boldnotice("Transfer successful")]: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
		card.AI = null
		AI.battery = circuit.battery
		if(core_mmi && core_mmi.braintype == "Android")
			AI.posibrain_inside = TRUE
		else
			AI.posibrain_inside = FALSE
		qdel(src)
	else //If for some reason you use an empty card on an empty AI terminal.
		to_chat(user, span_alert("There is no AI loaded on this terminal."))

/obj/item/circuitboard/aicore
	name = "AI core (AI Core Board)" //Well, duh, but best to be consistent
	var/battery = 200 //backup battery for when the AI loses power. Copied to/from AI mobs when carding, and placed here to avoid recharge via deconning the core

#undef AI_CORE_BRAIN
