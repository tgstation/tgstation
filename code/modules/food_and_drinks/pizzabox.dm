/obj/item/bombcore/miniature/pizza
	name = "pizza bomb"
	desc = "Special delivery!"
	icon_state = "pizzabomb_inactive"
	inhand_icon_state = "eshield"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'

/obj/item/pizzabox
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "pizzabox"
	base_icon_state = "pizzabox"
	inhand_icon_state = "pizzabox"
	lefthand_file = 'icons/mob/inhands/items/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/food_righthand.dmi'
	custom_materials = list(/datum/material/cardboard = 2000)

	var/open = FALSE
	var/can_open_on_fall = TRUE //if FALSE, this pizza box will never open if it falls from a stack
	/// Used so that you can not destroy the infinite pizza box
	var/foldable = TRUE
	var/boxtag = ""
	///Used to make sure artisinal box tags aren't overwritten.
	var/boxtag_set = FALSE
	var/list/boxes = list()

	var/obj/item/food/pizza/pizza

	var/obj/item/bombcore/miniature/pizza/bomb
	var/bomb_active = FALSE // If the bomb is counting down.
	var/bomb_defused = TRUE // If the bomb is inert.
	var/bomb_timer = 1 // How long before blowing the bomb, in seconds.
	/// Min bomb timer allowed in seconds
	var/bomb_timer_min = 1
	/// Max bomb timer allower in seconds
	var/bomb_timer_max = 20

/obj/item/pizzabox/Initialize(mapload)
	. = ..()
	if(pizza)
		pizza = new pizza
	update_appearance()
	register_context()

/obj/item/pizzabox/Destroy()
	unprocess()
	return ..()

/obj/item/pizzabox/update_desc()
	desc = initial(desc)
	. = ..()
	if(pizza && pizza.boxtag && !boxtag_set)
		boxtag = pizza.boxtag
		boxtag_set = TRUE
	if(open)
		if(pizza)
			desc = "[desc] It appears to have \a [pizza] inside. Use your other hand to take it out."
		if(bomb)
			desc = "[desc] Wait, what?! It has \a [bomb] inside!"
			if(bomb_defused)
				desc = "[desc] The bomb seems inert. Use your other hand to activate it."
			if(bomb_active)
				desc = "[desc] It looks like it's about to go off!"
	else
		var/obj/item/pizzabox/box = length(boxes) ? boxes[length(boxes)] : src
		if(length(boxes))
			desc = "A pile of boxes suited for pizzas. There appear to be [length(boxes) + 1] boxes in the pile."
		if(box.boxtag != "")
			desc = "[desc] The [length(boxes) ? "top box" : "box"]'s tag reads: [box.boxtag]"

/obj/item/pizzabox/update_icon_state()
	if(!open)
		icon_state = "[base_icon_state]"
		return ..()

	icon_state = pizza ? "[base_icon_state]_messy" : "[base_icon_state]_open"
	bomb?.icon_state = "pizzabomb_[bomb_active ? "active" : "inactive"]"
	return ..()

/obj/item/pizzabox/update_overlays()
	. = ..()
	if(open)
		if(pizza)
			var/mutable_appearance/pizza_overlay = mutable_appearance(pizza.icon, pizza.icon_state)
			pizza_overlay.pixel_y = -2
			. += pizza_overlay
		if(bomb)
			var/mutable_appearance/bomb_overlay = mutable_appearance(bomb.icon, bomb.icon_state)
			bomb_overlay.pixel_y = 8
			. += bomb_overlay
		return

	var/box_offset = 0
	for(var/stacked_box in boxes)
		box_offset += 3
		var/obj/item/pizzabox/box = stacked_box
		var/mutable_appearance/box_overlay = mutable_appearance(box.icon, box.icon_state)
		box_overlay.pixel_y = box_offset
		. += box_overlay

	var/obj/item/pizzabox/box = LAZYLEN(length(boxes)) ? boxes[length(boxes)] : src
	if(box.boxtag != "")
		var/mutable_appearance/tag_overlay = mutable_appearance(icon, "pizzabox_tag")
		tag_overlay.pixel_y = box_offset
		. += tag_overlay

