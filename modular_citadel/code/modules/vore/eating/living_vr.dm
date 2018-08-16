///////////////////// Mob Living /////////////////////
/mob/living
	var/digestable = TRUE					// Can the mob be digested inside a belly?
	var/obj/belly/vore_selected		// Default to no vore capability.
	var/list/vore_organs = list()		// List of vore containers inside a mob
	var/devourable = FALSE					// Can the mob be vored at all?
//	var/feeding = FALSE					// Are we going to feed someone else?
	var/vore_taste = null				// What the character tastes like
	var/no_vore = FALSE 					// If the character/mob can vore.
	var/openpanel = 0					// Is the vore panel open?
	var/noisy = FALSE					// tummies are rumbly?
	var/absorbed = FALSE				//are we absorbed?

//
// Hook for generic creation of stuff on new creatures
//
/hook/living_new/proc/vore_setup(mob/living/M)
	M.verbs += /mob/living/proc/preyloop_refresh
	M.verbs += /mob/living/proc/lick
	M.verbs += /mob/living/proc/escapeOOC

	if(M.no_vore) //If the mob isn't supposed to have a stomach, let's not give it an insidepanel so it can make one for itself, or a stomach.
		return 1
	M.verbs += /mob/living/proc/insidePanel

	//Tries to load prefs if a client is present otherwise gives freebie stomach
	spawn(20 SECONDS) // long delay because the server delays in its startup. just on the safe side.
		M.init_vore()

	//Return 1 to hook-caller
	return 1

/mob/living/proc/init_vore()
	//Something else made organs, meanwhile.
	if(LAZYLEN(vore_organs))
		return TRUE

	//We'll load our client's organs if we have one
	if(client && client.prefs_vr)
		if(!copy_from_prefs_vr())
			to_chat(src,"<span class='warning'>ERROR: You seem to have saved vore prefs, but they couldn't be loaded.</span>")
			return FALSE
		if(LAZYLEN(vore_organs))
			vore_selected = vore_organs[1]
			return TRUE

	//Or, we can create a basic one for them
	if(!LAZYLEN(vore_organs))
		LAZYINITLIST(vore_organs)
		var/obj/belly/B = new /obj/belly(src)
		vore_selected = B
		B.immutable = 1
		B.name = "Stomach"
		B.desc = "It appears to be rather warm and wet. Makes sense, considering it's inside [name]."
		B.can_taste = 1
		return TRUE

/*
// Hide vore organs in contents
//
/datum/proc/view_variables_filter_contents(list/L)
	return 0

/mob/living/view_variables_filter_contents(list/L)
	. = ..()
	var/len_before = L.len
	L -= vore_organs
	. += len_before - L.len*/

// Handle being clicked, perhaps with something to devour
//

			// Refactored to use centralized vore code system - Leshana

			// Critical adjustments due to TG grab changes - Poojawa

/mob/living/proc/vore_attack(var/mob/living/user, var/mob/living/prey)
	if(!user || !prey)
		return

	if(prey == src && user.zone_selected == "mouth") //you click your target
//		if(!feeding(src))
//			return
		if(!is_vore_predator(prey))
			to_chat(user, "<span class='notice'>They aren't voracious enough.</span>")
			return
		feed_self_to_grabbed(user, src)

	if(user == src) //you click yourself
		if(!is_vore_predator(src))
			to_chat(user, "<span class='notice'>You aren't voracious enough.</span>")
			return
		user.feed_grabbed_to_self(src, prey)

	else // click someone other than you/prey
//		if(!feeding(src))
//			return
		if(!is_vore_predator(src))
			to_chat(user, "<span class='notice'>They aren't voracious enough.</span>")
			return
		feed_grabbed_to_other(user, prey, src)
//
// Eating procs depending on who clicked what
//
/mob/living/proc/feed_grabbed_to_self(var/mob/living/user, var/mob/living/prey)
	var/belly = user.vore_selected
	return perform_the_nom(user, prey, user, belly)
