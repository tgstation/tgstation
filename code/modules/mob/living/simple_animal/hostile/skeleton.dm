/mob/living/simple_animal/hostile/skeleton
	name = "reanimated skeleton"
	desc = "A real bonefied skeleton, doesn't seem like it wants to socialize."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "skeleton"
	icon_living = "skeleton"
	icon_dead = "skeleton"
	gender = NEUTER
	mob_biotypes = list(MOB_UNDEAD, MOB_HUMANOID)
	turns_per_move = 5
	speak_emote = list("rattles")
	emote_see = list("rattles")
	a_intent = INTENT_HARM
	maxHealth = 40
	health = 40
	speed = 1
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 15
	minbodytemp = 0
	maxbodytemp = 1500
	healable = 0 //they're skeletons how would bruise packs help them??
	attacktext = "slashes"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 10
	robust_searching = 1
	stat_attack = UNCONSCIOUS
	gold_core_spawnable = NO_SPAWN
	faction = list("skeleton")
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	deathmessage = "collapses into a pile of bones!"
	del_on_death = 1
	loot = list(/obj/effect/decal/remains/human)

	do_footstep = TRUE

/mob/living/simple_animal/hostile/skeleton/eskimo
	name = "undead eskimo"
	desc = "The reanimated remains of some poor traveler."
	icon_state = "eskimo"
	icon_living = "eskimo"
	icon_dead = "eskimo_dead"
	maxHealth = 55
	health = 55
	weather_immunities = list("snow")
	melee_damage_lower = 17
	melee_damage_upper = 20
	deathmessage = "collapses into a pile of bones, its gear falling to the floor!"
	loot = list(/obj/effect/decal/remains/human,
				/obj/item/twohanded/spear,
				/obj/item/clothing/shoes/winterboots,
				/obj/item/clothing/suit/hooded/wintercoat)


/mob/living/simple_animal/hostile/skeleton/templar
	name = "undead templar"
	desc = "The reanimated remains of a holy templar knight."
	icon_state = "templar"
	icon_living = "templar"
	icon_dead = "templar_dead"
	maxHealth = 150
	health = 150
	weather_immunities = list("snow")
	speed = 2
	speak_chance = 1
	speak = list("THE GODS WILL IT!","DEUS VULT!","REMOVE KABAB!")
	force_threshold = 10 //trying to simulate actually having armor
	obj_damage = 50
	melee_damage_lower = 25
	melee_damage_upper = 30
	deathmessage = "collapses into a pile of bones, its gear clanging as it hits the ground!"
	loot = list(/obj/effect/decal/remains/human,
				/obj/item/clothing/suit/armor/riot/chaplain,
				/obj/item/clothing/head/helmet/chaplain,
				/obj/item/claymore/weak{name = "holy sword"})

/mob/living/simple_animal/hostile/skeleton/ice
	name = "ice skeleton"
	desc = "A reanimated skeleton protected by a thick sheet of natural ice armor. Looks slow, though."
	speed = 5
	maxHealth = 75
	health = 75
	weather_immunities = list("snow")
	color = rgb(114,228,250)
	loot = list(/obj/effect/decal/remains/human{color = rgb(114,228,250)})

/mob/living/simple_animal/hostile/skeleton/plasmaminer
	name = "shambling miner"
	desc = "A plasma-soaked miner, their exposed limbs turned into a grossly incandescent bone seemingly made of plasma."
	icon_state = "plasma_miner"
	icon_living = "plasma_miner"
	icon_dead = "plasma_miner"
	maxHealth = 150
	health = 150
	harm_intent_damage = 10
	melee_damage_lower = 15
	melee_damage_upper = 20
	light_color = LIGHT_COLOR_PURPLE
	gold_core_spawnable = HOSTILE_SPAWN
	attacktext = "slashes"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	deathmessage = "collapses into a pile of bones, their suit dissolving among the plasma!"
	loot = list(/obj/effect/decal/remains/plasma)

/mob/living/simple_animal/hostile/skeleton/plasmaminer/jackhammer
	desc = "A plasma-soaked miner, their exposed limbs turned into a grossly incandescent bone seemingly made of plasma. They seem to still have their mining tool in their hand, gripping tightly."
	icon_state = "plasma_miner_tool"
	icon_living = "plasma_miner_tool"
	icon_dead = "plasma_miner_tool"
	maxHealth = 185
	health = 185
	harm_intent_damage = 15
	melee_damage_lower = 20
	melee_damage_upper = 25
	attacktext = "blasts"
	attack_sound = 'sound/weapons/sonic_jackhammer.ogg'
	loot = list(/obj/effect/decal/remains/plasma, /obj/item/pickaxe/drill/jackhammer)

/mob/living/simple_animal/hostile/skeleton/plasmaminer/Initialize()
	. = ..()
	set_light(2)
	
/mob/living/simple_animal/hostile/skeleton/robust
	name = "robust skeleton"
	desc = "A real bonefied skeleton, and this one seems to have a bone to pick with you."
	del_on_death = 0
	icon_dead = null
	loot = list()
	gold_core_spawnable = HOSTILE_SPAWN
	var/datum/action/innate/skeleton/robust/grave_warden/GW
	var/gravewardened = 0
	
/mob/living/simple_animal/hostile/skeleton/robust/Initialize()
	. = ..()
	GW = new
	GW.Grant(src)

/mob/living/simple_animal/hostile/skeleton/robust/AttackingTarget()
	if(istype(target, /obj/vehicle/sealed/car/grave_warden))
		return
	. = ..()
	if(. && ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.stat == DEAD)
			convert(H)

