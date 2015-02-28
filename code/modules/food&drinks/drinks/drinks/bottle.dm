

///////////////////////////////////////////////Alchohol bottles! -Agouri //////////////////////////
//Functionally identical to regular drinks. The only difference is that the default bottle size is 100. - Darem
//Bottles now weaken and break when smashed on people's heads. - Giacom

/obj/item/weapon/reagent_containers/food/drinks/bottle
	amount_per_transfer_from_this = 10
	volume = 100
	item_state = "broken_beer" //Generic held-item sprite until unique ones are made.
	var/const/duration = 13 //Directly relates to the 'weaken' duration. Lowered by armor (i.e. helmets)
	var/isGlass = 1 //Whether the 'bottle' is made of glass or not so that milk cartons dont shatter when someone gets hit by it
	var/canfirebomb = 0 //can we be a firebomb?
	var/lit = 0 //are we lit?
	var/toohottohandle = 0 //drop firebombs after they get too hot

/obj/item/weapon/reagent_containers/food/drinks/bottle/proc/smash(mob/living/target as mob, mob/living/user as mob)

	//Creates a shattering noise and replaces the bottle with a broken_bottle
	user.drop_item()
	var/obj/item/weapon/broken_bottle/B = new /obj/item/weapon/broken_bottle(user.loc)
	user.put_in_active_hand(B)
	if(prob(33))
		new/obj/item/weapon/shard(target.loc) // Create a glass shard at the target's location!
	if(rigged)
		rigged.loc = user.loc
		rigged = null
	B.icon_state = src.icon_state

	var/icon/I = new('icons/obj/drinks.dmi', src.icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I

	playsound(src, "shatter", 70, 1)
	user.put_in_active_hand(B)
	src.transfer_fingerprints_to(B)

	qdel(src)

/obj/item/weapon/reagent_containers/food/drinks/bottle/proc/thrown_shatter()
	var/obj/item/weapon/broken_bottle/B = new /obj/item/weapon/broken_bottle(src.loc)
	if(prob(33))
		new/obj/item/weapon/shard(src.loc)
	if(rigged && !lit)
		rigged.loc = src.loc
	rigged = null
	update_icon()
	B.icon_state = src.icon_state

	var/icon/I = new('icons/obj/drinks.dmi', src.icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I

	playsound(src, "shatter", 70, 1)
	src.transfer_fingerprints_to(B)

	qdel(src)

/obj/item/weapon/reagent_containers/food/drinks/bottle/attack(mob/living/target as mob, mob/living/user as mob)

	if(!target)
		return

	if(user.a_intent != "harm" || !isGlass)
		return ..()


	force = 15 //Smashing bottles over someoen's head hurts.

	var/obj/item/organ/limb/affecting = user.zone_sel.selecting //Find what the player is aiming at

	var/armor_block = 0 //Get the target's armor values for normal attack damage.
	var/armor_duration = 0 //The more force the bottle has, the longer the duration.

	//Calculating duration and calculating damage.
	if(ishuman(target))

		var/mob/living/carbon/human/H = target
		var/headarmor = 0 // Target's head armor
		armor_block = H.run_armor_check(affecting, "melee") // For normal attack damage

		//If they have a hat/helmet and the user is targeting their head.
		if(istype(H.head, /obj/item/clothing/head) && affecting == "head")

			// If their head has an armor value, assign headarmor to it, else give it 0.
			if(H.head.armor["melee"])
				headarmor = H.head.armor["melee"]
			else
				headarmor = 0
		else
			headarmor = 0

		//Calculate the weakening duration for the target.
		armor_duration = (duration - headarmor) + force

	else
		//Only humans can have armor, right?
		armor_block = target.run_armor_check(affecting, "melee")
		if(affecting == "head")
			armor_duration = duration + force
	armor_duration /= 10

	//Apply the damage!
	target.apply_damage(force, BRUTE, affecting, armor_block)

	// You are going to knock someone out for longer if they are not wearing a helmet.
	var/head_attack_message = ""
	if(affecting == "head" && istype(target, /mob/living/carbon/))
		head_attack_message = " on the head"
		//Weaken the target for the duration that we calculated and divide it by 5.
		if(armor_duration)
			target.apply_effect(min(armor_duration, 10) , WEAKEN) // Never weaken more than a flash!

	//Display an attack message.
	if(target != user)
		target.visible_message("<span class='danger'>[user] has hit [target][head_attack_message] with a bottle of [src.name]!</span>", \
				"<span class='userdanger'>[user] has hit [target][head_attack_message] with a bottle of [src.name]!</span>")
	else
		user.visible_message("<span class='danger'>[target] hits himself with a bottle of [src.name][head_attack_message]!</span>", \
				"<span class='userdanger'>[target] hits himself with a bottle of [src.name][head_attack_message]!</span>")

	//Attack logs
	add_logs(user, target, "attacked", object="bottle")

	//The reagents in the bottle splash all over the target, thanks for the idea Nodrak
	if(src.reagents)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("<span class='danger'>The contents of \the [src] splashes all over [target]!</span>"), 1)
		src.reagents.reaction(target, TOUCH)

	//Finally, smash the bottle. This kills (del) the bottle.
	src.smash(target, user)

	return

// Broken Bottles and Molotovs/Firebombs //


/obj/item/weapon/broken_bottle
	name = "Broken Bottle"
	desc = "A bottle with a sharp broken bottom."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "broken_bottle"
	force = 9.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	item_state = "beer"
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("stabbed", "slashed", "attacked")
	var/icon/broken_outline = icon('icons/obj/drinks.dmi', "broken")

/obj/item/weapon/reagent_containers/food/drinks/bottle/update_icon()
	..()
	overlays.Cut()
	if(rigged)
		icon_state = "[initial(icon_state)]-firebomb"
	else
		icon_state = initial(icon_state)
	if(lit)
		overlays += "lit"

/obj/item/weapon/reagent_containers/food/drinks/bottle/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/medical/gauze))
		if(canfirebomb && !rigged)
			var/obj/item/stack/medical/gauze/G = I
			if(G.get_amount() >= 1)
				user << "<span class='warning'>You stuff [G] into the bottle's neck.</span>"
				var/obj/item/stack/medical/gauze/GZ = new G.type(src, 1)
				GZ.copy_evidences(G)
				G.add_fingerprint(user)
				GZ.add_fingerprint(user)
				rigged = GZ
				G.use(1)
				canfirebomb = 0
				update_icon()
	if(is_hot(I))
		if(!lit)
			var/turf/T = get_turf(src)
			T.visible_message("<span class='userdanger'>[user] lights [src] firebomb with [I]!</span>")
			src.lit = 1
			name = "lit [name]"
			update_icon()
			toohottohandle = world.time
			SSobj.processing |= src
			var/area/A = get_area(T)
			message_admins("[key_name(usr)]<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A> has primed a [name] firebomb for detonation at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[A.name] (JMP)</a>.")
			log_game("[key_name(usr)] has primed a [name] firebomb for detonation at [A.name] ([T.x],[T.y],[T.z]).")
	..()

