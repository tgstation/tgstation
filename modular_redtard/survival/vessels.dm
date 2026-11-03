/// Ratwood vessels (code/modules/reagents/reagent_containers/glass.dm, bottle.dm, modular/Neu_Food/code/cookware) are TG open
/// cups: the Ratwood root grafts onto /obj/item/reagent_containers/cup, so pouring from vessel to vessel, drinking, feeding and
/// heating are TG's. The Ratwood intents of a vessel choose what a click does: feed pours into a vessel, drinks or feeds
/// someone; fill draws from a vessel or open water; splash empties it over the target; hit strikes with it. Without Ratwood
/// intents (modern maps) it is plain TG. Volumes and transfer amounts are Ratwood's.
/obj/item/reagent_containers/glass
	parent_type = /obj/item/reagent_containers/cup
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30, 50)
	volume = 50
	spillable = TRUE

/// The Ratwood intent this vessel is used with, or null when it has none (TG behaviour then).
/obj/item/reagent_containers/glass/proc/rogue_vessel_intent(mob/living/user)
	if(!rogue_survival_enabled() || !isliving(user) || !length(rogue_intents()))
		return null
	return user.rogue_active_intent()

/obj/item/reagent_containers/glass/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/datum/intent/intent = rogue_vessel_intent(user)
	if(!intent)
		return ..()
	if(istype(intent, /datum/intent/hit))
		return NONE
	if(!is_open_container())
		to_chat(user, span_warning("[src] is corked!"))
		return ITEM_INTERACT_BLOCKING
	if(istype(intent, /datum/intent/splash))
		return try_splash(user, interacting_with) ? ITEM_INTERACT_SUCCESS : NONE
	if(istype(intent, /datum/intent/fill))
		if(interacting_with.is_drainable() && !isliving(interacting_with))
			return rogue_pour(interacting_with, user, TRUE)
		// Ratwood fill on a person is milking, which is not ported; it never strikes them.
		return isliving(interacting_with) ? ITEM_INTERACT_BLOCKING : NONE
	if(interacting_with.is_refillable() && !isliving(interacting_with))
		return rogue_pour(interacting_with, user, FALSE)
	return ..()

/// With Ratwood intents a right click does not splash or draw: the splash and fill intents do (a stray right click in combat
/// would empty the pot).
/obj/item/reagent_containers/glass/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(rogue_vessel_intent(user))
		return NONE
	return ..()

/// Ratwood attack_obj() with the feed or fill intent: pour into the target, or draw from it, a measure at a time while the
/// hands stay busy (eleven measures at most).
/obj/item/reagent_containers/glass/proc/rogue_pour(atom/target, mob/living/user, from_target)
	var/atom/giver = from_target ? target : src
	var/atom/taker = from_target ? src : target
	if(!giver.reagents.total_volume)
		to_chat(user, span_warning("[giver] is empty!"))
		return ITEM_INTERACT_BLOCKING
	if(taker.reagents.holder_full())
		to_chat(user, span_warning("[taker] is full."))
		return ITEM_INTERACT_BLOCKING
	if(from_target)
		user.visible_message(span_notice("[user] fills [src] with [target]."), span_notice("I fill [src] with [target]."))
		playsound(user, 'modular_redtard/survival/sound/fillcup.ogg', 100, TRUE)
	else
		user.visible_message(span_notice("[user] pours [src] into [target]."), span_notice("I pour [src] into [target]."))
		playsound(user, /datum/sound_effect/liquid_pour, 50, TRUE)
	for(var/i in 1 to ROGUE_POUR_ROUNDS)
		if(!do_after(user, ROGUE_POUR_TIME, target = target) || QDELETED(target))
			break
		if(!giver.reagents.total_volume || taker.reagents.holder_full())
			break
		giver.reagents.trans_to(taker, amount_per_transfer_from_this, transferred_by = user)
		target.update_appearance()
	return ITEM_INTERACT_SUCCESS

