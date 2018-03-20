/area/ruin/powered/Immortus
	name = "\improper Immortus Clinic"

/area/ruin/powered/Immortus/burglaralert(obj/trigger)
	for(var/obj/machinery/door/poddoor/P in src)
		if(P.density)
			P.open()
			addtimer(CALLBACK(P, /obj/machinery/door.proc/close), 600)
		else
			P.close()
			addtimer(CALLBACK(P, /obj/machinery/door.proc/open), 600)
	for(var/obj/machinery/alarm_light/L in src)
		L.alarm()

/obj/machinery/alarm_light
	name = "alarm light"
	desc = "Designed to let someone know when they've REALLY fucked up."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "firelight0"
	light_color = "#ff0000"
	var/alarming = FALSE

/obj/machinery/alarm_light/proc/alarm(duration = 600) //deciseconds
	icon_state = "firelight1"
	light_range = 3
	var/timesup = world.time + duration
	var/initangle = dir2angle(turn(dir, 90))
	var/oppangle = dir2angle(turn(dir, -90))
	var/prevangle = initangle
	var/phase = 1
	set_light(light_range, light_power, light_color)
	light.directional = initangle
	while(world.time < timesup) // Simulates the spinning light within the alarm
		switch(phase)
			if(1)
				light_range--
			if(2)
				light_range--
			if(3)
				prevangle = light.directional
				light.directional = null
			if(4)
				if(prevangle == initangle)
					light.directional = oppangle
				else
					light.directional = initangle
			if(5)
				light_range++
			if(6)
				light_range++
				phase = 0
		update_light()
		phase++
		sleep(1)
	light_range = 0
	icon_state = "firelight0"



