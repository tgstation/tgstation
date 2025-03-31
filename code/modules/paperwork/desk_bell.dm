// A receptionist's bell

/obj/structure/desk_bell
	name = "desk bell"
	desc = "The cornerstone of any customer service job. You feel an unending urge to ring it."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "desk_bell"
	layer = OBJ_LAYER
	anchored = FALSE
	pass_flags = PASSTABLE // Able to place on tables
	max_integrity = 5000 // To make attacking it not instantly break it
	throwforce = 2
	interaction_flags_mouse_drop = NEED_HANDS

	/// The amount of times this bell has been rang, used to check the chance it breaks
	var/times_rang = 0
	/// Is this bell broken?
	var/broken_ringer = FALSE
	/// The cooldown for ringing the bell
	COOLDOWN_DECLARE(ring_cooldown)
	/// The length of the cooldown. Setting it to 0 will skip all cooldowns alltogether.
	var/ring_cooldown_length = 0.3 SECONDS // This is here to protect against tinnitus.
	/// The sound the bell makes
	var/ring_sound = 'sound/machines/microwave/microwave-end.ogg'

/obj/structure/desk_bell/Initialize(mapload)
	. = ..()
	register_context()

/obj/structure/desk_bell/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(held_item?.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_RMB] = "Disassemble"
		return CONTEXTUAL_SCREENTIP_SET

	if(broken_ringer)
		if(held_item?.tool_behaviour == TOOL_SCREWDRIVER)
			context[SCREENTIP_CONTEXT_LMB] = "Fix"
	else
		var/click_context = "Ring"
		if(prob(1))
			click_context = "Annoy"
		context[SCREENTIP_CONTEXT_LMB] = click_context
	return CONTEXTUAL_SCREENTIP_SET

/obj/structure/desk_bell/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!COOLDOWN_FINISHED(src, ring_cooldown) && ring_cooldown_length)
		return TRUE
	if(!ring_bell(user))
		to_chat(user, span_notice("[src] is silent. Some idiot broke it."))
	if(ring_cooldown_length)
		COOLDOWN_START(src, ring_cooldown, ring_cooldown_length)
	return TRUE

/obj/structure/desk_bell/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/desk_bell/attackby(obj/item/weapon, mob/living/user, list/modifiers)
	. = ..()
	times_rang += weapon.force
	ring_bell(user)

/obj/structure/desk_bell/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	ring_bell()

// Fix the clapper
/obj/structure/desk_bell/screwdriver_act(mob/living/user, obj/item/tool)
	if(broken_ringer)
		balloon_alert(user, "repairing...")
		tool.play_tool_sound(src)
		if(tool.use_tool(src, user, 5 SECONDS))
			balloon_alert_to_viewers("repaired")
			playsound(user, 'sound/items/tools/change_drill.ogg', 50, vary = TRUE)
			broken_ringer = FALSE
			times_rang = 0
			return ITEM_INTERACT_SUCCESS
		return FALSE
	return ..()

// Deconstruct
/obj/structure/desk_bell/wrench_act_secondary(mob/living/user, obj/item/tool)
	balloon_alert(user, "taking apart...")
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 5 SECONDS))
		balloon_alert(user, "disassembled")
		playsound(user, 'sound/items/deconstruct.ogg', 50, vary = TRUE)
		if(!broken_ringer) // Drop 2 if it's not broken.
			new/obj/item/stack/sheet/iron(drop_location())
		new/obj/item/stack/sheet/iron(drop_location())
		qdel(src)
		return ITEM_INTERACT_SUCCESS
	return ..()

/// Check if the clapper breaks, and if it does, break it
/obj/structure/desk_bell/proc/check_clapper(mob/living/user)
	if(((times_rang >= 10000) || prob(times_rang/100)) && ring_cooldown_length)
		if (user)
			to_chat(user, span_notice("You hear [src]'s clapper fall off of its hinge. Nice job, you broke it."))
		else
			audible_message(span_notice("You hear [src]'s clapper fall off of its hinge. Nice job, you broke it."))
		broken_ringer = TRUE