/obj/item/weapon/reagent_containers/food/drinks/bottle/attack_hand(mob/user)
	if(loc == user)
		if(rigged && !lit)
			user.put_in_hands(rigged)
			user << "<span class='notice'>You remove [rigged] from [src].</span>"
			rigged = null
			canfirebomb = 1
			update_icon()
			return
	..()

/obj/item/weapon/reagent_containers/food/drinks/bottle/throw_impact(atom/A)
	if(lit)
		if(ismob(loc))  //if someone caught the firebomb
			var/mob/M = loc
			M.unEquip(src)
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.flammable)
				explosion(src.loc,-1,-1,-1, flame_range = 2, flame_prob = 60)	// smaller range than IEDs, higher chance for flames on turfs
				thrown_shatter()
				return
		thrown_shatter()
	else
		..()

/obj/item/weapon/reagent_containers/food/drinks/bottle/process()
	if(lit)
		if(toohottohandle < world.time - rand(50,70))
			throw_impact(T)

// Bottle Types //

/obj/item/weapon/reagent_containers/food/drinks/bottle/gin
	name = "Griffeater Gin"
	desc = "A bottle of high quality gin, produced in the New London Space Station."
	icon_state = "ginbottle"
	list_reagents = list("gin" = 100)
	canfirebomb = 1

/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey
	name = "Uncle Git's Special Reserve"
	desc = "A premium single-malt whiskey, gently matured inside the tunnels of a nuclear shelter. TUNNEL WHISKEY RULES."
	icon_state = "whiskeybottle"
	list_reagents = list("whiskey" = 100)
	canfirebomb = 1

