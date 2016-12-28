
/mob/living/simple_animal/hostile/clockwork
	faction = list("ratvar")
	gender = NEUTER
	icon = 'icons/mob/clockwork_mobs.dmi'
	unique_name = 1
	minbodytemp = 0
	unsuitable_atmos_damage = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0) //Robotic
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	languages_spoken = RATVAR
	languages_understood = HUMAN|RATVAR
	healable = FALSE
	del_on_death = TRUE
	speak_emote = list("clanks", "clinks", "clunks", "clangs")
	verb_ask = "requests"
	verb_exclaim = "proclaims"
	verb_yell = "harangues"
	bubble_icon = "clock"
	death_sound = 'sound/magic/clockwork/anima_fragment_death.ogg'
	var/playstyle_string = "<span class='heavy_brass'>You are a bug, yell at whoever spawned you!</span>"
	var/obj/item/clockwork/slab/internalslab //an internal slab for running scripture

/mob/living/simple_animal/hostile/clockwork/New()
	..()
	internalslab = new/obj/item/clockwork/slab/internal(src)

/mob/living/simple_animal/hostile/clockwork/Destroy()
	qdel(internalslab)
	internalslab = null
	return ..()

/mob/living/simple_animal/hostile/clockwork/get_spans()
	return ..() | SPAN_ROBOT

/mob/living/simple_animal/hostile/clockwork/Login()
	..()
	src << playstyle_string

/mob/living/simple_animal/hostile/clockwork/ratvar_act()
	fully_heal(TRUE)

/mob/living/simple_animal/hostile/clockwork/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, safety = 0, tesla_shock = 0, illusion = 0)
	return 0 //ouch, my metal-unlikely-to-be-damaged-by-electricity-body

/mob/living/simple_animal/hostile/clockwork/examine(mob/user)
	var/t_He = p_they(TRUE)
	var/t_s = p_s()
	var/msg = "<span class='brass'>*---------*\nThis is \icon[src] \a <b>[src]</b>!\n"
	msg += "[desc]\n"
	if(health < maxHealth)
		msg += "<span class='warning'>"
		if(health >= maxHealth/2)
			msg += "[t_He] look[t_s] slightly dented.\n"
		else
			msg += "<b>[t_He] look[t_s] severely dented!</b>\n"
		msg += "</span>"
	msg += "*---------*</span>"

	user << msg

/mob/living/simple_animal/hostile/clockwork/fragment //Anima fragment: Low health and high melee damage, but slows down when struck. Created by inserting a soul vessel into an empty fragment.
	name = "anima fragment"
	desc = "An ominous humanoid shell with a spinning cogwheel as its head, lifted by a jet of blazing red flame."
	icon_state = "anime_fragment"
	health = 90
	maxHealth = 90
	speed = -1
	melee_damage_lower = 18
	melee_damage_upper = 18
	attacktext = "crushes"
	attack_sound = 'sound/magic/clockwork/anima_fragment_attack.ogg'
	loot = list(/obj/item/clockwork/component/replicant_alloy/smashed_anima_fragment)
	weather_immunities = list("lava")
	movement_type = FLYING
	playstyle_string = "<span class='heavy_brass'>You are an anima fragment</span><b>, a clockwork creation of Ratvar. As a fragment, you have low health, do decent damage, and move at \
	extreme speed in addition to being immune to extreme temperatures and pressures. Taking damage will temporarily slow you down, however. \n Your goal is to serve the Justiciar and his servants \
	in any way you can. You yourself are one of these servants, and will be able to utilize anything they can, assuming it doesn't require opposable thumbs.</b>"
	var/movement_delay_time //how long the fragment is slowed after being hit

/mob/living/simple_animal/hostile/clockwork/fragment/New()
	..()
	SetLuminosity(2,1)
	if(prob(1))
		name = "anime fragment"
		real_name = name
		desc = "I-it's not like I want to show you the light of the Justiciar or anything, B-BAKA!"

/mob/living/simple_animal/hostile/clockwork/fragment/Stat()
	..()
	if(statpanel("Status") && movement_delay_time > world.time && !ratvar_awakens)
		stat(null, "Movement delay(seconds): [max(round((movement_delay_time - world.time)*0.1, 0.1), 0)]")

