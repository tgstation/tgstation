//Originally coded by ISaidNo, later modified by Kelenius. Ported from Baystation12.
// And then I, coiax, butchered the file to make a NEW BETTER mystery box

/obj/item/weapon/storage/briefcase/mystery
	name = "mystery box"
	// TODO make a variety of mystery box sprites and descriptions,
	// which either have different set of quests, or just pick them randomly
	// and either the same interface, or pick them randomly
	// ideas: syndicate monitoring device, abductor cube, box with a ? on it,
	// rubick's cube
	desc = "A seemingly discarded, dusty suitcase. It has a keypad."

	icon = 'icons/obj/storage.dmi'
	icon_state = "secure"
	item_state = "sec-case"

	var/victory_desc = " The lights on it are all green."
	var/failure_desc = " There are scorch marks visible at the seams."

	// Might still catch on fire in lava, but only if the box wants to
	burn_state = LAVA_PROOF
	unacidable = TRUE
	flags = HEAR

	var/locked = TRUE
	var/warning_given = FALSE

	var/datum/quest/quest

/obj/item/weapon/storage/briefcase/mystery/New()
	..()

	// We do not include a paper and pen in this mystery box
	for(var/atom/movable/AM in src)
		qdel(AM)

	SSobj.processing += src

	quest = new /datum/quest/just_say/potato()

	// Stored in mystery_loot.dm because of length
	add_loot()

/obj/item/weapon/storage/briefcase/mystery/attack_hand(mob/user)
	if ((src.loc == user) && (src.locked == 1))
		user << "<span class='warning'>[src] is locked and cannot be opened.</span>"
		return
	else
		return ..()

/obj/item/weapon/storage/briefcase/mystery/attack_self(mob/user)
	if(locked)
		if(!warning_given)
			user << "<span class='notice'>You press one of the buttons on the keypad...</span>"
			//TODO set up a variety of warning messages
			say_message("You have just activated a SRVYBX Pro 9053!")
			sleep(15)
			say_message("Please be aware that Box Co. \
				cannot accept any liability for \
				any injuries, damage or consequences that result from the \
				activation of this SRVYBX.")
			sleep(15)
			say_message("You continue at your own risk.")
			warning_given = TRUE
		else if(!quest.in_progress)
			user << "<span class='notice'>You press one of the buttons on the keypad...</span>"
			quest.begin()
		else
			quest.interact(src, user)
	else
		return ..()

/obj/item/weapon/storage/briefcase/mystery/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans)
	quest.Hear(message, speaker, message_langs, raw_message, radio_freq, spans)

/obj/item/weapon/storage/briefcase/mystery/process()
	while(quest.messages.len)
		var/datum/quest_message/message = quest.messages[1]
		quest.messages.Remove(message)
		say_message(message.text)
		sleep(15)
	if(quest.success && src.locked)
		unlock()

/obj/item/weapon/storage/briefcase/mystery/proc/say_message(text)
	src.audible_message("\icon[src] [text]")
	playsound(loc, 'sound/effects/messagejump.ogg', 50, 0)

/obj/item/weapon/storage/briefcase/mystery/proc/unlock()
	src.audible_message("<span class='notice'>Tinny congratulatory music plays, as you hear the [src] unlock.</span>", "The lights on the [src] all go green.")
	playsound(loc, 'sound/effects/yourwinner.ogg', 50, 0)
	locked = FALSE
	desc += victory_desc
	// It's not relockable, it is now an "ordinary" briefcase
	// unless certain special conditions are triggered

/obj/item/weapon/storage/briefcase/mystery/ex_act(strength)
	// Made from 100% obsidian
	return

/obj/item/weapon/storage/briefcase/mystery/Destroy()
	// If for any reason it's blown up without playing by the rules,
	// you only get the youtried wrapper
	if(locked)
		for(var/atom/movable/AM in src)
			qdel(AM)

		src += new /obj/item/trash/candy/youtried

	SSobj.processing -= src

	return ..()

/obj/item/weapon/storage/briefcase/mystery/attack_alien(mob/user)
	// We don't discriminate, aliens are allowed to get items they
	// probably can't use from the box.
	attack_hand(user)

/obj/item/weapon/storage/briefcase/mystery/emag_act(mob/user)
	if(locked)
		// No.
		user.visible_message("<span class='warning'>Sparks fly from the [src]!</span>")
		boom()

/obj/item/weapon/storage/briefcase/mystery/attackby(obj/item/weapon/W, mob/user)
	if(locked)
		if(istype(W, /obj/item/device/multitool))
			user << "<span class='notice'>The [W] doesn't seem to be able to interface with the [src].</span>"
		else
			return ..()
	else
		return ..()

