/obj/item/var/firefuel = 0

GLOBAL_LIST_EMPTY(rockhill_lit_fires)

/obj/machinery/light/rogue
	var/base_state
	var/fueluse = 0
	var/no_refuel = FALSE
	var/crossfire = TRUE
	var/status = LIGHT_OK
	var/lit = FALSE
	var/burn_started = 0
	var/burn_timer

/obj/machinery/light/rogue/Initialize(mapload)
	. = ..()
	if(fueluse > 0)
		fueluse -= round(rand(fueluse * ROCKHILL_FIRE_SPENT_MIN, fueluse * ROCKHILL_FIRE_SPENT_MAX))
	if(crossfire)
		var/static/list/loc_connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_entered))
		AddElement(/datum/element/connect_loc, loc_connections)
	if(status != LIGHT_OK || !ignite(silent = TRUE))
		set_light_on(FALSE)
		update_appearance(UPDATE_ICON_STATE)

/obj/machinery/light/rogue/Destroy()
	deltimer(burn_timer)
	GLOB.rockhill_lit_fires -= src
	return ..()

/obj/machinery/light/rogue/proc/endless()
	return initial(fueluse) <= 0

/obj/machinery/light/rogue/proc/fuel_left()
	if(endless())
		return INFINITY
	if(lit)
		return max(fueluse - (world.time - burn_started), 0)
	return fueluse

/obj/machinery/light/rogue/proc/shows_fuel()
	return !endless()

/obj/machinery/light/rogue/proc/can_ignite()
	return !lit && fuel_left() > 0

/obj/machinery/light/rogue/proc/ignite(silent = FALSE)
	if(!can_ignite())
		return FALSE
	lit = TRUE
	burn_started = world.time
	GLOB.rockhill_lit_fires += src
	set_light_on(TRUE)
	update_appearance(UPDATE_ICON_STATE)
	schedule_burn_out()
	if(!silent)
		playsound(src, ROCKHILL_FIRE_LIGHT_SOUND, 100, TRUE)
	return TRUE

/obj/machinery/light/rogue/proc/schedule_burn_out()
	deltimer(burn_timer)
	burn_timer = null
	var/left = fuel_left()
	if(left != INFINITY)
		burn_timer = addtimer(CALLBACK(src, PROC_REF(burn_out)), left, TIMER_STOPPABLE | TIMER_DELETE_ME)

/obj/machinery/light/rogue/proc/burn_out(silent = FALSE)
	if(!lit)
		return FALSE
	if(!endless())
		fueluse = fuel_left()
	lit = FALSE
	GLOB.rockhill_lit_fires -= src
	deltimer(burn_timer)
	burn_timer = null
	set_light_on(FALSE)
	update_appearance(UPDATE_ICON_STATE)
	if(!silent)
		playsound(src, ROCKHILL_FIRE_SNUFF_SOUND, 100, TRUE)
	return TRUE

/obj/machinery/light/rogue/proc/snuff(mob/user)
	if(!burn_out())
		return FALSE
	user?.visible_message(span_warning("[user] snuffs [src]."))
	return TRUE

/obj/machinery/light/rogue/proc/add_fuel(amount)
	var/left = fuel_left()
	if(lit)
		fueluse = min(left + amount, initial(fueluse))
		burn_started = world.time
		schedule_burn_out()
	else
		fueluse = min(left + amount, initial(fueluse))

/obj/machinery/light/rogue/update_icon_state()
	. = ..()
	if(base_state)
		set_fire_state("[base_state][lit ? 1 : 0]")

/obj/machinery/light/rogue/proc/set_fire_state(state)
	if(icon_exists(icon, state))
		icon_state = state

/obj/machinery/light/rogue/examine(mob/user)
	. = ..()
	if(!shows_fuel() || !user.Adjacent(src))
		return
	var/left = fuel_left()
	if(left <= 0)
		. += span_warning("The fire is burned out and hungry...")
		return
	var/minutes = round(left / (1 MINUTES))
	. += span_info("The fire will last for [minutes <= 1 ? "less than a minute" : "[minutes] minutes"].")

