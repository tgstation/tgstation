
//lava hermit

//Malfunctioning cryostasis sleepers: Spawns in makeshift shelters in lavaland. Ghosts become hermits with knowledge of how they got to where they are now.
/obj/effect/mob_spawn/ghost_role/human/hermit
	name = "malfunctioning cryostasis sleeper"
	desc = "A humming sleeper with a silhouetted occupant inside. Its stasis function is broken and it's likely being used as a bed."
	prompt_name = "a stranded hermit"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper"
	outfit = /datum/outfit/hermit
	you_are_text = "You've been stranded in this godless prison of a planet for longer than you can remember."
	flavour_text = "Each day you barely scrape by, and between the terrible conditions of your makeshift shelter, \
	the hostile creatures, and the ash drakes swooping down from the cloudless skies, all you can wish for is the feel of soft grass between your toes and \
	the fresh air of Earth. These thoughts are dispelled by yet another recollection of how you got here... "
	spawner_job_path = /datum/job/hermit

/obj/effect/mob_spawn/ghost_role/human/hermit/Initialize(mapload)
	. = ..()
	outfit = new outfit //who cares equip outfit works with outfit as a path or an instance
	var/arrpee = rand(1,4)
	switch(arrpee)
		if(1)
			flavour_text += "you were a [pick("arms dealer", "shipwright", "docking manager")]'s assistant on a small trading station several sectors from here. Raiders attacked, and there was \
			only one pod left when you got to the escape bay. You took it and launched it alone, and the crowd of terrified faces crowding at the airlock door as your pod's engines burst to \
			life and sent you to this hell are forever branded into your memory."
			outfit.uniform = /obj/item/clothing/under/misc/assistantformal
		if(2)
			flavour_text += "you're an exile from the Tiger Cooperative. Their technological fanaticism drove you to question the power and beliefs of the Exolitics, and they saw you as a \
			heretic and subjected you to hours of horrible torture. You were hours away from execution when a high-ranking friend of yours in the Cooperative managed to secure you a pod, \
			scrambled its destination's coordinates, and launched it. You awoke from stasis when you landed and have been surviving - barely - ever since."
			outfit.uniform = /obj/item/clothing/under/rank/prisoner
			outfit.shoes = /obj/item/clothing/shoes/sneakers/orange
		if(3)
			flavour_text += "you were a doctor on one of Nanotrasen's space stations, but you left behind that damn corporation's tyranny and everything it stood for. From a metaphorical hell \
			to a literal one, you find yourself nonetheless missing the recycled air and warm floors of what you left behind... but you'd still rather be here than there."
			outfit.uniform = /obj/item/clothing/under/rank/medical/scrubs/blue
			outfit.suit = /obj/item/clothing/suit/toggle/labcoat
			outfit.back = /obj/item/storage/backpack/medic
		if(4)
			flavour_text += "you were always joked about by your friends for \"not playing with a full deck\", as they so kindly put it. It seems that they were right when you, on a tour \
			at one of Nanotrasen's state-of-the-art research facilities, were in one of the escape pods alone and saw the red button. It was big and shiny, and it caught your eye. You pressed \
			it, and after a terrifying and fast ride for days, you landed here. You've had time to wisen up since then, and you think that your old friends wouldn't be laughing now."

/obj/effect/mob_spawn/ghost_role/human/hermit/Destroy()
	new/obj/structure/fluff/empty_cryostasis_sleeper(get_turf(src))
	return ..()

/datum/outfit/hermit
	name = "Lavaland Hermit"
	uniform = /obj/item/clothing/under/color/grey/ancient
	back = /obj/item/storage/backpack
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/sneakers/black
	l_pocket = /obj/item/tank/internals/emergency_oxygen
	r_pocket = /obj/item/flashlight/glowstick

