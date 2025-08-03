/datum/action/changeling/biodegrade
	name = "Biodegrade"
	desc = "Dissolves restraints or other objects preventing free movement. Costs 30 chemicals."
	helptext = "This is obvious to nearby people, and can destroy standard restraints and closets."
	button_icon_state = "biodegrade"
	chemical_cost = 30 //High cost to prevent spam
	dna_cost = 2
	req_human = TRUE
	disabled_by_fire = FALSE

/datum/action/changeling/biodegrade/sting_action(mob/living/carbon/human/user)
	var/list/obj/restraints = list()
	var/obj/item/clothing/suit/straitjacket = user.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	if(!straitjacket?.breakouttime)
		straitjacket = null
	var/obj/legcuffs = user.get_item_by_slot(ITEM_SLOT_LEGCUFFED)
	var/obj/handcuffs = user.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
	var/obj/some_manner_of_cage = astype(user.loc, /obj)
	var/mob/living/space_invader = user.pulledby
	if(!straitjacket && !legcuffs && !handcuffs && !some_manner_of_cage && !space_invader)
		user.balloon_alert(user, "already free!")
		return FALSE
	..()
	if(straitjacket)
		restraints.Add(straitjacket)
	if(legcuffs)
		restraints.Add(legcuffs)
	if(handcuffs)
		restraints.Add(handcuffs)
	if(some_manner_of_cage)
		restraints.Add(some_manner_of_cage)
	for(var/obj/restraint as anything in restraints)
		spew_acid(user, restraint)
	if(space_invader)
		punish_with_acid(user, space_invader)
	return TRUE

/datum/action/changeling/biodegrade/proc/spew_acid(mob/living/carbon/human/user, obj/restraint)
	if(restraint == user.loc)
		restraint.visible_message(span_userdanger("Bubbling acid start spewing out of [restraint]..."))
		addtimer(CALLBACK(restraint, TYPE_PROC_REF(/atom, atom_destruction), ACID), 4 SECONDS)
		// create multiple decals to signal to anyone pushing the locker to the crematorium
		// that "oh lawd ling comin"
		for(var/beat in 1 to 3)
			addtimer(CALLBACK(src, PROC_REF(make_puddle), restraint), beat SECONDS)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), restraint, 'sound/items/tools/welder.ogg', 50, TRUE), beat SECONDS)
		return
	//otherwise it's some kind of worn restraint
	user.visible_message(
		span_userdanger("[user] spews torrents of acid onto [restraint], melting it with horrifying ease."),
		user.balloon_alert(user, "melting restraints..."),
		span_danger("You hear retching, then the sizzling of powerful acid, closer to the sound of hissing steam."))
	addtimer(CALLBACK(restraint, TYPE_PROC_REF(/atom, atom_destruction), ACID), 1.5 SECONDS)
	playsound(user, 'sound/items/tools/welder.ogg', 50, TRUE)
	make_puddle(restraint)

/datum/action/changeling/biodegrade/proc/make_puddle(obj/melted_restraint)
	return new /obj/effect/decal/cleanable/greenglow(get_turf(melted_restraint))

/datum/action/changeling/biodegrade/proc/punish_with_acid(mob/living/carbon/human/user, mob/living/hapless_manhandler)
	if(!iscarbon(hapless_manhandler))
		user.visible_message(
			span_danger("[user] spews a torrent of sizzling acid onto [hapless_manhandler], using the opportunity to wrestle away."),
			user.balloon_alert(user, "dissuading captor..."),
			span_danger("You hear retching, then sizzling, quickly muffled by a loud keening of pain."))
		playsound(user, 'sound/items/tools/welder.ogg', 50, TRUE)
		hapless_manhandler.emote("scream")
		hapless_manhandler.Stun(2 SECONDS)
		hapless_manhandler.adjustFireLoss(40, updating_health = TRUE)
		hapless_manhandler.stop_pulling()
		return
	var/mob/living/carbon/hapless_carbon = hapless_manhandler
	var/obj/item/bodypart/arm/doomed_limb = hapless_carbon.get_active_hand()
	var/bio_state = doomed_limb.biological_state
	var/danger_message
	if(!(bio_state & BIO_FLESH) && !(bio_state & BIO_BONE))
		if(bio_state & BIO_METAL)
			danger_message = "metal and wire"
		else
			danger_message = "the limb"
	else if (bio_state & BIO_FLESH)
		if(bio_state & BIO_BONE)
			danger_message = "blood and bone"
	else if (bio_state & BIO_BONE)
		danger_message = "the bony connections"
	else//someone was being silly with bio_state in this case but let's avoid a runtime
		danger_message = "the limb"
	user.visible_message(
		span_danger("[user] spews acid onto the arm [hapless_manhandler] grabs [user.p_them()] with, melting through [danger_message]!"),
		user.balloon_alert(user, "removing captor's grab..."),
		span_danger("You hear someone retching, followed quickly by a horrible sizzling, which is then muffled by a terrible wail of pain."))
	to_chat(hapless_carbon, span_userdanger("YOUR ARM IS MELTING OFF!"))
	playsound(user, 'sound/items/tools/welder.ogg', 50, TRUE)
	hapless_carbon.emote("scream")
	doomed_limb.dismember()
	hapless_carbon.Stun(2 SECONDS)
	hapless_carbon.stop_pulling()
	return
