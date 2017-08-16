//Clockwork marauder: Slow but with high damage, resides inside of a servant. Created via the Memory Allocation scripture.
/mob/living/simple_animal/hostile/clockwork/marauder
	name = "clockwork marauder"
	desc = "A stalwart apparition of a soldier, blazing with crimson flames. It's armed with a gladius and shield."
	icon_state = "clockwork_marauder"
	health = 300
	maxHealth = 300
	speed = 1
	obj_damage = 40
	melee_damage_lower = 12
	melee_damage_upper = 12
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	weather_immunities = list("lava")
	movement_type = FLYING
	loot = list(/obj/item/clockwork/component/geis_capacitor/fallen_armor)
	var/true_name = "Meme Master 69" //Required to call forth the marauder
	var/global/list/possible_true_names = list("Servant", "Warden", "Serf", "Page", "Usher", "Knave", "Vassal", "Escort")
	var/mob/living/host //The mob that the marauder is living inside of
	var/recovering = FALSE //If the marauder is recovering from recalling
	var/blockchance = 17 //chance to block attacks entirely
	var/counterchance = 30 //chance to counterattack after blocking
	var/static/list/damage_heal_order = list(OXY, BURN, BRUTE, TOX) //we heal our host's damage in this order
	light_range = 2
	light_power = 1.1
	playstyle_string = "<span class='sevtug'>You are a clockwork marauder</span><b>, a living extension of Sevtug's will. As a marauder, you are somewhat slow, but may block attacks, \
	and have a chance to also counter blocked melee attacks for extra damage, in addition to being immune to extreme temperatures and pressures. \
	Your primary goal is to serve the creature that you are now a part of. You can use <span class='sevtug_small'><i>:b</i></span> to communicate silently with your master, \
	but can only exit if your master calls your true name or if they are exceptionally damaged. \
	\n\n\
	Stay near your host to protect and heal them; being too far from your host will rapidly cause you massive damage. Recall to your host if you are too weak and believe you cannot continue \
	fighting safely. As a final note, you should probably avoid harming any fellow servants of Ratvar.</span>"

/mob/living/simple_animal/hostile/clockwork/marauder/Initialize()
	. = ..()
	true_name = pick(possible_true_names)

/mob/living/simple_animal/hostile/clockwork/marauder/Life()
	..()
	if(is_in_host())
		if(!is_servant_of_ratvar(host))
			emerge_from_host(FALSE, TRUE)
			unbind_from_host()
			return
		if(!GLOB.ratvar_awakens && host.stat == DEAD)
			death()
			return
		if(GLOB.ratvar_awakens)
			adjustHealth(-50)
		else
			adjustHealth(-10)
		if(!recovering)
			heal_host() //also heal our host if inside of them and we aren't recovering
		else if(health == maxHealth)
			to_chat(src, "<span class='userdanger'>Your strength has returned. You can once again come forward!</span>")
			to_chat(host, "<span class='userdanger'>Your marauder is now strong enough to come forward again!</span>")
			recovering = FALSE
	else
		if(GLOB.ratvar_awakens) //If Ratvar is alive, marauders don't need a host and are downright impossible to kill
			adjustHealth(-5)
			heal_host()
		else if(host)
			if(!is_servant_of_ratvar(host))
				unbind_from_host()
				return
			if(host.stat == DEAD)
				adjustHealth(50)
				to_chat(src, "<span class='userdanger'>Your host is dead!</span>")
				return
			if(z && host.z && z == host.z)
				switch(get_dist(get_turf(src), get_turf(host)))
					if(2)
						adjustHealth(-1)
					if(3)
						//EQUILIBRIUM
					if(4)
						adjustHealth(1)
					if(5)
						adjustHealth(3)
					if(6)
						adjustHealth(6)
					if(7)
						adjustHealth(9)
					if(8 to INFINITY)
						adjustHealth(15)
						to_chat(src, "<span class='userdanger'>You're too far from your host and rapidly taking damage!</span>")
					else //right next to or on top of host
						adjustHealth(-2)
						heal_host() //gradually heal host if nearby and host is very weak
			else //well then, you're not even in the same zlevel
				adjustHealth(15)
				to_chat(src, "<span class='userdanger'>You're too far from your host and rapidly taking damage!</span>")

