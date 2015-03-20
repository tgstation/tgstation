/mob/living/simple_animal/slime
	name = "baby slime"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey baby slime"
	pass_flags = PASSTABLE
	say_message = "hums"
	ventcrawler = 2
	var/is_adult = 0
	languages = SLIME | HUMAN
	faction = list("slime")

	harm_intent_damage = 5
	icon_living = "grey baby slime"
	icon_dead = "grey baby slime dead"
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	emote_see = list("jiggles", "bounces in place")
	speak_emote = list("chirps")

	layer = 5

	maxHealth = 150
	health = 150
	gender = NEUTER

	update_icon = 0
	nutrition = 700

	see_in_dark = 8
	update_slimes = 0

	// canstun and canweaken don't affect slimes because they ignore stun and weakened variables
	// for the sake of cleanliness, though, here they are.
	status_flags = CANPARALYSE|CANPUSH

	var/cores = 1 // the number of /obj/item/slime_extract's the slime has left inside
	var/mutation_chance = 30 // Chance of mutating, should be between 25 and 35

	var/powerlevel = 0 // 1-10 controls how much electricity they are generating
	var/amount_grown = 0 // controls how long the slime has been overfed, if 10, grows or reproduces

	var/number = 0 // Used to understand when someone is talking to it

	var/mob/living/Victim = null // the person the slime is currently feeding on
	var/mob/living/Target = null // AI variable - tells the slime to hunt this down
	var/mob/living/Leader = null // AI variable - tells the slime to follow this person

	var/attacked = 0 // Determines if it's been attacked recently. Can be any number, is a cooloff-ish variable
	var/rabid = 0 // If set to 1, the slime will attack and eat anything it comes in contact with
	var/holding_still = 0 // AI variable, cooloff-ish for how long it's going to stay in one place
	var/target_patience = 0 // AI variable, cooloff-ish for how long it's going to follow its target

	var/list/Friends = list() // A list of friends; they are not considered targets for feeding; passed down after splitting

	var/list/speech_buffer = list() // Last phrase said near it and person who said it

	var/mood = "" // To show its face

	///////////TIME FOR SUBSPECIES

	var/colour = "grey"
	var/coretype = /obj/item/slime_extract/grey
	var/list/slime_mutation[4]


/mob/living/simple_animal/slime/pet
	name = "pet slime"
	desc = "A lovable, domesticated slime."
	health = 100
	maxHealth = 100

/mob/living/simple_animal/slime/pet/New()
	..()
	if(is_adult)
		overlays += "aslime-:33"

/mob/living/simple_animal/slime/New()
	if(is_adult)
		health = 200
		maxHealth = 200
	create_reagents(100)
	spawn (0)
		number = rand(1, 1000)
		name = "[colour] [is_adult ? "adult" : "baby"] slime ([number])"
		icon_state = "[colour] [is_adult ? "adult" : "baby"] slime"
		icon_dead = "[icon_state] dead"
		real_name = name
		slime_mutation = mutation_table(colour)
		mutation_chance = rand(25, 35)
		var/sanitizedcolour = replacetext(colour, " ", "")
		coretype = text2path("/obj/item/slime_extract/[sanitizedcolour]")
	..()

/mob/living/simple_animal/slime/regenerate_icons()
	icon_state = "[colour] [is_adult ? "adult" : "baby"] slime"
	icon_dead = "[icon_state] dead"
	overlays.len = 0
	if(mood)
		overlays += image('icons/mob/slimes.dmi', icon_state = "aslime-[mood]")
	..()