/obj/item/pizzabox/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	var/current_offset = 2
	if(!isinhands)
		return

	for(var/V in boxes) //add EXTRA BOX per box
		var/mutable_appearance/M = mutable_appearance(icon_file, inhand_icon_state)
		M.pixel_y = current_offset
		current_offset += 2
		. += M

/obj/item/pizzabox/attack_self(mob/user)
	if(length(boxes) > 0)
		return
	open = !open
	if(open && !bomb_defused)
		audible_message(span_warning("[icon2html(src, hearers(src))] *beep*"))
		bomb_active = TRUE
		START_PROCESSING(SSobj, src)
	update_appearance()

/obj/item/pizzabox/attack_self_secondary(mob/user)
	if(length(boxes) > 0)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(pizza || bomb || !foldable)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/obj/item/stack/sheet/cardboard/cardboard = new(user.drop_location())
	user.put_in_active_hand(cardboard)
	qdel(src)
	return SECONDARY_ATTACK_CONTINUE_CHAIN

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/pizzabox/attack_hand(mob/user, list/modifiers)
	if(user.get_inactive_held_item() != src)
		return ..()
	if(open)
		if(pizza)
			user.put_in_hands(pizza)
			pizza = null
			update_appearance()
		else if(bomb)
			if(wires.is_all_cut() && bomb_defused)
				user.put_in_hands(bomb)
				balloon_alert(user, "removed bomb")
				bomb = null
				update_appearance()
				return
			else
				bomb_timer = tgui_input_number(user, "Set the bomb timer", "Pizza Bomb", bomb_timer, bomb_timer_max, bomb_timer_min)
				if(!bomb_timer || QDELETED(user) || QDELETED(src) || !usr.canUseTopic(src, be_close = TRUE, no_dexterity = FALSE, no_tk = TRUE))
					return
				bomb_defused = FALSE
				log_bomber(user, "has trapped a", src, "with [bomb] set to [bomb_timer] seconds")
				bomb.adminlog = "The [bomb.name] in [src.name] that [key_name(user)] activated has detonated!"
				balloon_alert(user, "bomb set")
				update_appearance()
	else if(length(boxes))
		var/obj/item/pizzabox/topbox = boxes[length(boxes)]
		boxes -= topbox
		user.put_in_hands(topbox)
		topbox.update_appearance()
		update_appearance()
		user.regenerate_icons()

/obj/item/pizzabox/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pizzabox))
		var/obj/item/pizzabox/newbox = I
		if(!open && !newbox.open)
			var/list/add = list()
			add += newbox
			add += newbox.boxes
			if(!user.transferItemToLoc(newbox, src))
				return
			boxes += add
			newbox.boxes.Cut()
			newbox.update_appearance()
			update_appearance()
			user.regenerate_icons()
			if(length(boxes) >= 5)
				if(prob(10 * length(boxes)))
					user.balloon_alert_to_viewers("oops!")
					disperse_pizzas()
				else
					balloon_alert(user, "looks unstable...")
			return
		else
			balloon_alert(user, "close it first!")
	else if(istype(I, /obj/item/food/pizza))
		if(open)
			if(pizza)
				balloon_alert(user, "it's full!")
				return
			if(!user.transferItemToLoc(I, src))
				return
			pizza = I
			update_appearance()
			return
	else if(istype(I, /obj/item/bombcore/miniature/pizza))
		if(open && !bomb)
			if(!user.transferItemToLoc(I, src))
				return
			wires = new /datum/wires/explosive/pizza(src)
			bomb = I
			balloon_alert(user, "bomb placed")
			update_appearance()
			return
		else if(bomb)
			balloon_alert(user, "already rigged!")
	else if(istype(I, /obj/item/pen))
		if(!open)
			if(!user.can_write(I))
				return
			var/obj/item/pizzabox/box = length(boxes) ? boxes[length(boxes)] : src
			box.boxtag += tgui_input_text(user, "Write on [box]'s tag:", box, max_length = 30)
			if(!user.canUseTopic(src, be_close = TRUE))
				return
			balloon_alert(user, "writing box tag...")
			boxtag_set = TRUE
			update_appearance()
			return
	else if(is_wire_tool(I))
		if(wires && bomb)
			wires.interact(user)
	..()