/mob/living/simple_animal/hostile/clockwork/marauder/death(gibbed)
	emerge_from_host(FALSE, TRUE)
	unbind_from_host()
	visible_message("<span class='warning'>[src]'s equipment clatters lifelessly to the ground as the red flames within dissipate.</span>", \
	"<span class='userdanger'>Your equipment falls away. You feel a moment of confusion before your fragile form is annihilated.</span>")
	. = ..()

/mob/living/simple_animal/hostile/clockwork/marauder/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Current True Name: [true_name]")
		stat(null, "Host: [host ? host : "NONE"]")
		if(host)
			var/resulthealth = round((host.health / host.maxHealth) * 100, 0.5)
			if(iscarbon(host))
				resulthealth = round((abs(HEALTH_THRESHOLD_DEAD - host.health) / abs(HEALTH_THRESHOLD_DEAD - host.maxHealth)) * 100)
			stat(null, "Host Health: [resulthealth]%")
			if(GLOB.ratvar_awakens)
				stat(null, "You are [recovering ? "un" : ""]able to deploy!")
			else
				if(resulthealth > MARAUDER_EMERGE_THRESHOLD)
					stat(null, "You are [recovering ? "unable to deploy" : "able to deploy on hearing your True Name"]!")
				else
					stat(null, "You are [recovering ? "unable to deploy" : "able to deploy to protect your host"]!")
		stat(null, "You do [melee_damage_upper] damage on melee attacks.")

/mob/living/simple_animal/hostile/clockwork/marauder/Process_Spacemove(movement_dir = 0)
	return 1

/mob/living/simple_animal/hostile/clockwork/marauder/proc/bind_to_host(mob/living/new_host)
	if(!new_host)
		return FALSE
	host = new_host
	var/datum/action/innate/summon_marauder/SM = new()
	SM.linked_marauder = src
	SM.Grant(host)
	var/datum/action/innate/linked_minds/LM = new()
	LM.linked_marauder = src
	LM.Grant(host)
	return TRUE

/mob/living/simple_animal/hostile/clockwork/marauder/proc/unbind_from_host()
	if(host)
		for(var/datum/action/innate/summon_marauder/SM in host.actions)
			qdel(SM)
		for(var/datum/action/innate/linked_minds/LM in host.actions)
			qdel(LM)
		host = null
		return TRUE
	return FALSE

//DAMAGE and FATIGUE
/mob/living/simple_animal/hostile/clockwork/marauder/proc/heal_host()
	if(!host)
		return
	var/resulthealth = round((host.health / host.maxHealth) * 100, 0.5)
	if(iscarbon(host))
		resulthealth = round((abs(HEALTH_THRESHOLD_DEAD - host.health) / abs(HEALTH_THRESHOLD_DEAD - host.maxHealth)) * 100)
	if(GLOB.ratvar_awakens || resulthealth <= MARAUDER_EMERGE_THRESHOLD)
		new /obj/effect/temp_visual/heal(host.loc, "#AF0AAF")
		host.heal_ordered_damage(4, damage_heal_order)

/mob/living/simple_animal/hostile/clockwork/marauder/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(amount > 0)
		for(var/mob/living/L in view(2, src))
			if(L.is_holding_item_of_type(/obj/item/weapon/nullrod))
				to_chat(src, "<span class='userdanger'>The presence of a brandished holy artifact weakens your armor!</span>")
				amount *= 4 //if a wielded null rod is nearby, it takes four times the health damage
				break
	. = ..()
	if(src && updating_health)
		update_health_hud()
		update_stats()

