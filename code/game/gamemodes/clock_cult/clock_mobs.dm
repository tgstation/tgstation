
/mob/living/simple_animal/hostile/clockwork
	faction = list("ratvar")
	icon = 'icons/mob/clockwork_mobs.dmi'
	unique_name = 1
	minbodytemp = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0) //Robotic
	healable = FALSE
	del_on_death = TRUE
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

/mob/living/simple_animal/hostile/clockwork/fragment //Anima fragment: Low health and high melee damage, but slows down when struck. Created by inserting a soul vessel into an empty fragment.
	name = "anima fragment"
	desc = "An ominous humanoid shell with a spinning cogwheel as its head, lifted by a jet of blazing red flame."
	icon_state = "anime_fragment"
	health = 90
	maxHealth = 90
	speed = -1
	melee_damage_lower = 20
	melee_damage_upper = 20
	attacktext = "crushes"
	attack_sound = 'sound/magic/clockwork/anima_fragment_attack.ogg'
	loot = list(/obj/item/clockwork/component/replicant_alloy/smashed_anima_fragment)
	weather_immunities = list("lava")
	flying = 1
	playstyle_string = "<span class='heavy_brass'>You are an anima fragment</span><b>, a clockwork creation of Ratvar. As a fragment, you have low health, do decent damage, and move at \
	extreme speed in addition to being immune to extreme temperatures and pressures. Taking damage will temporarily slow you down, however. Your goal is to serve the Justiciar and his servants \
	in any way you can. You yourself are one of these servants, and will be able to utilize anything they can, assuming it doesn't require opposable thumbs.</b>"
	var/movement_delay_time //how long the fragment is slowed after being hit

/mob/living/simple_animal/hostile/clockwork/fragment/New()
	..()
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
	..(TRUE)
	return 1

/mob/living/simple_animal/hostile/clockwork/fragment/Process_Spacemove(movement_dir = 0)
	return 1

/mob/living/simple_animal/hostile/clockwork/fragment/movement_delay()
	. = ..()
	if(movement_delay_time > world.time && !ratvar_awakens)
		. += min((movement_delay_time - world.time) * 0.1, 10) //the more delay we have, the slower we go

/mob/living/simple_animal/hostile/clockwork/fragment/adjustHealth(amount)
	. = ..()
	if(!ratvar_awakens && amount > 0) //if ratvar is up we ignore movement delay
		if(movement_delay_time > world.time)
			movement_delay_time = movement_delay_time + amount*3
		else
			movement_delay_time = world.time + amount*3

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
	health = 25 //Health is governed by fatigue, but can be directly reduced by the presence of certain objects
	maxHealth = 25
	speed = 1
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	environment_smash = 1
	weather_immunities = list("lava")
	flying = 1
	loot = list(/obj/item/clockwork/component/replicant_alloy/fallen_armor)
	var/true_name = "Meme Master 69" //Required to call forth the marauder
	var/list/possible_true_names = list("Xaven", "Melange", "Ravan", "Kel", "Rama", "Geke", "Peris", "Vestra", "Skiwa") //All fairly short and easy to pronounce
	var/fatigue = 0 //Essentially what determines the marauder's power
	var/fatigue_recall_threshold = 100 //In variable form due to changed effects once Ratvar awakens
	var/mob/living/host //The mob that the marauder is living inside of
	var/recovering = FALSE //If the marauder is recovering from a large amount of fatigue
	playstyle_string = "<span class='heavy_brass'>You are a clockwork marauder</span><b>, a living extension of Ratvar's will. As a marauder, you are slow but sturdy and decently powerful \
	in addition to being immune to extreme temperatures and pressures. Your primary goal is to serve the creature that you are now a part of. You can use the Linked Minds ability in your \
	Marauder tab to communicate silently with your master, but can only exit if your master calls your true name.\n\n\
	\
	Taking damage and remaining outside of your master will cause <i>fatigue</i>, which hinders your movement speed and attacks, in addition to forcing you back into your master if it grows \
	too high. As a final note, you should probably avoid harming any fellow servants of Ratvar.</span>"

/mob/living/simple_animal/hostile/clockwork/marauder/New()
	..()
	true_name = pick(possible_true_names)