/*
/mob/living/proc/eat_held_mob(var/mob/living/user, var/mob/living/prey, var/mob/living/pred)
	var/belly
	if(user != pred)
		belly = input("Choose Belly") in pred.vore_organs
	else
		belly = pred.vore_selected
	return perform_the_nom(user, prey, pred, belly)*/

/mob/living/proc/feed_self_to_grabbed(var/mob/living/user, var/mob/living/pred)
	var/belly = input("Choose Belly") in pred.vore_organs
	return perform_the_nom(user, user, pred, belly)

/mob/living/proc/feed_grabbed_to_other(var/mob/living/user, var/mob/living/prey, var/mob/living/pred)
	return//disabled until I can make that toggle work
	var/belly = input("Choose Belly") in pred.vore_organs
	return perform_the_nom(user, prey, pred, belly)

//Dragon noms need to be faster
/mob/living/proc/dragon_feeding(var/mob/living/user, var/mob/living/prey)
	var/belly = user.vore_selected
	return perform_dragon(user, prey, user, belly)

/mob/living/proc/perform_dragon(var/mob/living/user, var/mob/living/prey, var/mob/living/pred, var/obj/belly/belly, swallow_time = 20)
	//Sanity
	if(!user || !prey || !pred || !istype(belly) || !(belly in pred.vore_organs))
		testing("[user] attempted to feed [prey] to [pred], via [lowertext(belly.name)] but it went wrong.")
		return

	// The belly selected at the time of noms
	var/attempt_msg = "ERROR: Vore message couldn't be created. Notify a dev. (at)"
	var/success_msg = "ERROR: Vore message couldn't be created. Notify a dev. (sc)"

/*	//Final distance check. Time has passed, menus have come and gone. Can't use do_after adjacent because doesn't behave for held micros
	var/user_to_pred = get_dist(get_turf(user),get_turf(pred))
	var/user_to_prey = get_dist(get_turf(user),get_turf(prey)) */

		// Prepare messages
	if(user == pred) //Feeding someone to yourself
		attempt_msg = text("<span class='warning'>[] starts to [] [] into their []!</span>",pred,lowertext(belly.vore_verb),prey,lowertext(belly.name))
		success_msg = text("<span class='warning'>[] manages to [] [] into their []!</span>",pred,lowertext(belly.vore_verb),prey,lowertext(belly.name))

	// Announce that we start the attempt!
	user.visible_message(attempt_msg)

	if(!do_mob(src, user, swallow_time))
		return FALSE // Prey escaped (or user disabled) before timer expired.

	// If we got this far, nom successful! Announce it!
	user.visible_message(success_msg)
	playsound(get_turf(user), "[belly.vore_sound]",75,0,-6,0)

	// Actually shove prey into the belly.
	belly.nom_mob(prey, user)
	if (pred == user)
		message_admins("[key_name(pred)] ate [key_name(prey)].")
		log_attack("[key_name(pred)] ate [key_name(prey)]")
	return TRUE
//
// Master vore proc that actually does vore procedures
//

/mob/living/proc/perform_the_nom(var/mob/living/user, var/mob/living/prey, var/mob/living/pred, var/obj/belly/belly, var/delay)
	//Sanity
	if(!user || !prey || !pred || !istype(belly) || !(belly in pred.vore_organs))
		testing("[user] attempted to feed [prey] to [pred], via [lowertext(belly.name)] but it went wrong.")
		return
	if (!prey.devourable)
		to_chat(user, "This can't be eaten!")
		return
	// The belly selected at the time of noms
	var/attempt_msg = "ERROR: Vore message couldn't be created. Notify a dev. (at)"
	var/success_msg = "ERROR: Vore message couldn't be created. Notify a dev. (sc)"