/mob/living/simple_animal/hostile/clockwork/fragment/death(gibbed)
	visible_message("<span class='warning'>[src]'s flame jets cut out as it falls to the floor with a tremendous crash.</span>", \
	"<span class='userdanger'>Your gears seize up. Your flame jets flicker out. Your soul vessel belches smoke as you helplessly crash down.</span>")
	..()

/mob/living/simple_animal/hostile/clockwork/fragment/Process_Spacemove(movement_dir = 0)
	return 1

/mob/living/simple_animal/hostile/clockwork/fragment/emp_act(severity)
	if(movement_delay_time > world.time)
		movement_delay_time = movement_delay_time + (50/severity)
	else
		movement_delay_time = world.time + (50/severity)

/mob/living/simple_animal/hostile/clockwork/fragment/movement_delay()
	. = ..()
	if(movement_delay_time > world.time && !ratvar_awakens)
		. += min((movement_delay_time - world.time) * 0.1, 10) //the more delay we have, the slower we go

/mob/living/simple_animal/hostile/clockwork/fragment/adjustHealth(amount)
	. = ..()
	if(!ratvar_awakens && amount > 0) //if ratvar is up we ignore movement delay
		if(movement_delay_time > world.time)
			movement_delay_time = movement_delay_time + amount*2.5
		else
			movement_delay_time = world.time + amount*2.5

/mob/living/simple_animal/hostile/clockwork/fragment/updatehealth()
	..()
	if(health == maxHealth)
		speed = initial(speed)
	else
		speed = 0 //slow down if damaged at all

/mob/living/simple_animal/hostile/clockwork/marauder //Clockwork marauder: Slow but with high damage, resides inside of a servant. Created via the Memory Allocation scripture.
	name = "clockwork marauder"
	desc = "A stalwart apparition of a soldier, blazing with crimson flames. It's armed with a gladius and shield."
	icon_state = "clockwork_marauder"
	health = 400
	maxHealth = 400
	speed = 1
	obj_damage = 40
	melee_damage_lower = 12
	melee_damage_upper = 12
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	weather_immunities = list("lava")
	movement_type = FLYING
	loot = list(/obj/item/clockwork/component/replicant_alloy/fallen_armor)
	var/true_name = "Meme Master 69" //Required to call forth the marauder
	var/global/list/possible_true_names = list("Freinag", "Jneqra", "Sbby", "Vqvbg", "Cntr", "Hfure", "Xanir", "Inffny", "Rfpbeg")
	var/mob/living/host //The mob that the marauder is living inside of
	var/recovering = FALSE //If the marauder is recovering from recalling
	var/blockchance = 20 //chance to block melee attacks entirely
	var/counterchance = 30 //chance to counterattack after blocking
	var/combattimer = 50 //after 5 seconds of not being hit ot attacking we count as 'out of combat' and lose block/counter chance
	playstyle_string = "<span class='sevtug'>You are a clockwork marauder</span><b>, a living extension of Sevtug's will. As a marauder, you are somewhat slow, but may block melee attacks \
	and have a chance to also counter blocked melee attacks for extra damage, in addition to being immune to extreme temperatures and pressures. \
	Your primary goal is to serve the creature that you are now a part of. You can use <span class='sevtug_small'><i>:b</i></span> to communicate silently with your master, \
	but can only exit if your master calls your true name or if they are exceptionally damaged. \
	\n\n\
	Stay near your host to protect and heal them; being too far from your host will rapidly cause you massive damage. Recall to your host if you are too weak and believe you cannot continue \
	fighting safely. As a final note, you should probably avoid harming any fellow servants of Ratvar.</span>"

/mob/living/simple_animal/hostile/clockwork/marauder/New()
	..()
	combattimer = 0
	true_name = pick(possible_true_names)
	SetLuminosity(2,1)

