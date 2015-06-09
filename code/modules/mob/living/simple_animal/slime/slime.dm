/mob/living/simple_animal/slime
	name = "baby slime"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey baby slime"
	pass_flags = PASSTABLE
	ventcrawler = 2
	var/is_adult = 0
	var/docile = 0
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

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	maxHealth = 150
	health = 150
	gender = NEUTER

	nutrition = 700

	see_in_dark = 8

	verb_say = "telepathically chirps"
	verb_ask = "telepathically asks"
	verb_exclaim = "telepathically cries"
	verb_yell = "telephatically cries"

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
	var/mutator_used = FALSE //So you can't shove a dozen mutators into a single slime

	///////////TIME FOR SUBSPECIES

	var/colour = "grey"
	var/coretype = /obj/item/slime_extract/grey
	var/list/slime_mutation[4]

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
		var/sanitizedcolour = replacetext(colour, " ", "")
		coretype = text2path("/obj/item/slime_extract/[sanitizedcolour]")
	..()

/mob/living/simple_animal/slime/regenerate_icons()
	overlays.len = 0
	var/icon_text = "[colour] [is_adult ? "adult" : "baby"] slime"
	icon_dead = "[icon_text] dead"
	if(stat != DEAD)
		icon_state = icon_text
		if(mood)
			overlays += image('icons/mob/slimes.dmi', icon_state = "aslime-[mood]")
	else
		icon_state = icon_dead
	..()

/mob/living/simple_animal/slime/movement_delay()
	if(bodytemperature >= 330.23) // 135 F
		return -1	// slimes become supercharged at high temperatures

	var/tally = 0

	var/health_deficiency = (100 - health)
	if(health_deficiency >= 45)
		tally += (health_deficiency / 25)

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

/mob/living/simple_animal/slime/Process_Spacemove(var/movement_dir = 0)
	return 2

/mob/living/simple_animal/slime/Stat()
	if(..())

		if(!docile)
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
	if(!Proj)
		return
	attacked += 10
	if((Proj.damage_type == BURN))
		adjustBruteLoss(-abs(Proj.damage)) //fire projectiles heals slimes.
		Proj.on_hit(src, 0)
	else
		..(Proj)
	return 0

/mob/living/simple_animal/slime/emp_act(severity)
	powerlevel = 0 // oh no, the power!
	..()

/mob/living/simple_animal/slime/MouseDrop(var/atom/movable/A as mob|obj)
	if(isliving(A) && A != src)
		var/mob/living/Food = A
		if(CanFeedon(Food))
			Feedon(Food)
	..()

/mob/living/simple_animal/slime/unEquip(obj/item/W as obj)
	return

/mob/living/simple_animal/slime/start_pulling(var/atom/movable/AM)
	return

/mob/living/simple_animal/slime/attack_ui(slot)
	return

/mob/living/simple_animal/slime/attack_slime(mob/living/simple_animal/slime/M as mob)
	if(..()) //successful slime attack
		if(M == src)
			return
		if(Victim)
			Victim = null
			visible_message("<span class='danger'>[M] pulls [src] off!</span>")
			return
		attacked += 5
		if(nutrition >= 100) //steal some nutrition. negval handled in life()
			nutrition -= (50 + (40 * M.is_adult))
			M.add_nutrition(50 + (40 * M.is_adult))
		if(health > 0)
			M.adjustBruteLoss(-10 + (-10 * M.is_adult))
			M.updatehealth()

/mob/living/simple_animal/slime/attack_animal(mob/living/simple_animal/M as mob)
	if(..())
		attacked += 10


/mob/living/simple_animal/slime/attack_paw(mob/living/carbon/monkey/M as mob)
	if(..()) //successful monkey bite.
		attacked += 10

/mob/living/simple_animal/slime/attack_larva(mob/living/carbon/alien/larva/L as mob)
	if(..()) //successful larva bite.
		attacked += 10

/mob/living/simple_animal/slime/attack_hulk(mob/living/carbon/human/user)
	if(user.a_intent == "harm")
		adjustBruteLoss(10)
		discipline_slime(user)


/mob/living/simple_animal/slime/attack_hand(mob/living/carbon/human/M as mob)
	if(Victim)
		if(Victim == M)
			if(prob(60))
				visible_message("<span class='warning'>[M] attempts to wrestle \the [name] off!</span>")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

			else
				visible_message("<span class='warning'> [M] manages to wrestle \the [name] off!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

				discipline_slime(M)

		else
			M.do_attack_animation(src)
			if(prob(30))
				visible_message("<span class='warning'>[M] attempts to wrestle \the [name] off of [Victim]!</span>")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

			else
				visible_message("<span class='warning'> [M] manages to wrestle \the [name] off of [Victim]!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

				discipline_slime(M)
	else
		if(stat == DEAD && surgeries.len)
			if(M.a_intent == "help")
				for(var/datum/surgery/S in surgeries)
					if(S.next_step(M, src))
						return 1
		if(..()) //successful attack
			attacked += 10

/mob/living/simple_animal/slime/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if(..()) //if harm or disarm intent.
		attacked += 10
		discipline_slime(M)


/mob/living/simple_animal/slime/attackby(obj/item/W, mob/living/user, params)
	if(stat == DEAD && surgeries.len)
		if(user.a_intent == "help")
			for(var/datum/surgery/S in surgeries)
				if(S.next_step(user, src))
					return 1
	if(istype(W,/obj/item/stack/sheet/mineral/plasma)) //Let's you feed slimes plasma.
		if (user in Friends)
			++Friends[user]
		else
			Friends[user] = 1
		user << "<span class='notice'>You feed the slime the plasma. It chirps happily.</span>"
		var/obj/item/stack/sheet/mineral/plasma/S = W
		S.use(1)
		return
	if(W.force > 0)
		attacked += 10
		if(prob(25))
			user.do_attack_animation(src)
			user.changeNext_move(CLICK_CD_MELEE)
			user << "<span class='danger'>[W] passes right through [src]!</span>"
			return
		if(Discipline && prob(50)) // wow, buddy, why am I getting attacked??
			Discipline = 0
	if(W.force >= 3)
		var/force_effect = 2 * W.force
		if(is_adult)
			force_effect = round(W.force/2)
		if(prob(10 + force_effect))
			discipline_slime(user)
	..()

/mob/living/simple_animal/slime/show_inv(mob/user)
	return

/mob/living/simple_animal/slime/proc/apply_water()
	adjustBruteLoss(rand(15,20))
	if(!client)
		if(Target) // Like cats
			Target = null
			++Discipline
	return

/mob/living/simple_animal/slime/getTrail()
	return null

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

/mob/living/simple_animal/slime/proc/discipline_slime(mob/user)

	if(stat == DEAD)
		return

	if(prob(80) && !client)
		Discipline++

		if(!is_adult)
			if(Discipline == 1)
				attacked = 0

	if(Victim || Target)
		Victim = null
		Target = null
		anchored = 0

	spawn(0)
		SStun = 1
		sleep(rand(20,60))
		SStun = 0

	spawn(0)
		canmove = 0
		if(user)
			step_away(src,user,15)
		sleep(3)
		if(user)
			step_away(src,user,15)
		canmove = 1

/mob/living/simple_animal/slime/pet
	docile = 1
