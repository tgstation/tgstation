/**
 * Mech prizes + MECHA COMBAT!!
 */

/// Mech battle special attack types.
#define SPECIAL_ATTACK_HEAL 1
#define SPECIAL_ATTACK_DAMAGE 2
#define SPECIAL_ATTACK_UTILITY 3
#define SPECIAL_ATTACK_OTHER 4

/// Max length of a mech battle
#define MAX_BATTLE_LENGTH 50

/obj/item/toy/prize
	icon = 'icons/obj/toy.dmi'
	icon_state = "ripleytoy"
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	verb_yell = "beeps"
	w_class = WEIGHT_CLASS_SMALL
	/// Timer when it'll be off cooldown
	var/timer = 0
	/// Cooldown between play sessions
	var/cooldown = 1.5 SECONDS
	/// Cooldown multiplier after a battle (by default: battle cooldowns are 30 seconds)
	var/cooldown_multiplier = 20
	/// If it makes noise when played with
	var/quiet = FALSE
	/// TRUE = Offering battle to someone || FALSE = Not offering battle
	var/wants_to_battle = FALSE
	/// TRUE = in combat currently || FALSE = Not in combat
	var/in_combat = FALSE
	/// The mech's health in battle
	var/combat_health = 0
	/// The mech's max combat health
	var/max_combat_health = 0
	/// TRUE = the special attack is charged || FALSE = not charged
	var/special_attack_charged = FALSE
	/// What type of special attack they use - SPECIAL_ATTACK_DAMAGE, SPECIAL_ATTACK_HEAL, SPECIAL_ATTACK_UTILITY, SPECIAL_ATTACK_OTHER
	var/special_attack_type = 0
	/// What message their special move gets on examining
	var/special_attack_type_message = ""
	/// The battlecry when using the special attack
	var/special_attack_cry = "*flip"
	/// Current cooldown of their special attack
	var/special_attack_cooldown = 0
	/// This mech's win count in combat
	var/wins = 0
	/// ...And their loss count in combat
	var/losses = 0

/obj/item/toy/prize/Initialize()
	. = ..()
	desc = "Mini-Mecha action figure! Collect them all! Attack your friends or another mech with one to initiate epic mech combat! [desc]."
	combat_health = max_combat_health
	switch(special_attack_type)
		if(SPECIAL_ATTACK_DAMAGE)
			special_attack_type_message = "an aggressive move, which deals bonus damage."
		if(SPECIAL_ATTACK_HEAL)
			special_attack_type_message = "a defensive move, which grants bonus healing."
		if(SPECIAL_ATTACK_UTILITY)
			special_attack_type_message = "a utility move, which heals the user and damages the opponent."
		if(SPECIAL_ATTACK_OTHER)
			special_attack_type_message = "a special move, which [special_attack_type_message]"
		else
			special_attack_type_message = "a mystery move, even I don't know."

/**
 * this proc combines "sleep" while also checking for if the battle should continue
 *
 * this goes through some of the checks - the toys need to be next to each other to fight!
 * if it's player vs themself: They need to be able to "control" both mechs (either must be adjacent or using TK)
 * if it's player vs player: Both players need to be able to "control" their mechs (either must be adjacent or using TK)
 * if it's player vs mech (suicide): the mech needs to be in range of the player
 * if all the checks are TRUE, it does the sleeps, and returns TRUE. Otherwise, it returns FALSE.
 * Arguments:
 * * delay - the amount of time the sleep at the end of the check will sleep for
 * * attacker - the attacking toy in the battle.
 * * attacker_controller - the controller of the attacking toy. there should ALWAYS be an attacker_controller
 * * opponent - (optional) the defender controller in the battle, for PvP
 */
