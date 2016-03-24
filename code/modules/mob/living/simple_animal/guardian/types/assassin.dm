//Assassin
/mob/living/simple_animal/hostile/guardian/assassin
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	playstyle_string = "As an assassin type you do low damage and have no damage resistance, but can enter stealth, massively increasing the damage of your next attack and causing it to ignore armor. Stealth is broken when you attack or take damage."
	magic_fluff_string = "..And draw the Space Ninja, a lethal, invisible assassin."
	tech_fluff_string = "Boot sequence complete. Assassin modules loaded. Holoparasite swarm online."
	var/toggle = FALSE
	var/stealthcooldown = 150
	var/obj/screen/alert/canstealthalert
	var/obj/screen/alert/instealthalert

/mob/living/simple_animal/hostile/guardian/assassin/New()
	..()
	stealthcooldown = 0

/mob/living/simple_animal/hostile/guardian/assassin/Life()
	..()
	updatestealthalert()

/mob/living/simple_animal/hostile/guardian/assassin/Stat()
	..()
	if(statpanel("Status"))
		if(stealthcooldown >= world.time)
			stat(null, "Stealth Cooldown Remaining: [max(round((stealthcooldown - world.time)*0.1, 0.1), 0)] seconds")

/mob/living/simple_animal/hostile/guardian/assassin/AttackingTarget()
	if(..())
		if(toggle && (isliving(target) || istype(target, /obj/structure/window) || istype(target, /obj/structure/grille)))
			ToggleMode(1)

/mob/living/simple_animal/hostile/guardian/assassin/adjustHealth(amount)
	. = ..()
	if(. && toggle)
		ToggleMode(1)

/mob/living/simple_animal/hostile/guardian/assassin/Recall()
	if(..() && toggle)
		ToggleMode(0)

/mob/living/simple_animal/hostile/guardian/assassin/ToggleMode(forced = 0)
	if(src.loc != summoner)
		if(toggle)
			melee_damage_lower = initial(melee_damage_lower)
			melee_damage_upper = initial(melee_damage_upper)
			armour_penetration = initial(armour_penetration)
			environment_smash = initial(environment_smash)
			alpha = initial(alpha)
			if(!forced)
				src << "<span class='danger'><B>You exit stealth.</span></B>"
				updatestealthalert()
			else
				visible_message("<span class='danger'>\The [src] suddenly appears!</span>")
				stealthcooldown = world.time + initial(stealthcooldown) //we were forced out of stealth and go on cooldown
			toggle = FALSE
		else if(stealthcooldown <= world.time)
			melee_damage_lower = 60
			melee_damage_upper = 60
			armour_penetration = 100
			environment_smash = 0
			PoolOrNew(/obj/effect/overlay/temp/guardian/phase/out, get_turf(src))
			alpha = 15
			if(!forced)
				src << "<span class='danger'><B>You enter stealth, empowering your next attack.</span></B>"
			updatestealthalert()
			toggle = TRUE
		else if(!forced)
			src << "<span class='danger'><B>You cannot yet enter stealth, wait another [max(round((stealthcooldown - world.time)*0.1, 0.1), 0)] seconds!</span></B>"
	else if(!forced)
		src << "<span class='danger'><B>You have to be deployed to enter stealth!</span></B>"

/mob/living/simple_animal/hostile/guardian/assassin/proc/updatestealthalert()
	if(stealthcooldown <= world.time)
		if(toggle)
			if(!instealthalert)
				instealthalert = throw_alert("instealth", /obj/screen/alert/instealth)
				clear_alert("canstealth")
				canstealthalert = null
		else
			if(!canstealthalert)
				canstealthalert = throw_alert("canstealth", /obj/screen/alert/canstealth)
				clear_alert("instealth")
				instealthalert = null
	else
		clear_alert("instealth")
		instealthalert = null
		clear_alert("canstealth")
		canstealthalert = null