/mob/living/simple_animal/hostile/clockwork/marauder/update_health_hud()
	if(hud_used && hud_used.healths)
		if(istype(hud_used, /datum/hud/marauder))
			var/datum/hud/marauder/M = hud_used
			var/resulthealth
			if(host)
				if(iscarbon(host))
					resulthealth = "[round((abs(HEALTH_THRESHOLD_DEAD - host.health) / abs(HEALTH_THRESHOLD_DEAD - host.maxHealth)) * 100)]%"
				else
					resulthealth = "[round((host.health / host.maxHealth) * 100, 0.5)]%"
			else
				resulthealth = "NONE"
			M.hosthealth.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#AF0AAF'>HOST<br>[resulthealth]</font></div>"
		hud_used.healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#AF0AAF'>[round((health / maxHealth) * 100, 0.5)]%</font>"

/mob/living/simple_animal/hostile/clockwork/marauder/proc/update_stats()
	if(GLOB.ratvar_awakens)
		speed = 0
		melee_damage_lower = 20
		melee_damage_upper = 20
		attacktext = "devastates"
	else
		var/healthpercent = (health/maxHealth) * 100
		switch(healthpercent)
			if(100 to 70) //Bonuses to speed and damage at high health
				speed = 0
				melee_damage_lower = 16
				melee_damage_upper = 16
				attacktext = "viciously slashes"
			if(70 to 40)
				speed = initial(speed)
				melee_damage_lower = initial(melee_damage_lower)
				melee_damage_upper = initial(melee_damage_upper)
				attacktext = initial(attacktext)
			if(40 to 30) //Damage decrease, but not speed
				speed = initial(speed)
				melee_damage_lower = 10
				melee_damage_upper = 10
				attacktext = "lightly slashes"
			if(30 to 20) //Speed decrease
				speed = 2
				melee_damage_lower = 8
				melee_damage_upper = 8
				attacktext = "lightly slashes"
			if(20 to 10) //Massive speed decrease and weak melee attacks
				speed = 3
				melee_damage_lower = 6
				melee_damage_upper = 6
				attacktext = "weakly slashes"
			if(10 to 0) //We are super weak and going to die
				speed = 4
				melee_damage_lower = 4
				melee_damage_upper = 4
				attacktext = "taps"

//ATTACKING, BLOCKING, and COUNTERING

/mob/living/simple_animal/hostile/clockwork/marauder/AttackingTarget()
	if(is_in_host())
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/clockwork/marauder/bullet_act(obj/item/projectile/Proj)
	if(blockOrCounter(null, Proj))
		return
	return ..()

/mob/living/simple_animal/hostile/clockwork/marauder/hitby(atom/movable/AM, skipcatch, hitpush, blocked)
	if(blockOrCounter(null, AM))
		return
	return ..()

/mob/living/simple_animal/hostile/clockwork/marauder/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/hostile/clockwork/marauder) || !blockOrCounter(M, M)) //we don't want infinite blockcounter loops if fighting another marauder
		return ..()

/mob/living/simple_animal/hostile/clockwork/marauder/attack_paw(mob/living/carbon/monkey/M)
	if(!blockOrCounter(M, M))
		return ..()

/mob/living/simple_animal/hostile/clockwork/marauder/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(!blockOrCounter(M, M))
		return ..()

/mob/living/simple_animal/hostile/clockwork/marauder/attack_slime(mob/living/simple_animal/slime/M)
	if(!blockOrCounter(M, M))
		return ..()

/mob/living/simple_animal/hostile/clockwork/marauder/attack_hand(mob/living/carbon/human/M)
	if(!blockOrCounter(M, M))
		return ..()

/mob/living/simple_animal/hostile/clockwork/marauder/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/nullrod) || !blockOrCounter(user, I))
		return ..()

/mob/living/simple_animal/hostile/clockwork/marauder/proc/blockOrCounter(mob/target, atom/textobject)
	if(GLOB.ratvar_awakens) //if ratvar has woken, we block nearly everything at a very high chance
		blockchance = 90
		counterchance = 90
	if(prob(blockchance))
		. = TRUE
		if(target)
			target.do_attack_animation(src)
			target.changeNext_move(CLICK_CD_MELEE)
		blockchance = initial(blockchance)
		playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', 30, 1, 0, 1) //clang
		visible_message("<span class='boldannounce'>[src] blocks [target && isitem(textobject) ? "[target]'s [textobject.name]":"\the [textobject]"]!</span>", \
		"<span class='userdanger'>You block [target && isitem(textobject) ? "[target]'s [textobject.name]":"\the [textobject]"]!</span>")
		if(target && Adjacent(target))
			if(prob(counterchance))
				counterchance = initial(counterchance)
				var/previousattacktext = attacktext
				attacktext = "counters"
				UnarmedAttack(target)
				attacktext = previousattacktext
			else
				counterchance = min(counterchance + initial(counterchance), 100)
	else
		blockchance = min(blockchance + initial(blockchance), 100)
	if(GLOB.ratvar_awakens)
		blockchance = 90
		counterchance = 90

