//ass ass in

/datum/sutando_abilities/assassin
	id = "assassin"
	name = "Undetected Elimination"
	value = 6
	var/stealthcooldown = 160
	var/obj/screen/alert/canstealthalert
	var/obj/screen/alert/instealthalert

/datum/sutando_abilities/assassin/Destroy()
	return ..()

/datum/sutando_abilities/assassin/handle_stats()
	stand.has_mode = TRUE
	stand.melee_damage_lower += 7
	stand.melee_damage_upper += 7
	stand.attacktext = "slashes"
	stand.attack_sound = 'sound/weapons/bladeslice.ogg'
	stand.toggle_button_type = /obj/screen/sutando/ToggleMode/Assassin


/datum/sutando_abilities/assassin/proc/updatestealthalert()
	if(stealthcooldown <= world.time)
		if(toggle)
			if(!instealthalert)
				instealthalert = stand.throw_alert("instealth", /obj/screen/alert/instealth)
				stand.clear_alert("canstealth")
				canstealthalert = null
		else
			if(!canstealthalert)
				canstealthalert = stand.throw_alert("canstealth", /obj/screen/alert/canstealth)
				stand.clear_alert("instealth")
				instealthalert = null
	else
		stand.clear_alert("instealth")
		instealthalert = null
		stand.clear_alert("canstealth")
		canstealthalert = null


/datum/sutando_abilities/assassin/life_act()
	updatestealthalert()
	if(stand.loc == user && toggle)
		stand.ToggleMode(0)

/datum/sutando_abilities/assassin/handle_mode(forced = 0)
	if(toggle)
		stand.melee_damage_lower = initial(stand.melee_damage_lower)
		stand.melee_damage_upper = initial(stand.melee_damage_upper)
		stand.armour_penetration = initial(stand.armour_penetration)
		stand.obj_damage = initial(stand.obj_damage)
		stand.environment_smash = initial(stand.environment_smash)
		stand.alpha = initial(stand.alpha)
		if(!forced)
			to_chat(stand,"<span class='danger'><B>You exit stealth.</span></B>")
		else
			stand.visible_message("<span class='danger'>\The [stand] suddenly appears!</span>")
			stealthcooldown = world.time + initial(stealthcooldown) //we were forcedd out of stealth and go on cooldown
			cooldown = world.time + 40 //can't recall for 4 seconds
		updatestealthalert()
		toggle = FALSE
	else if(stealthcooldown <= world.time)
		if(stand.loc == user)
			to_chat(stand,"<span class='danger'><B>You have to be manifested to enter stealth!</span></B>")
			return
		stand.melee_damage_lower = 50
		stand.melee_damage_upper = 50
		stand.armour_penetration = 100
		stand.obj_damage = 0
		stand.environment_smash = 0
		new /obj/effect/overlay/temp/sutando/phase/out(get_turf(stand))
		stand.alpha = 15
		if(!forced)
			to_chat(stand,"<span class='danger'><B>You enter stealth, empowering your next attack.</span></B>")
		updatestealthalert()
		toggle = TRUE
	else if(!forced)
		to_chat(stand,"<span class='danger'><B>You cannot yet enter stealth, wait another [max(round((stealthcooldown - world.time)*0.1, 0.1), 0)] seconds!</span></B>")

/datum/sutando_abilities/assassin/ability_act()
	if(toggle && (isliving(stand.target) || istype(stand.target, /obj/structure/window) || istype(stand.target, /obj/structure/grille)))
		stand.ToggleMode(1)