/obj/item/toy/prize/proc/combat_sleep(delay, obj/item/toy/prize/attacker, mob/living/carbon/attacker_controller, mob/living/carbon/opponent)
	if(!attacker_controller)
		return FALSE

	if(!attacker) //if there's no attacker, then attacker_controller IS the attacker
		if(!in_range(src, attacker_controller))
			attacker_controller.visible_message("<span class='suicide'>[attacker_controller] is running from [src]! The coward!</span>")
			return FALSE
	else // if there's an attacker, we can procede as normal
		if(!in_range(src, attacker)) //and the two toys aren't next to each other, the battle ends
			attacker_controller.visible_message("<span class='notice'> [attacker] and [src] separate, ending the battle. </span>", \
								"<span class='notice'> [attacker] and [src] separate, ending the battle. </span>")
			return FALSE

		//dead men tell no tales, incapacitated men fight no fights
		if(attacker_controller.incapacitated())
			return FALSE
		//if the attacker_controller isn't next to the attacking toy (and doesn't have telekinesis), the battle ends
		if(!in_range(attacker, attacker_controller) && !(attacker_controller.dna.check_mutation(TK)))
			attacker_controller.visible_message("<span class='notice'> [attacker_controller.name] seperates from [attacker], ending the battle.</span>", \
								"<span class='notice'> You separate from [attacker], ending the battle. </span>")
			return FALSE

		//if it's PVP and the opponent is not next to the defending(src) toy (and doesn't have telekinesis), the battle ends
		if(opponent)
			if(opponent.incapacitated())
				return FALSE
			if(!in_range(src, opponent) && !(opponent.dna.check_mutation(TK)))
				opponent.visible_message("<span class='notice'> [opponent.name] seperates from [src], ending the battle.</span>", \
							"<span class='notice'> You separate from [src], ending the battle. </span>")
				return FALSE
		//if it's not PVP and the attacker_controller isn't next to the defending toy (and doesn't have telekinesis), the battle ends
		else
			if (!in_range(src, attacker_controller) && !(attacker_controller.dna.check_mutation(TK)))
				attacker_controller.visible_message("<span class='notice'> [attacker_controller.name] seperates from [src] and [attacker], ending the battle.</span>", \
									"<span class='notice'> You separate [attacker] and [src], ending the battle. </span>")
				return FALSE

	//if all that is good, then we can sleep peacefully
	sleep(delay)
	return TRUE

//all credit to skasi for toy mech fun ideas
/obj/item/toy/prize/attack_self(mob/user)
	if(timer < world.time)
		to_chat(user, "<span class='notice'>You play with [src].</span>")
		timer = world.time + cooldown
		if(!quiet)
			playsound(user, 'sound/mecha/mechstep.ogg', 20, TRUE)
	else
		. = ..()

/obj/item/toy/prize/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(loc == user)
		attack_self(user)

/**
 * If you attack a mech with a mech, initiate combat between them
 */
/obj/item/toy/prize/attackby(obj/item/user_toy, mob/living/user)
	if(istype(user_toy, /obj/item/toy/prize))
		var/obj/item/toy/prize/P = user_toy
		if(check_battle_start(user, P))
			mecha_brawl(P, user)
	..()

/**
 * Attack is called from the user's toy, aimed at target(another human), checking for target's toy.
 */
/obj/item/toy/prize/attack(mob/living/carbon/human/target, mob/living/carbon/human/user)
	if(target == user)
		to_chat(user, "<span class='notice'>Target another toy mech if you want to start a battle with yourself.</span>")
		return
	else if(!user.combat_mode)
		if(wants_to_battle) //prevent spamming someone with offers
			to_chat(user, "<span class='notice'>You already are offering battle to someone!</span>")
			return
		if(!check_battle_start(user)) //if the user's mech isn't ready, don't bother checking
			return

		for(var/obj/item/I in target.held_items)
			if(istype(I, /obj/item/toy/prize)) //if you attack someone with a mech who's also holding a mech, offer to battle them
				var/obj/item/toy/prize/P = I
				if(!P.check_battle_start(target, null, user)) //check if the attacker mech is ready
					break

				//slap them with the metaphorical white glove
				if(P.wants_to_battle) //if the target mech wants to battle, initiate the battle from their POV
					mecha_brawl(P, target, user) //P = defender's mech / SRC = attacker's mech / target = defender / user = attacker
					P.wants_to_battle = FALSE
					return

		//extend the offer of battle to the other mech
		to_chat(user, "<span class='notice'>You offer battle to [target.name]!</span>")
		to_chat(target, "<span class='notice'><b>[user.name] wants to battle with [user.p_their()] [name]!</b> <i>Attack them with a toy mech to initiate combat.</i></span>")
		wants_to_battle = TRUE
		addtimer(CALLBACK(src, .proc/withdraw_offer, user), 6 SECONDS)
		return

	..()

/**
 * Overrides attack_tk - Sorry, you have to be face to face to initiate a battle, it's good sportsmanship
 */