/// Ratwood glass attackby(): an egg is broken into an open vessel, salt is worked into milk (survival/kneading.dm).
/obj/item/reagent_containers/glass/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/reagent_containers/powder/salt) && is_open_container() && reagents.has_reagent(/datum/reagent/consumable/milk))
		return salt_milk(user, tool)
	if(!istype(tool, /obj/item/reagent_containers/food/snacks/egg) || !is_open_container() || !tool.reagents)
		return ..()
	if(reagents.holder_full())
		to_chat(user, span_warning("[src] is full."))
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_notice("I break [tool] in [src]."))
	playsound(src, 'modular_redtard/survival/sound/eggbreak.ogg', 60, TRUE)
	tool.reagents.trans_to(src, tool.reagents.total_volume, transferred_by = user)
	qdel(tool)
	return ITEM_INTERACT_SUCCESS

/// Ratwood drinking: favourite and hated drinks (survival/appetite.dm) count by what is most of the vessel.
/obj/item/reagent_containers/glass/try_drink(mob/living/target_mob, mob/living/user)
	var/datum/reagent/drunk = reagents?.get_master_reagent()
	var/drunk_type = drunk?.type
	. = ..()
	if((. & ITEM_INTERACT_SUCCESS) && drunk_type)
		rogue_drink_preference(target_mob, drunk_type)

/// Ratwood vessels show their filling (update_icon()): the state of rogue_fill_state(), in the colour of what is inside.
/obj/item/reagent_containers/glass/update_overlays()
	. = ..()
	if(!reagents?.total_volume)
		return
	var/state = rogue_fill_state()
	if(!state || !icon_exists(icon, state))
		return
	var/mutable_appearance/filling = mutable_appearance(icon, state)
	filling.color = mix_color_from_reagents(reagents.reagent_list)
	. += filling

/// The icon state of the filling for what is inside now, or null for none.
/obj/item/reagent_containers/glass/proc/rogue_fill_state()
	return null

// Cups, bowls, buckets and pots (Ratwood cookware).

/obj/item/reagent_containers/glass/cup
	initial_reagent_flags = OPENCONTAINER
	amount_per_transfer_from_this = 6
	possible_transfer_amounts = list(6)
	volume = 25

/obj/item/reagent_containers/glass/cup/rogue_fill_state()
	return "[icon_state]_filling"

/obj/item/reagent_containers/glass/bowl
	initial_reagent_flags = OPENCONTAINER
	amount_per_transfer_from_this = 7
	possible_transfer_amounts = list(7)
	volume = 30
	/// Ratwood bowl filling: up to these amounts the bowl looks low or half full.
	var/rogue_fill_low = 11
	var/rogue_fill_half = 22
	/// A full bowl of these looks like porridge or stew (amount of the reagent it takes).
	var/static/list/rogue_porridge_looks = list(/datum/reagent/consumable/soup/porridge/oatmeal = 10)
	var/static/list/rogue_stew_looks = list(
		/datum/reagent/consumable/soup/stew/chicken = 17,
		/datum/reagent/consumable/soup/stew/meat = 17,
		/datum/reagent/consumable/soup/stew/fish = 17,
	)

/obj/item/reagent_containers/glass/bowl/rogue_fill_state()
	var/amount = reagents.total_volume
	if(amount <= rogue_fill_low)
		return "bowl_low"
	if(amount <= rogue_fill_half)
		return "bowl_half"
	for(var/reagent_type in rogue_porridge_looks)
		if(reagents.has_reagent(reagent_type, rogue_porridge_looks[reagent_type]))
			return "bowl_oatmeal"
	for(var/reagent_type in rogue_stew_looks)
		if(reagents.has_reagent(reagent_type, rogue_stew_looks[reagent_type]))
			return "bowl_stew"
	return "bowl_full"

/// Ratwood bowl attackby(): a spoon eats from the bowl.
/obj/item/reagent_containers/glass/bowl/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/kitchen/spoon))
		return spoon_from(user)
	return ..()

