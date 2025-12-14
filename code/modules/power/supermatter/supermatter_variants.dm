/// Normal SM with it's processing disabled.
/obj/machinery/power/supermatter_crystal/hugbox
	disable_damage = TRUE
	disable_gas =  TRUE
	disable_power_change = TRUE
	disable_process = SM_PROCESS_DISABLED

/// Normal SM designated as main engine.
/obj/machinery/power/supermatter_crystal/engine
	is_main_engine = TRUE

/// Shard SM.
/obj/machinery/power/supermatter_crystal/shard
	name = "supermatter shard"
	desc = "A strangely translucent and iridescent crystal that looks like it used to be part of a larger structure."
	base_icon_state = "sm_shard"
	icon_state = "sm_shard"
	anchored = FALSE
	absorption_ratio = 0.125
	explosion_power = 12
	layer = ABOVE_MOB_LAYER
	moveable = TRUE


/obj/machinery/power/supermatter_crystal/shard/Initialize(mapload)
	. = ..()

	register_context()


/obj/machinery/power/supermatter_crystal/shard/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(held_item?.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = anchored ? "Unanchor" : "Anchor"
		return CONTEXTUAL_SCREENTIP_SET


/// Shard SM with it's processing disabled.
/obj/machinery/power/supermatter_crystal/shard/hugbox
	name = "anchored supermatter shard"
	disable_damage = TRUE
	disable_gas =  TRUE
	disable_power_change = TRUE
	disable_process = SM_PROCESS_DISABLED
	moveable = FALSE
	anchored = TRUE

/// Shard SM designated as the main engine.
/obj/machinery/power/supermatter_crystal/shard/engine
	name = "anchored supermatter shard"
	is_main_engine = TRUE
	anchored = TRUE
	moveable = FALSE

/// Normal sm but small (sm sword recipe element) (wiz only) and adamantine pedestal for it
/obj/machinery/power/supermatter_crystal/small
	name = "strangely small supermatter crystal"
	desc = "A strangely translucent and iridescent crystal on an adamantine pedestal. It looks like it should be a bit bigger..."
	base_icon_state = "sm_small"
	icon_state = "sm_small"
	moveable = TRUE
	anchored = FALSE

/obj/machinery/power/supermatter_crystal/small/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps, "Adamantium Signal")
	priority_announce("Anomalous crystal detected onboard. Location is marked on every GPS device.", "Nanotrasen Anomaly Department Announcement")

/obj/item/adamantine_pedestal
	name = "adamantine pedestal"
	desc = "An adamantine pedestal. It looks like it should have something small but massive on top."
	icon = 'icons/obj/machines/engine/supermatter.dmi'
	icon_state = "pedestal"
	w_class = WEIGHT_CLASS_HUGE
	throw_speed = 1
	throw_range = 1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
