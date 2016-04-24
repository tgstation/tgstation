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
	if(invocation)
		user.whisper(invocation)
	src.invoke(user)
	uses--
	if(uses <= 0)
		user.drop_item()
		qdel(src)

/obj/item/weapon/paper/talisman/proc/invoke(mob/living/user)
	if(health_cost && iscarbon(user))
		var/mob/living/carbon/C = user
		C.apply_damage(health_cost, BRUTE, pick("l_arm", "r_arm"))

//Malformed Talisman: If something goes wrong.
/obj/item/weapon/paper/talisman/malformed
	cultist_name = "malformed talisman"
	cultist_desc = "A talisman with gibberish scrawlings. No good can come from invoking this."
	invocation = "Ra'sha yoka!"

/obj/item/weapon/paper/talisman/malformed/invoke(mob/living/user)
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

/obj/item/weapon/paper/talisman/supply/invoke(mob/living/user)
	var/dat = "<B>There are [uses] bloody runes on the parchment.</B><BR>"
	dat += "Please choose the chant to be imbued into the fabric of reality.<BR>"
	dat += "<HR>"
	dat += "<A href='?src=\ref[src];rune=newtome'>N'ath reth sh'yro eth d'raggathnor!</A> - Allows you to summon an arcane tome.<BR>"
	dat += "<A href='?src=\ref[src];rune=teleport'>Sas'so c'arta forbici!</A> - Allows you to move to a Rite of Dislocation with the keyword of \"veri\".<BR>"
	dat += "<A href='?src=\ref[src];rune=emp'>Ta'gh fara'qha fel d'amar det!</A> - Allows you to destroy technology in a short range.<BR>"
	dat += "<A href='?src=\ref[src];rune=conceal'>Kla'atu barada nikt'o!</A> - Allows you to conceal nearby runes.<BR>"
	dat += "<A href='?src=\ref[src];rune=reveal'>Nikt'o barada kla'atu!</A> - Allows you to reveal nearby runes.<BR>"
	dat += "<A href='?src=\ref[src];rune=runestun'>Fuu ma'jin!</A> - Allows you to stun a person by attacking them with the talisman.<BR>"
	dat += "<A href='?src=\ref[src];rune=soulstone'>Kal'om neth!</A> - Summons a soul stone, used to capure the spirits of dead or dying humans.<BR>"
	dat += "<A href='?src=\ref[src];rune=construct'>Daa'ig osk!</A> - Summons a construct shell for use with captured souls. It is too large to carry on your person.<BR>"
	var/datum/browser/popup = new(user, "talisman", "", 400, 400)
	popup.set_content(dat)
	popup.open()
	uses++ //To prevent uses being consumed just by opening it
	return 1

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
					T.keyword = "veri"
					usr.put_in_hands(T)
				if("emp")
					var/obj/item/weapon/paper/talisman/emp/T = new(usr)
					usr.put_in_hands(T)
				if("conceal")
					var/obj/item/weapon/paper/talisman/hide_runes/T = new(usr)
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
	var/keyword = "ire"

/obj/item/weapon/paper/talisman/teleport/invoke(mob/living/user)
	var/list/possible_runes = list()
	for(var/obj/effect/rune/teleport/R in teleport_runes)
		if(R.keyword == src.keyword)
			possible_runes.Add(R)
	if(!possible_runes.len)
		user << "<span class='cultitalic'>There are no Teleport runes with the same keyword!</span>"
		log_game("Teleportation talisman failed - no teleport runes of the same keyword")
		uses++ //To prevent deletion
		return
	var/chosen_rune = pick(possible_runes)
	user.visible_message("<span class='warning'>Dust flows from [user]'s hand, and they disappear in a flash of red light!</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman and find yourself somewhere else!</span>")
	if(user.buckled)
		user.buckled.unbuckle_mob(user,force=1)
	user.loc = get_turf(chosen_rune)

/obj/item/weapon/paper/talisman/teleport/New()
	..()
	spawn(1) //To give the keyword time to change from the imbue rune
		info += keyword

/obj/item/weapon/paper/talisman/teleport/examine(mob/user)
	..()
	if(iscultist(user) && keyword)
		user << "<b>Keyword:</b> [keyword]"

//Rite of Knowledge: Same as rune, but has two uses
/obj/item/weapon/paper/talisman/summon_tome
	cultist_name = "Talisman of Tome Summoning"
	cultist_desc = "A one-use talisman that will call an untranslated tome from the archives of the Geometer."
	invocation = "N'ath reth sh'yro eth d'raggathnor!"
	health_cost = 1

