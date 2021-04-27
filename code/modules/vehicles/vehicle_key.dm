/obj/item/key
	name = "key"
	desc = "A small grey key."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "key"
	w_class = WEIGHT_CLASS_TINY
	/// You can only do a big jingle that affects people this often, otherwise it just plays the jingle sound more quietly
	var/big_jingle_delay = 5 SECONDS
	/// The cooldown for big jingles
	COOLDOWN_DECLARE(big_jingle_cd)

/obj/item/key/attack_self(mob/user, modifiers)
	if(!COOLDOWN_FINISHED(src, big_jingle_cd))
		to_chat(user, "<span class='smallnotice'>You jingle the keys in your hand softly...</span>")
		playsound(src, pick('sound/items/key_jingle01.ogg', 'sound/items/key_jingle02.ogg'), 30)
		return

	. = ..()

	COOLDOWN_START(src, big_jingle_cd, big_jingle_delay)
	user.visible_message("<span class='notice'>[user] jingles [user.p_their()] keys around in an enticing fashion.</span>", "<span class='notice'>You jingle the keys around in an enticing fashion.</span>")
	playsound(src, pick('sound/items/key_jingle01.ogg', 'sound/items/key_jingle02.ogg'), 60)

	for(var/mob/living/iter_living in view(5, get_turf(user)))
		if(iter_living.stat > CONSCIOUS)
			continue

		if(prob(50) && HAS_TRAIT(iter_living, TRAIT_DUMB)) // 50% chance to freeze those with simple minds
			iter_living.visible_message("<span class='danger'>[iter_living] freezes in [iter_living.p_their()] tracks, transfixed by the jingling keys...</span>",\
				"<span class='userdanger'>Is that-... are those... jingle jingle jingle... beautiful...</span>", vision_distance = COMBAT_MESSAGE_RANGE)
			iter_living.Stun(rand(1 SECONDS, 3 SECONDS))
		else if(prob(20) && (isfelinid(iter_living) || ismoth(iter_living)))
			if(prob(50)) // 50% chance for felinids/moths to instantly pounce, to add some risk to the jingler
				iter_living.visible_message("<span class='danger'>[iter_living] snaps [iter_living.p_their()] attention to the jingling keys and, with the reflexes of a trained hunter, pounces!<span>",\
				"<span class='userdanger'>Can't... resist... KEYS!</span>", vision_distance = COMBAT_MESSAGE_RANGE)
				iter_living.AddComponent(/datum/component/tackler/one_shot, skill_mod = 2, target=user)
			else // otherwise, wait a moment...
				var/delay = rand(1 SECONDS, 3 SECONDS)
				iter_living.visible_message("<span class='danger'>[iter_living] freezes in place, tensing up at the jingling keys, waiting to strike...<span>",\
				"<span class='userdanger'>Must have... jingles... wait for it...</span>", vision_distance = COMBAT_MESSAGE_RANGE)
				iter_living.Stun(delay - 2)
				iter_living.AddComponent(/datum/component/tackler/one_shot, skill_mod = 2, target = user, delay = delay)

/obj/item/key/atv
	name = "ATV key"
	desc = "A small grey key for starting and operating ATVs."

/obj/item/key/security
	desc = "A keyring with a small steel key, and a rubber stun baton accessory."
	icon_state = "keysec"

