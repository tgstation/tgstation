/mob/living/simple_animal/hostile/netherworld
	name = "creature"
	desc = "A sanity-destroying otherthing from the netherworld."
	icon_state = "otherthing"
	icon_living = "otherthing"
	icon_dead = "otherthing-dead"
	health = 80
	maxHealth = 80
	obj_damage = 100
	melee_damage_lower = 25
	melee_damage_upper = 50
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = list("creature")
	speak_emote = list("screams")
	gold_core_spawnable = HOSTILE_SPAWN
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	faction = list("nether")

/datum/action/innate/nether
	icon_icon = 'icons/mob/actions/actions_animal.dmi'

/mob/living/simple_animal/hostile/netherworld/migo
	name = "mi-go"
	desc = "A pinkish, fungoid crustacean-like creature with numerous pairs of clawed appendages and a head covered with waving antennae."
	speak_emote = list("screams", "clicks", "chitters", "barks", "moans", "growls", "meows", "reverberates", "roars", "squeaks", "rattles", "exclaims", "yells", "remarks", "mumbles", "jabbers", "stutters", "seethes")
	icon_state = "mi-go"
	icon_living = "mi-go"
	icon_dead = "mi-go-dead"
	attacktext = "lacerates"
	speed = -0.5
	var/static/list/migo_sounds
	deathmessage = "wails as its form turns into a pulpy mush."
	death_sound = 'sound/voice/hiss6.ogg'