/mob/living/simple_animal/hostile/clockwork/marauder/Life()
	..()
	if(is_in_host())
		if(!ratvar_awakens && host.stat == DEAD)
			death()
			return
		adjust_fatigue(-2)
		if(!fatigue && recovering)
			src << "<span class='userdanger'>Your strength has returned. You can once again come forward!</span>"
			host << "<span class='userdanger'>Your marauder is now strong enough to come forward again!</span>"
			recovering = FALSE
	else
		if(ratvar_awakens) //If Ratvar is alive, marauders both don't take fatigue loss and move at sanic speeds
			update_fatigue()
		else
			if(host)
				if(host.stat == DEAD)
					death()
					return
				switch(get_dist(get_turf(src), get_turf(host)))
					if(2 to 4)
						adjust_fatigue(1)
					if(5)
						adjust_fatigue(3)
					if(6 to INFINITY)
						adjust_fatigue(10)
						src << "<span class='userdanger'>You're too far from your host and rapidly taking fatigue damage!</span>"
					else //right next to or on top of host
						adjust_fatigue(-1)

/mob/living/simple_animal/hostile/clockwork/marauder/Process_Spacemove(movement_dir = 0)
	return 1

/mob/living/simple_animal/hostile/clockwork/marauder/proc/update_fatigue()
	if(!ratvar_awakens && host && host.stat == DEAD)
		death()
		return
	if(ratvar_awakens)
		speed = -1
		melee_damage_lower = 30
		melee_damage_upper = 30
		attacktext = "devastates"
	else
		switch(fatigue)
			if(0 to 10) //Bonuses to speed and damage at normal fatigue levels
				speed = 0
				melee_damage_lower = 15
				melee_damage_upper = 15
				attacktext = "viciously slashes"
			if(10 to 25)
				speed = initial(speed)
				melee_damage_lower = initial(melee_damage_lower)
				melee_damage_upper = initial(melee_damage_upper)
				attacktext = initial(attacktext)
			if(25 to 50) //Damage decrease, but not speed
				melee_damage_lower = 7
				melee_damage_upper = 7
				attacktext = "lightly slashes"
			if(50 to 75) //Speed decrease
				speed = 2
			if(75 to 99) //Massive speed decrease and weak melee attacks
				speed = 3
				melee_damage_lower = 5
				melee_damage_upper = 5
				attacktext = "weakly slashes"
			if(99 to fatigue_recall_threshold)
				src << "<span class='userdanger'>The fatigue becomes too much!</span>"
				if(host)
					src << "<span class='userdanger'>You retreat to [host] - you will have to wait before being deployed again.</span>"
					host << "<span class='userdanger'>[true_name] is too fatigued to fight - you will need to wait until they are strong enough.</span>"
					recovering = TRUE
					return_to_host()
				else
					death() //Shouldn't ever happen, but...

/mob/living/simple_animal/hostile/clockwork/marauder/death(gibbed)
	..(TRUE)
	emerge_from_host(0, 1)
	visible_message("<span class='warning'>[src]'s equipment clatters lifelessly to the ground as the red flames within dissipate.</span>", \
	"<span class='userdanger'>Your equipment falls away. You feel a moment of confusion before your fragile form is annihilated.</span>")
	return 1

/mob/living/simple_animal/hostile/clockwork/marauder/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Fatigue: [fatigue]/[fatigue_recall_threshold]")
		stat(null, "Current True Name: [true_name]")
		stat(null, "Host: [host ? host : "NONE"]")
		if(host)
			var/resulthealth
			resulthealth = round((abs(config.health_threshold_dead - host.health) / abs(config.health_threshold_dead - host.maxHealth)) * 100)
			stat(null, "Host Health: [resulthealth]%")
			if(resulthealth > 60)
				stat(null, "You are [recovering ? "unable to deploy" : "can deploy on hearing True Name"]!")
			else
				stat(null, "You are [recovering ? "unable to deploy" : "can deploy to protect your host"]!")
		stat(null, "You do [melee_damage_upper] on melee attacks.")

/mob/living/simple_animal/hostile/clockwork/marauder/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans)
	..()
	if(findtext(message, true_name) && is_in_host()) //Called or revealed by hearing their true name
		if(speaker == host)
			emerge_from_host(1)
		else
			src << "<span class='warning'><b>You hear your true name and partially emerge before you can stop yourself!</b></span>"
			host.visible_message("<span class='warning'>[host]'s skin flashes crimson!</span>", "<span class='warning'><b>Your marauder instinctively reacts to its true name!</b></span>")

/mob/living/simple_animal/hostile/clockwork/marauder/say(message)
	if(is_in_host())
		message = "<span class='heavy_brass'>Marauder [true_name]:</span> <span class='brass'>\"[message]\"</span>" //Automatic linked minds
		src << message
		host << message
		return 1
	..()

