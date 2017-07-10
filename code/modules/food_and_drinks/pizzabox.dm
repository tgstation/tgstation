/obj/item/weapon/bombcore/pizza
	parent_type = /obj/item/weapon/bombcore/miniature
	name = "pizza bomb"
	desc = "Special delivery!"
	icon_state = "pizzabomb_inactive"
	item_state = "eshield0"
	origin_tech = "syndicate=3;engineering=3"

/obj/item/pizzabox
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "pizzabox1"
	item_state = "pizzabox"

	var/open = FALSE
	var/boxtag = ""
	var/list/boxes = list()

	var/obj/item/weapon/reagent_containers/food/snacks/pizza/pizza

	var/obj/item/weapon/bombcore/pizza/bomb
	var/bomb_active = FALSE // If the bomb is counting down.
	var/bomb_defused = TRUE // If the bomb is inert.
	var/bomb_timer = 1 // How long before blowing the bomb.
	var/const/BOMB_TIMER_MIN = 1
	var/const/BOMB_TIMER_MAX = 10

/obj/item/pizzabox/New()
	update_icon()
	..()

/obj/item/pizzabox/Destroy()
	unprocess()
	return ..()

/obj/item/pizzabox/update_icon()
	// Description
	desc = initial(desc)
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
		var/obj/item/pizzabox/box = boxes.len ? boxes[boxes.len] : src
		if(boxes.len)
			desc = "A pile of boxes suited for pizzas. There appears to be [boxes.len + 1] boxes in the pile."
		if(box.boxtag != "")
			desc = "[desc] The [boxes.len ? "top box" : "box"]'s tag reads: [box.boxtag]"

	// Icon/Overlays
	cut_overlays()
	if(open)
		icon_state = "pizzabox_open"
		if(pizza)
			icon_state = "pizzabox_messy"
			var/mutable_appearance/pizza_overlay = mutable_appearance(pizza.icon, pizza.icon_state)
			pizza_overlay.pixel_y = -3
			add_overlay(pizza_overlay)
		if(bomb)
			bomb.icon_state = "pizzabomb_[bomb_active ? "active" : "inactive"]"
			var/mutable_appearance/bomb_overlay = mutable_appearance(bomb.icon, bomb.icon_state)
			bomb_overlay.pixel_y = 5
			add_overlay(bomb_overlay)
	else
		icon_state = "pizzabox[boxes.len + 1]"
		var/obj/item/pizzabox/box = boxes.len ? boxes[boxes.len] : src
		if(box.boxtag != "")
			var/mutable_appearance/tag_overlay = mutable_appearance(icon, "pizzabox_tag")
			tag_overlay.pixel_y = boxes.len * 3
			add_overlay(tag_overlay)

/obj/item/pizzabox/attack_self(mob/user)
	if(boxes.len > 0)
		return
	open = !open
	if(open && !bomb_defused)
		audible_message("<span class='warning'>[bicon(src)] *beep*</span>")
		bomb_active = TRUE
		START_PROCESSING(SSobj, src)
	update_icon()

/obj/item/pizzabox/attack_hand(mob/user)
	if(user.get_inactive_held_item() != src)
		..()
		return
	if(open)
		if(pizza)
			user.put_in_hands(pizza)
			to_chat(user, "<span class='notice'>You take [pizza] out of [src].</span>")
			pizza = null
			update_icon()
			return
		else if(bomb)
			if(wires.is_all_cut() && bomb_defused)
				user.put_in_hands(bomb)
				to_chat(user, "<span class='notice'>You carefully remove the [bomb] from [src].</span>")
				bomb = null
				update_icon()
				return
			else
				bomb_timer = input(user, "Set the [bomb] timer from [BOMB_TIMER_MIN] to [BOMB_TIMER_MAX].", bomb, bomb_timer) as num
				bomb_timer = Clamp(Ceiling(bomb_timer / 2), BOMB_TIMER_MIN, BOMB_TIMER_MAX)
				bomb_defused = FALSE

				var/message = "[ADMIN_LOOKUPFLW(user)] has trapped a [src] with [bomb] set to [bomb_timer * 2] seconds."
				GLOB.bombers += message
				message_admins(message)
				log_game("[key_name(user)] has trapped a [src] with [bomb] set to [bomb_timer * 2] seconds.")
				bomb.adminlog = "The [bomb.name] in [src.name] that [key_name(user)] activated has detonated!"

				to_chat(user, "<span class='warning'>You trap [src] with [bomb].</span>")
				update_icon()
			return
	else if(boxes.len)
		var/obj/item/pizzabox/topbox = boxes[boxes.len]
		boxes -= topbox
		user.put_in_hands(topbox)
		to_chat(user, "<span class='notice'>You remove the topmost [name] from the stack.</span>")
		topbox.update_icon()
		update_icon()
		return
	..()