/obj/item/reagent_containers/glass/bowl/proc/spoon_from(mob/living/user)
	if(!reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return ITEM_INTERACT_BLOCKING
	if(!canconsume(user, user))
		return ITEM_INTERACT_BLOCKING
	if(!do_after(user, ROGUE_SPOON_TIME, target = src) || !reagents.total_volume)
		return ITEM_INTERACT_BLOCKING
	var/datum/reagent/eaten = reagents.get_master_reagent()
	var/eaten_type = eaten?.type
	playsound(src, 'modular_redtard/survival/sound/eat.ogg', rand(30, 60), TRUE)
	user.visible_message(span_info("[user] eats from [src]."), span_info("I eat from [src]."))
	reagents.trans_to(user, ROGUE_SPOON_SIP, transferred_by = user, methods = INGEST)
	if(eaten_type)
		rogue_drink_preference(user, eaten_type)
	return ITEM_INTERACT_SUCCESS

/// Ratwood: a noble drinking soup straight from the bowl, without a spoon, minds the bad manners.
/obj/item/reagent_containers/glass/bowl/try_drink(mob/living/target_mob, mob/living/user)
	. = ..()
	if((. & ITEM_INTERACT_SUCCESS) && target_mob == user)
		rogue_noble_bad_manners(user)

/obj/item/reagent_containers/glass/bucket
	initial_reagent_flags = OPENCONTAINER
	amount_per_transfer_from_this = 25
	possible_transfer_amounts = list(25)
	volume = 120
	/// Ratwood bucket filling: up to this amount it looks half full.
	var/rogue_fill_split = 50

/obj/item/reagent_containers/glass/bucket/rogue_fill_state()
	return reagents.total_volume <= rogue_fill_split ? "bucket_half" : "bucket_full"

/obj/item/reagent_containers/glass/bucket/pot
	volume = 240

/obj/item/reagent_containers/glass/bucket/pot/rogue_fill_state()
	return reagents.total_volume <= rogue_fill_split ? "pote_half" : "pote_full"

/// Ratwood pot attackby(): a bowl is filled from the pot, as much as it takes.
/obj/item/reagent_containers/glass/bucket/pot/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/reagent_containers/glass/bowl))
		return fill_bowl(user, tool)
	return ..()

/obj/item/reagent_containers/glass/bucket/pot/proc/fill_bowl(mob/living/user, obj/item/reagent_containers/glass/bowl/bowl)
	if(!reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return ITEM_INTERACT_BLOCKING
	if(bowl.reagents.holder_full())
		to_chat(user, span_warning("[bowl] is full."))
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_notice("Filling the bowl..."))
	playsound(user, pick('modular_redtard/survival/sound/waterwash1.ogg', 'modular_redtard/survival/sound/waterwash2.ogg'), 70, FALSE)
	if(!do_after(user, ROGUE_BOWL_FILL_TIME, target = src))
		return ITEM_INTERACT_BLOCKING
	reagents.trans_to(bowl, reagents.total_volume, transferred_by = user)
	return ITEM_INTERACT_SUCCESS

/obj/item/reagent_containers/glass/bucket/pot/examine(mob/user)
	. = ..()
	. += span_notice("Fill it with water and put it on a hearth: once it boils, drop ingredients in to brew a stew, a porridge or a hot drink. Melt fat in a dry pot for tallow to deep fry in.")

/obj/item/reagent_containers/glass/bucket/pot/stone
	volume = 120

/obj/item/reagent_containers/glass/bucket/pot/decrepit
	volume = 120

/obj/item/reagent_containers/glass/bucket/pot/kettle
	volume = 120

/obj/item/reagent_containers/glass/bucket/pot/kettle/rogue_fill_state()
	return null

/obj/item/reagent_containers/glass/bucket/pot/kettle/tankard
	volume = 60

/obj/item/reagent_containers/glass/bucket/pot/kettle/tankard/silver
	volume = 90

/obj/item/reagent_containers/glass/bucket/pot/kettle/tankard/blacksteel
	volume = 120

/obj/item/reagent_containers/glass/bucket/pot/teapot
	volume = 120

/obj/item/reagent_containers/glass/bucket/pot/teapot/rogue_fill_state()
	return null

/obj/item/reagent_containers/glass/bucket/pot/carved
	volume = 99

/obj/item/reagent_containers/glass/bucket/pot/carved/rogue_fill_state()
	return null

/obj/item/reagent_containers/glass/crucible
	initial_reagent_flags = OPENCONTAINER
	volume = 5

/obj/item/reagent_containers/glass/mortar
	initial_reagent_flags = OPENCONTAINER
	amount_per_transfer_from_this = 9
	possible_transfer_amounts = list(9)
	volume = 100

// Bottles (Ratwood bottle.dm): corked, nothing pours in or out; the hand uncorks them and corks them back.

