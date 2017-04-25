/datum/round_event_control/treevenge
	name = "Treevenge (Christmas)"
	holidayID = CHRISTMAS
	typepath = /datum/round_event/treevenge
	max_occurrences = 1
	weight = 20

/datum/round_event/treevenge/start()
	for(var/obj/structure/flora/tree/pine/xmas in world)
		var/mob/living/simple_animal/hostile/tree/evil_tree = new /mob/living/simple_animal/hostile/tree(xmas.loc)
		evil_tree.icon_state = xmas.icon_state
		evil_tree.icon_living = evil_tree.icon_state
		evil_tree.icon_dead = evil_tree.icon_state
		evil_tree.icon_gib = evil_tree.icon_state
		qdel(xmas) //b-but I don't want to delete xmas...

//this is an example of a possible round-start event
/datum/round_event_control/presents
	name = "Presents under Trees (Christmas)"
	holidayID = CHRISTMAS
	typepath = /datum/round_event/presents
	weight = -1							//forces it to be called, regardless of weight
	max_occurrences = 1
	earliest_start = 0

/datum/round_event/presents/start()
	for(var/obj/structure/flora/tree/pine/xmas in world)
		if(xmas.z != 1)
			continue
		for(var/turf/open/floor/T in orange(1,xmas))
			for(var/i=1,i<=rand(1,5),i++)
				new /obj/item/weapon/a_gift(T)
	for(var/mob/living/simple_animal/pet/dog/corgi/Ian/Ian in GLOB.mob_list)
		Ian.place_on_head(new /obj/item/clothing/head/helmet/space/santahat(Ian))
	for(var/obj/machinery/computer/security/telescreen/entertainment/Monitor in GLOB.machines)
		Monitor.icon_state = "entertainment_xmas"

/datum/round_event/presents/announce()
	priority_announce("Ho Ho Ho, Merry Xmas!", "Unknown Transmission")


/obj/item/weapon/toy/xmas_cracker
	name = "xmas cracker"
	icon = 'icons/obj/christmas.dmi'
	icon_state = "cracker"
	desc = "Directions for use: Requires two people, one to pull each end."
	var/cracked = 0

/obj/item/weapon/toy/xmas_cracker/attack(mob/target, mob/user)
	if( !cracked && ishuman(target) && (target.stat == CONSCIOUS) && !target.get_active_held_item() )
		target.visible_message("[user] and [target] pop \an [src]! *pop*", "<span class='notice'>You pull \an [src] with [target]! *pop*</span>", "<span class='italics'>You hear a pop.</span>")
		var/obj/item/weapon/paper/Joke = new /obj/item/weapon/paper(user.loc)
		Joke.name = "[pick("awful","terrible","unfunny")] joke"
		Joke.info = pick("What did one snowman say to the other?\n\n<i>'Is it me or can you smell carrots?'</i>",
			"Why couldn't the snowman get laid?\n\n<i>He was frigid!</i>",
			"Where are santa's helpers educated?\n\n<i>Nowhere, they're ELF-taught.</i>",
			"What happened to the man who stole advent calanders?\n\n<i>He got 25 days.</i>",
			"What does Santa get when he gets stuck in a chimney?\n\n<i>Claus-trophobia.</i>",
			"Where do you find chili beans?\n\n<i>The north pole.</i>",
			"What do you get from eating tree decorations?\n\n<i>Tinsilitis!</i>",
			"What do snowmen wear on their heads?\n\n<i>Ice caps!</i>",
			"Why is Christmas just like life on ss13?\n\n<i>You do all the work and the fat guy gets all the credit.</i>",
			"Why doesn�t Santa have any children?\n\n<i>Because he only comes down the chimney.</i>")
		new /obj/item/clothing/head/festive(target.loc)
		user.update_icons()
		cracked = 1
		icon_state = "cracker1"
		var/obj/item/weapon/toy/xmas_cracker/other_half = new /obj/item/weapon/toy/xmas_cracker(target)
		other_half.cracked = 1
		other_half.icon_state = "cracker2"
		target.put_in_active_hand(other_half)
		playsound(user, 'sound/effects/snap.ogg', 50, 1)
		return 1
	return ..()

