/*
KING OF GOATS
The king of goat is inside a 9x9 arena protected by two guards while during stage one it is generally a cake walk the later stages however can prove extremely challenging and downright impossible for less skilled miners..
The king goat is as indicated by his name the king of all goats and as such if you attempt to fight him you will learn why he is the king in the first place...
It has no ranged attacks what so ever but makes up for it by being confined in a small space and having the ability to summon guards, charge at his enemy and do a aoe explosion attack which can prove devistating for most miners.
The three stages of the king goat:
 Stage 1: The king goat is pretty much just a slightly more robust regular goat, the king will proceed to charge at you full force in the hopes of taking you out easily but can be easily defeated by even a unexperienced miner.
 Stage 2: This is where things start heating up. At this stage the king goat will become slightly larger and start doing special attacks which range from summoning guards to come to his aid to stomping his hooves on the ground causing the arena to shake and a aoe explosion to appear around him most miners do not make it pass this stage but if you do...
 Stage 3: Oh boy your in for it now at this stage the king goat will completly heal and grow slightly bigger and start glowing it has the exact same attacks as stage 2 but is much more intimidating if you can defeat him at stage three he will fall over dead on the ground and drop a ladder so you may now leave the arena but dont forget to grab the loot first!
The loot:
The goat gun: This weapon as the name implies fires goats at your enemies knocking them down and doing a bit of brute damage it self recharges and combined with the goat pope hat or king goat pelt can lead to some interesting shenigans,
The king goat pelt: Hope you brought a knife cause your gonna need to butcher the king goats corpse to get this prize. Once you butcher the king goat you can grab his pelt and wear it on your head as armor, boasting decent bomb resistance and slightly better gun and laser resistance then the drake helm at the cost of slightly reduced melee protection this is THE prize to show who the king of lavaland really is around here! Also makes goats friendly towards you as long as you are wearing it for they will see you as their new king.
Difficulty: Insanely Hard
*/

//Visager's tracks 'Battle!' and 'Miniboss Fight' from the album 'Songs from an Unmade World 2' are available here
//http://freemusicarchive.org/music/Visager/Songs_From_An_Unmade_World_2/ and are made available under the CC BY 4.0 Attribution license,
//which is available for viewing here: https://creativecommons.org/licenses/by/4.0/legalcode


//the king and his court
/mob/living/simple_animal/hostile/megafauna/king
	name = "king of the goats"
	desc = "The oldest and wisest of the goats. King of his race, peerless in dignity and power. His golden fleece radiates nobility."
	icon = 'icons/mob/king_of_goats.dmi'
	icon_state = "king_goat"
	icon_living = "king_goat"
	icon_dead = "king_goat_dead"
	faction = list("goat_king")
	speak = list("EHEHEHEHEH","eh?")
	speak_chance = 1
	attack_same = FALSE
	speak_emote = list("brays in a booming voice")
	emote_hear = list("brays in a booming voice")
	emote_see = list("stamps a mighty foot, shaking the surroundings")
	response_help_continuous  = "placates"
	response_harm_continuous   = "assaults"
	attack_verb_simple = "brutalized"
	attack_sound = 'sound/weapons/punch1.ogg'
	health = 500
	a_intent = INTENT_HARM
	sentience_type = SENTIENCE_BOSS
	stat_attack = DEAD
	wander = FALSE
	movement_type = GROUND
	maxHealth = 500
	armour_penetration = 35
	melee_damage_lower = 35
	melee_damage_upper = 55
	minbodytemp = 0
	maxbodytemp = INFINITY
	obj_damage = 400
	vision_range = 5
	aggro_vision_range = 18
	robust_searching = TRUE
	move_to_delay = 3
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0



	var/stun_chance = 5 //chance per attack to Weaken target

/mob/living/simple_animal/hostile/megafauna/king/ex_act(severity, target)
	switch (severity)
		if (1)
			adjustBruteLoss(100)

		if (2)
			adjustBruteLoss(50)

		if(3)
			adjustBruteLoss(25)

/mob/living/simple_animal/hostile/megafauna/king/phase2
	name = "emperor of the goats"
	desc = "The King of Kings, God amongst men, and your superior in every way."
	icon_state = "king_goat2"
	icon_living = "king_goat2"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 4, /obj/item/clothing/head/goatpelt/king = 1)
	health = 750
	maxHealth = 750
	armour_penetration = 50
	melee_damage_lower = 40
	melee_damage_upper = 60
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	pixel_y = 5

	var/spellscast = 0
	var/phase3 = FALSE
	var/sound_id = "goat"
	var/special_attacks = 0
	var/list/rangers = list()
	var/current_song = 'sound/ambience/Visager-Battle.ogg'
	var/current_song_length = 1200
	stun_chance = 7

/mob/living/simple_animal/hostile/megafauna/king/phase2/Initialize()
	. = ..()
	update_icon()

