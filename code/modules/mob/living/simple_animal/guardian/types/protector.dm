//Protector
/mob/living/simple_animal/hostile/guardian/protector
	melee_damage_lower = 15
	melee_damage_upper = 15
	range = 15 //worse for it due to how it leashes
	damage_coeff = list(BRUTE = 0.4, BURN = 0.4, TOX = 0.4, CLONE = 0.4, STAMINA = 0, OXY = 0.4)
	playstyle_string = span_holoparasite("As a <b>protector</b> type you cause your summoner to leash to you instead of you leashing to them and have two modes; Combat Mode, where you do and take medium damage, and Protection Mode, where you do and take almost no damage, but move slightly slower.")
	magic_fluff_string = span_holoparasite("..And draw the Guardian, a stalwart protector that never leaves the side of its charge.")
	tech_fluff_string = span_holoparasite("Boot sequence complete. Protector modules loaded. Holoparasite swarm online.")
	carp_fluff_string = span_holoparasite("CARP CARP CARP! You caught one! Wait, no... it caught you! The fisher has become the fishy.")
	miner_fluff_string = span_holoparasite("You encounter... Uranium, a very resistant guardian.")
	creator_name = "Protector"
	creator_desc = "Causes you to teleport to it when out of range, unlike other parasites. Has two modes; Combat, where it does and takes medium damage, and Protection, where it does and takes almost no damage but moves slightly slower."
	creator_icon = "protector"
	toggle_button_type = /atom/movable/screen/guardian/toggle_mode
	/// Damage removed in protecting mode.
	var/damage_penalty = 13
	/// Is it in protecting mode?
	var/toggle = FALSE
	/// Overlay of our protection shield.
	var/mutable_appearance/shield_overlay

/mob/living/simple_animal/hostile/guardian/protector/ex_act(severity)
	if(severity >= EXPLODE_DEVASTATE)
		adjustBruteLoss(400) //if in protector mode, will do 20 damage and not actually necessarily kill the summoner
	else
		. = ..()
	if(QDELETED(src))
		return FALSE
	if(toggle)
		visible_message(span_danger("The explosion glances off [src]'s energy shielding!"))

	return TRUE

/mob/living/simple_animal/hostile/guardian/protector/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(. > 0 && toggle)
		var/image/flash_overlay = new('icons/effects/effects.dmi', src, "shield-flash", layer+0.01, dir = pick(GLOB.cardinals))
		flash_overlay.color = guardian_color
		flick_overlay_view(flash_overlay, 0.5 SECONDS)

/mob/living/simple_animal/hostile/guardian/protector/toggle_modes()
	if(COOLDOWN_FINISHED(src, manifest_cooldown))
		return
	COOLDOWN_START(src, manifest_cooldown, 1 SECONDS)
	if(toggle)
		cut_overlay(shield_overlay)
		melee_damage_lower += damage_penalty
		melee_damage_upper += damage_penalty
		speed = initial(speed)
		damage_coeff = list(BRUTE = 0.4, BURN = 0.4, TOX = 0.4, CLONE = 0.4, STAMINA = 0, OXY = 0.4)
		to_chat(src, span_bolddanger("You switch to combat mode."))
		toggle = FALSE
	else
		if(!shield_overlay)
			shield_overlay = mutable_appearance('icons/effects/effects.dmi', "shield-grey")
			shield_overlay.color = guardian_color
		add_overlay(shield_overlay)
		melee_damage_lower -= damage_penalty
		melee_damage_upper -= damage_penalty
		speed = 1
		damage_coeff = list(BRUTE = 0.05, BURN = 0.05, TOX = 0.05, CLONE = 0.05, STAMINA = 0, OXY = 0.05) //damage? what's damage?
		to_chat(src, span_bolddanger("You switch to protection mode."))
		toggle = TRUE

/mob/living/simple_animal/hostile/guardian/protector/check_distance() //snap to what? snap to the guardian!
	if(!summoner || get_dist(summoner, src) <= range)
		return
	if(istype(summoner.loc, /obj/effect))
		to_chat(src, span_holoparasite("You moved out of range, and were pulled back! You can only move [range] meters from [summoner.real_name]!"))
		visible_message(span_danger("\The [src] jumps back to its user."))
		recall(forced = TRUE)
		return
	to_chat(summoner, span_holoparasite("You moved out of range, and were pulled back! You can only move [range] meters from <font color=\"[guardian_color]\"><b>[real_name]</b></font>!"))
	summoner.visible_message(span_danger("\The [summoner] jumps back to [summoner.p_their()] protector."))
	new /obj/effect/temp_visual/guardian/phase/out(get_turf(summoner))
	summoner.forceMove(get_turf(src))
	new /obj/effect/temp_visual/guardian/phase(get_turf(summoner))
