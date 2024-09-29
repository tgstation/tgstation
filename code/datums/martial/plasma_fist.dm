#define TORNADO_COMBO "HHD"
#define THROWBACK_COMBO "DHD"
#define PLASMA_COMBO "HDDDH"

/datum/martial_art/plasma_fist
	name = "Plasma Fist"
	id = MARTIALART_PLASMAFIST
	help_verb = /mob/living/proc/plasma_fist_help
	var/nobomb = FALSE
	var/plasma_power = 1 //starts at a 1, 2, 4 explosion.
	var/plasma_increment = 1 //how much explosion power gets added per kill (1 = 1, 2, 4. 2 = 2, 4, 8 and so on)
	var/plasma_cap = 12 //max size explosion level
	var/datum/action/cooldown/spell/aoe/repulse/tornado_spell
	display_combos = TRUE

/datum/martial_art/plasma_fist/New()
	. = ..()
	tornado_spell = new(src)

/datum/martial_art/plasma_fist/Destroy()
	tornado_spell = null
	return ..()

/datum/martial_art/plasma_fist/proc/check_streak(mob/living/attacker, mob/living/defender)
	if(findtext(streak,TORNADO_COMBO))
		if(attacker == defender)//helps using apotheosis
			return FALSE
		reset_streak()
		return Tornado(attacker, defender)
	if(findtext(streak,THROWBACK_COMBO))
		if(attacker == defender)//helps using apotheosis
			return FALSE
		reset_streak()
		return Throwback(attacker, defender)
	if(findtext(streak,PLASMA_COMBO))
		reset_streak()
		if(attacker == defender && !nobomb)
			return Apotheosis(attacker, defender)
		return Plasma(attacker, defender)
	return FALSE

/datum/martial_art/plasma_fist/proc/Tornado(mob/living/attacker, mob/living/defender)
	attacker.say("TORNADO SWEEP!", forced="plasma fist")
	dance_rotate(attacker, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), attacker, 'sound/items/weapons/punch1.ogg', 15, TRUE, -1))
	tornado_spell.cast(attacker)
	log_combat(attacker, defender, "tornado sweeped (Plasma Fist)")
	return TRUE

