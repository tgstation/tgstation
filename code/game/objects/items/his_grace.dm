//His Grace is a very special weapon granted only to traitor chaplains.
//When awakened, He thirsts for blood and begins ticking a "bloodthirst" counter.
//The wielder of His Grace is immune to stuns and gradually heals.
//If the wielder fails to feed His Grace in time, He will devour them and become incredibly aggressive.
//Leaving His Grace alone for some time will reset His thirst and put Him to sleep.
//Using His Grace effectively requires extreme speed and care.
/obj/item/his_grace
	name = "artistic toolbox"
	desc = "A toolbox painted bright green. Looking at it makes you feel uneasy."
	icon_state = "his_grace"
	item_state = "artistic_toolbox"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	icon = 'icons/obj/items_and_weapons.dmi'
	w_class = WEIGHT_CLASS_GIGANTIC
	origin_tech = "combat=4;engineering=4;syndicate=2"
	force = 12
	attack_verb = list("robusted")
	hitsound = 'sound/weapons/smash.ogg'
	var/awakened = FALSE
	var/bloodthirst = HIS_GRACE_SATIATED
	var/prev_bloodthirst = HIS_GRACE_SATIATED
	var/force_bonus = 0

/obj/item/his_grace/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)
	GLOB.poi_list += src

/obj/item/his_grace/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	GLOB.poi_list -= src
	for(var/mob/living/L in src)
		L.forceMove(get_turf(src))
	return ..()

/obj/item/his_grace/attack_self(mob/living/user)
	if(!awakened)
		INVOKE_ASYNC(src, .proc/awaken, user)

/obj/item/his_grace/attack(mob/living/M, mob/user)
	if(awakened && M.stat)
		consume(M)
	else
		..()

/obj/item/his_grace/CtrlClick(mob/user) //you can't pull his grace
	return

/obj/item/his_grace/examine(mob/user)
	..()
	if(awakened)
		switch(bloodthirst)
			if(HIS_GRACE_SATIATED to HIS_GRACE_PECKISH)
				to_chat(user, "<span class='his_grace'>[src] isn't very hungry. Not yet.</span>")
			if(HIS_GRACE_PECKISH to HIS_GRACE_HUNGRY)
				to_chat(user, "<span class='his_grace'>[src] would like a snack.</span>")
			if(HIS_GRACE_HUNGRY to HIS_GRACE_FAMISHED)
				to_chat(user, "<span class='his_grace'>[src] is quite hungry now.</span>")
			if(HIS_GRACE_FAMISHED to HIS_GRACE_STARVING)
				to_chat(user, "<span class='his_grace'>[src] is openly salivating at the sight of you. Be careful.</span>")
			if(HIS_GRACE_STARVING to HIS_GRACE_CONSUME_OWNER)
				to_chat(user, "<span class='his_grace bold'>You walk a fine line. [src] is very close to devouring you.</span>")
			if(HIS_GRACE_CONSUME_OWNER to HIS_GRACE_FALL_ASLEEP)
				to_chat(user, "<span class='his_grace bold'>[src] is shaking violently and staring directly at you.</span>")
	else
		to_chat(user, "<span class='his_grace'>[src] is latched closed.</span>")

/obj/item/his_grace/relaymove(mob/living/user) //Allows changelings, etc. to climb out of Him after they revive, provided He isn't active
	if(!awakened)
		user.forceMove(get_turf(src))
		user.visible_message("<span class='warning'>[user] scrambles out of [src]!</span>", "<span class='notice'>You climb out of [src]!</span>")