/obj/item/reagent_containers/glass/bottle
	initial_reagent_flags = TRANSPARENT
	spillable = FALSE
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10)
	volume = 50
	/// Corked (Ratwood closed).
	var/corked = TRUE

/obj/item/reagent_containers/glass/bottle/attack_self(mob/user, modifiers)
	toggle_cork(user)
	return TRUE

/// Ratwood toggle_cork(): open or close the bottle.
/obj/item/reagent_containers/glass/bottle/proc/toggle_cork(mob/user)
	corked = !corked
	if(corked)
		update_container_flags((reagents.flags & ~OPENCONTAINER) | TRANSPARENT)
		spillable = FALSE
		playsound(src, 'modular_redtard/survival/sound/recork.ogg', 100, TRUE)
		to_chat(user, span_smallnotice("I carefully press the cork back into the mouth of [src]."))
	else
		add_container_flags(OPENCONTAINER)
		spillable = TRUE
		playsound(src, 'modular_redtard/survival/sound/uncork.ogg', 100, TRUE)
		to_chat(user, span_smallnotice("I thumb off the cork from [src]."))
	update_appearance()

/obj/item/reagent_containers/glass/bottle/examine(mob/user)
	. = ..()
	. += span_smallnotice((corked ? "It is corked. Use it in hand to uncork it." : "It is uncorked."))

/obj/item/reagent_containers/glass/bottle/alchemical
	volume = 30

/obj/item/reagent_containers/glass/bottle/claybottle
	initial_reagent_flags = OPENCONTAINER
	spillable = TRUE
	corked = FALSE
	volume = 75

/obj/item/reagent_containers/glass/bottle/clayvase
	initial_reagent_flags = OPENCONTAINER
	spillable = TRUE
	corked = FALSE
	volume = 65

/obj/item/reagent_containers/glass/bottle/clayfancyvase
	initial_reagent_flags = OPENCONTAINER
	spillable = TRUE
	corked = FALSE
	volume = 65

/obj/item/reagent_containers/glass/bottle/waterskin
	initial_reagent_flags = OPENCONTAINER
	spillable = TRUE
	corked = FALSE
	possible_transfer_amounts = list(5, 10)
	volume = 75

// Water to fill vessels from (Ratwood turf/open/water attackby(), structures/well.dm).

/// Whether this vessel is used to draw: with Ratwood intents only the fill intent draws (Ratwood), without them any click.
/proc/rogue_vessel_draws(mob/living/user, obj/item/vessel)
	if(!istype(vessel, /obj/item/reagent_containers/glass) || !vessel.is_open_container())
		return FALSE
	var/obj/item/reagent_containers/glass/glass = vessel
	var/datum/intent/intent = glass.rogue_vessel_intent(user)
	return !intent || istype(intent, /datum/intent/fill)

/// Draws the reagents into the vessel after the wait; ITEM_INTERACT_* for the click.
/proc/rogue_draw_into(mob/living/user, obj/item/vessel, atom/source, list/drawn, wait)
	if(vessel.reagents.holder_full())
		to_chat(user, span_warning("[vessel] is full."))
		return ITEM_INTERACT_BLOCKING
	playsound(user, 'modular_redtard/survival/sound/drawwater.ogg', 100, FALSE)
	if(!do_after(user, wait, target = source) || QDELETED(vessel))
		return ITEM_INTERACT_BLOCKING
	vessel.reagents.add_reagent_list(drawn)
	to_chat(user, span_notice("I fill [vessel] from [source]."))
	return ITEM_INTERACT_SUCCESS

/// Ratwood open water fills a vessel at once; what it gives depends on the water (Ratwood water_reagent). The TG scoop of a
/// few units is replaced.
/turf/open/water/rockhill
	reagent_to_extract = null
	/// What a vessel draws here.
	var/datum/reagent/rogue_water_reagent = /datum/reagent/water

/turf/open/water/rockhill/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!rogue_water_reagent || !rogue_vessel_draws(user, tool))
		return ..()
	var/list/drawn = list()
	drawn[rogue_water_reagent] = ROGUE_WATER_FILL
	return rogue_draw_into(user, tool, src, drawn, ROGUE_WATER_FILL_TIME)

/turf/open/water/rockhill/examine(mob/user)
	. = ..()
	if(rogue_water_reagent)
		. += span_info("A vessel could be filled with <b>[initial(rogue_water_reagent.name)]</b> here.")

