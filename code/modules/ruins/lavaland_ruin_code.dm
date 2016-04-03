/obj/structure/lavaland_door
	name = "necropolis gate"
	desc = "An imposing, seemingly impenetrable door."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "door"
	anchored = 1
	density = 1
	bound_width = 96
	bound_height = 96
	burn_state = LAVA_PROOF
	luminosity = 1

/obj/structure/lavaland_door/singularity_pull()
	return 0

/obj/structure/lavaland_door/Destroy()
	return QDEL_HINT_LETMELIVE

/obj/machinery/lavaland_controller
	name = "weather control machine"
	desc = "Controls the weather."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "processor"
	var/ongoing_weather = FALSE
	var/weather_cooldown = 0

/obj/machinery/lavaland_controller/process()
	if(ongoing_weather || weather_cooldown > world.time)
		return
	ongoing_weather = TRUE
	weather_cooldown = world.time + rand(3500, 6500)
	var/datum/weather/ash_storm/LAVA = new /datum/weather/ash_storm
	LAVA.weather_start_up()
	ongoing_weather = FALSE

/obj/machinery/lavaland_controller/Destroy()
	return QDEL_HINT_LETMELIVE



//lavaland_surface_seed_vault.dmm
//Seed Vault

/obj/effect/spawner/lootdrop/seed_vault
	name = "seed vault seeds"
	lootcount = 1

	loot = list(/obj/item/seeds/gatfruit = 10,
				/obj/item/seeds/cherry = 15,
				/obj/item/seeds/berry/glow = 10,
				/obj/item/seeds/sunflower/moonflower = 8
				)

/obj/effect/mob_spawn/human/seed_vault
	name = "vault creature sleeper"
	mob_name = "Vault Creature"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	mob_species = /datum/species/pod
	flavour_text = {"You are a strange, artificial creature. Your creators were a highly advanced and benevolent race, and launched many seed vaults into the stars, hoping to aid fledgling civilizations. You are to tend to the vault and await the arrival of sentient species. You've been waiting quite a while though..."}

/obj/effect/mob_spawn/human/seed_vault/special(mob/living/new_spawn)
	var/plant_name = pick("Tomato", "Potato", "Brocolli", "Carrot", "Deathcap", "Ambrosia", "Pumpkin", "Ivy", "Kudzu", "Bannana", "Moss", "Flower", "Bloom", "Spore", "Root", "Bark", "Glowshroom", "Petal", "Leaf", "Venus", "Sprout","Cocao", "Strawberry", "Citrus", "Oak", "Cactus", "Pepper", "Juniper")
	new_spawn.real_name = plant_name

//Greed

/obj/structure/cursed_slot_machine
	name = "greed's slot machine"
	desc = "High stakes, high rewards."
	icon = 'icons/obj/economy.dmi'
	icon_state = "slots1"
	anchored = 1
	density = 1
	var/win_prob = 5

