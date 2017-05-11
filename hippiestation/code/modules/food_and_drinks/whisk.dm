/obj/item/weapon/whisk
	name = "whisk"
	desc = "A kitchen device used to stir things."
	icon = 'hippiestation/icons/obj/weapons.dmi'
	icon_state = "whisk"

/obj/item/weapon/whisk/afterattack(atom/target, mob/user)
	if(istype(target, /obj))
		var/obj/O = target
		if(O.container_type & OPENCONTAINER && O.reagents.total_volume && do_mob(user, user, 5))
			to_chat(user, "<span class='notice'>You stir the contents inside [O].</span>")
			if (O.reagents.has_reagent("milk"))
				var/numberofsticks = round(O.reagents.get_reagent_amount("milk") / 15)
				if(numberofsticks)
					to_chat(user, "<span class='notice'>It yields [numberofsticks] sticks of butter!</span>")
				while(O.reagents.get_reagent_amount("milk") >= 15) //Butter
					O.reagents.remove_reagent("milk", 15)
					new /obj/item/weapon/reagent_containers/food/snacks/butter(O.loc)
			if (O.reagents.has_reagent("eggyolk")) //Mayonaise
				var/amount = O.reagents.get_reagent_amount("eggyolk")
				O.reagents.remove_reagent("eggyolk", amount)
				O.reagents.add_reagent("mayonnaise", amount)
				to_chat(user, "<span class='notice'>It yields some mayonaise!</span>")
	return

/obj/item/weapon/whisk/stirring_rod //In case chemistry would like one.
	name = "stirring rod"
	desc = "A stick of glass that is surprisingly strong and good at mixing."
	icon_state = "stirring_rod"