/*	//Final distance check. Time has passed, menus have come and gone. Can't use do_after adjacent because doesn't behave for held micros
	var/user_to_pred = get_dist(get_turf(user),get_turf(pred))
	var/user_to_prey = get_dist(get_turf(user),get_turf(prey)) */

	// Prepare messages
	if(user == pred) //Feeding someone to yourself
		attempt_msg = text("<span class='warning'>[] is attemping to [] [] into their []!</span>",pred,lowertext(belly.vore_verb),prey,lowertext(belly.name))
		success_msg = text("<span class='warning'>[] manages to [] [] into their []!</span>",pred,lowertext(belly.vore_verb),prey,lowertext(belly.name))
	else //Feeding someone to another person
		attempt_msg = text("<span class='warning'>[] is attempting to make [] [] [] into their []!</span>",user,pred,lowertext(belly.vore_verb),prey,lowertext(belly.name))
		success_msg = text("<span class='warning'>[] manages to make [] [] [] into their []!</span>",user,pred,lowertext(belly.vore_verb),prey,lowertext(belly.name))

	if(!prey.Adjacent(user)) // let's not even bother attempting it yet if they aren't next to us.
		return FALSE
		
	// Announce that we start the attempt!
	user.visible_message(attempt_msg)

	// Now give the prey time to escape... return if they did
	var/swallow_time = delay || ishuman(prey) ? belly.human_prey_swallow_time : belly.nonhuman_prey_swallow_time
		
	if(!do_mob(src, user, swallow_time))
		return FALSE // Prey escaped (or user disabled) before timer expired.

	if(!prey.Adjacent(user)) //double check'd just in case they moved during the timer and the do_mob didn't fail for whatever reason
		return FALSE
		
	// If we got this far, nom successful! Announce it!
	user.visible_message(success_msg)
	for(var/mob/M in get_hearers_in_view(5, get_turf(user)))
		if(M.client && M.client.prefs.cit_toggles & EATING_NOISES)
			playsound(get_turf(user),"[belly.vore_sound]",50,0,-5,0,ignore_walls = FALSE,channel=CHANNEL_PRED)

	// Actually shove prey into the belly.
	belly.nom_mob(prey, user)
//	user.update_icons()
	stop_pulling()

	// Flavor handling
	if(belly.can_taste && prey.get_taste_message(FALSE))
		to_chat(belly.owner, "<span class='notice'>[prey] tastes of [prey.get_taste_message(FALSE)].</span>")

	// Inform Admins
	var/prey_braindead
	var/prey_stat
	if(prey.ckey)
		prey_stat = prey.stat//only return this if they're not an unmonkey or whatever
		if(!prey.client)//if they disconnected, tell us
			prey_braindead = 1
	if (pred == user)
		message_admins("[ADMIN_LOOKUPFLW(pred)] ate [ADMIN_LOOKUPFLW(prey)][!prey_braindead ? "" : " (BRAINDEAD)"][prey_stat ? " (DEAD/UNCONSCIOUS)" : ""].")
		log_attack("[key_name(pred)] ate [key_name(prey)]")
	else
		message_admins("[ADMIN_LOOKUPFLW(user)] forced [ADMIN_LOOKUPFLW(pred)] to eat [ADMIN_LOOKUPFLW(prey)].")
		log_attack("[key_name(user)] forced [key_name(pred)] to eat [key_name(prey)].")
	return TRUE

