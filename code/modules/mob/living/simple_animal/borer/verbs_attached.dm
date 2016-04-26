
/obj/item/verbs/borer/attached/verb/borer_speak(var/message as text)
	set category = "Alien"
	set name = "Borer Speak"
	set desc = "Communicate with your bretheren"

	if(!message)
		return

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	message = capitalize(message)

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.borer_speak(message)

/* Disabled for now.
/obj/item/verbs/borer/attached/verb/bond_brain()
	set category = "Alien"
	set name = "Assume Control"
	set desc = "Fully connect to the brain of your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.bond_brain()

/obj/item/verbs/borer/attached/verb/kill_host()
	set category = "Alien"
	set name = "Kill Host"
	set desc = "Give the host massive brain damage, killing them nearly instantly."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.kill_host()

/obj/item/verbs/borer/attached/verb/damage_brain()
	set category = "Alien"
	set name = "Retard Host"
	set desc = "Give the host a bit of brain damage.  Can be healed with alkysine."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.damage_brain()
*/

/obj/item/verbs/borer/attached/verb/evolve()
	set category = "Alien"
	set name = "Evolve"
	set desc = "Upgrade yourself or your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.evolve()

/obj/item/verbs/borer/attached/verb/secrete_chemicals()
	set category = "Alien"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.secrete_chemicals()

/obj/item/verbs/borer/attached/verb/abandon_host()
	set category = "Alien"
	set name = "Abandon Host"
	set desc = "Slither out of your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.abandon_host()

/obj/item/verbs/borer/attached/verb/analyze_host()
	set category = "Alien"
	set name = "Analyze Health"
	set desc = "Check your host for damage."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.analyze_host()