/obj/item/disk/holodisk/immortus_one
	name = "Welcome"
	preset_image_type = /datum/preset_holoimage/fuzzy
	preset_record_text = {"
	NAME Sentry
	DELAY 10
	SAY Welcome to Immortus Clinics
	DELAY 20
	SAY We understand that for our distinguished clients in their final days...
	DELAY 20
	SAY small-minded regulations and medical ethics can only offer to hasten your end.
	DELAY 20
	SAY Here at Immortus, we offer hope instead.
	DELAY 20
	SAY That is why we established this clinic in an unregistered sector...
	DELAY 20
	SAY to offer you the latest and most cutting-edge of treatments.
	DELAY 200;"}

/obj/item/disk/holodisk/immortus_two
	name = "Welcome"
	preset_image_type = /datum/preset_holoimage/fuzzy
	preset_record_text = {"
	NAME Sentry
	DELAY 10
	SAY Welcome to Immortus Clinics
	DELAY 20
	SAY We understand that for our distinguished clients in their final days...
	DELAY 20
	SAY small-minded regulations and medical ethics can only offer to hasten your end.
	DELAY 20
	SAY Here at Immortus, we offer hope instead.
	DELAY 20
	SAY That is why we established this clinic in an unregistered sector...
	DELAY 20
	SAY to offer you the latest and most cutting-edge of treatments.
	DELAY 200;"}

/obj/machinery/light/spooky
	var/default_on = FALSE
	var/frequency = 900 // Max time between flickering in deciseconds

/obj/machinery/light/spooky/on
	default_on = TRUE
	frequency = 3000

/obj/machinery/light/spooky/Initialize()
	GLOB.machines += src
	flicker_loop()

/obj/machinery/light/spooky/proc/flicker_loop()
	addtimer(CALLBACK(src, .proc/flicker_loop), rand(300, frequency))
	if(default_on)
		flicker(20)
		if(prob(5))
			var/turf/T = get_step(src, turn(dir, 180))
			sleep(rand(30,60))
			var/obj/structure/statue/male/S = new(T)
			sleep(8)
			qdel(S)
	else
		flicker(20, FALSE)
		if(prob(5))
			sleep(rand(20,50))
			var/turf/T = get_step(src, turn(dir, 180))
			var/obj/structure/statue/angel/A = new(T)
			var/mob/living/carbon/human/H = locate() in view(brightness, src)
			sleep(6)
			A.icon_state = "angelseen"
			if(H)
				A.forceMove(get_step(H, dir))
			sleep(6)
			qdel(A)


/obj/machinery/light/sequence
	brightness = 4
	on = FALSE
	var/static/list/lights = list(list(),list(),list(),list(),list(),list(),list(),list(),list(),list()) //Max of 10 groups
	var/group = 1
	var/static/sequencing

/obj/machinery/light/sequence/Initialize()
	GLOB.machines += src
	if(!sequencing)
		sequencing = TRUE
		addtimer(CALLBACK(src, /obj/machinery/light/sequence.proc/light_sequence, 1), 300)
	lights[group] += src

/obj/machinery/light/sequence/Destroy()
	lights[group] -= src
	. = ..()

/obj/machinery/light/sequence/proc/light_sequence(groupnum, backwards = FALSE)
	var/obj/machinery/light/sequence/chosen
	for(var/i in 1 to 4)
		chosen = pick(lights[groupnum])
		if(chosen.status == LIGHT_OK)
			break
	if(chosen)
		to_chat(world, "Flickering [chosen] at loc: [chosen.x], [chosen.y] in group #[chosen.group]")
		chosen.flicker(10)
	var/next = groupnum
	if(backwards)
		next--
		if(next == 0 || !LAZYLEN(lights[next]))
			next = 1
			addtimer(CALLBACK(chosen, .proc/light_sequence, next, FALSE), 75)
		else
			addtimer(CALLBACK(chosen, .proc/light_sequence, next, TRUE), 75)
	else
		next++
		if(next == 11 || !LAZYLEN(lights[next]))
			next -= 2
			addtimer(CALLBACK(chosen, .proc/light_sequence, next, TRUE), 75)
		else
			addtimer(CALLBACK(chosen, .proc/light_sequence, next, FALSE), 75)
	addtimer(CALLBACK(src, .proc/flicker, 20, FALSE), 100)


/mob/living/simple_animal/hostile/zombie
	name = "undead"
	desc = "An experiment - gone tragically wrong."
	icon = 'icons/mob/human.dmi'
	icon_state = "zombie"
	icon_living = "zombie"
	icon_dead = "zombie_dead"
	turns_per_move = 5
	move_to_delay = 5
	speak_emote = list("groans")
	emote_see = list("groans")
	a_intent = "harm"
	maxHealth = 60
	health = 60
	speed = 2.5
	obj_damage = 30
	melee_damage_lower = 20
	melee_damage_upper = 20
	attacktext = "claws"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 350
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	robust_searching = 1
	stat_attack = UNCONSCIOUS
	gold_core_spawnable = 0
	faction = list("zombie")
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/zombie = 3)
	see_invisible = SEE_INVISIBLE_MINIMUM
	see_in_dark = 8

/mob/living/simple_animal/hostile/zombie/death()
	..()
	addtimer(CALLBACK(src, .proc/arise), rand(400,600))

/mob/living/simple_animal/hostile/zombie/proc/arise()
	if(stat == DEAD)
		visible_message("<span class='danger'>[src] staggers to their feet!</span>")
		playsound(src, 'sound/hallucinations/growl1.ogg', 100, 1)
		revive(full_heal = 1)

/obj/structure/displaycase/necrostaff
	start_showpiece_type = /obj/item/gun/magic/staff/necro
	req_access = list(ACCESS_SYNDICATE_LEADER)

/obj/item/gun/magic/staff/necro
	name = "staff of necromancy"
	desc = "The product of failed experiments to achieve immortality, this staff can be used to turn the dead into some crude caricature of life. \
	<br><b>Use the staff in-hand to summon any thralls you've captured and enter attack mode, use it again to recall them and return to capture mode. \
	<br>In capture mode the staff's magic will claim the souls of the dead, in attack mode the staff's magic will designate a target for their aggression. \
	<br>Striking one of your thralls with the staff will release them from un-life.</b>"
	item_state = "staffofanimation"
	icon_state = "necrostaff"
	fire_sound = "sound/magic/summonitems_generic.ogg"
	ammo_type = /obj/item/ammo_casing/magic/necro
	max_charges = 2
	recharge_rate = 12
	var/capturing = TRUE
	var/max_souls = 10
	var/channeling = FALSE
	var/list/souls = list()

/obj/item/gun/magic/staff/necro/proc/summon(atom/target, mob/user)
	if(capturing && ismob(target) && loc == user)
		var/mob/M = target
		var/datum/beam/current_beam = M.Beam(loc,icon_state="chain",time=50)
		playsound(M,'sound/weapons/chainhit.ogg',50,1)
		user.visible_message("<span class='danger'>[user] attempts to bind [M]'s soul to the [src].</span>", "<span class='danger'>You attempt to bind [M]'s soul to the [src].</span>")
		if(!channeling)
			channeling = TRUE
			if(do_after(user, 30, target = user))
				if(M.stat == DEAD)
					if(souls.len < max_souls)
						playsound(M,'sound/magic/wandodeath.ogg',50,1)
						M.Beam(loc,icon_state="lichbeam",time=15)
						var/mob/living/simple_animal/hostile/mimic/copy/mob/MM = new(src, M, user)
						souls += MM
						MM.home = src
					else
						to_chat(user, "<span class='notice'>Your staff cannot hold any more souls!</span>")
				else
					to_chat(user, "<span class='notice'>Your staff can only capture the souls of the dead!</span>")
			qdel(current_beam)
			channeling = FALSE
	if(!capturing && souls.len)
		if(souls.len)
			to_chat(user, "<span class='danger'>You designate [target] for your thrall's wrath!</span>")
			for(var/mob/C in contents)
				C.faction = user.faction.Copy()
				C.forceMove(get_turf(src))
			for(var/mob/living/simple_animal/hostile/mimic/copy/mob/S in souls)
				S.marked = target
				S.GiveTarget(target)

/obj/item/gun/magic/staff/necro/attack_self(mob/user)
	if(capturing)
		playsound(src,'sound/magic/summon_karp.ogg',50,1)
		capturing = FALSE
		to_chat(user, "<span class='notice'>You twist the [src]'s grip, shifting the staff into <b>attack mode</b>.</span>")
	else
		capturing = TRUE
		playsound(src,'sound/magic/wandodeath.ogg',50,1)
		to_chat(user, "<span class='notice'>You twist the [src]'s grip, shifting the staff into <b>capture mode</b> [souls.len ? "and calling your thralls back to the staff.":"."]</span>")
		for(var/mob/living/simple_animal/hostile/H in souls)
			if(H.loc != src)
				H.LoseTarget()
				H.Beam(loc,icon_state="lichbeam",time=20)
				H.forceMove(src)

/obj/item/gun/magic/staff/necro/afterattack(atom/A, mob/user, proximity_flag)
	if(A in souls && user)
		var/mob/M = A
		user.visible_message("<span class='warning'>[user] releases [M] from the [src]'s service.</span>", "<span class='warning'>You release [M] from its eternal service.</span>")
		M.Beam(loc,icon_state="drainlife",time=20)
		M.death()
	else
		..()

/obj/item/gun/magic/staff/necro/Destroy()
	for(var/mob/S in souls)
		S.death()
	..()

/obj/item/ammo_casing/magic/necro
	projectile_type = /obj/item/projectile/magic/necro
	var/obj/item/gun/magic/staff/necro/holder

/obj/item/ammo_casing/magic/necro/Initialize()
	. = ..()
	if(istype(loc, /obj/item/gun/magic/staff/necro))
		holder = loc

/obj/item/projectile/magic/necro
	name = "bolt of necromancy"
	icon_state = "red_1"
	var/obj/item/gun/magic/staff/necro/the_staff

/obj/item/projectile/magic/necro/Initialize()
	. = ..()
	if(istype(loc, /obj/item/ammo_casing/magic/necro))
		var/obj/item/ammo_casing/magic/necro/ammo = loc
		if(ammo.holder)
			the_staff = ammo.holder

/obj/item/projectile/magic/necro/on_hit(atom/target)
	. = ..()
	if(the_staff)
		INVOKE_ASYNC(the_staff, /obj/item/gun/magic/staff/necro/.proc/summon, target, firer)

/obj/item/paper/contract/immortus
	name = "contract for magical power"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	icon_state = "paper_onfire"

/obj/item/paper/contract/immortus/Initialize()
	..()
	update_text()

/obj/item/paper/contract/immortus/update_text()
	info = "<center><B>Contract for resurrection</B></center><BR><BR><BR>I, Herbert West, of sound mind, do hereby willingly offer my soul to the infernal hells by way of the infernal agent, in exchange for arcane abilities beyond normal human ability. I understand that upon my demise, my soul shall fall into the infernal hells for all eternity.<BR><BR><BR>Signed, <font face=\"Nyala\" color=#600A0A size=6><i>Dr. Herbert West</i></font>"