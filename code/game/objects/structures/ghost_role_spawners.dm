//Objects that spawn ghosts in as a certain role when they click on it, i.e. away mission bartenders.

//Preserved terrarium/seed vault: Spawns in seed vault structures in lavaland. Ghosts become plantpeople and are advised to begin growing plants in the room near them.
/obj/effect/mob_spawn/human/seed_vault
	name = "preserved terrarium"
	desc = "An ancient machine that seems to be used for storing plant matter. The glass is obstructed by a mat of vines."
	mob_name = "a lifebringer"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "terrarium"
	density = TRUE
	roundstart = FALSE
	death = FALSE
	mob_species = /datum/species/pod
	flavour_text = "<font size=3><b>Y</b></font><b>ou are a living ecosystem - an example of the mastery over life that your creators possessed. Your masters, benevolent as they were, created uncounted \
	seed vaults and spread them across the universe to every planet they could chart. You are in one such seed vault. Your goal is to cultivate and spread life wherever it will go while waiting \
	for contact from your creators. Estimated time of last contact: Deployment, 5x10^3 millennia ago.</b>"

/obj/effect/mob_spawn/human/seed_vault/special(mob/living/new_spawn)
	var/plant_name = pick("Tomato", "Potato", "Brocolli", "Carrot", "Ambrosia", "Pumpkin", "Ivy", "Kudzu", "Bannana", "Moss", "Flower", "Bloom", "Root", "Bark", "Glowshroom", "Petal", "Leaf", \
	"Venus", "Sprout","Cocao", "Strawberry", "Citrus", "Oak", "Cactus", "Pepper", "Juniper")
	new_spawn.real_name = plant_name

/obj/effect/mob_spawn/human/seed_vault/Destroy()
	var/obj/structure/S = new(get_turf(src))
	S.name = "empty terrarium"
	S.desc = "An ancient machine that seems to be used for storing plant matter. Its hatch is ajar."
	S.icon = 'icons/obj/lavaland/spawners.dmi'
	S.icon_state = "terrarium_open"
	S.density = TRUE
	S.anchored = TRUE

//Ash walker eggs: Spawns in ash walker dens in lavaland. Ghosts become unbreathing lizards that worship the Necropolis and are advised to retrieve corpses to create more ash walkers.
/obj/effect/mob_spawn/human/ash_walker
	name = "ash walker egg"
	desc = "A man-sized yellow egg, spawned from some unfathomable creature. A humanoid silhouette lurks within."
	mob_name = "an ash walker"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	mob_species = /datum/species/lizard/ashwalker
	helmet = /obj/item/clothing/head/helmet/gladiator
	uniform = /obj/item/clothing/under/gladiator
	roundstart = FALSE
	death = FALSE
	anchored = 0
	density = 0
	flavour_text = "<font size=3><b>Y</b></font><b>ou are an ash walker. Your tribe worships <span class='danger'>the Necropolis</span>. The wastes are sacred ground, its monsters a blessed bounty. \
	You have seen lights in the distance... they foreshadow the arrival of outsiders that seek to tear apart the Necropolis and its domain. Fresh sacrifices for the Dark One.</b>"

/obj/effect/mob_spawn/human/ash_walker/special(mob/living/new_spawn)
	new_spawn.real_name = random_unique_lizard_name(gender)
	new_spawn << "<b>Drag the corpses of men and beasts to your nest. It will absorb them to create more of your kind. Glory to the Dark One!</b>"
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		H.underwear = "Nude"
		H.update_body()

/obj/effect/mob_spawn/human/ash_walker/New()
	..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("An ash walker egg is ready to hatch in \the [A.name].", source = src, action=NOTIFY_ATTACK)

//Timeless prisons: Spawns in Wish Granter prisons in lavaland. Ghosts become age-old users of the Wish Granter and are advised to seek repentance for their past.
/obj/effect/mob_spawn/human/exile
	name = "timeless prison"
	desc = "Although this stasis pod looks medicinal, it seems as though it's meant to preserve something for a very long time."
	mob_name = "a penitent exile"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	mob_species = /datum/species/shadow
	flavour_text = "<font size=3><b>Y</b></font>ou are cursed. Years ago, you sacrificed the lives of your trusted friends and the humanity of yourself to reach the Wish Granter. Though you did so, \
	it has come at a cost: your very body rejects the light, dooming you to wander endlessly in this horrible wasteland.</b>"

/obj/effect/mob_spawn/human/exile/special(mob/living/new_spawn)
	new_spawn.real_name = "[new_spawn.real_name] ([rand(0,999)])"
	var/wish = rand(1,4)
	switch(wish)
		if(1)
			new_spawn << "<b>You wished to kill, and kill you did. You've lost track of how many, but the spark of excitement that murder once held has winked out. You feel only regret.</b>"
		if(2)
			new_spawn << "<b>You wished for unending wealth, but no amount of money was worth this existence. Maybe charity might redeem your soul?</b>"
		if(3)
			new_spawn << "<b>You wished for power. Little good it did you, cast out of the light. You are the [gender == MALE ? "king" : "queen"] of a hell that holds no subjects. You feel only remorse.</b>"
		if(4)
			new_spawn << "<b>You wished for immortality, even as your friends lay dying behind you. No matter how many times you cast yourself into the lava, you awaken in this room again within a few days. There is no escape.</b>"

//Golem shells: Spawns in Free Golem ships in lavaland. Ghosts become mineral golems and are advised to spread personal freedom.
/obj/effect/mob_spawn/human/golem
	name = "inert golem shell"
	desc = "A humanoid shape, empty, lifeless, and full of potential."
	mob_name = "a free golem"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	mob_species = /datum/species/golem
	roundstart = FALSE
	death = FALSE
	anchored = 0
	density = 0
	flavour_text = "<font size=3><b>Y</b></font><b>ou are a Free Golem. Your family worships <span class='danger'>The Liberator</span>. In his infinite and divine wisdom, he set your clan free to \
	travel the stars with a single declaration: \"Yeah go do whatever.\" Though you are bound to the one who created you, it is customary in your society to repeat those same words to newborn \
	golems, so that no golem may ever be forced to serve again.</b>"

/obj/effect/mob_spawn/human/golem/New()
	..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("A golem shell has been completed in \the [A.name].", source = src, action=NOTIFY_ATTACK)

/obj/effect/mob_spawn/human/golem/special(mob/living/new_spawn)
	var/golem_surname = pick(golem_names)
	// 3% chance that our golem has a human surname, because
	// cultural contamination
	if(prob(3))
		golem_surname = pick(last_names)

	var/datum/species/X = mob_species
	var/golem_forename = initial(X.id)

	// The id of golem species is either their material "diamond","gold",
	// or just "golem" for the plain ones. So we're using it for naming.

	if(golem_forename == "golem")
		golem_forename = "iron"

	new_spawn.real_name = "[capitalize(golem_forename)] [golem_surname]"
	// This means golems have names like Iron Forge, or Diamond Quarry
	// also a tiny chance of being called "Plasma Meme"
	// which is clearly a feature

	new_spawn << "Build golem shells in the autolathe, and feed refined mineral sheets to the shells to bring them to life! You are generally a peaceful group unless provoked."
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		H.set_cloned_appearance()


/obj/effect/mob_spawn/human/golem/adamantine
	name = "dust-caked golem shell"
	desc = "A humanoid shape, empty, lifeless, and full of potential."
	mob_name = "a free golem"
	anchored = 1
	density = 1
	mob_species = /datum/species/golem/adamantine
