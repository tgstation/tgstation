//////////////////The Monster

/mob/living/simple_animal/slaughter
	name = "slaughter demon"
	real_name = "slaughter demon"
	desc = "A large, menacing creature covered in armored black scales."
	speak_emote = list("gurgles")
	emote_hear = list("wails","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/mob.dmi'
	icon_state = "daemon"
	icon_living = "daemon"
	speed = 1
	a_intent = "harm"
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/magic/demon_attack1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	faction = list("slaughter")
	attacktext = "wildly tears into"
	maxHealth = 200
	health = 200
	healable = 0
	environment_smash = 1
	melee_damage_lower = 30
	melee_damage_upper = 30
	see_in_dark = 8
	var/boost = 0
	bloodcrawl = BLOODCRAWL_EAT
	see_invisible = SEE_INVISIBLE_MINIMUM
	var/list/consumed_mobs = list()
	var/playstyle_string = "<B><font size=3 color='red'>You are a slaughter demon,</font> a terrible creature from another realm. You have a single desire: To kill.  \
							You may use the \"Blood Crawl\" ability near blood pools to travel through them, appearing and dissaapearing from the station at will. \
							Pulling a dead or unconscious mob while you enter a pool will pull them in with you, allowing you to feast and regain your health. \
							You move quickly upon leaving a pool of blood, but the material world will soon sap your strength and leave you sluggish. </B>"

/mob/living/simple_animal/slaughter/New()
	..()
	var/obj/effect/proc_holder/spell/bloodcrawl/bloodspell = new
	AddSpell(bloodspell)
	if(istype(loc, /obj/effect/dummy/slaughter))
		bloodspell.phased = 1

/mob/living/simple_animal/slaughter/Life()
	..()
	if(boost<world.time)
		speed = 1
	else
		speed = 0

/mob/living/simple_animal/slaughter/death()
	..(1)
	new /obj/effect/decal/cleanable/blood (get_turf(src))
	var/obj/effect/decal/cleanable/blood/innards = new (get_turf(src))
	innards.icon = 'icons/obj/surgery.dmi'
	innards.icon_state = "innards"
	innards.name = "pile of viscera"
	innards.desc = "A repulsive pile of guts and gore."
	new /obj/item/organ/internal/heart/demon (src.loc)
	playsound(get_turf(src),'sound/magic/demon_dies.ogg', 200, 1)
	visible_message("<span class='danger'>[src] screams in anger as it collapses into a puddle of viscera, its most recent meals spilling out of it.</span>")
	for(var/mob/living/M in consumed_mobs)
		M.loc = get_turf(src)
	ghostize()
	qdel(src)
	return


/mob/living/simple_animal/slaughter/phasein()
	. = ..()
	speed = 0
	boost = world.time + 60


//The loot from killing a slaughter demon - can be consumed to allow the user to blood crawl
/obj/item/organ/internal/heart/demon
	name = "demon heart"
	desc = "Still it beats furiously, emanating an aura of utter hate."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "demon_heart"
	origin_tech = "combat=5;biotech=8"

/obj/item/organ/internal/heart/demon/attack(mob/M, mob/living/carbon/user, obj/target)
	if(M != user)
		return ..()
	user.visible_message("<span class='warning'>[user] raises [src] to their mouth and tears into it with their teeth!</span>", \
						 "<span class='danger'>An unnatural hunger consumes you. You raise [src] your mouth and devour it!</span>")
	playsound(user, 'sound/magic/Demon_consume.ogg', 50, 1)
	for(var/obj/effect/proc_holder/spell/knownspell in user.mind.spell_list)
		if(knownspell.type == /obj/effect/proc_holder/spell/bloodcrawl)
			user <<"<span class='warning'>...and you don't feel any different.</span>"
			qdel(src)
			return
	user.visible_message("<span class='warning'>[user]'s eyes flare a deep crimson!</span>", \
						 "<span class='userdanger'>You feel a strange power seep into your body... you have absorbed the demon's blood-travelling powers!</span>")
	/*for(var/obj/item/organ/internal/O in user.internal_organs)
		if(istype(O, /obj/item/organ/internal/heart))
			O.Remove(user, 1)
			O.loc = get_turf(user)
			qdel(O)*/
	user.drop_item()
	src.Insert(user) //Consuming the heart literally replaces your heart with a demon heart. H A R D C O R E

/obj/item/organ/internal/heart/demon/Insert(mob/living/carbon/M, special = 0)
	..()
	if(M.mind)
		M.mind.AddSpell(new /obj/effect/proc_holder/spell/bloodcrawl(null))

/obj/item/organ/internal/heart/demon/Remove(mob/living/carbon/M, special = 0)
	..()
	if(M.mind)
		M.mind.remove_spell(/obj/effect/proc_holder/spell/bloodcrawl)

/mob/living/simple_animal/slaughter/cult //Summoned as part of the cult objective "Bring the Slaughter"
	name = "harbringer of the slaughter"
	real_name = "harbringer of the slaughter"
	desc = "An awful creature from beyond the realms of madness."
	maxHealth = 500
	health = 500
	melee_damage_upper = 60
	melee_damage_lower = 60
	environment_smash = 3 //Smashes through EVERYTHING - r-walls included
	playstyle_string = "<b><span class='userdanger'>You are a Harbringer of the Slaughter.</span> Brought forth by the servants of Nar-Sie, you have a single purpose: slaughter the heretics \
	who do not worship the Geometer. You may use the ability 'Blood Crawl' near a pool of blood to enter it and become incorporeal. Using the ability again near a blood pool will allow you \
	to emerge from it. You are fast, powerful, and almost invincible. By dragging a dead or unconscious body into a blood pool with you, you will consume it after a time and fully regain \
	your health. You may use the Sense Victims in your Cultist tab to locate a random, living heretic.</span></b>"

/mob/living/simple_animal/slaughter/cult/verb/sense_victims()
	set name = "Sense Victims"
	set desc = "Locates the nearest heretic for annihilation."
	set category = "Cultist"

	var/list/victims = list()
	for(var/mob/living/L in living_mob_list)
		if(!L.stat && !iscultist(L) && L.key && L != usr)
			victims.Add(L)
	if(!victims.len)
		usr << "<span class='warning'>You could not locate any sapient heretics for the Slaughter.</span>"
		return 0
	var/mob/living/victim = pick(victims)
	victim << "<span class='userdanger'>You feel an awful sense of being watched...</span>"
	victim.Stun(3) //HUE
	var/area/A = victim.loc.loc
	if(!A)
		usr << "<span class='warning'>You could not locate any sapient heretics for the Slaughter.</span>"
		return 0
	usr << "<span class='danger'>You sense a terrified soul at [A]. <b>Show them the error of their ways.</b></span>"

/mob/living/simple_animal/slaughter/cult/New()
	..()
	spawn(5)
		var/list/demon_candidates = get_candidates(ROLE_CULTIST)
		if(!demon_candidates.len)
			visible_message("<span class='warning'>[src] disappears in a flash of red light!</span>")
			qdel(src)
			return 0
		var/client/C = pick(demon_candidates)
		var/mob/living/simple_animal/slaughter/cult/S = src
		if(!C)
			visible_message("<span class='warning'>[src] disappears in a flash of red light!</span>")
			qdel(src)
			return 0
		S.key = C.key
		S.mind.assigned_role = "Harbringer of the Slaughter"
		S.mind.special_role = "Harbringer of the Slaugther"
		S << playstyle_string
		S << 'sound/magic/demon_dies.ogg'
		ticker.mode.add_cultist(S.mind)
		var/datum/objective/always_succeed/new_objective = new /datum/objective/always_succeed
		new_objective.owner = S.mind
		new_objective.explanation_text = "Bring forth the Slaughter to the nonbelievers."
		S.mind.objectives += new_objective
		S << "<B>Objective #[1]</B>: [new_objective.explanation_text]"