/obj/item/weapon/storage/briefcase/mystery/proc/boom(mob/user)
	if(!locked)
		// Anti-tamper system is disabled when unlocked.
		// Anti-tamper shouldn't trigger when unlocked anyway
		return

	src.visible_message("<span class='warning'>[src]'s anti-tamper system activates! Light flashes through the gaps! You smell smoke...</span>", "<span class='warning'>A harsh alarm sounds, and then a hiss. You smell smoke...</span>")
	// TODO need some sort of harsh alarm sound effect plus cooking

	for(var/atom/movable/AM in src)
		qdel(AM)

	src += new /obj/item/trash/candy/youtried
	desc += failure_desc

	// Well done, it's just a useless box/suitcase/whatever now
	// Enjoy choking on the wrapper
	locked = FALSE

/obj/item/weapon/storage/briefcase/mystery/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] seems frustrated by the mystery posed by \the [src]! \He seems to be giving up on life.</span>")

	// Don't waste this delicious soul
	var/obj/item/weapon/reagent_containers/food/snacks/candy/youtried/YT
	YT = new(get_turf(user))
	YT.flavour(user)
	qdel(YT)

	src.audible_message("<span class='notice'>You hear a faint hum from inside the [src].</span>")
	return OXYLOSS


/obj/item/weapon/reagent_containers/food/snacks/candy/youtried
	name = "UTried(tm) candy"
	desc = "It\'s a delicious 'UTried' candy bar, still in its wrapper. For some reason, you can only open it a little bit.\nA warning on the side recommends you do not eat the candy too quickly in an attempt to end your life."
	// Yes, this is an INFINITE candy bar. Which makes the empty wrapper
	// even more disturbing.
	trash = /obj/item/weapon/reagent_containers/food/snacks/candy/youtried

/obj/item/weapon/reagent_containers/food/snacks/candy/youtried/New()
	..()
	// Why would't ghosts want to follow an immortal candy bar?
	poi_list |= src

/obj/item/weapon/reagent_containers/food/snacks/candy/youtried/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] eating the [src] far too quickly! It looks like they're trying to commit suicide through empty calories...")
	src.visible_message("<span class='warning'>The [src] shines brightly for a moment, and then dims.</span>", "You hear a faint hum.")
	replicate(user)
	return (TOXLOSS | OXYLOSS)

/obj/item/weapon/reagent_containers/food/snacks/candy/youtried/proc/flavour(mob/user)
	src.name = initial(src.name) + " (" + user.real_name + " flavour)"
	src.desc = initial(src.desc) + "\nThis bar seems to be flavoured with " + user.real_name + "."

/obj/item/weapon/reagent_containers/food/snacks/candy/youtried/proc/replicate(mob/user)

	var/turf/T = get_turf(user)
	var/obj/item/weapon/reagent_containers/food/snacks/candy/youtried/child = new(T)
	child.flavour(user)
	qdel(child)
	// Why yes, this does make a new immortal candy bar and then teleport
	// it somewhere else.
	// I SURE HOPE THIS ISN'T HOW IMMORTAL CANDY BARS REPRODUCE, UNTIL
	// SOMEONE TRIES TO LOCK IT AWAY, BUT ONE DAY, PANDORA OPENS THE BOX
	// AND THE BARS WILL CONSUME US ALL

/obj/item/weapon/reagent_containers/food/snacks/candy/youtried/Destroy()
	// I DID MOST DEFINITELY NOT COPY AND PASTE THIS FROM THE NUKE DISK
	// CODE, HOW DARE YOU ACCUSE ME OF SUCH A THING
	if(blobstart.len > 0)
		var/turf/targetturf = get_turf(pick(blobstart))
		var/turf/diskturf = get_turf(src)
		if(ismob(loc))
			var/mob/M = loc
			M.remove_from_mob(src)
		if(istype(loc, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = loc
			S.remove_from_storage(src, diskturf)
		forceMove(targetturf) //move the disc, so ghosts remain orbitting it even if it's "destroyed"
	else
		throw EXCEPTION("Unable to find a blobstart landmark")
	return QDEL_HINT_LETMELIVE //Cancel destruction regardless of success

/obj/item/trash/candy/youtried
	name = "'UTried' candy wrapper"
	desc = "It\'s a 'UTried' candy wrapper. It's slightly burnt, and smells toxic. A warning on it warns the wrapper is not suitable for consumption by carbon based lifeforms."
	burn_state = LAVA_PROOF // CANNOT BURN WHAT HAS ALREADY BEEN BURNT
	// But the wrapper is not immortal, it's just annoying.

/obj/item/trash/candy/youtried/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is swallowing the [src]. It looks like \he's trying to commit suicide...</span>")

	// TODO when the stomach organ is implemented, move it to that instead
	if(istype(user, /mob/living/carbon))
		var/mob/living/carbon/C = user
		C.stomach_contents += src
	src.loc = user

	return (TOXLOSS | OXYLOSS)