/obj/item/pizzabox/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pizzabox))
		var/obj/item/pizzabox/newbox = I
		if(!open && !newbox.open)
			var/list/add = list()
			add += newbox
			add += newbox.boxes

			if((boxes.len + 1) + add.len <= 5)
				if(!user.drop_item())
					return
				boxes += add
				newbox.boxes.Cut()
				newbox.loc = src
				to_chat(user, "<span class='notice'>You put [newbox] on top of [src]!</span>")
				newbox.update_icon()
				update_icon()
				return
			else
				to_chat(user, "<span class='notice'>The stack is dangerously high!</span>")
		else
			to_chat(user, "<span class='notice'>Close [open ? src : newbox] first!</span>")
	else if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/pizza) || istype(I, /obj/item/weapon/reagent_containers/food/snacks/customizable/pizza))
		if(open)
			if(!user.drop_item())
				return
			pizza = I
			I.loc = src
			to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
			update_icon()
			return
	else if(istype(I, /obj/item/weapon/bombcore/pizza))
		if(open && !bomb)
			if(!user.drop_item())
				return
			wires = new /datum/wires/explosive/pizza(src)
			bomb = I
			I.loc = src
			to_chat(user, "<span class='notice'>You put [I] in [src]. Sneeki breeki...</span>")
			update_icon()
			return
		else if(bomb)
			to_chat(user, "<span class='notice'>[src] already has a bomb in it!</span>")
	else if(istype(I, /obj/item/weapon/pen))
		if(!open)
			var/obj/item/pizzabox/box = boxes.len ? boxes[boxes.len] : src
			box.boxtag += stripped_input(user, "Write on [box]'s tag:", box, "", 30)
			to_chat(user, "<span class='notice'>You write with [I] on [src].</span>")
			update_icon()
			return
	else if(is_wire_tool(I))
		if(wires && bomb)
			wires.interact(user)
	else if(istype(I, /obj/item/weapon/reagent_containers/food))
		to_chat(user, "<span class='notice'>That's not a pizza!</span>")
	..()

/obj/item/pizzabox/process()
	if(bomb_active && !bomb_defused && (bomb_timer > 0))
		playsound(loc, 'sound/items/timer.ogg', 50, 0)
		bomb_timer--
	if(bomb_active && !bomb_defused && (bomb_timer <= 0))
		if(bomb in src)
			bomb.detonate()
			unprocess()
			qdel(src)
	if(!bomb_active || bomb_defused)
		if(bomb_defused && bomb in src)
			bomb.defuse()
			bomb_active = FALSE
			unprocess()
	return

/obj/item/pizzabox/proc/unprocess()
	STOP_PROCESSING(SSobj, src)
	qdel(wires)
	wires = null
	update_icon()

/obj/item/pizzabox/bomb/New()
	var/randompizza = pick(subtypesof(/obj/item/weapon/reagent_containers/food/snacks/pizza))
	pizza = new randompizza(src)
	bomb = new(src)
	wires = new /datum/wires/explosive/pizza(src)
	..()

/obj/item/pizzabox/margherita/New()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/pizza/margherita(src)
	boxtag = "Margherita Deluxe"
	..()

/obj/item/pizzabox/vegetable/New()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/pizza/vegetable(src)
	boxtag = "Gourmet Vegatable"
	..()

/obj/item/pizzabox/mushroom/New()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/pizza/mushroom(src)
	boxtag = "Mushroom Special"
	..()

/obj/item/pizzabox/meat/New()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/pizza/meat(src)
	boxtag = "Meatlover's Supreme"
	..()