/turf/open/water/bloody
	rogue_water_reagent = /datum/reagent/blood

/turf/open/water/swamp
	rogue_water_reagent = /datum/reagent/water/gross

/turf/open/water/sewer
	rogue_water_reagent = /datum/reagent/water/gross

/turf/open/water/river/muddy
	rogue_water_reagent = /datum/reagent/water/gross

/turf/open/water/ocean
	rogue_water_reagent = /datum/reagent/water/salt

/turf/open/water/ocean/deep/thermalwater
	rogue_water_reagent = /datum/reagent/water

/// Ratwood wells give a bucket water, fountains fill any vessel; the dubious well poisons, the swamp fountain is dirty.
/obj/structure/well
	/// What one draw gives.
	var/list/rogue_well_reagents = list(/datum/reagent/water = ROGUE_WELL_WATER)
	/// Only a bucket reaches the water (Ratwood wells; fountains take any vessel).
	var/rogue_well_bucket_only = TRUE
	var/rogue_well_time = ROGUE_WELL_TIME

/obj/structure/well/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/reagent_containers/glass) || !length(rogue_well_reagents))
		return ..()
	if(rogue_well_bucket_only && !istype(tool, /obj/item/reagent_containers/glass/bucket))
		to_chat(user, span_warning("I need a bucket."))
		return ITEM_INTERACT_BLOCKING
	if(!tool.is_open_container())
		to_chat(user, span_warning("[tool] is corked!"))
		return ITEM_INTERACT_BLOCKING
	return rogue_draw_into(user, tool, src, rogue_well_reagents, rogue_well_time)

/obj/structure/well/poisoned
	rogue_well_reagents = list(/datum/reagent/water = ROGUE_WELL_WATER / 5, /datum/reagent/toxin = ROGUE_WELL_WATER / 5)
	rogue_well_time = ROGUE_WELL_TIME * 3

/obj/structure/well/fountain
	rogue_well_bucket_only = FALSE

/obj/structure/well/fountainswamp
	rogue_well_bucket_only = FALSE
	rogue_well_reagents = list(/datum/reagent/water/gross = ROGUE_WELL_WATER)

// Wood bins (Ratwood farming/bin.dm, big_liquid_containers.dm) on medieval maps: a washbin holds six hundred units of what is
// poured into it (the water bins of the map come with water, clean or dirty) and things besides. A hand opens it; a right click
// washes oneself, or what is in the hand, in its water, which takes some and leaves the rest dirty; a strong kick knocks it over,
// spilling the water around and the things out, and a right click stands it up again. Rain fills a bin under the open sky.
// Vessels draw from it and pour into it (rogue_pour() above); tongs quench in it (crafting/tongs.dm). Trash bins hold no water.

#define BIN_WASH_SOUNDS list('modular_redtard/survival/sound/waterwash1.ogg', 'modular_redtard/survival/sound/waterwash2.ogg')
#define BIN_KICK_SOUND 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg'

/// The bins that hold water, for the rain to fill.
GLOBAL_LIST_EMPTY(rogue_water_bins)
/// What fills them while it rains (/datum/rogue_rain_catcher).
GLOBAL_DATUM(rogue_rain_catcher, /datum/rogue_rain_catcher)

/obj/item/roguebin
	/// Ratwood: a trash bin holds no water (only washbins get reagents).
	var/rogue_holds_water = TRUE
	/// Ratwood kover: knocked over by a kick; it is stood up again by a right click.
	var/rogue_tipped = FALSE
	/// Ratwood base_state: the bin's own sprite, under the filling and in its fall.
	var/rogue_bin_state
	/// What the bin comes with from the map (Ratwood /water and /water/gross bins).
	var/datum/reagent/rogue_start_water

/obj/item/roguebin/trash
	rogue_holds_water = FALSE

/obj/item/roguebin/water
	rogue_start_water = /datum/reagent/water

/obj/item/roguebin/water/gross
	rogue_start_water = /datum/reagent/water/gross