//
//End vore code.
/*
	//Handle case: /obj/item/holder
		if(/obj/item/holder/micro)
			var/obj/item/holder/H = I

			if(!isliving(user)) return 0 // Return 0 to continue upper procs
			var/mob/living/attacker = user  // Typecast to living

			if (is_vore_predator(src))
				for (var/mob/living/M in H.contents)
					attacker.eat_held_mob(attacker, M, src)
				return 1 //Return 1 to exit upper procs
			else
				log_attack("[attacker] attempted to feed [H.contents] to [src] ([src.type]) but it failed.")

 // I just can't imagine this not being complained about
	//Handle case: /obj/item/radio/beacon
		if(/obj/item/radio/beacon)
			var/confirm = alert(user, "[src == user ? "Eat the beacon?" : "Feed the beacon to [src]?"]", "Confirmation", "Yes!", "Cancel")
			if(confirm == "Yes!")
				var/bellychoice = input("Which belly?","Select A Belly") in src.vore_organs
				var/datum/belly/B = src.vore_organs[bellychoice]
				src.visible_message("<span class='warning'>[user] is trying to stuff a beacon into [src]'s [bellychoice]!</span>","<span class='warning'>[user] is trying to stuff a beacon into you!</span>")
				if(do_after(user,30,src))
					user.drop_item()
					I.loc = src
					B.internal_contents += I
					src.visible_message("<span class='warning'>[src] is fed the beacon!</span>","You're fed the beacon!")
					playsound(get_turf(src), B.vore_sound,50,0,-6,0)
					return 1
				else
					return 1 //You don't get to hit someone 'later'

	return 0
*/

//
// Release everything in every vore organ
//
/mob/living/proc/release_vore_contents(var/include_absorbed = TRUE)
	for(var/belly in vore_organs)
		var/obj/belly/B = belly
		B.release_all_contents(include_absorbed)

//
// Custom resist catches for /mob/living
//
/mob/living/proc/vore_process_resist()

	//Are we resisting from inside a belly?
	if(isbelly(loc))
		var/obj/belly/B = loc
		B.relay_resist(src)
		return TRUE //resist() on living does this TRUE thing.

	//Other overridden resists go here

	return FALSE

// internal slimy button in case the loop stops playing but the player wants to hear it
/mob/living/proc/preyloop_refresh()
	set name = "Internal loop refresh"
	set category = "Vore"
	if(isbelly(loc))
		src.stop_sound_channel(CHANNEL_PREYLOOP) // sanity just in case
		var/sound/preyloop = sound('sound/vore/prey/loop.ogg', repeat = TRUE)
		src.playsound_local(get_turf(src),preyloop,80,0, channel = CHANNEL_PREYLOOP)
	else
		to_chat(src, "<span class='alert'>You aren't inside anything, you clod.</span>")

// OOC Escape code for pref-breaking or AFK preds
//
/mob/living/proc/escapeOOC()
	set name = "OOC Escape"
	set category = "Vore"

	//You're in a belly!
	if(isbelly(loc))
		var/obj/belly/B = loc
		var/confirm = alert(src, "You're in a mob. If you're otherwise unable to escape from a pred AFK for a long time, use this.", "Confirmation", "Okay", "Cancel")
		if(!confirm == "Okay" || loc != B)
			return
		//Actual escaping
		forceMove(get_turf(src)) //Just move me up to the turf, let's not cascade through bellies, there's been a problem, let's just leave.
		if(is_blind(src) && !has_trait(TRAIT_BLIND))
			src.adjust_blindness(-1)
		src.stop_sound_channel(CHANNEL_PREYLOOP)
		for(var/mob/living/simple_animal/SA in range(10))
			SA.prey_excludes[src] = world.time

		if(isanimal(B.owner))
			var/mob/living/simple_animal/SA = B.owner
			SA.update_icons()

	//You're in a dogborg!
	else if(istype(loc, /obj/item/dogborg/sleeper))
		var/obj/item/dogborg/sleeper/belly = loc //The belly!

		var/confirm = alert(src, "You're in a dogborg sleeper. This is for escaping from preference-breaking or if your predator disconnects/AFKs. You can also resist out naturally too.", "Confirmation", "Okay", "Cancel")
		if(!confirm == "Okay" || loc != belly)
			return
		//Actual escaping
		belly.go_out(src) //Just force-ejects from the borg as if they'd clicked the eject button.
	else
		to_chat(src,"<span class='alert'>You aren't inside anyone, though, is the thing.</span>")

