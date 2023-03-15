//FOR THE BASE OBJECT//

/obj/item/anime
	name = "anime dermal implant"
	desc = "You should not be seeing this item!"
	icon = 'monkestation/icons/obj/device.dmi'
	icon_state = "coder"
	var/obj/item/organ/ears/ears = null
	var/obj/item/organ/tail/tail = null
	var/food_likes
	var/food_dislikes
	var/list/weeb_screams
	var/list/weeb_laughs
	var/hacked = FALSE

/obj/item/anime/attack_self(mob/living/carbon/user)
	if(ishuman(user))
		anime_transformation(user)

/obj/item/anime/afterattack(mob/living/carbon/user)
	if(hacked && ishuman(user))
		anime_transformation(user)

//DERMAL IMPLANT SETS//
/obj/item/anime/cat
	name = "anime cat dermal implant"
	desc = "It smells of ammonia"
	icon_state = "cat"
	ears = new /obj/item/organ/ears/cat
	tail = new /obj/item/organ/tail/cat
	food_likes = DAIRY | MEAT | JUNKFOOD
	food_dislikes = FRUIT | VEGETABLES
	weeb_screams = list('monkestation/sound/voice/screams/felinid/hiss.ogg','monkestation/sound/voice/screams/felinid/merowr.ogg','monkestation/sound/voice/screams/felinid/scream_cat.ogg', 'monkestation/sound/voice/screams/felinid/ooknya.ogg')
	weeb_laughs = list('monkestation/sound/voice/laugh/felinid/cat_laugh0.ogg','monkestation/sound/voice/laugh/felinid/cat_laugh1.ogg','monkestation/sound/voice/laugh/felinid/cat_laugh2.ogg','monkestation/sound/voice/laugh/felinid/cat_laugh3.ogg','monkestation/sound/voice/laugh/felinid/ooknyahaha.ogg')

/obj/item/anime/fox
	name = "anime fox dermal implant"
	desc = "You're ready to become the next hokage!"
	icon_state = "fox"
	ears = new /obj/item/organ/ears/fox
	tail = new /obj/item/organ/tail/fox
	food_likes = MEAT | FRUIT | VEGETABLES
	food_dislikes = GROSS | GRAIN
	weeb_screams = list('monkestation/sound/voice/screams/misc/awoo1.ogg', 'monkestation/sound/voice/screams/misc/awoo2.ogg')
	weeb_laughs = list('monkestation/sound/voice/laugh/felinid/cat_laugh0.ogg','monkestation/sound/voice/laugh/felinid/cat_laugh1.ogg','monkestation/sound/voice/laugh/felinid/cat_laugh2.ogg','monkestation/sound/voice/laugh/felinid/cat_laugh3.ogg','monkestation/sound/voice/laugh/felinid/ooknyahaha.ogg')


/obj/item/anime/wolf
	name = "anime wolf dermal implant"
	desc = "Sit, boy!"
	icon_state = "wolf"
	ears = new /obj/item/organ/ears/fox
	tail = new /obj/item/organ/tail/wolf
	food_likes = MEAT | JUNKFOOD | RAW
	food_dislikes = FRUIT | VEGETABLES | DAIRY
	weeb_screams = list('monkestation/sound/voice/screams/misc/awoo1.ogg', 'monkestation/sound/voice/screams/misc/awoo2.ogg')
	weeb_laughs = list('monkestation/sound/voice/laugh/felinid/cat_laugh0.ogg','monkestation/sound/voice/laugh/felinid/cat_laugh1.ogg','monkestation/sound/voice/laugh/felinid/cat_laugh2.ogg','monkestation/sound/voice/laugh/felinid/cat_laugh3.ogg','monkestation/sound/voice/laugh/felinid/ooknyahaha.ogg')


/obj/item/anime/shark
	name = "anime shark dermal implant"
	desc = "A."
	icon_state = "shark"
	tail = new /obj/item/organ/tail/shark
	food_likes = MEAT | JUNKFOOD | RAW
	food_dislikes = FRUIT | VEGETABLES | DAIRY
	weeb_screams = list('monkestation/sound/voice/screams/misc/shark_scream0.ogg')
	weeb_laughs = list('monkestation/sound/voice/screams/misc/shark_scream0.ogg')

//ANIME TRAIT SPAWNER//
/obj/item/choice_beacon/anime
	name = "anime dermal implant kit"
	desc = "Summon your spirit animal."
	icon = 'monkestation/icons/obj/device.dmi'
	icon_state = "anime"
	pickup_sound =  'monkestation/sound/misc/anime.ogg'
	var/hacked_l = FALSE

/obj/item/choice_beacon/anime/spawn_option(obj/choice, mob/living/carbon/human/M)//overwrite choice proc so it doesn't drop pod.
	var/obj/item/anime/new_item = new choice()
	if(hacked_l)
		new_item.name = "Hacked " + new_item.name
		new_item.hacked = TRUE
	var/msg = "<span class=danger>The box spits out a [new_item]. </span>"
	to_chat(M, msg)
	var/list/slots = list (
		"backpack" = ITEM_SLOT_BACKPACK,
		"hands" = ITEM_SLOT_HANDS
	)
	if(!M.equip_in_one_of_slots(new_item, slots , qdel_on_fail = FALSE))
		new_item.forceMove(M.loc)

/obj/item/choice_beacon/anime/generate_display_names()
	var/static/list/anime
	if(!anime)
		anime = list()
		var/list/templist = list()
		templist = list(/obj/item/anime/cat, //Add to this list if you want your implant to be included in the trait
						 /obj/item/anime/fox,
						 /obj/item/anime/wolf,
						 /obj/item/anime/shark
						)
		for(var/V in templist)
			var/atom/A = V
			anime[initial(A.name)] = A
	return anime

/obj/item/choice_beacon/anime/hacked
	name = "hacked anime dermal implant kit"
	hacked_l = TRUE

/obj/item/anime/proc/anime_transformation(mob/living/carbon/user)
	if(ishuman(user))
		var/mob/living/carbon/human/weeb = user
		var/new_color = null
		if(!hacked)
			new_color = input(user, "Choose an Anime color:", "Anime Color (clicking 'cancel' will set Anime color to Hair color):", weeb.hair_color) as color|null
		if(new_color) //If they DON'T pick a color, then it just defaults to their original hair color.
			weeb.custom_color = sanitize_hexcolor(new_color)
		else
			weeb.custom_color = weeb.hair_color
		if(ears)
			ears.Insert(weeb)
		if(tail)
			tail.Insert(weeb)
		if(weeb_screams)
			weeb.alternative_screams += weeb_screams
		if(weeb_laughs)
			weeb.alternative_laughs += weeb_laughs
		if(food_likes)
			weeb.dna.species.liked_food = food_likes
		if(food_dislikes)
			weeb.dna.species.disliked_food = food_dislikes
			weeb.dna.species.toxic_food = food_dislikes

		var/turf/location = get_turf(weeb)
		weeb.add_splatter_floor(location)
		var/msg = "<span class=danger>You feel the power of God and Anime flow through you!</span>"
		to_chat(weeb, msg)
		playsound(location, 'sound/weapons/circsawhit.ogg', 50, 1)
		weeb.update_body()
		weeb.update_hair()
		qdel(src)
