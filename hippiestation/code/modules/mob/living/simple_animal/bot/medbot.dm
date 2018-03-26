/mob/living/simple_animal/bot/medbot/medicate_patient(mob/living/carbon/C)
	. = ..()
	if (.)
		var/obj/item/reagent_containers/food/snacks/lollipop/L = new(C.loc)

		if(C.put_in_hands(L))
			visible_message("<span class='notice'>[src] dispenses a lollipop into the hands of [C].</span>")
		else
			visible_message("<span class='notice'>[src] dispenses a lollipop.</span>")

		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
