

///////////////////////////////////////////////Alchohol bottles! -Agouri //////////////////////////
//Functionally identical to regular drinks. The only difference is that the default bottle size is 100. - Darem
//Bottles now weaken and break when smashed on people's heads. - Giacom

/obj/item/weapon/reagent_containers/food/drinks/bottle
	amount_per_transfer_from_this = 10
	volume = 100
	throwforce = 15
	item_state = "broken_beer" //Generic held-item sprite until unique ones are made.
	var/const/duration = 13 //Directly relates to the 'weaken' duration. Lowered by armor (i.e. helmets)
	var/isGlass = 1 //Whether the 'bottle' is made of glass or not so that milk cartons dont shatter when someone gets hit by it

/obj/item/weapon/reagent_containers/food/drinks/bottle/throw_impact(atom/target,mob/thrower)
	..(target,thrower)
	SplashReagents(target)
	smash(target,thrower,1)
	return

/obj/item/weapon/reagent_containers/food/drinks/bottle/proc/smash(mob/living/target, mob/living/user, ranged = 0)

	//Creates a shattering noise and replaces the bottle with a broken_bottle
	var/new_location = get_turf(loc)
	var/obj/item/weapon/broken_bottle/B = new /obj/item/weapon/broken_bottle(new_location)
	if(ranged)
		B.loc = new_location
	else
		user.drop_item()
		user.put_in_active_hand(B)
	B.icon_state = src.icon_state

	var/icon/I = new('icons/obj/drinks.dmi', src.icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I

	if(isGlass)
		if(prob(33))
			new/obj/item/weapon/shard(new_location)
		playsound(src, "shatter", 70, 1)
	else
		B.name = "broken carton"
		B.force = 0
		B.throwforce = 0
		B.desc = "A carton with the bottom half burst open. Might give you a papercut."
	src.transfer_fingerprints_to(B)

	qdel(src)

/obj/item/weapon/reagent_containers/food/drinks/bottle/attack(mob/living/target, mob/living/user)

	if(!target)
		return

	if(user.a_intent != "harm" || !isGlass)
		return ..()


	force = 15 //Smashing bottles over someoen's head hurts.

	var/obj/item/bodypart/affecting = user.zone_selected //Find what the player is aiming at

	var/armor_block = 0 //Get the target's armor values for normal attack damage.
	var/armor_duration = 0 //The more force the bottle has, the longer the duration.

	//Calculating duration and calculating damage.
	if(ishuman(target))

		var/mob/living/carbon/human/H = target
		var/headarmor = 0 // Target's head armor
		armor_block = H.run_armor_check(affecting, "melee","","",armour_penetration) // For normal attack damage

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
	armor_block = min(90,armor_block)
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
		user.visible_message("<span class='danger'>[target] hits \himself with a bottle of [src.name][head_attack_message]!</span>", \
				"<span class='userdanger'>[target] hits \himself with a bottle of [src.name][head_attack_message]!</span>")

	//Attack logs
	add_logs(user, target, "attacked", src)

	//The reagents in the bottle splash all over the target, thanks for the idea Nodrak
	SplashReagents(target)

	//Finally, smash the bottle. This kills (del) the bottle.
	src.smash(target, user)

	return

/obj/item/weapon/reagent_containers/food/drinks/bottle/proc/SplashReagents(var/mob/M)
	if(src.reagents.total_volume)
		M.visible_message("<span class='danger'>The contents of \the [src] splashes all over [M]!</span>")
		reagents.reaction(M, TOUCH)
		reagents.clear_reagents()
	return

//Keeping this here for now, I'll ask if I should keep it here.
/obj/item/weapon/broken_bottle
	name = "Broken Bottle"
	desc = "A bottle with a sharp broken bottom."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "broken_bottle"
	force = 9
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = 1
	item_state = "beer"
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("stabbed", "slashed", "attacked")
	var/icon/broken_outline = icon('icons/obj/drinks.dmi', "broken")
	sharpness = IS_SHARP

/obj/item/weapon/reagent_containers/food/drinks/bottle/gin
	name = "Griffeater Gin"
	desc = "A bottle of high quality gin, produced in the New London Space Station."
	icon_state = "ginbottle"
	list_reagents = list("gin" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey
	name = "Uncle Git's Special Reserve"
	desc = "A premium single-malt whiskey, gently matured inside the tunnels of a nuclear shelter. TUNNEL WHISKEY RULES."
	icon_state = "whiskeybottle"
	list_reagents = list("whiskey" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka
	name = "Tunguska Triple Distilled"
	desc = "Aah, vodka. Prime choice of drink AND fuel by Russians worldwide."
	icon_state = "vodkabottle"
	list_reagents = list("vodka" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka/badminka
	name = "Badminka Vodka"
	desc = "The label's written in Cyrillic. All you can make out is the name and a word that looks vaguely like 'Vodka'."
	icon_state = "badminka"
	list_reagents = list("vodka" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/tequila
	name = "Caccavo Guaranteed Quality Tequila"
	desc = "Made from premium petroleum distillates, pure thalidomide and other fine quality ingredients!"
	icon_state = "tequilabottle"
	list_reagents = list("tequila" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing
	name = "Bottle of Nothing"
	desc = "A bottle filled with nothing."
	icon_state = "bottleofnothing"
	list_reagents = list("nothing" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/patron
	name = "Wrapp Artiste Patron"
	desc = "Silver laced tequila, served in space night clubs across the galaxy."
	icon_state = "patronbottle"
	list_reagents = list("patron" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/rum
	name = "Captain Pete's Cuban Spiced Rum"
	desc = "This isn't just rum, oh no. It's practically GRIFF in a bottle."
	icon_state = "rumbottle"
	list_reagents = list("rum" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater
	name = "Flask of Holy Water"
	desc = "A flask of the chaplain's holy water."
	icon_state = "holyflask"
	list_reagents = list("holywater" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater/hell
	desc = "A flask of holy water...it's been sitting in the Necropolis a while though."
	list_reagents = list("hellwater" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth
	name = "Goldeneye Vermouth"
	desc = "Sweet, sweet dryness~"
	icon_state = "vermouthbottle"
	list_reagents = list("vermouth" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua
	name = "Robert Robust's Coffee Liqueur"
	desc = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936, HONK."
	icon_state = "kahluabottle"
	list_reagents = list("kahlua" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/goldschlager
	name = "College Girl Goldschlager"
	desc = "Because they are the only ones who will drink 100 proof cinnamon schnapps."
	icon_state = "goldschlagerbottle"
	list_reagents = list("goldschlager" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac
	name = "Chateau De Baton Premium Cognac"
	desc = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. You might as well not scream 'SHITCURITY' this time."
	icon_state = "cognacbottle"
	list_reagents = list("cognac" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/wine
	name = "Doublebeard Bearded Special Wine"
	desc = "A faint aura of unease and asspainery surrounds the bottle."
	icon_state = "winebottle"
	list_reagents = list("wine" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe
	name = "Extra-Strong Absinthe"
	desc = "An strong alcoholic drink brewed and distributed by"
	icon_state = "absinthebottle"
	list_reagents = list("absinthe" = 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe/New()
	..()
	redact()

/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe/proc/redact()
	// There was a large fight in the coderbus about a player reference
	// in absinthe. Ergo, this is why the name generation is now so
	// complicated. Judge us kindly.
	var/shortname = pickweight(
		list("T&T" = 1, "A&A" = 1, "Generic" = 1))
	var/fullname
	switch(shortname)
		if("T&T")
			fullname = "Teal and Tealer"
		if("A&A")
			fullname = "Ash and Asher"
		if("Generic")
			fullname = "Nanotrasen Cheap Imitations"
	var/removals = list("\[REDACTED\]", "\[EXPLETIVE DELETED\]",
		"\[EXPUNGED\]", "\[INFORMATION ABOVE YOUR SECURITY CLEARANCE\]",
		"\[MOVE ALONG CITIZEN\]", "\[NOTHING TO SEE HERE\]")
	var/chance = 50

	if(prob(chance))
		shortname = pick_n_take(removals)

	var/list/final_fullname = list()
	for(var/word in splittext(fullname, " "))
		if(prob(chance))
			word = pick_n_take(removals)
		final_fullname += word

	fullname = jointext(final_fullname, " ")

	// Actually finally setting the new name and desc
	name = "[shortname] [name]"
	desc = "[desc] [fullname] Inc."


/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe/premium
	name = "Ashwalker Premium Absinthe"
	desc = "E.Y.E: Divine Cybermancy is set in a dystopian future following a complex background of events. The human race has become involved in an interplanetary conflict stemming from a mysterious race as well as an unexplained psionic entity known as the meta-streumonic force, that has turned civilizations against each other and threatens the universe. The player takes the role of an E.Y.E. member, a secretive and elite army of psi-cybernetic warrior monks founded, funded and ruled by a group of megacorporations named Secreta Secretorum. With access to advanced technology, each member is infused with cybernetics, psionic training, and DNA acquired from the only known member of the mysterious advanced civilization to ever be captured and killed. The player wakes up after a fight in which your teammates are killed, with the Secreta Secretorum is attempting a coup against the all-powerful Federation, a consortium of corporations, several worlds and planets who comprise the current human government and rule them with an iron fist.To complicate matters, E.Y.E is composed of two groups, the Jian Shang Di and the Culter Dei, to which you belong, both having their own leaders and members. Brothers in the past, they are currently in the middle of an unofficial and secret civil war. By the Year 15, this struggle has calmed down because their mutual fight against the Federation has intensified. However, in the shadows, Commander Rimanah plots to destabilize and destroy the Jians by weakening their power base or make them worthless in the eyes of Secreta Secretorum. He created a special task force for this goal, where the player is one of its members.Your loyalties are torn between Commander Rimanah, (leader of the Culter Dei) who is a separatist with an unstoppable ambition, and your superior, and your Mentor, a friend and instructor. The Mentor tries at all costs to unite the two rival groups. In doing so, you are thrust into the middle of a fratricidal war fraught with political conspiracies and quests for power in which different groups and megacorporations are implicated. These troubles set the stage for an attack by the unknown meta-streumonic force bent on destroying humankind.Gameplay begins with character creation, in which the player has three slots in which to choose from DNA types to apply. This initial character-building DNA infusion has a semi-random outcome in generating the initial character statistics. Gameplay is from a first-person perspective. The player begins each game asleep and in a dreamscape, and must walk through a door within the dream in order to wake up. Upon awaking, they spawn in the location they were in when last they exited. Very little is known to the player about the environment at first, so they must learn about it by speaking to characters and accessing historical data terminals. Between missions, the player spends time talking to various friendly characters, learning about the current conflicts and their history, obtaining objectives, and attempting to serve their greater goals by choosing from response options which can influence the direction of the conversation. Many between-mission scenes take place in the Temple, an elaborate and vast futuristic structure that serves as headquarters to the E.Y.E. organization. New weapons and technologies can be purchased here using Brouzouf, the game's form of currency, which is earned by killing enemies, completing objectives, or hacking bank terminals. The Temple also contains many characters to speak to, a training room for testing weapons, multiple mobile armories where the player's currently available equipment can be loaded and armor changed, a medical section where new cybernetic abilities can be purchased, and an archive room where the history of the in-game universe can be learned through the use of data terminals, and where new psionic powers can be purchased. The Temple also features an armory where new weapons can be bought, which can then be equipped using the mobile armories. The Temple can be accessed at any time by choosing the Temple option at the game's loading screen, or in the escape menu, which pauses the current mission. Side missions can be acquired from Temple guard at its entrance, or the player can simply take a Temple exit to enter the local streets and see randomly generated objectives, battle various enemies, hack bank terminals, etc., to earn Brouzouf and experience, and to find new technologies.The player loads out prior to missions at mobile armories, choosing armor and a variety of weapons. Melee weapons generally consist of different types of Samurai blade weapons. Ranged weapons consist of traditional firearms from handgun, shotgun, assault, submachine, heavy machine, and sniper classes, some of which have varying wall-penetrating values. Grenades and automated drone robots are also available. Ammunition clips are unlimited when at a mobile armory. All items must be placed in inventory slots that are divided into groupings for each area on the player where they are to be stored. As a unique gameplay mechanic, all equipment carried causes a weight disadvantage, termed a malus in-game, as does the armor type chosen (light, medium, or heavy). The total weight malus is shown in the player's stats screen as a percentage; weightier characters move slower, create more noise when moving, and incur more damage from long falls. " // I can't escape my cycles of guilt.
	icon_state = "absinthepremium"

/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe/premium/redact()
	return

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


////////////////////////// MOLOTOV ///////////////////////
/obj/item/weapon/reagent_containers/food/drinks/bottle/molotov
	name = "molotov cocktail"
	desc = "A throwing weapon used to ignite things, typically filled with an accelerant. Recommended highly by rioters and revolutionaries. Light and toss."
	icon_state = "vodkabottle"
	list_reagents = list()
	var/list/accelerants = list(	/datum/reagent/consumable/ethanol,/datum/reagent/fuel,/datum/reagent/clf3,/datum/reagent/phlogiston,
							/datum/reagent/napalm,/datum/reagent/hellwater,/datum/reagent/toxin/plasma,/datum/reagent/toxin/spore_burning)
	var/active = 0

/obj/item/weapon/reagent_containers/food/drinks/bottle/molotov/CheckParts(list/parts_list)
	..()
	var/obj/item/weapon/reagent_containers/food/drinks/bottle/B = locate() in contents
	if(B)
		icon_state = B.icon_state
		B.reagents.copy_to(src,100)
		if(!B.isGlass)
			desc += " You're not sure if making this out of a carton was the brightest idea."
			isGlass = 0
	return

/obj/item/weapon/reagent_containers/food/drinks/bottle/molotov/throw_impact(atom/target,mob/thrower)
	var/firestarter = 0
	for(var/datum/reagent/R in reagents.reagent_list)
		for(var/A in accelerants)
			if(istype(R,A))
				firestarter = 1
				break
	SplashReagents(target)
	if(firestarter && active)
		target.fire_act()
		new /obj/effect/hotspot(get_turf(target))
	..()

/obj/item/weapon/reagent_containers/food/drinks/bottle/molotov/attackby(obj/item/I, mob/user, params)
	if(I.is_hot() && !active)
		active = 1
		var/turf/bombturf = get_turf(src)
		var/area/bombarea = get_area(bombturf)
		message_admins("[key_name(user)]<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A> has primed a [name] for detonation at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[bombarea] (JMP)</a>.")
		log_game("[key_name(user)] has primed a [name] for detonation at [bombarea] ([bombturf.x],[bombturf.y],[bombturf.z]).")

		user << "<span class='info'>You light \the [src] on fire.</span>"
		overlays += fire_overlay
		if(!isGlass)
			spawn(50)
				if(active)
					var/counter
					var/target = src.loc
					for(counter = 0, counter<2, counter++)
						if(istype(target, /obj/item/weapon/storage))
							var/obj/item/weapon/storage/S = target
							target = S.loc
					if(istype(target, /atom))
						var/atom/A = target
						SplashReagents(A)
						A.fire_act()
					qdel(src)

/obj/item/weapon/reagent_containers/food/drinks/bottle/molotov/attack_self(mob/user)
	if(active)
		if(!isGlass)
			user << "<span class='danger'>The flame's spread too far on it!</span>"
			return
		user << "<span class='info'>You snuff out the flame on \the [src].</span>"
		overlays -= fire_overlay
		active = 0