/obj/structure/cursed_slot_machine/attack_hand(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(in_use)
		return
	in_use = TRUE
	user << "<span class='danger'><B>You feel your very life draining away as you pull the lever...it'll be worth it though, right?</B></span>"
	user.adjustCloneLoss(20)
	if(user.stat)
		user.gib()
	icon_state = "slots2"
	sleep(50)
	icon_state = "slots1"
	in_use = FALSE
	if(prob(win_prob))
		new /obj/item/weapon/dice/d20/fate/one_use(get_turf(src))
		if(user)
			user << "You hear laughter echoing around you as the machine fades away. In it's place...more gambling."
			qdel(src)
	else
		if(user)
			user << "<span class='danger'>Looks like you didn't win anything this time...next time though, right?</span>"
//Gluttony

/obj/effect/gluttony
	name = "gluttony's wall"
	desc = "Only those who truly indulge may pass."
	anchored = 1
	density = 1
	icon_state = "blob"
	icon = 'icons/mob/blob.dmi'

/obj/effect/gluttony/CanPass(atom/movable/mover, turf/target, height=0)//So bullets will fly over and stuff.
	if(height==0)
		return 1
	if(istype(mover, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mover
		if(H.nutrition >= NUTRITION_LEVEL_FAT)
			return 1
		else
			H << "<span class='danger'><B>You're not gluttonous enough to pass this barrier!</B></span>"
	else
		return 0

//Pride

/obj/structure/mirror/magic/pride
	name = "pride's mirror"
	desc = "Pride cometh before the..."
	icon_state = "magic_mirror"

/obj/structure/mirror/magic/pride/curse(mob/user)
	user.visible_message("<span class='danger'><B>The ground splits beneath [user] as their hand leaves the mirror!</B></span>")
	var/turf/T = get_turf(user)
	T.ChangeTurf(/turf/simulated/chasm/straight_down)
	var/turf/simulated/chasm/straight_down/C = T
	C.drop(user)

//Sloth - I'll finish this item later

//Envy

/obj/item/weapon/knife/envy
	name = "envy's knife"
	desc = "Their success will be yours."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "render"
	force = 18
	throwforce = 10
	w_class = 3
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/weapon/knife/envy/afterattack(atom/movable/AM, mob/living/carbon/human/user, proximity)
	..()
	if(!proximity)
		return
	if(!istype(user))
		return
	if(istype(AM, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if(user.real_name != H.dna.real_name)
			user.real_name = H.dna.real_name
			H.dna.transfer_identity(user, transfer_SE=1)
			user.updateappearance(mutcolor_update=1)
			user.domutcheck()
			user << "You assume the face of [H]. Are you satisfied?"

///Ash Walkers

/mob/living/simple_animal/hostile/spawner/ash_walker
	name = "ash walker nest"
	desc = "A nest built around a necropolis tendril. The eggs seem to grow unnaturally fast..."
	icon = 'icons/mob/nest.dmi'
	icon_state = "ash_walker_nest"
	icon_living = "ash_walker_nest"
	health = 200
	maxHealth = 200
	loot = list(/obj/effect/gibspawner, /obj/item/device/assembly/signaler/anomaly)
	del_on_death = 1
	var/meat_counter

/mob/living/simple_animal/hostile/spawner/ash_walker/Life()
	..()
	if(!stat)
		consume()
		spawn_mob()

/mob/living/simple_animal/hostile/spawner/ash_walker/proc/consume()
	for(var/mob/living/H in view(src,1)) //Only for corpse right next to/on same tile
		if(H.stat)
			visible_message("<span class='warning'>Tendrils reach out from \the [src.name] pulling [H] in! Blood seeps over the eggs as [H] is devoured.</span>")
			playsound(get_turf(src),'sound/magic/Demon_consume.ogg', 100, 1)
			meat_counter ++
			H.gib()

/mob/living/simple_animal/hostile/spawner/ash_walker/spawn_mob()
	if(meat_counter >= 2)
		new /obj/effect/mob_spawn/human/ash_walker(get_step(src.loc, SOUTH))
		visible_message("<span class='danger'>An egg is ready to hatch!</span>")
		meat_counter -= 2

/obj/effect/mob_spawn/human/ash_walker
	name = "ash walker egg"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	mob_species = /datum/species/lizard
	helmet = /obj/item/clothing/head/helmet/gladiator
	uniform = /obj/item/clothing/under/gladiator
	roundstart = FALSE
	death = FALSE
	anchored = 0
	density = 0
	flavour_text = {"<B>You are an Ash Walker. Your tribe worships<span class='danger'>the necropolis</span>. The wastes are sacred ground, it's monsters a blessed bounty. You have seen lights in the distance though, the arrival of outsiders seeking to destroy the land. Fresh sacrifices.</B>"}

/obj/effect/mob_spawn/human/ash_walker/special(mob/living/new_spawn)
	new_spawn.real_name = random_unique_lizard_name(gender)
	new_spawn << "Drag corpes to your nest to feed the young, and spawn more Ash Walkers. Bring glory to the tribe!"
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		H.dna.species.specflags |= NOBREATH



//Wishgranter Exile

/obj/effect/mob_spawn/human/exile
	name = "exile sleeper"
	mob_name = "Penitent Exile"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	mob_species = /datum/species/shadow
	flavour_text = {"You are cursed! Many years ago you risked it all to reach the Wish Granter, siezing it's power for yourself and leaving your friends for dead.. Though your wish came true, it did so at a price, and you've been doomed to wander these wastes ever since. You seek only to atone now, to somehow redeem yourself, and finally be released. You've seen ships landing in the distance. Perhaps now is the time to make things right?"}

/obj/effect/mob_spawn/human/exile/special(mob/living/new_spawn)
	new_spawn.real_name = "[new_spawn.real_name] ([rand(0,999)])"
	var/wish = rand(1,4)
	switch(wish)
		if(1)
			new_spawn << "You wished to kill, and kill you did. You've lost track of the number and murder long lost it's spark of excitement. You feel only regret."
		if(2)
			new_spawn << "You wished for unending wealth, but no amount of money was worth this existence. Maybe charity might redeem your soul?"
		if(3)
			new_spawn << "You wished for power. Little good it did you, cast out of the light. You are a king, but ruling over a miserable wasteland. You feel only remorse."
		if(4)
			new_spawn << "You wished for immortality, even as your friends lay dying behind you. No matter how many times you cast yourself into the lava, you awaken in this room again within a few days. You are overwhelmed with guilt."

//Free Golems

/obj/item/weapon/disk/design_disk/golem_shell
	name = "Golem Creation Disk"
	desc = "A gift from the Liberator."
	icon_state = "datadisk1"

/obj/item/weapon/disk/design_disk/golem_shell/New()
	..()
	var/datum/design/golem_shell/G = new
	blueprint = G

/datum/design/golem_shell
	name = "Golem Shell Construction"
	desc = "Allows for the construction of a Golem Shell."
	id = "golem"
	req_tech = list("materials" = 12)
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 40000)
	build_path = /obj/item/golem_shell
	category = list("Imported")

/obj/item/golem_shell
	name = "empty golem shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "The incomplete body of a golem."

/obj/item/golem_shell/attackby(obj/item/I, mob/user, params)
	..()
	var/species
	if(istype(I, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/O = I

		if(istype(O, /obj/item/stack/sheet/metal))
			species = /datum/species/golem

		if(istype(O, /obj/item/stack/sheet/mineral/plasma))
			species = /datum/species/golem/plasma

		if(istype(O, /obj/item/stack/sheet/mineral/diamond))
			species = /datum/species/golem/diamond

		if(istype(O, /obj/item/stack/sheet/mineral/gold))
			species = /datum/species/golem/gold

		if(istype(O, /obj/item/stack/sheet/mineral/silver))
			species = /datum/species/golem/silver

		if(istype(O, /obj/item/stack/sheet/mineral/uranium))
			species = /datum/species/golem/uranium

		if(species)
			if(O.use(10))
				user << "You finish up the golem shell with ten sheets of [O]."
				var/obj/effect/mob_spawn/human/golem/G = new(get_turf(src))
				G.mob_species = species
				qdel(src)
			else
				user << "You need at least ten sheets to finish a golem."
		else
			user << "You can't build a golem out of this kind of material."

/obj/effect/mob_spawn/human/golem
	name = "completed golem shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	mob_species = /datum/species/golem
	roundstart = FALSE
	death = FALSE
	anchored = 0
	density = 0
	flavour_text = {"<B>You are a Free Golem. Your family worships <span class='danger'>The Liberator</span>. In his infinite and divine wisdom, he set your clan free to travel the stars with a single declaration; 'Yeah go do whatever.' Though you are bound to the one who created you, it is customary in your society to repeat those same words to newborn golems, so that no golem may ever be forced to serve again.</B>"}


/obj/effect/mob_spawn/human/golem/New()
	..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("A golem shell has been completed in \the [A.name].", source = src, attack_not_jump = 1)

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
	name = "golem sleeper"
	mob_name = "Free Golem"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	anchored = 1
	density = 1
	mob_species = /datum/species/golem/adamantine