/mob/living/simple_animal/hostile/megafauna/king/Found(atom/A)
	if(isliving(A))
		return A
	return ..()

/mob/living/simple_animal/hostile/retaliate/goat/guard/Found(atom/A)
	if(isliving(A))
		return A
	return ..()

/mob/living/simple_animal/hostile/retaliate/goat/guard
	name = "honour guard"
	desc = "A very handsome and noble beast."
	icon = 'icons/mob/king_of_goats.dmi'
	icon_state = "goat_guard"
	icon_living = "goat_guard"
	icon_dead = "goat_guard_dead"
	faction = list("goat_king")
	attack_same = FALSE
	sentience_type = SENTIENCE_BOSS
	stat_attack = DEAD
	wander = FALSE
	robust_searching = TRUE
	health = 125
	maxHealth = 125
	minbodytemp = 0
	maxbodytemp = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	armour_penetration = 10
	melee_damage_lower = 10
	melee_damage_upper = 15

/mob/living/simple_animal/hostile/retaliate/goat/guard/master
	name = "master of the guard"
	desc = "A very handsome and noble beast - the most trusted of all the king's men."
	icon_state = "goat_guard_m"
	icon_living = "goat_guard_m"
	icon_dead = "goat_guard_m_dead"
	health = 200
	maxHealth = 200
	armour_penetration = 15
	melee_damage_lower = 15
	melee_damage_upper = 20
	move_to_delay = 3

/mob/living/simple_animal/hostile/retaliate/goat/guard/pope
	name = "Goat Pope"
	desc = "For what is a God without a pope to spread their holy words"
	icon_state = "goat_pope"
	icon_living = "goat_pope"
	icon_dead = "goat_pope_dead"
	health = 100
	maxHealth = 100
	armour_penetration = 25
	melee_damage_lower = 25
	melee_damage_upper = 30
	move_to_delay = 3
	loot = list(/obj/item/clothing/head/goatpope)

/mob/living/simple_animal/hostile/megafauna/king/Retaliate()
	..()
	if(stat == CONSCIOUS && prob(5))
		visible_message("<span class='warning'>\The [src] bellows indignantly, with a judgemental gleam in his eye.</span>")

/mob/living/simple_animal/hostile/megafauna/king/phase2/Retaliate()
	set waitfor = FALSE
	..()
	if(spellscast < 10)
		if(prob(5) && move_to_delay >= 3) //speed buff
			spellscast++
			visible_message("<span class='cult'>\The [src] shimmers and seems to phase in and out of reality itself!</span>")
			move_to_delay = 1

		else if(prob(5) && melee_damage_lower != 50) //damage buff
			spellscast++
			visible_message("<span class='cult'>\The [src]' horns grow larger and more menacing!</span>")
			melee_damage_lower = 50

		else if(prob(5)) //spawn adds
			spellscast++
			visible_message("<span class='cult'>\The [src] summons the imperial guard to his aid, and they appear in a flash!</span>")
			var/mob/living/simple_animal/hostile/retaliate/goat/guard/master/M = new(get_step(src,pick(GLOB.cardinals)))
			M.enemies |= enemies
			var/mob/living/simple_animal/hostile/retaliate/goat/guard/G = new(get_step(src,pick(GLOB.cardinals)))
			G.enemies |= enemies
			G = new(get_step(src,pick(GLOB.cardinals)))
			G.enemies |= enemies

		else if(prob(5)) //EMP blast
			spellscast++
			visible_message("<span class='cult'>\The [src] disrupts nearby electrical equipment!</span>")
			empulse(get_turf(src), 5, 2, 0)

		else if(prob(5) && melee_damage_type == BRUTE && !special_attacks) //elemental attacks
			spellscast++
			visible_message("<span class='cult'>\The [src]' horns flicker with holy white flames!</span>")
			melee_damage_type = BURN

		else if(prob(5)) //earthquake spell
			visible_message("<B><span class='danger'>\The [src]' eyes begin to glow ominously as dust and debris in the area is kicked up in a light breeze!!</span></B>")
			stop_automated_movement = TRUE
			if(do_after(src, 6 SECONDS, src))
				var/health_holder = getBruteLoss()
				visible_message("<B><span class='cult'>\The [src] raises its fore-hooves and stomps them into the ground with incredible force!!</span></B>")
				explosion(get_step(src,pick(GLOB.cardinals)), -1, 2, 2, 3, 6)
				explosion(get_step(src,pick(GLOB.cardinals)), -1, 1, 4, 4, 6)
				explosion(get_step(src,pick(GLOB.cardinals)), -1, 3, 4, 3, 6)
				stop_automated_movement = FALSE
				spellscast++
				if(!(getBruteLoss() > health_holder))
					adjustBruteLoss(health_holder - getBruteLoss()) //our own magicks cannot harm us
			else
				visible_message("<span class='notice'>\The [src] loses concentration and huffs haughtily.</span>")
				stop_automated_movement = FALSE

		else return

