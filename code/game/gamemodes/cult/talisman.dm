/obj/item/weapon/paper/talisman
<<<<<<< HEAD
	var/cultist_name = "talisman"
	var/cultist_desc = "A basic talisman. It serves no purpose."
	var/invocation = "Naise meam!"
	var/uses = 1
	var/health_cost = 0 //The amount of health taken from the user when invoking the talisman

/obj/item/weapon/paper/talisman/examine(mob/user)
	if(iscultist(user) || user.stat == DEAD)
		user << "<b>Name:</b> [cultist_name]"
		user << "<b>Effect:</b> [cultist_desc]"
		user << "<b>Uses Remaining:</b> [uses]"
	else
		user << "<span class='danger'>There are indecipherable images scrawled on the paper in what looks to be... <i>blood?</i></span>"

/obj/item/weapon/paper/talisman/attack_self(mob/living/user)
	if(!iscultist(user))
		user << "<span class='danger'>There are indecipherable images scrawled on the paper in what looks to be... <i>blood?</i></span>"
		return
	if(invoke(user))
		uses--
	if(uses <= 0)
		user.drop_item()
		qdel(src)

/obj/item/weapon/paper/talisman/proc/invoke(mob/living/user, successfuluse = 1)
	. = successfuluse
	if(successfuluse) //if the calling whatever says we succeed, do the fancy stuff
		if(invocation)
			user.whisper(invocation)
		if(health_cost && iscarbon(user))
			var/mob/living/carbon/C = user
			C.apply_damage(health_cost, BRUTE, pick("l_arm", "r_arm"))

//Malformed Talisman: If something goes wrong.
/obj/item/weapon/paper/talisman/malformed
	cultist_name = "malformed talisman"
	cultist_desc = "A talisman with gibberish scrawlings. No good can come from invoking this."
	invocation = "Ra'sha yoka!"

/obj/item/weapon/paper/talisman/malformed/invoke(mob/living/user, successfuluse = 1)
	user << "<span class='cultitalic'>You feel a pain in your head. The Geometer is displeased.</span>"
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.apply_damage(10, BRUTE, "head")

//Supply Talisman: Has a few unique effects. Granted only to starter cultists.
/obj/item/weapon/paper/talisman/supply
	cultist_name = "Supply Talisman"
	cultist_desc = "A multi-use talisman that can create various objects. Intended to increase the cult's strength early on."
	invocation = null
	uses = 3

/obj/item/weapon/paper/talisman/supply/invoke(mob/living/user, successfuluse = 1)
	var/dat = "<B>There are [uses] bloody runes on the parchment.</B><BR>"
	dat += "Please choose the chant to be imbued into the fabric of reality.<BR>"
	dat += "<HR>"
	dat += "<A href='?src=\ref[src];rune=newtome'>N'ath reth sh'yro eth d'raggathnor!</A> - Summons an arcane tome, used to scribe runes and communicate with other cultists.<BR>"
	dat += "<A href='?src=\ref[src];rune=teleport'>Sas'so c'arta forbici!</A> - Allows you to move to a selected teleportation rune.<BR>"
	dat += "<A href='?src=\ref[src];rune=emp'>Ta'gh fara'qha fel d'amar det!</A> - Allows you to destroy technology in a short range.<BR>"
	dat += "<A href='?src=\ref[src];rune=runestun'>Fuu ma'jin!</A> - Allows you to stun a person by attacking them with the talisman.<BR>"
	dat += "<A href='?src=\ref[src];rune=veiling'>Kla'atu barada nikt'o!</A> - Two use talisman, first use makes all nearby runes invisible, second use reveals nearby hidden runes.<BR>"
	dat += "<A href='?src=\ref[src];rune=soulstone'>Kal'om neth!</A> - Summons a soul stone, used to capure the spirits of dead or dying humans.<BR>"
	dat += "<A href='?src=\ref[src];rune=construct'>Daa'ig osk!</A> - Summons a construct shell for use with soulstone-captured souls. It is too large to carry on your person.<BR>"
	var/datum/browser/popup = new(user, "talisman", "", 400, 400)
	popup.set_content(dat)
	popup.open()
	return 0

