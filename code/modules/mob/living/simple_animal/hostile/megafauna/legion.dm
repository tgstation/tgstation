/*

LEGION

Legion spawns from the necropolis gate in the far north of lavaland. It is the guardian of the Necropolis and emerges from within whenever an intruder tries to enter through its gate.
Whenever Legion emerges, everything in lavaland will receive a notice via color, audio, and text. This is because Legion is powerful enough to slaughter the entirety of lavaland with little effort.

It has two attack modes that it constantly rotates between.

In ranged mode, it will behave like a normal legion - retreating when possible and firing legion skulls at the target.
In charge mode, it will spin and rush its target, attacking with melee whenever possible.

When Legion dies, it drops a staff of storms, which allows its wielder to call and disperse ash storms at will and functions as a powerful melee weapon.

Difficulty: Medium

*/

/mob/living/simple_animal/hostile/megafauna/legion
	name = "Legion"
	health = 800
	maxHealth = 800
	icon_state = "legion"
	icon_living = "legion"
	desc = "One of many."
	icon = 'icons/mob/lavaland/legion.dmi'
	attacktext = "chomps"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	faction = list("mining")
	speak_emote = list("echoes")
	armour_penetration = 50
	melee_damage_lower = 25
	melee_damage_upper = 25
	speed = 2
	ranged = 1
	flying = 1
	del_on_death = 1
	retreat_distance = 5
	minimum_distance = 5
	ranged_cooldown_time = 20
	var/size = 10
	var/charging = 0
	pixel_y = -90
	pixel_x = -75
	loot = list(/obj/item/stack/sheet/bone = 3)
	vision_range = 13
	aggro_vision_range = 18
	idle_vision_range = 13

/mob/living/simple_animal/hostile/megafauna/legion/New()
	..()
	new/obj/item/device/gps/internal/legion(src)

/mob/living/simple_animal/hostile/megafauna/legion/OpenFire(the_target)
	if(world.time >= ranged_cooldown && !charging)
		if(prob(75))
			var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/A = new(src.loc)
			A.GiveTarget(target)
			A.friends = friends
			A.faction = faction
			ranged_cooldown = world.time + ranged_cooldown_time
		else
			visible_message("<span class='warning'><b>[src] charges!</b></span>")
			SpinAnimation(speed = 20, loops = 5)
			ranged = 0
			retreat_distance = 0
			minimum_distance = 0
			speed = 0
			charging = 1
			spawn(50)
				ranged = 1
				retreat_distance = 5
				minimum_distance = 5
				speed = 2
				charging = 0

/mob/living/simple_animal/hostile/megafauna/legion/death()
	if(health > 0)
		return
	if(size > 2)
		adjustHealth(-maxHealth) //heal ourself to full in prep for splitting
		var/mob/living/simple_animal/hostile/megafauna/legion/L = new(src.loc)

		L.maxHealth = maxHealth * 0.6
		maxHealth = L.maxHealth

		L.health = L.maxHealth
		health = L.health

		L.size = size - 2
		size = L.size

		var/size_multiplier = L.size * 0.08
		L.resize = size_multiplier
		resize = L.resize

		L.update_transform()
		update_transform()

		L.target = target

		visible_message("<span class='boldannounce'>[src] splits in twain!</span>")
	else
		var/last_legion = TRUE
		for(var/mob/living/simple_animal/hostile/megafauna/legion/other in mob_list)
			if(other != src)
				last_legion = FALSE
				break
		if(last_legion)
			src.loot = list(/obj/item/weapon/staff/storm)
		else if(prob(5))
			src.loot = list(/obj/structure/closet/crate/necropolis/tendril)
		..()

/mob/living/simple_animal/hostile/megafauna/legion/Process_Spacemove(movement_dir = 0)
	return 1

/obj/item/device/gps/internal/legion
	icon_state = null
	gpstag = "Echoing Signal"
	desc = "The message repeats."
	invisibility = 100


//Loot

/obj/item/weapon/staff/storm
	name = "staff of storms"
	desc = "An ancient staff retrieved from the remains of Legion. The wind stirs as you move it."
	icon_state = "staffofstorms"
	item_state = "staffofstorms"
	icon = 'icons/obj/guns/magic.dmi'
	slot_flags = SLOT_BACK
	item_state = "staffofstorms"
	w_class = 4
	force = 25
	damtype = BURN
	hitsound = 'sound/weapons/sear.ogg'
	var/storm_cooldown = 0

/obj/item/weapon/staff/storm/attack_self(mob/user)
	if(storm_cooldown > world.time)
		user << "<span class='warning'>The staff is still recharging!</span>"
		return
	if(user.z != ZLEVEL_LAVALAND)
		user << "<span class='warning'>You can't seem to control the weather here!</span>"
		return

	var/datum/weather/ash_storm/A
	for(var/V in SSweather.existing_weather)
		var/datum/weather/W = V
		if(W.name == "ash storm")
			A = W
			break
	if(!A)
		user << "<span class='warning'>How odd! The planet seems to have lost its atmosphere!</span>"
		return

	if(A.stage != END_STAGE)
		if(A.stage == WIND_DOWN_STAGE)
			user << "<span class='warning'>The storm is already ending! It would be a waste to use the staff now.</span>"
			return
		user.visible_message("<span class='warning'>[user] holds [src] skywards as an orange beam travels into the sky!</span>", \
		"<span class='notice'>You hold [src] skyward, dispelling the ash storm!</span>")
		playsound(user, 'sound/magic/Staff_Change.ogg', 200, 0)
		A.wind_down()
	else
		user.visible_message("<span class='warning'>[user] holds [src] skywards as red lightning crackles into the sky!</span>", \
		"<span class='notice'>You hold [src] skyward, calling down a terrible storm!</span>")
		playsound(user, 'sound/magic/Staff_Chaos.ogg', 200, 0)
		A.telegraph()

	storm_cooldown = world.time + 600