/obj/item/pizzabox/process(delta_time)
	if(bomb_active && !bomb_defused && (bomb_timer > 0))
		playsound(loc, 'sound/items/timer.ogg', 50, FALSE)
		bomb_timer -= delta_time
	if(bomb_active && !bomb_defused && (bomb_timer <= 0))
		if(bomb in src)
			bomb.detonate()
			unprocess()
			qdel(src)
	if(!bomb_active || bomb_defused)
		if(bomb_defused && (bomb in src))
			bomb.defuse()
			bomb_active = FALSE
			unprocess()
	return

/obj/item/pizzabox/attack(mob/living/target, mob/living/user, def_zone)
	. = ..()
	if(length(boxes) >= 3 && prob(25 * length(boxes)))
		disperse_pizzas()

/obj/item/pizzabox/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(length(boxes) >= 2 && prob(20 * length(boxes)))
		disperse_pizzas()

/obj/item/pizzabox/examine(mob/user)
	. = ..()
	if(isobserver(user))
		if(bomb)
			. += span_deadsay("This pizza box contains [bomb_defused ? "an unarmed bomb" : "an armed bomb"].")
		if(pizza && istype(pizza, /obj/item/food/pizza/margherita/robo))
			. += span_deadsay("The pizza in this pizza box contains nanomachines.")

/obj/item/pizzabox/proc/disperse_pizzas()
	visible_message(span_warning("The pizzas fall everywhere!"))
	for(var/V in boxes)
		var/obj/item/pizzabox/P = V
		var/fall_dir = pick(GLOB.alldirs)
		step(P, fall_dir)
		if(P.pizza && P.can_open_on_fall && prob(50)) //rip pizza
			P.open = TRUE
			P.pizza.forceMove(get_turf(P))
			fall_dir = pick(GLOB.alldirs)
			step(P.pizza, fall_dir)
			P.pizza = null
			P.update_appearance()
		boxes -= P
	update_appearance()
	if(isliving(loc))
		var/mob/living/L = loc
		L.regenerate_icons()

/obj/item/pizzabox/proc/unprocess()
	STOP_PROCESSING(SSobj, src)
	qdel(wires)
	wires = null
	update_appearance()

/obj/item/pizzabox/bomb/Initialize(mapload)
	. = ..()
	if(!pizza)
		var/randompizza = pick(subtypesof(/obj/item/food/pizza))
		pizza = new randompizza(src)
	bomb = new(src)
	wires = new /datum/wires/explosive/pizza(src)

/obj/item/pizzabox/bomb/armed
	bomb_timer = 5
	bomb_defused = FALSE
	boxtag = "Meat Explosion"
	boxtag_set = TRUE
	pizza = /obj/item/food/pizza/meat

/obj/item/pizzabox/margherita
	pizza = /obj/item/food/pizza/margherita

/obj/item/pizzabox/margherita/robo
	pizza = /obj/item/food/pizza/margherita/robo

/obj/item/pizzabox/vegetable
	pizza = /obj/item/food/pizza/vegetable

/obj/item/pizzabox/mushroom
	pizza = /obj/item/food/pizza/mushroom

/obj/item/pizzabox/meat
	pizza = /obj/item/food/pizza/meat

/obj/item/pizzabox/pineapple
	pizza = /obj/item/food/pizza/pineapple

//An anomalous pizza box that, when opened, produces the opener's favorite kind of pizza.
/obj/item/pizzabox/infinite
	resistance_flags = FIRE_PROOF | LAVA_PROOF | ACID_PROOF //hard to destroy
	can_open_on_fall = FALSE
	foldable = FALSE
	boxtag = "Your Favourite" //used to give it a tag overlay, shouldn't be seen by players
	///List of pizzas this box can spawn. Weighted by chance to be someone's favorite.
	var/list/pizza_types = list(
		/obj/item/food/pizza/meat = 10,
		/obj/item/food/pizza/mushroom = 10,
		/obj/item/food/pizza/margherita = 10,
		/obj/item/food/pizza/sassysage = 8,
		/obj/item/food/pizza/vegetable = 8,
		/obj/item/food/pizza/pineapple = 5,
		/obj/item/food/pizza/donkpocket = 3,
		/obj/item/food/pizza/dank = 1,
	)
	///List of ckeys and their favourite pizzas. e.g. pizza_preferences[ckey] = /obj/item/food/pizza/meat
	var/static/list/pizza_preferences

