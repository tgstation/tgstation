/datum/martial_art/holy_crunch
	name = "Holy Crunch"
	deflection_chance = 5
	no_guns = TRUE
	allow_temp_override = FALSE

/datum/martial_art/holy_crunch/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("power word: grail", "power word: justice", "power word: purge", "power word: judicator", "power word: banish")
	D.visible_message("<span class='danger'>[A] uses [atk_verb] on [D]!</span>", \
					  "<span class='userdanger'>[A] uses [atk_verb] on you!</span>")
	D.apply_damage(10, BRUTE)
	playsound(get_turf(D), 'sound/magic/clockwork/ratvar_attack.ogg', 25, 1, -1)
	if(prob(D.getBruteLoss()) && !D.lying)
		D.visible_message("<span class='warning'>[A] sends [D] to the ground with holy energies!</span>", "<span class='userdanger'>An unseen force sends swipes you off your feet!</span>")
		D.Knockdown(80)
	add_logs(A, D, "[atk_verb] (Holy Crunch)")
	return 1

/obj/item/holy_crunch_scroll
	name = "holy deed"
	desc = "Orders from the powers above."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll3"

/obj/item/holy_crunch_scroll/attack_self(mob/living/carbon/human/user)
	if(!istype(user) || !user)
		return
	var/resolve = "<span class='danger'>cA phantom force punches your gut!</b></span>"
	to_chat(user, resolve)
	user.Knockdown(80)
	var/message = "<span class='sciradio'>You have overcome the holy crunch, and now may control it! You do not get any special moves, but your attacks now deal a considerable amount of damage. <b>Deus Vult!</b></span>"
	to_chat(user, message)
	var/datum/martial_art/holy_crunch/holycrunch = new(null)
	holycrunch.teach(user)
	user.drop_item()
	visible_message("<span class='warning'>[src] lights up in fire and quickly burns to ash.</span>")
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)