/obj/item/weapon/paper/talisman/summon_tome/invoke(mob/living/user)
	user.visible_message("<span class='warning'>[user]'s hand glows red for a moment.</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman!</span>")
	var/obj/item/weapon/tome/T = new(get_turf(user))
	if(user.put_in_hands(T))
		user.visible_message("<span class='warning'>A tome appears in [user]'s hand!</span>", \
							 "<span class='cultitalic'>An arcane tome materializes in your free hand.</span>")
	else
		user.visible_message("<span class='warning'>A tome appears at [user]'s feet!</span>", \
							 "<span class='cultitalic'>An arcane tome materialzies at your feet.</span>")

//Talisman of Obscurity: Same as rune
/obj/item/weapon/paper/talisman/hide_runes
	cultist_name = "Talisman of Veiling"
	cultist_desc = "A talisman that will make all runes within a small radius invisible."
	invocation = "Kla'atu barada nikt'o!"
	health_cost = 1

/obj/item/weapon/paper/talisman/hide_runes/invoke(mob/living/user)
	user.visible_message("<span class='warning'>Dust flows from [user]'s hand.</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman, veiling nearby runes.</span>")
	for(var/obj/effect/rune/R in orange(3,user))
		R.visible_message("<span class='danger'>[R] fades away.</span>")
		R.invisibility = INVISIBILITY_OBSERVER

//Rite of True Sight: Same as rune, but doesn't work on ghosts
/obj/item/weapon/paper/talisman/true_sight
	cultist_name = "Talisman of Revealing"
	cultist_desc = "A talisman that reveals nearby invisible runes."
	invocation = "Nikt'o barada kla'atu!"
	health_cost = 1

/obj/item/weapon/paper/talisman/true_sight/invoke(mob/living/user)
	user.visible_message("<span class='warning'>A flash of light shines from [user]'s hand!</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman, revealing nearby runes.</span>")
	for(var/obj/effect/rune/R in orange(3,user))
		R.invisibility = 0


//Rite of False Truths: Same as rune
/obj/item/weapon/paper/talisman/make_runes_fake
	cultist_name = "Talisman of Disguising"
	cultist_desc = "A talisman that will make nearby runes appear fake."
	invocation = "By'o nar'nar!"
	health_cost = 3

/obj/item/weapon/paper/talisman/make_runes_fake/invoke(mob/living/user)
	user.visible_message("<span class='warning'>Dust flows from [user]s hand.</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman, making nearby runes appear fake.</span>")
	for(var/obj/effect/rune/R in orange(3,user))
		R.desc = "A rune drawn in crayon."

//Rite of Disruption: Same as rune
/obj/item/weapon/paper/talisman/emp
	cultist_name = "Talisman of Electromagnetic Pulse"
	cultist_desc = "A talisman that will cause a moderately-sized electromagnetic pulse."
	invocation = "Ta'gh fara'qha fel d'amar det!"
	health_cost = 5

/obj/item/weapon/paper/talisman/emp/invoke(mob/living/user)
	user.visible_message("<span class='warning'>[user]'s hand flashes a bright blue!</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman, emitting an EMP blast.</span>")
	empulse(src, 4, 8)

//Rite of Disorientation: Stuns and inhibit speech on a single target for quite some time
/obj/item/weapon/paper/talisman/stun
	cultist_name = "Talisman of Stunning"
	cultist_desc = "A talisman that will stun and inhibit speech on a single target. To use, attack target directly."
	invocation = "Fuu ma'jin!"
	health_cost = 15

//Rite of Arming: Equips cultist armor on the user, where available
/obj/item/weapon/paper/talisman/armor
	cultist_name = "Talisman of Arming"
	cultist_desc = "A talisman that will equip the invoker with cultist equipment if there is a slot to equip it to."
	invocation = "N'ath reth sh'yro eth draggathnor!"
	health_cost = 3

/obj/item/weapon/paper/talisman/stun/attack_self(mob/living/user)
	if(iscultist(user))
		user << "<span class='warning'>To use this talisman, attack the target directly.</span>"
	else
		user << "<span class='danger'>There are indecipherable images scrawled on the paper in what looks to be... <i>blood?</i></span>"

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

/obj/item/weapon/paper/talisman/armor/invoke(mob/living/user)
	user.visible_message("<span class='warning'>Otherworldly armor suddenly appears on [user]!</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman, arming yourself!</span>")
	user.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(user), slot_head)
	user.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(user), slot_wear_suit)
	user.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult/alt(user), slot_shoes)
	user.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/cultpack(user), slot_back)
	user.put_in_hands(new /obj/item/weapon/melee/cultblade(user))
