/obj/item/cortical_cage
	name = "cortical borer cage"
	desc = "A harmless cage that is intended to capture cortical borers."
	icon = 'monkestation/code/modules/antagonists/borers/icons/items.dmi'
	icon_state = "cage"

	///If true, the trap is "open" and can trigger.
	var/opened = FALSE
	///The radio that is inserted into the trap.
	var/obj/item/radio/internal_radio
	///The borer that is inside the trap
	var/mob/living/basic/cortical_borer/trapped_borer

/obj/item/cortical_cage/Initialize(mapload)
	. = ..()
	update_appearance()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(spring_trap),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/cortical_cage/update_overlays()
	. = ..()
	if(trapped_borer)
		. += "borer"
	if(internal_radio)
		. += "radio"
	if(opened)
		. += "doors_open"
	else
		. += "doors_closed"

/obj/item/cortical_cage/attack_self(mob/user, modifiers)
	opened = !opened
	if(opened)
		user.visible_message("[user] opens [src].", "You open [src].", "You hear a metallic thunk.")
	else
		user.visible_message("[user] closes [src].", "You close [src].", "You hear a metallic thunk.")
	playsound(src, 'sound/machines/boltsup.ogg', 30, TRUE)
	update_appearance()

/obj/item/cortical_cage/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/radio))
		internal_radio = attacking_item
		internal_radio.forceMove(src)
		visible_message("[internal_radio] attaches to [src] with a click.", "You attach [internal_radio] to the [src].", "You hear a clicking sound.")
		update_appearance()
		return
	return ..()

/obj/item/cortical_cage/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(internal_radio)
		internal_radio.forceMove(drop_location())
		user.visible_message("[internal_radio] pops off [src].", "You pop off [internal_radio] from [src].", "You hear a clicking sound then a loud metallic thunk.")
		internal_radio = null
		update_appearance()
		return

/obj/item/cortical_cage/proc/spring_trap(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	//it will only trigger on a cortical borer, and it has to be opened
	if(!iscorticalborer(AM) || !opened)
		return
	trapped_borer = AM
	trapped_borer.visible_message("[trapped_borer] gets sucked into [src]!", "You get sucked into [src]!", "You hear a vacuuming sound.")
	trapped_borer.forceMove(src)
	opened = FALSE
	if(internal_radio)
		var/area/src_area = get_area(src)
		internal_radio.talk_into(src, "A cortical borer has been trapped in [src_area].", RADIO_CHANNEL_COMMON)
	playsound(src, 'sound/machines/boltsup.ogg', 30, TRUE)
	update_appearance()

/obj/item/cortical_cage/relaymove(mob/living/user, direction)
	if(!iscorticalborer(user))
		user.forceMove(drop_location())
		update_appearance()
		return
	if(opened)
		loc.visible_message(span_notice("[user] climbs out of [src]!"), \
		span_warning("[user] jumps out of [src]!"))
		opened = FALSE
		trapped_borer.forceMove(drop_location())
		trapped_borer = null
		update_appearance()
		return
	else if(user.client)
		container_resist_act(user)

/obj/item/cortical_cage/container_resist_act(mob/living/user)
	user.changeNext_move(CLICK_CD_BREAKOUT)
	COOLDOWN_START(user, last_special, CLICK_CD_BREAKOUT)
	to_chat(user, span_notice("You begin squeezing through the bars in an attempt to escape! (This will take time.)"))
	to_chat(loc, span_warning("You see [user] begin trying to squeeze through the bars!"))
	if(!do_after(user, rand(30 SECONDS, 40 SECONDS), target = user) || opened || !(user in contents))
		return
	loc.visible_message(span_warning("[user] squeezes through [src]'s handles!"), ignored_mobs = user)
	to_chat(user, span_boldannounce("Bingo, you squeeze through!"))
	opened = FALSE
	trapped_borer.forceMove(drop_location())
	trapped_borer = null
	update_appearance()
