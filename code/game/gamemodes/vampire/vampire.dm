//This is the gamemode file for the ported goon gamemode vampires.
//They get a traitor objective and a blood sucking objective
/datum/game_mode
	var/list/datum/mind/vampires = list()
	var/list/datum/mind/enthralled = list() //those controlled by a vampire
	var/list/thralls = list() //vammpires controlling somebody
/datum/game_mode/vampire
	name = "vampire"
	config_tag = "vampire"
	restricted_jobs = list("AI", "Cyborg", "Mobile MMI", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Chaplain") //Consistent screening has filtered all infiltration attempts on high value jobs
	protected_jobs = list()
	required_players = 1
	required_players_secret = 15
	required_enemies = 2
	recommended_enemies = 4

	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 10

	var/const/prob_int_murder_target = 50 // intercept names the assassination target half the time
	var/const/prob_right_murder_target_l = 25 // lower bound on probability of naming right assassination target
	var/const/prob_right_murder_target_h = 50 // upper bound on probability of naimg the right assassination target

	var/const/prob_int_item = 50 // intercept names the theft target half the time
	var/const/prob_right_item_l = 25 // lower bound on probability of naming right theft target
	var/const/prob_right_item_h = 50 // upper bound on probability of naming the right theft target

	var/const/prob_int_sab_target = 50 // intercept names the sabotage target half the time
	var/const/prob_right_sab_target_l = 25 // lower bound on probability of naming right sabotage target
	var/const/prob_right_sab_target_h = 50 // upper bound on probability of naming right sabotage target

	var/const/prob_right_killer_l = 25 //lower bound on probability of naming the right operative
	var/const/prob_right_killer_h = 50 //upper bound on probability of naming the right operative
	var/const/prob_right_objective_l = 25 //lower bound on probability of determining the objective correctly
	var/const/prob_right_objective_h = 50 //upper bound on probability of determining the objective correctly

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/vampire_amount = 4


/datum/game_mode/vampire/announce()
	world << "<B>The current game mode is - Vampires!</B>"
	world << "<B>There are Vampires from Space Transylvania on the station, keep your blood close and neck safe!</B>"

/datum/game_mode/vampire/pre_setup()
	// mixed mode scaling
	if(istype(ticker.mode, /datum/game_mode/mixed))
		mixed = 1
	if(mixed)
		recommended_enemies = 2
		required_enemies = 1
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_vampires = get_players_for_role(BE_VAMPIRE)

	for(var/datum/mind/player in possible_vampires)
		for(var/job in restricted_jobs)//Removing robots from the list
			if(player.assigned_role == job)
				possible_vampires -= player

	vampire_amount = min(recommended_enemies, max(required_enemies,round(num_players() / 10))) //1 + round(num_players() / 10)

	if(possible_vampires.len>0)
		for(var/i = 0, i < vampire_amount, i++)
			if(!possible_vampires.len) break
			var/datum/mind/vampire = pick(possible_vampires)
			possible_vampires -= vampire
			if(vampire.special_role) continue
			vampires += vampire
			modePlayer += vampires
		return 1
	else
		return 0

/datum/game_mode/vampire/post_setup()
	for(var/datum/mind/vampire in vampires)
		grant_vampire_powers(vampire.current)
		vampire.special_role = "Vampire"
		forge_vampire_objectives(vampire)
		greet_vampire(vampire)
	if(!mixed)
		spawn (rand(waittime_l, waittime_h))
			send_intercept()
	..()
	return

/datum/game_mode/proc/auto_declare_completion_vampire()
	testing("VAMPIRE GAMEMODE END CALL")
	if(vampires.len)
		testing("VAMP HAS LENGTH")
		var/text = "<FONT size = 2><B>The vampires were:</B></FONT>"
		for(var/datum/mind/vampire in vampires)
			var/traitorwin = 1

			text += "<br>[vampire.key] was [vampire.name] ("
			if(vampire.current)
				if(vampire.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(vampire.current.real_name != vampire.name)
					text += " as [vampire.current.real_name]"
			else
				text += "body destroyed"
			text += ")"

			if(vampire.objectives.len)//If the traitor had no objectives, don't need to process this.
				var/count = 1
				for(var/datum/objective/objective in vampire.objectives)
					if(objective.check_completion())
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
						feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
					else
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
						feedback_add_details("traitor_objective","[objective.type]|FAIL")
						traitorwin = 0
					count++

			var/special_role_text
			if(vampire.special_role)
				special_role_text = lowertext(vampire.special_role)
			else
				special_role_text = "antagonist"

			if(traitorwin)
				text += "<br><font color='green'><B>The [special_role_text] was successful!</B></font>"
				feedback_add_details("traitor_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The [special_role_text] has failed!</B></font>"
				feedback_add_details("traitor_success","FAIL")
		world << text
	else
		testing("VAMP HAS NO LENGTH")
	return 1

/datum/game_mode/proc/auto_declare_completion_enthralled()
	if(enthralled.len)
		var/text = "<FONT size = 2><B>The Enthralled were:</B></FONT>"
		for(var/datum/mind/Mind in enthralled)
			text += "<br>[Mind.key] was [Mind.name] ("
			if(Mind.current)
				if(Mind.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(Mind.current.real_name != Mind.name)
					text += " as [Mind.current.real_name]"
			else
				text += "body destroyed"
			text += ")"
		world << text
	return 1

/datum/game_mode/proc/forge_vampire_objectives(var/datum/mind/vampire)
	//Objectives are traitor objectives plus blood objectives

	var/datum/objective/blood/blood_objective = new
	blood_objective.owner = vampire
	blood_objective.gen_amount_goal(150, 400)
	vampire.objectives += blood_objective

	var/datum/objective/assassinate/kill_objective = new
	kill_objective.owner = vampire
	kill_objective.find_target()
	vampire.objectives += kill_objective

	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = vampire
	steal_objective.find_target()
	vampire.objectives += steal_objective


	switch(rand(1,100))
		if(1 to 80)
			if (!(locate(/datum/objective/escape) in vampire.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = vampire
				vampire.objectives += escape_objective
		else
			if (!(locate(/datum/objective/survive) in vampire.objectives))
				var/datum/objective/survive/survive_objective = new
				survive_objective.owner = vampire
				vampire.objectives += survive_objective
	return

/datum/game_mode/proc/grant_vampire_powers(mob/living/carbon/vampire_mob)
	if(!istype(vampire_mob))	return
	vampire_mob.make_vampire()

/datum/game_mode/proc/greet_vampire(var/datum/mind/vampire, var/you_are=1)
	var/dat
	if (you_are)
		dat = "<B>\red You are a Vampire! \black</br></B>"
	dat += {"To bite someone, target the head and use harm intent with an empty hand. Drink blood to gain new powers.
You are weak to holy things and starlight. Don't go into space and avoid the Chaplain, the chapel and especially Holy Water."}
	vampire.current << dat
	vampire.current << "<B>You must complete the following tasks:</B>"

	if (vampire.current.mind)
		if (vampire.current.mind.assigned_role == "Clown")
			vampire.current << "Your lust for blood has allowed you to overcome your clumsy nature allowing you to wield weapons without harming yourself."
			vampire.current.mutations.Remove(M_CLUMSY)

	var/obj_count = 1
	for(var/datum/objective/objective in vampire.objectives)
		vampire.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return

/datum/vampire
	var/bloodtotal = 0 // CHANGE TO ZERO WHEN PLAYTESTING HAPPENS
	var/bloodusable = 0 // CHANGE TO ZERO WHEN PLAYTESTING HAPPENS
	var/mob/living/owner = null
	var/gender = FEMALE
	var/iscloaking = 0 // handles the vampire cloak toggle
	var/list/powers = list() // list of available powers and passives, see defines in setup.dm
	var/mob/living/carbon/human/draining // who the vampire is draining of blood
	var/nullified = 0 //Nullrod makes them useless for a short while.
/datum/vampire/New(gend = FEMALE)
	gender = gend

/mob/proc/make_vampire()
	if(!mind)				return
	if(!mind.vampire)
		mind.vampire = new /datum/vampire(gender)
		mind.vampire.owner = src
	verbs += /client/proc/vampire_rejuvinate
	verbs += /client/proc/vampire_hypnotise
	verbs += /client/proc/vampire_glare
	//testing purposes REMOVE BEFORE PUSH TO MASTER
	/*for(var/handler in typesof(/client/proc))
		if(findtext("[handler]","vampire_"))
			verbs += handler*/
	for(var/i = 1; i <= 3; i++) // CHANGE TO 3 RATHER THAN 12 AFTER TESTING IS DONE
		if(!(i in mind.vampire.powers))
			mind.vampire.powers.Add(i)


	for(var/n in mind.vampire.powers)
		switch(n)
			if(VAMP_SHAPE)
				verbs += /client/proc/vampire_shapeshift
			if(VAMP_VISION)
				continue
			if(VAMP_DISEASE)
				verbs += /client/proc/vampire_disease
			if(VAMP_CLOAK)
				verbs += /client/proc/vampire_cloak
			if(VAMP_BATS)
				verbs += /client/proc/vampire_bats
			if(VAMP_SCREAM)
				verbs += /client/proc/vampire_screech
			if(VAMP_JAUNT)
				verbs += /client/proc/vampire_jaunt
			if(VAMP_BLINK)
				verbs += /client/proc/vampire_shadowstep
			if(VAMP_SLAVE)
				verbs += /client/proc/vampire_enthrall
			if(VAMP_FULL)
				continue
/mob/proc/remove_vampire_powers()
	for(var/handler in typesof(/client/proc))
		if(findtext("[handler]","vampire_"))
			verbs -= handler

/mob/proc/handle_bloodsucking(mob/living/carbon/human/H)
	src.mind.vampire.draining = H
	var/blood = 0
	var/bloodtotal = 0 //used to see if we increased our blood total
	var/bloodusable = 0 //used to see if we increased our blood usable
	src.attack_log += text("\[[time_stamp()]\] <font color='red'>Bit [H.name] ([H.ckey]) in the neck and draining their blood</font>")
	H.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been bit in the neck by [src.name] ([src.ckey])</font>")
	log_attack("[src.name] ([src.ckey]) bit [H.name] ([H.ckey]) in the neck")
	src.visible_message("\red <b>[src.name] bites [H.name]'s neck!<b>", "\red <b>You bite [H.name]'s neck and begin to drain their blood.", "\blue You hear a soft puncture and a wet sucking noise")
	if(!iscarbon(src))
		H.LAssailant = null
	else
		H.LAssailant = src
	while(do_mob(src, H, 50))
		if(!mind.vampire || !(mind in ticker.mode.vampires))
			src << "\red Your fangs have disappeared!"
			return 0
		if(H.flags & NO_BLOOD)
			src << "<span class='warning'>Not a drop of blood here</span>"
			return 0
		bloodtotal = src.mind.vampire.bloodtotal
		bloodusable = src.mind.vampire.bloodusable
		if(!H.vessel.get_reagent_amount("blood"))
			src << "\red They've got no blood left to give."
			break
		if(H.stat < 2) //alive
			blood = min(10, H.vessel.get_reagent_amount("blood"))// if they have less than 10 blood, give them the remnant else they get 10 blood
			src.mind.vampire.bloodtotal += blood
			src.mind.vampire.bloodusable += blood
			H.adjustCloneLoss(10) // beep boop 10 damage
		else
			blood = min(5, H.vessel.get_reagent_amount("blood"))// The dead only give 5 bloods
			src.mind.vampire.bloodtotal += blood
		if(bloodtotal != src.mind.vampire.bloodtotal)
			src << "\blue <b>You have accumulated [src.mind.vampire.bloodtotal] [src.mind.vampire.bloodtotal > 1 ? "units" : "unit"] of blood[src.mind.vampire.bloodusable != bloodusable ?", and have [src.mind.vampire.bloodusable] left to use" : "."]"
		check_vampire_upgrade(mind)
		H.vessel.remove_reagent("blood",25)

	src.mind.vampire.draining = null
	src << "\blue You stop draining [H.name] of blood."
	return 1

/mob/proc/check_vampire_upgrade(datum/mind/v)
	if(!v) return
	if(!v.vampire) return
	var/datum/vampire/vamp = v.vampire
	var/list/old_powers = vamp.powers.Copy()

	// This used to be a switch statement.
	// Don't use switch statements for shit like this, since blood can be any random-ass value.
	// if(100) requires the blood to be at EXACTLY 100 units to trigger.
	// if(blud >= 100) activates when blood is at or over 100 units.
	// TODO: Make this modular.

	// TIER 1
	if(vamp.bloodtotal >= 100)
		if(!(VAMP_VISION in vamp.powers))
			vamp.powers.Add(VAMP_VISION)
		if(!(VAMP_SHAPE in vamp.powers))
			vamp.powers.Add(VAMP_SHAPE)

	// TIER 2
	if(vamp.bloodtotal >= 150)
		if(!(VAMP_CLOAK in vamp.powers))
			vamp.powers.Add(VAMP_CLOAK)
		if(!(VAMP_DISEASE in vamp.powers))
			vamp.powers.Add(VAMP_DISEASE)

	// TIER 3
	if(vamp.bloodtotal >= 200)
		if(!(VAMP_BATS in vamp.powers))
			vamp.powers.Add(VAMP_BATS)
		if(!(VAMP_SCREAM in vamp.powers))
			vamp.powers.Add(VAMP_SCREAM)
		// Commented out until we can figured out a way to stop this from spamming.
		//src << "\blue Your rejuvination abilities have improved and will now heal you over time when used."

	// TIER 3.5 (/vg/)
	if(vamp.bloodtotal >= 250)
		if(!(VAMP_BLINK in vamp.powers))
			vamp.powers.Add(VAMP_BLINK)

	// TIER 4
	if(vamp.bloodtotal >= 300)
		if(!(VAMP_JAUNT in vamp.powers))
			vamp.powers.Add(VAMP_JAUNT)
		if(!(VAMP_SLAVE in vamp.powers))
			vamp.powers.Add(VAMP_SLAVE)

	// TIER 5
	if(vamp.bloodtotal >= 500)
		if(!(VAMP_FULL in vamp.powers))
			vamp.powers.Add(VAMP_FULL)

	announce_new_power(old_powers, vamp.powers)

/mob/proc/announce_new_power(list/old_powers, list/new_powers)
	for(var/n in new_powers)
		if(!(n in old_powers))
			switch(n)
				if(VAMP_SHAPE)
					src << "\blue You have gained the shapeshifting ability, at the cost of stored blood you can change your form permanently."
					verbs += /client/proc/vampire_shapeshift
				if(VAMP_VISION)
					src << "\blue Your vampiric vision has improved."
					//no verb
				if(VAMP_DISEASE)
					src << "\blue You have gained the Diseased Touch ability which causes those you touch to die shortly after unless treated medically."
					verbs += /client/proc/vampire_disease
				if(VAMP_CLOAK)
					src << "\blue You have gained the Cloak of Darkness ability which when toggled makes you near invisible in the shroud of darkness."
					verbs += /client/proc/vampire_cloak
				if(VAMP_BATS)
					src << "\blue You have gained the Summon Bats ability."
					verbs += /client/proc/vampire_bats // work in progress
				if(VAMP_SCREAM)
					src << "\blue You have gained the Chriopteran Screech ability which stuns anything with ears in a large radius and shatters glass in the process."
					verbs += /client/proc/vampire_screech
				if(VAMP_JAUNT)
					src << "\blue You have gained the Mist Form ability which allows you to take on the form of mist for a short period and pass over any obstacle in your path."
					verbs += /client/proc/vampire_jaunt
				if(VAMP_SLAVE)
					src << "\blue You have gained the Enthrall ability which at a heavy blood cost allows you to enslave a human that is not loyal to any other for a random period of time."
					verbs += /client/proc/vampire_enthrall
				if(VAMP_BLINK)
					src << "\blue You have gained the ability to shadowstep, which makes you disappear into nearby shadows at the cost of blood."
					verbs += /client/proc/vampire_shadowstep
				if(VAMP_FULL)
					src << "\blue You have reached your full potential and are no longer weak to the effects of anything holy and your vision has been improved greatly."
					//no verb
//prepare for copypaste
/datum/game_mode/proc/update_vampire_icons_added(datum/mind/vampire_mind)
	var/ref = "\ref[vampire_mind]"
	if(ref in thralls)
		if(vampire_mind.current)
			if(vampire_mind.current.client)
				var/I = image('icons/mob/mob.dmi', loc = vampire_mind.current, icon_state = "vampire")
				vampire_mind.current.client.images += I
	for(var/headref in thralls)
		for(var/datum/mind/t_mind in thralls[headref])
			var/datum/mind/head = locate(headref)
			if(head)
				if(head.current)
					if(head.current.client)
						var/I = image('icons/mob/mob.dmi', loc = t_mind.current, icon_state = "vampthrall")
						head.current.client.images += I
				if(t_mind.current)
					if(t_mind.current.client)
						var/I = image('icons/mob/mob.dmi', loc = head.current, icon_state = "vampire")
						t_mind.current.client.images += I
				if(t_mind.current)
					if(t_mind.current.client)
						var/I = image('icons/mob/mob.dmi', loc = t_mind.current, icon_state = "vampthrall")
						t_mind.current.client.images += I

/datum/game_mode/proc/update_vampire_icons_removed(datum/mind/vampire_mind)
	for(var/headref in thralls)
		var/datum/mind/head = locate(headref)
		for(var/datum/mind/t_mind in thralls[headref])
			if(t_mind.current)
				if(t_mind.current.client)
					for(var/image/I in t_mind.current.client.images)
						if((I.icon_state == "vampthrall" || I.icon_state == "vampire") && I.loc == vampire_mind.current)
							//world.log << "deleting [vampire_mind] overlay"
							del(I)
		if(head)
			//world.log << "found [head.name]"
			if(head.current)
				if(head.current.client)
					for(var/image/I in head.current.client.images)
						if((I.icon_state == "vampthrall" || I.icon_state == "vampire") && I.loc == vampire_mind.current)
							//world.log << "deleting [vampire_mind] overlay"
							del(I)
	if(vampire_mind.current)
		if(vampire_mind.current.client)
			for(var/image/I in vampire_mind.current.client.images)
				if(I.icon_state == "vampthrall" || I.icon_state == "vampire")
					del(I)

/datum/game_mode/proc/remove_vampire_mind(datum/mind/vampire_mind, datum/mind/head)
	//var/list/removal
	if(!istype(head))
		head = vampire_mind //workaround for removing a thrall's control over the enthralled
	var/ref = "\ref[head]"
	if(ref in thralls)
		thralls[ref] -= vampire_mind
	enthralled -= vampire_mind
	vampire_mind.special_role = null
	update_vampire_icons_removed(vampire_mind)
	//world << "Removed [vampire_mind.current.name] from vampire shit"
	vampire_mind.current << "\red <FONT size = 3><B>The fog clouding your mind clears. You remember nothing from the moment you were enthralled until now.</B></FONT>"

/mob/living/carbon/human/proc/check_sun()

	var/ax = x
	var/ay = y

	for(var/i = 1 to 20)
		ax += sun.dx
		ay += sun.dy

		var/turf/T = locate( round(ax,0.5),round(ay,0.5),z)

		if(T.x == 1 || T.x==world.maxx || T.y==1 || T.y==world.maxy)
			break

		if(T.density)
			return
	if(prob(35))
		switch(health)
			if(80 to 100)
				src << "\red Your skin flakes away..."
			if(60 to 80)
				src << "<span class='warning'>Your skin sizzles!</span>"
			if((-INFINITY) to 60)
				if(!on_fire)
					src << "<b>\red Your skin catches fire!</b>"
				else
					src << "<b>\red You continue to burn!</b>"
				fire_stacks += 5
				IgniteMob()
		emote("scream",,, 1)
	else
		switch(health)
			if((-INFINITY) to 60)
				fire_stacks++
				IgniteMob()
	adjustFireLoss(3)

/mob/living/carbon/human/proc/handle_vampire()
	if(hud_used)
		if(!hud_used.vampire_blood_display)
			hud_used.vampire_hud()
			//hud_used.human_hud(hud_used.ui_style)
		hud_used.vampire_blood_display.maptext_width = 64
		hud_used.vampire_blood_display.maptext_height = 64
		hud_used.vampire_blood_display.maptext = "<div align='left' valign='top' style='position:relative; top:0px; left:6px'> U:<font color='#33FF33' size='1'>[mind.vampire.bloodusable]</font><br> T:<font color='#FFFF00' size='1'>[mind.vampire.bloodtotal]</font></div>"
	handle_vampire_cloak()
	if(istype(loc, /turf/space))
		check_sun()
	mind.vampire.nullified = max(0, mind.vampire.nullified - 1)