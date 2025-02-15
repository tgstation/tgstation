/obj/item/knife/poison
	name = "venom knife"
	icon = 'modular_meta/features/venom_knife/icons/stabby.dmi'
	icon_state = "buckknife"
	worn_icon_state = "buckknife"
	force = 18
	throwforce = 18
	throw_speed = 5
	throw_range = 7
	var/amount_per_transfer_from_this = 10
	var/list/possible_transfer_amounts
	var/turf/location
	desc = "An infamous knife of syndicate design, \
	it has a tiny hole going through the blade to the handle which stores toxins."

/obj/item/knife/poison/Initialize(mapload)
	. = ..()
	create_reagents(40,OPENCONTAINER)
	possible_transfer_amounts = list(5, 10)

/obj/item/knife/poison/attack_self(mob/user)
	if(possible_transfer_amounts.len)
		var/i=0
		for(var/amount in possible_transfer_amounts)
			i++
			if(amount == amount_per_transfer_from_this)
				if(i<possible_transfer_amounts.len)
					amount_per_transfer_from_this = possible_transfer_amounts[i+1]
				else
					amount_per_transfer_from_this = possible_transfer_amounts[1]
				balloon_alert(user, "Transferring [amount_per_transfer_from_this]u.")
				to_chat(user, "<span class='notice'>[src]'s transfer amount is now [amount_per_transfer_from_this] units.</span>")
				return

/obj/item/knife/poison/afterattack(mob/living/enemy, mob/user)
	location = get_turf(src)
	if(istype(enemy)) // Вызывает рантаймы, если удар пришёлся не на моба, а на какой-то другой объект.
		if(enemy.can_inject() && prob(65)) // Проверяет на хардсуиты, модсуиты или еву, я бы ещё сделал чтобы он блокировался сековской бронёй, но увы такими знаниями не обладаю.
			reagents.trans_to(enemy, amount_per_transfer_from_this)
		else
			to_chat(usr, span_warning("[enemy]'s armor is too thick to penetrate."))
		if(reagents.has_reagent(/datum/reagent/toxin/initropidril))
			to_chat(usr, span_warning("The knife violently explodes in your hand!"))
			user.visible_message(span_warning("[user]'s knife violently explodes in their hand!"), ignored_mobs = user)
			explosion(location, 0, 0, 1, 1, 0) // Придумайте лучше способ наказывать людей не умеющих читать маленький красный текст, такой взрыв к слову оторвёт руку в 100% случаев, но не введёт в крит при полном здоровье.
			qdel(src)
	return

/obj/item/knife/poison/click_alt(mob/user)
	. = ..()
	if(!reagents.has_reagent(/datum/reagent/ , check_subtypes = TRUE))
		to_chat(usr, span_warning("There's no reagents to remove from knife's internal compartment."))
		return CLICK_ACTION_BLOCKING
	else
		to_chat(usr, span_notice("You empty the knife's internal compartment from reagents."))
		reagents.clear_reagents()
	return CLICK_ACTION_SUCCESS

/obj/item/knife/poison/examine(mob/user)
	. = ..()
	. += span_notice("Use in-hand to to increase or decrease its transfer amount. \
	Each hit has a 65% chance to transfer reagents from knife's internal storage to your victim, \
	however spaceproof armor, like a MOD-suit will prevent reagent transfer.")
	. += span_warning("Warning! Adding initropidril will cause the knife to malfunction and cause serious trouble to the user")

/obj/item/knife/poison/suicide_act(mob/living/user)
	if (reagents.has_reagent(/datum/reagent/toxin/initropidril))
		user.visible_message(span_suicide("[user] is trying to drink the initropidril from the knife!"))
		playsound(src, 'sound/items/drink.ogg', 115, TRUE, -1)
		reagents.clear_reagents()
		spawn(10)
			explosion(src, 0, 1, 1, 1, 0) // Почему взрыв? — Описано выше.
			qdel(src)
			spawn(15)
				user.gib(DROP_ALL_REMAINS)
				new /obj/effect/gibspawner(get_turf(user)) // gibs не разлетаются по разным тайлам, нужно использовать get_step, но а что если оно в стену улетит?
		return BRUTELOSS

	else if (reagents.has_reagent(/datum/reagent/toxin, check_subtypes = TRUE))
		user.visible_message(span_suicide("[user] is trying to drink the poison from the knife!"))
		playsound(src, 'sound/items/drink.ogg', 50, TRUE, -1)
		reagents.clear_reagents()
		return TOXLOSS
	else
		user.visible_message(span_suicide("[user] slits their throat with [src]!"))
		playsound(src, 'sound/effects/butcher.ogg', 25, TRUE, -1)
		spawn(5)
			playsound(src, 'sound/effects/wounds/blood3.ogg', 50, TRUE, -1)
		return BRUTELOSS