/obj/item/key/security/suicide_act(mob/living/carbon/user)
	if(!user.emote("spin")) //In the off chance that someone attempts this suicide while under the effects of mime's bane they deserve the silliness.
		user.visible_message("<span class='suicide'>[user] is putting \the [src] in [user.p_their()] ear and starts [user.p_their()] motor! It looks like [user.p_theyre()] trying to commit suicide... But [user.p_they()] sputters and stalls out! </span>")
		playsound(src, 'sound/misc/sadtrombone.ogg', 50, TRUE, -1)
		return SHAME
	user.visible_message("<span class='suicide'>[user] is putting \the [src] in [user.p_their()] ear and starts [user.p_their()] motor! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	user.say("Vroom vroom!!", forced="secway key suicide") //Not doing a shamestate here, because even if they fail to speak they're spinning.
	addtimer(CALLBACK(user, /mob/living/.proc/gib), 20)
	return MANUAL_SUICIDE

/obj/item/key/janitor
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon_state = "keyjanitor"

/obj/item/key/janitor/suicide_act(mob/living/carbon/user)
	switch(user.mind?.get_skill_level(/datum/skill/cleaning))
		if(SKILL_LEVEL_NONE to SKILL_LEVEL_NOVICE) //Their mind is too weak to ascend as a janny
			user.visible_message("<span class='suicide'>[user] is putting \the [src] in [user.p_their()] mouth and is trying to become one with the janicart, but has no idea where to start! It looks like [user.p_theyre()] trying to commit suicide!</span>")
			user.gib()
			return MANUAL_SUICIDE
		if(SKILL_LEVEL_APPRENTICE to SKILL_LEVEL_JOURNEYMAN) //At least they tried
			user.visible_message("<span class='suicide'>[user] is putting \the [src] in [user.p_their()] mouth and has inefficiently become one with the janicart! It looks like [user.p_theyre()] trying to commit suicide!</span>")
			user.AddElement(/datum/element/cleaning)
			addtimer(CALLBACK(src, .proc/manual_suicide, user), 51)
			return MANUAL_SUICIDE
		if(SKILL_LEVEL_EXPERT to SKILL_LEVEL_MASTER) //They are worthy enough, but can it go even further beyond?
			user.visible_message("<span class='suicide'>[user] is putting \the [src] in [user.p_their()] mouth and has skillfully become one with the janicart! It looks like [user.p_theyre()] trying to commit suicide!</span>")
			user.AddElement(/datum/element/cleaning)
			for(var/i in 1 to 100)
				addtimer(CALLBACK(user, /atom/proc/add_atom_colour, (i % 2)? "#a245bb" : "#7a7d82", ADMIN_COLOUR_PRIORITY), i)
			addtimer(CALLBACK(src, .proc/manual_suicide, user), 101)
			return MANUAL_SUICIDE
		if(SKILL_LEVEL_LEGENDARY to INFINITY) //Holy shit, look at that janny go!
			user.visible_message("<span class='suicide'>[user] is putting \the [src] in [user.p_their()] mouth and has epically become one with the janicart, and they're even in overdrive mode! It looks like [user.p_theyre()] trying to commit suicide!</span>")
			user.AddElement(/datum/element/cleaning)
			playsound(src, 'sound//magic/lightning_chargeup.ogg', 50, TRUE, -1)
			user.reagents.add_reagent(/datum/reagent/drug/methamphetamine, 10) //Gotta go fast!
			for(var/i in 1 to 150)
				addtimer(CALLBACK(user, /atom/proc/add_atom_colour, (i % 2)? "#a245bb" : "#7a7d82", ADMIN_COLOUR_PRIORITY), i)
			addtimer(CALLBACK(src, .proc/manual_suicide, user), 151)
			return MANUAL_SUICIDE

/obj/item/key/proc/manual_suicide(mob/living/user)
	if(user)
		user.remove_atom_colour(ADMIN_COLOUR_PRIORITY)
		user.visible_message("<span class='suicide'>[user] forgot [user.p_they()] isn't actually a janicart! That's a paddlin'!</span>")
		if(user.mind?.get_skill_level(/datum/skill/cleaning) >= SKILL_LEVEL_LEGENDARY) //Janny janny janny janny janny
			playsound(src, 'sound/effects/adminhelp.ogg', 50, TRUE, -1)
		user.adjustOxyLoss(200)
		user.death(0)

/obj/item/key/lasso
	name = "bone lasso"
	desc = "Perfect for taming all kinds of supernatural beasts! (Warning: only perfect for taming one kind of supernatural beast.)"
	force = 12
	icon_state = "lasso"
	inhand_icon_state = "chain"
	worn_icon_state = "whip"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	attack_verb_continuous = list("flogs", "whips", "lashes", "disciplines")
	attack_verb_simple = list("flog", "whip", "lash", "discipline")
	hitsound = 'sound/weapons/whip.ogg'
	slot_flags = ITEM_SLOT_BELT
