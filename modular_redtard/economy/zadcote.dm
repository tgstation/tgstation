/**
 * ZADCOTE (Ratwood code/modules/roguetown/roguemachine/zadcote/, Azure Peak's crow-post): the bird mail of the merchant, the
 * stewardry and the bathhouse. A zadcote keeps a reserve of carrier zads and up to ten zadlinks, each bonded to a zadcage that a
 * person carries on the belt. Its operators send zads to a cage with a message and a parcel light enough for the zads (one zad
 * a small thing, two a pouch, three something bulky) or, once in five minutes, with bottle bombs that fall on the cage's
 * holder. The zad waits at the cage a few minutes: its holder takes the parcel, writes a reply, hands it something to carry
 * and sends it home, or it flies home empty. The holder may also summon zads to the cage. On every way home a zad may die of
 * exhaustion. The merchant's and the bathhouse's cotes take coin for scrying: an operator looks through the eyes of a bonded
 * zad for a while. Packs of trained zads restock the reserve, bottle bombs fill its crate.
 *
 * The zadcage (Ratwood /obj/item/zadcage) and the pack of zads (/obj/item/zadpack) are Ratwood items the porter has not brought
 * yet; the cote finds them by path once it does. A cage's behaviour lives on the rogue_zadcage component the cote gives it.
 * Ratwood's zads drawn flying over the map are not ported: the cote and the cage tell of them in words and sounds.
 */

#define ZAD_CAGE_PATH "/obj/item/zadcage"
#define ZAD_PACK_PATH "/obj/item/zadpack"
#define ZAD_OUTBOUND "outbound"
#define ZAD_RETURN "return"
#define ZAD_SOUND_FLY 'modular_redtard/economy/sound/birdfly.ogg'
#define ZAD_SOUND_CAW pick('modular_redtard/economy/sound/crow1.ogg', 'modular_redtard/economy/sound/crow2.ogg', 'modular_redtard/economy/sound/crow3.ogg')
#define ZAD_TIER_MIN 1
#define ZAD_TIER_MAX 3

/// The heaviest parcel a flight of zads carries (Ratwood zad_max_weight_for_tier()).
/proc/rogue_zad_max_weight(zads)
	switch(zads)
		if(1)
			return WEIGHT_CLASS_SMALL
		if(2)
			return WEIGHT_CLASS_NORMAL
	return WEIGHT_CLASS_BULKY

/// A slot of a zadcote bonded to one zadcage (Ratwood /datum/zadlink).
/datum/rogue_zadlink
	var/datum/weakref/cote_ref
	var/slot_index
	var/display_name = ""
	var/datum/weakref/cage_ref
	var/severed = FALSE
	var/datum/weakref/flight_ref
	/// The holder may call zads to the cage.
	var/allow_summons = TRUE

/datum/rogue_zadlink/New(obj/item/roguemachine/zadcote/cote, index)
	cote_ref = WEAKREF(cote)
	slot_index = index

/datum/rogue_zadlink/proc/label()
	return length(display_name) ? display_name : "Slot [slot_index]"

/datum/rogue_zadlink/proc/cage()
	return cage_ref?.resolve()

/datum/rogue_zadlink/proc/flight()
	return flight_ref?.resolve()

/datum/rogue_zadlink/proc/cage_component()
	var/obj/item/cage = cage()
	return cage?.GetComponent(/datum/component/rogue_zadcage)

/// A flight of zads to a cage or home (Ratwood /datum/zad_flight).
/datum/rogue_zad_flight
	var/datum/weakref/cote_ref
	var/datum/weakref/link_ref
	var/direction = ZAD_OUTBOUND
	var/zads = 1
	var/message = ""
	var/list/obj/item/payload = list()
	var/bombs = 0
	var/bomb_caw = ""
	var/launch_time
	var/arrival_time
	var/turnback_checked = FALSE
	var/sender_ckey
	/// Zads that will die on the way home.
	var/lost = 0

/datum/rogue_zad_flight/New(obj/item/roguemachine/zadcote/cote, datum/rogue_zadlink/link, zads, message, list/items, bombs)
	cote_ref = WEAKREF(cote)
	link_ref = WEAKREF(link)
	src.zads = clamp(zads, ZAD_TIER_MIN, ZAD_TIER_MAX)
	src.message = message || ""
	src.bombs = clamp(bombs, 0, ZAD_TIER_MAX)
	for(var/obj/item/parcel as anything in items)
		parcel.forceMove(cote)
		payload += parcel
	launch_time = world.time
	var/landing = src.bombs ? rand(rogue_value("machines_zad_bomb_landing_min"), rogue_value("machines_zad_bomb_landing_max")) : rogue_value("machines_zad_landing_time")
	arrival_time = world.time + rogue_value("machines_zad_outbound_time") + landing

/datum/rogue_zad_flight/Destroy()
	payload.Cut()
	return ..()

/datum/rogue_zad_flight/proc/target_link()
	return link_ref?.resolve()

/datum/rogue_zad_flight/proc/drop_payload(turf/spot)
	for(var/obj/item/parcel as anything in payload)
		if(!QDELETED(parcel))
			parcel.forceMove(spot)
	payload.Cut()

