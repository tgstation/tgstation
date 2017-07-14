//Anima fragment: Low health and high melee damage, but slows down when struck. Created by inserting a soul vessel into an empty fragment.
/mob/living/simple_animal/hostile/clockwork/fragment
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
	light_range = 2
	light_power = 0.8
	playstyle_string = "<span class='heavy_brass'>You are an anima fragment</span><b>, a clockwork creation of Ratvar. As a fragment, you have decent health that very gradually regenerates, do \
	decent damage, and move at extreme speed in addition to being immune to extreme temperatures and pressures. Taking damage, and slamming into non-Servants, will temporarily slow you down, however.\n\
	Your goal is to serve the Justiciar and his servants in any way you can. You yourself are one of these servants, and will be able to utilize anything they can, assuming it doesn't require \
	opposable thumbs.</b>"
	var/movement_delay_time //how long the fragment is slowed after being hit

/mob/living/simple_animal/hostile/clockwork/fragment/Initialize()
	. = ..()
	if(prob(1))
		name = "anime fragment"
		desc = "I-it's not like I want to show you the light of the Justiciar or anything, B-BAKA!"

/mob/living/simple_animal/hostile/clockwork/fragment/Life()
	..()
	if(GLOB.ratvar_awakens)
		adjustHealth(-5)
	else if(movement_delay_time > world.time)
		adjustHealth(-0.2)
	else
		adjustHealth(-1)

/mob/living/simple_animal/hostile/clockwork/fragment/Stat()
	..()
	if(statpanel("Status") && movement_delay_time > world.time && !GLOB.ratvar_awakens)
		stat(null, "Movement delay(seconds): [max(round((movement_delay_time - world.time)*0.1, 0.1), 0)]")

/mob/living/simple_animal/hostile/clockwork/fragment/death(gibbed)
	visible_message("<span class='warning'>[src]'s flame jets cut out as it falls to the floor with a tremendous crash.</span>", \
	"<span class='userdanger'>Your gears seize up. Your flame jets flicker out. Your soul vessel belches smoke as you helplessly crash down.</span>")
	..()

/mob/living/simple_animal/hostile/clockwork/fragment/Process_Spacemove(movement_dir = 0)
	return 1

/mob/living/simple_animal/hostile/clockwork/fragment/Collide(atom/movable/AM)
	. = ..()
	if(movement_delay_time <= world.time && next_move <= world.time && isliving(AM) && !is_servant_of_ratvar(AM))
		var/mob/living/L = AM
		if(L.stat) //we don't want to attack them if they're unconscious or dead because that feels REALLY BAD for the player
			return
		var/previousattacktext = attacktext
		attacktext = "slams into"
		UnarmedAttack(L)
		attacktext = previousattacktext
		changeNext_move(CLICK_CD_MELEE)
		if(!GLOB.ratvar_awakens)
			adjustHealth(4)
			adjust_movement_delay(10) //with the above damage, total of 20 movement delay plus speed = 0 due to damage

/mob/living/simple_animal/hostile/clockwork/fragment/emp_act(severity)
	adjust_movement_delay(50/severity)

/mob/living/simple_animal/hostile/clockwork/fragment/movement_delay()
	. = ..()
	if(movement_delay_time > world.time && !GLOB.ratvar_awakens)
		. += min((movement_delay_time - world.time) * 0.1, 10) //the more delay we have, the slower we go

/mob/living/simple_animal/hostile/clockwork/fragment/adjustHealth(amount)
	. = ..()
	if(amount > 0)
		adjust_movement_delay(amount*2.5)

/mob/living/simple_animal/hostile/clockwork/fragment/proc/adjust_movement_delay(amount)
	if(GLOB.ratvar_awakens) //if ratvar is up we ignore movement delay
		movement_delay_time = 0
	else if(movement_delay_time > world.time)
		movement_delay_time = movement_delay_time + amount
	else
		movement_delay_time = world.time + amount

/mob/living/simple_animal/hostile/clockwork/fragment/updatehealth()
	..()
	if(health == maxHealth)
		speed = initial(speed)
	else
		speed = 0 //slow down if damaged at all
