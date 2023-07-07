//Assassin
/mob/living/simple_animal/hostile/guardian/assassin
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	sharpness = SHARP_POINTY
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	playstyle_string = span_holoparasite("As an <b>assassin</b> type you do medium damage and have no damage resistance, but can enter stealth, massively increasing the damage of your next attack and causing it to ignore armor. Stealth is broken when you attack or take damage.")
	magic_fluff_string = span_holoparasite("..And draw the Space Ninja, a lethal, invisible assassin.")
	tech_fluff_string = span_holoparasite("Boot sequence complete. Assassin modules loaded. Holoparasite swarm online.")
	carp_fluff_string = span_holoparasite("CARP CARP CARP! Caught one! It's an assassin carp! Just when you thought it was safe to go back to the water... which is unhelpful, because we're in space.")
	miner_fluff_string = span_holoparasite("You encounter... Glass, a sharp, fragile attacker.")
	creator_name = "Assassin"
	creator_desc = "Does medium damage and takes full damage, but can enter stealth, causing its next attack to do massive damage and ignore armor. However, it becomes briefly unable to recall after attacking from stealth."
	creator_icon = "assassin"
	toggle_button_type = /atom/movable/screen/guardian/toggle_mode/assassin
	/// Is it in stealth mode?
	var/toggle = FALSE
	/// Time between going in stealth.
	var/stealth_cooldown_time = 16 SECONDS
	/// Damage added in stealth mode.
	var/damage_bonus = 35
	/// Our wound bonus when in stealth mode.
	var/stealth_wound_bonus = -20 //from -100, you can now wound!
	/// Screen alert given when we are able to stealth.
	var/atom/movable/screen/alert/canstealthalert
	/// Screen alert given when we are in stealth.
	var/atom/movable/screen/alert/instealthalert
	/// Cooldown for the stealth toggle.
	COOLDOWN_DECLARE(stealth_cooldown)

/mob/living/simple_animal/hostile/guardian/assassin/get_status_tab_items()
	. = ..()
	if(!COOLDOWN_FINISHED(src, stealth_cooldown))
		. += "Stealth Cooldown Remaining: [DisplayTimeText(COOLDOWN_TIMELEFT(src, stealth_cooldown))]"

/mob/living/simple_animal/hostile/guardian/assassin/AttackingTarget(atom/attacked_target)
	. = ..()
	if(.)
		if(toggle && (isliving(target) || istype(target, /obj/structure/window) || istype(target, /obj/structure/grille)))
			toggle_modes(forced = TRUE)

/mob/living/simple_animal/hostile/guardian/assassin/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(. > 0 && toggle)
		toggle_modes(forced = TRUE)

/mob/living/simple_animal/hostile/guardian/assassin/recall_effects()
	if(toggle)
		toggle_modes(forced = TRUE)

/mob/living/simple_animal/hostile/guardian/assassin/toggle_modes(forced = FALSE)
	if(toggle)
		melee_damage_lower -= damage_bonus
		melee_damage_upper -= damage_bonus
		armour_penetration = initial(armour_penetration)
		wound_bonus = initial(wound_bonus)
		obj_damage = initial(obj_damage)
		environment_smash = initial(environment_smash)
		alpha = initial(alpha)
		if(!forced)
			to_chat(src, span_bolddanger("You exit stealth."))
		else
			visible_message(span_danger("\The [src] suddenly appears!"))
			COOLDOWN_START(src, stealth_cooldown, stealth_cooldown_time) //we were forced out of stealth and go on cooldown
			addtimer(CALLBACK(src, PROC_REF(updatestealthalert)), stealth_cooldown_time)
			COOLDOWN_START(src, manifest_cooldown, 4 SECONDS) //can't recall for 4 seconds
		updatestealthalert()
		toggle = FALSE
	else if(COOLDOWN_FINISHED(src, stealth_cooldown))
		if(!is_deployed())
			to_chat(src, span_bolddanger("You have to be manifested to enter stealth!"))
			return
		melee_damage_lower += damage_bonus
		melee_damage_upper += damage_bonus
		armour_penetration = 100
		wound_bonus = stealth_wound_bonus
		obj_damage = 0
		environment_smash = ENVIRONMENT_SMASH_NONE
		new /obj/effect/temp_visual/guardian/phase/out(get_turf(src))
		alpha = 15
		if(!forced)
			to_chat(src, span_bolddanger("You enter stealth, empowering your next attack."))
		updatestealthalert()
		toggle = TRUE
	else if(!forced)
		to_chat(src, span_bolddanger("You cannot yet enter stealth, wait another [DisplayTimeText(COOLDOWN_TIMELEFT(src, stealth_cooldown))]!"))

/mob/living/simple_animal/hostile/guardian/assassin/proc/updatestealthalert()
	if(!COOLDOWN_FINISHED(src, stealth_cooldown))
		clear_alert("instealth")
		instealthalert = null
		clear_alert("canstealth")
		canstealthalert = null
		return
	if(toggle && !instealthalert)
		instealthalert = throw_alert("instealth", /atom/movable/screen/alert/instealth)
		clear_alert("canstealth")
		canstealthalert = null
	else if(!toggle && !canstealthalert)
		canstealthalert = throw_alert("canstealth", /atom/movable/screen/alert/canstealth)
		clear_alert("instealth")
		instealthalert = null

