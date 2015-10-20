/datum/game_mode
	var/list/datum/mind/vampires = list()


/mob/proc/make_mob_into_vampire() //For easy calling on mobs
	if(make_vampire(src))
		return 1
	return 0


/mob/proc/remove_vampire_from_mob() //For easy calling on mobs, again
	if(remove_vampire(src))
		return 1
	return 0


/mob/proc/grant_vampire_objectives()
	if(!is_vampire(src) || !ishuman(src))
		return 0
	var/mob/living/carbon/human/V = src
	var/list/possible_objectives = list("steal blood", "convert")
	var/chosen_objective = pick(possible_objectives)
	switch(chosen_objective)
		if("steal blood")
			var/datum/objective/suck_blood/vampire_objective = new
			vampire_objective.owner = V.mind
			V.mind.objectives += vampire_objective
			V << "<b>Objective #1:</b> [vampire_objective.explanation_text]"
		if("convert")
			var/datum/objective/convert_vampires/vampire_objective = new
			vampire_objective.owner = V.mind
			V.mind.objectives += vampire_objective
			V << "<b>Objective #1:</b> [vampire_objective.explanation_text]"


/proc/is_vampire(var/mob/living/M)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.vampires)


/proc/change_vampire_state(var/mob/living/M, var/remove)
	if(!M || !istype(M))
		return 0
	if(!remove)
		ticker.mode.vampires += M.mind
	else
		ticker.mode.vampires.Remove(M.mind)
	return 1


/datum/vampire //This datum handles stuff specific to the vampire mini-antag
	var/sucked_blood = 25 //The amount of blood a vampire has stolen. Used for objectives and isn't actually counted as blood for abilities and whatnot.
	var/clean_blood = 25 //The good stuff! Wholesome food for the growing vampire.
	var/dirty_blood = 0 //Works as blood, but we won't like it. Always prioritized lower than clean blood.
	var/draining_blood = 0 //Are we currently draining blood?
	var/mob/living/vampire_mob //The vampire datum's holder.


/datum/vampire/New()
	..()
	spawn(5)
		if(!vampire_mob) //If there's no holder for the datum, just delete it
			qdel(src)


/datum/vampire/proc/add_blood(var/blood_amount, var/dirty, var/source)
	if(dirty)
		dirty_blood += blood_amount
	else
		clean_blood += blood_amount
	sucked_blood += blood_amount
	if(source)
		vampire_mob << "<span class='danger'>Gained [dirty ? "dirty" : "clean"] blood from [source].</span>"
	return 1


/datum/vampire/proc/use_blood(var/blood_amount, var/clean_only)
	if(blood_amount == 0)
		return 1
	if(clean_blood && (clean_blood - blood_amount >= 0))
		clean_blood -= blood_amount
		return 1
	else if(dirty_blood && (dirty_blood - blood_amount >= 0) && !clean_only)
		dirty_blood -= (blood_amount * 2) //Dirty blood uses up twice as much as clean blood
		return 1
	else
		return 0 //No blood remaining. Bad things for the vampire.


/mob/proc/get_vampire()
	if(!mind && !mind.vampire)
		return 0
	return mind.vampire


/proc/make_vampire(var/mob/living/carbon/human/V)
	if(!V || !istype(V) || !V.mind) //Only works on humans that aren't braindead
		return 0
	var/datum/mind/M = V.mind
	if(!change_vampire_state(V, 0))
		return 0
	var/datum/vampire/VD = new (M)
	M.vampire = VD
	M.special_role = "Vampire"
	VD.vampire_mob = M
	V.verbs += /mob/living/carbon/human/proc/teach_vampire_martial_art
	V << "<span class='userdanger'>Lilith's blessing warps your body... you are a vampire!</span>"
	V << "<b>You are a vampire - a supernatural, nearly-immortal creature nourished by blood. You are physically incapable of death unless certain conditions are met, and you will slowly recuperate all \
	wounds while blood is in your body. However, there are some weaknesses that \ will bypass your immortality. Holy water and consecrated areas will either outright hurt you or at least weaken \
	your powers. Blood is your primary resource, and you are incapable of naturally creating it in your body. Instead, you must steal it from sapient humans. To do this, click on them while targeting the \
	head with an empty hand and harm intent. They will be hypnotized during this \ process, and will not remember the event after it has transpired. It takes several seconds to initiate, and will never \
	fatally drain them of blood. You may distinguish other vampires by examining them.</b>"
	var/datum/martial_art/vampirism/VM = new (null)
	VM.teach(V)
	V.grant_vampire_objectives()
	return 1