/mob/living/simple_animal/hostile/netherworld/migo/Initialize()
	. = ..()
	migo_sounds = list('sound/items/bubblewrap.ogg', 'sound/items/change_jaws.ogg', 'sound/items/crowbar.ogg', 'sound/items/drink.ogg', 'sound/items/deconstruct.ogg', 'sound/items/carhorn.ogg', 'sound/items/change_drill.ogg', 'sound/items/dodgeball.ogg', 'sound/items/eatfood.ogg', 'sound/items/megaphone.ogg', 'sound/items/screwdriver.ogg', 'sound/items/weeoo1.ogg', 'sound/items/wirecutter.ogg', 'sound/items/welder.ogg', 'sound/items/zip.ogg', 'sound/items/rped.ogg', 'sound/items/ratchet.ogg', 'sound/items/polaroid1.ogg', 'sound/items/pshoom.ogg', 'sound/items/airhorn.ogg', 'sound/items/geiger/high1.ogg', 'sound/items/geiger/high2.ogg', 'sound/voice/bcreep.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/ed209_20sec.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss6.ogg', 'sound/voice/mpatchedup.ogg', 'sound/voice/mfeelbetter.ogg', 'sound/voice/human/manlaugh1.ogg', 'sound/voice/human/womanlaugh.ogg', 'sound/weapons/sear.ogg', 'sound/ambience/antag/clockcultalr.ogg', 'sound/ambience/antag/ling_aler.ogg', 'sound/ambience/antag/tatoralert.ogg', 'sound/ambience/antag/monkey.ogg', 'sound/mecha/nominal.ogg', 'sound/mecha/weapdestr.ogg', 'sound/mecha/critdestr.ogg', 'sound/mecha/imag_enh.ogg', 'sound/effects/adminhelp.ogg', 'sound/effects/alert.ogg', 'sound/effects/attackblob.ogg', 'sound/effects/bamf.ogg', 'sound/effects/blobattack.ogg', 'sound/effects/break_stone.ogg', 'sound/effects/bubbles.ogg', 'sound/effects/bubbles2.ogg', 'sound/effects/clang.ogg', 'sound/effects/clockcult_gateway_disrupted.ogg', 'sound/effects/clownstep2.ogg', 'sound/effects/curse1.ogg', 'sound/effects/dimensional_rend.ogg', 'sound/effects/doorcreaky.ogg', 'sound/effects/empulse.ogg', 'sound/effects/explosion_distant.ogg', 'sound/effects/explosionfar.ogg', 'sound/effects/explosion1.ogg', 'sound/effects/grillehit.ogg', 'sound/effects/genetics.ogg', 'sound/effects/heart_beat.ogg', 'sound/effects/hyperspace_begin.ogg', 'sound/effects/hyperspace_end.ogg', 'sound/effects/his_grace_awaken.ogg', 'sound/effects/pai_boot.ogg', 'sound/effects/phasein.ogg', 'sound/effects/picaxe1.ogg', 'sound/effects/ratvar_reveal.ogg', 'sound/effects/sparks1.ogg', 'sound/effects/smoke.ogg', 'sound/effects/splat.ogg', 'sound/effects/snap.ogg', 'sound/effects/tendril_destroyed.ogg', 'sound/effects/supermatter.ogg', 'sound/misc/desceration-01.ogg', 'sound/misc/desceration-02.ogg', 'sound/misc/desceration-03.ogg', 'sound/misc/bloblarm.ogg', 'sound/misc/airraid.ogg', 'sound/misc/bang.ogg', 'sound/misc/disco.ogg', 'sound/misc/highlander.ogg', 'sound/misc/interference.ogg', 'sound/misc/notice1.ogg', 'sound/misc/notice2.ogg', 'sound/misc/sadtrombone.ogg', 'sound/misc/slip.ogg', 'sound/misc/splort.ogg', 'sound/weapons/armbomb.ogg', 'sound/weapons/beam_sniper.ogg', 'sound/weapons/chainsawhit.ogg', 'sound/weapons/emitter.ogg', 'sound/weapons/emitter2.ogg', 'sound/weapons/blade1.ogg', 'sound/weapons/bladeslice.ogg', 'sound/weapons/blastcannon.ogg', 'sound/weapons/blaster.ogg', 'sound/weapons/bulletflyby3.ogg', 'sound/weapons/circsawhit.ogg', 'sound/weapons/cqchit2.ogg', 'sound/weapons/drill.ogg', 'sound/weapons/genhit1.ogg', 'sound/weapons/gunshot_silenced.ogg', 'sound/weapons/gunshot2.ogg', 'sound/weapons/handcuffs.ogg', 'sound/weapons/homerun.ogg', 'sound/weapons/kenetic_accel.ogg', 'sound/machines/clockcult/steam_whoosh.ogg', 'sound/machines/fryer/deep_fryer_emerge.ogg', 'sound/machines/airlock.ogg', 'sound/machines/airlock_alien_prying.ogg', 'sound/machines/airlockclose.ogg', 'sound/machines/airlockforced.ogg', 'sound/machines/airlockopen.ogg', 'sound/machines/alarm.ogg', 'sound/machines/blender.ogg', 'sound/machines/boltsdown.ogg', 'sound/machines/boltsup.ogg', 'sound/machines/buzz-sigh.ogg', 'sound/machines/buzz-two.ogg', 'sound/machines/chime.ogg', 'sound/machines/cryo_warning.ogg', 'sound/machines/defib_charge.ogg', 'sound/machines/defib_failed.ogg', 'sound/machines/defib_ready.ogg', 'sound/machines/defib_zap.ogg', 'sound/machines/deniedbeep.ogg', 'sound/machines/ding.ogg', 'sound/machines/disposalflush.ogg', 'sound/machines/door_close.ogg', 'sound/machines/door_open.ogg', 'sound/machines/engine_alert1.ogg', 'sound/machines/engine_alert2.ogg', 'sound/machines/hiss.ogg', 'sound/machines/honkbot_evil_laugh.ogg', 'sound/machines/juicer.ogg', 'sound/machines/ping.ogg', 'sound/machines/signal.ogg', 'sound/machines/synth_no.ogg', 'sound/machines/synth_yes.ogg', 'sound/machines/terminal_alert.ogg', 'sound/machines/triple_beep.ogg', 'sound/machines/twobeep.ogg', 'sound/machines/ventcrawl.ogg', 'sound/machines/warning-buzzer.ogg', 'sound/ai/outbreak5.ogg', 'sound/ai/outbreak7.ogg', 'sound/ai/poweroff.ogg', 'sound/ai/radiation.ogg', 'sound/ai/shuttlecalled.ogg', 'sound/ai/shuttledock.ogg', 'sound/ai/shuttlerecalled.ogg', 'sound/ai/aimalf.ogg') //hahahaha fuck you code divers

/mob/living/simple_animal/hostile/netherworld/migo/say(message)
	..()
	if(stat)
		return
	var/chosen_sound = pick(migo_sounds)
	playsound(src, chosen_sound, 100, TRUE)

/mob/living/simple_animal/hostile/netherworld/migo/Life()
	..()
	if(stat)
		return
	if(prob(10))
		var/chosen_sound = pick(migo_sounds)
		playsound(src, chosen_sound, 100, TRUE)