/obj/machinery/light/rogue/fire_act(exposed_temperature, exposed_volume)
	ignite()

/obj/machinery/light/rogue/extinguish()
	. = ..()
	if(burn_out())
		new /obj/effect/temp_visual/small_smoke(loc)

/obj/machinery/light/rogue/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(!lit || !isliving(arrived))
		return
	var/mob/living/victim = arrived
	victim.adjust_fire_stacks(ROCKHILL_FIRE_CROSS_STACKS)
	victim.ignite_mob()

/obj/machinery/light/rogue/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/flashlight/flare))
		var/obj/item/flashlight/flare/flare = tool
		if(lit && !flare.light_on)
			if(flare.ignition(user) == ROCKHILL_FLARE_IGNITED)
				user.visible_message(span_info("[user] lights [flare] in [src]."))
			return ITEM_INTERACT_SUCCESS
	if(!lit && tool.get_temperature())
		if(ignite())
			user.visible_message(span_info("[user] lights [src]."))
		else
			balloon_alert(user, "won't light!")
		return ITEM_INTERACT_SUCCESS
	if(lit && istype(tool, /obj/item/natural/dirtclod))
		if(!user.temporarilyRemoveItemFromInventory(tool))
			return ITEM_INTERACT_BLOCKING
		qdel(tool)
		snuff(user)
		return ITEM_INTERACT_SUCCESS
	if(tool.firefuel && !no_refuel && !endless())
		return try_refuel(user, tool)
	return ..()

/obj/machinery/light/rogue/proc/try_refuel(mob/living/user, obj/item/fuel)
	if(fuel_left() > initial(fueluse) - ROCKHILL_FIRE_FULL_MARGIN)
		balloon_alert(user, "fully fueled")
		return ITEM_INTERACT_BLOCKING
	if(tgui_alert(user, "Fuel [src] with [fuel]?", "Fuel", list("Yes", "No")) != "Yes")
		return ITEM_INTERACT_BLOCKING
	if(QDELETED(fuel) || user.get_active_held_item() != fuel || !user.Adjacent(src))
		return ITEM_INTERACT_BLOCKING
	if(!user.temporarilyRemoveItemFromInventory(fuel))
		return ITEM_INTERACT_BLOCKING
	user.visible_message(span_warning("[user] feeds [fuel] to [src]."))
	add_fuel(fuel.firefuel)
	qdel(fuel)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/light/rogue/candle/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !lit)
		return
	return snuff(user)

/obj/machinery/light/rogue/chand/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !lit)
		return
	return snuff(user)

/obj/machinery/light/rogue/campfire/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !lit || !user.can_perform_action(src))
		return
	snuff(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/light/rogue/campfire/rogue_onkick(mob/living/carbon/human/kicker)
	if(lit)
		snuff(kicker)

/obj/machinery/light/rogue/firebowl/standing
	var/knocked_over = FALSE

/obj/machinery/light/rogue/firebowl/standing/can_ignite()
	return !knocked_over && ..()

/obj/machinery/light/rogue/firebowl/standing/update_icon_state()
	. = ..()
	if(knocked_over)
		set_fire_state("[base_state]over")

/obj/machinery/light/rogue/firebowl/standing/rogue_onkick(mob/living/carbon/human/kicker)
	playsound(src, ROCKHILL_FIRE_KICK_SOUND, 100, TRUE)
	if(knocked_over || !prob(kicker.rogue_stat(ROGUE_STAT_STRENGTH) * ROCKHILL_FIRE_TOPPLE_PER_STRENGTH))
		kicker.visible_message(span_warning("[kicker] kicks [src]!"))
		return
	kicker.visible_message(span_warning("[kicker] kicks over [src]!"))
	knocked_over = TRUE
	if(!burn_out())
		update_appearance(UPDATE_ICON_STATE)

/obj/machinery/light/rogue/firebowl/standing/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !knocked_over)
		return
	user.visible_message(span_notice("[user] starts to pick up [src]..."))
	if(!do_after(user, ROCKHILL_FIRE_RAISE_TIME, target = src) || !knocked_over)
		return TRUE
	knocked_over = FALSE
	update_appearance(UPDATE_ICON_STATE)
	return TRUE