/mob/living/simple_animal/hostile/megafauna/king/phase2/proc/phase3_transition()
	phase3 = TRUE
	spellscast = 0
	maxHealth = 750
	revive(TRUE)
	current_song = 'sound/ambience/Visager-Miniboss_Fight.ogg'
	current_song_length = 1759
	var/sound/song_played = sound(current_song)
	for(var/mob/M in rangers)
		if(!M.client || !(M.client.prefs.toggles & SOUND_INSTRUMENTS))
			continue
		M.stop_sound_channel(CHANNEL_JUKEBOX)
		rangers[M] = world.time + current_song_length
		M.playsound_local(null, null, 30, channel = CHANNEL_JUKEBOX, S = song_played)
	stun_chance = 10
	update_icon()
	visible_message("<span class='cult'>\The [src]' wounds close with a flash, and when he emerges, he's even larger than before!</span>")


/mob/living/simple_animal/hostile/megafauna/king/phase2/update_icon()
	var/matrix/M = new
	if(phase3)
		icon_state = "king_goat3"
		icon_living = "king_goat3"
		M.Scale(1.5)
	else
		M.Scale(1.25)
	transform = M
	pixel_y = 10

/mob/living/simple_animal/hostile/megafauna/king/phase2/Life()
	. = ..()
	if(stat != DEAD)
		var/sound/song_played = sound(current_song)

		for(var/mob/M in range(10, src))
			if(!M.client || !(M.client.prefs.toggles & SOUND_INSTRUMENTS))
				continue
			if(!(M in rangers) || world.time > rangers[M])
				M.stop_sound_channel(CHANNEL_JUKEBOX)
				rangers[M] = world.time + current_song_length
				M.playsound_local(null, null, 30, channel = CHANNEL_JUKEBOX, S = song_played)
		for(var/mob/L in rangers)
			if(get_dist(src, L) > 10)
				rangers -= L
				if(!L || !L.client)
					continue
				L.stop_sound_channel(CHANNEL_JUKEBOX)
	else
		for(var/mob/L in rangers)
			rangers -= L
			if(!L || !L.client)
				continue
			L.stop_sound_channel(CHANNEL_JUKEBOX)
	if(move_to_delay < 3)
		move_to_delay += 0.1
	if((health <= 150 && !phase3 && spellscast == 10) || (stat == DEAD && !phase3)) //begin phase 3, reset spell limit and heal
		phase3_transition()
	if(!.)
		return FALSE
	if(special_attacks >= 10 && melee_damage_type != BRUTE)
		visible_message("<span class='cult'>The energy surrounding \the [src]'s horns dissipates.</span>")
		melee_damage_type = BRUTE
	if(special_attacks >= 10 && melee_damage_lower == 50)
		visible_message("<span class='cult'>The [src]' horns shrink back down to normal size.</span>")
		melee_damage_lower = 40

/mob/living/simple_animal/hostile/megafauna/king/proc/OnDeath()
	visible_message("<span class='cult'>\The [src] lets loose a terrific wail as its wounds close shut with a flash of light, and its eyes glow even brighter than before!</span>")
	new /mob/living/simple_animal/hostile/megafauna/king/phase2(get_turf(src))
	qdel(src)

/mob/living/simple_animal/hostile/megafauna/king/phase2/OnDeath()
	for(var/mob/L in rangers)
		rangers -= L
		if(!L || !L.client)
			continue
		L.stop_sound_channel(CHANNEL_JUKEBOX)
	if(phase3)
		visible_message("<span class='cult'>\The [src] shrieks as the seal on his power breaks and he starts to break apart!</span>")
		new /obj/structure/ladder/unbreakable/goat(loc)
		new /obj/item/gun/energy/goatgun(loc)
		new /obj/item/toy/plush/goatplushie/angry/kinggoat(loc) //If someone dies from this after beating the king goat im going to laugh

/mob/living/simple_animal/hostile/megafauna/king/death()
	..()
	OnDeath()

/mob/living/simple_animal/hostile/megafauna/king/phase2/Destroy()
	for(var/mob/L in rangers)
		rangers -= L
		if(!L || !L.client)
			continue
		L.stop_sound_channel(CHANNEL_JUKEBOX)
	. = ..()

/mob/living/simple_animal/hostile/megafauna/king/AttackingTarget()
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat == DEAD)
			L.gib()
		if(prob(stun_chance))
			L.Paralyze(5)
			visible_message("<span class='warning'>\The [L] is bowled over by the impact of [src]'s attack!</span>")

/mob/living/simple_animal/hostile/megafauna/king/phase2/AttackingTarget()
	. = ..()
	if(isliving(target))
		if(melee_damage_type != BRUTE)
			special_attacks++
