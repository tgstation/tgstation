/// Ratwood's surgical tools (surgery/surgery_tools_rogue.dm). The porter brings them as weapons; here they get the tool
/// behaviour each step of surgery asks for (combat/surgery/steps.dm), and the surgical flag of Ratwood's Initialize(): out of
/// combat a surgical tool that finds nothing to do on a body does not strike it (TG's perform_surgery()). The cautery sears
/// only while it is hot from a fire; the Pestran multitool unfolds into whichever tool the surgeon picks.

/// The sound of a cautery put to the fire (Ratwood firelight.ogg).
#define ROGUE_CAUTERY_HEAT_SOUND 'modular_redtard/rockhill/sound/items/firelight.ogg'

/obj/item/rogueweapon/surgery/Initialize(mapload)
	. = ..()
	item_flags |= SURGICAL_TOOL

/obj/item/rogueweapon/surgery/scalpel
	tool_behaviour = TOOL_SCALPEL

/// Ratwood's crude stone scalpel: an improvised blade, sharp enough to cut where a scalpel would.
/obj/item/rogueweapon/surgery/scalpel/improv
	tool_behaviour = ROGUE_TOOL_IMPROVISED_SCALPEL

/// Both saws, the improvised one too (Ratwood gives it TOOL_SAW).
/obj/item/rogueweapon/surgery/saw
	tool_behaviour = TOOL_SAW

/obj/item/rogueweapon/surgery/hemostat
	tool_behaviour = TOOL_HEMOSTAT

/obj/item/rogueweapon/surgery/hemostat/improv
	tool_behaviour = ROGUE_TOOL_IMPROVISED_HEMOSTAT

/obj/item/rogueweapon/surgery/retractor
	tool_behaviour = TOOL_RETRACTOR

/obj/item/rogueweapon/surgery/retractor/improv
	tool_behaviour = ROGUE_TOOL_IMPROVISED_RETRACTOR

/obj/item/rogueweapon/surgery/bonesetter
	tool_behaviour = TOOL_BONESET

/// Ratwood's cautery iron, and the branding irons made from it: cold it is a club; held to a lit fire with the use intent it
/// heats up for a while, sears (TOOL_CAUTERY), burns what it strikes and glows.
/obj/item/rogueweapon/surgery/cautery
	/// Ratwood heated: hot from a fire, until it cools.
	var/rogue_heated = FALSE

/// Ratwood pre_attack(): the cautery is held to a lit fire, a forge, a hearth or a brazier, with the use intent.
/obj/item/rogueweapon/surgery/cautery/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/machinery/light/rogue) || !istype(user.rogue_active_intent(), /datum/intent/use))
		return ..()
	var/obj/machinery/light/rogue/fire = interacting_with
	if(!fire.lit)
		return ..()
	user.visible_message(span_info("[user] heats [src]."), span_info("I heat [src]."))
	rogue_heat(rogue_value("surgery_cautery_heat_time"))
	return ITEM_INTERACT_SUCCESS

/// Ratwood fire_act(): hot for the time, the cooling timer started over.
/obj/item/rogueweapon/surgery/cautery/proc/rogue_heat(duration)
	if(!rogue_heated)
		playsound(src, ROGUE_CAUTERY_HEAT_SOUND, 100, TRUE)
	rogue_set_heated(TRUE)
	addtimer(CALLBACK(src, PROC_REF(rogue_set_heated), FALSE), duration, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_DELETE_ME)

/// Ratwood update_heated(): a hot iron sears and burns, a cold one is only an iron.
/obj/item/rogueweapon/surgery/cautery/proc/rogue_set_heated(heated)
	rogue_heated = heated
	tool_behaviour = heated ? TOOL_CAUTERY : null
	damtype = heated ? BURN : BRUTE
	update_appearance(UPDATE_OVERLAYS)

/obj/item/rogueweapon/surgery/cautery/get_temperature()
	if(rogue_heated)
		return FIRE_MINIMUM_TEMPERATURE_TO_SPREAD
	return ..()