/obj/machinery/light/rogue/torchholder
	var/obj/item/flashlight/flare/torch/torch
	var/torch_off_state = "torchwall0"

/obj/machinery/light/rogue/torchholder/Initialize(mapload)
	torch = new(src)
	return ..()

/obj/machinery/light/rogue/torchholder/Destroy()
	QDEL_NULL(torch)
	return ..()

/obj/machinery/light/rogue/torchholder/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone != torch)
		return
	burn_out(silent = TRUE)
	torch = null
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/light/rogue/torchholder/endless()
	return FALSE

/obj/machinery/light/rogue/torchholder/fuel_left()
	if(!torch)
		return 0
	if(lit)
		return max(torch.fuel - (world.time - burn_started), 0)
	return torch.fuel

/obj/machinery/light/rogue/torchholder/burn_out(silent = FALSE)
	if(lit && torch)
		torch.fuel = fuel_left()
		burn_started = world.time
	return ..()

/obj/machinery/light/rogue/torchholder/shows_fuel()
	return !!torch

/obj/machinery/light/rogue/torchholder/add_fuel(amount)
	return

/obj/machinery/light/rogue/torchholder/update_icon_state()
	. = ..()
	if(!torch)
		set_fire_state(base_state)
	else if(!lit)
		set_fire_state(torch_off_state)

/obj/machinery/light/rogue/torchholder/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !torch)
		return
	var/was_lit = lit
	var/obj/item/flashlight/flare/torch/taken = torch
	burn_out(silent = TRUE)
	if(!user.put_in_hands(taken))
		taken.forceMove(drop_location())
	if(was_lit)
		taken.ignition()
	playsound(src, ROCKHILL_TORCH_TAKE_SOUND, 70, TRUE)
	return TRUE

/obj/machinery/light/rogue/torchholder/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/flashlight/flare/torch))
		return ..()
	var/obj/item/flashlight/flare/torch/held = tool
	if(torch)
		if(held.light_on && !lit)
			if(ignite())
				user.visible_message(span_info("[user] lights [src]."))
			else
				balloon_alert(user, "burned out!")
			return ITEM_INTERACT_SUCCESS
		if(!held.light_on && lit && held.ignition(user) == ROCKHILL_FLARE_IGNITED)
			user.visible_message(span_info("[user] lights [held] in [src]."))
		return ITEM_INTERACT_SUCCESS
	var/was_lit = held.light_on
	if(!user.transferItemToLoc(held, src))
		return ITEM_INTERACT_BLOCKING
	if(was_lit)
		held.turn_off()
		STOP_PROCESSING(SSobj, held)
	torch = held
	if(!was_lit || !ignite(silent = TRUE))
		update_appearance(UPDATE_ICON_STATE)
	playsound(src, ROCKHILL_TORCH_PUT_SOUND, 70, TRUE)
	return ITEM_INTERACT_SUCCESS

/// Ratwood's torch (flashlight.dm): a flame lights it - a fire, a lit torch, a spark (fire_act()) - and using it in hand
/// only snuffs a lit one. TG's flare lights itself in hand and never goes out from it.
/obj/item/flashlight/flare/torch/attack_self(mob/user)
	if(!rogue_combat_enabled())
		return ..()
	if(!fuel)
		to_chat(user, span_warning("[src] doesn't have any pitch left!"))
		return
	if(!light_on)
		to_chat(user, span_warning("I need a flame to light [src]."))
		return
	turn_off()
	playsound(src, 'modular_redtard/rockhill/sound/items/firesnuff.ogg', 100, TRUE)
	user.visible_message(span_notice("[user] snuffs out [src]."), span_notice("I snuff out [src]."))