/obj/item/weapon/paper/talisman/supply/Topic(href, href_list)
	if(src)
		if(usr.stat || usr.restrained() || !in_range(src, usr))
			return
		if(href_list["rune"])
			switch(href_list["rune"])
				if("newtome")
					var/obj/item/weapon/tome/T = new(usr)
					usr.put_in_hands(T)
				if("teleport")
					var/obj/item/weapon/paper/talisman/teleport/T = new(usr)
					usr.put_in_hands(T)
				if("emp")
					var/obj/item/weapon/paper/talisman/emp/T = new(usr)
					usr.put_in_hands(T)
				if("runestun")
					var/obj/item/weapon/paper/talisman/stun/T = new(usr)
					usr.put_in_hands(T)
				if("soulstone")
					var/obj/item/device/soulstone/T = new(usr)
					usr.put_in_hands(T)
				if("construct")
					new /obj/structure/constructshell(get_turf(usr))
				if("veiling")
					var/obj/item/weapon/paper/talisman/true_sight/T = new(usr)
					usr.put_in_hands(T)
			src.uses--
			if(src.uses <= 0)
				if(iscarbon(usr))
					var/mob/living/carbon/C = usr
					C.drop_item()
					visible_message("<span class='warning'>[src] crumbles to dust.</span>")
				qdel(src)

/obj/item/weapon/paper/talisman/supply/weak
	uses = 2

//Rite of Translocation: Same as rune
/obj/item/weapon/paper/talisman/teleport
	cultist_name = "Talisman of Teleportation"
	cultist_desc = "A single-use talisman that will teleport a user to a random rune of the same keyword."
	color = "#551A8B" // purple
	invocation = "Sas'so c'arta forbici!"
	health_cost = 5

/obj/item/weapon/paper/talisman/teleport/invoke(mob/living/user, successfuluse = 1)
	var/list/potential_runes = list()
	var/list/teleportnames = list()
	var/list/duplicaterunecount = list()
	for(var/R in teleport_runes)
		var/obj/effect/rune/teleport/T = R
		var/resultkey = T.listkey
		if(resultkey in teleportnames)
			duplicaterunecount[resultkey]++
			resultkey = "[resultkey] ([duplicaterunecount[resultkey]])"
		else
			teleportnames.Add(resultkey)
			duplicaterunecount[resultkey] = 1
		potential_runes[resultkey] = T

	if(!potential_runes.len)
		user << "<span class='warning'>There are no valid runes to teleport to!</span>"
		log_game("Teleport talisman failed - no other teleport runes")
		return ..(user, 0)

	if(user.z > ZLEVEL_SPACEMAX)
		user << "<span class='cultitalic'>You are not in the right dimension!</span>"
		log_game("Teleport talisman failed - user in away mission")
		return ..(user, 0)

	var/input_rune_key = input(user, "Choose a rune to teleport to.", "Rune to Teleport to") as null|anything in potential_runes //we know what key they picked
	var/obj/effect/rune/teleport/actual_selected_rune = potential_runes[input_rune_key] //what rune does that key correspond to?
	if(!actual_selected_rune)
		return ..(user, 0)
	user.visible_message("<span class='warning'>Dust flows from [user]'s hand, and they disappear in a flash of red light!</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman and find yourself somewhere else!</span>")
	user.forceMove(get_turf(actual_selected_rune))
	return ..()


/obj/item/weapon/paper/talisman/summon_tome
	cultist_name = "Talisman of Tome Summoning"
	cultist_desc = "A one-use talisman that will call an untranslated tome from the archives of the Geometer."
	color = "#512727" // red-black
	invocation = "N'ath reth sh'yro eth d'raggathnor!"
	health_cost = 1

/obj/item/weapon/paper/talisman/summon_tome/invoke(mob/living/user, successfuluse = 1)
	. = ..()
	user.visible_message("<span class='warning'>[user]'s hand glows red for a moment.</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman!</span>")
	new /obj/item/weapon/tome(get_turf(user))
	user.visible_message("<span class='warning'>A tome appears at [user]'s feet!</span>", \
			 "<span class='cultitalic'>An arcane tome materializes at your feet.</span>")

/obj/item/weapon/paper/talisman/true_sight
	cultist_name = "Talisman of Veiling"
	cultist_desc = "A multi-use talisman that hides nearby runes. On its second use, will reveal nearby runes."
	color = "#9c9c9c" // grey
	invocation = "Kla'atu barada nikt'o!"
	health_cost = 1
	uses = 2
	var/revealing = FALSE //if it reveals or not

