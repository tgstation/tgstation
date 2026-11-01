/// Ratwood's pumpkins (code/modules/farming/shellplant.dm): a short blade cuts a pumpkin open for a spoon to scoop out its flesh a
/// chunk at a time, leaving the empty shell and its seeds; a chopping blow cuts it all into slices; a blunt blow smashes it for its
/// seeds. A short blade carves the shell into one of the pumpkin lanterns: Ratwood picks the design in a TGUI window, here a
/// radial menu.
///
/// The pumpkin, its shell and most lanterns are Ratwood's but not in the port yet (the zumpkin lantern is). The pumpkin path is
/// left to the porter on purpose: economy/trade_data.dm trades it as soon as it exists, and a pumpkin declared here would be an
/// item without a sprite. So the pumpkin's ways are on the shellplant root (Ratwood's only shellplant is the pumpkin), and its
/// numbers - foodamt, foodextracted, seed, shell - come with it from the porter. Until then the pumpkin is not sown
/// (/datum/plant_def/can_grow()) and no lantern without its sprite is offered.
/obj/item/natural/shellplant
	abstract_type = /obj/item/natural/shellplant
	/// How many pieces of flesh it holds (Ratwood foodamt).
	var/foodamt = 1
	/// The flesh it gives (Ratwood foodextracted).
	var/foodextracted = null
	/// Its seeds (Ratwood seed).
	var/seed = null
	/// What is left when it is scooped out (Ratwood shell).
	var/shell = null
	/// Cut open, so that a spoon reaches the flesh (Ratwood open).
	var/open = FALSE

/obj/item/natural/shellplant/examine(mob/user)
	. = ..()
	if(open)
		. += span_smallnotice("It is open and I could use a spoon to extract its flesh.")
		. += span_smallnotice("It has [foodamt] chunks remaining.")
	else
		. += span_smallnotice("I could cut it open to reach inside, chop it into slices or squash it for seeds.")

/// Ratwood pumpkin attackby(): by the intent's class of blow - a short cutting blade opens it, a chopping blow slices it all, a
/// blunt blow smashes it for its seeds - or a spoon scoops it out once it is open.
/obj/item/natural/shellplant/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!isliving(user))
		return ..()
	var/datum/intent/intent = user.rogue_active_intent()
	var/blade_class = intent?.noaa ? null : intent?.blade_class
	if(blade_class == BCLASS_CUT && tool.wlength == WLENGTH_SHORT)
		if(!open && do_after(user, rogue_value("farm_pumpkin_work_time"), target = src))
			playsound(get_turf(user), 'modular_redtard/survival/sound/slicing.ogg', 60, TRUE, -1)
			icon_state = "[initial(icon_state)]-open"
			open = TRUE
		return ITEM_INTERACT_SUCCESS
	if(blade_class == BCLASS_CHOP)
		if(do_after(user, rogue_value("farm_pumpkin_work_time"), target = src))
			playsound(get_turf(user), 'modular_redtard/survival/sound/chopping_block.ogg', 60, TRUE, -1)
			if(foodextracted)
				var/atom/spot = drop_location()
				for(var/i in 1 to foodamt)
					new foodextracted(spot)
			qdel(src)
		return ITEM_INTERACT_SUCCESS
	if(blade_class == BCLASS_BLUNT)
		if(seed)
			rogue_drop_seeds(seed, user)
		else
			qdel(src)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/kitchen/spoon) && open)
		if(do_after(user, rogue_value("farm_pumpkin_work_time"), target = src) && foodamt > 0)
			if(foodextracted)
				new foodextracted(drop_location())
				user.visible_message(span_notice("[user] carves out the [src]'s plant flesh."), span_notice("I carve out the [src]'s flesh."))
			foodamt--
			if(foodamt <= 0)
				if(shell)
					new shell(drop_location())
				if(seed)
					rogue_drop_seeds(seed, user)
				else
					qdel(src)
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/item/pumpkinshell/examine(mob/user)
	. = ..()
	. += span_smallnotice("Using a small blade, I could stab or cut it into a variety of decorations.")

/// Ratwood pumpkinshell attackby(): a short blade cutting or stabbing carves it.
/obj/item/pumpkinshell/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!isliving(user) || tool.wlength != WLENGTH_SHORT)
		return ..()
	var/datum/intent/intent = user.rogue_active_intent()
	if(!intent || intent.noaa || (intent.blade_class != BCLASS_CUT && intent.blade_class != BCLASS_STAB))
		return ..()
	rogue_carve(user)
	return ITEM_INTERACT_SUCCESS

/// Ratwood's carving window (ui_act() choose_carving): pick a design, two seconds of carving, and the shell is that lantern.
/obj/item/pumpkinshell/proc/rogue_carve(mob/living/user)
	var/list/choices = list()
	var/list/designs = list()
	for(var/obj/item/lantern as anything in rogue_pumpkin_lanterns())
		var/design = initial(lantern.name)
		designs[design] = lantern
		choices[design] = image(icon = initial(lantern.icon), icon_state = initial(lantern.icon_state))
	if(!length(choices))
		to_chat(user, span_warning("I can't think of anything to carve into [src]."))
		return
	var/picked = show_radial_menu(user, src, choices, require_near = TRUE, tooltips = TRUE)
	if(!picked || QDELETED(src) || !rogue_holds_blade(user))
		return
	user.visible_message(span_notice("[user] begins to carve a [picked]."), span_notice("I begin carving a [picked]."))
	if(!do_after(user, rogue_value("farm_pumpkin_carve_time"), target = src))
		return
	playsound(get_turf(user), 'modular_redtard/survival/sound/slicing.ogg', 60, TRUE, -1)
	var/lantern_type = designs[picked]
	new lantern_type(drop_location())
	qdel(src)

/// Whether the carver still holds a short blade, so a carving is not finished with the knife put away.
/obj/item/pumpkinshell/proc/rogue_holds_blade(mob/living/user)
	var/obj/item/held = user.get_active_held_item()
	return held?.wlength == WLENGTH_SHORT

/// Ratwood's pumpkin lanterns (typesof(/obj/item/flashlight/flare/torch/lantern/pumpkin)) that have their sprite: until the porter
/// brings the others, the lantern line holds only the zumpkin lantern and a bare parent without a pumpkin sprite.
/proc/rogue_pumpkin_lanterns()
	var/static/list/lanterns
	if(!lanterns)
		lanterns = list()
		for(var/obj/item/lantern as anything in typesof(/obj/item/flashlight/flare/torch/lantern/pumpkin))
			if(findtext(initial(lantern.icon_state), "pumpkinlamp") == 1)
				lanterns += lantern
	return lanterns