/obj/item/roguemachine/zadcote
	anchored = TRUE
	w_class = WEIGHT_CLASS_GIGANTIC
	var/faction = "merchant"
	var/motto = "ZADCOTE"
	var/list/operator_jobs = list()
	var/operator_trait
	var/list/datum/rogue_zadlink/slots = list()
	var/list/datum/rogue_zad_flight/outbound = list()
	var/list/datum/rogue_zad_flight/returning = list()
	var/reserve = 0
	var/bomb_stock = 0
	var/bomb_cooldown_until = 0
	/// Takes coin for scrying through a zad's eyes.
	var/allows_voyeur = FALSE
	var/voyeur_fund = 0
	/// Newest first: what flew out and what came home (Ratwood mail_log).
	var/list/mail_log = list()

/obj/item/roguemachine/zadcote/Initialize(mapload)
	. = ..()
	reserve = rogue_value("machines_zad_reserve_start")
	for(var/i in 1 to rogue_value("machines_zad_slots"))
		slots += new /datum/rogue_zadlink(src, i)
	START_PROCESSING(SSobj, src)
	addtimer(CALLBACK(src, PROC_REF(spawn_starter_cages)), 1)

/obj/item/roguemachine/zadcote/Destroy()
	STOP_PROCESSING(SSobj, src)
	var/turf/spot = drop_location()
	for(var/datum/rogue_zad_flight/flight as anything in outbound + returning)
		flight.drop_payload(spot)
	for(var/datum/rogue_zadlink/link as anything in slots)
		sever_link(link)
	QDEL_LIST(outbound)
	QDEL_LIST(returning)
	QDEL_LIST(slots)
	return ..()

/// Ratwood spawn_starter_cages(): a cage for every slot lies at the cote, bonded and ready (once the cage is ported).
/obj/item/roguemachine/zadcote/proc/spawn_starter_cages()
	var/cage_type = text2path(ZAD_CAGE_PATH)
	if(!cage_type)
		return
	for(var/datum/rogue_zadlink/link as anything in slots)
		if(!link.cage())
			attach_cage(new cage_type(drop_location()))

/obj/item/roguemachine/zadcote/examine(mob/user)
	. = ..()
	. += span_notice(motto)
	. += span_info("Reserve: [reserve] zads. Flights: [flight_count()] / [rogue_value("machines_zad_flight_cap")].")
	if(bomb_stock)
		. += span_info("Bombs stored: [bomb_stock] / [rogue_value("machines_zad_bomb_stock_cap")].")
	if(allows_voyeur)
		. += span_info("Its scrying basin holds [voyeur_fund] mammons.")

/obj/item/roguemachine/zadcote/proc/is_operator(mob/user)
	if(!ishuman(user))
		return FALSE
	return (user.mind?.assigned_role?.title in operator_jobs) || (operator_trait && HAS_TRAIT(user, operator_trait))

/obj/item/roguemachine/zadcote/proc/flight_count()
	return length(outbound) + length(returning)

/obj/item/roguemachine/zadcote/proc/restock(amount)
	reserve = min(reserve + amount, rogue_value("machines_zad_reserve_cap"))

/obj/item/roguemachine/zadcote/proc/find_slot(index)
	index = text2num(index)
	return (index >= 1 && index <= length(slots)) ? slots[index] : null

/// Bonds an unbonded cage to the first free slot, or to a severed one (Ratwood attach_cage()).
/obj/item/roguemachine/zadcote/proc/attach_cage(obj/item/cage, mob/user)
	var/datum/component/rogue_zadcage/bond = cage.GetComponent(/datum/component/rogue_zadcage)
	if(bond?.cote())
		if(user)
			to_chat(user, span_warning("This zadcage is already bonded elsewhere."))
		return FALSE
	var/datum/rogue_zadlink/free
	for(var/datum/rogue_zadlink/link as anything in slots)
		if(!link.cage() && !link.severed)
			free = link
			break
	if(!free)
		for(var/datum/rogue_zadlink/link as anything in slots)
			if(link.severed && !link.flight())
				free = link
				break
	if(!free)
		if(user)
			to_chat(user, span_warning("[src] is full - no free slot to bond this zadcage."))
		return FALSE
	free.cage_ref = WEAKREF(cage)
	free.severed = FALSE
	bond = cage.AddComponent(/datum/component/rogue_zadcage)
	bond.bind(src, free)
	if(user)
		to_chat(user, span_notice("The zadcote chirps as the zadcage clicks into bond on slot [free.slot_index]."))
	return TRUE

/obj/item/roguemachine/zadcote/proc/sever_link(datum/rogue_zadlink/link)
	if(!link || link.severed)
		return
	link.severed = TRUE
	var/datum/component/rogue_zadcage/bond = link.cage_component()
	bond?.on_severed()
	link.cage_ref = null

/obj/item/roguemachine/zadcote/attack_hand(mob/user, list/modifiers)
	if(!anchored)
		return ..()
	if(!is_operator(user))
		to_chat(user, span_warning("The zadcote ignores you. Only its owners may operate it."))
		return TRUE
	ui_interact(user)
	return TRUE