//
//	Verb for saving vore preferences to save file
//
/mob/living/proc/save_vore_prefs()
	if(!client)
		return FALSE
	if(client && !client.prefs_vr)
		return FALSE
	if(!copy_to_prefs_vr())
		return FALSE
	if(client && !client.prefs_vr.save_vore())
		return FALSE

	return TRUE

/mob/living/proc/apply_vore_prefs()
	if(!client)
		return FALSE
	if(client && !client.prefs_vr)
		return FALSE
	if(client && !client.prefs_vr.load_vore())
		return FALSE
	if(!copy_from_prefs_vr())
		return FALSE

	return TRUE

/mob/living/proc/copy_to_prefs_vr()
	if(!client)
		return FALSE
	if(client && !client.prefs_vr)
		src << "<span class='warning'>You attempted to save your vore prefs but somehow you're in this character without a client.prefs_vr variable. Tell a dev.</span>"
		return FALSE

	var/datum/vore_preferences/P = client.prefs_vr

	P.digestable = src.digestable
	P.devourable = src.devourable
	P.vore_taste = src.vore_taste

	var/list/serialized = list()
	for(var/belly in src.vore_organs)
		var/obj/belly/B = belly
		serialized += list(B.serialize()) //Can't add a list as an object to another list in Byond. Thanks.

	P.belly_prefs = serialized

	return TRUE

//
//	Proc for applying vore preferences, given bellies
//
/mob/living/proc/copy_from_prefs_vr()
	if(!client)
		return FALSE
	if(client && !client.prefs_vr)
		src << "<span class='warning'>You attempted to apply your vore prefs but somehow you're in this character without a client.prefs_vr variable. Tell a dev.</span>"
		return FALSE

	var/datum/vore_preferences/P = client.prefs_vr

	digestable = P.digestable
	devourable = P.devourable
	vore_taste = P.vore_taste

	vore_organs.Cut()
	for(var/entry in P.belly_prefs)
		list_to_object(entry,src)

	return TRUE

//
// Returns examine messages for bellies
//
/mob/living/proc/examine_bellies()
	if(!show_pudge()) //Some clothing or equipment can hide this.
		return ""

	var/message = ""
	for (var/belly in vore_organs)
		var/obj/belly/B = belly
		message += B.get_examine_msg()

	return message

//
// Whether or not people can see our belly messages
//
/mob/living/proc/show_pudge()
	return TRUE //Can override if you want.

/mob/living/carbon/human/show_pudge()
	//A uniform could hide it.
	if(istype(w_uniform,/obj/item/clothing))
		var/obj/item/clothing/under = w_uniform
		if(under.hides_bulges)
			return FALSE

	//We return as soon as we find one, no need for 'else' really.
	if(istype(wear_suit,/obj/item/clothing))
		var/obj/item/clothing/suit = wear_suit
		if(suit.hides_bulges)
			return FALSE


	return ..()

//
// Clearly super important. Obviously.
//
/mob/living/proc/lick(var/mob/living/tasted in oview(1))
	set name = "Lick Someone"
	set category = "Vore"
	set desc = "Lick someone nearby!"

	if(!istype(tasted))
		return

	if(src == stat)
		return

	src.setClickCooldown(100)

	src.visible_message("<span class='warning'>[src] licks [tasted]!</span>","<span class='notice'>You lick [tasted]. They taste rather like [tasted.get_taste_message()].</span>","<b>Slurp!</b>")


/mob/living/proc/get_taste_message(allow_generic = TRUE, datum/species/mrace)
	if(!vore_taste && !allow_generic)
		return FALSE

	var/taste_message = ""
	if(vore_taste && (vore_taste != ""))
		taste_message += "[vore_taste]"
	else
		if(ishuman(src))
			taste_message += "they haven't bothered to set their flavor text"
		else
			taste_message += "a plain old normal [src]"

/*	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.touching.reagent_list.len) //Just the first one otherwise I'll go insane.
			var/datum/reagent/R = H.touching.reagent_list[1]
			taste_message += " You also get the flavor of [R.taste_description] from something on them"*/
	return taste_message