/mob/living/simple_animal/hostile/skeleton/robust/death(gibbed)
	var/obj/effect/decal/remains/human/skelebones = new (src.loc)
	..()
	if(health > 0)
		return
	else
		if(!gibbed && skelebones.loc)
			sleep(300)
			if(skelebones.loc)
				INVOKE_ASYNC(src, .proc/revive, 1, 1)
				src.loc = skelebones.loc
				qdel(skelebones)
				visible_message(
					"<span class='danger'>[src] re-forms from the pile of bones!</span>",
					"<span class='userdanger'>You rise again!</span>")
			else
				to_chat(src, "<span class='notice'>Without your bones, your spirit eases up and ascends.</span>")
				qdel(src)
		else
			to_chat(src, "<span class='notice'>Without your bones, your spirit eases up and ascends.</span>")
			qdel(src)
			
/mob/living/simple_animal/hostile/skeleton/robust/proc/convert(mob/living/carbon/L)
	if(!L)
		return
	visible_message(
		"<span class='danger'>[src] rips out [L]'s skeleton!</span>",
		"<span class='userdanger'>You free the skeleton from inside [L]!</span>")
	var/mob/living/simple_animal/hostile/skeleton/robust/newskele = new (L.loc)
	newskele.faction = faction.Copy()
	if(L.mind)
		L.mind.transfer_to(newskele)
	L.gib()

/obj/vehicle/sealed/car/grave_warden
	name = "grave warden"
	desc = "A pile of skeletons somehow forming one large skeleton."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "legion"
	max_integrity = 600
	obj_integrity = 600
	armor = list("melee" = 70, "bullet" = 40, "laser" = 40, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	enter_delay = 20
	max_occupants = 200
	movedelay = 3
	car_traits = CAN_KIDNAP
	key_type = null
	key_type_exact = FALSE
	engine_sound = 'sound/magic/RATTLEMEBONES2.ogg'
	
/obj/vehicle/sealed/car/grave_warden/Initialize(mapload)
	. = ..()
	src.transform *= 2
	
/obj/vehicle/sealed/car/grave_warden/auto_assign_occupant_flags(mob/M)
	if(istype(M, /mob/living/simple_animal/hostile/skeleton))
		var/mob/living/simple_animal/hostile/skeleton/S = M
		if(S.mind) //Ensures only skeletons can control the grave warden. (Including more at once)
			add_control_flags(S, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_PERMISSION)
			remove_action_type_from_mob(/datum/action/vehicle/sealed/DumpKidnappedMobs, S)
			remove_action_type_from_mob(/datum/action/vehicle/sealed/remove_key, S)
			return
	add_control_flags(M, VEHICLE_CONTROL_KIDNAPPED)
	
/obj/vehicle/sealed/car/grave_warden/Bump(atom/movable/M)
	. = ..()
	if(isliving(M))
		if(ismegafauna(M))
			return
		var/mob/living/L = M
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			H.visible_message("<span class='danger'>[H] screams as the they are pulled into [src], flesh being flung as their skeleton becomes intermeshed!</span>")
			var/mob/living/simple_animal/hostile/skeleton/robust/newskele = new (H.loc)
			if(H.mind)
				H.mind.transfer_to(newskele)
			H.gib()
			newskele.gravewardened = 1
			mob_forced_enter(newskele)
			obj_integrity += 100
			return
		L.visible_message("<span class='warning'>[src] pulls [L] into itself!</span>")
		mob_forced_enter(L)
	if(istype(M, /obj/machinery/door))
		var/obj/machinery/door/D = M
		D.take_damage(20)
	
/obj/vehicle/sealed/car/grave_warden/mob_try_exit(mob/M, mob/user, silent = FALSE)
	if(M == user && (occupants[M] & VEHICLE_CONTROL_KIDNAPPED))
		to_chat(user, "<span class='notice'>You wiggle around in [src] and try to release yourself.</span>")
		if(!do_after(user, escape_time, target = src))
			return FALSE
		mob_exit(M, silent)
		return TRUE
	mob_exit(M, silent)
	return TRUE
	
/obj/vehicle/sealed/car/grave_warden/attack_hand(mob/living/user)
	src.Bump(user)
	return
	
/datum/action/innate/skeleton/robust/grave_warden
	name = "Summon Grave Warden"
	desc = "Form the grave warden, and become one with death."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = null

/datum/action/innate/skeleton/robust/grave_warden/Activate()
	var/mob/living/simple_animal/hostile/skeleton/robust/S = owner
	if(S.gravewardened == 1)
		to_chat(owner, "<span class='danger'>You have already formed a grave warden!</span>")
		return 0
	var/skele_amount = 0
	var/static/list/skele_check_angles = list(EAST, WEST, NORTH, SOUTH)
	for(var/i in skele_check_angles)
		var/turf/T = get_turf(get_step(S, i))
		for(var/mob/living/simple_animal/hostile/skeleton/robust/L in T)
			if(S.Adjacent(L))
				skele_amount = skele_amount + 1
	if(skele_amount >= 4)
		var/obj/vehicle/sealed/car/grave_warden/G = new (S.loc)
		for(var/i in skele_check_angles)
			var/turf/T = get_turf(get_step(S, i))
			for(var/mob/living/simple_animal/hostile/skeleton/robust/L in T)
				L.gravewardened = 1
				G.mob_forced_enter(L)
		S.gravewardened = 1
		G.mob_forced_enter(S)
		S.visible_message(
		"<span class='danger'>The skeletons mesh together, and form the Grave Warden!</span>",
		"<span class='userdanger'>You mesh together with your fellow skeletons, and form the Grave Warden!</span>")
	else
		to_chat(owner, "<span class='danger'>You lack the needed skeletons!  You need 5 in a plus position!</span>")
		skele_amount = 0
		return 0