/obj/item/roguemachine/zadcote/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode || !anchored)
		return NONE
	if(tool.type == text2path(ZAD_CAGE_PATH) || tool.GetComponent(/datum/component/rogue_zadcage))
		if(!is_operator(user))
			to_chat(user, span_warning("You have no authority to bond a zadcage to this zadcote."))
			return ITEM_INTERACT_BLOCKING
		attach_cage(tool, user)
		return ITEM_INTERACT_SUCCESS
	if(tool.type == text2path(ZAD_PACK_PATH))
		if(!is_operator(user))
			to_chat(user, span_warning("Only the zadcote's owners may restock it."))
			return ITEM_INTERACT_BLOCKING
		restock(rogue_value("machines_zad_pack_size"))
		to_chat(user, span_notice("The zadcote chirps as [rogue_value("machines_zad_pack_size")] fresh zads join the reserve."))
		playsound(src, ROGUE_SOUND_HISS, 50, FALSE, -1)
		qdel(tool)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/bomb))
		if(!is_operator(user))
			to_chat(user, span_warning("Only the zadcote's owners may use it."))
			return ITEM_INTERACT_BLOCKING
		if(bomb_stock >= rogue_value("machines_zad_bomb_stock_cap"))
			to_chat(user, span_warning("The zadcote's bomb crate is full."))
			return ITEM_INTERACT_BLOCKING
		bomb_stock++
		to_chat(user, span_notice("You feed a bottlebomb into [src]'s crate. ([bomb_stock] / [rogue_value("machines_zad_bomb_stock_cap")])"))
		qdel(tool)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/roguecoin))
		if(!allows_voyeur)
			to_chat(user, span_warning("This zadcote has no scrying basin to feed."))
			return ITEM_INTERACT_BLOCKING
		if(!rogue_coin_accepted(tool))
			return ITEM_INTERACT_BLOCKING
		voyeur_fund += tool.get_real_price()
		to_chat(user, span_notice("You feed [tool] into [src]'s scrying basin. ([voyeur_fund]m stored.)"))
		playsound(src, ROGUE_SOUND_GOLD_MISC, 60, FALSE, -1)
		qdel(tool)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/roguemachine/zadcote/proc/log_flight(datum/rogue_zadlink/link, kind, message, list/item_names, zads, bombs = 0, lost = 0, summoned = FALSE)
	mail_log.Insert(1, list(list(
		"stamp" = round_timestamp("hh:mm"),
		"slot" = link?.slot_index || 0,
		"sender" = link ? link.label() : "an unknown slot",
		"message" = message,
		"items" = item_names || list(),
		"kind" = kind,
		"zads_used" = zads,
		"bombs" = bombs,
		"lost" = lost,
		"summoned" = summoned,
	)))
	if(length(mail_log) > 20)
		mail_log.Cut(21)

/// Ratwood dispatch(): zads fly from the cote to a bonded cage with a message and a parcel, or with bombs.
/obj/item/roguemachine/zadcote/proc/dispatch(datum/rogue_zadlink/link, zads, message, send_held, bombs, mob/living/keeper, bomb_caw)
	var/datum/component/rogue_zadcage/bond = link?.cage_component()
	if(!link || link.severed)
		to_chat(keeper, span_warning("That zadlink is severed."))
		return FALSE
	if(!bond)
		to_chat(keeper, span_warning("That zadlink has no bonded zadcage."))
		return FALSE
	if(link.flight())
		to_chat(keeper, span_warning("A flight is already on that slot."))
		return FALSE
	if(bond.occupied)
		to_chat(keeper, span_warning("That zadcage is already occupied. Wait for it to return."))
		return FALSE
	if(length(bond.held_payload))
		to_chat(keeper, span_warning("Unclaimed parcels still sit in that zadcage. Wait for the holder to retrieve them."))
		return FALSE
	zads = clamp(round(zads), ZAD_TIER_MIN, ZAD_TIER_MAX)
	bombs = clamp(round(bombs), 0, ZAD_TIER_MAX)
	if(bombs > 0)
		if(world.time < bomb_cooldown_until)
			to_chat(keeper, span_warning("The zads refuse - you may only send a bombs flight every [DisplayTimeText(rogue_value("machines_zad_bomb_cooldown"))], you maniac."))
			return FALSE
		if(bombs > bomb_stock)
			to_chat(keeper, span_warning("The zadcote has only [bomb_stock] bottlebombs stored."))
			return FALSE
		zads = bombs
	if(reserve < zads)
		to_chat(keeper, span_warning("Only [reserve] zads remain in the cote."))
		return FALSE
	if(flight_count() >= rogue_value("machines_zad_flight_cap"))
		to_chat(keeper, span_warning("Too many flights in the air."))
		return FALSE
	var/list/parcels = list()
	if(!bombs && send_held)
		var/obj/item/held = keeper.get_active_held_item()
		if(held && !held.GetComponent(/datum/component/rogue_zadcage) && !istype(held, /obj/item/bomb) && held.type != text2path(ZAD_PACK_PATH))
			if(held.w_class > rogue_zad_max_weight(zads))
				to_chat(keeper, span_warning("[held] is too heavy for [zads] zad\s. Use a larger tier or send a smaller parcel."))
				return FALSE
			if(!keeper.temporarilyRemoveItemFromInventory(held))
				return FALSE
			parcels += held
	reserve -= zads
	if(bombs > 0)
		bomb_stock -= bombs
		bomb_cooldown_until = world.time + rogue_value("machines_zad_bomb_cooldown")
	var/datum/rogue_zad_flight/flight = new(src, link, zads, message, parcels, bombs)
	flight.sender_ckey = keeper.ckey
	flight.bomb_caw = bomb_caw
	outbound += flight
	link.flight_ref = WEAKREF(flight)
	playsound(src, ZAD_SOUND_FLY, 65, TRUE, 2)
	playsound(src, ZAD_SOUND_CAW, 55, TRUE, 2)
	visible_message(span_notice("[zads] zad\s leap from [src] and beat for the sky."))
	var/list/names = list()
	for(var/obj/item/parcel as anything in parcels)
		names += parcel.name
	log_flight(link, "sent", message, names, zads, bombs)
	return TRUE

