/*

Talismans are portable versions of runes that resemble blank sheets of paper. They may have different effects than their parent runes and are created by using a Rite of Binding with a paper on top and
a compatible rune somewhere nearby. A list of compatible runes can found below.

Basic Runes:
Rite of Translocation
Rite of Knowledge
Rite of Obscurity
Rite of True Sight
Rite of False Truths
Rite of Disruption
Rite of Disorientation

*/

/obj/item/weapon/paper/talisman
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
	if(src.invoke(user))
		uses--
	if(uses <= 0)
		user.drop_item()
		qdel(src)

/obj/item/weapon/paper/talisman/proc/invoke(mob/living/user)
	if(invocation)
		user.whisper(invocation)
	if(health_cost && iscarbon(user))
		var/mob/living/carbon/C = user
		C.apply_damage(health_cost, BRUTE, pick("l_arm", "r_arm"))
		return 1

//Malformed Talisman: If something goes wrong.
/obj/item/weapon/paper/talisman/malformed
	cultist_name = "malformed talisman"
	cultist_desc = "A talisman with gibberish scrawlings. No good can come from invoking this."
	invocation = "Ra'sha yoka!"
	health_cost = 10

/obj/item/weapon/paper/talisman/malformed/invoke(mob/living/user)
	. = ..()
	user << "<span class='cultitalic'>You feel a pain in your head. The Geometer is displeased.</span>"


//Supply Talisman: Has a few unique effects. Granted only to starter cultists.
/obj/item/weapon/paper/talisman/supply
	cultist_name = "Supply Talisman"
	cultist_desc = "A multi-use talisman that can create various objects. Intended to increase the cult's strength early on."
	invocation = null
	uses = 3

/obj/item/weapon/paper/talisman/supply/invoke(mob/living/user)
	var/dat = "<B>There are [uses] bloody runes on the parchment.</B><BR>"
	dat += "Please choose the chant to be imbued into the fabric of reality.<BR>"
	dat += "<HR>"
	dat += "<A href='?src=\ref[src];rune=newtome'>N'ath reth sh'yro eth d'raggathnor!</A> - Allows you to summon an arcane tome.<BR>"
	dat += "<A href='?src=\ref[src];rune=teleport'>Sas'so c'arta forbici!</A> - Allows you to move to a chosen Rite of Dislocation.<BR>"
	dat += "<A href='?src=\ref[src];rune=emp'>Ta'gh fara'qha fel d'amar det!</A> - Allows you to destroy technology in a short range.<BR>"
	dat += "<A href='?src=\ref[src];rune=reveal'>Kla'atu barada nikt'o!</A> - Allows you to reveal or hide nearby runes.<BR>"
	dat += "<A href='?src=\ref[src];rune=runestun'>Fuu ma'jin!</A> - Allows you to stun a person by attacking them with the talisman.<BR>"
	dat += "<A href='?src=\ref[src];rune=soulstone'>Kal'om neth!</A> - Summons a soul stone, used to capure the spirits of dead or dying humans.<BR>"
	dat += "<A href='?src=\ref[src];rune=construct'>Daa'ig osk!</A> - Summons a construct shell for use with captured souls. It is too large to carry on your person.<BR>"
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
					var/obj/item/weapon/paper/talisman/summon_tome/T = new(usr)
					usr.put_in_hands(T)
				if("teleport")
					var/obj/item/weapon/paper/talisman/teleport/T = new(usr)
					usr.put_in_hands(T)
				if("emp")
					var/obj/item/weapon/paper/talisman/emp/T = new(usr)
					usr.put_in_hands(T)
				if("reveal")
					var/obj/item/weapon/paper/talisman/true_sight/T = new(usr)
					usr.put_in_hands(T)
				if("runestun")
					var/obj/item/weapon/paper/talisman/stun/T = new(usr)
					usr.put_in_hands(T)
				if("soulstone")
					var/obj/item/device/soulstone/T = new(usr)
					usr.put_in_hands(T)
				if("construct")
					new /obj/structure/constructshell(get_turf(usr))
			src.uses--
			if(src.uses <= 0)
				if(iscarbon(usr))
					var/mob/living/carbon/C = usr
					C.drop_item()
					visible_message("<span class='warning'>[src] crumbles to dust.</span>")
				qdel(src)
		return
	else
		return

