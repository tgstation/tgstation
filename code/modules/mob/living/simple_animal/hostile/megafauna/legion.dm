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
			visible_message("<span class='danger'>[src] charges!</span>")
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

		visible_message("<span class='danger'>[src] splits!</span>")
	else
		var/last_legion = TRUE
		for(var/mob/living/simple_animal/hostile/megafauna/legion/other in mob_list)
			if(other != src)
				last_legion = FALSE
				break
		if(last_legion)
			src.loot = list(/obj/item/weapon/staff_of_storms)
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

/obj/item/weapon/staff_of_storms
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
	var/obj/machinery/lavaland_controller/linked_machine
	var/storm_cooldown = 0

/obj/item/weapon/staff_of_storms/attack_self(mob/user)
	if(storm_cooldown > world.time)
		user << "The staff is still recharging."
		return

	if(!linked_machine || linked_machine.z != user.z)
		for(var/obj/machinery/lavaland_controller/controller in machines)
			if(controller.z == user.z)
				linked_machine = controller
				break

	if(linked_machine && linked_machine.ongoing_weather)
		if(linked_machine.ongoing_weather.stage == WIND_DOWN_STAGE || linked_machine.ongoing_weather.stage == END_STAGE)
			user << "The storm is already ending. It would be a waste to use the staff now."
			return
		linked_machine.ongoing_weather.duration = 0
		user << "<span class='danger'><B>With an appropriately dramatic flourish, you dispell the storm.</B>"
		playsound(get_turf(src),'sound/magic/Staff_Change.ogg', 200, 1)
		storm_cooldown = world.time + 600

	else if (linked_machine && !linked_machine.ongoing_weather)
		user << "<span class='danger'><B>You lift the staff towards the heavens, calling down a terrible storm.</B>"
		linked_machine.weather_cooldown = 0
		playsound(get_turf(src),'sound/magic/Staff_Change.ogg', 200, 1)
		storm_cooldown = world.time + 600

	else
		user << "You can't seem to control the weather here."