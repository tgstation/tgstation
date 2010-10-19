/datum/disease/wizarditis
	name = "Wizarditis"
	max_stages = 4
	spread = "Airborne"
	cure = "The Manly Dorf"
	cure_id = "manlydorf"
	agent = "Rincewindus Vulgaris"
	affected_species = list("Human")
	curable = 0
	permeability_mod = -5

/*
BIRUZ BENNAR
SCYAR NILA - teleport
NEC CANTIO - dis techno
EI NATH - shocking grasp
AULIE OXIN FIERA - knock
TARCOL MINTI ZHERI - forcewall
STI KALY - blind
*/

/datum/disease/wizarditis/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(4))
				affected_mob.say(pick("You shall not pass!", "Expeliarmus!", "By Merlins beard!", ""))
			if(prob(2))
				affected_mob << "\red You feel [pick("that you don't have enough mana.", "that the winds of magic are gone.", "an urge to summon familiar.")]"


		if(3)
			spawn_wizard_clothes(5)
			if(prob(4))
				affected_mob.say(pick("NEC CANTIO!","AULIE OXIN FIERA!", "STI KALY!", "TARCOL MINTI ZHERI!"))
			if(prob(2))
				affected_mob << "\red You feel [pick("the magic bubbling in your veins","that this location gives you a +1 to INT","an urge to summon familiar.")]."

		if(4)
			spawn_wizard_clothes(10)
			if(prob(4))
				affected_mob.say(pick("NEC CANTIO!","AULIE OXIN FIERA!","STI KALY!","EI NATH!"))
				return
			if(prob(2))
				affected_mob << "\red You feel [pick("the tidal wave of raw power building inside","that this location gives you a +2 to INT and +1 to WIS","an urge to teleport")]."
			if(prob(5))

				var/list/theareas = new/list()
				for(var/area/AR in world)
					if(theareas.Find(AR)) continue
					var/turf/picked = pick(get_area_turfs(AR.type))
					if (picked.z == affected_mob.z)
						theareas += AR

				var/area/thearea = pick(theareas)
				affected_mob.say("SCYAR NILA [uppertext(thearea.name)]")

				var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
				smoke.set_up(5, 0, affected_mob.loc)
				smoke.attach(affected_mob)
				smoke.start()
				var/list/L = list()
				for(var/turf/T in get_area_turfs(thearea.type))
					if(T.z != affected_mob.z) continue
					if(!T.density)
						var/clear = 1
						for(var/obj/O in T)
							if(O.density)
								clear = 0
								break
						if(clear)
							L+=T

				affected_mob.loc = pick(L)
				smoke.start()

				return
	return



/datum/disease/wizarditis/proc/spawn_wizard_clothes(var/chance=5)
	var/mob/living/carbon/human/H = affected_mob
	if(prob(chance))
		if(!istype(H.head, /obj/item/clothing/head/wizard))
			if(H.head)
				H.drop_from_slot(H.head)
			H.head = new /obj/item/clothing/head/wizard(H)
			H.head.layer = 20
		return
	if(prob(chance))
		if(!istype(H.wear_suit, /obj/item/clothing/suit/wizrobe))
			if(H.wear_suit)
				H.drop_from_slot(H.wear_suit)
			H.wear_suit = new /obj/item/clothing/suit/wizrobe(H)
			H.wear_suit.layer = 20
		return
	if(prob(chance))
		if(!istype(H.shoes, /obj/item/clothing/shoes/sandal))
			if(H.shoes)
				H.drop_from_slot(H.shoes)
			H.shoes = new /obj/item/clothing/shoes/sandal(H)
			H.shoes.layer = 20
		return
	if(prob(chance))
		if(!istype(H.r_hand, /obj/item/weapon/staff))
			if(H.r_hand)
				H.drop_from_slot(H.r_hand)
			H.r_hand = new /obj/item/weapon/staff(H)
			H.r_hand.layer = 20
		return
	return