/proc/remove_vampire(var/mob/living/carbon/human/V)
	if(!V || !istype(V) || !V.mind) //Only works on humans that aren't braindead
		return 0
	var/datum/mind/M = V.mind
	if(!change_vampire_state(V, 1))
		return 0
	if(M.vampire)
		qdel(M.vampire)
		M.vampire = null
	else
		return 0
	V.verbs -= /mob/living/carbon/human/proc/teach_vampire_martial_art
	V << "<span class='userdanger'>You feel Lilith's blessing vanish. Your immortality fades, your hunger ebbs... you are no longer a vampire!</span>"
	M.special_role = null
	V.attack_log += "\[[time_stamp()]\] <font color='red'>Is no longer a vampire!</font>"
	return 1


/datum/game_mode/vampire //I know this is in a bad spot - gamemode code is archaic - but there's no better place for it.
	name = "vampire"
	config_tag = "vampire"
	antag_flag = BE_TRAITOR //Side-antagonist
	required_players = 1 //They're non-lethal
	required_enemies = 1
	recommended_enemies = 2
	restricted_jobs = list("AI", "Cyborg", "Chaplain") //Holy men can NEVER be vampires.
	protected_jobs = list("Security Officer", "Warden", "Head of Security", "Captain")


/datum/game_mode/vampire/announce()
	world << "<b>The current game mode is - Vampire!</b>"
	world << "<b>Some of the crew have made a pact with otherworldy forces and became bloodsucking <span class='boldannounce'>vampires</span>!</b>"
	world << "<b>Vampires: Suck the blood from unsuspecting people and grow in power!</b>"
	world << "<b>Crew: Find and destroy the vampires with their weaknesses.</b>"


/datum/game_mode/vampire/pre_setup() //Will only ever assign 1 or 2 vampires because this is a SIDE ANTAG.
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"

	var/vampires_to_spawn = rand(1,2)
	while(vampires_to_spawn)
		var/datum/mind/vampire_mind = pick(antag_candidates)
		vampires += vampire_mind
		antag_candidates -= vampire_mind
		modePlayer += vampire_mind
		vampire_mind.special_role = "Vampire"
		vampire_mind.restricted_roles = restricted_jobs
		vampires_to_spawn--
	return 1


/datum/game_mode/vampire/post_setup()
	for(var/datum/mind/vampire in vampires)
		log_game("[vampire.key] (ckey) has been selected as a vampire.")
		make_vampire(vampire.current)
	..()
	return


/datum/objective/suck_blood
	dangerrating = 10
	var/targetAmount = 5000

/datum/objective/suck_blood/New()
	targetAmount = pick(500,525,550,575,600)
	explanation_text = "Consume [targetAmount] units of blood."
	..()

/datum/objective/suck_blood/check_completion()
	if(!istype(owner.current, /mob/living/carbon/human))
		return 0
	var/mob/living/carbon/human/H = owner.current
	if(!H || H.stat == DEAD)
		return 0
	if(!is_vampire(H))
		return 0
	var/blood_drunk = 0
	for(var/datum/vampire/V in H.mind)
		blood_drunk += V.sucked_blood
	if(blood_drunk < targetAmount)
		return 0
	return 1


/datum/objective/convert_vampires
	dangerrating = 20
	var/targetAmount = 3

/datum/objective/convert_vampires/New()
	targetAmount = rand(2,4)
	explanation_text = "Become powerful enough to create new vampires and ensure there are at least [targetAmount] vampires when the shuttle arrives."
	..()

