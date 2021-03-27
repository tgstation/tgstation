#define NEMESIS_MAX_CHARGE		 	20
#define NEMESIS_CHARGE_PER_MINE		 3
#define NEMESIS_CHARGE_PER_JUMP		 2
#define NEMESIS_CHARGE_PER_KNOCKDOWN 2
#define NEMESIS_CHARGE_PER_PARALYZE  6

#define NEMESIS_KNOCKDOWN_LENGTH 	 2 SECONDS
#define NEMESIS_PARALYZIS_LENGTH	 5 SECONDS

/datum/martial_art/nemesis //Funny, but there are no actuall kicks in this bootleg martial art
	name = "Nemesis Kick"
	id = MARTIALART_NEMESIS
	block_chance = 15 //Lets give them a small block chance, Nemesis Solutions equipment is also based around defencive moves

/datum/martial_art/nemesis/can_use(mob/living/owner)
	if (!ishuman(owner))
		return FALSE
	return ..()

/datum/martial_art/nemesis/harm_act(mob/living/carbon/human/A, mob/living/D)
	var/obj/item/clothing/gloves/rapid/nemesis/gloves = A.get_item_by_slot(ITEM_SLOT_GLOVES)
	if(!gloves || !istype(gloves))
		return FALSE //If something goes wrong, just skip the whole thing
	var/datum/species/species = A.dna.species

	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)

	var/atk_verb = pick("left hook","right hook","straight punch")

	var/damage = rand(5, 10) + species.punchdamagelow //Nice stamina damage, especially considering the fact that we have 25% punch cooldown
	if(!damage)
		playsound(D.loc, species.miss_sound, 25, TRUE, -1)
		D.visible_message("<span class='warning'>[A]'s [atk_verb] misses [D]!</span>", \
						"<span class='danger'>You avoid [A]'s [atk_verb]!</span>", "<span class='hear'>You hear a swoosh!</span>", COMBAT_MESSAGE_RANGE, A)
		to_chat(A, "<span class='warning'>Your [atk_verb] misses [D]!</span>")
		log_combat(A, D, "attempted to hit", atk_verb)
		return FALSE


	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, MELEE)

	playsound(D.loc, species.attack_sound, 25, TRUE, -1)

	D.visible_message("<span class='danger'>[A] [atk_verb]ed [D]!</span>", \
					"<span class='userdanger'>You're [atk_verb]ed by [A]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, A)
	to_chat(A, "<span class='danger'>You [atk_verb]ed [D]!</span>")

	D.apply_damage(damage, STAMINA, affecting, armor_block)
	log_combat(A, D, "punched (nemesis kick) ")
	if(A != D)
		gloves.gain_charge()
	return TRUE

/datum/martial_art/nemesis/disarm_act(mob/living/carbon/human/A, mob/living/D)
	var/obj/item/clothing/gloves/rapid/nemesis/gloves = A.get_item_by_slot(ITEM_SLOT_GLOVES)
	if(!gloves || !istype(gloves))
		return FALSE

	if(gloves.charge < NEMESIS_CHARGE_PER_KNOCKDOWN) //Common shoves if you don't have the charge
		return FALSE

	if(gloves.charge >= NEMESIS_CHARGE_PER_PARALYZE && D.body_position == LYING_DOWN) //Knockdown first and only then paralyzis.
		D.visible_message("<span class='danger'>[A] finishes [D] with an overcharged glove, knocking [D.p_them()] out!</span>", \
						"<span class='userdanger'>You're punched with an overcharged glove by [A]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", null, A)
		to_chat(A, "<span class='danger'>You overcharge your gloves and punch [D] with all of your might, finishing them!</span>")
		playsound(get_turf(A), 'sound/weapons/egloves.ogg', 50, TRUE, -1)
		D.Paralyze(NEMESIS_PARALYZIS_LENGTH)
		gloves.lose_charge(NEMESIS_PARALYZIS_LENGTH)
		return TRUE

	D.visible_message("<span class='danger'>[A] punches [D] with [gloves], knocking them down!</span>", \
						"<span class='userdanger'>You're punched with [gloves] by [A]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", null, A)
	to_chat(A, "<span class='danger'>You punch [D] using [gloves], knocking them down!</span>")
	playsound(get_turf(A), 'sound/weapons/egloves.ogg', 50, TRUE, -1)
	D.Knockdown(NEMESIS_KNOCKDOWN_LENGTH)
	D.Jitter(NEMESIS_KNOCKDOWN_LENGTH)
	gloves.lose_charge(NEMESIS_CHARGE_PER_KNOCKDOWN)
	return TRUE