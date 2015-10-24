/datum/game_mode
	var/list/datum/mind/vampires = list()

/*
	VAMPIRE PROCS
*/

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
	V.verbs += /mob/living/carbon/human/proc/vampire_sanguine_regeneration
	V.verbs += /mob/living/carbon/human/proc/vampire_accelerated_recovery
	V.verbs += /mob/living/carbon/human/proc/vampire_chiropteran_shapeshift
	V.verbs += /mob/living/carbon/human/proc/vampire_demonic_strength
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
	V.verbs.Remove(/mob/living/carbon/human/proc/teach_vampire_martial_art)
	V.verbs.Remove(/mob/living/carbon/human/proc/vampire_sanguine_regeneration)
	V.verbs.Remove(/mob/living/carbon/human/proc/vampire_accelerated_recovery)
	V.verbs.Remove(/mob/living/carbon/human/proc/vampire_chiropteran_shapeshift)
	V.verbs.Remove(/mob/living/carbon/human/proc/vampire_demonic_strength)
	V << "<span class='userdanger'>You feel Lilith's blessing vanish. Your immortality fades, your hunger ebbs... you are no longer a vampire!</span>"
	M.special_role = null
	V.attack_log += "\[[time_stamp()]\] <font color='red'>Is no longer a vampire!</font>"
	return 1

/*
	MIND DATUM
*/

/datum/vampire //This datum handles stuff specific to the vampire mini-antag
	var/sucked_blood = 25 //The amount of blood a vampire has stolen. Used for objectives and isn't actually counted as blood for abilities and whatnot.
	var/clean_blood = 25 //The good stuff! Wholesome food for the growing vampire.
	var/dirty_blood = 0 //Works as blood, but we won't like it. Always prioritized lower than clean blood.
	var/draining_blood = 0 //Are we currently draining blood?
	var/fast_heal = 0 //Is passive regeneration speed tripled?
	var/stun_reduction = 0 //Is stun reduction active?
	var/bat_form = 0 //Are we a bat?
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

/*
	GAME MODE FILES
*/

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

/*
	MARTIAL ART
*/

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
			D << "<span class='userdanger'>Your mind is cloudy... your neck hurts and you can't remember what caused it.</span>"
		return 1
	else
		return basic_hit(A,D)
	return 1

/*
	VAMPIRE ABILITIES
*/

//Recall Thirst: Re-teaches the vampire martial art so vampires who forget how to drain people can once again do so.
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
	return 1

//Sanguine Regeneration: Triples healing over time but increases passive blood use.
/mob/living/carbon/human/proc/vampire_sanguine_regeneration()
	set name = "Sanguine Regeneration (Toggle)"
	set desc = "Increases your passive healing ability. Costs 2 cl of clean blood per second or 6 dirty blood per second."
	set category = "Vampirism"

	if(!is_vampire(usr))
		usr << "<span class='warning'>The knowledge slips away as you try to grasp it...</span>"
		usr.verbs -= src
		return 0

	var/datum/vampire/V = usr.get_vampire()
	var/mob/living/carbon/human/user = usr
	V.fast_heal = !V.fast_heal
	user << "[V.fast_heal ? "<span class='danger'>You begin harnessing your blood to heal your wounds.</span>" : "<span class='danger'>You relax your body's frantic regeneration.</span>"]"
	return 1

//Accelerated Recovery: Quickly reduces stuns but increases passive blood use.
/mob/living/carbon/human/proc/vampire_accelerated_recovery()
	set name = "Accelerated Recovery (Toggle)"
	set desc = "Dramatically increases stun recovery rate. Costs 3 cl of clean blood per second or 9 dirty blood per second."
	set category = "Vampirism"

	if(!is_vampire(usr))
		usr << "<span class='warning'>The knowledge slips away as you try to grasp it...</span>"
		usr.verbs -= src
		return 0

	var/datum/vampire/V = usr.get_vampire()
	var/mob/living/carbon/human/user = usr
	V.stun_reduction = !V.stun_reduction
	user << "[V.stun_reduction ? "<span class='danger'>You begin harnessing your blood to empower your metabolism.</span>" : "<span class='danger'>You relax your body's coursing adrenaline.</span>"]"
	return 1

