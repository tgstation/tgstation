

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass
	name = "drinking glass"
	desc = "Your standard drinking glass."
	icon_state = "glass_empty"
	amount_per_transfer_from_this = 10
	volume = 50
	materials = list(MAT_GLASS=500)
	obj_integrity = 20
	max_integrity = 20
	spillable = 1
	resistance_flags = ACID_PROOF
	unique_rename = 1

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/on_reagent_change()
	cut_overlays()
	if (reagents.reagent_list.len > 0)
		var/datum/reagent/largest_reagent = reagents.get_master_reagent()
		if(largest_reagent)
			if(largest_reagent.glass_name)
				name = "[largest_reagent.glass_name]"

				if(largest_reagent.glass_desc)
					desc = "[largest_reagent.glass_desc]"

				if(largest_reagent.glass_icon_state)
					icon_state = "[largest_reagent.glass_icon_state]"
				else
					icon_state = "glass_clear"
					var/image/I = image(icon, "glassoverlay")
					I.color = largest_reagent.color
					add_overlay(I) // looking at you, grape soda!
			else
				icon_state ="glass_clear"
				var/image/I = image(icon, "glassoverlay")
				I.color = mix_color_from_reagents(reagents.reagent_list)
				add_overlay(I)
				name = "glass of ..what?"
				desc = "You can't really tell what this is."
	else
		icon_state = "glass_empty"
		name = "drinking glass"
		desc = "Your standard drinking glass."
		return

//Shot glasses!//
//  This lets us add shots in here instead of lumping them in with drinks because >logic  //
//  The format for shots is the exact same as iconstates for the drinking glass, except you use a shot glass instead.  //
//  If it's a new drink, remember to add it to Chemistry-Reagents.dm  and Chemistry-Recipes.dm as well.  //
//  You can only mix the ported-over drinks in shot glasses for now (they'll mix in a shaker, but the sprite won't change for glasses). //
//  This is on a case-by-case basis, and you can even make a seperate sprite for shot glasses if you want. //

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass
	name = "shot glass"
	desc = "A shot glass - the universal symbol for bad decisions."
	icon_state = "shotglass"
	gulp_size = 15
	amount_per_transfer_from_this = 15
	possible_transfer_amounts = list()
	volume = 15
	materials = list(MAT_GLASS=100)

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass/on_reagent_change()
	if (gulp_size < 15)
		gulp_size = 15
	else
		gulp_size = max(round(reagents.total_volume / 15), 15)

	if (reagents.reagent_list.len > 0)
		switch(reagents.get_master_reagent_id())
			if("vodka")
				icon_state = "shotglassclear"
				name = "shot of vodka"
				desc = "Good for cold weather."
			if("water")
				icon_state = "shotglassclear"
				name = "shot of water"
				desc = "You're not sure why someone would drink this from a shot glass."
			if("whiskey")
				icon_state = "shotglassbrown"
				name = "shot of whiskey"
				desc = "Just like the old west."
			if("hcider")
				icon_state = "shotglassbrown"
				name = "shot of hard cider"
				desc = "Not meant to be drunk from a shot glass."
			if("rum")
				icon_state = "shotglassbrown"
				name = "shot of rum"
				desc = "You dirty pirate."
			if("b52")
				icon_state = "b52glass"
				name = "B-52"
				desc = "Kahlua, Irish Cream, and cognac. You will get bombed."
			if("toxinsspecial")
				icon_state = "toxinsspecialglass"
				name = "Toxins Special"
				desc = "Whoah, this thing is on FIRE!"
			if ("vermouth")
				icon_state = "shotglassclear"
				name = "shot of vermouth"
				desc = "This better be going in a martini."
			if ("tequila")
				icon_state = "shotglassgold"
				name = "shot of tequila"
				desc = "Bad decisions ahead!"
			if ("patron")
				icon_state = "shotglassclear"
				name = "shot of patron"
				desc = "The good stuff. Goes great with a lime wedge."
			if ("kahlua")
				icon_state = "shotglasscream"
				name = "shot of coffee liqueur"
				desc = "Doesn't look too appetizing..."
			if ("nothing")
				icon_state = "shotglass"
				name = "shot of nothing"
				desc = "The mime insists there's booze in the glass. You're not so sure."
			if ("goldschlager")
				icon_state = "shotglassgold"
				name = "shot of goldschlager"
				desc = "Yup. You're officially a college girl."
			if ("cognac")
				icon_state = "shotglassbrown"
				name = "shot of cognac"
				desc = "You get the feeling this would piss off a rich person somewhere."
			if ("wine")
				icon_state = "shotglassred"
				name = "shot of wine"
				desc = "What kind of craven oaf would drink wine from a shot glass?"
			if ("blood")
				icon_state = "shotglassred"
				name = "shot of blood"
				desc = "If you close your eyes it sort of tastes like wine..."
			if ("liquidgibs")
				icon_state = "shotglassred"
				name = "shot of gibs"
				desc = "...Let's not talk about this."
			if ("absinthe")
				icon_state = "shotglassgreen"
				name = "shot of absinthe"
				desc = "I am stuck in the cycles of my guilt..."
			else
				icon_state = "shotglassbrown"
				name = "shot of... what?"
				desc = "You can't really tell what's in the glass."
	else
		icon_state = "shotglass"
		name = "shot glass"
		desc = "A shot glass - the universal symbol for bad decisions."
		return

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/filled/New()
	..()
	on_reagent_change()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/filled/soda
	name = "Soda Water"
	list_reagents = list("sodawater" = 50)

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/filled/cola
	name = "Space Cola"
	list_reagents = list("cola" = 50)

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/filled/nuka_cola
	name = "Nuka Cola"
	list_reagents = list("nuka_cola" = 50)

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/attackby(obj/item/I, mob/user, params)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/egg)) //breaking eggs
		var/obj/item/weapon/reagent_containers/food/snacks/egg/E = I
		if(reagents)
			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, "<span class='notice'>[src] is full.</span>")
			else
				to_chat(user, "<span class='notice'>You break [E] in [src].</span>")
				reagents.add_reagent("eggyolk", 5)
				qdel(E)
			return
	else
		..()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/attack(obj/target, mob/user)
	if(user.a_intent == INTENT_HARM && ismob(target) && target.reagents && reagents.total_volume)
		target.visible_message("<span class='danger'>[user] splashes the contents of [src] onto [target]!</span>", \
						"<span class='userdanger'>[user] splashes the contents of [src] onto [target]!</span>")
		add_logs(user, target, "splashed", src)
		reagents.reaction(target, TOUCH)
		reagents.clear_reagents()
		return
	..()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/afterattack(obj/target, mob/user, proximity)
	if((!proximity) || !check_allowed_items(target,target_self=1))
		return

	else if(reagents.total_volume && user.a_intent == INTENT_HARM)
		user.visible_message("<span class='danger'>[user] splashes the contents of [src] onto [target]!</span>", \
							"<span class='notice'>You splash the contents of [src] onto [target].</span>")
		reagents.reaction(target, TOUCH)
		reagents.clear_reagents()
		return
	..()