/obj/item/weapon/paper/talisman/true_sight/invoke(mob/living/user, successfuluse = 1)
	. = ..()
	if(!revealing)
		user.visible_message("<span class='warning'>Thin grey dust falls from [user]'s hand!</span>", \
			"<span class='cultitalic'>You speak the words of the talisman, hiding nearby runes.</span>")
		invocation = "Nikt'o barada kla'atu!"
		revealing = TRUE
		for(var/obj/effect/rune/R in range(3,user))
			R.talismanhide()
	else
		user.visible_message("<span class='warning'>A flash of light shines from [user]'s hand!</span>", \
			 "<span class='cultitalic'>You speak the words of the talisman, revealing nearby runes.</span>")
		for(var/obj/effect/rune/R in range(3,user))
			R.talismanreveal()

//Rite of False Truths: Same as rune
/obj/item/weapon/paper/talisman/make_runes_fake
	cultist_name = "Talisman of Disguising"
	cultist_desc = "A talisman that will make nearby runes appear fake."
	color = "#ff80d5" // honk
	invocation = "By'o nar'nar!"

/obj/item/weapon/paper/talisman/make_runes_fake/invoke(mob/living/user, successfuluse = 1)
	. = ..()
	user.visible_message("<span class='warning'>Dust flows from [user]s hand.</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman, making nearby runes appear fake.</span>")
	for(var/obj/effect/rune/R in orange(6,user))
		R.desc = "A rune vandalizing the station."


//Rite of Disruption: Weaker than rune
/obj/item/weapon/paper/talisman/emp
	cultist_name = "Talisman of Electromagnetic Pulse"
	cultist_desc = "A talisman that will cause a moderately-sized electromagnetic pulse."
	color = "#4d94ff" // light blue
	invocation = "Ta'gh fara'qha fel d'amar det!"
	health_cost = 5

/obj/item/weapon/paper/talisman/emp/invoke(mob/living/user, successfuluse = 1)
	. = ..()
	user.visible_message("<span class='warning'>[user]'s hand flashes a bright blue!</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman, emitting an EMP blast.</span>")
	empulse(src, 4, 8)


//Rite of Disorientation: Stuns and inhibit speech on a single target for quite some time
/obj/item/weapon/paper/talisman/stun
	cultist_name = "Talisman of Stunning"
	cultist_desc = "A talisman that will stun and inhibit speech on a single target. To use, attack target directly."
	color = "#ff0000" // red
	invocation = "Fuu ma'jin!"
	health_cost = 10

/obj/item/weapon/paper/talisman/stun/invoke(mob/living/user, successfuluse = 0)
	if(successfuluse) //if we're forced to be successful(we normally aren't) then do the normal stuff
		return ..()
	if(iscultist(user))
		user << "<span class='warning'>To use this talisman, attack the target directly.</span>"
	else
		user << "<span class='danger'>There are indecipherable images scrawled on the paper in what looks to be... <i>blood?</i></span>"
	return 0

/obj/item/weapon/paper/talisman/stun/attack(mob/living/target, mob/living/user, successfuluse = 1)
	if(iscultist(user))
		invoke(user, 1)
		user.visible_message("<span class='warning'>[user] holds up [src], which explodes in a flash of red light!</span>", \
							 "<span class='cultitalic'>You stun [target] with the talisman!</span>")
		var/obj/item/weapon/nullrod/N = locate() in target
		if(N)
			target.visible_message("<span class='warning'>[target]'s holy weapon absorbs the talisman's light!</span>", \
								   "<span class='userdanger'>Your holy weapon absorbs the blinding light!</span>")
		else
			target.Weaken(10)
			target.Stun(10)
			target.flash_eyes(1,1)
			if(issilicon(target))
				var/mob/living/silicon/S = target
				S.emp_act(1)
			else if(iscarbon(target))
				var/mob/living/carbon/C = target
				C.silent += 5
				C.stuttering += 15
				C.cultslurring += 15
				C.Jitter(15)
			if(is_servant_of_ratvar(target))
				target.adjustBruteLoss(15)
		user.drop_item()
		qdel(src)
		return
	..()