//Icebox version of hermit
/obj/effect/mob_spawn/ghost_role/human/hermit/icemoon
	name = "cryostasis bed"
	desc = "A humming sleeper with a silhouetted occupant inside. Its stasis function is broken and it's likely being used as a bed."
	prompt_name = "a grumpy old man"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper"
	outfit = /datum/outfit/hermit
	you_are_text = "You've been hunting polar bears for 40 years now! What do these 'NaniteTrans' newcomers want?"
	flavour_text = "You were fine hunting polar bears and taming wolves out here on your own, \
		but now that there are corporate stooges around, you need to watch your step. "
	spawner_job_path = /datum/job/hermit

//beach dome

/obj/effect/mob_spawn/ghost_role/human/beach
	prompt_name = "a beach bum"
	name = "beach bum sleeper"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	you_are_text = "You're, like, totally a dudebro, bruh."
	flavour_text = "Ch'yea. You came here, like, on spring break, hopin' to pick up some bangin' hot chicks, y'knaw?"
	spawner_job_path = /datum/job/beach_bum
	outfit = /datum/outfit/beachbum

/obj/effect/mob_spawn/ghost_role/human/beach/lifeguard
	you_are_text = "You're a spunky lifeguard!"
	flavour_text = "It's up to you to make sure nobody drowns or gets eaten by sharks and stuff."
	name = "lifeguard sleeper"
	outfit = /datum/outfit/beachbum/lifeguard

/obj/effect/mob_spawn/ghost_role/human/beach/lifeguard/special(mob/living/carbon/human/lifeguard, mob/mob_possessor)
	. = ..()
	lifeguard.gender = FEMALE
	lifeguard.update_body()

/datum/outfit/beachbum
	name = "Beach Bum"
	id = /obj/item/card/id/advanced
	uniform = /obj/item/clothing/under/pants/jeans
	glasses = /obj/item/clothing/glasses/sunglasses
	l_pocket = /obj/item/food/pizzaslice/dank
	r_pocket = /obj/item/storage/wallet/random

/datum/outfit/beachbum/post_equip(mob/living/carbon/human/bum, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	bum.dna.add_mutation(/datum/mutation/human/stoner)

/datum/outfit/beachbum/lifeguard
	name = "Beach Lifeguard"
	id_trim = /datum/id_trim/lifeguard
	uniform = /obj/item/clothing/under/shorts/red

/obj/effect/mob_spawn/ghost_role/human/bartender
	name = "bartender sleeper"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "a space bartender"
	you_are_text = "You are a space bartender!"
	flavour_text = "Time to mix drinks and change lives. Smoking space drugs makes it easier to understand your patrons' odd dialect."
	spawner_job_path = /datum/job/space_bartender
	outfit = /datum/outfit/spacebartender

/datum/outfit/spacebartender
	name = "Space Bartender"
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/space_bartender
	uniform = /obj/item/clothing/under/rank/civilian/bartender
	suit = /obj/item/clothing/suit/armor/vest
	back = /obj/item/storage/backpack
	glasses = /obj/item/clothing/glasses/sunglasses/reagent
	shoes = /obj/item/clothing/shoes/sneakers/black

/datum/outfit/spacebartender/post_equip(mob/living/carbon/human/bartender, visualsOnly = FALSE)
	. = ..()
	var/obj/item/card/id/id_card = bartender.wear_id
	if(bartender.age < AGE_MINOR)
		id_card.registered_age = AGE_MINOR
		to_chat(bartender, span_notice("You're not technically old enough to access or serve alcohol, but your ID has been discreetly modified to display your age as [AGE_MINOR]. Try to keep that a secret!"))

//Preserved terrarium/seed vault: Spawns in seed vault structures in lavaland. Ghosts become plantpeople and are advised to begin growing plants in the room near them.
/obj/effect/mob_spawn/ghost_role/human/seed_vault
	name = "preserved terrarium"
	desc = "An ancient machine that seems to be used for storing plant matter. The glass is obstructed by a mat of vines."
	prompt_name = "lifebringer"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "terrarium"
	density = TRUE
	mob_species = /datum/species/pod
	you_are_text = "You are a sentient ecosystem, an example of the mastery over life that your creators possessed."
	flavour_text = "Your masters, benevolent as they were, created uncounted seed vaults and spread them across \
	the universe to every planet they could chart. You are in one such seed vault. \
	Your goal is to protect the vault you are assigned to, cultivate the seeds passed onto you, \
	and eventually bring life to this desolate planet while waiting for contact from your creators. \
	Estimated time of last contact: Deployment, 5000 millennia ago."
	spawner_job_path = /datum/job/lifebringer

/obj/effect/mob_spawn/ghost_role/human/seed_vault/Initialize(mapload)
	. = ..()
	mob_name = pick("Tomato", "Potato", "Broccoli", "Carrot", "Ambrosia", "Pumpkin", "Ivy", "Kudzu", "Banana", "Moss", "Flower", "Bloom", "Root", "Bark", "Glowshroom", "Petal", "Leaf", \
	"Venus", "Sprout","Cocoa", "Strawberry", "Citrus", "Oak", "Cactus", "Pepper", "Juniper")

/obj/effect/mob_spawn/ghost_role/human/seed_vault/Destroy()
	new/obj/structure/fluff/empty_terrarium(get_turf(src))
	return ..()

//Ash walker eggs: Spawns in ash walker dens in lavaland. Ghosts become unbreathing lizards that worship the Necropolis and are advised to retrieve corpses to create more ash walkers.

/obj/structure/ash_walker_eggshell
	name = "ash walker egg"
	desc = "A man-sized yellow egg, spawned from some unfathomable creature. A humanoid silhouette lurks within. The egg shell looks resistant to temperature but otherwise rather brittle."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | FREEZE_PROOF
	max_integrity = 80
	var/obj/effect/mob_spawn/ghost_role/human/ash_walker/egg

/obj/structure/ash_walker_eggshell/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0) //lifted from xeno eggs
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/attackblob.ogg', 100, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			if(damage_amount)
				playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/ash_walker_eggshell/attack_ghost(mob/user) //Pass on ghost clicks to the mob spawner
	if(egg)
		egg.attack_ghost(user)
	. = ..()