/// Ring the bell
/obj/structure/desk_bell/proc/ring_bell(mob/living/user)
	if(broken_ringer)
		return FALSE
	check_clapper(user)
	// The lack of varying is intentional. The only variance occurs on the strike the bell breaks.
	playsound(src, ring_sound, 70, vary = broken_ringer, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	flick("desk_bell_ring", src)
	times_rang++
	return TRUE

/obj/structure/desk_bell/mouse_drop_dragged(atom/over_object, mob/user)
	if(over_object != user)
		return FALSE
	var/obj/item/inhand_desk_bell/held_bell = new (user, src)
	user.put_in_hands(held_bell, del_on_fail = FALSE)

// A warning to all who enter; the ringing sound STACKS. It won't be deafening because it only goes every decisecond,
// but I did feel like my ears were going to start bleeding when I tested it with my autoclicker.
/obj/structure/desk_bell/speed_demon
	desc = "The cornerstone of any customer service job. This one's been modified for hyper-performance."
	ring_cooldown_length = 0

/// Handheld bell
/obj/item/inhand_desk_bell
	name = "held desk bell"
	force = 1
	w_class = WEIGHT_CLASS_SMALL
	obj_flags = CONDUCTS_ELECTRICITY
	force = 1
	throwforce = 2
	/// Our contained bell
	var/obj/structure/desk_bell/bell

/obj/item/inhand_desk_bell/Initialize(mapload, obj/structure/desk_bell/bell)
	if (mapload)
		stack_trace("You shouldn't map in this item, use /obj/structure/desk_bell")
	if (!bell)
		return INITIALIZE_HINT_QDEL
	register_item_context()
	src.bell = bell
	bell.forceMove(src)
	appearance = bell.appearance
	RegisterSignals(bell, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(on_bell_gone))
	return ..()

/// If we don't have a bell we're nothing
/obj/item/inhand_desk_bell/proc/on_bell_gone()
	SIGNAL_HANDLER
	UnregisterSignal(bell, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	bell = null
	qdel(src)

/obj/item/inhand_desk_bell/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	. = NONE
	if(istype(target, /obj/vehicle/ridden/wheelchair))
		var/obj/vehicle/ridden/wheelchair/chair = target
		if(!chair.bell_attached)
			context[SCREENTIP_CONTEXT_LMB] = "Attach bell to wheelchair."
			return CONTEXTUAL_SCREENTIP_SET

/obj/item/inhand_desk_bell/examine(mob/user)
	return bell.examine(user)

/obj/item/inhand_desk_bell/on_thrown(mob/living/carbon/user, atom/target)
	var/obj/throwing_bell = bell // We are about to null this variable but also want to return it
	bell.forceMove(user.drop_location())
	return throwing_bell

/obj/item/inhand_desk_bell/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if (isturf(loc))
		bell.forceMove(loc)

/obj/item/inhand_desk_bell/attack(mob/living/target_mob, mob/living/user, params)
	. = ..()
	if (.)
		return
	bell.ring_bell(user)

/obj/item/inhand_desk_bell/attack_self(mob/user, modifiers)
	. = ..()
	if (.)
		return
	bell.ring_bell(user)

/obj/item/inhand_desk_bell/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if (!istype(interacting_with, /obj/vehicle/ridden/wheelchair))
		return NONE
	var/obj/vehicle/ridden/wheelchair/chair = interacting_with

	if (chair.bell_attached)
		user.balloon_alert(user, "already has a bell!")
		return ITEM_INTERACT_FAILURE
	user.balloon_alert(user, "attaching bell...")
	if (!do_after(user, 0.5 SECONDS, chair))
		return ITEM_INTERACT_FAILURE

	chair.attach_bell(bell)
	return ITEM_INTERACT_SUCCESS