//Rite of Arming: Equips cultist armor on the user, where available
/obj/item/weapon/paper/talisman/armor
	cultist_name = "Talisman of Arming"
	cultist_desc = "A talisman that will equip the invoker with cultist equipment if there is a slot to equip it to."
	color = "#33cc33" // green
	invocation = "N'ath reth sh'yro eth draggathnor!"

/obj/item/weapon/paper/talisman/armor/invoke(mob/living/user, successfuluse = 1)
	. = ..()
	user.visible_message("<span class='warning'>Otherworldly armor suddenly appears on [user]!</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman, arming yourself!</span>")
	user.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(user), slot_head)
	user.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(user), slot_wear_suit)
	user.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult/alt(user), slot_shoes)
	user.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/cultpack(user), slot_back)
	user.drop_item()
	user.put_in_hands(new /obj/item/weapon/melee/cultblade(user))
	user.put_in_hands(new /obj/item/weapon/restraints/legcuffs/bola/cult(user))

/obj/item/weapon/paper/talisman/armor/attack(mob/living/target, mob/living/user)
	if(iscultist(user) && iscultist(target))
		user.drop_item()
		invoke(target)
		qdel(src)
		return
	..()


//Talisman of Horrors: Breaks the mind of the victim with nightmarish hallucinations
/obj/item/weapon/paper/talisman/horror
	cultist_name = "Talisman of Horrors"
	cultist_desc = "A talisman that will break the mind of the victim with nightmarish hallucinations."
	color = "#ffb366" // light orange
	invocation = "Lo'Nab Na'Dm!"

/obj/item/weapon/paper/talisman/horror/attack(mob/living/target, mob/living/user)
	if(iscultist(user))
		user << "<span class='cultitalic'>You disturb [target] with visons of the end!</span>"
		if(iscarbon(target))
			var/mob/living/carbon/H = target
			H.reagents.add_reagent("mindbreaker", 25)
			if(is_servant_of_ratvar(target))
				target << "<span class='userdanger'>You see a brief but horrible vision of Ratvar, rusted and scrapped, being torn apart.</span>"
				target.emote("scream")
				target.confused = max(0, target.confused + 3)
				target.flash_eyes()
		qdel(src)


//Talisman of Fabrication: Creates a construct shell out of 25 metal sheets.
/obj/item/weapon/paper/talisman/construction
	cultist_name = "Talisman of Construction"
	cultist_desc = "Use this talisman on at least twenty-five metal sheets to create an empty construct shell"
	invocation = "Ethra p'ni dedol!"
	color = "#000000" // black

/obj/item/weapon/paper/talisman/construction/attack_self(mob/living/user)
	if(iscultist(user))
		user << "<span class='warning'>To use this talisman, place it upon a stack of metal sheets.</span>"
	else
		user << "<span class='danger'>There are indecipherable images scrawled on the paper in what looks to be... <i>blood?</i></span>"


/obj/item/weapon/paper/talisman/construction/attack(obj/M,mob/living/user)
	if(iscultist(user))
		user << "<span class='cultitalic'>This talisman will only work on a stack of metal sheets!</span>"
		log_game("Construct talisman failed - not a valid target")

/obj/item/weapon/paper/talisman/construction/afterattack(obj/item/stack/sheet/target, mob/user, proximity_flag, click_parameters)
	..()
	if(proximity_flag && iscultist(user))
		if(istype(target, /obj/item/stack/sheet/metal))
			var/turf/T = get_turf(target)
			if(target.use(25))
				new /obj/structure/constructshell(T)
				user << "<span class='warning'>The talisman clings to the metal and twists it into a construct shell!</span>"
				user << sound('sound/effects/magic.ogg',0,1,25)
				qdel(src)
		if(istype(target, /obj/item/stack/sheet/plasteel))
			var/quantity = target.amount
			var/turf/T = get_turf(target)
			new /obj/item/stack/sheet/runed_metal(T,quantity)
			target.use(quantity)
			user << "<span class='warning'>The talisman clings to the plasteel, transforming it into runed metal!</span>"
			user << sound('sound/effects/magic.ogg',0,1,25)
			qdel(src)
		else
			user << "<span class='warning'>The talisman must be used on metal or plasteel!</span>"