/obj/item/toy/prize/attack_tk(mob/user)
	if(timer < world.time)
		to_chat(user, "<span class='notice'>You telekinetically play with [src].</span>")
		timer = world.time + cooldown
		if(!quiet)
			playsound(user, 'sound/mecha/mechstep.ogg', 20, TRUE)
	return COMPONENT_CANCEL_ATTACK_CHAIN


/**
 * Resets the request for battle.
 *
 * For use in a timer, this proc resets the wants_to_battle variable after a short period.
 * Arguments:
 * * user - the user wanting to do battle
 */
/obj/item/toy/prize/proc/withdraw_offer(mob/living/carbon/user)
	if(wants_to_battle)
		wants_to_battle = FALSE
		to_chat(user, "<span class='notice'>You get the feeling they don't want to battle.</span>")
/**
 * Starts a battle, toy mech vs player. Player... doesn't win.
 */
/obj/item/toy/prize/suicide_act(mob/living/carbon/user)
	if(in_combat)
		to_chat(user, "<span class='notice'>[src] is in battle, let it finish first.</span>")
		return

	user.visible_message("<span class='suicide'>[user] begins a fight [user.p_they()] can't win with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")

	in_combat = TRUE
	sleep(1.5 SECONDS)
	for(var/i in 1 to 4)
		switch(i)
			if(1, 3)
				SpinAnimation(5, 0)
				playsound(src, 'sound/mecha/mechstep.ogg', 30, TRUE)
				user.adjustBruteLoss(25)
				user.adjustStaminaLoss(50)
			if(2)
				user.SpinAnimation(5, 0)
				playsound(user, 'sound/weapons/smash.ogg', 20, TRUE)
				combat_health-- //we scratched it!
			if(4)
				say(special_attack_cry + "!!")
				user.adjustStaminaLoss(25)

		if(!combat_sleep(1 SECONDS, null, user))
			say("PATHETIC.")
			combat_health = max_combat_health
			in_combat = FALSE
			return SHAME

	sleep(0.5 SECONDS)
	user.adjustBruteLoss(450)

	in_combat = FALSE
	say("AN EASY WIN. MY POWER INCREASES.") // steal a soul, become swole
	add_atom_colour(rgb(255, 115, 115), ADMIN_COLOUR_PRIORITY)
	max_combat_health = round(max_combat_health*1.5 + 0.1)
	combat_health = max_combat_health
	wins++
	return BRUTELOSS

/obj/item/toy/prize/examine()
	. = ..()
	. += "<span class='notice'>This toy's special attack is [special_attack_cry], [special_attack_type_message] </span>"
	if(in_combat)
		. += "<span class='notice'>This toy has a maximum health of [max_combat_health]. Currently, it's [combat_health].</span>"
		. += "<span class='notice'>Its special move light is [special_attack_cooldown? "flashing red." : "green and is ready!"]</span>"
	else
		. += "<span class='notice'>This toy has a maximum health of [max_combat_health].</span>"

	if(wins || losses)
		. += "<span class='notice'>This toy has [wins] wins, and [losses] losses.</span>"

/**
 * Override the say proc if they're mute
 */
/obj/item/toy/prize/say()
	if(!quiet)
		. = ..()

/**
 * The 'master' proc of the mech battle. Processes the entire battle's events and makes sure it start and finishes correctly.
 *
 * src is the defending toy, and the battle proc is called on it to begin the battle.
 * After going through a few checks at the beginning to ensure the battle can start properly, the battle begins a loop that lasts
 * until either toy has no more health. During this loop, it also ensures the mechs stay in combat range of each other.
 * It will then randomly decide attacks for each toy, occasionally making one or the other use their special attack.
 * When either mech has no more health, the loop ends, and it displays the victor and the loser while updating their stats and resetting them.
 * Arguments:
 * * attacker - the attacking toy, the toy in the attacker_controller's hands
 * * attacker_controller - the user, the one who is holding the toys / controlling the fight
 * * opponent - optional arg used in Mech PvP battles: the other person who is taking part in the fight (controls src)
 */