//COMMUNICATION and EMERGENCE

/mob/living/simple_animal/hostile/clockwork/marauder/handle_inherent_channels(message, message_mode)
	if(host && (is_in_host() || message_mode == MODE_BINARY))
		marauder_comms(message)
		return TRUE
	return ..()

/mob/living/simple_animal/hostile/clockwork/marauder/proc/marauder_comms(message)
	var/name_part = "<span class='sevtug'>[src] ([true_name])</span>"
	message = "<span class='sevtug_small'>\"[message]\"</span>" //Processed output
	to_chat(src, "[name_part]<span class='sevtug_small'>:</span> [message]")
	to_chat(host, "[name_part]<span class='sevtug_small'>:</span> [message]")
	for(var/M in GLOB.mob_list)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [name_part] <span class='sevtug_small'>(to</span> <span class='sevtug'>[findtextEx(host.name, host.real_name) ? "[host.name]" : "[host.real_name] (as [host.name])"]</span><span class='sevtug_small'>):</span> [message] ")
	return TRUE

/mob/living/simple_animal/hostile/clockwork/marauder/proc/return_to_host()
	if(is_in_host())
		return FALSE
	if(!host)
		to_chat(src, "<span class='warning'>You don't have a host!</span>")
		return FALSE
	var/resulthealth = round((host.health / host.maxHealth) * 100, 0.5)
	if(iscarbon(host))
		resulthealth = round((abs(HEALTH_THRESHOLD_DEAD - host.health) / abs(HEALTH_THRESHOLD_DEAD - host.maxHealth)) * 100)
	host.visible_message("<span class='warning'>[host]'s skin flashes crimson!</span>", "<span class='sevtug'>You feel [true_name]'s consciousness settle in your mind.</span>")
	visible_message("<span class='warning'>[src] suddenly disappears!</span>", "<span class='sevtug'>You return to [host].</span>")
	forceMove(host)
	if(resulthealth > MARAUDER_EMERGE_THRESHOLD && health != maxHealth)
		recovering = TRUE
		to_chat(src, "<span class='userdanger'>You have weakened and will need to recover before manifesting again!</span>")
		to_chat(host, "<span class='sevtug'>[true_name] has weakened and will need to recover before manifesting again!</span>")
	return TRUE

/mob/living/simple_animal/hostile/clockwork/marauder/proc/try_emerge()
	if(!host)
		to_chat(src, "<span class='warning'>You don't have a host!</span>")
		return FALSE
	if(!GLOB.ratvar_awakens)
		var/resulthealth = round((host.health / host.maxHealth) * 100, 0.5)
		if(iscarbon(host))
			resulthealth = round((abs(HEALTH_THRESHOLD_DEAD - host.health) / abs(HEALTH_THRESHOLD_DEAD - host.maxHealth)) * 100)
		if(host.stat != DEAD && resulthealth > MARAUDER_EMERGE_THRESHOLD) //if above 20 health, fails
			to_chat(src, "<span class='warning'>Your host must be at [MARAUDER_EMERGE_THRESHOLD]% or less health to emerge like this!</span>")
			return FALSE
	return emerge_from_host(FALSE)

