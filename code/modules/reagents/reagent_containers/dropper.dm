/obj/item/reagent_containers/dropper
	name = "dropper"
	desc = "A dropper. Holds up to 5 units."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "dropper0"
	inhand_icon_state = "dropper"
	worn_icon_state = "pen"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(1, 2, 3, 4, 5)
	volume = 5
	reagent_flags = TRANSPARENT
	custom_price = PAYCHECK_CREW

/obj/item/reagent_containers/dropper/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	if(!target.reagents)
		return

	if(reagents.total_volume > 0)
		if(target.reagents.holder_full())
			to_chat(user, span_notice("[target] is full."))
			return

		if(!target.is_injectable(user))
			to_chat(user, span_warning("You cannot transfer reagents to [target]!"))
			return

		var/trans = 0
		var/fraction = min(amount_per_transfer_from_this / reagents.total_volume, 1)

		if(ismob(target))
			if(ishuman(target))
				var/mob/living/carbon/human/victim = target

				var/obj/item/safe_thing = victim.is_eyes_covered()

				if(safe_thing)
					if(!safe_thing.reagents)
						safe_thing.create_reagents(100)

					trans = reagents.trans_to(safe_thing, amount_per_transfer_from_this, transferred_by = user, methods = TOUCH)

					target.visible_message(span_danger("[user] tries to squirt something into [target]'s eyes, but fails!"), \
											span_userdanger("[user] tries to squirt something into your eyes, but fails!"))

					to_chat(user, span_notice("You transfer [round(trans, 0.01)] unit\s of the solution."))
					update_appearance()
					return
			else if(isalien(target)) //hiss-hiss has no eyes!
				to_chat(target, span_danger("[target] does not seem to have any eyes!"))
				return

			target.visible_message(span_danger("[user] squirts something into [target]'s eyes!"), \
									span_userdanger("[user] squirts something into your eyes!"))

			reagents.expose(target, TOUCH, fraction)
			var/mob/M = target
			var/R
			if(reagents)
				for(var/datum/reagent/A in src.reagents.reagent_list)
					R += "[A] ([num2text(A.volume)]),"

			log_combat(user, M, "squirted", R)

		trans = src.reagents.trans_to(target, amount_per_transfer_from_this, transferred_by = user)
		to_chat(user, span_notice("You transfer [round(trans, 0.01)] unit\s of the solution."))
		update_appearance()
		target.update_appearance()

	else

		if(!target.is_drawable(user, FALSE)) //No drawing from mobs here
			to_chat(user, span_warning("You cannot directly remove reagents from [target]!"))
			return

		if(!target.reagents.total_volume)
			to_chat(user, span_warning("[target] is empty!"))
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, transferred_by = user)

		to_chat(user, span_notice("You fill [src] with [round(trans, 0.01)] unit\s of the solution."))

		update_appearance()
		target.update_appearance()

/obj/item/reagent_containers/dropper/update_overlays()
	. = ..()
	if(!reagents.total_volume)
		return
	var/mutable_appearance/filling = mutable_appearance('icons/obj/medical/reagent_fillings.dmi', "dropper")
	filling.color = mix_color_from_reagents(reagents.reagent_list)
	. += filling