/obj/item/toy/prize/proc/mecha_brawl(obj/item/toy/prize/attacker, mob/living/carbon/attacker_controller, mob/living/carbon/opponent)
	//A GOOD DAY FOR A SWELL BATTLE!
	attacker_controller.visible_message("<span class='danger'> [attacker_controller.name] collides [attacker] with [src]! Looks like they're preparing for a brawl! </span>", \
						"<span class='danger'> You collide [attacker] into [src], sparking a fierce battle! </span>", \
						"<span class='hear'> You hear hard plastic smacking into hard plastic.</span>", COMBAT_MESSAGE_RANGE)

	/// Who's in control of the defender (src)?
	var/mob/living/carbon/src_controller = (opponent)? opponent : attacker_controller
	/// How long has the battle been going?
	var/battle_length = 0

	in_combat = TRUE
	attacker.in_combat = TRUE

	//1.5 second cooldown * 20 = 30 second cooldown after a fight
	timer = world.time + cooldown*cooldown_multiplier
	attacker.timer = world.time + attacker.cooldown*attacker.cooldown_multiplier

	sleep(1 SECONDS)
	//--THE BATTLE BEGINS--
	while(combat_health > 0 && attacker.combat_health > 0 && battle_length < MAX_BATTLE_LENGTH)
		if(!combat_sleep(0.5 SECONDS, attacker, attacker_controller, opponent)) //combat_sleep checks everything we need to have checked for combat to continue
			break

		//before we do anything - deal with charged attacks
		if(special_attack_charged)
			src_controller.visible_message("<span class='danger'> [src] unleashes its special attack!! </span>", \
							"<span class='danger'> You unleash [src]'s special attack! </span>")
			special_attack_move(attacker)
		else if(attacker.special_attack_charged)

			attacker_controller.visible_message("<span class='danger'> [attacker] unleashes its special attack!! </span>", \
								"<span class='danger'> You unleash [attacker]'s special attack! </span>")
			attacker.special_attack_move(src)
		else
			//process the cooldowns
			if(special_attack_cooldown > 0)
				special_attack_cooldown--
			if(attacker.special_attack_cooldown > 0)
				attacker.special_attack_cooldown--

			//combat commences
			switch(rand(1,8))
				if(1 to 3) //attacker wins
					if(attacker.special_attack_cooldown == 0 && attacker.combat_health <= round(attacker.max_combat_health/3)) //if health is less than 1/3 and special off CD, use it
						attacker.special_attack_charged = TRUE
						attacker_controller.visible_message("<span class='danger'> [attacker] begins charging its special attack!! </span>", \
											"<span class='danger'> You begin charging [attacker]'s special attack! </span>")
					else //just attack
						attacker.SpinAnimation(5, 0)
						playsound(attacker, 'sound/mecha/mechstep.ogg', 30, TRUE)
						combat_health--
						attacker_controller.visible_message("<span class='danger'> [attacker] devastates [src]! </span>", \
											"<span class='danger'> You ram [attacker] into [src]! </span>", \
											"<span class='hear'> You hear hard plastic smacking hard plastic.</span>", COMBAT_MESSAGE_RANGE)
						if(prob(5))
							combat_health--
							playsound(src, 'sound/effects/meteorimpact.ogg', 20, TRUE)
							attacker_controller.visible_message("<span class='boldwarning'> ...and lands a CRIPPLING BLOW! </span>", \
												"<span class='boldwarning'> ...and you land a CRIPPLING blow on [src]! </span>", null, COMBAT_MESSAGE_RANGE)

				if(4) //both lose
					attacker.SpinAnimation(5, 0)
					SpinAnimation(5, 0)
					combat_health--
					attacker.combat_health--
					do_sparks(2, FALSE, src)
					do_sparks(2, FALSE, attacker)
					if(prob(50))
						attacker_controller.visible_message("<span class='danger'> [attacker] and [src] clash dramatically, causing sparks to fly! </span>", \
											"<span class='danger'> [attacker] and [src] clash dramatically, causing sparks to fly! </span>", \
											"<span class='hear'> You hear hard plastic rubbing against hard plastic.</span>", COMBAT_MESSAGE_RANGE)
					else
						src_controller.visible_message("<span class='danger'> [src] and [attacker] clash dramatically, causing sparks to fly! </span>", \
										"<span class='danger'> [src] and [attacker] clash dramatically, causing sparks to fly! </span>", \
										"<span class='hear'> You hear hard plastic rubbing against hard plastic.</span>", COMBAT_MESSAGE_RANGE)
				if(5) //both win
					playsound(attacker, 'sound/weapons/parry.ogg', 20, TRUE)
					if(prob(50))
						attacker_controller.visible_message("<span class='danger'> [src]'s attack deflects off of [attacker]. </span>", \
											"<span class='danger'> [src]'s attack deflects off of [attacker]. </span>", \
											"<span class='hear'> You hear hard plastic bouncing off hard plastic.</span>", COMBAT_MESSAGE_RANGE)
					else
						src_controller.visible_message("<span class='danger'> [attacker]'s attack deflects off of [src]. </span>", \
										"<span class='danger'> [attacker]'s attack deflects off of [src]. </span>", \
										"<span class='hear'> You hear hard plastic bouncing off hard plastic.</span>", COMBAT_MESSAGE_RANGE)

				if(6 to 8) //defender wins
					if(special_attack_cooldown == 0 && combat_health <= round(max_combat_health/3)) //if health is less than 1/3 and special off CD, use it
						special_attack_charged = TRUE
						src_controller.visible_message("<span class='danger'> [src] begins charging its special attack!! </span>", \
										"<span class='danger'> You begin charging [src]'s special attack! </span>")
					else //just attack
						SpinAnimation(5, 0)
						playsound(src, 'sound/mecha/mechstep.ogg', 30, TRUE)
						attacker.combat_health--
						src_controller.visible_message("<span class='danger'> [src] smashes [attacker]! </span>", \
										"<span class='danger'> You smash [src] into [attacker]! </span>", \
										"<span class='hear'> You hear hard plastic smashing hard plastic.</span>", COMBAT_MESSAGE_RANGE)
						if(prob(5))
							attacker.combat_health--
							playsound(attacker, 'sound/effects/meteorimpact.ogg', 20, TRUE)
							src_controller.visible_message("<span class='boldwarning'> ...and lands a CRIPPLING BLOW! </span>", \
											"<span class='boldwarning'> ...and you land a CRIPPLING blow on [attacker]! </span>", null, COMBAT_MESSAGE_RANGE)
				else
					attacker_controller.visible_message("<span class='notice'> [src] and [attacker] stand around awkwardly.</span>", \
										"<span class='notice'> You don't know what to do next.</span>")

		battle_length++
		sleep(0.5 SECONDS)

	/// Lines chosen for the winning mech
	var/list/winlines = list("YOU'RE NOTHING BUT SCRAP!", "I'LL YIELD TO NONE!", "GLORY IS MINE!", "AN EASY FIGHT.", "YOU SHOULD HAVE NEVER FACED ME.", "ROCKED AND SOCKED.")

	if(attacker.combat_health <= 0 && combat_health <= 0) //both lose
		playsound(src, 'sound/machines/warning-buzzer.ogg', 20, TRUE)
		attacker_controller.visible_message("<span class='boldnotice'> MUTUALLY ASSURED DESTRUCTION!! [src] and [attacker] both end up destroyed!</span>", \
							"<span class='boldnotice'> Both [src] and [attacker] are destroyed!</span>")
	else if(attacker.combat_health <= 0) //src wins
		wins++
		attacker.losses++
		playsound(attacker, 'sound/effects/light_flicker.ogg', 20, TRUE)
		attacker_controller.visible_message("<span class='notice'> [attacker] falls apart!</span>", \
							"<span class='notice'> [attacker] falls apart!</span>", null, COMBAT_MESSAGE_RANGE)
		say("[pick(winlines)]")
		src_controller.visible_message("<span class='notice'> [src] destroys [attacker] and walks away victorious!</span>", \
						"<span class='notice'> You raise up [src] victoriously over [attacker]!</span>")
	else if (combat_health <= 0) //attacker wins
		attacker.wins++
		losses++
		playsound(src, 'sound/effects/light_flicker.ogg', 20, TRUE)
		src_controller.visible_message("<span class='notice'> [src] collapses!</span>", \
						"<span class='notice'> [src] collapses!</span>", null, COMBAT_MESSAGE_RANGE)
		attacker.say("[pick(winlines)]")
		attacker_controller.visible_message("<span class='notice'> [attacker] demolishes [src] and walks away victorious!</span>", \
							"<span class='notice'> You raise up [attacker] proudly over [src]</span>!")
	else //both win?
		say("NEXT TIME.")
		//don't want to make this a one sided conversation
		quiet? attacker.say("I WENT EASY ON YOU.") : attacker.say("OF COURSE.")

	in_combat = FALSE
	attacker.in_combat = FALSE

	combat_health = max_combat_health
	attacker.combat_health = attacker.max_combat_health

	return