/obj/item/pizzabox/infinite/Initialize(mapload)
	. = ..()
	if(!pizza_preferences)
		pizza_preferences = list()

/obj/item/pizzabox/infinite/examine(mob/user)
	if(!open && ishuman(user))
		attune_pizza(user) //pizza tag changes based on examiner
	. = ..()
	if(isobserver(user))
		. += span_deadsay("This pizza box is anomalous, and will produce infinite pizza.")

/obj/item/pizzabox/infinite/attack_self(mob/living/user)
	if(ishuman(user))
		attune_pizza(user)
		to_chat(user, span_notice("Another pizza immediately appears in the box, what the hell?"))
	return ..()

/obj/item/pizzabox/infinite/proc/attune_pizza(mob/living/carbon/human/nommer) //tonight on "proc names I never thought I'd type"
	if(!nommer.ckey)
		return

	//list our ckey and assign it a favourite pizza
	if(!pizza_preferences[nommer.ckey])
		if(nommer.has_quirk(/datum/quirk/pineapple_liker))
			pizza_preferences[nommer.ckey] = /obj/item/food/pizza/pineapple
		else if(nommer.has_quirk(/datum/quirk/pineapple_hater))
			var/list/pineapple_pizza_liker = pizza_types.Copy()
			pineapple_pizza_liker -= /obj/item/food/pizza/pineapple
			pizza_preferences[nommer.ckey] = pick_weight(pineapple_pizza_liker)
		else if(nommer.mind?.assigned_role.title == /datum/job/botanist)
			pizza_preferences[nommer.ckey] = /obj/item/food/pizza/dank
		else
			pizza_preferences[nommer.ckey] = pick_weight(pizza_types)
	if(pizza)
		//if the pizza isn't our favourite, delete it
		if(pizza.type != pizza_preferences[nommer.ckey])
			QDEL_NULL(pizza)
		else
			pizza.foodtypes = nommer.dna.species.liked_food //make sure it's our favourite
			return

	var/obj/item/food/pizza/favourite_pizza_type = pizza_preferences[nommer.ckey]
	pizza = new favourite_pizza_type
	boxtag_set = FALSE
	update_appearance() //update our boxtag to match our new pizza
	pizza.foodtypes = nommer.dna.species.liked_food //it's our favorite!

///screentips for pizzaboxes
/obj/item/pizzabox/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(!held_item)
		if(user.get_inactive_held_item() != src)
			return NONE
		if(open)
			if(pizza)
				context[SCREENTIP_CONTEXT_LMB] = "Remove pizza"
			else if(bomb && wires.is_all_cut() && bomb_defused)
				context[SCREENTIP_CONTEXT_LMB] = "Remove bomb"
		else
			if(length(boxes) > 0)
				context[SCREENTIP_CONTEXT_LMB] = "Remove pizza box"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item == src)
		if(length(boxes) > 0)
			return NONE
		context[SCREENTIP_CONTEXT_LMB] = open ? "Close" : "Open"
		if(!pizza && !bomb && foldable)
			context[SCREENTIP_CONTEXT_RMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/pizzabox))
		if(!open)
			context[SCREENTIP_CONTEXT_LMB] = "Stack pizza box"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/food/pizza))
		if(open && !pizza)
			context[SCREENTIP_CONTEXT_LMB] = "Place pizza"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/pen))
		if(!open)
			context[SCREENTIP_CONTEXT_LMB] = "Write boxtag"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/bombcore/miniature/pizza))
		if(open && !bomb)
			context[SCREENTIP_CONTEXT_LMB] = "Place bomb"
		return CONTEXTUAL_SCREENTIP_SET

	if(is_wire_tool(held_item))
		if(open && bomb)
			context[SCREENTIP_CONTEXT_LMB] = "Access wires"
		return CONTEXTUAL_SCREENTIP_SET