/mob/living/simple_animal/hostile/clockwork/marauder/Life()
	..()
	if(combattimer < world.time)
		blockchance = max(blockchance - 5, initial(blockchance))
		counterchance = max(counterchance - 10, initial(counterchance))
	if(is_in_host())
		if(!ratvar_awakens && host.stat == DEAD)
			death()
			return
		if(ratvar_awakens)
			adjustHealth(-50)
		else
			adjustHealth(-10)
		if(!recovering)
			heal_host() //also heal our host if inside of them and we aren't recovering
		else if(health == maxHealth)
			src << "<span class='userdanger'>Your strength has returned. You can once again come forward!</span>"
			host << "<span class='userdanger'>Your marauder is now strong enough to come forward again!</span>"
			recovering = FALSE
	else
		if(ratvar_awakens)
			adjustHealth(-5)
			heal_host()
		else if(host) //If Ratvar is alive, marauders don't need a host and are downright impossible to kill
			if(host.stat == DEAD)
				adjustHealth(50)
				src << "<span class='userdanger'>Your host is dead!</span>"
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
						adjustHealth(5)
					if(7)
						adjustHealth(7)
					if(8 to INFINITY)
						adjustHealth(10)
						src << "<span class='userdanger'>You're too far from your host and rapidly taking damage!</span>"
					else //right next to or on top of host
						adjustHealth(-2)
						heal_host() //gradually heal host if nearby and host is very weak
			else //well then, you're not even in the same zlevel
				adjustHealth(10)
				src << "<span class='userdanger'>You're too far from your host and rapidly taking damage!</span>"
			update_health_hud()

/mob/living/simple_animal/hostile/clockwork/marauder/Process_Spacemove(movement_dir = 0)
	return 1

//DAMAGE and FATIGUE
/mob/living/simple_animal/hostile/clockwork/marauder/proc/heal_host()
	if(!host)
		return
	var/resulthealth = round((host.health / host.maxHealth) * 100, 0.5)
	if(iscarbon(host))
		resulthealth = round((abs(HEALTH_THRESHOLD_DEAD - host.health) / abs(HEALTH_THRESHOLD_DEAD - host.maxHealth)) * 100)
	if(ratvar_awakens || resulthealth <= MARAUDER_EMERGE_THRESHOLD)
		PoolOrNew(/obj/effect/overlay/temp/heal, list(host.loc, "#AF0AAF"))
		host.adjustBruteLoss(-1)
		host.adjustFireLoss(-1)
		host.adjustToxLoss(-1)
		host.adjustOxyLoss(-3)

/mob/living/simple_animal/hostile/clockwork/marauder/proc/update_stats()
	if(ratvar_awakens)
		speed = 0
		melee_damage_lower = 20
		melee_damage_upper = 20
		attacktext = "devastates"
	else
		switch((health/maxHealth) * 100)
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


/mob/living/simple_animal/hostile/clockwork/marauder/death(gibbed)
	emerge_from_host(0, 1)
	visible_message("<span class='warning'>[src]'s equipment clatters lifelessly to the ground as the red flames within dissipate.</span>", \
	"<span class='userdanger'>Your equipment falls away. You feel a moment of confusion before your fragile form is annihilated.</span>")
	..()

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
			if(ratvar_awakens)
				stat(null, "You are [recovering ? "un" : ""]able to deploy!")
			else
				if(resulthealth > MARAUDER_EMERGE_THRESHOLD)
					stat(null, "You are [recovering ? "unable to deploy" : "able to deploy on hearing your True Name"]!")
				else
					stat(null, "You are [recovering ? "unable to deploy" : "able to deploy to protect your host"]!")
		if(ratvar_awakens)
			stat(null, "Block Chance: 80%")
			stat(null, "Counter Chance: 80%")
		else
			stat(null, "Block Chance: [blockchance]%")
			stat(null, "Counter Chance: [counterchance]%")
		stat(null, "You do [melee_damage_upper] damage on melee attacks.")

/mob/living/simple_animal/hostile/clockwork/marauder/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(amount > 0)
		combattimer = world.time + initial(combattimer)
		for(var/mob/living/L in view(2, src))
			if(L.is_holding_item_of_type(/obj/item/weapon/nullrod))
				src << "<span class='userdanger'>The presence of a brandished holy artifact weakens your armor!</span>"
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
			M.blockchance.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#2A0006'>[blockchance]%</font></div>"
			M.counterchance.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#2A0006'>[counterchance]%</font></div>"
		hud_used.healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#AF0AAF'>[round((health / maxHealth) * 100, 0.5)]%</font>"

//ATTACKING, BLOCKING, and COUNTERING

/mob/living/simple_animal/hostile/clockwork/marauder/AttackingTarget()
	if(is_in_host())
		return 0
	combattimer = world.time + initial(combattimer)
	..()

/mob/living/simple_animal/hostile/clockwork/marauder/bullet_act(obj/item/projectile/Proj)
	if(blockOrCounter(null, Proj))
		return
	return ..()