/**
 * This proc checks if a battle can be initiated between src and attacker.
 *
 * Both SRC and attacker (if attacker is included) timers are checked if they're on cooldown, and
 * both SRC and attacker (if attacker is included) are checked if they are in combat already.
 * If any of the above are true, the proc returns FALSE and sends a message to user (and target, if included) otherwise, it returns TRUE
 * Arguments:
 * * user: the user who is initiating the battle
 * * attacker: optional arg for checking two mechs at once
 * * target: optional arg used in Mech PvP battles (if used, attacker is target's toy)
 */
/obj/item/toy/prize/proc/check_battle_start(mob/living/carbon/user, obj/item/toy/prize/attacker, mob/living/carbon/target)
	if(attacker?.in_combat)
		to_chat(user, "<span class='notice'>[target?target.p_their() : "Your" ] [attacker.name] is in combat.</span>")
		target?.to_chat(target, "<span class='notice'>Your [attacker.name] is in combat.</span>")
		return FALSE
	if(in_combat)
		to_chat(user, "<span class='notice'>Your [name] is in combat.</span>")
		target?.to_chat(target, "<span class='notice'>[target.p_their()] [name] is in combat.</span>")
		return FALSE
	if(attacker && attacker.timer > world.time)
		to_chat(user, "<span class='notice'>[target?target.p_their() : "Your" ] [attacker.name] isn't ready for battle.</span>")
		target?.to_chat(target, "<span class='notice'>Your [attacker.name] isn't ready for battle.</span>")
		return FALSE
	if(timer > world.time)
		to_chat(user, "<span class='notice'>Your [name] isn't ready for battle.</span>")
		target?.to_chat(target, "<span class='notice'>[target.p_their()] [name] isn't ready for battle.</span>")
		return FALSE

	return TRUE

