#define TRUE_CHANGELING_REFORM_THRESHOLD 0 //Can turn back at will, by default
#define TRUE_CHANGELING_PASSIVE_HEAL 3 //Amount of brute damage restored per tick
#define TRUE_CHANGELING_FORCED_REFORM 180 //3 minutes

//Changelings in their true form.
//Massive health and damage, but all of their chems and it's really obvious it's >them

/mob/living/simple_animal/hostile/true_changeling
	name = "horror"
	real_name = "horror"
	desc = "Holy shit, what the fuck is that thing?!"
	speak_emote = list("says with one of its faces")
	emote_hear = list("says with one of its faces")
	icon = 'icons/mob/changeling.dmi'
	icon_state = "horror1"
	icon_living = "horror1"
	icon_dead = "horror_dead"
	speed = 0.5
	gender = NEUTER
	a_intent = "harm"
	stop_automated_movement = TRUE
	status_flags = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	health = 240
	maxHealth = 240 //pretty durable
	damage_coeff = list(BRUTE = 0.75, BURN = 2, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1) //feel the burn!!
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
	var/time_spent_as_true = 0
	var/playstyle_string = "<b><span class='big danger'>We have entered our true form!</span><br>We are unbelievably deadly, and regenerate life at a steady rate. We must utilise the abilities that we have gained as a result of our transformation, as our old ones are not usable in this form. Taking too much damage will also turn us back into a \
	human in addition to knocking us out. We are not as strong health-wise as we are damage, and we must avoid fire at all costs. Finally, we will uncontrollably revert into a human after some time due to our inability to maintain this form.</b>"
	var/mob/living/carbon/human/stored_changeling = null //The changeling that transformed
	var/devouring = FALSE //If the true changeling is currently devouring a human
	var/wallcrawl = FALSE //If the true changeling is crawling around the place, allowing it to counteract gravity loss
	var/range = 7
	var/datum/action/innate/changeling/reform/reform
	var/datum/action/innate/changeling/devour/devour
	var/datum/action/innate/changeling/spine_crawl/spine_crawl

/mob/living/simple_animal/hostile/true_changeling/Initialize()
	. = ..()
	icon_state = "horror[rand(1, 5)]"
	reform = new
	reform.Grant(src)
	devour = new
	devour.Grant(src)
	spine_crawl = new
	spine_crawl.Grant(src)

/mob/living/simple_animal/hostile/true_changeling/Destroy()
	QDEL_NULL(reform)
	QDEL_NULL(devour)
	QDEL_NULL(spine_crawl)
	stored_changeling = null
	return ..()

/mob/living/simple_animal/hostile/true_changeling/Login()
	. = ..()
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
			time_left = CLAMP(time_left, 0, INFINITY)
			stat(null, "Time Remaining: [time_left]")
		stat(null, "Ignoring Gravity: [wallcrawl ? "YES" : "NO"]")

/mob/living/simple_animal/hostile/true_changeling/death()
	..(1)
	new /obj/effect/gibspawner/human(get_turf(src))
	if(stored_changeling && mind)
		visible_message("<span class='warning'>[src] lets out a furious scream as it shrinks into its human form.</span>", \
						"<span class='userdanger'>We lack the power to maintain this form! We helplessly turn back into a human...</span>")
		stored_changeling.loc = get_turf(src)
		mind.transfer_to(stored_changeling)
		stored_changeling.Unconscious(300) //Make them helpless for some time
		stored_changeling.status_flags &= ~GODMODE
		qdel(src)
	else
		visible_message("<span class='warning'>[src] lets out a waning scream as it falls, twitching, to the floor.</span>", \
						"<span class='userdanger'>We have fallen! We begin the revival process...</span>")
		addtimer(CALLBACK(src, .proc/lingreform), 450)

/mob/living/simple_animal/hostile/true_changeling/proc/lingreform()
	if(!src)
		return FALSE
	visible_message("<span class='userdanger'>the twitching corpse of [src] reforms!</span>")
	for(var/mob/M in view(7, src))
		flash_color(M, flash_color = list("#db0000", "#db0000", "#db0000", rgb(0,0,0)), flash_time = 5)
	new /obj/effect/gibspawner/human(get_turf(src))
	revive() //Changelings can self-revive, and true changelings are no exception

/mob/living/simple_animal/hostile/true_changeling/mob_negates_gravity()
	return wallcrawl

/mob/living/simple_animal/hostile/true_changeling/adjustFireLoss(amount)
	if(!stat)
		playsound(src, 'sound/creatures/ling_scream.ogg', 100, 1)
	..()

