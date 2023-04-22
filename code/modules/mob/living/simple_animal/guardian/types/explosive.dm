#define UNREGISTER_BOMB_SIGNALS(A) \
	do { \
		UnregisterSignal(A, boom_signals); \
		UnregisterSignal(A, COMSIG_PARENT_EXAMINE); \
	} while (0)

//Explosive
/mob/living/simple_animal/hostile/guardian/explosive
	melee_damage_lower = 15
	melee_damage_upper = 15
	damage_coeff = list(BRUTE = 0.6, BURN = 0.6, TOX = 0.6, CLONE = 0.6, STAMINA = 0, OXY = 0.6)
	range = 13
	playstyle_string = span_holoparasite("As an <b>explosive</b> type, you have moderate close combat abilities and are capable of converting nearby items and objects into disguised bombs via right-click.")
	magic_fluff_string = span_holoparasite("..And draw the Scientist, master of explosive death.")
	tech_fluff_string = span_holoparasite("Boot sequence complete. Explosive modules active. Holoparasite swarm online.")
	carp_fluff_string = span_holoparasite("CARP CARP CARP! Caught one! It's an explosive carp! Boom goes the fishy.")
	miner_fluff_string = span_holoparasite("You encounter... Gibtonite, an explosive fighter.")
	creator_name = "Explosive"
	creator_desc = "High damage resist and medium power attack that may explosively teleport targets. Can turn any object, including objects too large to pick up, into a bomb, dealing explosive damage to the next person to touch it. The object will return to normal after the trap is triggered or after a delay."
	creator_icon = "explosive"
	/// Static list of signals that activate the boom.
	var/static/list/boom_signals = list(COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_BUMPED, COMSIG_ATOM_ATTACK_HAND)
	/// After this amount of time passses, boom deactivates.
	var/decay_time = 1 MINUTES
	/// Time between bombs.
	var/bomb_cooldown_time = 20 SECONDS
	/// The cooldown timer between bombs.
	COOLDOWN_DECLARE(bomb_cooldown)

/mob/living/simple_animal/hostile/guardian/explosive/get_status_tab_items()
	. = ..()
	if(!COOLDOWN_FINISHED(src, bomb_cooldown))
		. += "Bomb Cooldown Remaining: [DisplayTimeText(COOLDOWN_TIMELEFT(src, bomb_cooldown))]"

/mob/living/simple_animal/hostile/guardian/explosive/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	if(LAZYACCESS(modifiers, RIGHT_CLICK) && proximity_flag && isobj(attack_target))
		plant_bomb(attack_target)
		return
	return ..()

/mob/living/simple_animal/hostile/guardian/explosive/proc/plant_bomb(obj/planting_on)
	if(!COOLDOWN_FINISHED(src, bomb_cooldown))
		to_chat(src, span_bolddanger("Your powers are on cooldown! You must wait [DisplayTimeText(COOLDOWN_TIMELEFT(src, bomb_cooldown))] between bombs."))
		return
	to_chat(src, span_bolddanger("Success! Bomb armed!"))
	COOLDOWN_START(src, bomb_cooldown, bomb_cooldown_time)
	RegisterSignal(planting_on, COMSIG_PARENT_EXAMINE, PROC_REF(display_examine))
	RegisterSignals(planting_on, boom_signals, PROC_REF(kaboom))
	addtimer(CALLBACK(src, PROC_REF(disable), planting_on), decay_time, TIMER_UNIQUE|TIMER_OVERRIDE)

/mob/living/simple_animal/hostile/guardian/explosive/proc/kaboom(atom/source, mob/living/explodee)
	SIGNAL_HANDLER
	if(!istype(explodee))
		return
	if(explodee == src || explodee == summoner || hasmatchingsummoner(explodee))
		return
	to_chat(explodee, span_bolddanger("[source] was boobytrapped!"))
	to_chat(src, span_bolddanger("Success! Your trap caught [explodee]"))
	playsound(source, 'sound/effects/explosion2.ogg', 200, TRUE)
	new /obj/effect/temp_visual/explosion(get_turf(source))
	EX_ACT(explodee, EXPLODE_HEAVY)
	UNREGISTER_BOMB_SIGNALS(source)

/mob/living/simple_animal/hostile/guardian/explosive/proc/disable(obj/rigged_obj)
	to_chat(src, span_bolddanger("Failure! Your trap didn't catch anyone this time."))
	UNREGISTER_BOMB_SIGNALS(rigged_obj)

/mob/living/simple_animal/hostile/guardian/explosive/proc/display_examine(datum/source, mob/user, text)
	SIGNAL_HANDLER
	text += span_holoparasite("It glows with a strange <font color=\"[guardian_color]\">light</font>!")

#undef UNREGISTER_BOMB_SIGNALS