/mob/living/simple_animal/hostile/clockwork/marauder/adjustHealth(amount) //Fatigue damage
	for(var/mob/living/L in range(1, src))
		if(L.null_rod_check()) //Null rods allow direct damage
			src << "<span class='userdanger'>The power of a holy artifact bypasses your armor and wounds you directly!</span>"
			return ..()
	return adjust_fatigue(amount)

/mob/living/simple_animal/hostile/clockwork/marauder/AttackingTarget()
	if(is_in_host())
		return 0
	..()

/mob/living/simple_animal/hostile/clockwork/marauder/proc/adjust_fatigue(amount) //Adds or removes the given amount of fatigue
	if(!ratvar_awakens || amount < 0)
		fatigue = Clamp(fatigue + amount, 0, fatigue_recall_threshold)
		update_fatigue()
	else
		amount = 0
	return amount

/mob/living/simple_animal/hostile/clockwork/marauder/verb/linked_minds() //Discreet communications between a marauder and its host
	set name = "Linked Minds"
	set desc = "Silently communicates with your master."
	set category = "Marauder"

	if(!host) //Verb isn't removed because they might gain one... somehow
		usr << "<span class='warning'>You don't have a host!</span>"
		return 0
	var/message = stripped_input(usr, "Enter a message to tell your host.", "Telepathy")// as null|anything
	if(!usr || !message)
		return 0
	if(!host)
		usr << "<span class='warning'>Your host seems to have vanished!</span>"
		return 0
	message = "<span class='heavy_brass'>Marauder [true_name]:</span> <span class='brass'>\"[message]\"</span>" //Processed output
	usr << message
	host << message
	return 1

/mob/living/proc/talk_with_marauder() //See above - this is the host version
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
			verbs -= src
			return 0
	var/message = stripped_input(src, "Enter a message to tell your marauder.", "Telepathy")// as null|anything
	if(!src || !message)
		return 0
	if(!marauder)
		usr << "<span class='warning'>Your marauder seems to have vanished!</span>"
		return 0
	message = "<span class='heavy_brass'>Servant [name == real_name ? name : "[real_name] (as [name])"]:</span> <span class='brass'>\"[message]\"</span>" //Processed output
	src << message
	marauder << message
	return 1

/mob/living/simple_animal/hostile/clockwork/marauder/verb/change_true_name()
	set name = "Change True Name (One-Use)"
	set desc = "Changes your true name, used to be called forth."
	set category = "Marauder"

	verbs -= /mob/living/simple_animal/hostile/clockwork/marauder/verb/change_true_name
	var/new_name = stripped_input(usr, "Enter a new true name (20-character limit).", "Change True Name")// as null|anything
	if(!usr)
		return 0
	if(!new_name)
		usr << "<span class='notice'>You decide against changing your true name for now.</span>"
		verbs += /mob/living/simple_animal/hostile/clockwork/marauder/verb/change_true_name //If they decide against it, let them have another opportunity
		return 0
	new_name = dd_limittext(new_name, 20)
	true_name = new_name
	usr << "<span class='userdanger'>You have changed your true name to \"[new_name]\"!</span>"
	if(host)
		host << "<span class='userdanger'>Your clockwork marauder has changed their true name to \"[new_name]\"!</span>"
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
	host << "<span class='heavy_brass'>You feel [true_name]'s consciousness settle in your mind.</span>"
	visible_message("<span class='warning'>[src] is yanked into [host]'s body!</span>", "<span class='brass'>You return to [host].</span>")
	forceMove(host)
	return 1

/mob/living/simple_animal/hostile/clockwork/marauder/verb/try_emerge()
	set name = "Attempt to Emerge from Host"
	set desc = "Attempts to emerge from your host, likely to only work if your host is very heavily damaged."
	set category = "Marauder"

	if(!host)
		src << "<span class='warning'>You don't have a host!</span>"
		verbs -= /mob/living/simple_animal/hostile/clockwork/marauder/verb/try_emerge
		return 0
	var/resulthealth
	resulthealth = round((abs(config.health_threshold_dead - host.health) / abs(config.health_threshold_dead - host.maxHealth)) * 100)
	if(!ratvar_awakens && host.stat != DEAD && resulthealth > 60) //if above 20 health, fails
		src << "<span class='warning'>Your host must be at 60% or less health to emerge like this!</span>"
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