/datum/martial_art/plasma_fist/proc/Throwback(mob/living/attacker, mob/living/defender)
	defender.visible_message(
		span_danger("[attacker] hits [defender] with Plasma Punch!"),
		span_userdanger("You're hit with a Plasma Punch by [attacker]!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		null,
		attacker,
	)
	to_chat(attacker, span_danger("You hit [defender] with Plasma Punch!"))
	playsound(defender, 'sound/items/weapons/punch1.ogg', 50, TRUE, -1)
	var/atom/throw_target = get_edge_target_turf(defender, get_dir(defender, get_step_away(defender, attacker)))
	defender.throw_at(throw_target, 200, 4,attacker)
	attacker.say("HYAH!", forced="plasma fist")
	log_combat(attacker, defender, "threw back (Plasma Fist)")
	return TRUE

/datum/martial_art/plasma_fist/proc/Plasma(mob/living/attacker, mob/living/defender)
	var/hasclient = !!defender.client

	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	playsound(defender, 'sound/items/weapons/punch1.ogg', 50, TRUE, -1)
	attacker.say("PLASMA FIST!", forced="plasma fist")
	defender.visible_message(
		span_danger("[attacker] hits [defender] with THE PLASMA FIST TECHNIQUE!"),
		span_userdanger("You're suddenly hit with THE PLASMA FIST TECHNIQUE by [attacker]!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		null,
		attacker,
	)
	to_chat(attacker, span_danger("You hit [defender] with THE PLASMA FIST TECHNIQUE!"))
	log_combat(attacker, defender, "gibbed (Plasma Fist)")
	var/turf/Dturf = get_turf(defender)
	defender.investigate_log("has been gibbed by plasma fist.", INVESTIGATE_DEATHS)
	defender.gib(DROP_ALL_REMAINS)
	if(nobomb)
		return

	if(!hasclient)
		to_chat(attacker, span_warning("Taking this plasma energy for your </span>[span_notice("Apotheosis")]<span class='warning'> would bring dishonor to the clan!"))
		new /obj/effect/temp_visual/plasma_soul(Dturf)//doesn't beam to you, so it just hangs around and poofs.

	else if(plasma_power >= plasma_cap)
		to_chat(attacker, span_warning("You cannot power up your </span>[span_notice("Apotheosis")]<span class='warning'> any more!"))
		new /obj/effect/temp_visual/plasma_soul(Dturf)//doesn't beam to you, so it just hangs around and poofs.

	else
		plasma_power += plasma_increment
		to_chat(attacker, span_nicegreen("Power increasing! Your </span>[span_notice("Apotheosis")]<span class='nicegreen'> is now at power level [plasma_power]!"))
		new /obj/effect/temp_visual/plasma_soul(Dturf, attacker)
		var/oldcolor = attacker.color
		attacker.color = "#9C00FF"
		flash_color(attacker, flash_color = "#9C00FF", flash_time = 3 SECONDS)
		animate(attacker, color = oldcolor, time = 3 SECONDS)

	return TRUE

/datum/martial_art/plasma_fist/proc/Apotheosis(mob/living/user, mob/living/target)
	user.say("APOTHEOSIS!!", forced="plasma fist")
	if (ishuman(user))
		var/mob/living/carbon/human/human_attacker = user
		human_attacker.set_species(/datum/species/plasmaman)
		human_attacker.add_traits(list(TRAIT_FORCED_STANDING, TRAIT_BOMBIMMUNE), type)
		human_attacker.unequip_everything()
		human_attacker.underwear = "Nude"
		human_attacker.undershirt = "Nude"
		human_attacker.socks = "Nude"
		human_attacker.update_body()

	var/turf/boomspot = get_turf(user)
	//before ghosting to prevent issues
	log_combat(user, user, "triggered final plasma explosion with size [plasma_power], [plasma_power*2], [plasma_power*4] (Plasma Fist)")
	message_admins("[key_name_admin(user)] triggered final plasma explosion with size [plasma_power], [plasma_power*2], [plasma_power*4].")

	to_chat(user, span_userdanger("The explosion knocks your soul out of your body!"))
	user.ghostize(FALSE) //prevents... horrible memes just believe me

	user.apply_damage(rand(50, 70), BRUTE, wound_bonus = CANT_WOUND)

	addtimer(CALLBACK(src, PROC_REF(Apotheosis_end), user), 6 SECONDS)
	playsound(boomspot, 'sound/items/weapons/punch1.ogg', 50, TRUE, -1)
	explosion(user, devastation_range = plasma_power, heavy_impact_range = plasma_power*2, light_impact_range = plasma_power*4, ignorecap = TRUE, explosion_cause = src)
	plasma_power = 1 //just in case there is any clever way to cause it to happen again
	return TRUE

/datum/martial_art/plasma_fist/proc/Apotheosis_end(mob/living/dying)
	dying.remove_traits(list(TRAIT_FORCED_STANDING, TRAIT_BOMBIMMUNE), type)
	if(dying.stat == DEAD)
		return
	dying.investigate_log("has been killed by plasma fist apotheosis.", INVESTIGATE_DEATHS)
	dying.death()

/datum/martial_art/plasma_fist/harm_act(mob/living/attacker, mob/living/defender)
	if(defender.check_block(attacker, 10, attacker.name, UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	add_to_streak("H", defender)
	return check_streak(attacker, defender) ? MARTIAL_ATTACK_SUCCESS : MARTIAL_ATTACK_INVALID

/datum/martial_art/plasma_fist/disarm_act(mob/living/attacker, mob/living/defender)
	if(defender.check_block(attacker, 0, attacker.name, UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL
	add_to_streak("D", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS
	if(attacker == defender)//there is no disarming yourself, so we need to let plasma fist user know
		to_chat(attacker, span_notice("You have added a disarm to your streak."))
		return MARTIAL_ATTACK_FAIL
	return MARTIAL_ATTACK_INVALID

/datum/martial_art/plasma_fist/grab_act(mob/living/attacker, mob/living/defender)
	if(defender.check_block(attacker, 0, "[attacker]'s grab", UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	add_to_streak("G", defender)
	return check_streak(attacker, defender) ? MARTIAL_ATTACK_SUCCESS : MARTIAL_ATTACK_INVALID

/mob/living/proc/plasma_fist_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Plasma Fist."
	set category = "Plasma Fist"

	var/datum/martial_art/plasma_fist/martial = usr.mind.martial_art
	to_chat(usr, "<b><i>You clench your fists and have a flashback of knowledge...</i></b>")
	to_chat(usr, "[span_notice("Tornado Sweep")]: Punch Punch Shove. Repulses opponent and everyone back.")
	to_chat(usr, "[span_notice("Throwback")]: Shove Punch Shove. Throws the opponent and an item at them.")
	to_chat(usr, "[span_notice("The Plasma Fist")]: Punch Shove Shove Shove Punch. Instantly gibs an opponent.[martial.nobomb ? "" : " Each kill with this grows your [span_notice("Apotheosis")] explosion size."]")
	if(!martial.nobomb)
		to_chat(usr, "[span_notice("Apotheosis")]: Use [span_notice("The Plasma Fist")] on yourself. Sends you away in a glorious explosion.")


/obj/effect/temp_visual/plasma_soul
	name = "plasma energy"
	desc = "Leftover energy brought out from The Plasma Fist."
	icon = 'icons/effects/effects.dmi'
	icon_state = "plasmasoul"
	duration = 3 SECONDS
	var/atom/movable/beam_target

/obj/effect/temp_visual/plasma_soul/Initialize(mapload, _beam_target)
	. = ..()
	beam_target = _beam_target
	if(beam_target)
		var/datum/beam/beam = Beam(beam_target, "plasmabeam", beam_type=/obj/effect/ebeam/plasma_fist, time = 3 SECONDS)
		animate(beam.visuals, alpha = 0, time = 3 SECONDS)
	animate(src, alpha = 0, transform = matrix()*0.5, time = 3 SECONDS)

/obj/effect/temp_visual/plasma_soul/Destroy()
	if(!beam_target)
		visible_message(span_notice("[src] fades away..."))
	. = ..()

/obj/effect/ebeam/plasma_fist
	name = "plasma"
	mouse_opacity = MOUSE_OPACITY_ICON
	desc = "Flowing energy."

/datum/martial_art/plasma_fist/nobomb
	name = "Novice Plasma Fist"
	nobomb = TRUE

#undef TORNADO_COMBO
#undef THROWBACK_COMBO
#undef PLASMA_COMBO