/obj/item/his_grace/process()
	if(!bloodthirst)
		drowse()
		return
	if(bloodthirst < HIS_GRACE_CONSUME_OWNER)
		adjust_bloodthirst(1 + Floor(LAZYLEN(contents) * 0.5)) //Maybe adjust this?
	else
		adjust_bloodthirst(1) //don't cool off rapidly once we're at the point where His Grace consumes all.
	var/mob/living/master = get_atom_on_turf(src, /mob/living)
	if(istype(master) && (src in master.held_items))
		switch(bloodthirst)
			if(HIS_GRACE_CONSUME_OWNER to HIS_GRACE_FALL_ASLEEP)
				master.visible_message("<span class='boldwarning'>[src] turns on [master]!</span>", "<span class='his_grace big bold'>[src] turns on you!</span>")
				do_attack_animation(master, null, src)
				master.emote("scream")
				master.remove_status_effect(STATUS_EFFECT_HISGRACE)
				flags_1 &= ~NODROP_1
				master.Knockdown(60)
				master.adjustBruteLoss(master.maxHealth)
				playsound(master, 'sound/effects/splat.ogg', 100, 0)
			else
				master.apply_status_effect(STATUS_EFFECT_HISGRACE)
		return
	forceMove(get_turf(src)) //no you can't put His Grace in a locker you just have to deal with Him
	if(bloodthirst < HIS_GRACE_CONSUME_OWNER)
		return
	if(bloodthirst >= HIS_GRACE_FALL_ASLEEP)
		drowse()
		return
	var/list/targets = list()
	for(var/mob/living/L in oview(2, src))
		targets += L
	if(!LAZYLEN(targets))
		return
	var/mob/living/L = pick(targets)
	step_to(src, L)
	if(Adjacent(L))
		if(!L.stat)
			L.visible_message("<span class='warning'>[src] lunges at [L]!</span>", "<span class='his_grace big bold'>[src] lunges at you!</span>")
			do_attack_animation(L, null, src)
			playsound(L, 'sound/weapons/smash.ogg', 50, 1)
			playsound(L, 'sound/misc/desceration-01.ogg', 50, 1)
			L.adjustBruteLoss(force)
			adjust_bloodthirst(-5) //Don't stop attacking they're right there!
		else
			consume(L)

/obj/item/his_grace/proc/awaken(mob/user) //Good morning, Mr. Grace.
	if(awakened)
		return
	awakened = TRUE
	user.visible_message("<span class='boldwarning'>[src] begins to rattle. He thirsts.</span>", "<span class='his_grace'>You flick [src]'s latch up. You hope this is a good idea.</span>")
	name = "His Grace"
	desc = "A bloodthirsty artifact created by a profane rite."
	gender = MALE
	adjust_bloodthirst(1)
	force_bonus = HIS_GRACE_FORCE_BONUS * LAZYLEN(contents)
	playsound(user, 'sound/effects/pope_entry.ogg', 100)
	icon_state = "his_grace_awakened"

/obj/item/his_grace/proc/drowse() //Good night, Mr. Grace.
	if(!awakened)
		return
	var/turf/T = get_turf(src)
	T.visible_message("<span class='boldwarning'>[src] slowly stops rattling and falls still, His latch snapping closed.</span>")
	playsound(loc, 'sound/weapons/batonextend.ogg', 100, 1)
	name = initial(name)
	desc = initial(desc)
	icon_state = initial(icon_state)
	gender = initial(gender)
	force = initial(force)
	force_bonus = initial(force_bonus)
	awakened = FALSE
	bloodthirst = 0

/obj/item/his_grace/proc/consume(mob/living/meal) //Here's your dinner, Mr. Grace.
	if(!meal)
		return
	meal.visible_message("<span class='warning'>[src] swings open and devours [meal]!</span>", "<span class='his_grace big bold'>[src] consumes you!</span>")
	meal.adjustBruteLoss(200)
	playsound(meal, 'sound/misc/desceration-02.ogg', 75, 1)
	playsound(src, 'sound/items/eatfood.ogg', 100, 1)
	meal.forceMove(src)
	force_bonus += HIS_GRACE_FORCE_BONUS
	prev_bloodthirst = bloodthirst
	if(prev_bloodthirst < HIS_GRACE_CONSUME_OWNER)
		bloodthirst = max(LAZYLEN(contents), 1) //Never fully sated, and His hunger will only grow.
	else
		bloodthirst = HIS_GRACE_CONSUME_OWNER
	update_stats()