/obj/item/roguebin/Initialize(mapload)
	. = ..()
	rogue_bin_state = icon_state
	if(rogue_holds_water)
		// Ratwood draws a washbin as either of its two bins.
		if(icon_state == "washbin1")
			rogue_bin_state = "washbin[rand(1, 2)]"
		create_reagents(rogue_value("bin_volume"), DRAINABLE | REFILLABLE | AMOUNT_VISIBLE)
		RegisterSignal(reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(rogue_bin_changed))
		if(rogue_start_water)
			reagents.add_reagent(rogue_start_water, rogue_value("bin_start_water"))
		GLOB.rogue_water_bins += src
		if(!GLOB.rogue_rain_catcher)
			GLOB.rogue_rain_catcher = new
	update_appearance()

/obj/item/roguebin/Destroy()
	GLOB.rogue_water_bins -= src
	return ..()

/obj/item/roguebin/proc/rogue_bin_changed(datum/reagents/holder)
	SIGNAL_HANDLER
	update_appearance()

/obj/item/roguebin/update_icon_state()
	if(rogue_bin_state)
		icon_state = rogue_tipped ? "[rogue_bin_state]over" : rogue_bin_state
	return ..()

/// Ratwood update_icon(): the water shows in the colour of what is in it.
/obj/item/roguebin/update_overlays()
	. = ..()
	if(rogue_tipped || !reagents?.total_volume)
		return
	var/mutable_appearance/filling = mutable_appearance(icon, "liquid2")
	filling.color = mix_color_from_reagents(reagents.reagent_list)
	. += filling

/obj/item/roguebin/examine(mob/user)
	. = ..()
	if(rogue_tipped)
		. += span_warning("It has been knocked over.")
	else if(rogue_holds_water && rogue_survival_enabled())
		. += span_notice("Right-click it to wash yourself, or what is in your hand, in its water.")

/// Ratwood attack_hand(): a hand opens the bin standing on the floor; it is moved by pulling, never carried.
/obj/item/roguebin/attack_hand(mob/user, list/modifiers)
	if(!rogue_survival_enabled() || !isturf(loc) || !atom_storage)
		return ..()
	atom_storage.open_storage(user)
	return TRUE

/// Ratwood attack_right() with an empty hand: stand the bin up, or wash in it.
/obj/item/roguebin/attack_hand_secondary(mob/user, list/modifiers)
	if(!rogue_survival_enabled() || !isliving(user) || !isturf(loc) || (!rogue_tipped && !rogue_holds_water))
		return ..()
	var/mob/living/washer = user
	if(washer.stat != STABLE)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(rogue_tipped)
		INVOKE_ASYNC(src, PROC_REF(rogue_stand_up), washer)
	else
		INVOKE_ASYNC(src, PROC_REF(rogue_bin_wash), washer)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Ratwood attack_right() with something in the hand: wash it in the bin (or stand the fallen bin up).
