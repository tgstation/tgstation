/obj/item/weapon/storage/toolbox
	name = "toolbox"
	desc = "Danger. Very robust."
	icon_state = "red"
	item_state = "toolbox_red"
	flags = CONDUCT
	force = 12
	throwforce = 12
	throw_speed = 2
	throw_range = 7
	w_class = WEIGHT_CLASS_BULKY
	materials = list(MAT_METAL = 500)
	origin_tech = "combat=1;engineering=1"
	attack_verb = list("robusted")
	hitsound = 'sound/weapons/smash.ogg'

/obj/item/weapon/storage/toolbox/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] robusts [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/weapon/storage/toolbox/emergency
	name = "emergency toolbox"
	icon_state = "red"
	item_state = "toolbox_red"

/obj/item/weapon/storage/toolbox/emergency/New()
	..()
	new /obj/item/weapon/crowbar/red(src)
	new /obj/item/weapon/weldingtool/mini(src)
	new /obj/item/weapon/extinguisher/mini(src)
	if(prob(50))
		new /obj/item/device/flashlight(src)
	else
		new /obj/item/device/flashlight/flare(src)
	new /obj/item/device/radio/off(src)

/obj/item/weapon/storage/toolbox/mechanical
	name = "mechanical toolbox"
	icon_state = "blue"
	item_state = "toolbox_blue"

/obj/item/weapon/storage/toolbox/mechanical/New()
	..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/device/analyzer(src)
	new /obj/item/weapon/wirecutters(src)

/obj/item/weapon/storage/toolbox/electrical
	name = "electrical toolbox"
	icon_state = "yellow"
	item_state = "toolbox_yellow"

/obj/item/weapon/storage/toolbox/electrical/New()
	..()
	var/pickedcolor = pick("red","yellow","green","blue","pink","orange","cyan","white")
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/device/t_scanner(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/stack/cable_coil(src,30,pickedcolor)
	new /obj/item/stack/cable_coil(src,30,pickedcolor)
	if(prob(5))
		new /obj/item/clothing/gloves/color/yellow(src)
	else
		new /obj/item/stack/cable_coil(src,30,pickedcolor)

/obj/item/weapon/storage/toolbox/syndicate
	name = "suspicious looking toolbox"
	icon_state = "syndicate"
	item_state = "toolbox_syndi"
	origin_tech = "combat=2;syndicate=1;engineering=2"
	silent = 1
	force = 15
	throwforce = 18

/obj/item/weapon/storage/toolbox/syndicate/New()
	..()
	new /obj/item/weapon/screwdriver/nuke(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool/largetank(src)
	new /obj/item/weapon/crowbar/red(src)
	new /obj/item/weapon/wirecutters(src, "red")
	new /obj/item/device/multitool(src)
	new /obj/item/clothing/gloves/combat(src)

/obj/item/weapon/storage/toolbox/drone
	name = "mechanical toolbox"
	icon_state = "blue"
	item_state = "toolbox_blue"

/obj/item/weapon/storage/toolbox/drone/New()
	..()
	var/pickedcolor = pick("red","yellow","green","blue","pink","orange","cyan","white")
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/stack/cable_coil(src,30,pickedcolor)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/device/multitool(src)

/obj/item/weapon/storage/toolbox/brass
	name = "brass box"
	desc = "A huge brass box with several indentations in its surface."
	icon_state = "brassbox"
	w_class = WEIGHT_CLASS_HUGE
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 28
	storage_slots = 28
	slowdown = 1
	flags = HANDSLOW
	attack_verb = list("robusted", "crushed", "smashed")
	var/proselytizer_type = /obj/item/clockwork/clockwork_proselytizer/scarab

/obj/item/weapon/storage/toolbox/brass/prefilled/New()
	..()
	new proselytizer_type(src)
	new /obj/item/weapon/screwdriver/brass(src)
	new /obj/item/weapon/wirecutters/brass(src)
	new /obj/item/weapon/wrench/brass(src)
	new /obj/item/weapon/crowbar/brass(src)
	new /obj/item/weapon/weldingtool/experimental/brass(src)

/obj/item/weapon/storage/toolbox/brass/prefilled/ratvar
	var/slab_type = /obj/item/clockwork/slab/scarab

/obj/item/weapon/storage/toolbox/brass/prefilled/ratvar/New()
	..()
	new slab_type(src)

/obj/item/weapon/storage/toolbox/brass/prefilled/ratvar/admin
	slab_type = /obj/item/clockwork/slab/debug
	proselytizer_type = /obj/item/clockwork/clockwork_proselytizer/scarab/debug

#define HIS_GRACE_SATIATED 0 //He hungers not. If bloodthirst is set to this, His Grace is asleep.
#define HIS_GRACE_PECKISH 30 //Slightly hungry. Slightly increased damage and nothing else.
#define HIS_GRACE_HUNGRY 60 //Getting closer. Increased danage and slight healing. It also starts eating anyone around it if it's left on the ground.
#define HIS_GRACE_FAMISHED 90 //Dangerous. Highly increased damage, good healing, and stun resist. It also becomes nodrop at this point.
#define HIS_GRACE_STARVING 110 //Incredibly close to breaking loose. Extreme damage and healing, and stun immunity.
#define HIS_GRACE_CONSUME_OWNER 120 //You're dead, kiddo. The toolbox consumes its owner at this point and resets to zero.
#define HIS_GRACE_FALL_ASLEEP 150 //If it reaches this point, it falls asleep and resets to zero.

//His Grace is a very special weapon granted only to traitor chaplains.
//When awakened through sacrifice, it thirsts for blood and begins ticking a "bloodthirst" counter.
//As His Grace grows hungrier, it grants its wielder various benefits.
//If the wielder fails to feed His Grace in time, it will devour them.
//Leaving His Grace alone for some time will reset its timer and put it to sleep.
//Using His Grace effectively is a delicate balancing act of keeping it hungry enough to induce benefits but sated enough to let you live.
/obj/item/weapon/storage/toolbox/his_grace
	name = "artistic toolbox"
	desc = "A toolbox painted bright green. Looking at it makes you feel uneasy."
	icon_state = "green"
	item_state = "artistic_toolbox"
	w_class = 5
	origin_tech = "combat=4;engineering=4;syndicate=2"
	var/awakened = 0
	var/bloodthirst = HIS_GRACE_SATIATED
	var/victims = 0
	var/warning_messages = list("peckish", "hungry", "famished", "starving", "consume") //Messages that have NOT been shown

/obj/item/weapon/storage/toolbox/his_grace/Destroy()
	for(var/mob/living/L in src)
		L.forceMove(get_turf(src))
	return ..()

/obj/item/weapon/storage/toolbox/his_grace/attack_self(mob/living/user)
	if(!awakened)
		user << "<span class='notice'>[src] begins to vibrate...</span>"
		addtimer(CALLBACK(src, .proc/awaken), 50)

/obj/item/weapon/storage/toolbox/his_grace/attack(mob/living/M, mob/user)
	if(awakened && M.stat)
		consume(M)
	else
		..()

/obj/item/weapon/storage/toolbox/his_grace/examine(mob/user)
	..()
	if(awakened)
		if(victims.len)
			user << "You hear the distant murmuring of [victims.len] victims to [src]."
		switch(bloodthirst)
			if(HIS_GRACE_SATIATED to HIS_GRACE_PECKISH)
				user << "<span class='danger'>[src] isn't very hungry. Not yet.</span>"
			if(HIS_GRACE_PECKISH to HIS_GRACE_HUNGRY)
				user << "<span class='danger'>[src] would like a snack.</span>"
			if(HIS_GRACE_HUNGRY to HIS_GRACE_FAMISHED)
				user << "<span class='warning'>[src] is quite hungry now...</span>"
			if(HIS_GRACE_FAMISHED to HIS_GRACE_STARVING)
				user << "<span class='boldannounce'>[src] is openly salivating at the sight of you. Be careful.</span>"
			if(HIS_GRACE_STARVING to HIS_GRACE_CONSUME_OWNER)
				user << "<span class='boldwarning'>You walk a fine line. [src] is very close to devouring you.</span>"
			if(HIS_GRACE_CONSUME_OWNER to HIS_GRACE_FALL_ASLEEP)
				user << "<span class='boldwarning'>[src] is shaking violently and staring directly at you.</span>"

/obj/item/weapon/storage/toolbox/his_grace/relaymove(mob/living/user) //Allows changelings, etc. to climb out of the box after they revive
	user.forceMove(get_turf(src))
	user.visible_message("<span class='warning'>[user] scrambles out of [src]!</span>", "<span class='notice'>You climb out of [src]!</span>")

/obj/item/weapon/storage/toolbox/his_grace/process()
	if(!awakened)
		return
	adjust_bloodthirst(1 + victims) //Maybe adjust this?
	change_phases()
	if(ishuman(loc))
		var/mob/living/carbon/human/master = loc
		switch(bloodthirst) //Handles benefits outside of stun absorbs, which are in change_phases()
			if(HIS_GRACE_HUNGRY to HIS_GRACE_FAMISHED)
				master.adjustBruteLoss(-1)
				master.adjustFireLoss(-1)
				master.adjustToxLoss(-0.5)
				master.adjustOxyLoss(-5)
				master.adjustCloneLoss(-0.5)
			if(HIS_GRACE_FAMISHED to HIS_GRACE_STARVING)
				master.adjustBruteLoss(-2)
				master.adjustFireLoss(-2)
				master.adjustToxLoss(-1)
				master.adjustOxyLoss(-10)
				master.adjustCloneLoss(-1)
				master.AdjustStunned(-1)
				master.AdjustWeakened(-1)
			if(HIS_GRACE_STARVING to HIS_GRACE_CONSUME_OWNER)
				master.adjustBruteLoss(-20) //The biggest danger at this point is the toolbox itself
				master.adjustFireLoss(-20)
				master.adjustToxLoss(-10)
				master.setOxyLoss(0)
				master.adjustCloneLoss(-5)
				master.add_stun_absorption("his_grace", 15, 1, null, null, "[src] shields them from harm!")
			if(HIS_GRACE_CONSUME_OWNER to HIS_GRACE_FALL_ASLEEP)
				master.visible_message("<span class='boldwarning'>[src] turns on its master!</span>", "<span class='userdanger'>[src] turns on you!</span>")
				playsound(src, 'sound/effects/tendril_destroyed.ogg', 100, 0)
				master.Weaken(3)
				master.adjustBruteLoss(100)
				playsound(master, 'sound/misc/desceration-03.ogg', 100, )
				playsound(master, 'sound/effects/splat.ogg', 100, 0)
				master.emote("scream")
				consume(master) //Y O U   H A V E   F A I L E D   M E
			if(HIS_GRACE_FALL_ASLEEP to INFINITY)
				drowse()
	else
		if(bloodthirst >= HIS_GRACE_CONSUME_OWNER)
			if(bloodthirst >= HIS_GRACE_FALL_ASLEEP)
				drowse()
				return
			for(var/mob/living/L in range(1, src))
				if(L.loc == src)
					continue
				if(!L.stat)
					L.visible_message("<span class='warning'>[src] lunges at [L]!</span>", "<span class='userdanger'>[src] lunges at you!</span>")
					playsound(L, 'sound/effects/splat.ogg', 50, 1)
					playsound(L, 'sound/misc/desceration-01.ogg', 50, 1)
					L.adjustBruteLoss(force)
					return //Only one at a tome
				else
					consume(L)
					return

/obj/item/weapon/storage/toolbox/his_grace/proc/awaken() //Attempts to awaken. This can only occur if organs fill the box, and gives out a global warning.
	if(awakened)
		return
	var/organ_count = 0
	for(var/obj/item/organ/O in src) //Doesn't have to be any kind, we're not picky
		organ_count++
	if(organ_count < 5)
		if(isliving(loc))
			loc = get_turf(src)
		visible_message("<span class='warning'>[src] stops shaking. It needs more organs.</span>")
	else
		for(var/obj/item/organ/O in src)
			qdel(O) //delicious flesh
		name = "His Grace"
		desc = "A bloodthirsty artefact created by a profane rite."
		gender = MALE
		visible_message("<span class='boldwarning'>[src] begins to rattle. It thirsts.</span>") //rattle me bones capn
		adjust_bloodthirst(1)
		awakened = 1
		send_to_playing_players("<span class='boldannounce'><font size=6>HIS GRACE THIRSTS FOR BLOOD</font></span>")
		send_to_playing_players('sound/effects/his_grace_awaken.ogg')
		icon_state = "green_awakened"
		START_PROCESSING(SSprocessing, src)

/obj/item/weapon/storage/toolbox/his_grace/proc/drowse() //Falls asleep, spitting out all victims and resetting to zero.
	if(!awakened)
		return
	visible_message("<span class='boldwarning'>[src] slowly stops rattling and falls still... but it still lurks in its sleep.</span>")
	name = initial(name)
	desc = initial(desc)
	icon_state = initial(icon_state)
	gender = initial(gender)
	awakened = 0
	victims = 0
	warning_messages = initial(warning_messages)
	adjust_bloodthirst(-bloodthirst)
	STOP_PROCESSING(SSprocessing, src)
	send_to_playing_players("<span class='boldannounce'><font size=6>HIS GRACE HAS RETURNED TO SLUMBER</font></span>")
	send_to_playing_players('sound/effects/pope_entry.ogg')
	for(var/mob/living/L in src)
		L.forceMove(get_turf(src))

/obj/item/weapon/storage/toolbox/his_grace/proc/adjust_bloodthirst(amt)
	bloodthirst = min(max(1, bloodthirst + amt), HIS_GRACE_FALL_ASLEEP)

/obj/item/weapon/storage/toolbox/his_grace/proc/consume(mob/living/meal)
	if(!meal)
		return
	meal.adjustBruteLoss(200)
	meal.visible_message("<span class='warning'>[src] pulls [meal] into itself!</span>", "<span class='userdanger'>[src] consumes you!</span>")
	playsound(meal, 'sound/misc/desceration-02.ogg', 75, 1)
	playsound(src, 'sound/items/eatfood.ogg', 100, 1)
	meal.forceMove(src)
	adjust_bloodthirst(-(bloodthirst - victims)) //Never fully sated, and it starts off higher as it eats

/obj/item/weapon/storage/toolbox/his_grace/proc/change_phases()
	switch(bloodthirst)
		if(HIS_GRACE_SATIATED to HIS_GRACE_PECKISH)
			force = 15 //Constantly keep its power low if it's this full
		if(HIS_GRACE_PECKISH to HIS_GRACE_HUNGRY)
			if(is_string_in_list("peckish", warning_messages))
				remove_strings_from_list("peckish", warning_messages)
				loc.visible_message("<span class='warning'>[src] is feeling snackish.</span>", "<span class='danger'>[src] begins to hunger. Its damage has been increased.</span>")
				force = 20
				spawn(400) //To prevent spam
					if(src)
						warning_messages += "peckish"
		if(HIS_GRACE_HUNGRY to HIS_GRACE_FAMISHED)
			if(is_string_in_list("hungry", warning_messages))
				remove_strings_from_list("hungry", warning_messages)
				loc.visible_message("<span class='warning'>[src] is getting hungry. Its power grows.</span>", "<span class='boldannounce'>You feel a sense of hunger come over you. [src]'s damage has increased.</span>")
				force = 25
				spawn(400)
					if(src)
						warning_messages += "hungry"
		if(HIS_GRACE_FAMISHED to HIS_GRACE_STARVING)
			if(is_string_in_list("famished", warning_messages))
				remove_strings_from_list("famished", warning_messages)
				loc.visible_message("<span class='warning'>[src] is very hungry...</span>", "<span class='boldwarning'>Bloodlust overcomes you. You are now resistant to stuns.</span>")
				force = 30
				spawn(400)
					if(src)
						warning_messages += "famished"
		if(HIS_GRACE_STARVING to HIS_GRACE_CONSUME_OWNER)
			if(is_string_in_list("starving", warning_messages))
				remove_strings_from_list("starving", warning_messages)
				loc.visible_message("<span class='boldwarning'>[src] is starving!</span>", "<span class='userdanger'>[src] is at its full power! Feed it quickly or you will be consumed!</span>")
				force = 40
				spawn(400)
					if(src)
						warning_messages += "starving"