/// Ratwood request_summon(): the cage's holder calls zads to it, to send something home.
/obj/item/roguemachine/zadcote/proc/request_summon(datum/rogue_zadlink/link, mob/requester, zads)
	var/datum/component/rogue_zadcage/bond = link?.cage_component()
	if(!bond || link.severed)
		return FALSE
	if(!link.allow_summons)
		to_chat(requester, span_warning("The zadcote does not accept summons on this zadlink."))
		return FALSE
	if(link.flight())
		to_chat(requester, span_warning("A flight is already on this zadlink."))
		return FALSE
	if(bond.occupied)
		to_chat(requester, span_warning("This zadcage is already occupied."))
		return FALSE
	zads = clamp(round(zads), ZAD_TIER_MIN, ZAD_TIER_MAX)
	if(reserve < zads)
		to_chat(requester, span_warning("Only [reserve] zads remain in the cote."))
		return FALSE
	if(flight_count() >= rogue_value("machines_zad_flight_cap"))
		to_chat(requester, span_warning("Too many flights in the air. Try again shortly."))
		return FALSE
	reserve -= zads
	var/datum/rogue_zad_flight/flight = new(src, link, zads, "", null, 0)
	flight.sender_ckey = requester.ckey
	outbound += flight
	link.flight_ref = WEAKREF(flight)
	playsound(src, ZAD_SOUND_FLY, 65, TRUE, 2)
	visible_message(span_notice("[zads] zad\s leap from [src], summoned away."))
	log_flight(link, "sent", "", null, zads, 0, 0, TRUE)
	return TRUE

/obj/item/roguemachine/zadcote/process(seconds_per_tick)
	if(!anchored)
		return
	for(var/datum/rogue_zad_flight/flight as anything in outbound.Copy())
		if(!flight.turnback_checked && world.time >= flight.launch_time + rogue_value("machines_zad_turnback_check"))
			flight.turnback_checked = TRUE
			var/datum/rogue_zadlink/link = flight.target_link()
			if(!link?.cage_component())
				turn_back(flight)
				continue
		if(world.time >= flight.arrival_time)
			arrive(flight)
	for(var/datum/rogue_zad_flight/flight as anything in returning.Copy())
		if(world.time >= flight.arrival_time)
			come_home(flight)

/// Ratwood resolve_turnback(): nowhere to land, the zads bring everything back.
/obj/item/roguemachine/zadcote/proc/turn_back(datum/rogue_zad_flight/flight)
	outbound -= flight
	flight.drop_payload(drop_location())
	restock(flight.zads)
	bomb_stock = min(bomb_stock + flight.bombs, rogue_value("machines_zad_bomb_stock_cap"))
	var/datum/rogue_zadlink/link = flight.target_link()
	if(link)
		link.flight_ref = null
	visible_message(span_warning("The zads return to [src] - there was nowhere to land."))
	qdel(flight)

/// Ratwood resolve_arrival(): the zads reach the cage.
/obj/item/roguemachine/zadcote/proc/arrive(datum/rogue_zad_flight/flight)
	outbound -= flight
	var/datum/rogue_zadlink/link = flight.target_link()
	var/datum/component/rogue_zadcage/bond = link?.cage_component()
	if(!bond)
		outbound += flight
		turn_back(flight)
		return
	link.flight_ref = null
	if(!bond.holder())
		visible_message(span_warning("[src] chimes. The zads report Zadcage #[link.slot_index] is not on a person."))
	bond.receive(flight)

/obj/item/roguemachine/zadcote/proc/receive_return(datum/rogue_zad_flight/flight)
	flight.direction = ZAD_RETURN
	flight.launch_time = world.time
	flight.arrival_time = world.time + rogue_value("machines_zad_outbound_time")
	for(var/i in 1 to flight.zads)
		if(prob(rogue_value("machines_zad_attrition")))
			flight.lost++
	returning += flight

