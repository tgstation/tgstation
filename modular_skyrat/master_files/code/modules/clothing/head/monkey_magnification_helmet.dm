/obj/item/clothing/head/helmet/monkey_sentience
	name = "monkey mind magnification helmet"
	desc = "A fragile, circuitry embedded helmet for boosting the intelligence of a monkey to a higher level. You see several warning labels..."
	icon_state = "monkeymind"
	inhand_icon_state = "monkeymind"
	strip_delay = 100
	armor = list(MELEE = 5, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 25, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, WOUND = 0)
	var/mob/living/carbon/human/magnification = null ///if the helmet is on a valid target (just works like a normal helmet if not (cargo please stop))
	var/polling = FALSE///if the helmet is currently polling for targets (special code for removal)
	var/light_colors = 1 ///which icon state color this is (red, blue, yellow)

/obj/item/clothing/head/helmet/monkey_sentience/Initialize()
	. = ..()
	light_colors = rand(1,3)
	update_appearance()

/obj/item/clothing/head/helmet/monkey_sentience/examine(mob/user)
	. = ..()
	. += "<span class='boldwarning'>---WARNING: REMOVAL OF HELMET ON SUBJECT MAY LEAD TO:---</span>"
	. += "<span class='warning'>BLOOD RAGE</span>"
	. += "<span class='warning'>BRAIN DEATH</span>"
	. += "<span class='warning'>PRIMAL GENE ACTIVATION</span>"
	. += "<span class='warning'>GENETIC MAKEUP MASS SUSCEPTIBILITY</span>"
	. += "<span class='boldnotice'>Ask your CMO if mind magnification is right for you.</span>"

/obj/item/clothing/head/helmet/monkey_sentience/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][light_colors][magnification ? "up" : null]"

/obj/item/clothing/head/helmet/monkey_sentience/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_HEAD)
		return
	if(istype(user, /mob/living/carbon/human/dummy)) //Prevents ghosts from being polled when the helmet is put on a dummy.
		return
	if(!ismonkey(user) || user.ckey)
		var/mob/living/something = user
		to_chat(something, "<span class='boldnotice'>You feel a stabbing pain in the back of your head for a moment.</span>")
		something.apply_damage(5,BRUTE,BODY_ZONE_HEAD,FALSE,FALSE,FALSE) //notably: no damage resist (it's in your helmet), no damage spread (it's in your helmet)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		return
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		say("ERROR: Central Command has temporarily outlawed monkey sentience helmets in this sector. NEAREST LAWFUL SECTOR: 2.537 million light years away.")
		return
	magnification = user //this polls ghosts
	visible_message("<span class='warning'>[src] powers up!</span>")
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	RegisterSignal(magnification, COMSIG_SPECIES_LOSS, .proc/make_fall_off)
	INVOKE_ASYNC(src, /obj/item/clothing/head/helmet/monkey_sentience.proc/connect, user)

/obj/item/clothing/head/helmet/monkey_sentience/proc/connect(mob/user)
	polling = TRUE
	var/list/candidates = poll_candidates_for_mob("Do you want to play as a mind magnified monkey?", ROLE_SENTIENCE, target_mob = magnification, ignore_category = POLL_IGNORE_SENTIENCE_POTION)
	polling = FALSE
	if(!magnification)
		return
	if(!candidates.len)
		UnregisterSignal(magnification, COMSIG_SPECIES_LOSS)
		magnification = null
		visible_message("<span class='notice'>[src] falls silent and drops on the floor. Maybe you should try again later?</span>")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		user.dropItemToGround(src)
		return
	var/mob/picked = pick(candidates)
	magnification.key = picked.key
	playsound(src, 'sound/machines/microwave/microwave-end.ogg', 100, FALSE)
	to_chat(magnification, "<span class='notice'>You're a mind magnified monkey! Protect your helmet with your life- if you lose it, your sentience goes with it!</span>")
	var/policy = get_policy(ROLE_MONKEY_HELMET)
	if(policy)
		to_chat(magnification, policy)
	icon_state = "[icon_state]up"
	REMOVE_TRAIT(magnification, TRAIT_PRIMITIVE, SPECIES_TRAIT) //Monkeys with sentience should be able to use less primitive tools.

/obj/item/clothing/head/helmet/monkey_sentience/Destroy()
	if(magnification)
		ADD_TRAIT(magnification, TRAIT_PRIMITIVE, SPECIES_TRAIT)
		magnification = null
	return ..()

/obj/item/clothing/head/helmet/monkey_sentience/proc/disconnect()
	if(!magnification) //not put on a viable head
		return
	//either used up correctly or taken off before polling finished (punish this by having a chance to gib the monkey?)
	UnregisterSignal(magnification, COMSIG_SPECIES_LOSS)
	playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
	ADD_TRAIT(magnification, TRAIT_PRIMITIVE, SPECIES_TRAIT) //We removed it, now that they're back to being dumb, add the trait again.
	if(!polling)//put on a viable head, but taken off after polling finished.
		if(magnification.client)
			to_chat(magnification, "<span class='userdanger'>You feel your flicker of sentience ripped away from you, as everything becomes dim...</span>")
			magnification.ghostize(FALSE)
		if(prob(10))
			switch(rand(1,4))
				if(1) //blood rage
					magnification.ai_controller.blackboard[BB_MONKEY_AGGRESSIVE] = TRUE
				if(2) //brain death
					magnification.apply_damage(500,BRAIN,BODY_ZONE_HEAD,FALSE,FALSE,FALSE)
				if(3) //primal gene (gorilla)
					magnification.gorillize()
				if(4) //genetic mass susceptibility (gib)
					magnification.gib()
	magnification = null

/obj/item/clothing/head/helmet/monkey_sentience/dropped(mob/user)
	. = ..()
	disconnect()

/obj/item/clothing/head/helmet/monkey_sentience/proc/make_fall_off()
	SIGNAL_HANDLER
	if(magnification)
		visible_message("<span class='warning'>[src] falls off of [magnification]'s head as it changes shape!</span>")
		magnification.dropItemToGround(src)
