/obj/item/caution
	desc = "Caution! Wet Floor!"
	name = "wet floor sign"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "caution"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 1
	throwforce = 3
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb_continuous = list("warns", "cautions", "smashes")
	attack_verb_simple = list("warn", "caution", "smash")

/obj/item/choice_beacon
	name = "choice beacon"
	desc = "Hey, why are you viewing this?!! Please let CentCom know about this odd occurrence."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-blue"
	inhand_icon_state = "radio"
	var/uses = 1

/obj/item/choice_beacon/attack_self(mob/user)
	if(canUseBeacon(user))
		generate_options(user)

/obj/item/choice_beacon/proc/generate_display_names() // return the list that will be used in the choice selection. entries should be in (type.name = type) fashion. see choice_beacon/hero for how this is done.
	return list()

/obj/item/choice_beacon/proc/canUseBeacon(mob/living/user)
	if(user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return TRUE
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 40, TRUE)
		return FALSE

/obj/item/choice_beacon/proc/generate_options(mob/living/M)
	var/list/display_names = generate_display_names()
	if(!display_names.len)
		return
	var/choice = input(M,"Which item would you like to order?","Select an Item") as null|anything in sortList(display_names)
	if(!choice || !M.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	spawn_option(display_names[choice],M)
	uses--
	if(!uses)
		qdel(src)
	else
		to_chat(M, "<span class='notice'>[uses] use[uses > 1 ? "s" : ""] remaining on the [src].</span>")

/obj/item/choice_beacon/proc/spawn_option(obj/choice,mob/living/M)
	var/obj/structure/closet/supplypod/bluespacepod/pod = new()
	new choice(pod)
	pod.explosionSize = list(0,0,0,0)
	var/msg = "<span class=danger>After making your selection, you notice a strange target on the ground. It might be best to step back!</span>"
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(istype(H.ears, /obj/item/radio/headset))
			msg = "You hear something crackle in your ears for a moment before a voice speaks.  \"Please stand by for a message from Central Command.  Message as follows: <span class='bold'>Item request received. Your package is inbound, please stand back from the landing site.</span> Message ends.\""
	to_chat(M, msg)

	new /obj/effect/pod_landingzone(get_turf(src), pod)

/obj/item/choice_beacon/ingredient
	name = "ingredient delivery beacon"
	desc = "Summon a box of ingredients to help you get started cooking."
	icon_state = "gangtool-white"

/obj/item/choice_beacon/ingredient/generate_display_names()
	var/list/ingredients = list()
	for(var/V in subtypesof(/obj/item/storage/box/ingredients))
		var/obj/item/storage/box/ingredients/A = V
		ingredients[initial(A.theme_name)] = A
	return ingredients

/obj/item/choice_beacon/ingredient/spawn_option(obj/choice,mob/living/M)
	new choice(get_turf(M))
	to_chat(M, "<span class='hear'>You hear something crackle from the beacon for a moment before a voice speaks. \"Please stand by for a message from Sophronia Broadcasting. Message as follows: <b>Please enjoy your Sophronia Broadcasting's 'Plasteel Chef' Ingredients Box, exactly as shown in the hit show!</b> Message ends.\"</span>")

/obj/item/storage/box/ingredients //This box is for the randomly chosen version the chef used to spawn with, it shouldn't actually exist.
	name = "ingredients box"
	illustration = "fruit"
	var/theme_name

/obj/item/storage/box/ingredients/Initialize()
	. = ..()
	if(theme_name)
		name = "[name] ([theme_name])"
		desc = "A box containing supplementary ingredients for the aspiring chef. The box's theme is '[theme_name]'."
		inhand_icon_state = "syringe_kit"

/obj/item/storage/box/ingredients/wildcard
	theme_name = "wildcard"

/obj/item/storage/box/ingredients/wildcard/PopulateContents()
	for(var/i in 1 to 7)
		var/randomFood = pick(/obj/item/food/grown/chili,
							  /obj/item/food/grown/tomato,
							  /obj/item/food/grown/carrot,
							  /obj/item/food/grown/potato,
							  /obj/item/food/grown/potato/sweet,
							  /obj/item/food/grown/apple,
							  /obj/item/food/chocolatebar,
							  /obj/item/food/grown/cherries,
							  /obj/item/food/grown/banana,
							  /obj/item/food/grown/cabbage,
							  /obj/item/food/grown/soybeans,
							  /obj/item/food/grown/corn,
							  /obj/item/food/grown/mushroom/plumphelmet,
							  /obj/item/food/grown/mushroom/chanterelle)
		new randomFood(src)

/obj/item/storage/box/ingredients/fiesta
	theme_name = "fiesta"

/obj/item/storage/box/ingredients/fiesta/PopulateContents()
	new /obj/item/food/tortilla(src)
	for(var/i in 1 to 2)
		new /obj/item/food/grown/corn(src)
		new /obj/item/food/grown/soybeans(src)
		new /obj/item/food/grown/chili(src)

/obj/item/storage/box/ingredients/italian
	theme_name = "italian"

/obj/item/storage/box/ingredients/italian/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/food/grown/tomato(src)
		new /obj/item/food/meatball(src)
	new /obj/item/reagent_containers/food/drinks/bottle/wine(src)

/obj/item/storage/box/ingredients/vegetarian
	theme_name = "vegetarian"

/obj/item/storage/box/ingredients/vegetarian/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/food/grown/carrot(src)
	new /obj/item/food/grown/eggplant(src)
	new /obj/item/food/grown/potato(src)
	new /obj/item/food/grown/apple(src)
	new /obj/item/food/grown/corn(src)
	new /obj/item/food/grown/tomato(src)

/obj/item/storage/box/ingredients/american
	theme_name = "american"

/obj/item/storage/box/ingredients/american/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/food/grown/potato(src)
		new /obj/item/food/grown/tomato(src)
		new /obj/item/food/grown/corn(src)
	new /obj/item/food/meatball(src)

/obj/item/storage/box/ingredients/fruity
	theme_name = "fruity"

/obj/item/storage/box/ingredients/fruity/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/food/grown/apple(src)
		new /obj/item/food/grown/citrus/orange(src)
	new /obj/item/food/grown/citrus/lemon(src)
	new /obj/item/food/grown/citrus/lime(src)
	new /obj/item/food/grown/watermelon(src)

/obj/item/storage/box/ingredients/sweets
	theme_name = "sweets"

/obj/item/storage/box/ingredients/sweets/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/food/grown/cherries(src)
		new /obj/item/food/grown/banana(src)
	new /obj/item/food/chocolatebar(src)
	new /obj/item/food/grown/cocoapod(src)
	new /obj/item/food/grown/apple(src)

/obj/item/storage/box/ingredients/delights
	theme_name = "delights"

/obj/item/storage/box/ingredients/delights/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/food/grown/potato/sweet(src)
		new /obj/item/food/grown/bluecherries(src)
	new /obj/item/food/grown/vanillapod(src)
	new /obj/item/food/grown/cocoapod(src)
	new /obj/item/food/grown/berries(src)

/obj/item/storage/box/ingredients/grains
	theme_name = "grains"

/obj/item/storage/box/ingredients/grains/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/food/grown/oat(src)
	new /obj/item/food/grown/wheat(src)
	new /obj/item/food/grown/cocoapod(src)
	new /obj/item/reagent_containers/honeycomb(src)
	new /obj/item/seeds/poppy(src)

/obj/item/storage/box/ingredients/carnivore
	theme_name = "carnivore"

/obj/item/storage/box/ingredients/carnivore/PopulateContents()
	new /obj/item/food/meat/slab/bear(src)
	new /obj/item/food/meat/slab/spider(src)
	new /obj/item/food/spidereggs(src)
	new /obj/item/food/carpmeat(src)
	new /obj/item/food/meat/slab/xeno(src)
	new /obj/item/food/meat/slab/corgi(src)
	new /obj/item/food/meatball(src)

/obj/item/storage/box/ingredients/exotic
	theme_name = "exotic"

/obj/item/storage/box/ingredients/exotic/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/food/carpmeat(src)
		new /obj/item/food/grown/soybeans(src)
		new /obj/item/food/grown/cabbage(src)
	new /obj/item/food/grown/chili(src)

/obj/item/storage/box/ingredients/random
	theme_name = "random"
	desc = "This box should not exist, contact the proper authorities."

/obj/item/storage/box/ingredients/random/Initialize()
	.=..()
	var/chosen_box = pick(subtypesof(/obj/item/storage/box/ingredients) - /obj/item/storage/box/ingredients/random)
	new chosen_box(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/choice_beacon/hero
	name = "heroic beacon"
	desc = "To summon heroes from the past to protect the future."

/obj/item/choice_beacon/hero/generate_display_names()
	var/static/list/hero_item_list
	if(!hero_item_list)
		hero_item_list = list()
		var/list/templist = typesof(/obj/item/storage/box/hero) //we have to convert type = name to name = type, how lovely!
		for(var/V in templist)
			var/atom/A = V
			hero_item_list[initial(A.name)] = A
	return hero_item_list

/obj/item/choice_beacon/hero/spawn_option(obj/choice,mob/living/M)
	new choice(get_turf(M))
	to_chat(M, "<span class='hear'>You hear something crackle from the beacon for a moment before a voice speaks. \"Please stand by for a message from Sophronia Broadcasting. Message as follows: <b>Please enjoy your Sophronia Broadcasting's 'History Comes Alive branded' Costume Set, exactly as shown in the hit show!</b> Message ends.\"</span>")


/obj/item/storage/box/hero
	name = "Courageous Tomb Raider - 1940's."
	desc = "This legendary figure of still dubious historical accuracy is thought to have been a world-famous archeologist who embarked on countless adventures in far away lands, along with his trademark whip and fedora hat."

/obj/item/storage/box/hero/PopulateContents()
	new /obj/item/clothing/head/fedora/curator(src)
	new /obj/item/clothing/suit/curator(src)
	new /obj/item/clothing/under/rank/civilian/curator/treasure_hunter(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/melee/curator_whip(src)

/obj/item/storage/box/hero/astronaut
	name = "First Man on the Moon - 1960's."
	desc = "One small step for a man, one giant leap for mankind. Relive the beginnings of space exploration with this fully functional set of vintage EVA equipment."

/obj/item/storage/box/hero/astronaut/PopulateContents()
	new /obj/item/clothing/suit/space/nasavoid(src)
	new /obj/item/clothing/head/helmet/space/nasavoid(src)
	new /obj/item/tank/internals/oxygen(src)
	new /obj/item/gps(src)

/obj/item/storage/box/hero/scottish
	name = "Braveheart, the Scottish rebel - 1300's."
	desc = "Seemingly a legendary figure in the battle for Scottish independence, this historical figure is closely associated with blue facepaint, big swords, strange man skirts, and his ever enduring catchphrase: 'FREEDOM!!'"

/obj/item/storage/box/hero/scottish/PopulateContents()
	new /obj/item/clothing/under/costume/kilt(src)
	new /obj/item/claymore/weak/ceremonial(src)
	new /obj/item/toy/crayon/spraycan(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/storage/box/hero/carphunter
	name = "Carp Hunter, Wildlife Expert - 2506."
	desc = "Despite his nickname, this wildlife expert was mainly known as a passionate environmentalist and conservationist, often coming in contact with dangerous wildlife to teach about the beauty of nature."

/obj/item/storage/box/hero/carphunter/PopulateContents()
	new /obj/item/clothing/suit/space/hardsuit/carp/old(src)
	new /obj/item/clothing/mask/gas/carp(src)
	new /obj/item/kitchen/knife/hunting(src)
	new /obj/item/storage/box/papersack/meat(src)

/obj/item/choice_beacon/augments
	name = "augment beacon"
	desc = "Summons augmentations. Can be used 3 times!"
	uses = 3

/obj/item/choice_beacon/augments/generate_display_names()
	var/static/list/augment_list
	if(!augment_list)
		augment_list = list()
		var/list/templist = list(
		/obj/item/organ/cyberimp/brain/anti_drop,
		/obj/item/organ/cyberimp/arm/toolset,
		/obj/item/organ/cyberimp/arm/surgery,
		/obj/item/organ/cyberimp/chest/thrusters,
		/obj/item/organ/lungs/cybernetic/tier3,
		/obj/item/organ/liver/cybernetic/tier3) //cyberimplants range from a nice bonus to fucking broken bullshit so no subtypesof
		for(var/V in templist)
			var/atom/A = V
			augment_list[initial(A.name)] = A
	return augment_list

/obj/item/choice_beacon/augments/spawn_option(obj/choice,mob/living/M)
	new choice(get_turf(M))
	to_chat(M, "<span class='hear'>You hear something crackle from the beacon for a moment before a voice speaks. \"Please stand by for a message from S.E.L.F. Message as follows: <b>Item request received. Your package has been transported, use the autosurgeon supplied to apply the upgrade.</b> Message ends.\"</span>")

/obj/item/skub
	desc = "It's skub."
	name = "skub"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "skub"
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("skubs")
	attack_verb_simple = list("skub")

/obj/item/skub/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/container_item/tank_holder, "holder_skub", FALSE)

/obj/item/skub/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] has declared themself as anti-skub! The skub tears them apart!</span>")

	user.gib()
	playsound(src, 'sound/items/eatfood.ogg', 50, TRUE, -1)
	return MANUAL_SUICIDE

/obj/item/virgin_mary
	name = "\proper a picture of the virgin mary"
	desc = "A small, cheap icon depicting the virgin mother."
	icon = 'icons/obj/blackmarket.dmi'
	icon_state = "madonna"
	resistance_flags = FLAMMABLE
	///Has this item been used already.
	var/used_up = FALSE
	///List of mobs that have already been mobbed.
	var/static/list/mob_mobs = list()

#define NICKNAME_CAP	(MAX_NAME_LEN/2)
/obj/item/virgin_mary/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(resistance_flags & ON_FIRE)
		return
	if(!burn_paper_product_attackby_check(W, user, TRUE))
		return
	if(used_up)
		return
	if(!isliving(user) || !user.mind) //A sentient mob needs to be burning it, ya cheezit.
		return
	var/mob/living/joe = user

	if(joe in mob_mobs) //Only one nickname fuckhead
		to_chat(joe, "<span class='warning'>You have already been initiated into the mafioso life.</span>")
		return

	to_chat(joe, "<span class='notice'>As you burn the picture, a nickname comes to mind...</span>")
	var/nickname = stripped_input(joe, "Pick a nickname", "Mafioso Nicknames", null, NICKNAME_CAP, TRUE)
	nickname = reject_bad_name(nickname, allow_numbers = FALSE, max_length = NICKNAME_CAP, ascii_only = TRUE)
	if(!nickname)
		return
	var/new_name
	var/space_position = findtext(joe.real_name, " ")
	if(space_position)//Can we find a space?
		new_name = "[copytext(joe.real_name, 1, space_position)] \"[nickname]\" [copytext(joe.real_name, space_position)]"
	else //Append otherwise
		new_name = "[joe.real_name] \"[nickname]\""
	joe.real_name = new_name
	used_up = TRUE
	mob_mobs += joe
	joe.say("My soul will burn like this saint if I betray my family. I enter alive and I will have to get out dead.", forced = /obj/item/virgin_mary)
	to_chat(joe, "<span class='userdanger'>Being inducted into the mafia does not grant antagonist status.</span>")

#undef NICKNAME_CAP

/obj/item/virgin_mary/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] starts saying their Hail Mary's at a terrifying pace! It looks like [user.p_theyre()] trying to enter the afterlife!</span>")
	user.say("Hail Mary, full of grace, the Lord is with thee. Blessed are thou amongst women, and blessed is the fruit of thy womb, Jesus. Holy Mary, mother of God, pray for us sinners, now and at the hour of our death. Amen. ", forced = /obj/item/virgin_mary)
	addtimer(CALLBACK(src, .proc/manual_suicide, user), 75)
	addtimer(CALLBACK(user, /atom/movable/proc/say, "O my Mother, preserve me this day from mortal sin..."), 50)
	return MANUAL_SUICIDE

/obj/item/virgin_mary/proc/manual_suicide(mob/living/user)
	user.adjustOxyLoss(200)
	user.death(0)

// Bouquets
/obj/item/bouquet
	name = "mixed bouquet"
	desc = "A bouquet of sunflowers, lilies, and geraniums. How delightful."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "mixedbouquet"

/obj/item/bouquet/sunflower
	name = "sunflower bouquet"
	desc = "A bright bouquet of sunflowers."
	icon_state = "sunbouquet"

/obj/item/bouquet/poppy
	name = "poppy bouquet"
	desc = "A bouquet of poppies. You feel loved just looking at it."
	icon_state = "poppybouquet"

/obj/item/gun_maintenance_supplies
	name = "gun maintenance supplies"
	desc = "plastic box containing gun maintenance supplies and spare parts. Use them on a Mosin Nagant to clean it."
	icon = 'icons/obj/storage.dmi'
	icon_state = "plasticbox"
	w_class = WEIGHT_CLASS_SMALL