/mob/living/simple_animal/hostile/netherworld/imlagre
	name = "livligtre"
	desc = "An odd, large nether inhabitant that lifelinks with a few members of itself to reanimate."
	icon_state = "imlagre1"
	icon_living = "imlagre1"
	icon_dead = "imlagredead"
	gold_core_spawnable = NO_SPAWN
	speak_emote = list("clicks", "clackers")
	health = 50
	maxHealth = 50
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "slashes"
	deathmessage = "unwinds in a a paroxysm of laughter."
	var/list/linked_imlagres = list()
	var/laughmod = 1 //need this on the mob so it carries over to life, and i like letting admins var as much as they please
	var/list/laughs = list('sound/voice/human/manlaugh1.ogg', 'sound/voice/human/manlaugh2.ogg')
	var/playstyle_string = "<span class='swarmer'>As an imlagre, I have evolved the power to lifelink with a group of my kind, and if I am close enough, revive from them.</span>"
	var/datum/action/innate/nether/imlagre_chat/chat
	var/datum/action/innate/nether/imlagre_check/check

/mob/living/simple_animal/hostile/netherworld/imlagre/Initialize(mapload, initial = TRUE)
	. = ..()
	if(initial == TRUE)
		summon_imlagre(2)
	laughmod = rand(0.5,1.5)
	chat = new
	chat.Grant(src)
	check = new
	check.Grant(src)
	name = "livligtre ([rand(1, 999)])"

/mob/living/simple_animal/hostile/netherworld/imlagre/Destroy()
	QDEL_NULL(chat)
	QDEL_NULL(check)
	return ..()

/mob/living/simple_animal/hostile/netherworld/imlagre/Login()
	..()
	to_chat(usr, playstyle_string)
	imlagre_check() //called when new imlagres are added, needs to be it's own proc

/mob/living/simple_animal/hostile/netherworld/imlagre/proc/imlagre_check()
	if(linked_imlagres.len == 0)
		to_chat(usr, "<span class='swarmer'><b>I have no linked imlagre.</b></span>")
	else
		to_chat(usr, "<span class='swarmer'><b>I have some linked imlagre! They are...</b></span>")
		for(var/i in linked_imlagres)
			var/mob/living/simple_animal/hostile/netherworld/imlagre/theboyz = i
			to_chat(usr, "<span class='swarmer'>/improper[theboyz], in the [lowertext(get_area_name(theboyz))]!</span>")

/mob/living/simple_animal/hostile/netherworld/imlagre/proc/summon_imlagre(amt_to_add = 1)
	var/list/total_imlagres = linked_imlagres + src //this is incase you want to continue adding imlagres after you've already generated some
	for(var/i in 1 to amt_to_add) //loop that generates the buggers
		var/newguy = new /mob/living/simple_animal/hostile/netherworld/imlagre(loc, FALSE)
		total_imlagres += newguy
	for(var/mob/living/ii in total_imlagres) //loop that relates them
		var/mob/living/simple_animal/hostile/netherworld/imlagre/needs_to_sync = ii
		needs_to_sync.linked_imlagres = total_imlagres - needs_to_sync //refers to all related imlagres then removes itself

/mob/living/simple_animal/hostile/netherworld/imlagre/Life()
	. = ..()
	if(!stat)
		if(target && prob(15))
			playsound(src, src.laughs, 100, TRUE, frequency = laughmod) //much more likely to laugh if they're targetting someone
		if(prob(4))
			playsound(src, src.laughs, 100, TRUE, frequency = laughmod)


/mob/living/simple_animal/hostile/netherworld/imlagre/death()
	for(var/mob/living/i in src.linked_imlagre)
		i.Beam(src,icon_state="lichbeam",time=10,maxdistance=INFINITY)
	addtimer(CALLBACK(src, .proc/imlagre_revive), 100)
	. = ..()

/mob/living/simple_animal/hostile/netherworld/imlagre/proc/imlagre_revive()
	var/itlives = FALSE
	for(var/mob/living/simple_animal/hostile/netherworld/imlagre/i in viewers(7, src))
		if(!(i in src.linked_imlagre))
			return
		if(!i.stat) //if any of them are alive then REVIVE!!
			itlives = TRUE
			revive(TRUE)
			var/flufftext = list("wicked", "sinister", "baleful", "hideous", "wild", "malevolent")
			visible_message("<span class='danger'>[src] winds back together with a [pick(flufftext)] cackle!</span>")
			adjustBruteLoss(maxHealth * 0.5)
			break //don't want to spam visible messages, needed
	if(itlives == FALSE)
		for(var/mob/living/i in linked_imlagres)
			i.visible_message("<span class='danger'>[i]'s corpse explodes in a shower of gore!</span>")
			i.gib()
		visible_message("<span class='danger'>[src]'s corpse explodes in a shower of gore!</span>")
		gib()

/datum/action/innate/nether/imlagre_chat
	name = "Speak to the Lifelink"
	desc = "Allows you to chat and coordinate with the other Lifelinked."
	button_icon_state = "expand"

