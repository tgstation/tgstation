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
	dat += "<A href='?src=\ref[src];rune=teleport'>Sas'so c'arta forbici!</A> - Allows you to move to a Rite of Dislocation with the keyword of \"veri\".<BR>"
	dat += "<A href='?src=\ref[src];rune=emp'>Ta'gh fara'qha fel d'amar det!</A> - Allows you to destroy technology in a short range.<BR>"
	dat += "<A href='?src=\ref[src];rune=conceal'>Kla'atu barada nikt'o!</A> - Allows you to conceal nearby runes, or reveal previously concealed runes.<BR>"
	dat += "<A href='?src=\ref[src];rune=flame'>Dedo va'batoh!</A> - Allows you to set nearby non-believers on fire.<BR>"
	dat += "<A href='?src=\ref[src];rune=sacrune'>Barhah hra zar'garis!</A> - A sacrifice rune appears under your feet, ready to be invoked in the name of Nar-sie.<BR>"
	dat += "<A href='?src=\ref[src];rune=soulstone'>Kal'om neth!</A> - Summons a soul stone, used to capure the spirits of dead or dying humans.<BR>"
	dat += "<A href='?src=\ref[src];rune=construct'>Daa'ig osk!</A> - Summons a construct shell for use with captured souls. It is too large to carry on your person.<BR>"
	var/datum/browser/popup = new(user, "talisman", "", 400, 400)
	popup.set_content(dat)
	popup.open()
	uses++ //To prevent uses being consumed just by opening it
	return 1

/obj/item/weapon/paper/talisman/supply/Topic(href, href_list)
	if(!src || usr.stat || usr.restrained() || !in_range(src, usr))
		return
	if(href_list["rune"])
		switch(href_list["rune"])
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
			if("flame")
				var/obj/item/weapon/paper/talisman/flame/T = new(usr)
				usr.put_in_hands(T)
			if("sacrune")
				new /obj/effect/rune/sacrifice(get_turf(usr))
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
		user.buckled.unbuckle_mob()
	user.loc = get_turf(chosen_rune)

/obj/item/weapon/paper/talisman/teleport/New()
	..()
	spawn(1) //To give the keyword time to change from the imbue rune
		info += keyword

/obj/item/weapon/paper/talisman/teleport/examine(mob/user)
	..()
	if(iscultist(user) && keyword)
		user << "<b>Keyword:</b> [keyword]"


//Talisman of Obscurity: Same as rune
/obj/item/weapon/paper/talisman/hide_runes
	cultist_name = "Talisman of Veiling"
	cultist_desc = "A talisman that will make all runes within a small radius invisible, or make invisible runes visible again."
	invocation = "Kla'atu barada nikt'o!"
	health_cost = 1

/obj/item/weapon/paper/talisman/hide_runes/invoke(mob/living/user)
	user.visible_message("<span class='warning'>Dust flows from [user]'s hand.</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman, veiling nearby runes.</span>")
	for(var/obj/effect/rune/R in orange(3,src))
		if(R.invisibility == INVISIBILITY_OBSERVER)
			R.invisibility = 0
			R.alpha = initial(R.alpha)
		else
			R.visible_message("<span class='danger'>[R] fades away.</span>")
			R.invisibility = INVISIBILITY_OBSERVER
			R.alpha = 100 //To help ghosts distinguish hidden runes


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


//Rite of the Cleansing Flame: Same as rune
/obj/item/weapon/paper/talisman/flame
	cultist_name = "Talisman of Immolation"
	cultist_desc = "A talisman that sets any non-believers who can see you on fire."
	invocation = "Dedo va'batoh!"
	health_cost = 10

/obj/item/weapon/paper/talisman/flame/invoke(mob/living/user)
	user.visible_message("<span class='warning'>\The [src] in [user]'s hand suddenly burns away in a red flash!</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman, setting your enemies on fire.</span>")
	for(var/mob/living/carbon/C in viewers(user))
		if(!iscultist(C) && !C.null_rod_check())
			C << "<span class='cultlarge'>You feel your skin crisp as you burst into flames!</span>"
			C.fire_act()


//Rite of Arming: Equips cultist armor on the user, where available
/obj/item/weapon/paper/talisman/armor
	cultist_name = "Talisman of Arming"
	cultist_desc = "A talisman that will equip the invoker with cultist equipment if there is a slot to equip it to."
	invocation = "N'ath reth sh'yro eth draggathnor!"
	health_cost = 3

/obj/item/weapon/paper/talisman/armor/invoke(mob/living/user)
	user.visible_message("<span class='warning'>Otherworldly armor suddenly appears on [user]!</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman, arming yourself!</span>")
	user.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(user), slot_head)
	user.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(user), slot_wear_suit)
	user.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult/alt(user), slot_shoes)
	user.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/cultpack(user), slot_back)
	user.put_in_hands(new /obj/item/weapon/melee/cultblade(user))