/// The glowing tip ("<state>_hot"), over the iron so that its held sprite stays the baked one.
/obj/item/rogueweapon/surgery/cautery/update_overlays()
	. = ..()
	if(rogue_heated && icon_exists(icon, "[icon_state]_hot"))
		. += mutable_appearance(icon, "[icon_state]_hot")

/obj/item/rogueweapon/surgery/cautery/examine(mob/user)
	. = ..()
	if(rogue_heated)
		. += span_warning("The tip is hot to the touch.")

/// Ratwood's Pestran surgical multitool (modular/churchloop/artefactsten.dm): used in hand it unfolds into a scalpel, a saw,
/// forceps, a speculum, bone forceps or a cautery, with that tool's force and intents. Its suture is not ported: the module's
/// needle sews (combat/medicine.dm).
/obj/item/rogueweapon/surgery/multitool
	tool_behaviour = TOOL_SCALPEL
	/// The tool it is unfolded into, a key of GLOB.rogue_multitool_modes.
	var/rogue_mode = "scalpel"

/// Ratwood _mode_params: tool behaviour, force, damage type and intents of each mode, in its order.
GLOBAL_LIST_INIT(rogue_multitool_modes, list(
	"scalpel" = list(TOOL_SCALPEL, 12, BRUTE, list(/datum/intent/dagger/cut, /datum/intent/dagger/thrust)),
	"saw" = list(TOOL_SAW, 16, BRUTE, list(/datum/intent/dagger/cut, /datum/intent/dagger/chop/cleaver)),
	"hemostat" = list(TOOL_HEMOSTAT, 6, BRUTE, list(/datum/intent/use)),
	"retractor" = list(TOOL_RETRACTOR, 6, BRUTE, list(/datum/intent/use)),
	"bonesetter" = list(TOOL_BONESET, 8, BRUTE, list(/datum/intent/use)),
	"cautery" = list(TOOL_CAUTERY, 8, BURN, list(/datum/intent/use, /datum/intent/mace/strike, /datum/intent/mace/smash)),
))

/obj/item/rogueweapon/surgery/multitool/Initialize(mapload)
	. = ..()
	rogue_apply_mode(rogue_mode)

/// Ratwood attack_self(): the surgeon picks the tool it unfolds into.
/obj/item/rogueweapon/surgery/multitool/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	INVOKE_ASYNC(src, PROC_REF(rogue_pick_mode), user)
	return TRUE

/obj/item/rogueweapon/surgery/multitool/proc/rogue_pick_mode(mob/user)
	var/choice = tgui_input_list(user, "Unfold into which tool?", name, GLOB.rogue_multitool_modes, rogue_mode)
	if(!choice || choice == rogue_mode || QDELETED(src) || !user.is_holding(src))
		return
	rogue_apply_mode(choice)
	playsound(src, 'sound/machines/click.ogg', 50, FALSE)
	to_chat(user, span_notice("Multitool mode: [uppertext(choice)]."))
	if(isliving(user))
		var/mob/living/surgeon = user
		surgeon.rogue_refresh_intents()

/// Ratwood _apply_mode(): the tool, force, damage and intents of the mode.
/obj/item/rogueweapon/surgery/multitool/proc/rogue_apply_mode(mode)
	var/list/params = GLOB.rogue_multitool_modes[mode]
	if(!params)
		return
	rogue_mode = mode
	tool_behaviour = params[1]
	force = params[2]
	damtype = params[3]
	var/list/intents = params[4]
	possible_item_intents = intents.Copy()
	name = "[initial(name)] ([mode])"

/obj/item/rogueweapon/surgery/multitool/get_temperature()
	if(rogue_mode == "cautery")
		return FIRE_MINIMUM_TEMPERATURE_TO_SPREAD
	return ..()

#undef ROGUE_CAUTERY_HEAT_SOUND