/obj/item/clothing/head/festive
	name = "festive paper hat"
	icon_state = "xmashat"
	desc = "A crappy paper hat that you are REQUIRED to wear."
	flags_inv = 0
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0)

/obj/effect/landmark/xmastree
	name = "christmas tree spawner"
	var/tree = /obj/structure/flora/tree/pine/xmas

/obj/effect/landmark/xmastree/Initialize(mapload)
	..()
	if(FESTIVE_SEASON in SSevents.holidays)
		new tree(get_turf(src))
	qdel(src)

/obj/effect/landmark/xmastree/rdrod
	name = "festivus pole spawner"
	tree = /obj/structure/festivus

/datum/round_event_control/santa
	name = "Santa is coming to town! (Christmas)"
	holidayID = CHRISTMAS
	typepath = /datum/round_event/santa
	weight = 150
	max_occurrences = 1
	earliest_start = 20000

/datum/round_event/santa
	var/mob/living/carbon/human/santa //who is our santa?

/datum/round_event/santa/announce()
	priority_announce("Santa is coming to town!", "Unknown Transmission")

/datum/round_event/santa/start()
	for(var/mob/M in GLOB.dead_mob_list)
		spawn(0)
			var/response = alert(M, "Santa is coming to town! Do you want to be santa?", "Ho ho ho!", "Yes", "No")
			if(response == "Yes" && M && M.client && M.stat == DEAD && !santa)
				santa = new /mob/living/carbon/human(pick(GLOB.blobstart))
				santa.key = M.key
				qdel(M)

				santa.real_name = "Santa Claus"
				santa.name = "Santa Claus"
				santa.mind.name = "Santa Claus"
				santa.mind.assigned_role = "Santa"
				santa.mind.special_role = "Santa"

				santa.hair_style = "Long Hair"
				santa.facial_hair_style = "Full Beard"
				santa.hair_color = "FFF"
				santa.facial_hair_color = "FFF"

				santa.equip_to_slot_or_del(new /obj/item/clothing/under/color/red, slot_w_uniform)
				santa.equip_to_slot_or_del(new /obj/item/clothing/suit/space/santa, slot_wear_suit)
				santa.equip_to_slot_or_del(new /obj/item/clothing/head/santa, slot_head)
				santa.equip_to_slot_or_del(new /obj/item/clothing/mask/breath, slot_wear_mask)
				santa.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/red, slot_gloves)
				santa.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/red, slot_shoes)
				santa.equip_to_slot_or_del(new /obj/item/weapon/tank/internals/emergency_oxygen/double, slot_belt)
				santa.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain, slot_ears)
				santa.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/santabag, slot_back)
				santa.equip_to_slot_or_del(new /obj/item/device/flashlight, slot_r_store) //most blob spawn locations are really dark.

				var/obj/item/weapon/card/id/gold/santacard = new(santa)
				santacard.update_label("Santa Claus", "Santa")
				var/datum/job/captain/J = new/datum/job/captain
				santacard.access = J.get_access()
				santa.equip_to_slot_or_del(santacard, slot_wear_id)

				santa.update_icons()

				var/obj/item/weapon/storage/backpack/bag = santa.back
				var/obj/item/weapon/a_gift/gift = new(santa)
				while(bag.can_be_inserted(gift, 1))
					bag.handle_item_insertion(gift, 1)
					gift = new(santa)

				var/datum/objective/santa_objective = new()
				santa_objective.explanation_text = "Bring joy and presents to the station!"
				santa_objective.completed = 1 //lets cut our santas some slack.
				santa_objective.owner = santa.mind
				santa.mind.objectives += santa_objective
				santa.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/presents)
				var/obj/effect/proc_holder/spell/targeted/area_teleport/teleport/telespell = new(santa)
				telespell.clothes_req = 0 //santa robes aren't actually magical.
				santa.mind.AddSpell(telespell) //does the station have chimneys? WHO KNOWS!

				to_chat(santa, "<span class='boldannounce'>You are Santa! Your objective is to bring joy to the people on this station. You can conjure more presents using a spell, and there are several presents in your bag.</span>")