/mob/living/simple_animal/hostile/clockwork/reclaimer
	name = "clockwork reclaimer"
	desc = "A tiny clockwork arachnid with a single cogwheel spinning quickly in its head. Its legs blur, too fast to be seen clearly."
	icon_state = "clockwork_reclaimer"
	health = 50
	maxHealth = 50
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "slams into"
	attack_sound = 'sound/magic/clockwork/anima_fragment_attack.ogg'
	ventcrawler = 2
	playstyle_string = "<span class='heavy_brass'>You are a clockwork reclaimer</span><b>, a harbringer of the Justiciar's light. You can crawl through vents to move more swiftly. Your \
	goal: purge all untruths and honor Ratvar. You may alt-click a valid target to break yourself apart and convert the target to a servant of Ratvar.</b>"

/mob/living/simple_animal/hostile/clockwork/reclaimer/New()
	..()
	if(prob(1))
		real_name = "jehovah's witness"
		name = real_name
	spawn(1)
		if(mind)
			mind.special_role = null
		add_servant_of_ratvar(src, TRUE)
		src << playstyle_string

/mob/living/simple_animal/hostile/clockwork/reclaimer/Life()
	..()
	if(ishuman(loc))
		var/mob/living/carbon/human/L = loc
		if(L.stat || !L.client)
			disengage()

/mob/living/simple_animal/hostile/clockwork/reclaimer/death()
	..(1)
	visible_message("<span class='warning'>[src] bursts into deadly shrapnel!</span>")
	for(var/mob/living/carbon/C in range(2, src))
		C.adjustBruteLoss(rand(3, 5))
	qdel(src)

/mob/living/simple_animal/hostile/clockwork/reclaimer/AltClickOn(atom/movable/A)
	if(!ishuman(A))
		return ..()
	var/mob/living/carbon/human/H = A
	if(is_servant_of_ratvar(H) || H.stat || (H.mind && !H.client))
		src << "<span class='warning'>[H] isn't a valid target! Valid targets are conscious non-servants.</span>"
		return 0
	if(get_dist(src, H) > 3)
		src << "<span class='warning'>You need to be closer to dominate [H]!</span>"
		return 0
	visible_message("<span class='warning'>[src] rockets with blinding speed towards [H]!</span>", "<span class='heavy_brass'>You leap with blinding speed towards [H]'s head!</span>")
	for(var/i = 9, i > 0, i -= 3)
		pixel_y += i
		sleep(1)
	icon_state = "[initial(icon_state)]_charging"
	while(loc != H.loc)
		if(!H)
			icon_state = initial(icon_state)
			return 0
		sleep(1)
		forceMove(get_step(src, get_dir(src, H)))
	if(H.head)
		H.visible_message("<span class='warning'>[src] tears apart [H]'s [H.name]!</span>")
		H.unEquip(H.head)
		qdel(H.head)
	H.visible_message("<span class='warning'>[src] latches onto [H]'s head and digs its claws in!</span>", "<span class='userdanger'>[src] leaps onto your head and impales its claws deep!</span>")
	add_servant_of_ratvar(H)
	H.equip_to_slot_or_del(new/obj/item/clothing/head/helmet/clockwork/reclaimer(null), slot_head)
	loc = H
	icon_state = initial(icon_state)
	status_flags += GODMODE
	src << "<span class='userdanger'>ASSIMILATION SUCCESSFUL.</span>"
	H << "<span class='userdanger'>ASSIMILATION SUCCESSFUL.</span>"
	H.say("ASSIMILATION SUCCESSFUL.")
	if(!H.mind)
		mind.transfer_to(H)
	return 1

/mob/living/simple_animal/hostile/clockwork/reclaimer/verb/disengage()
	set name = "Disgengage From Host"
	set desc = "Jumps off of your host if you have one, freeing their mind but allowing you movement."
	set category = "Clockwork"

	if(!ishuman(usr.loc))
		usr << "<span class='warning'>You have no host! Alt-click on a non-servant to enslave them.</span>"
		return
	var/mob/living/carbon/human/L = usr.loc
	usr.loc = get_turf(L)
	pixel_y = initial(pixel_y)
	usr.visible_message("<span class='warning'>[usr] jumps off of [L]'s head!</span>", "<span class='notice'>You disengage from your host.</span>")
	usr.status_flags -= GODMODE
	remove_servant_of_ratvar(L)
	L.unEquip(L.head)
	qdel(L.head)



/mob/living/mind_control_holder
	name = "imprisoned mind"
	desc = "A helpless mind, imprisoned in its own body."
	stat = 0
	status_flags = GODMODE

/mob/living/mind_control_holder/say()
	return 0