/// Ratwood complete_return(): the zads land with the reply and the parcel; the exhausted ones never do.
/obj/item/roguemachine/zadcote/proc/come_home(datum/rogue_zad_flight/flight)
	returning -= flight
	var/datum/rogue_zadlink/link = flight.target_link()
	var/list/names = list()
	for(var/obj/item/parcel as anything in flight.payload)
		names += parcel.name
	flight.drop_payload(drop_location())
	restock(flight.zads - flight.lost)
	playsound(src, ZAD_SOUND_FLY, 60, TRUE, 2)
	playsound(src, ZAD_SOUND_CAW, 50, TRUE, 2)
	if(flight.lost)
		var/loss_text
		if(flight.zads == 1)
			loss_text = "the zad perished of exhaustion."
		else if(flight.lost == flight.zads)
			loss_text = "all [flight.lost] zads perished of exhaustion."
		else
			loss_text = "[flight.lost] of [flight.zads] zads dropped from the sky, exhausted - [flight.zads - flight.lost] returned home."
		visible_message(span_warning("[src] reports [loss_text]"))
	log_flight(link, "returned", flight.message, names, flight.zads, 0, flight.lost)
	if(length(flight.message) || length(names))
		var/header = link ? (length(link.display_name) ? "Slot [link.slot_index] ([link.display_name])" : "Slot [link.slot_index]") : "A lost slot"
		visible_message(span_notice("A zad returns to [src] - [header][length(flight.message) ? " says: \"[flight.message]\"" : ""][length(names) ? " brings: [english_list(names)]" : ""]"))
		playsound(src, 'modular_redtard/rockhill/sound/misc/notice.ogg', 60, FALSE, -1)
	else if(!flight.lost)
		visible_message(span_notice("A zad returns to [src] - empty-clawed."))
	qdel(flight)

/// The operator looks through the eyes of a bonded zad for a while, for coin from the basin (Ratwood begin_voyeur()).
/obj/item/roguemachine/zadcote/proc/begin_voyeur(datum/rogue_zadlink/link, mob/living/carbon/human/keeper)
	var/datum/component/rogue_zadcage/bond = link?.cage_component()
	if(!allows_voyeur || !bond || link.severed)
		to_chat(keeper, span_warning("There is no bonded zad to scry through."))
		return
	var/cost = rogue_value("machines_zad_voyeur_cost")
	if(voyeur_fund < cost)
		to_chat(keeper, span_warning("The zadcote's scrying fund is empty. Feed it mammon coins to scry."))
		return
	voyeur_fund -= cost
	to_chat(keeper, span_notice("You whisper into the zadcote. The bonded zad stirs from afar... ([voyeur_fund]m left for scrying.)"))
	if(!do_after(keeper, rogue_value("machines_zad_voyeur_time"), src) || QDELETED(bond) || !bond.start_voyeur(keeper))
		voyeur_fund += cost

/obj/item/roguemachine/zadcote/ui_status(mob/user, datum/ui_state/state)
	if(isobserver(user))
		return UI_CLOSE
	return ..()

/obj/item/roguemachine/zadcote/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RogueZadcote", name)
		ui.open()

/obj/item/roguemachine/zadcote/ui_data(mob/user)
	var/list/data = list()
	data["motto"] = motto
	data["reserve"] = reserve
	data["reserve_cap"] = rogue_value("machines_zad_reserve_cap")
	data["flights"] = flight_count()
	data["flight_cap"] = rogue_value("machines_zad_flight_cap")
	data["bomb_stock"] = bomb_stock
	data["bomb_cooldown"] = max(0, round((bomb_cooldown_until - world.time) / 10))
	data["allows_voyeur"] = allows_voyeur
	data["voyeur_fund"] = voyeur_fund
	data["voyeur_cost"] = rogue_value("machines_zad_voyeur_cost")
	data["mail_log"] = mail_log
	var/obj/item/held = user.get_active_held_item()
	data["held"] = held ? list("name" = held.name, "w_class" = held.w_class) : null
	var/list/rows = list()
	for(var/datum/rogue_zadlink/link as anything in slots)
		var/datum/component/rogue_zadcage/bond = link.cage_component()
		var/datum/rogue_zad_flight/flight = link.flight()
		rows += list(list(
			"slot" = link.slot_index,
			"name" = link.display_name,
			"label" = link.label(),
			"severed" = link.severed,
			"bonded" = !!bond,
			"occupied" = bond?.occupied || FALSE,
			"has_payload" = length(bond?.held_payload) > 0,
			"allow_summons" = link.allow_summons,
			"in_flight" = !!flight,
			"flight_zads" = flight?.zads,
			"flight_seconds" = flight ? max(0, round((flight.arrival_time - world.time) / 10)) : 0,
			"flight_bombs" = flight?.bombs,
		))
	data["slots"] = rows
	return data

/obj/item/roguemachine/zadcote/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/keeper = ui.user
	if(!is_operator(keeper))
		to_chat(keeper, span_warning("Only the zadcote's faction may operate it."))
		return TRUE
	var/datum/rogue_zadlink/link = find_slot(params["slot"])
	switch(action)
		if("set_slot_name")
			if(link)
				link.display_name = copytext_char(sanitize(params["name"]), 1, 33)
				var/datum/component/rogue_zadcage/bond = link.cage_component()
				bond?.refresh_label()
		if("sever")
			if(link)
				sever_link(link)
				to_chat(keeper, span_notice("The bond on slot [link.slot_index] withers. The zads will return what is owed, then no more."))
		if("toggle_summons")
			if(link)
				link.allow_summons = !link.allow_summons
		if("dispatch")
			if(link)
				dispatch(link, text2num(params["zads"]), copytext_char(sanitize(params["message"]), 1, 501), params["send_held"], text2num(params["bombs"]), keeper, copytext_char(sanitize(params["bomb_caw"]), 1, 41))
		if("voyeur")
			if(link)
				INVOKE_ASYNC(src, PROC_REF(begin_voyeur), link, keeper)
		if("withdraw_voyeur")
			if(allows_voyeur && voyeur_fund > 0)
				rogue_coins_out(voyeur_fund, keeper, null, src)
				to_chat(keeper, span_notice("You drain [voyeur_fund]m from [src]'s scrying basin."))
				voyeur_fund = 0
	return TRUE

/obj/item/roguemachine/zadcote/steward
	faction = "steward"
	motto = "STEWARDRY ZADCOTE"
	operator_jobs = list(JOB_ROCKHILL_GRAND_DUKE, JOB_ROCKHILL_STEWARD, JOB_ROCKHILL_CLERK, JOB_ROCKHILL_COUNCILLOR, JOB_ROCKHILL_HAND)

/obj/item/roguemachine/zadcote/merchant
	faction = "merchant"
	motto = "COMPANY ZADCOTE"
	operator_jobs = list(JOB_ROCKHILL_MERCHANT, JOB_ROCKHILL_SHOPHAND)
	operator_trait = TRAIT_AGENT_MERCHANT
	allows_voyeur = TRUE

/obj/item/roguemachine/zadcote/bathhouse
	faction = "bathhouse"
	motto = "BATHHOUSE ZADCOTE"
	operator_jobs = list(JOB_ROCKHILL_BATHMASTER, JOB_ROCKHILL_BATHHOUSE_ATTENDANT)
	operator_trait = TRAIT_AGENT_BATHHOUSE
	allows_voyeur = TRUE

/**
 * A zadcage bonded to a zadcote (Ratwood /obj/item/zadcage): the zad that lands in it waits a few minutes for its holder to take
 * the parcel, write a reply and send it home with something to carry; the holder may also call zads to it.
 */
/datum/component/rogue_zadcage
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/weakref/cote_ref
	var/datum/weakref/link_ref
	/// A zad waits in the cage now (Ratwood current_occupancy).
	var/occupied = FALSE
	var/occupancy_expires = 0
	var/occupancy_zads = 1
	var/reply_message = ""
	var/list/obj/item/held_payload = list()
	var/severed_announced = FALSE
	var/depart_timer
	/// Who scries through the zad now, and how to bring them back.
	var/mob/living/voyeur
	var/voyeur_timer

/datum/component/rogue_zadcage/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/rogue_zadcage/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/rogue_zadcage/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_ATTACK_SELF, COMSIG_ATOM_EXAMINE))

