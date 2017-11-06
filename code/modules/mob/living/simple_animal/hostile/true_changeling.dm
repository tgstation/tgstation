#define TRUE_CHANGELING_REFORM_THRESHOLD 0 //Can turn back at will, by default
#define TRUE_CHANGELING_PASSIVE_HEAL 3 //Amount of brute damage restored per tick
#define TRUE_CHANGELING_FORCED_REFORM 180 //3 minutes

//Changelings in their true form.
//Massive health and damage, but move slowly.

/mob/living/simple_animal/hostile/true_changeling
	name = "true changeling"
	real_name = "true changeling"
	desc = "Holy shit, what the fuck is that thing?!"
	speak_emote = list("says with one of its faces")
	emote_hear = list("says with one of its faces")
	icon = 'icons/mob/animal.dmi'
	icon_state = "horror1"
	icon_living = "horror1"
	icon_dead = "horror_dead"
	speed = 1
	gender = NEUTER
	a_intent = "harm"
	stop_automated_movement = 1
	status_flags = CANPUSH
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	health = 250
	maxHealth = 250 //pretty durable
	force_threshold = 10
	healable = 0
	environment_smash = 1 //Tables, closets, etc.
	melee_damage_lower = 35
	melee_damage_upper = 35
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	wander = 0
	attacktext = "tears into"
	attack_sound = 'sound/creatures/hit3.ogg'
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 15) //It's a pretty big dude. Actually killing one is a feat.
	gold_core_spawnable = 1 //To be fair, they won't be able to become changelings, like headslugs can
	var/time_spent_as_true = 0
	var/playstyle_string = "<b><font size=3 color='red'>We have entered our true form!</font> We are unbelievably powerful, and regenerate life at a steady rate. However, most of \
	our abilities are useless in this form, and we must utilise the abilities that we have gained as a result of our transformation. Taking too much damage will also turn us back into a \
	human in addition to knocking us out for a long time. Finally, we will uncontrollably revert into a human after some time due to our inability to maintain this form.</b>"
	var/mob/living/carbon/human/stored_changeling = null //The changeling that transformed
	var/devouring = FALSE //If the true changeling is currently devouring a human
	var/wallcrawl = FALSE //If the true changeling is crawling around the place, allowing it to counteract gravity loss

/mob/living/simple_animal/hostile/true_changeling/New()
	..()
	var/horrorskin = pick(1, 2, 3, 4)
	switch(horrorskin)
		if(1)
			icon_state = "horror1"
		if(2)
			icon_state = "horror2"
		if(3)
			icon_state = "horror3"
		if(4)
			icon_state = "horror4"
	spawn(0)
		to_chat(usr, playstyle_string)

/mob/living/simple_animal/hostile/true_changeling/Life()
	..()
	adjustBruteLoss(-TRUE_CHANGELING_PASSIVE_HEAL) //True changelings slowly regenerate
	time_spent_as_true++ //Used for re-forming
	if(stored_changeling && time_spent_as_true >= TRUE_CHANGELING_FORCED_REFORM)
		death() //After a while, the ling'll revert back without being able to control it

/mob/living/simple_animal/hostile/true_changeling/Stat()
	..()
	if(statpanel("Status"))
		if(stored_changeling)
			var/time_left = TRUE_CHANGELING_FORCED_REFORM - time_spent_as_true
			time_left = Clamp(time_left, 0, INFINITY)
			stat(null, "Time Remaining: [time_left]")
		stat(null, "Ignoring Gravity: [wallcrawl ? "YES" : "NO"]")

/mob/living/simple_animal/hostile/true_changeling/death()
	..(1)
	if(stored_changeling && mind)
		visible_message("<span class='warning'>[src] lets out a furious scream as it shrinks into its human form.</span>", \
						"<span class='userdanger'>We lack the power to maintain this form! We helplessly turn back into a human...</span>")
		stored_changeling.loc = get_turf(src)
		mind.transfer_to(stored_changeling)
		stored_changeling.Unconscious(30) //Make them helpless for 30 seconds
		stored_changeling.status_flags &= ~GODMODE
		qdel(src)
	else
		visible_message("<span class='warning'>[src] lets out a waning scream as it falls, twitching, to the floor.</span>", \
						"<span class='userdanger'>We have fallen! We begin the revival process... (this will take around 45 seconds.)</span>")
		spawn(450)
			if(src)
				visible_message("<span class='warning'>[src] suddenly rises from the dead!</span>")
				revive() //Changelings can self-revive, and true changelings are no exception

/mob/living/simple_animal/hostile/true_changeling/mob_negates_gravity()
	return wallcrawl