/**
 * Processes any special attack moves that happen in the battle (called in the mechaBattle proc).
 *
 * Makes the toy shout their special attack cry and updates its cooldown. Then, does the special attack.
 * Arguments:
 * * victim - the toy being hit by the special move
 */
/obj/item/toy/prize/proc/special_attack_move(obj/item/toy/prize/victim)
	say(special_attack_cry + "!!")

	special_attack_charged = FALSE
	special_attack_cooldown = 3

	switch(special_attack_type)
		if(SPECIAL_ATTACK_DAMAGE) //+2 damage
			victim.combat_health-=2
			playsound(src, 'sound/weapons/marauder.ogg', 20, TRUE)
		if(SPECIAL_ATTACK_HEAL) //+2 healing
			combat_health+=2
			playsound(src, 'sound/mecha/mech_shield_raise.ogg', 20, TRUE)
		if(SPECIAL_ATTACK_UTILITY) //+1 heal, +1 damage
			victim.combat_health--
			combat_health++
			playsound(src, 'sound/mecha/mechmove01.ogg', 30, TRUE)
		if(SPECIAL_ATTACK_OTHER) //other
			super_special_attack(victim)
		else
			say("I FORGOT MY SPECIAL ATTACK...")

/**
 * Base proc for 'other' special attack moves.
 *
 * This one is only for inheritance, each mech with an 'other' type move has their procs below.
 * Arguments:
 * * victim - the toy being hit by the super special move (doesn't necessarily need to be used)
 */
/obj/item/toy/prize/proc/super_special_attack(obj/item/toy/prize/victim)
	visible_message("<span class='notice'> [src] does a cool flip.</span>")

/obj/item/toy/prize/ripley
	name = "toy Ripley"
	desc = "1/13"
	max_combat_health = 4 //200 integrity
	special_attack_type = SPECIAL_ATTACK_DAMAGE
	special_attack_cry = "GIGA DRILL BREAK"

/obj/item/toy/prize/fireripley //rip
	name = "toy Firefighting Ripley"
	desc = "2/13"
	icon_state = "fireripleytoy"
	max_combat_health = 5 //250 integrity?
	special_attack_type = SPECIAL_ATTACK_UTILITY
	special_attack_cry = "FIRE SHIELD"

/obj/item/toy/prize/deathripley
	name = "toy Deathsquad Ripley"
	desc = "3/13"
	icon_state = "deathripleytoy"
	max_combat_health = 5 //250 integrity
	special_attack_type = SPECIAL_ATTACK_OTHER
	special_attack_type_message = "instantly destroys the opposing mech if its health is less than this mech's health."
	special_attack_cry = "KILLER CLAMP"