/// Anything hot lights an unlit torch: a lit torch held to it, as Ratwood's lit torch sets what it touches alight.
/obj/item/flashlight/flare/torch/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!rogue_combat_enabled() || light_on || !tool.get_temperature())
		return ..()
	if(ignition(user) == ROCKHILL_FLARE_IGNITED)
		playsound(src, 'modular_redtard/rockhill/sound/items/firelight.ogg', 100, TRUE)
		user.visible_message(span_info("[user] lights [src] with [tool]."))
	return ITEM_INTERACT_SUCCESS

// --- Candles

/// Ratwood's candles (items/candle.dm): a lit candle gives a small fire's light and burns its wax down to a stub. A flame
/// lights it - a torch, a fire, another candle, a spark - and using it in hand snuffs it; running over one on the floor
/// tramples it out. Candlesticks and skull, silver and Eora's candles never burn down. Ratwood's open_flame() each tick is left
/// out: on the medieval maps there is no gas for it to set alight.
/obj/item/candle
	heat = 1000
	light_range = 3
	light_power = 1
	light_color = LIGHT_COLOR_FIRE
	light_on = FALSE
	/// Ratwood wax: what is left to burn, in Ratwood's two-second ticks; candle_wax when made.
	var/wax = 0
	var/lit = FALSE
	/// Ratwood infinite: it never burns down.
	var/infinite = FALSE
	/// Ratwood start_lit: lit when made (the map's lit candles).
	var/start_lit = FALSE
	/// The icon state of a candle whose look does not melt (Ratwood's own update_icon() of the candlesticks and the skull, gold
	/// and silver candles), "_lit" added while lit; a candle without it shows how far its wax has burned.
	var/candle_state
	/// Which of Ratwood's three looks of burning wax the candle has, 1 (whole) to 3 (nearly gone).
	var/wax_look = 1

/obj/item/candle/lit
	start_lit = TRUE

/obj/item/candle/yellow/lit
	start_lit = TRUE

/obj/item/candle/eora
	infinite = TRUE
	light_color = "#ff13d8"

/obj/item/candle/eora/lit
	start_lit = TRUE

/obj/item/candle/infinite
	infinite = TRUE
	start_lit = TRUE

/obj/item/candle/skull
	infinite = TRUE
	candle_state = "skullcandle"

/obj/item/candle/skull/lit
	start_lit = TRUE

/obj/item/candle/candlestick
	infinite = TRUE

/obj/item/candle/candlestick/gold
	candle_state = "gcandelabra"

/obj/item/candle/candlestick/gold/lit
	start_lit = TRUE

/obj/item/candle/candlestick/gold/single
	candle_state = "singlegcandelabra"

/obj/item/candle/candlestick/gold/single/lit
	start_lit = TRUE

/obj/item/candle/candlestick/silver
	candle_state = "scandelabra"

/obj/item/candle/candlestick/silver/lit
	start_lit = TRUE

/obj/item/candle/candlestick/silver/single/lit
	candle_state = "singlescandelabra"
	start_lit = TRUE

/obj/item/candle/gold/lit
	candle_state = "gcandle"
	start_lit = TRUE

/obj/item/candle/silver/lit
	infinite = TRUE
	candle_state = "scandle"
	start_lit = TRUE

/obj/item/candle/Initialize(mapload)
	. = ..()
	wax = rogue_value("candle_wax")
	var/static/list/loc_connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_trampled))
	AddElement(/datum/element/connect_loc, loc_connections)
	if(!start_lit || !light_candle())
		update_appearance(UPDATE_ICON_STATE)

/obj/item/candle/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/candle/update_icon_state()
	. = ..()
	icon_state = candle_state ? "[candle_state][lit ? "_lit" : ""]" : "candle[wax_look][lit ? "_lit" : ""]"

/obj/item/candle/get_temperature()
	return lit ? ..() : 0