/datum/objective/convert_vampires/check_completion()
	if(!istype(owner.current, /mob/living/carbon/human))
		return 0
	var/mob/living/carbon/human/H = owner.current
	if(!H || H.stat == DEAD)
		return 0
	if(!is_vampire(H))
		return 0
	var/existing_vampires = 0
	for(var/mob/living/L in living_mob_list)
		if(is_vampire(L))
			existing_vampires++
	if(existing_vampires >= targetAmount)
		return 1
	return 0


/datum/game_mode/proc/auto_declare_completion_vampire()
	var/text = ""
	if(vampires.len)
		text += "<br><span class='big'><b>The vampires were:</b></span>"
		for(var/datum/mind/vampire in vampires)
			text += printplayer(vampire)
	text += "<br>"
	world << text


/datum/martial_art/vampirism //Used for draining blood
	name = "Vampiric Thirst"

/datum/martial_art/vampirism/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(is_vampire(A) && A.a_intent == "harm" && A.zone_sel.selecting == "head" && !is_vampire(D)) //Allows vampires to drain blood from people. Takes quite a while though!
		if(!A.mind || (A.mind && !A.mind.vampire))
			return ..()
		var/datum/vampire/V = A.mind.vampire
		if(V.draining_blood)
			return 1
		A.visible_message("<span class='warning'>[A] starts leaning toward [D]'s neck...</span>")
		if(!do_after(A, 20, target = D))
			return 1
		if(V.draining_blood)
			return 1
		V.draining_blood = 1
		A.visible_message("<span class='warning'><b>[A] starts draining the blood from [D]!</b></span>", "<span class='danger'>You begin draining [D]'s blood. You will need to be still.</span>")
		D << "<span class='userdanger'>You suddenly feel queasy and docile...</span>"
		while(A.Adjacent(D))
			if(!do_after(A, 10, target = D)) //This happens every second, and makes sure the vampire stays near their target and doesn't move at all. This shows as really fast progress bars, though.
				break
			var/datum/reagent/blood = D.get_blood(D.vessel)
			if(blood.volume < BLOOD_VOLUME_OKAY + 25) //Never fatally drains them
				A << "<span class='warning'>[D] will yield no more blood. They will soon forget this event - it would be wise to leave.</span>"
				break
			playsound(D, 'sound/effects/drain_blood.ogg', 10, 0)
			D.drip(4) //Blood droplets on the floor - signifies where it happened
			D.Stun(1.1) //The .1 is to make sure they don't have a split second of no stun
			if(!D.silent)
				D.silent += 1
			if(D.mind && D.client && !(D.stat == DEAD))
				V.add_blood(4, 0) //1 blood drained for every unit of blood in a human; quite slow
			else
				V.add_blood(4, 1) //If it's braindead, dead in general, or has no mind, give dirty blood instead
			if(D.job && D.job == "Chaplain") //A vampire drinks the chaplain's blood. This kills the vampire.
				A << "<span class='userdanger'>THEIR BLOOD! IT BURNS!</span>"
				A.audible_message("<span class='warning'>[A] screeches in agony and bursts into flames!</span>")
				A.adjust_fire_stacks(3)
				A.IgniteMob()
				A.Stun(1)
				break
		V.draining_blood = 0
		D << "<span class='userdanger'>...up and away...</span>"
		D.Stun(5)
		D.silent += 5
		spawn(50)
			D << "<span class='userdanger'>You can't recall anything after the sting in your neck... your mind is cloudy...</span>"
		return 1
	else
		return basic_hit(A,D)
	return 1


/mob/living/carbon/human/proc/teach_vampire_martial_art() //In case another martial art overrides the blood-draining one
	set name = "Recall Thirst"
	set desc = "Recall how to drain blood from humans. Use if you suddenly cannot do so."
	set category = "Vampirism"

	if(!is_vampire(usr))
		usr << "<span class='warning'>The knowledge slips away as you try to grasp it...</span>"
		usr.verbs -= src
		return 0

	usr << "<span class='danger'>You recall how to drain blood from humans. If you forget how to do so, use this ability again.</span>"
	var/datum/martial_art/vampirism/VM = new (null)
	VM.teach(usr)