/mob/living/simple_animal/slime/movement_delay()
	if(bodytemperature >= 330.23) // 135 F
		return -1	// slimes become supercharged at high temperatures

	var/tally = 0

	var/health_deficiency = (100 - health)
	if(health_deficiency >= 45) tally += (health_deficiency / 25)

	if(bodytemperature < 183.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75

	if(reagents)
		if(reagents.has_reagent("morphine")) // morphine slows slimes down
			tally *= 2

		if(reagents.has_reagent("frostoil")) // Frostoil also makes them move VEEERRYYYYY slow
			tally *= 5

	if(health <= 0) // if damaged, the slime moves twice as slow
		tally *= 2

	return tally + config.slime_delay

/mob/living/simple_animal/slime/ObjBump(obj/O)
	if(!client && powerlevel > 0)
		var/probab = 10
		switch(powerlevel)
			if(1 to 2)	probab = 20
			if(3 to 4)	probab = 30
			if(5 to 6)	probab = 40
			if(7 to 8)	probab = 60
			if(9)		probab = 70
			if(10)		probab = 95
		if(prob(probab))
			if(istype(O, /obj/structure/window) || istype(O, /obj/structure/grille))
				if(nutrition <= get_hunger_nutrition() && !Atkcool)
					if (is_adult || prob(5))
						O.attack_slime(src)
						Atkcool = 1
						spawn(45)
							Atkcool = 0

/mob/living/simple_animal/slime/MobBump(mob/M)
	if(istype(M, /mob/living/carbon/human)) //pushing humans
		if(is_adult && prob(10)) //only if we're adult, and 10% of the time
			return 0
		else
			return 1

/mob/living/simple_animal/slime/Process_Spacemove(var/movement_dir = 0)
	return 2

/mob/living/simple_animal/slime/Stat()
	..()

	if(statpanel("Status"))
		if(is_adult)
			stat(null, "Health: [round((health / 200) * 100)]%")
		else
			stat(null, "Health: [round((health / 150) * 100)]%")

		stat(null, "Nutrition: [nutrition]/[get_max_nutrition()]")
		if(amount_grown >= 10)
			if(is_adult)
				stat(null, "You can reproduce!")
			else
				stat(null, "You can evolve!")

		stat(null,"Power Level: [powerlevel]")

/mob/living/simple_animal/slime/adjustFireLoss(amount)
	..(-abs(amount)) // Heals them
	return

/mob/living/simple_animal/slime/bullet_act(var/obj/item/projectile/Proj)
	attacked += 10
	..(Proj)
	return 0

/mob/living/simple_animal/slime/emp_act(severity)
	powerlevel = 0 // oh no, the power!
	..()

/mob/living/simple_animal/slime/ex_act(severity, target)
	..()

	switch (severity)
		if (1.0)
			gib()
			return

		if (2.0)
			adjustBruteLoss(60)
			adjustFireLoss(60)

		if(3.0)
			adjustBruteLoss(30)

	updatehealth()

/mob/living/simple_animal/slime/MouseDrop(var/atom/movable/A as mob|obj)
	if(isliving(A) && A != src && usr == src)
		var/mob/living/Food = A
		if(Food.Adjacent(src) && !stat && Food.stat != DEAD) //messy
			Feedon(Food)
	..()

/mob/living/simple_animal/slime/unEquip(obj/item/W as obj)
	return

/mob/living/simple_animal/slime/start_pulling(var/atom/movable/AM)
	return

/mob/living/simple_animal/slime/attack_ui(slot)
	return

/mob/living/simple_animal/slime/attack_slime(mob/living/simple_animal/slime/M as mob)
	..()
	if(Victim)
		Victim = null
		visible_message("<span class='danger'>[M] pulls [src] off!</span>")
		return
	attacked += 5
	if(src.nutrition >= 100) //steal some nutrition. negval handled in life()
		src.nutrition -= (50 + (5 * M.amount_grown))
		M.add_nutrition(50 + (5 * M.amount_grown))
	if(src.health > 0)
		src.adjustBruteLoss(4 + (2 * M.amount_grown)) //amt_grown isn't very linear but it works
		src.updatehealth()
		M.adjustBruteLoss(-4 + (-2 * M.amount_grown))
		M.updatehealth()
	return

/mob/living/simple_animal/slime/attack_animal(mob/living/simple_animal/M as mob)
	if(..())
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		attacked += 10
		adjustBruteLoss(damage)
		updatehealth()

/mob/living/simple_animal/slime/attack_paw(mob/living/carbon/monkey/M as mob)
	if(..()) //successful monkey bite.
		if(stat != DEAD)
			attacked += 10
			adjustBruteLoss(rand(1, 3))
			updatehealth()
	return

/mob/living/simple_animal/slime/attack_larva(mob/living/carbon/alien/larva/L as mob)
	if(..()) //successful larva bite.
		var/damage = rand(1, 3)
		if(stat != DEAD)
			L.amount_grown = min(L.amount_grown + damage, L.max_grown)
			adjustBruteLoss(damage)
			updatehealth()

/mob/living/simple_animal/slime/attack_hulk(mob/living/carbon/human/user)
	if(user.a_intent == "harm")
		adjustBruteLoss(5)
		if(Victim || Target)
			Victim = null
			Target = null
			anchored = 0
			if(prob(80) && !client)
				Discipline++
			spawn(0)
				step_away(src,user,15)
				sleep(3)
				step_away(src,user,15)


/mob/living/simple_animal/slime/attack_hand(mob/living/carbon/human/M as mob)
	if(Victim)
		if(Victim == M)
			if(prob(60))
				visible_message("<span class='warning'>[M] attempts to wrestle \the [name] off!</span>")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

			else
				visible_message("<span class='warning'> [M] manages to wrestle \the [name] off!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

				if(prob(90) && !client)
					Discipline++

				spawn()
					SStun = 1
					sleep(rand(45,60))
					if(src)
						SStun = 0

				Victim = null
				anchored = 0
				step_away(src,M)

		else
			M.do_attack_animation(src)
			if(prob(30))
				visible_message("<span class='warning'>[M] attempts to wrestle \the [name] off of [Victim]!</span>")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

			else
				visible_message("<span class='warning'> [M] manages to wrestle \the [name] off of [Victim]!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

				if(prob(80) && !client)
					Discipline++

					if(!is_adult)
						if(Discipline == 1)
							attacked = 0

				spawn()
					SStun = 1
					sleep(rand(55,65))
					if(src)
						SStun = 0

				Victim = null
				anchored = 0
				step_away(src,M)

		return


	if(..()) //successful attack
		attacked += 10

/mob/living/simple_animal/slime/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if(..()) //if harm or disarm intent.

		if (M.a_intent == "harm")
			if (prob(95))
				attacked += 10
				playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
				var/damage = rand(15, 30)
				if (damage >= 25)
					damage = rand(20, 40)
					visible_message("<span class='danger'>[M] has slashed [name]!</span>", \
							"<span class='userdanger'>[M] has slashed [name]!</span>")
				else
					visible_message("<span class='danger'>[M] has wounded [name]!</span>", \
							"<span class='userdanger'>)[M] has wounded [name]!</span>")

				add_logs(M, src, "attacked", admin=0)
				if (health != DEAD)
					adjustBruteLoss(damage)
					updatehealth()
			else
				playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] has attempted to lunge at [name]!</span>", \
						"<span class='userdanger'>[M] has attempted to lunge at [name]!</span>")

		if (M.a_intent == "disarm")
			playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
			var/damage = 5
			attacked += 10

			if(prob(95))
				visible_message("<span class='danger'>[M] has tackled [name]!</span>", \
						"<span class='userdanger'>[M] has tackled [name]!</span>")

				if(Victim || Target)
					Victim = null
					Target = null
					anchored = 0
					if(prob(80) && !client)
						Discipline++
						if(!istype(src, /mob/living/simple_animal/slime))
							if(Discipline == 1)
								attacked = 0

				spawn()
					SStun = 1
					sleep(rand(5,20))
					SStun = 0

				spawn(0)

					step_away(src,M,15)
					sleep(3)
					step_away(src,M,15)

			else
				drop_item()
				visible_message("<span class='danger'>[M] has disarmed [name]!</span>",
						"<span class='userdanger'>[M] has disarmed [name]!</span>")
			add_logs(M, src, "disarmed", admin=0)
			adjustBruteLoss(damage)
			updatehealth()
	return

/mob/living/simple_animal/slime/attackby(obj/item/W, mob/living/user, params)
	if(istype(W,/obj/item/stack/sheet/mineral/plasma)) //Let's you feed slimes plasma.
		if (user in Friends)
			++Friends[user]
		else
			Friends[user] = 1
		user << "You feed the slime the plasma. It chirps happily."
		var/obj/item/stack/sheet/mineral/plasma/S = W
		S.use(1)
		return
	else if(W.force > 0)
		attacked += 10
		if(prob(25))
			user.do_attack_animation(src)
			user << "<span class='danger'>[W] passes right through [src]!</span>"
			return
		if(Discipline && prob(50)) // wow, buddy, why am I getting attacked??
			Discipline = 0
	else if(W.force >= 3)
		var/force_effect = 2 * W.force
		if(is_adult)
			force_effect = round(W.force/2)
		if(prob(10 + force_effect))
			if(Victim || Target)
				if(prob(80) && !client)
					Discipline++
				if(Discipline == 1 && !is_adult)
					attacked = 0
				spawn()
					SStun = 1
					sleep(rand(5,20))
					SStun = 0

				Victim = null
				Target = null
				anchored = 0

				spawn(0)
					if(user)
						canmove = 0
						step_away(src, user)
						if(prob(25 + 2*force_effect))
							sleep(2)
							if(user)
								step_away(src, user)
						canmove = 1
	..()

/mob/living/simple_animal/slime/show_inv(mob/user)
	return

/mob/living/simple_animal/slime/proc/apply_water()
	adjustToxLoss(rand(15,20))
	if(!client)
		if(Target) // Like cats
			Target = null
			++Discipline
	return

/mob/living/simple_animal/slime/getTrail()
	return null

/mob/living/simple_animal/slime/slip(var/s_amount, var/w_amount, var/obj/O, var/lube)
	if(lube>=2)
		return 0
	.=..()

/mob/living/simple_animal/slime/stripPanelUnequip(obj/item/what, mob/who)
	src << "<span class='warning'>You don't have the dexterity to do this!</span>"
	return

/mob/living/simple_animal/slime/stripPanelEquip(obj/item/what, mob/who)
	src << "<span class='warning'>You don't have the dexterity to do this!</span>"
	return

/mob/living/simple_animal/slime/examine(mob/user)

	var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n"
	if (src.stat == DEAD)
		msg += "<span class='deadsay'>It is limp and unresponsive.</span>\n"
	else
		if (src.getBruteLoss())
			msg += "<span class='warning'>"
			if (src.getBruteLoss() < 40)
				msg += "It has some punctures in its flesh!"
			else
				msg += "<B>It has severe punctures and tears in its flesh!</B>"
			msg += "</span>\n"

		switch(powerlevel)

			if(2 to 3)
				msg += "It is flickering gently with a little electrical activity.\n"

			if(4 to 5)
				msg += "It is glowing gently with moderate levels of electrical activity.\n"

			if(6 to 9)
				msg += "<span class='warning'>It is glowing brightly with high levels of electrical activity.</span>\n"

			if(10)
				msg += "<span class='warning'><B>It is radiating with massive levels of electrical activity!</B></span>\n"

	msg += "*---------*</span>"
	user << msg
	return