/// Ratwood light(): the candle catches and glows; one that does not last forever starts burning its wax.
/obj/item/candle/proc/light_candle()
	if(lit || (!infinite && wax <= 0))
		return FALSE
	lit = TRUE
	set_light_on(TRUE)
	update_appearance(UPDATE_ICON_STATE)
	if(!infinite)
		START_PROCESSING(SSobj, src)
	return TRUE

/// Ratwood put_out_candle().
/obj/item/candle/proc/put_out_candle()
	if(!lit)
		return FALSE
	lit = FALSE
	set_light_on(FALSE)
	STOP_PROCESSING(SSobj, src)
	update_appearance(UPDATE_ICON_STATE)
	return TRUE

/// Ratwood process(): the wax burns a tick at a time, the candle melting by thirds, and the last of it leaves a stub.
/obj/item/candle/process(seconds_per_tick)
	if(!lit || infinite)
		return PROCESS_KILL
	wax = max(wax - seconds_per_tick * rogue_value("candle_wax_per_second"), 0)
	if(wax <= 0)
		burn_down()
		return PROCESS_KILL
	update_wax_look()

/// Ratwood update_icon(): whole above 750 wax, half burned above 400, nearly gone below.
/obj/item/candle/proc/update_wax_look()
	var/look = wax > rogue_value("candle_wax_full") ? 1 : (wax > rogue_value("candle_wax_half") ? 2 : 3)
	if(look == wax_look)
		return
	wax_look = look
	update_appearance(UPDATE_ICON_STATE)

/// Ratwood process() at the end of the wax: a melted stub is left where the candle was, in the hand that held it.
/obj/item/candle/proc/burn_down()
	var/mob/holder = ismob(loc) ? loc : null
	var/obj/item/trash/candle/stub = new(drop_location())
	stub.icon = icon
	qdel(src)
	holder?.put_in_hands(stub)

/// Ratwood attack_self(): using a lit candle in hand snuffs it; an unlit one needs a flame.
/obj/item/candle/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	if(put_out_candle())
		playsound(src, ROCKHILL_FIRE_SNUFF_SOUND, 50, TRUE)
		user.visible_message(span_notice("[user] snuffs [src]."), span_notice("I snuff [src]."))
	else
		to_chat(user, span_warning("I need a flame to light [src]."))
	return TRUE

/// A flame held to an unlit candle lights it: a torch, another candle, a burning pipe.
/obj/item/candle/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(lit || !tool.get_temperature())
		return ..()
	if(light_candle())
		user.visible_message(span_info("[user] lights [src] with [tool]."), span_info("I light [src] with [tool]."))
	return ITEM_INTERACT_SUCCESS

/// An unlit candle held to a flame catches from it: a lit fire, sconce or wall candle, or a burning thing.
/obj/item/candle/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(lit)
		return NONE
	var/burning = FALSE
	if(istype(interacting_with, /obj/machinery/light/rogue))
		var/obj/machinery/light/rogue/fire = interacting_with
		burning = fire.lit
	else if(isitem(interacting_with))
		var/obj/item/flame = interacting_with
		burning = flame.get_temperature()
	if(!burning)
		return NONE
	if(light_candle())
		user.visible_message(span_info("[user] lights [src] from [interacting_with]."), span_info("I light [src] from [interacting_with]."))
	return ITEM_INTERACT_SUCCESS

/obj/item/candle/fire_act(exposed_temperature, exposed_volume)
	if(!lit && light_candle())
		return TRUE
	return ..()

/// Ratwood candle spark_act(): a spark lights a candle.
/obj/item/candle/spark_act()
	fire_act()

/obj/item/candle/extinguish()
	. = ..()
	put_out_candle()

/// Ratwood Crossed(): someone running over a candle on the floor tramples it out, its wax squashed nearly to the end.
/obj/item/candle/proc/on_trampled(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(!isturf(loc) || !ishuman(arrived))
		return
	var/mob/living/carbon/human/runner = arrived
	if(runner.move_intent != MOVE_INTENT_RUN)
		return
	if(!infinite)
		wax = min(wax, rogue_value("candle_trampled_wax"))
		update_wax_look()
	put_out_candle()
