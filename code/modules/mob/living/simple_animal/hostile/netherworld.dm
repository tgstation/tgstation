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
	gold_core_spawnable = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	faction = list("nether")

/mob/living/simple_animal/hostile/netherworld/migo
	name = "mi-go"
	desc = "A pinkish, fungoid crustacean-like creature with numerous pairs of clawed appendages and a head covered with waving antennae."
	speak_emote = list("screams", "clicks", "chitters", "barks", "moans", "growls", "meows", "reverberates", "roars", "squeaks", "rattles", "exclaims", "yells", "remarks", "mumbles", "jabbers", "stutters", "seethes")
	icon_state = "mi-go"
	icon_living = "mi-go"
	icon_dead = "mi-go-dead"
	attacktext = "lacerates"
	speed = -0.5
	var/list/migo_sounds
	deathmessage = "wails as its form turns into a pulpy mush."
	death_sound = 'sound/voice/hiss6.ogg'

/mob/living/simple_animal/hostile/netherworld/migo/Initialize()
    . = ..()
    migo_sounds = list("sound/items/bubblewrap.ogg", "sound/items/change_jaws.ogg", "sound/items/crowbar.ogg", "sound/items/drink.ogg", "sound/items/deconstruct.ogg", "sound/items/carhorn.ogg", "sound/items/change_drill.ogg", "sound/items/dodgeball.ogg", "sound/items/eatfood.ogg", "sound/items/megaphone.ogg", "sound/items/screwdriver.ogg", "sound/items/weeoo1.ogg", "sound/items/wirecutter.ogg", "sound/items/welder.ogg", "sound/items/zip.ogg", "sound/items/rped.ogg", "sound/items/rachet.ogg", "sound/items/polaroid1.ogg", "sound/items/pshoom.ogg", "sound/items/airhorn.ogg", "sound/items/geiger/high1.ogg", "sound/items/geiger/high2.ogg", "sound/voice/bcreep.ogg", "sound/voice/biamthelaw.ogg", "sound/voice/ed209_20sec.ogg", "sound/voice/hiss3.ogg", "sound/voice/hiss6.ogg", "sound/voice/mpatchedup.ogg", "sound/voice/mfeelbetter.ogg", "sound/voice/human/manlaugh1.ogg", "sound/voice/human/womanlaugh.ogg", "sound/weapons/sear.ogg", "sound/ambience/antag/clockcultalr.ogg", "sound/ambience/antag/ling_aler.ogg", "sound/ambience/antag/tatoralert.ogg", "sound/ambience/antag/monkey.ogg", "sound/mecha/nominal.ogg", "sound/mecha/weapdestr.ogg", "sound/mecha/critdestr.ogg", "sound/mecha/imag_enh.ogg", "sound/effects/adminhelp.ogg", "sound/effects/alert.ogg", "sound/effects/attackblob.ogg", "sound/effects/bamf.ogg", "sound/effects/blobattack.oggsound/effects/break_stone.oggsound/effects/bubbles.oggsound/effects/bubbles2.oggsound/effects/clang.oggsound/effects/clockcult_gateway_disrupted.oggsound/effects/clownstep2.oggsound/effects/curse1.oggsound/effects/dimensional_rend.oggsound/effects/doorcreaky.oggsound/effects/empulse.oggsound/effects/explosion_distant.oggsound/effects/explosion_far.oggsound/effects/explosion1.oggsound/effects/grillehit.oggsound/effects/genetics.oggsound/effects/heart_beat.oggsound/effects/hyperspace_begin.oggsound/effects/hyperspace_end.oggsound/effects/his_grace_awaken.oggsound/effects/pai_boot.oggsound/effects/phasein.oggsound/effects/picaxe1.oggsound/effects/ratvar_reveal.oggsound/effects/sparks1.oggsound/effects/smoke.oggsound/effects/splat.oggsound/effects/snap.oggsound/effects/tendril_destroyed.oggsound/effects/supermatter.oggsound/misc/desceration-01.ogg", "sound/misc/desceration-02.ogg", "sound/misc/desceration-03.oggsound/misc/bloblarm.oggsound/misc/airraid.oggsound/misc/bang.ogg", "sound/misc/disc.ogg", "sound/misc/highlander.ogg", "sound/misc/interference.ogg", "sound/misc/notice1.ogg", "sound/misc/notice2.ogg", "sound/misc/sadtrombone.ogg", "sound/misc/slip.ogg", "sound/misc/splort.oggsound/weapons/armbomb.oggsound/weapons/beam_sniper.ogg", "sound/weapons/chainsawhit.ogg", "sound/weapons/emitter.ogg", "sound/weapons/emitter2.ogg", "sound/weapon/blade1.ogg", "sound/weapon/bladeslice.ogg", "sound/weapon/blastcannon.ogg", "sound/weapon/blaster.ogg", "sound/weapon/bulletflyby3.ogg", "sound/weapon/circsawhit.ogg", "sound/weapon/cqchit2.ogg", "sound/weapon/drill.ogg", "sound/weapon/genhit1.ogg", "sound/weapon/gunshot_silenced.ogg", "sound/weapon/gunshot2.oggsound/weapon/handcuffs.oggsound/weapon/homerun.oggsound/weapon/kenetic_accel.ogg", "sound/machines/clockcult/steam_woosh.ogg", "sound/machines/fryer/deep_fryer_emerge.ogg", "sound/machines/airlock.ogg", "sound/machines/airlock_alien_prying.ogg", "sound/machines/airlockclose.oggsound/machines/airlockforced.ogg", "sound/machines/airlockopen.ogg", "sound/machines/alarm.ogg", "sound/machines/blender.ogg", "sound/machines/boltsdown.ogg", "sound/machines/boltsup.oggsound/machines/buzz-sigh.oggsound/machines/buzz-two.oggsound/machines/chime.oggsound/machines/cryo_warning.ogg", "sound/machines/defib_charge.ogg", "sound/machines/defib_failed.ogg", "sound/machines/defib_ready.ogg", "sound/machines/defib_zap.ogg", "sound/machines/deniedbeep.ogg", "sound/machines/ding.ogg", "sound/machines/disposalflush.ogg", "sound/machines/door_close.ogg", "sound/machines/door_open.ogg", "sound/machines/engine_alert1.oggsound/machines/engine_alert2.oggsound/machines/hiss.oggsound/machines/honkbot_evil_laugh.ogg", "sound/machines/juicer.ogg", "sound/machines/ping.ogg", "sound/machines/signal.ogg", "sound/machines/synth_no.ogg", "sound/machines/synth_yes.ogg", "sound/machines/terminal_alert.ogg", "sound/machines/triple_beep.oggsound/machines/twobeep.oggsound/machines/ventcrawl.ogg", "sound/machines/warning-buzzer.ogg", "sound/ai/outbreak5.ogg", "sound/ai/outbreak7.ogg", "sound/ai/poweroff.ogg", "sound/ai/radiation.ogg", "sound/ai/shuttlecalled.ogg", "sound/ai/shuttledock.ogg", "sound/ai/shuttlerecalled.ogg", "sound/ai/aimalf.ogg")