/obj/structure/ash_walker_eggshell/Destroy()
	if(!egg)
		return ..()
	var/mob/living/carbon/human/yolk = new /mob/living/carbon/human/(get_turf(src))
	yolk.fully_replace_character_name(null,random_unique_lizard_name(gender))
	yolk.set_species(/datum/species/lizard/ashwalker)
	yolk.underwear = "Nude"
	yolk.equipOutfit(/datum/outfit/ashwalker)//this is an authentic mess we're making
	yolk.update_body()
	yolk.gib()
	QDEL_NULL(egg)
	return ..()

/obj/effect/mob_spawn/ghost_role/human/ash_walker
	name = "ash walker egg"
	desc = "A man-sized yellow egg, spawned from some unfathomable creature. A humanoid silhouette lurks within."
	prompt_name = "necropolis ash walker"
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	mob_species = /datum/species/lizard/ashwalker
	outfit = /datum/outfit/ashwalker
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	you_are_text = "You are an ash walker. Your tribe worships the Necropolis."
	flavour_text = "The wastes are sacred ground, its monsters a blessed bounty. \
	You have seen lights in the distance... they foreshadow the arrival of outsiders that seek to tear apart the Necropolis and its domain. \
	Fresh sacrifices for your nest."
	spawner_job_path = /datum/job/ash_walker
	var/datum/team/ashwalkers/team
	var/obj/structure/ash_walker_eggshell/eggshell

/obj/effect/mob_spawn/ghost_role/human/ash_walker/Destroy()
	eggshell = null
	return ..()

/obj/effect/mob_spawn/ghost_role/human/ash_walker/allow_spawn(mob/user, silent = FALSE)
	if(!(user.key in team.players_spawned))//one per person unless you get a bonus spawn
		return TRUE
	if(!silent)
		to_chat(user, span_warning("You have exhausted your usefulness to the Necropolis."))
	return FALSE