/obj/item/toy/prize/deathripley/super_special_attack(obj/item/toy/prize/victim)
	playsound(src, 'sound/weapons/sonic_jackhammer.ogg', 20, TRUE)
	if(victim.combat_health < combat_health) //Instantly kills the other mech if it's health is below our's.
		say("EXECUTE!!")
		victim.combat_health = 0
	else //Otherwise, just deal one damage.
		victim.combat_health--

/obj/item/toy/prize/gygax
	name = "toy Gygax"
	desc = "4/13"
	icon_state = "gygaxtoy"
	max_combat_health = 5 //250 integrity
	special_attack_type = SPECIAL_ATTACK_UTILITY
	special_attack_cry = "SUPER SERVOS"

/obj/item/toy/prize/durand
	name = "toy Durand"
	desc = "5/13"
	icon_state = "durandtoy"
	max_combat_health = 6 //400 integrity
	special_attack_type = SPECIAL_ATTACK_HEAL
	special_attack_cry = "SHIELD OF PROTECTION"

/obj/item/toy/prize/honk
	name = "toy H.O.N.K."
	desc = "6/13"
	icon_state = "honktoy"
	max_combat_health = 4 //140 integrity
	special_attack_type = SPECIAL_ATTACK_OTHER
	special_attack_type_message = "puts the opposing mech's special move on cooldown and heals this mech."
	special_attack_cry = "MEGA HORN"

/obj/item/toy/prize/honk/super_special_attack(obj/item/toy/prize/victim)
	playsound(src, 'sound/machines/honkbot_evil_laugh.ogg', 20, TRUE)
	victim.special_attack_cooldown += 3 //Adds cooldown to the other mech and gives a minor self heal
	combat_health++

/obj/item/toy/prize/marauder
	name = "toy Marauder"
	desc = "7/13"
	icon_state = "maraudertoy"
	max_combat_health = 7 //500 integrity
	special_attack_type = SPECIAL_ATTACK_DAMAGE
	special_attack_cry = "BEAM BLAST"

/obj/item/toy/prize/seraph
	name = "toy Seraph"
	desc = "8/13"
	icon_state = "seraphtoy"
	max_combat_health = 8 //550 integrity
	special_attack_type = SPECIAL_ATTACK_DAMAGE
	special_attack_cry = "ROCKET BARRAGE"

/obj/item/toy/prize/mauler
	name = "toy Mauler"
	desc = "9/13"
	icon_state = "maulertoy"
	max_combat_health = 7 //500 integrity
	special_attack_type = SPECIAL_ATTACK_DAMAGE
	special_attack_cry = "BULLET STORM"

/obj/item/toy/prize/odysseus
	name = "toy Odysseus"
	desc = "10/13"
	icon_state = "odysseustoy"
	max_combat_health = 4 //120 integrity
	special_attack_type = SPECIAL_ATTACK_HEAL
	special_attack_cry = "MECHA BEAM"

/obj/item/toy/prize/phazon
	name = "toy Phazon"
	desc = "11/13"
	icon_state = "phazontoy"
	max_combat_health = 6 //200 integrity
	special_attack_type = SPECIAL_ATTACK_UTILITY
	special_attack_cry = "NO-CLIP"

/obj/item/toy/prize/reticence
	name = "toy Reticence"
	desc = "12/13"
	icon_state = "reticencetoy"
	quiet = TRUE
	max_combat_health = 4 //100 integrity
	special_attack_type = SPECIAL_ATTACK_OTHER
	special_attack_type_message = "has a lower cooldown than normal special moves, increases the opponent's cooldown, and deals damage."
	special_attack_cry = "*wave"

/obj/item/toy/prize/reticence/super_special_attack(obj/item/toy/prize/victim)
	special_attack_cooldown-- //Has a lower cooldown...
	victim.special_attack_cooldown++ //and increases the opponent's cooldown by 1...
	victim.combat_health-- //and some free damage.

/obj/item/toy/prize/clarke
	name = "toy Clarke"
	desc = "13/13"
	icon_state = "clarketoy"
	max_combat_health = 4 //200 integrity
	special_attack_type = SPECIAL_ATTACK_UTILITY
	special_attack_cry = "ROLL OUT"

#undef SPECIAL_ATTACK_HEAL
#undef SPECIAL_ATTACK_DAMAGE
#undef SPECIAL_ATTACK_UTILITY
#undef SPECIAL_ATTACK_OTHER
#undef MAX_BATTLE_LENGTH