//Chiropteran Shapeshift: Transforms the vampire into a quick, ventcrawling bat. Return to a normal human at will. Death as a bat or manual cancel revert them to their normal form and stun them.
/mob/living/carbon/human/proc/vampire_chiropteran_shapeshift()
	set name = "Chiropteran Shapeshift (100cl)"
	set desc = "Allows you to morph into a swift bat, capable of using ventilation shafts for movement and passing through creatures. You may revert at will. Costs 100 clean blood or 300 dirty blood."
	set category = "Vampirism"

	if(!is_vampire(usr))
		usr << "<span class='warning'>The knowledge slips away as you try to grasp it...</span>"
		usr.verbs -= src
		return 0

	var/datum/vampire/V = usr.get_vampire()
	var/mob/living/carbon/human/user = usr
	if(!V.use_blood(100, 0))
		if(!V.use_blood(300, 0))
			user << "<span class='warning'>You don't have the blood to give yourself strength!</span>"
			return 0
	user.visible_message("<span class='warning'>[user]'s body suddenly twists and contorts into a chiropteran form!</span>")
	if(user.handcuffed)
		user.unEquip(user.handcuffed)
	user.status_flags |= GODMODE //To prevent them from taking damage while in the bat
	var/mob/living/simple_animal/hostile/retaliate/bat/vampiric/VB = new(get_turf(user))
	user.mind.transfer_to(VB)
	user.loc = VB
	VB.stored_human = user
	V.bat_form = 1

/mob/living/simple_animal/hostile/retaliate/bat/vampiric
	name = "vampire bat"
	desc = "A vicious-looking animal whose eyes glow with a peculiar intelligence."
	maxHealth = 40 //Pretty fragile, but can still tank a few hits
	health = 40
	see_in_dark = 10
	harm_intent_damage = 10
	speed = -1 //gotta go fast
	var/mob/living/carbon/human/stored_human //The vampire who is controlling the bat

/mob/living/simple_animal/hostile/retaliate/bat/vampiric/Stat()
	..()
	if(statpanel("Status"))
		if(mind)
			if(mind.vampire)
				stat("Total Blood Stolen", "[mind.vampire.sucked_blood]cl")
				stat("Clean Blood", "[mind.vampire.clean_blood]cl")
				stat("Dirty Blood", "[mind.vampire.dirty_blood]cl")

				stat("Sanguine Regeneration", "[mind.vampire.fast_heal ? "ON" : "OFF"]")
				stat("Accelerated Recovery", "[mind.vampire.stun_reduction ? "ON" : "OFF"]")

/mob/living/simple_animal/hostile/retaliate/bat/vampiric/Process_Spacemove(movement_dir = 0)
	return 1	//No drifting in space for space carp!	//original comments do not steal	//i did it anyway faggot

/mob/living/simple_animal/hostile/retaliate/bat/vampiric/death()
	..(1)
	if(stored_human && is_vampire(src))
		var/datum/vampire/V = get_vampire()
		visible_message("<span class='warning'>[src]'s body suddenly contorts and expands into a humanoid form!</span>")
		stored_human.loc = get_turf(src)
		if(mind)
			mind.transfer_to(stored_human)
		stored_human.status_flags &= ~GODMODE
		stored_human.Paralyse(5)
		V.bat_form = 0
		qdel(src)

/mob/living/simple_animal/hostile/retaliate/bat/vampiric/AttackingTarget()
	..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.stat != DEAD && is_vampire(src))
			var/datum/vampire/V = get_vampire()
			src << "<span class='warning'>You drain some blood along with the bite!</span>"
			H.drip(3)
			V.add_blood(3, 0) //If a vampire bites a living human, add 3 clean blood in addition to the damage!

/mob/living/simple_animal/hostile/retaliate/bat/vampiric/verb/turn_to_human()
	set name = "Human Form"
	set desc = "Transform yourself back into a human."
	set category = "Vampirism"

	if(!stored_human)
		usr << "<span class='warning'>You aren't a human to begin with!</span>"
		return 0

	death() //Dying is how they turn back

//Demonic Strength: Allows you to snap out of restraints. Costs 50 clean blood or 150 dirty blood.
/mob/living/carbon/human/proc/vampire_demonic_strength()
	set name = "Demonic Strength (50cl)"
	set desc = "Allows you to break free of handcuffs. Costs 50 cl of clean blood or 150 cl of dirty blood."
	set category = "Vampirism"

	if(!is_vampire(usr))
		usr << "<span class='warning'>The knowledge slips away as you try to grasp it...</span>"
		usr.verbs -= src
		return 0

	var/datum/vampire/V = usr.get_vampire()
	var/mob/living/carbon/human/user = usr
	if(!user.handcuffed)
		if(user.restrained())
			user << "<span class='warning'>You aren't capable of breaking out of that type of restraint!</span>"
		else
			user << "<span class='warning'>You aren't handcuffed!</span>"
		return 0
	var/obj/H = user.get_item_by_slot(slot_handcuffed)
	if(!V.use_blood(50, 1))
		if(!V.use_blood(150, 0))
			user << "<span class='warning'>You don't have the blood to give yourself strength!</span>"
			return 0
	user.visible_message("<span class='warning'>[user] snaps [H] and frees themself in a surge of strength!</span>", \
						 "<span class='danger'>You feel dark strength surge through you and snap through [H] around your wrists!</span>")
	playsound(user, 'sound/effects/snap.ogg', 100, 0)
	user.unEquip(H)
	qdel(H)
	return 1