//Rite of Translocation: Same as rune
/obj/item/weapon/paper/talisman/teleport
	cultist_name = "Talisman of Teleportation"
	cultist_desc = "A single-use talisman that will teleport a user to a random rune of the same keyword."
	invocation = "Sas'so c'arta forbici!"
	health_cost = 5

/obj/item/weapon/paper/talisman/teleport/invoke(mob/living/user)
	..()
	var/list/potential_runes = list()
	for(var/R in teleport_runes)
		var/obj/effect/rune/teleport/T = teleport_runes[R]
		if(T.z <= ZLEVEL_SPACEMAX)
			potential_runes["[T.listkey]"] = T

	if(!potential_runes.len)
		user << "<span class='warning'>There are no valid runes to teleport to!</span>"
		log_game("Teleport talisman failed - no other teleport runes")
		return 0

	if(user.z > ZLEVEL_SPACEMAX)
		user << "<span class='cultitalic'>You are not in the right dimension!</span>"
		log_game("Teleport talisman failed - user in away mission")
		return 0

	var/input_rune_key = input(user, "Choose a rune to teleport to.", "Rune to Teleport to") as null|anything in potential_runes
	var/obj/effect/rune/teleport/actual_selected_rune = teleport_runes["[input_rune_key]"]
	if(!actual_selected_rune)
		return 0
	user.visible_message("<span class='warning'>Dust flows from [user]'s hand, and they disappear in a flash of red light!</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman and find yourself somewhere else!</span>")
	user.forceMove(get_turf(actual_selected_rune))
	return 1

//Rite of Knowledge: Same as rune, but has two uses
/obj/item/weapon/paper/talisman/summon_tome
	cultist_name = "Talisman of Tome Summoning"
	cultist_desc = "A one-use talisman that will call an untranslated tome from the archives of the Geometer."
	invocation = "N'ath reth sh'yro eth d'raggathnor!"
	health_cost = 1

/obj/item/weapon/paper/talisman/summon_tome/invoke(mob/living/user)
	. = ..()
	user.visible_message("<span class='warning'>[user]'s hand glows red for a moment.</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman!</span>")
	new /obj/item/weapon/tome(get_turf(user))
	user.visible_message("<span class='warning'>A tome appears at [user]'s feet!</span>", \
						 "<span class='cultitalic'>An arcane tome materialzies at your feet.</span>")

//Rite of True Sight: Same as rune, but doesn't work on ghosts
/obj/item/weapon/paper/talisman/true_sight
	cultist_name = "Talisman of Veiling"
	cultist_desc = "A talisman that hides nearby runes. On its second use, will reveal nearby runes."
	invocation = "Kla'atu barada nikt'o!"
	health_cost = 1
	uses = 2
	var/revealing = FALSE //if it reveals or not

/obj/item/weapon/paper/talisman/true_sight/invoke(mob/living/user)
	. = ..()
	if(!revealing)
		user.visible_message("<span class='warning'>Thin grey dust falls from [user]'s hand!</span>", \
			"<span class='cultitalic'>You speak the words of the talisman, hiding nearby runes.</span>")
		cultist_name = "Talisman of Revealing"
		cultist_desc = "A talisman that reveals nearby runes."
		invocation = "Nikt'o barada kla'atu!"
		revealing = TRUE
		for(var/obj/effect/rune/R in range(3,user))
			R.visible_message("<span class='danger'>[R] fades away.</span>")
			R.invisibility = INVISIBILITY_OBSERVER
			R.alpha = 100 //To help ghosts distinguish hidden runes
	else
		user.visible_message("<span class='warning'>A flash of light shines from [user]'s hand!</span>", \
			 "<span class='cultitalic'>You speak the words of the talisman, revealing nearby runes.</span>")
		for(var/obj/effect/rune/R in range(3,user))
			R.invisibility = 0
			R.visible_message("<span class='danger'>[R] suddenly appears!</span>")
			R.alpha = initial(R.alpha)

