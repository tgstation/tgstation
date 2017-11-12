/obj/item/whisk
	name = "whisk"
	desc = "A kitchen device used to stir things."
	icon = 'hippiestation/icons/obj/items_and_weapons.dmi'
	icon_state = "whisk"

/obj/item/whisk/afterattack(atom/target, mob/user)
	if(istype(target, /obj))
		var/obj/O = target
		if(O.container_type & OPENCONTAINER_1 && O.reagents.total_volume)
			to_chat(user, "<span class='notice'>You begin to stir the contents inside [O].</span>")
			while(O.reagents.get_reagent_amount("milk") >= 15) //Butter
				if(do_mob(user, user, 5))
					O.reagents.remove_reagent("milk", 15)
					new /obj/item/reagent_containers/food/snacks/butter(O.loc)
					to_chat(user, "<span class='notice'>It yields a stick of butter!</span>")
			if (O.reagents.has_reagent("eggyolk") && do_mob(user, user, 5)) //Mayonaise
				var/amount = O.reagents.get_reagent_amount("eggyolk")
				O.reagents.remove_reagent("eggyolk", amount)
				O.reagents.add_reagent("mayonnaise", amount)
				to_chat(user, "<span class='notice'>It yields some mayonaise!</span>")
	return

/obj/item/whisk/stirring_rod //In case chemistry would like one.
	name = "stirring rod"
	desc = "A stick of glass that is surprisingly strong and good at mixing."
	icon_state = "stirring_rod"