/mob/living/simple_animal/hostile/clockwork/marauder/hitby(atom/movable/AM, skipcatch, hitpush, blocked)
	if(blockOrCounter(null, AM))
		return
	return ..()

/mob/living/simple_animal/hostile/clockwork/marauder/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/hostile/clockwork/marauder) || !blockOrCounter(M, M))
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
	if(ratvar_awakens) //if ratvar has woken, we block nearly everything at a very high chance
		blockchance = 80
		counterchance = 80
	if(prob(blockchance))
		. = TRUE
		if(target)
			target.do_attack_animation(src)
			target.changeNext_move(CLICK_CD_MELEE)
		blockchance = initial(blockchance)
		playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', 10, 1, 0, 1) //clang
		visible_message("<span class='boldannounce'>[src] blocks [target && istype(textobject, /obj/item) ? "[target]'s [textobject.name]":"\the [textobject]"]!</span>", \
		"<span class='userdanger'>You block [target && istype(textobject, /obj/item) ? "[target]'s [textobject.name]":"\the [textobject]"]!</span>")
		if(target && Adjacent(target))
			if(prob(counterchance))
				counterchance = initial(counterchance)
				var/previousattacktext = attacktext
				attacktext = "counters"
				target.attack_animal(src)
				attacktext = previousattacktext
			else
				counterchance = min(counterchance + initial(counterchance), 100)
	else
		blockchance = min(blockchance + initial(blockchance), 100)
	if(ratvar_awakens)
		blockchance = 80
		counterchance = 80
	update_health_hud()

//COMMUNICATION and EMERGENCE

/mob/living/simple_animal/hostile/clockwork/marauder/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans)
	..()
	if(findtext(message, true_name) && is_in_host()) //Called or revealed by hearing their true name
		if(speaker == host)
			emerge_from_host(1)
		else
			src << "<span class='boldannounce'>You hear your true name and partially emerge before you can stop yourself!</span>"
			host.visible_message("<span class='warning'>[host]'s skin flashes crimson!</span>", "<span class='boldannounce'>Your marauder instinctively reacts to its true name!</span>")

/mob/living/simple_animal/hostile/clockwork/marauder/say(message, message_mode)
	if(host && (is_in_host() || message_mode == MODE_BINARY))
		marauder_comms(message)
		return 1
	..()

/mob/living/simple_animal/hostile/clockwork/marauder/proc/marauder_comms(message)
	if(host)
		message = "<span class='sevtug'>Marauder [true_name]:</span> <span class='sevtug_small'>\"[message]\"</span>" //Processed output
		src << message
		host << message
		for(var/M in mob_list)
			if(isobserver(M))
				var/link = FOLLOW_LINK(M, src)
				M << "[link] [message]"
		return 1
	return 0

/mob/living/proc/talk_with_marauder() //hosts communicate via a verb, marauders just use :b
	set name = "Linked Minds"
	set desc = "Silently communicates with your marauder."
	set category = "Clockwork"
	var/mob/living/simple_animal/hostile/clockwork/marauder/marauder

	if(!marauder)
		for(var/mob/living/simple_animal/hostile/clockwork/marauder/C in living_mob_list)
			if(C.host == src)
				marauder = C
		if(!marauder) //Double-check afterwards
			src << "<span class='warning'>You aren't hosting any marauders!</span>"
			verbs -= /mob/living/proc/talk_with_marauder
			return 0
	var/message = stripped_input(src, "Enter a message to tell your marauder.", "Telepathy")// as null|anything
	if(!src || !message)
		return 0
	if(!marauder)
		usr << "<span class='warning'>Your marauder seems to have vanished!</span>"
		return 0
	message = "<span class='sevtug'>Servant [findtextEx(name, real_name) ? "[name]" : "[real_name] (as [name])"]:</span> <span class='brass'>\"[message]\"</span>" //Processed output
	src << message
	marauder << message
	for(var/M in mob_list)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			M << "[link] [message]"
	return 1