/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka
	name = "Tunguska Triple Distilled"
	desc = "Aah, vodka. Prime choice of drink AND fuel by Russians worldwide."
	icon_state = "vodkabottle"
	list_reagents = list("vodka" = 100)
	canfirebomb = 1

/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka/badminka
	name = "Badminka Vodka"
	desc = "The label's written in Cyrillic. All you can make out is the name and a word that looks vaguely like 'Vodka'."
	icon_state = "badminka"
	list_reagents = list("vodka" = 100)
	canfirebomb = 1

/obj/item/weapon/reagent_containers/food/drinks/bottle/tequila
	name = "Caccavo Guaranteed Quality Tequila"
	desc = "Made from premium petroleum distillates, pure thalidomide and other fine quality ingredients!"
	icon_state = "tequilabottle"
	list_reagents = list("tequila" = 100)
	canfirebomb = 1

/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing
	name = "Bottle of Nothing"
	desc = "A bottle filled with nothing"
	icon_state = "bottleofnothing"
	list_reagents = list("nothing" = 100)
	canfirebomb = 1

/obj/item/weapon/reagent_containers/food/drinks/bottle/patron
	name = "Wrapp Artiste Patron"
	desc = "Silver laced tequila, served in space night clubs across the galaxy."
	icon_state = "patronbottle"
	list_reagents = list("patron" = 100)
	canfirebomb = 1

/obj/item/weapon/reagent_containers/food/drinks/bottle/rum
	name = "Captain Pete's Cuban Spiced Rum"
	desc = "This isn't just rum, oh no. It's practically GRIFF in a bottle."
	icon_state = "rumbottle"
	list_reagents = list("rum" = 100)
	canfirebomb = 1

/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater
	name = "Flask of Holy Water"
	desc = "A flask of the chaplain's holy water."
	icon_state = "holyflask"
	list_reagents = list("holywater" = 100)
	canfirebomb = 1

/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth
	name = "Goldeneye Vermouth"
	desc = "Sweet, sweet dryness~"
	icon_state = "vermouthbottle"
	list_reagents = list("vermouth" = 100)
	canfirebomb = 1

/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua
	name = "Robert Robust's Coffee Liqueur"
	desc = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936, HONK"
	icon_state = "kahluabottle"
	list_reagents = list("kahlua" = 100)
	canfirebomb = 1

/obj/item/weapon/reagent_containers/food/drinks/bottle/goldschlager
	name = "College Girl Goldschlager"
	desc = "Because they are the only ones who will drink 100 proof cinnamon schnapps."
	icon_state = "goldschlagerbottle"
	list_reagents = list("goldschlager" = 100)
	canfirebomb = 1

/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac
	name = "Chateau De Baton Premium Cognac"
	desc = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. You might as well not scream 'SHITCURITY' this time."
	icon_state = "cognacbottle"
	list_reagents = list("cognac" = 100)
	canfirebomb = 1

/obj/item/weapon/reagent_containers/food/drinks/bottle/wine
	name = "Doublebeard Bearded Special Wine"
	desc = "A faint aura of unease and asspainery surrounds the bottle."
	icon_state = "winebottle"
	list_reagents = list("wine" = 100)
	canfirebomb = 1

//////////////////////////JUICES AND STUFF ///////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice
	name = "Orange Juice"
	desc = "Full of vitamins and deliciousness!"
	icon_state = "orangejuice"
	item_state = "carton"
	isGlass = 0
	list_reagents = list("orangejuice" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/cream
	name = "Milk Cream"
	desc = "It's cream. Made from milk. What else did you think you'd find in there?"
	icon_state = "cream"
	item_state = "carton"
	isGlass = 0
	list_reagents = list("cream" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice
	name = "Tomato Juice"
	desc = "Well, at least it LOOKS like tomato juice. You can't tell with all that redness."
	icon_state = "tomatojuice"
	item_state = "carton"
	isGlass = 0
	list_reagents = list("tomatojuice" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice
	name = "Lime Juice"
	desc = "Sweet-sour goodness."
	icon_state = "limejuice"
	item_state = "carton"
	isGlass = 0
	list_reagents = list("limejuice" = 100)
