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
			V.mind.memory += "<b>Objective #1</b>: [vampire_objective.explanation_text]"
		if("convert")
			var/datum/objective/convert_vampires/vampire_objective = new
			vampire_objective.owner = V.mind
			V.mind.objectives += vampire_objective
			V << "<b>Objective #1:</b> [vampire_objective.explanation_text]"
			V.mind.memory += "<b>Objective #1</b>: [vampire_objective.explanation_text]"


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


/datum/vampire/proc/add_blood(var/blood_amount, var/dirty, var/source = "")
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
	V.grant_vampire_objectives()
	VD.vampire_mob = M
	V << "<span class='userdanger'>Lilith's blessing warps your body... you are a vampire!</span>"
	V << "<b>You are a vampire - a supernatural, nearly-immortal creature nourished by blood. You are physically incapable of death unless certain conditions are met, and you will slowly recuperate all \
	wounds while blood is in your body. However, there are some weaknesses that \ will bypass your immortality. Holy water and consecrated areas will either outright hurt you or at least weaken \
	your powers. Blood is your primary resource, and you are incapable of naturally creating it in your body. Instead, you must steal it from sapient humans. To do this, click on them while targeting the \
	head with an empty hand and harm intent. They will be hypnotized during this \ process, and will not remember the event after it has transpired. It takes several seconds to initiate, and will never \
	fatally drain them of blood. You may distinguish other vampires by examining them.</b>"
	var/datum/martial_art/vampirism/VM = new (null)
	VM.teach(V)
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


/obj/item/weapon/antag_spawner/vampire
	name = "filled glass goblet"
	desc = "It's topped off with what seems to be blood. If one listens closely, they can hear a faint singing..."
	icon = 'icons/obj/vampire.dmi'
	icon_state = "glass_goblet_filled"
	w_class = 2

/obj/item/weapon/antag_spawner/vampire/examine(mob/user)
	..()
	if(is_vampire(user) && used)
		user << "<span class='warning'>If you are powerful enough, you may activate the goblet in your hand to refill it and create more vampires.</span>"

/obj/item/weapon/antag_spawner/vampire/attack_self(mob/user)
	if(!user.mind)
		return 0
	if(is_vampire(user))
		if(!used)
			user << "<span class='warning'>[src] is already full.</span>"
			return
		var/datum/vampire/V = user.get_vampire()
		if(!V)
			return 0
		if(V.sucked_blood < 500) //They need quite a bit of blood
			user << "<span class='warning'>You are not powerful enough to fill the goblet.</span>"
			return 0
		else
			var/mob/living/carbon/human/H = user
			if(V.clean_blood < 50) //50 blood to fill the goblet
				user << "<span class='warning'>You do not possess enough clean blood to fill the goblet.</span>"
				return 0
			user.visible_message("<span class='warning'>[user] cuts their finger on the lip of [src] and begins dripping blood into it...</span>", "<span class='userdanger'>You begin preparing the goblet for conversion of fledgling vampires.</span>")
			H.apply_damage(5, BRUTE, pick("l_arm", "r_arm"))
			if(!do_after(user, 100, target = user))
				return 0
			user.visible_message("<span class='warning'>[user] fills [src] with their own blood!</span>", "<span class='userdanger'>You fill the goblet. You may now create an additional vampire.</span>")
			used = 0
			name = initial(name)
			desc = initial(desc)
			icon_state = initial(icon_state)
		return 1
	if(used)
		user << "<span class='notice'>The goblet is empty.</span>"
		return 0
	if(iscultist(user))
		user << "<span class='warning'>Nar-Sie does not interfere with the business of Lilith. No good can from this.</span>"
		return 0
	if(user.mind.assigned_role == "Chaplain")
		user.visible_message("<span class='warning'>[user] spills the contents of [src] onto the ground!</span>", \
							 "<span class='warning'>The disgusting blood in the goblet reeks of the unholy. You spill it onto the ground.</span>")
		used = 1
		name = "glass goblet"
		desc = "It's an empty glass goblet. It sparkles with a bright sheen."
		icon_state = "glass_goblet"
		return 0
	if(isloyal(user))
		user << "<span class='warning'>Something about the goblet fills you with dread. You can't bring yourself to drink it.</span>"
		return 0
	user.visible_message("<span class='warning'>[user] slowly raises [src] to their lips with a trembling hand...</span>", \
						 "<span class='userdanger'>You slowly lift the goblet to your lips, the haunting song resonating in your ears...</span>")
	if(!do_after(user, 50, target = user))
		return 0
	if(used)
		return 0
	playsound(user, 'sound/items/drink.ogg', 10, 1)
	user.visible_message("<span class='warning'>[user] tips [src] up, spilling the contents into \his mouth.</span>", \
						 "<span class='userdanger'>Something strange and terrifying enters your mind as you drink from the goblet...</span>")
	user << "<font size=1 color='red'>\"The iron has been struck...\"</font>"
	used = 1
	name = "glass goblet"
	desc = "It's an empty glass goblet. It has faint red stains at the bottom."
	icon_state = "glass_goblet"
	spawn(30)
		if(user)
			user.make_mob_into_vampire()