/mob/living/simple_animal/hostile/true_changeling/adjustFireLoss(amount)
	amount *= 2 //True changelings take 2 times the burn damage!
	..()

/mob/living/simple_animal/hostile/true_changeling/verb/reform()
	set name = "Re-Form Human Shell"
	set desc = "We turn back into a human. This takes considerable effort and will stun us for some time afterwards."
	set category = "True Changeling"

	if(stat)
		to_chat(usr, "<span class='warning'>We must be conscious to debase ourselves!</span>")
		return FALSE
	if(!stored_changeling)
		to_chat(usr, "<span class='warning'>We do not have a form other than this!</span>")
		return FALSE
	if(time_spent_as_true < TRUE_CHANGELING_REFORM_THRESHOLD)
		to_chat(usr, "<span class='warning'>We are not able to change back at will!</span>")
		return FALSE
	visible_message("<span class='warning'>[src] suddenly crunches and twists into a smaller form!</span>", \
					"<span class='danger'>We return to our lesser form.</span>")
	stored_changeling.loc = get_turf(src)
	mind.transfer_to(stored_changeling)
	stored_changeling.Unconscious(80)
	stored_changeling.status_flags &= ~GODMODE
	qdel(usr)
	return 1

/mob/living/simple_animal/hostile/true_changeling/verb/devour()
	set name = "Devour"
	set desc = "We tear into the innards of a human. After some time, they will be significantly damaged and our health partially restored."
	set category = "True Changeling"

	if(stat)
		to_chat(usr, "<span class='warning'>We must be conscious to feast!</span>")
		return FALSE
	if(devouring)
		to_chat(usr, "<span class='warning'>We are already feasting on a human!</span>")
		return FALSE
	var/list/potential_targets = list()
	for(var/mob/living/carbon/human/H in range(1, src))
		if(H == stored_changeling || (H.mind && H.mind.changeling)) //You can't eat changelings in human form
			continue
		potential_targets.Add(H)
	if(!potential_targets.len)
		to_chat(usr, "<span class='warning'>There are no humans nearby!</span>")
		return FALSE
	var/mob/living/carbon/human/lunch
	if(potential_targets.len == 1)
		lunch = potential_targets[1]
	else
		lunch = input(src, "Choose a human to devour.", "Lunch") as null|anything in potential_targets
	if(!lunch)
		return FALSE
	if(lunch.getBruteLoss() >= 200)
		to_chat(usr, "<span class='warning'>This human's flesh is too mangled to devour!</span>")
		return FALSE
	devouring = TRUE
	visible_message("<span class='warning'>[src] begins ripping apart and feasting on [lunch]!</span>", \
						"<span class='danger'>We begin to feast upon [lunch]...</span>")
	if(!do_mob(src, 50, target = lunch))
		devouring = FALSE
		return FALSE
	devouring = FALSE
	visible_message("<span class='warning'>[src] tears a chunk from [lunch]'s flesh!</span>", \
						"<span class='danger'>We tear a chunk of flesh from [lunch] and devour it!</span>")
	lunch.adjustBruteLoss(60)
	to_chat(lunch, "<span class='userdager'>[src] tears into you!</span>")
	var/obj/effect/decal/cleanable/blood/gibs/G = new(get_turf(lunch))
	step(G, pick(GLOB.alldirs)) //Make some gibs spray out for dramatic effect
	playsound(lunch, 'sound/creatures/hit6.ogg', 50, 1)
	if(!lunch.stat)
		lunch.emote("scream")
	if(lunch.disabilities & FAT)
		adjustBruteLoss(-100) //Tasty leetle peegy
	else
		adjustBruteLoss(-50)

/mob/living/simple_animal/hostile/true_changeling/verb/crawl()
	set name = "Spine Crawl"
	set desc = "We use our spines to gouge into terrain and crawl along it, negating gravity loss. This makes us very slow."
	set category = "True Changeling"

	if(stat)
		to_chat(usr, "<span class='warning'>We must be conscious to switch our method of movement!</span>")
		return FALSE
	wallcrawl = !wallcrawl
	if(wallcrawl)
		visible_message("<span class='warning'>[src] begins gouging its spines into the terrain!</span>", \
							"<span class='danger'>We begin using our spines for movement.</span>")
		speed = 3 //Veeery slow
	else
		visible_message("<span class='warning'>[src] recedes their spines back into their body!</span>", \
							"<span class='danger'>We return moving normally.</span>")
		speed = initial(speed)

#undef TRUE_CHANGELING_REFORM_THRESHOLD
#undef TRUE_CHANGELING_PASSIVE_HEAL
#undef TRUE_CHANGELING_FORCED_REFORM