//Talisman of Shackling: Applies special cuffs directly from the talisman
/obj/item/weapon/paper/talisman/shackle
	cultist_name = "Talisman of Shackling"
	cultist_desc = "Use this talisman on a victim to handcuff them with dark bindings."
	invocation = "In'totum Lig'abis!"
	color = "#B27300" // burnt-orange
	uses = 4

/obj/item/weapon/paper/talisman/shackle/invoke(mob/living/user, successfuluse = 0)
	if(successfuluse) //if we're forced to be successful(we normally aren't) then do the normal stuff
		return ..()
	if(iscultist(user))
		user << "<span class='warning'>To use this talisman, attack the target directly.</span>"
	else
		user << "<span class='danger'>There are indecipherable images scrawled on the paper in what looks to be... <i>blood?</i></span>"
	return 0

/obj/item/weapon/paper/talisman/shackle/attack(mob/living/carbon/target, mob/living/user)
	if(iscultist(user) && istype(target))
		if(target.stat == DEAD)
			user.visible_message("<span class='cultitalic'>This talisman's magic does not affect the dead!</span>")
			return
		CuffAttack(target, user)
		return
	..()

/obj/item/weapon/paper/talisman/shackle/proc/CuffAttack(mob/living/carbon/C, mob/living/user)
	if(!C.handcuffed)
		invoke(user, 1)
		playsound(loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
		C.visible_message("<span class='danger'>[user] begins restraining [C] with dark magic!</span>", \
								"<span class='userdanger'>[user] begins shaping a dark magic around your wrists!</span>")
		if(do_mob(user, C, 30))
			if(!C.handcuffed)
				C.handcuffed = new /obj/item/weapon/restraints/handcuffs/energy/cult/used(C)
				C.update_handcuffed()
				user << "<span class='notice'>You shackle [C].</span>"
				add_logs(user, C, "handcuffed")
				uses--
			else
				user << "<span class='warning'>[C] is already bound.</span>"
		else
			user << "<span class='warning'>You fail to shackle [C].</span>"
	else
		user << "<span class='warning'>[C] is already bound.</span>"
	if(uses <= 0)
		user.drop_item()
		qdel(src)
	return

/obj/item/weapon/restraints/handcuffs/energy/cult //For the talisman of shackling
	name = "cult shackles"
	desc = "Shackles that bind the wrists with sinister magic."
	trashtype = /obj/item/weapon/restraints/handcuffs/energy/used
	origin_tech = "materials=2;magnets=5"
	flags = DROPDEL

/obj/item/weapon/restraints/handcuffs/energy/cult/used/dropped(mob/user)
	user.visible_message("<span class='danger'>[user]'s shackles shatter in a discharge of dark magic!</span>", \
							"<span class='userdanger'>Your [src] shatters in a discharge of dark magic!</span>")
	. = ..()
=======
	icon_state = "paper_talisman"
	var/imbue = null
	var/uses = 0
	var/nullblock = 0

/obj/item/weapon/paper/talisman/examine(mob/user)
	..()
	if(iscultist(user) || isobserver(user))
		switch(imbue)
			if("newtome")
				to_chat(user, "This talisman has been imbued with the power of spawning a new Arcane Tome.")
			if("armor")
				to_chat(user, "This talisman has been imbued with the power of clothing yourself in cult fighting gear.")
			if("emp")
				to_chat(user, "This talisman has been imbued with the power of disabling technology in a small radius around you.")
			if("conceal")
				to_chat(user, "This talisman has been imbued with the power of concealing nearby runes.")
			if("revealrunes")
				to_chat(user, "This talisman has been imbued with the power of revealing hidden nearby runes.")
			if("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri")
				to_chat(user, "This talisman has been imbued with the power of taking you to someplace else. You can read <i>[imbue]</i> on it.")
			if("communicate")
				to_chat(user, "This talisman has been imbued with the power of communicating your whispers to your allies.")
			if("deafen")
				to_chat(user, "This talisman has been imbued with the power of deafening visible enemies.")
			if("blind")
				to_chat(user, "This talisman has been imbued with the power of blinding visible enemies.")
			if("runestun")
				to_chat(user, "This talisman has been imbued with the power of paralyzing the beings you touch with it. The effect works on silicons as well, but humans will also be muted for a short time.")
			if("supply")
				to_chat(user, "This talisman has been imbued with the power of providing you and your allies with some supplies to start your cult.")
			else
				to_chat(user, "This talisman.....has no particular power. Is this some kind of joke?")
	else
		to_chat(user, "Something about the blood stains on this paper fills you with uneasiness.")

/obj/item/weapon/paper/talisman/proc/findNullRod(var/atom/target)
	if(istype(target,/obj/item/weapon/nullrod))
		var/turf/T = get_turf(target)
		nullblock = 1
		T.turf_animation('icons/effects/96x96.dmi',"nullding",-32,-32,MOB_LAYER+1,'sound/piano/Ab7.ogg',anim_plane = PLANE_EFFECTS)
		return 1
	else if(target.contents)
		for(var/atom/A in target.contents)
			findNullRod(A)
	return 0

/obj/item/weapon/paper/talisman/New()
	..()
	pixel_x=0
	pixel_y=0


/obj/item/weapon/paper/talisman/attack_self(mob/living/user as mob)
	if(iscultist(user))
		var/delete = 1
		switch(imbue)
			if("newtome")
				call(/obj/effect/rune/proc/tomesummon)()
			if("armor") //Fuck off with your shit /tg/. This isn't Edgy Rev+
				call(/obj/effect/rune/proc/armor)()
			if("emp")
				call(/obj/effect/rune/proc/emp)(usr.loc,3)
			if("conceal")
				call(/obj/effect/rune/proc/obscure)(2)
			if("revealrunes")
				call(/obj/effect/rune/proc/revealrunes)(src)
			if("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri")
				var/turf/T1 = get_turf(user)
				call(/obj/effect/rune/proc/teleport)(imbue)
				var/turf/T2 = get_turf(user)
				if(T1!=T2)
					T1.turf_animation('icons/effects/effects.dmi',"rune_teleport")
			if("communicate")
				//If the user cancels the talisman this var will be set to 0
				delete = call(/obj/effect/rune/proc/communicate)()
			if("deafen")
				deafen()
				qdel(src)
			if("blind")
				blind()
				qdel(src)
			if("runestun")
				to_chat(user, "<span class='warning'>To use this talisman, attack your target directly.</span>")
				return
			if("supply")
				supply()
		user.take_organ_damage(5, 0)
		if(src && src.imbue!="supply" && src.imbue!="runestun")
			if(delete)
				qdel(src)
		return
	else
		to_chat(user, "You see strange symbols on the paper. Are they supposed to mean something?")
		return


/obj/item/weapon/paper/talisman/attack(mob/living/carbon/T as mob, mob/living/user as mob)
	if(iscultist(user))
		if(imbue == "runestun")
			user.take_organ_damage(5, 0)
			runestun(T)
			qdel(src)
		else
			..()   ///If its some other talisman, use the generic attack code, is this supposed to work this way?
	else
		..()

/obj/item/weapon/paper/talisman/attack_animal(var/mob/living/simple_animal/M as mob)
	if(istype(M, /mob/living/simple_animal/construct/harvester))
		attack_self(M)

/obj/item/weapon/paper/talisman/proc/supply(var/key)
	if (!src.uses)
		qdel(src)
		return

	var/dat = {"<B>There are [src.uses] bloody runes on the parchment.</B>
<BR>Please choose the chant to be imbued into the fabric of reality.<BR>
<HR>
<A href='?src=\ref[src];rune=newtome'>N'ath reth sh'yro eth d'raggathnor!</A> - Allows you to summon a new arcane tome.<BR>
<A href='?src=\ref[src];rune=teleport'>Sas'so c'arta forbici!</A> - Allows you to move to a rune with the same last word.<BR>
<A href='?src=\ref[src];rune=emp'>Ta'gh fara'qha fel d'amar det!</A> - Allows you to destroy technology in a short range.<BR>
<A href='?src=\ref[src];rune=conceal'>Kla'atu barada nikt'o!</A> - Allows you to conceal the runes you placed on the floor.<BR>
<A href='?src=\ref[src];rune=communicate'>O bidai nabora se'sma!</A> - Allows you to coordinate with others of your cult.<BR>
<A href='?src=\ref[src];rune=runestun'>Fuu ma'jin</A> - Allows you to stun a person by attacking them with the talisman.<BR>
<A href='?src=\ref[src];rune=soulstone'>Kal om neth</A> - Summons a soul stone<BR>
<A href='?src=\ref[src];rune=construct'>Da A'ig Osk</A> - Summons a construct shell for use with captured souls. It is too large to carry on your person.<BR>"}
//<A href='?src=\ref[src];rune=armor'>Sa tatha najin</A> - Allows you to summon armoured robes and an unholy blade<BR> //Kept for reference
	usr << browse(dat, "window=id_com;size=350x200")
	return


/obj/item/weapon/paper/talisman/Topic(href, href_list)
	if(!src)	return
	if (usr.stat || usr.restrained() || !in_range(src, usr))	return

	if (href_list["rune"])
		switch(href_list["rune"])
			if("newtome")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.imbue = "newtome"
			if("teleport")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				var/list/words = list("ire" = "ire", "ego" = "ego", "nahlizet" = "nahlizet", "certum" = "certum", "veri" = "veri", "jatkaa" = "jatkaa", "balaq" = "balaq", "mgar" = "mgar", "karazet" = "karazet", "geeri" = "geeri")
				T.imbue = input("Write your teleport destination rune:", "Rune Scribing") in words
			if("emp")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.imbue = "emp"
			if("conceal")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.imbue = "conceal"
			if("communicate")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.imbue = "communicate"
			if("runestun")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.imbue = "runestun"
			//if("armor")
				//var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				//T.imbue = "armor"
			if("soulstone")
				new /obj/item/device/soulstone(get_turf(usr))
			if("construct")
				new /obj/structure/constructshell/cult(get_turf(usr))
		src.uses--
		supply()
	return


/obj/item/weapon/paper/talisman/supply
	imbue = "supply"
	uses = 5


//imbued talismans invocation for a few runes, since calling the proc causes a runtime error due to src = null
/obj/item/weapon/paper/talisman/proc/runestun(var/mob/living/T as mob)//When invoked as talisman, stun and mute the target mob.
	usr.say("Dream sign ''Evil sealing talisman'[pick("'","`")]!")
	nullblock = 0
	for(var/turf/TU in range(T,1))
		findNullRod(TU)
	if(nullblock)
		usr.visible_message("<span class='danger'>[usr] invokes a talisman at [T], but they are unaffected!</span>")
	else
		usr.visible_message("<span class='danger'>[usr] invokes a talisman at [T]</span>")

		if(issilicon(T))
			T.Weaken(15)

		else if(iscarbon(T))
			var/mob/living/carbon/C = T
			C.flash_eyes(visual = 1)
			if (!(M_HULK in C.mutations))
				C.silent += 15
			C.Weaken(25)
			C.Stun(25)
	return

/obj/item/weapon/paper/talisman/proc/blind()
	var/affected = 0
	for(var/mob/living/carbon/C in view(2,usr))
		if (iscultist(C))
			continue
		nullblock = 0
		for(var/turf/T in range(C,1))
			findNullRod(T)
		if(nullblock)
			continue
		C.eye_blurry += 30
		C.eye_blind += 10
		//talismans is weaker.
		affected++
		to_chat(C, "<span class='warning'>You feel a sharp pain in your eyes, and the world disappears into darkness..</span>")
	if(affected)
		usr.whisper("Sti[pick("'","`")] kaliesin!")
		to_chat(usr, "<span class='warning'>Your talisman turns into gray dust, blinding those who not follow the Nar-Sie.</span>")


/obj/item/weapon/paper/talisman/proc/deafen()
	var/affected = 0
	for(var/mob/living/carbon/C in range(7,usr))
		if (iscultist(C))
			continue
		nullblock = 0
		for(var/turf/T in range(C,1))
			findNullRod(T)
		if(nullblock)
			continue
		C.ear_deaf += 30
		//talismans is weaker.
		C.show_message("\<span class='warning'>The world around you suddenly becomes quiet.</span>")
		affected++
	if(affected)
		usr.whisper("Sti[pick("'","`")] kaliedir!")
		to_chat(usr, "<span class='warning'>Your talisman turns into gray dust, deafening everyone around.</span>")
		for (var/mob/V in orange(1,src))
			if(!(iscultist(V)))
				V.show_message("<span class='warning'>Dust flows from [usr]'s hands for a moment, and the world suddenly becomes quiet..</span>")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
