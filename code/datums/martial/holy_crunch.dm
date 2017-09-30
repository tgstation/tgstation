#define WRIST_WRENCH_COMBO "DD"
#define BACK_KICK_COMBO "HG"
#define STOMACH_KNEE_COMBO "GH"
#define HEAD_KICK_COMBO "DHH"
#define ELBOW_DROP_COMBO "HDHDH"

/datum/martial_art/holy_crunch
	name = "Holy Crunch"
	deflection_chance = 5
	no_guns = TRUE
	allow_temp_override = FALSE

/datum/martial_art/chaplain_snap/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("power word: grail", "power word: justice", "power word: purge", "power word: judicator", "power word: banish")
	D.visible_message("<span class='danger'>[A] uses [atk_verb] on [D]!</span>", \
					  "<span class='userdanger'>[A] uses [atk_verb] on you!</span>")
	D.apply_damage(10, BRUTE)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, 1, -1)
	if(prob(D.getBruteLoss()) && !D.lying)
		D.visible_message("<span class='warning'>[A] sends [D] to the ground with holy energies!</span>", "<span class='userdanger'>An unseen force sends swipes you off your feet!</span>")
		D.Knockdown(80)
	add_logs(A, D, "[atk_verb] (Holy Crunch)")
	return 1

/obj/item/holy_crunch_scroll
	name = "holy deed"
	desc = "Orders from the powers above."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"

/obj/item/holy_crunch_scroll/attack_self(mob/living/carbon/human/user)
	if(!istype(user) || !user)
		return
	var/resolve = "<span class='danger'>You feel an immense pressure pushing on you at all sides!</span>"
	to_chat(user, resolve)
	user.Knockdown(80)
	//remind me to add a sleep or timer or whatever
	var/message = "<span class='sciradio'>You have overcome the holy crunch, and now may control it! You do not get any special moves, but your attacks now deal a considerable amount of damage. Deus Vult!</span>"
	to_chat(user, message)
	var/datum/martial_art/holy_crunch/holycrunch = new(null)
	holycrunch.teach(user)
	user.drop_item()
	visible_message("<span class='warning'>[src] lights up in fire and quickly burns to ash.</span>")
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)