/mob/living/simple_animal/hostile/clockwork/marauder/proc/emerge_from_host(hostchosen, force) //Notice that this is a proc rather than a verb - marauders can NOT exit at will, but they CAN return
	if(!is_in_host())
		return FALSE
	if(!force && recovering)
		if(hostchosen)
			to_chat(host, "<span class='sevtug'>[true_name] is too weak to come forth!</span>")
		else
			to_chat(host, "<span class='sevtug'>[true_name] tries to emerge to protect you, but it's too weak!</span>")
		to_chat(src, "<span class='userdanger'>You try to come forth, but you're too weak!</span>")
		return FALSE
	if(!force)
		if(hostchosen) //marauder approved
			to_chat(host, "<span class='sevtug'>Your words echo with power as [true_name] emerges from your body!</span>")
		else
			to_chat(host, "<span class='sevtug'>[true_name] emerges from your body to protect you!</span>")
	forceMove(host.loc)
	visible_message("<span class='warning'>[host]'s skin glows red as [name] emerges from their body!</span>", "<span class='sevtug_small'>You exit the safety of [host]'s body!</span>")
	return TRUE

/mob/living/simple_animal/hostile/clockwork/marauder/get_alt_name()
	return " ([text2ratvar(true_name)])"

/mob/living/simple_animal/hostile/clockwork/marauder/proc/is_in_host() //Checks if the marauder is inside of their host
	return host && loc == host

//HOST ACTIONS

//Summon Marauder action: Calls forth or recalls your marauder
/datum/action/innate/summon_marauder
	name = "Force Marauder to Emerge/Recall"
	desc = "Allows you to force your clockwork marauder to emerge or recall as required."
	button_icon_state = "clockwork_marauder"
	background_icon_state = "bg_clock"
	check_flags = AB_CHECK_CONSCIOUS
	buttontooltipstyle = "clockcult"
	var/mob/living/simple_animal/hostile/clockwork/marauder/linked_marauder
	var/static/list/defend_phrases = list("Defend me", "Come forth", "Assist me", "Protect me", "Give aid", "Help me")
	var/static/list/return_phrases = list("Return", "Return to me", "Your job is done", "You have served", "Come back", "Retreat")

/datum/action/innate/summon_marauder/IsAvailable()
	if(!linked_marauder)
		return FALSE
	if(isliving(owner))
		var/mob/living/L = owner
		if(!L.can_speak_vocal() || L.stat)
			return FALSE
	return ..()

/datum/action/innate/summon_marauder/Activate()
	if(linked_marauder.is_in_host())
		clockwork_say(owner, text2ratvar("[pick(defend_phrases)], [linked_marauder.true_name]!"))
		linked_marauder.emerge_from_host(TRUE)
	else
		clockwork_say(owner, text2ratvar("[pick(return_phrases)], [linked_marauder.true_name]!"))
		linked_marauder.return_to_host()
	return TRUE

//Linked Minds action: talks to your marauder
/datum/action/innate/linked_minds
	name = "Linked Minds"
	desc = "Allows you to silently communicate with your marauder."
	button_icon_state = "linked_minds"
	background_icon_state = "bg_clock"
	check_flags = AB_CHECK_CONSCIOUS
	buttontooltipstyle = "clockcult"
	var/mob/living/simple_animal/hostile/clockwork/marauder/linked_marauder

/datum/action/innate/linked_minds/IsAvailable()
	if(!linked_marauder)
		return FALSE
	return ..()

/datum/action/innate/linked_minds/Activate()
	var/message = stripped_input(owner, "Enter a message to tell your marauder.", "Telepathy")
	if(!owner || !message)
		return FALSE
	if(!linked_marauder)
		to_chat(owner, "<span class='warning'>Your marauder seems to have been destroyed!</span>")
		return FALSE
	var/name_part = "<span class='sevtug'>Servant [findtextEx(owner.name, owner.real_name) ? "[owner.name]" : "[owner.real_name] (as [owner.name])"]</span>"
	message = "<span class='sevtug_small'>\"[message]\"</span>" //Processed output
	to_chat(owner, "[name_part]<span class='sevtug_small'>:</span> [message]")
	to_chat(linked_marauder, "[name_part]<span class='sevtug_small'>:</span> [message]")
	for(var/M in GLOB.mob_list)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [name_part] <span class='sevtug_small'>(to</span> <span class='sevtug'>[linked_marauder] ([linked_marauder.true_name])</span><span class='sevtug_small'>):</span> [message]")
	return TRUE