/datum/component/rogue_zadcage/Destroy(force)
	end_voyeur()
	deltimer(depart_timer)
	var/atom/cage = parent
	var/turf/spot = get_turf(cage)
	for(var/obj/item/parcel as anything in held_payload)
		if(spot)
			parcel.forceMove(spot)
		else
			qdel(parcel)
	held_payload.Cut()
	var/datum/rogue_zadlink/link = zadlink()
	if(link?.cage() == parent)
		link.cage_ref = null
	return ..()

/datum/component/rogue_zadcage/proc/cote()
	return cote_ref?.resolve()

/datum/component/rogue_zadcage/proc/zadlink()
	return link_ref?.resolve()

/datum/component/rogue_zadcage/proc/bind(obj/item/roguemachine/zadcote/cote, datum/rogue_zadlink/link)
	cote_ref = WEAKREF(cote)
	link_ref = WEAKREF(link)
	severed_announced = FALSE
	refresh_label()

/datum/component/rogue_zadcage/proc/on_severed()
	severed_announced = FALSE
	refresh_label()

/datum/component/rogue_zadcage/proc/refresh_label()
	var/obj/item/cage = parent
	var/datum/rogue_zadlink/link = zadlink()
	if(!link || !cote())
		cage.name = initial(cage.name)
	else if(link.severed)
		cage.name = "severed zadcage"
	else
		cage.name = "zadcage #[link.slot_index]"

/datum/component/rogue_zadcage/proc/holder()
	var/atom/cursor = parent
	while(cursor && !isturf(cursor))
		if(ismob(cursor))
			return cursor
		cursor = cursor.loc
	return null

/datum/component/rogue_zadcage/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/datum/rogue_zadlink/link = zadlink()
	var/obj/item/roguemachine/zadcote/cote = cote()
	if(!link || !cote)
		examine_list += span_info("This zadcage has no bond. Strike it against a zadcote to make one.")
		return
	if(link.severed)
		examine_list += span_warning("Bond severed. This zadcage was tied to [cote.name], slot [link.slot_index].")
		return
	examine_list += span_info("Bonded to [cote.name], slot [link.slot_index]: [link.label()].")
	if(occupied)
		examine_list += span_notice("A zad is waiting in the cage.")

/datum/component/rogue_zadcage/proc/on_attack_self(datum/source, mob/user)
	SIGNAL_HANDLER
	var/datum/rogue_zadlink/link = zadlink()
	if(link?.severed && !severed_announced)
		severed_announced = TRUE
		to_chat(user, span_warning("The zadlink has been severed."))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(occupied || length(held_payload) || (link && !link.severed && link.allow_summons))
		INVOKE_ASYNC(src, TYPE_PROC_REF(/datum, ui_interact), user)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/// The zads land: bombs fall, or a zad waits with the parcel (Ratwood receive_flight(), complete_arrival()).