/obj/item/roguebin/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	if(!rogue_survival_enabled() || !isturf(loc) || !rogue_holds_water || user.stat != STABLE)
		return ..()
	if(rogue_tipped)
		INVOKE_ASYNC(src, PROC_REF(rogue_stand_up), user)
	else
		INVOKE_ASYNC(src, PROC_REF(rogue_bin_wash), user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/item/roguebin/proc/rogue_stand_up(mob/living/user)
	user.visible_message(span_notice("[user] starts to pick up [src]..."), span_notice("I start to pick up [src]..."))
	if(!do_after(user, rogue_value("bin_upright_time"), src) || !rogue_tipped)
		return
	rogue_tipped = FALSE
	update_appearance()

/// Ratwood attack_right(): a wash takes a little clean water (dirty water when there is no clean), and whatever clean water is
/// left goes dirty - even when the wash is cut short.
/obj/item/roguebin/proc/rogue_bin_wash(mob/living/washer, obj/item/tool)
	if(!rogue_take_wash_water())
		to_chat(washer, span_warning("No water to wash these stains."))
		return
	playsound(washer, pick(BIN_WASH_SOUNDS), 100, FALSE)
	if(tool)
		washer.visible_message(span_info("[washer] starts to wash [tool] in [src]."))
		if(do_after(washer, rogue_value("wash_time"), src) && !QDELETED(tool) && washer.is_holding(tool))
			tool.wash(CLEAN_SCRUB)
			washer.update_held_items()
			playsound(washer, pick(BIN_WASH_SOUNDS), 100, FALSE)
	else
		washer.visible_message(span_info("[washer] starts to wash in [src]."))
		if(do_after(washer, rogue_value("wash_time"), src))
			rogue_bin_washed(washer)
	rogue_dirty_water()

/// The water one wash takes: clean if there is enough, else dirty. FALSE when there is not enough of either.
/obj/item/roguebin/proc/rogue_take_wash_water()
	var/needed = rogue_value("bin_wash_water")
	if(reagents?.has_reagent(/datum/reagent/water, needed))
		reagents.remove_reagent(/datum/reagent/water, needed)
		return TRUE
	if(reagents?.has_reagent(/datum/reagent/water/gross, needed))
		reagents.remove_reagent(/datum/reagent/water/gross, needed)
		return TRUE
	return FALSE

/// Ratwood: washing in a bin cleans, puts out fire and cools a hot body (less than open water does).
/obj/item/roguebin/proc/rogue_bin_washed(mob/living/washer)
	washer.rogue_wash_body()
	washer.extinguish_mob()
	washer.rogue_chill(rogue_value("bin_wash_cooling"), rogue_value("swim_cold_floor"))
	playsound(washer, pick(BIN_WASH_SOUNDS), 100, FALSE)

/// Ratwood: what was washed (or quenched) in the bin leaves all its clean water dirty.
/obj/item/roguebin/proc/rogue_dirty_water()
	var/datum/reagent/clean = reagents?.has_reagent(/datum/reagent/water)
	if(!clean)
		return
	var/amount = clean.volume
	reagents.remove_reagent(/datum/reagent/water, amount)
	reagents.add_reagent(/datum/reagent/water/gross, amount)

/// Ratwood onkick(): a kick knocks a standing bin over with a chance by the kicker's strength.
/obj/item/roguebin/rogue_onkick(mob/living/carbon/human/kicker)
	playsound(src, BIN_KICK_SOUND, 100)
	if(rogue_tipped || !prob(kicker.rogue_stat(ROGUE_STAT_STRENGTH) * rogue_value("bin_kick_chance")))
		kicker.visible_message(span_warning("[kicker] kicks [src]!"), span_warning("I kick [src]!"))
		return
	kicker.visible_message(span_warning("[kicker] kicks over [src]!"), span_warning("I kick over [src]!"))
	rogue_tip_over()

/// Ratwood kover: the bin falls, its water splashes all around and what is in it spills out.
/obj/item/roguebin/proc/rogue_tip_over()
	rogue_tipped = TRUE
	if(reagents?.total_volume)
		chem_splash(get_turf(src), null, rogue_value("bin_splash_range"), list(reagents), adminlog = FALSE)
		reagents.clear_reagents()
	atom_storage?.remove_all(drop_location())
	update_appearance()

/// Ratwood rain reaction_obj(): rain pours into a standing bin under the open sky.
/obj/item/roguebin/proc/rogue_catch_rain(seconds)
	if(rogue_tipped || !reagents || !isturf(loc))
		return
	reagents.add_reagent(/datum/reagent/water, rogue_value("bin_rain_water") * seconds)

/// Fills the bins under the sky while it rains: wakes when a rain starts (TG's weather signals), sleeps when none falls.
/datum/rogue_rain_catcher

/datum/rogue_rain_catcher/New()
	. = ..()
	for(var/datum/weather/particle/rockhill/rain_type as anything in valid_subtypesof(/datum/weather/particle/rockhill))
		if(initial(rain_type.rockhill_douses_fires))
			RegisterSignal(SSdcs, COMSIG_WEATHER_START(rain_type), PROC_REF(on_rain))

/datum/rogue_rain_catcher/proc/on_rain(datum/source, datum/weather/rain)
	SIGNAL_HANDLER
	START_PROCESSING(SSobj, src)

/datum/rogue_rain_catcher/process(seconds_per_tick)
	var/datum/weather/particle/rockhill/weather = SSrockhill_weather.active_weather()
	if(!weather?.rockhill_douses_fires)
		return PROCESS_KILL
	for(var/obj/item/roguebin/bin as anything in GLOB.rogue_water_bins)
		if(rogue_rain_falls_on(bin))
			bin.rogue_catch_rain(seconds_per_tick)

#undef BIN_WASH_SOUNDS
#undef BIN_KICK_SOUND