/obj/item/weapon/antag_spawner/vampire/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	if(M == user)
		return attack_self(user)
	if(!is_vampire(user) || used)
		return ..()
	if(is_vampire(M))
		user << "<span class='warning'>[M] has already received Lilith's blessing!</span>"
		return 0
	var/datum/reagent/blood = M.get_blood(M.vessel)
	if(blood.volume > BLOOD_VOLUME_OKAY + 50) //Around the same drained by bloodsucking
		user << "<span class='warning'>[M] requires less blood in their body so that they may hunger for it!</span>"
		return 0
	if(iscultist(M))
		user << "<span class='warning'>[M] has already made a pact with another demon!</span>"
		return 0
	if(isloyal(M))
		user << "<span class='warning'>[M]'s mind is enslaved by corporate bonds!</span>"
		return 0
	if(M.mind && M.mind.assigned_role == "Chaplain")
		user << "<span class='warning'>[M]'s heretical aura wards away Lilith's blessing!</span>"
		return 0
	if(!M.mind || !M.client)
		user << "<span class='warning'>[M] must not be braindead or catatonic!</span>"
		return 0
	M.visible_message("<span class='warning'>[user] brings [src] to [M]'s lips and begins tipping it back!</span>", \
					  "<span class='userdanger'>A haunting song fills your ears as [user] begins forcing you to drink from [src]!</span>")
	if(!do_after(user, 100, target = M))
		return 0
	playsound(user, 'sound/items/drink.ogg', 10, 1)
	M.visible_message("<span class='warning'>[user] feeds [M] the contents of [src]!</span>", \
					  "<span class='userdanger'>Something strange and terrifying enters your mind as you drink from the goblet...</span>")
	user << "<font size=1 color='red'>\"The iron has been struck...\"</font>"
	used = 1
	name = "glass goblet"
	desc = "It's an empty glass goblet. It has faint red stains at the bottom."
	icon_state = "glass_goblet"
	spawn(30)
		if(M)
			M.make_mob_into_vampire()

/obj/item/weapon/antag_spawner/vampire/attack_hand(mob/user)
	if(ishuman(user) && user.mind && user.mind.assigned_role != "Chaplain" && !is_vampire(user) && !used)
		user << "<span class='warning'>The gentle harmony emanating from [src] grows louder for just a moment...</span>"
	..()


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
				A << "<span class='warning'>[D] will yield no more blood.</span>"
				break
			playsound(D, 'sound/effects/drain_blood.ogg', 10, 0)
			D.drip(4) //nyaa~
			D.Stun(1.1) //The .1 is to make sure they don't have a split second of no stun
			if(!D.silent)
				D.silent += 1
			if(D.mind && D.client && !(D.stat == DEAD))
				V.add_blood(1, 0) //1 blood drained for every unit of blood in a human; quite slow
			else
				V.add_blood(1, 1) //If it's braindead, dead in general, or has no mind, give dirty blood instead
			if(D.job && D.job == "Chaplain") //A vampire drinks the chaplain's blood. This kills the vampire.
				A << "<span class='userdanger'>THEIR BLOOD! IT BURNS!</span>"
				A.audible_message("<span class='warning'>[A] screeches in agony and bursts into flames!</span>")
				A.adjust_fire_stacks(3)
				A.IgniteMob()
				A.Stun(1)
				break
		V.draining_blood = 0
		A << "<span class='danger'>[D] will soon forget this event. It would be wise to leave.</span>"
		D << "<span class='userdanger'>...up and away...</span>"
		D.Stun(5)
		D.silent += 5
		spawn(50)
			D << "<span class='userdanger'>You can't recall anything after the sting in your neck... your mind is cloudy...</span>"
		return 1
	else
		return basic_hit(A,D)
	return 1

/datum/round_event_control/create_vampire_goblet
	name = "Create Blood Goblet"
	typepath = /datum/round_event/create_vampire_goblet
	weight = 7
	max_occurrences = 3
	earliest_start = 3600 //5 minutes


/datum/round_event/create_vampire_goblet


/datum/round_event/create_vampire_goblet/start()
	var/mob/living/carbon/human/H = get_vampire_candidate()
	if(!H)
		message_admins("Event attempted to spawn a vampire creation goblet, but could not find any candidates!")
		return 0
	new /obj/item/weapon/antag_spawner/vampire(get_turf(H))
	H << "<span class='userdanger'>You feel a gentle wind as an enticing goblet appears at your feet...</span>"
	H << 'sound/spookoween/ghosty_wind.ogg'


/datum/round_event/create_vampire_goblet/proc/get_vampire_candidate()
	var/list/potential_candidates = list()
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.client && H.mind && !is_vampire(H) && !isloyal(H) && !iscultist(H))
			potential_candidates.Add(H)
	if(potential_candidates.len)
		var/chosen_candidate = pick(potential_candidates)
		return chosen_candidate
	return 0