/datum/component/rogue_zadcage/proc/receive(datum/rogue_zad_flight/flight)
	var/obj/item/cage = parent
	playsound(cage, ZAD_SOUND_FLY, 60, TRUE, 2)
	playsound(cage, ZAD_SOUND_CAW, 55, TRUE, 2)
	if(flight.bombs > 0)
		drop_bombs(flight)
		qdel(flight)
		return
	occupied = TRUE
	occupancy_zads = flight.zads
	occupancy_expires = world.time + rogue_value("machines_zad_occupancy")
	reply_message = ""
	cage.visible_message(span_notice("A zad alights on [cage]."))
	for(var/obj/item/parcel as anything in flight.payload)
		parcel.forceMove(cage)
		held_payload += parcel
	flight.payload.Cut()
	var/mob/holder = holder()
	if(holder && length(flight.message))
		to_chat(holder, span_notice("The zad on [cage] carries a message: \"[flight.message]\""))
	depart_timer = addtimer(CALLBACK(src, PROC_REF(auto_depart)), rogue_value("machines_zad_occupancy"), TIMER_STOPPABLE)
	qdel(flight)

/// Ratwood begin_bomb_arrival(): the zads hang bottle bombs over the cage and let them fall around it.
/datum/component/rogue_zadcage/proc/drop_bombs(datum/rogue_zad_flight/flight)
	var/obj/item/cage = parent
	var/mob/holder = holder()
	var/bomb_word = flight.bombs > 1 ? "BOMBS" : "BOMB"
	cage.balloon_alert_to_viewers("[bomb_word]!!!")
	if(flight.bomb_caw)
		cage.say(flight.bomb_caw)
	if(holder)
		to_chat(holder, span_userdanger("[bomb_word] dangle from the zad[flight.zads > 1 ? "s" : ""] above your zadcage!"))
	for(var/mob/living/near in range(3, get_turf(cage)))
		if(near != holder)
			to_chat(near, span_userdanger("Above [cage]: [bomb_word]!"))
	var/datum/rogue_zadlink/link = flight.target_link()
	var/log_line = "ZAD BOMB: [flight.sender_ckey || "<UNKNOWN>"] -> [holder?.ckey || "<UNATTENDED>"], [flight.bombs] bombs on zadcage #[link?.slot_index] at [AREACOORD(cage)]"
	message_admins(log_line)
	log_game(log_line)
	var/delay = rand(rogue_value("machines_zad_bomb_landing_min"), rogue_value("machines_zad_bomb_landing_max")) - rogue_value("machines_zad_landing_time")
	for(var/i in 1 to flight.bombs)
		addtimer(CALLBACK(src, PROC_REF(pop_bomb)), max(1, delay) + (i - 1) * 1 SECONDS)

/datum/component/rogue_zadcage/proc/pop_bomb()
	var/turf/center = get_turf(parent)
	if(!center)
		return
	var/list/tiles = list(center)
	for(var/turf/near in orange(1, center))
		tiles += near
	explosion(pick(tiles), light_impact_range = 1, flame_range = 2, smoke = TRUE, explosion_cause = parent)

/// The window closes and the zad flies home empty (Ratwood auto_depart()).
/datum/component/rogue_zadcage/proc/auto_depart()
	if(!occupied)
		return
	var/obj/item/cage = parent
	cage.visible_message(span_warning("The zad lifts from [cage] empty - the window closed."))
	send_home(null, null)

/// The zad flies home with the reply and the parcel in the sender's hand (Ratwood dispatch_return()).
/datum/component/rogue_zadcage/proc/send_home(mob/living/sender, send_held)
	var/obj/item/roguemachine/zadcote/cote = cote()
	var/datum/rogue_zadlink/link = zadlink()
	if(!occupied || !cote || !link)
		return FALSE
	var/list/parcels = list()
	if(sender && send_held)
		var/obj/item/held = sender.get_active_held_item()
		if(held && held != parent && !held.GetComponent(/datum/component/rogue_zadcage))
			if(held.w_class > rogue_zad_max_weight(occupancy_zads))
				to_chat(sender, span_warning("[held] is too heavy for the [occupancy_zads] zad return tier."))
				return FALSE
			if(!sender.temporarilyRemoveItemFromInventory(held))
				return FALSE
			parcels += held
	var/datum/rogue_zad_flight/flight = new(cote, link, occupancy_zads, reply_message, parcels, 0)
	cote.receive_return(flight)
	occupied = FALSE
	reply_message = ""
	deltimer(depart_timer)
	if(sender)
		var/obj/item/cage = parent
		cage.visible_message(span_notice("The zad lifts from [cage] and beats away."))
	return TRUE

/datum/component/rogue_zadcage/proc/retrieve(mob/living/user)
	if(!length(held_payload))
		to_chat(user, span_warning("[parent] holds no parcels."))
		return
	for(var/obj/item/parcel as anything in held_payload)
		if(!user.put_in_hands(parcel))
			parcel.forceMove(get_turf(parent))
		to_chat(user, span_notice("You take [parcel] from [parent]."))
	held_payload.Cut()