/obj/effect/mob_spawn/ghost_role/human/ash_walker/special(mob/living/carbon/human/spawned_human)
	. = ..()
	spawned_human.fully_replace_character_name(null,random_unique_lizard_name(gender))
	to_chat(spawned_human, "<b>Drag the corpses of men and beasts to your nest. It will absorb them to create more of your kind. Invade the strange structure of the outsiders if you must. Do not cause unnecessary destruction, as littering the wastes with ugly wreckage is certain to not gain you favor. Glory to the Necropolis!</b>")

	spawned_human.mind.add_antag_datum(/datum/antagonist/ashwalker, team)

	spawned_human.remove_language(/datum/language/common)
	team.players_spawned += (spawned_human.key)
	eggshell.egg = null
	QDEL_NULL(eggshell)

/obj/effect/mob_spawn/ghost_role/human/ash_walker/Initialize(mapload, datum/team/ashwalkers/ashteam)
	. = ..()
	var/area/spawner_area = get_area(src)
	team = ashteam
	eggshell = new /obj/structure/ash_walker_eggshell(get_turf(loc))
	eggshell.egg = src
	src.forceMove(eggshell)
	if(spawner_area)
		notify_ghosts("An ash walker egg is ready to hatch in \the [spawner_area.name].", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_ASHWALKER)

/datum/outfit/ashwalker
	name = "Ash Walker"
	head = /obj/item/clothing/head/helmet/gladiator
	uniform = /obj/item/clothing/under/costume/gladiator/ash_walker

/datum/outfit/ashwalker/spear
	name = "Ash Walker - Spear"
	back = /obj/item/spear/bonespear

///Syndicate Listening Post

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate
	name = "Syndicate Bioweapon Scientist"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	prompt_name = "a syndicate science technician"
	you_are_text = "You are a syndicate science technician, employed in a top secret research facility developing biological weapons."
	flavour_text = "Unfortunately, your hated enemy, Nanotrasen, has begun mining in this sector. Continue your research as best you can, and try to keep a low profile."
	important_text = "The base is rigged with explosives, DO NOT abandon it or let it fall into enemy hands!"
	outfit = /datum/outfit/lavaland_syndicate
	spawner_job_path = /datum/job/lavaland_syndicate

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/special(mob/living/new_spawn)
	. = ..()
	new_spawn.grant_language(/datum/language/codespeak, TRUE, TRUE, LANGUAGE_MIND)

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/comms
	name = "Syndicate Comms Agent"
	prompt_name = "a syndicate comms agent"
	you_are_text = "You are a syndicate comms agent, employed in a top secret research facility developing biological weapons."
	flavour_text = "Unfortunately, your hated enemy, Nanotrasen, has begun mining in this sector. Monitor enemy activity as best you can, and try to keep a low profile. Use the communication equipment to provide support to any field agents, and sow disinformation to throw Nanotrasen off your trail. Do not let the base fall into enemy hands!"
	important_text = "DO NOT abandon the base."
	outfit = /datum/outfit/lavaland_syndicate/comms

/datum/outfit/lavaland_syndicate
	name = "Lavaland Syndicate Agent"
	id = /obj/item/card/id/advanced/chameleon
	id_trim = /datum/id_trim/chameleon/operative
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/toggle/labcoat
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	ears = /obj/item/radio/headset/syndicate/alt
	shoes = /obj/item/clothing/shoes/combat
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	r_hand = /obj/item/gun/ballistic/automatic/sniper_rifle

	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/lavaland_syndicate/post_equip(mob/living/carbon/human/syndicate, visualsOnly = FALSE)
	syndicate.faction |= ROLE_SYNDICATE

/datum/outfit/lavaland_syndicate/comms
	name = "Lavaland Syndicate Comms Agent"
	suit = /obj/item/clothing/suit/armor/vest
	mask = /obj/item/clothing/mask/chameleon/gps
	r_hand = /obj/item/melee/energy/sword/saber

/obj/item/clothing/mask/chameleon/gps/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps, "Encrypted Signal")