/mob/living/simple_animal/hostile/netherworld/migo/say()
	..()
	if(stat)
		return
	var/chosen_sound = pick(migo_sounds)
	playsound(src, chosen_sound, 100, TRUE)

/mob/living/simple_animal/hostile/netherworld/migo/Life()
	..()
	if(prob(10))
		if(stat)
			return
		var/chosen_sound = pick(migo_sounds)
		playsound(src, chosen_sound, 100, TRUE)

/mob/living/simple_animal/hostile/netherworld/blankbody
	name = "blank body"
	desc = "This looks human enough, but its flesh has an ashy texture, and it's face is featureless save an eerie smile."
	icon_state = "blank-body"
	icon_living = "blank-body"
	icon_dead = "blank-dead"
	gold_core_spawnable = 0
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
	spawn_time = 50 //5 seconds
	max_mobs = 15
	icon = 'icons/mob/nest.dmi'
	spawn_text = "crawls through"
	mob_type = /mob/living/simple_animal/hostile/netherworld/migo
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("nether")
	deathmessage = "shatters into oblivion."
	del_on_death = 1

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
			new /obj/effect/gibspawner/human(get_turf(M))
			if(M.stat == DEAD)
				var/mob/living/simple_animal/hostile/netherworld/blankbody/blank
				blank = new(get_turf(src))
				blank.name = "[M]"
				blank.desc = "It's [M], but their flesh has an ashy texture, and their face is featureless save an eerie smile."
				src.visible_message("<span class='warning'>[M] reemerges from the link!</span>")
				qdel(M)