/// The operator's eyes follow the zad until the time runs out or they move (Ratwood start_voyeur()).
/datum/component/rogue_zadcage/proc/start_voyeur(mob/living/keeper)
	if(voyeur)
		to_chat(keeper, span_warning("The zad is already being scryed through - wait for the current scrying to end."))
		return FALSE
	var/obj/item/cage = parent
	var/mob/holder = holder()
	var/atom/movable/target = holder || cage
	message_admins("ZAD VOYEUR: [key_name_admin(keeper)] scryed via zadcage on [holder ? key_name_admin(holder) : "the empty cage at [AREACOORD(cage)]"]")
	log_game("ZAD VOYEUR: [key_name(keeper)] scryed via zadcage on [holder ? key_name(holder) : "the empty cage"]")
	target.visible_message(span_notice("A strange blue glow emits from [holder ? "a zadcage on [holder]" : "the zad in [cage]"]."))
	if(holder && holder.stat < HARD_CRIT && !HAS_TRAIT(holder, TRAIT_KNOCKEDOUT))
		to_chat(holder, span_warning("The zad in your zadcage stirs - you feel a pair of eyes peering through it."))
	voyeur = keeper
	keeper.reset_perspective(target)
	keeper.visible_message(span_danger("[keeper] stares into the zadcote, [keeper.p_their()] eyes rolling back into [keeper.p_their()] head."))
	to_chat(keeper, span_notice("You see through the zad's eyes. Move to look away; the bond breaks on its own after [DisplayTimeText(rogue_value("machines_zad_voyeur_duration"))]."))
	RegisterSignal(keeper, COMSIG_MOVABLE_MOVED, PROC_REF(on_voyeur_moved))
	RegisterSignal(keeper, COMSIG_QDELETING, PROC_REF(on_voyeur_moved))
	voyeur_timer = addtimer(CALLBACK(src, PROC_REF(end_voyeur)), rogue_value("machines_zad_voyeur_duration"), TIMER_STOPPABLE)
	return TRUE

/datum/component/rogue_zadcage/proc/on_voyeur_moved(datum/source)
	SIGNAL_HANDLER
	end_voyeur()

/datum/component/rogue_zadcage/proc/end_voyeur()
	deltimer(voyeur_timer)
	if(!voyeur)
		return
	UnregisterSignal(voyeur, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	if(!QDELETED(voyeur))
		voyeur.reset_perspective()
		to_chat(voyeur, span_notice("The zad's sight fades from your eyes."))
	voyeur = null

/datum/component/rogue_zadcage/ui_host(mob/user)
	return parent

/datum/component/rogue_zadcage/ui_state(mob/user)
	return GLOB.hands_state

/datum/component/rogue_zadcage/ui_status(mob/user, datum/ui_state/state)
	if(isobserver(user))
		return UI_CLOSE
	return ..()

/datum/component/rogue_zadcage/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RogueZadcage", "zadcage")
		ui.open()

/datum/component/rogue_zadcage/ui_data(mob/user)
	var/list/data = list()
	var/datum/rogue_zadlink/link = zadlink()
	var/obj/item/roguemachine/zadcote/cote = cote()
	data["bonded"] = !!link
	data["severed"] = link?.severed || FALSE
	data["slot_label"] = link ? link.label() : ""
	data["cote_name"] = cote ? cote.name : ""
	data["cote_motto"] = cote ? cote.motto : ""
	data["allow_summons"] = link?.allow_summons || FALSE
	data["pending_flight"] = !!link?.flight()
	data["occupied"] = occupied
	data["time_remaining"] = occupied ? max(0, round((occupancy_expires - world.time) / 10)) : 0
	data["warning"] = occupied && occupancy_expires - world.time <= rogue_value("machines_zad_warning_tail")
	data["capacity"] = occupancy_zads
	data["reply_message"] = reply_message
	var/obj/item/held = user.get_active_held_item()
	data["held"] = (held && held != parent) ? list("name" = held.name, "w_class" = held.w_class) : null
	var/list/stored = list()
	for(var/obj/item/parcel as anything in held_payload)
		stored += parcel.name
	data["stored"] = stored
	return data

/datum/component/rogue_zadcage/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/user = ui.user
	switch(action)
		if("set_reply")
			if(occupied)
				reply_message = copytext_char(sanitize(params["message"]), 1, 501)
		if("send_reply")
			if(occupied && do_after(user, rogue_value("machines_zad_send_time"), parent))
				send_home(user, params["send_held"])
		if("retrieve")
			retrieve(user)
		if("summon")
			var/obj/item/roguemachine/zadcote/cote = cote()
			var/datum/rogue_zadlink/link = zadlink()
			if(cote && link && do_after(user, rogue_value("machines_zad_send_time"), parent))
				cote.request_summon(link, user, text2num(params["zads"]))
	return TRUE

#undef ZAD_CAGE_PATH
#undef ZAD_PACK_PATH
#undef ZAD_OUTBOUND
#undef ZAD_RETURN
#undef ZAD_SOUND_FLY
#undef ZAD_SOUND_CAW
#undef ZAD_TIER_MIN
#undef ZAD_TIER_MAX