/datum/action/innate/changeling
	icon_icon = 'icons/mob/changeling.dmi'
	background_icon_state = "bg_ling"

/datum/action/innate/changeling/reform
	name = "Re-Form Human Shell"
	desc = "We turn back into a human. This takes considerable effort and will stun us for some time afterwards."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "reform"

/datum/action/innate/changeling/reform/Activate()
	var/mob/living/simple_animal/hostile/true_changeling/M = owner
	if(!istype(M))
		return
	if(!M.stored_changeling)
		to_chat(M, "<span class='warning'>We do not have a form other than this!</span>")
		return FALSE
	if(M.time_spent_as_true < TRUE_CHANGELING_REFORM_THRESHOLD)
		to_chat(M, "<span class='warning'>We are not able to change back at will!</span>")
		return FALSE
	M.visible_message("<span class='warning'>[M] suddenly crunches and twists into a smaller form!</span>", \
					"<span class='danger'>We return to our human form.</span>")
	M.stored_changeling.forceMove(get_turf(M))
	M.mind.transfer_to(M.stored_changeling)
	M.stored_changeling.Unconscious(200)
	M.stored_changeling.status_flags &= ~GODMODE
	qdel(M)
	return TRUE

/datum/action/innate/changeling/devour
	name = "Devour"
	desc = "We tear into the innards of a human. After some time, they will be significantly damaged and our health partially restored."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "devour"

/datum/action/innate/changeling/devour/Activate()
	var/mob/living/simple_animal/hostile/true_changeling/M = owner
	if(!istype(M))
		return
	if(M.devouring)
		to_chat(M, "<span class='warning'>We are already feasting on a human!</span>")
		return FALSE
	var/list/potential_targets = list()
	for(var/mob/living/carbon/human/H in range(1, M))
		potential_targets.Add(H)
	if(!potential_targets.len)
		to_chat(M, "<span class='warning'>There are no humans nearby!</span>")
		return FALSE
	var/mob/living/carbon/human/lunch
	if(potential_targets.len == 1)
		lunch = potential_targets[1]
	else
		lunch = input(src, "Choose a human to devour.", "Lunch") as null|anything in potential_targets
	if(!lunch)
		return FALSE
	if(lunch.getBruteLoss() >= 200)
		to_chat(M, "<span class='warning'>This human's flesh is too mangled to devour!</span>")
		return FALSE
	M.devouring = TRUE
	M.visible_message("<span class='warning'>[M] begins ripping apart and feasting on [lunch]!</span>", \
						"<span class='danger'>We begin to feast upon [lunch]...</span>")
	if(!do_mob(M, 50, target = lunch))
		M.devouring = FALSE
		return FALSE
	M.devouring = FALSE
	M.visible_message("<span class='warning'>[M] tears a chunk from [lunch]'s flesh!</span>", \
						"<span class='danger'>We tear a chunk of flesh from [lunch] and devour it!</span>")
	lunch.adjustBruteLoss(60)
	to_chat(lunch, "<span class='userdanger'>[M] tears into you!</span>")
	var/obj/effect/decal/cleanable/blood/gibs/G = new(get_turf(lunch))
	step(G, pick(GLOB.alldirs)) //Make some gibs spray out for dramatic effect
	playsound(lunch, 'sound/creatures/hit6.ogg', 100, 1)
	if(!lunch.stat)
		lunch.emote("scream")
	M.adjustBruteLoss(-50)

/datum/action/innate/changeling/spine_crawl
	name = "Spine Crawl"
	desc = "We use our spines to gouge into terrain and crawl along it, negating gravity loss. This makes us slower."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "spine"

/datum/action/innate/changeling/spine_crawl/Activate()
	var/mob/living/simple_animal/hostile/true_changeling/M = owner
	if(!istype(M))
		return FALSE
	M.wallcrawl = !M.wallcrawl
	if(M.wallcrawl)
		M.visible_message("<span class='danger'>[M] begins gouging its spines into the terrain!</span>", \
							"<span class='notice'>We begin using our spines for movement.</span>")
		M.speed = 1
	else
		M.visible_message("<span class='danger'>[M] recedes their spines back into their body!</span>", \
							"<span class='notice'>We return moving normally.</span>")
		M.speed = initial(M.speed)

#undef TRUE_CHANGELING_REFORM_THRESHOLD
#undef TRUE_CHANGELING_PASSIVE_HEAL
#undef TRUE_CHANGELING_FORCED_REFORM