/mob/living/simple_animal/hostile/clockwork/marauder/verb/change_true_name()
	set name = "Change True Name (One-Use)"
	set desc = "Changes your true name, used to be called forth."
	set category = "Marauder"

	verbs -= /mob/living/simple_animal/hostile/clockwork/marauder/verb/change_true_name
	var/new_name = stripped_input(usr, "Enter a new true name (8-character limit).", "Change True Name","", 9)
	if(!usr)
		return 0
	if(!new_name)
		usr << "<span class='notice'>You decide against changing your true name for now.</span>"
		verbs += /mob/living/simple_animal/hostile/clockwork/marauder/verb/change_true_name //If they decide against it, let them have another opportunity
		return 0
	true_name = new_name
	usr << "<span class='heavy_brass'>You have changed your true name to </span><span class='sevtug'>\"[new_name]\"</span><span class='heavy_brass'>!</span>"
	if(host)
		host << "<span class='heavy_brass'>Your clockwork marauder has changed their true name to </span><span class='sevtug'>\"[new_name]\"</span><span class='heavy_brass'>!</span>"
	return 1

/mob/living/simple_animal/hostile/clockwork/marauder/verb/return_to_host()
	set name = "Return to Host"
	set desc = "Recalls yourself to your host, assuming you aren't already there."
	set category = "Marauder"

	if(is_in_host())
		return 0
	if(!host)
		src << "<span class='warning'>You don't have a host!</span>"
		verbs -= /mob/living/simple_animal/hostile/clockwork/marauder/verb/return_to_host
		return 0
	var/resulthealth = round((host.health / host.maxHealth) * 100, 0.5)
	if(iscarbon(host))
		resulthealth = round((abs(HEALTH_THRESHOLD_DEAD - host.health) / abs(HEALTH_THRESHOLD_DEAD - host.maxHealth)) * 100)
	host.visible_message("<span class='warning'>[host]'s skin flashes crimson!</span>", "<span class='heavy_brass'>You feel [true_name]'s consciousness settle in your mind.</span>")
	visible_message("<span class='warning'>[src] suddenly disappears!</span>", "<span class='heavy_brass'>You return to [host].</span>")
	forceMove(host)
	if(resulthealth > MARAUDER_EMERGE_THRESHOLD)
		recovering = TRUE
		src << "<span class='userdanger'>You have weakened and will need to recover before manifesting again!</span>"
	return 1

/mob/living/simple_animal/hostile/clockwork/marauder/verb/try_emerge()
	set name = "Attempt to Emerge from Host"
	set desc = "Attempts to emerge from your host, likely to only work if your host is very heavily damaged."
	set category = "Marauder"

	if(!host)
		src << "<span class='warning'>You don't have a host!</span>"
		verbs -= /mob/living/simple_animal/hostile/clockwork/marauder/verb/try_emerge
		return 0
	var/resulthealth = round((host.health / host.maxHealth) * 100, 0.5)
	if(iscarbon(host))
		resulthealth = round((abs(HEALTH_THRESHOLD_DEAD - host.health) / abs(HEALTH_THRESHOLD_DEAD - host.maxHealth)) * 100)
	if(!ratvar_awakens && host.stat != DEAD && resulthealth > MARAUDER_EMERGE_THRESHOLD) //if above 20 health, fails
		src << "<span class='warning'>Your host must be at [MARAUDER_EMERGE_THRESHOLD]% or less health to emerge like this!</span>"
		return
	return emerge_from_host(0)

/mob/living/simple_animal/hostile/clockwork/marauder/proc/emerge_from_host(hostchosen, force) //Notice that this is a proc rather than a verb - marauders can NOT exit at will, but they CAN return
	if(!is_in_host())
		return 0
	if(!force && recovering)
		if(hostchosen)
			host << "<span class='heavy_brass'>[true_name] is too weak to come forth!</span>"
		else
			host << "<span class='heavy_brass'>[true_name] tries to emerge to protect you, but it's too weak!</span>"
		src << "<span class='userdanger'>You try to come forth, but you're too weak!</span>"
		return 0
	if(hostchosen) //marauder approved
		host << "<span class='heavy_brass'>Your words echo with power as [true_name] emerges from your body!</span>"
	else
		host << "<span class='heavy_brass'>[true_name] emerges from your body to protect you!</span>"
	forceMove(get_turf(host))
	visible_message("<span class='warning'>[host]'s skin glows red as [name] emerges from their body!</span>", "<span class='brass'>You exit the safety of [host]'s body!</span>")
	return 1

/mob/living/simple_animal/hostile/clockwork/marauder/proc/is_in_host() //Checks if the marauder is inside of their host
	return host && loc == host