/datum/action/innate/nether/imlagre_chat/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/netherworld/imlagre))
		to_chat(owner, "<span class='userdanger'>An admin fucked you up, you should ahelp this. And, if by some chance you got an imlagre mob action button by a bug, please report it on github!</span>")
		return
	var/mob/living/simple_animal/hostile/netherworld/imlagre/I = owner
	if(I.linked_imlagres.len == 0)
		to_chat(I, "<span class='swarmer'>I have no linked imlagre!</span>")
	else
		var/input = input(I, "Enter a message to send to our fellow linked imlagre.","Mindlink", "")
		if(!input)
			return
		if(I.linked_imlagres.len >= 5)
			to_chat(I, "<span class='swarmer'>Lifelink Message to the </span><span class='danger'>SWARM</span><span class='swarmer'>: <b>[input]</b></span>")
		else
			if(I.linked_imlagres == 1)
				for(var/mob/living/i in I.linked_imlagres)
					to_chat(I, "<span class='swarmer'>Lifelink Message to [i]: <b>[input]</b></span>")
			var/list/linkedmsg = list()
			for(var/mob/living/i in I.linked_imlagres)
				linkedmsg.Add(i.name)
			to_chat(I, "<span class='swarmer'>Lifelink Message to [linkedmsg.Join(" and ")]: <b>[input]</b></span>")
		for(var/i in I.linked_imlagres)
			to_chat(i, "<span class='swarmer'>Lifelink Message from [uppertext(I.name)]: <b>[input]</b></span>")
			log_talk(I,"imlagre message:[key_name(I)] : [input]",LOGSAY)

/datum/action/innate/nether/imlagre_check
	name = "Check the Lifelink"
	desc = ""
	button_icon_state = "expand"

/datum/action/innate/nether/imlagre_check/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/netherworld/imlagre))
		to_chat(owner, "<span class='userdanger'>An admin fucked you up, you should ahelp this. And, if by some chance you got an imlagre mob action button by a bug, please report it on github!</span>")
		return
	var/mob/living/simple_animal/hostile/netherworld/imlagre/I = owner
	I.imlagre_check()

/mob/living/simple_animal/hostile/netherworld/imlagre/single

/mob/living/simple_animal/hostile/netherworld/imlagre/single/Initialize(mapload, initial = FALSE)
	..()

/mob/living/simple_animal/hostile/netherworld/blankbody
	name = "blank body"
	desc = "This looks human enough, but its flesh has an ashy texture, and it's face is featureless save an eerie smile."
	icon_state = "blank-body"
	icon_living = "blank-body"
	icon_dead = "blank-dead"
	gold_core_spawnable = NO_SPAWN
	health = 100
	maxHealth = 100
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "punches"
	deathmessage = "falls apart into a fine dust."

/mob/living/simple_animal/hostile/spawner/nether
	name = "netherworld link"
	desc = "A direct link to another dimension full of creatures not very happy to see you. <span class='warning'>Entering the link would be a very bad idea.</span>"
	icon_state = "nether"
	icon_living = "nether"
	health = 50
	maxHealth = 50
	spawn_time = 600 //1 minute
	max_mobs = 15
	icon = 'icons/mob/nest.dmi'
	spawn_text = "crawls through"
	mob_types = list(/mob/living/simple_animal/hostile/netherworld/migo, /mob/living/simple_animal/hostile/netherworld, /mob/living/simple_animal/hostile/netherworld/blankbody, /mob/living/simple_animal/hostile/netherworld/imlagre)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("nether")
	deathmessage = "shatters into oblivion."
	del_on_death = TRUE

/mob/living/simple_animal/hostile/spawner/nether/attack_hand(mob/user)
		user.visible_message("<span class='warning'>[user] is violently pulled into the link!</span>", \
						  "<span class='userdanger'>Touching the portal, you are quickly pulled through into a world of unimaginable horror!</span>")
		contents.Add(user)

/mob/living/simple_animal/hostile/spawner/nether/Life()
	..()
	var/list/C = src.get_contents()
	for(var/mob/living/M in C)
		if(M)
			playsound(src, 'sound/magic/demon_consume.ogg', 50, 1)
			M.adjustBruteLoss(60)
			new /obj/effect/gibspawner/generic(get_turf(M))
			if(M.stat == DEAD)
				var/mob/living/simple_animal/hostile/netherworld/blankbody/blank
				blank = new(loc)
				blank.name = "[M]"
				blank.desc = "It's [M], but their flesh has an ashy texture, and their face is featureless save an eerie smile."
				src.visible_message("<span class='warning'>[M] reemerges from the link!</span>")
				qdel(M)