//Rite of Disruption: Same as rune
/obj/item/weapon/paper/talisman/emp
	cultist_name = "Talisman of Electromagnetic Pulse"
	cultist_desc = "A talisman that will cause a moderately-sized electromagnetic pulse."
	invocation = "Ta'gh fara'qha fel d'amar det!"
	health_cost = 5

/obj/item/weapon/paper/talisman/emp/invoke(mob/living/user)
	. = ..()
	user.visible_message("<span class='warning'>[user]'s hand flashes a bright blue!</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman, emitting an EMP blast.</span>")
	empulse(src, 3, 7)

//Rite of Arming: Equips cultist armor on the user, where available
/obj/item/weapon/paper/talisman/armor
	cultist_name = "Talisman of Arming"
	cultist_desc = "A talisman that will equip the invoker with cultist equipment if there is a slot to equip it to."
	invocation = "N'ath reth sh'yro eth draggathnor!"
	health_cost = 3

/obj/item/weapon/paper/talisman/armor/invoke(mob/living/user)
	. = ..()
	user.visible_message("<span class='warning'>Otherworldly armor suddenly appears on [user]!</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman, arming yourself!</span>")
	user.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(user), slot_head)
	user.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(user), slot_wear_suit)
	user.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult/alt(user), slot_shoes)
	user.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/cultpack(user), slot_back)
	user.drop_item()
	user.put_in_hands(new /obj/item/weapon/melee/cultblade(user))

/obj/item/weapon/paper/talisman/armor/attack(mob/living/target, mob/living/user)
	if(iscultist(user) && iscultist(target))
		user.drop_item()
		invoke(target)
		qdel(src)
		return
	..()

//Rite of Disorientation: Stuns and inhibit speech on a single target for quite some time
/obj/item/weapon/paper/talisman/stun
	cultist_name = "Talisman of Stunning"
	cultist_desc = "A talisman that will stun and inhibit speech on a single target. To use, attack target directly."
	invocation = "Fuu ma'jin!"
	health_cost = 15

/obj/item/weapon/paper/talisman/stun/invoke(mob/living/user)
	if(iscultist(user))
		user << "<span class='warning'>To use this talisman, attack the target directly.</span>"
	else
		user << "<span class='danger'>There are indecipherable images scrawled on the paper in what looks to be... <i>blood?</i></span>"
	return 0

/obj/item/weapon/paper/talisman/stun/attack(mob/living/target, mob/living/user)
	if(iscultist(user))
		user.whisper(invocation)
		user.visible_message("<span class='warning'>[user] holds up [src], which explodes in a flash of red light!</span>", \
							 "<span class='cultitalic'>You stun [target] with the talisman!</span>")
		var/obj/item/weapon/nullrod/N = locate() in target
		if(N)
			target.visible_message("<span class='warning'>[target]'s holy weapon absorbs the talisman's light!</span>", \
								   "<span class='userdanger'>Your holy weapon absorbs the blinding light!</span>")
		else
			target.Weaken(9)
			target.Stun(9)
			target.flash_eyes(1,1)
			if(issilicon(target))
				var/mob/living/silicon/S = target
				S.emp_act(1)
			if(iscarbon(target))
				var/mob/living/carbon/C = target
				C.silent += 4
				C.stuttering += 15
				C.cultslurring += 15
				C.Jitter(15)
		user.drop_item()
		qdel(src)
		return
	..()
