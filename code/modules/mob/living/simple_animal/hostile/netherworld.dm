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
	speak_emote = list("screams", "clicks", "chitters", "barks", "moans", "growls", "meows", "reverberates", "roars", "squeaks", "rattles", "exclaims", "yells")
	gold_core_spawnable = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	faction = list("nether")

/mob/living/simple_animal/hostile/netherworld/migo
	name = "mi-go"
	desc = "A pinkish, fungoid crustacean-like creature with numerous pairs of clawed appendages and a head covered with waving antennae."
	icon_state = "mi-go"
	icon_living = "mi-go"
	icon_dead = "mi-go-dead"
	attacktext = "lacerates"
	var/list/migo_sounds
	deathmessage = "wails as it's form turns into a pulpy mush."
	death_sound = 'sound/voice/hiss6.ogg'

/mob/living/simple_animal/hostile/netherworld/migo/Initialize()
    . = ..()
    migo_sounds = world.file2list("strings/migo_sounds.txt")

/mob/living/simple_animal/hostile/netherworld/migo/say()
	..()
	var/chosen_sound = pick(migo_sounds)
	playsound(src, chosen_sound, 100, TRUE)

/mob/living/simple_animal/hostile/netherworld/migo/Life()
	..()
	if(prob(10))
		var/chosen_sound = pick(migo_sounds)
		playsound(src, chosen_sound, 100, TRUE)

/mob/living/simple_animal/hostile/spawner/nether
	name = "netherworld link"
	desc = "A direct link to another dimension full of creatures not very happy to see you. <span class='warning'>Entering the link would be a very bad idea.</span>"
	icon_state = "nether"
	icon_living = "nether"
	health = 20
	maxHealth = 20
	max_mobs = 7
	icon = 'icons/mob/nest.dmi'
	spawn_text = "crawls through"
	mob_type = /mob/living/simple_animal/hostile/netherworld/migo
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("nether")

/mob/living/simple_animal/hostile/spawner/nether/attack_hand(mob/user)
	user.visible_message("<span class='warning'>[user] is violently pulled into the link!</span>", \
						  "<span class='userdanger'>touching the portal, you are quickly pulled through into a world of unimaginable horror!</span>")
	qdel(user)