/obj/item/his_grace/proc/adjust_bloodthirst(amt)
	prev_bloodthirst = bloodthirst
	if(prev_bloodthirst < HIS_GRACE_CONSUME_OWNER)
		bloodthirst = Clamp(bloodthirst + amt, HIS_GRACE_SATIATED, HIS_GRACE_CONSUME_OWNER)
	else
		bloodthirst = Clamp(bloodthirst + amt, HIS_GRACE_CONSUME_OWNER, HIS_GRACE_FALL_ASLEEP)
	update_stats()

/obj/item/his_grace/proc/update_stats()
	flags_1 &= ~NODROP_1
	var/mob/living/master = get_atom_on_turf(src, /mob/living)
	switch(bloodthirst)
		if(HIS_GRACE_CONSUME_OWNER to HIS_GRACE_FALL_ASLEEP)
			if(HIS_GRACE_CONSUME_OWNER > prev_bloodthirst)
				master.visible_message("<span class='userdanger'>[src] enters a frenzy!</span>")
		if(HIS_GRACE_STARVING to HIS_GRACE_CONSUME_OWNER)
			flags_1 |= NODROP_1
			if(HIS_GRACE_STARVING > prev_bloodthirst)
				master.visible_message("<span class='boldwarning'>[src] is starving!</span>", "<span class='his_grace big'>[src]'s bloodlust overcomes you. [src] must be fed, or you will become His meal.\
				[force_bonus < 15 ? " And still, His power grows.":""]</span>")
				force_bonus = max(force_bonus, 15)
		if(HIS_GRACE_FAMISHED to HIS_GRACE_STARVING)
			flags_1 |= NODROP_1
			if(HIS_GRACE_FAMISHED > prev_bloodthirst)
				master.visible_message("<span class='warning'>[src] is very hungry!</span>", "<span class='his_grace big'>Spines sink into your hand. [src] must feed immediately.\
				[force_bonus < 10 ? " His power grows.":""]</span>")
				force_bonus = max(force_bonus, 10)
			if(prev_bloodthirst >= HIS_GRACE_STARVING)
				master.visible_message("<span class='warning'>[src] is now only very hungry!</span>", "<span class='his_grace big'>Your bloodlust recedes.</span>")
		if(HIS_GRACE_HUNGRY to HIS_GRACE_FAMISHED)
			if(HIS_GRACE_HUNGRY > prev_bloodthirst)
				master.visible_message("<span class='warning'>[src] is getting hungry.</span>", "<span class='his_grace big'>You feel [src]'s hunger within you.\
				[force_bonus < 5 ? " His power grows.":""]</span>")
				force_bonus = max(force_bonus, 5)
			if(prev_bloodthirst >= HIS_GRACE_FAMISHED)
				master.visible_message("<span class='warning'>[src] is now only somewhat hungry.</span>", "<span class='his_grace'>[src]'s hunger recedes a little...</span>")
		if(HIS_GRACE_PECKISH to HIS_GRACE_HUNGRY)
			if(HIS_GRACE_PECKISH > prev_bloodthirst)
				master.visible_message("<span class='warning'>[src] is feeling snackish.</span>", "<span class='his_grace'>[src] begins to hunger.</span>")
			if(prev_bloodthirst >= HIS_GRACE_HUNGRY)
				master.visible_message("<span class='warning'>[src] is now only a little peckish.</span>", "<span class='his_grace big'>[src]'s hunger recedes somewhat...</span>")
		if(HIS_GRACE_SATIATED to HIS_GRACE_PECKISH)
			if(prev_bloodthirst >= HIS_GRACE_PECKISH)
				master.visible_message("<span class='warning'>[src] is satiated.</span>", "<span class='his_grace big'>[src]'s hunger recedes...</span>")
	force = initial(force) + force_bonus
