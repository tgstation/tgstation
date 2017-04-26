//ass ass in

/datum/guardian_abilities/assassin
	id = "assassin"
	name = "Undetected Elimination"
	value = 6
	var/stealthcooldown = 160
	var/obj/screen/alert/canstealthalert
	var/obj/screen/alert/instealthalert

/datum/guardian_abilities/assassin/Destroy()
	return ..()

/datum/guardian_abilities/assassin/handle_stats()
	guardian.has_mode = TRUE
	guardian.melee_damage_lower += 7
	guardian.melee_damage_upper += 7
	guardian.attacktext = "slashes"
	guardian.attack_sound = 'sound/weapons/bladeslice.ogg'
	guardian.toggle_button_type = /obj/screen/guardian/ToggleMode/Assassin


/datum/guardian_abilities/assassin/proc/updatestealthalert()
	if(stealthcooldown <= world.time)
		if(toggle)
			if(!instealthalert)
				instealthalert = guardian.throw_alert("instealth", /obj/screen/alert/instealth)
				guardian.clear_alert("canstealth")
				canstealthalert = null
		else
			if(!canstealthalert)
				canstealthalert = guardian.throw_alert("canstealth", /obj/screen/alert/canstealth)
				guardian.clear_alert("instealth")
				instealthalert = null
	else
		guardian.clear_alert("instealth")
		instealthalert = null
		guardian.clear_alert("canstealth")
		canstealthalert = null


/datum/guardian_abilities/assassin/life_act()
	updatestealthalert()
	if(guardian.loc == user && toggle)
		guardian.ToggleMode(0)

/datum/guardian_abilities/assassin/handle_mode(forced = 0)
	if(toggle)
		guardian.melee_damage_lower = initial(guardian.melee_damage_lower)
		guardian.melee_damage_upper = initial(guardian.melee_damage_upper)
		guardian.armour_penetration = initial(guardian.armour_penetration)
		guardian.obj_damage = initial(guardian.obj_damage)
		guardian.environment_smash = initial(guardian.environment_smash)
		guardian.alpha = initial(guardian.alpha)
		if(!forced)
			to_chat(guardian,"<span class='danger'><B>You exit stealth.</span></B>")
		else
			guardian.visible_message("<span class='danger'>\The [guardian] suddenly appears!</span>")
			stealthcooldown = world.time + initial(stealthcooldown) //we were forcedd out of stealth and go on cooldown
			cooldown = world.time + 40 //can't recall for 4 seconds
		updatestealthalert()
		toggle = FALSE
	else if(stealthcooldown <= world.time)
		if(guardian.loc == user)
			to_chat(guardian,"<span class='danger'><B>You have to be manifested to enter stealth!</span></B>")
			return
		guardian.melee_damage_lower = 50
		guardian.melee_damage_upper = 50
		guardian.armour_penetration = 100
		guardian.obj_damage = 0
		guardian.environment_smash = 0
		new /obj/effect/overlay/temp/guardian/phase/out(get_turf(guardian))
		guardian.alpha = 15
		if(!forced)
			to_chat(guardian,"<span class='danger'><B>You enter stealth, empowering your next attack.</span></B>")
		updatestealthalert()
		toggle = TRUE
	else if(!forced)
		to_chat(guardian,"<span class='danger'><B>You cannot yet enter stealth, wait another [max(round((stealthcooldown - world.time)*0.1, 0.1), 0)] seconds!</span></B>")

/datum/guardian_abilities/assassin/ability_act()
	if(toggle && (isliving(guardian.target) || istype(guardian.target, /obj/structure/window) || istype(guardian.target, /obj/structure/grille)))
		guardian.ToggleMode(1)