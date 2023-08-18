/obj/item/melee/greykingsword
	name = "blade of the grey-king"
	desc = "A legendary sword made with 3 replica katanas nailed together and dipped in heavy narcotics."
	icon = 'voidcrew/icons/obj/items_and_weapons.dmi'
	icon_state = "grey_sword"
	//item_state = "swordoff"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	force = 15
	throwforce = 8
	w_class = WEIGHT_CLASS_NORMAL
	block_chance = 30
	//attack_verb = list("struck", "slashed", "mall-ninjad", "tided", "multi-shanked", "shredded")
	custom_materials = list(/datum/material/iron = 1420)
	sharpness = SHARP_EDGED

	var/prick_chance = 50
	var/prick_chems = list(
		/datum/reagent/toxin = 10,
		/datum/reagent/toxin/mindbreaker = 10,
		/datum/reagent/drug/space_drugs = 10,
		/datum/reagent/drug/methamphetamine = 5,
		/datum/reagent/drug/bath_salts = 5,
		/datum/reagent/drug/aranesp = 5,
		/datum/reagent/drug/pumpup = 10,
		/datum/reagent/medicine/omnizine = 10,
		/datum/reagent/medicine/earthsblood = 15,
		/datum/reagent/medicine/omnizine/protozine = 15
	)

/obj/item/melee/greykingsword/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if (iscarbon(target) && prob(prick_chance))
		var/mob/living/carbon/C = target
		var/datum/reagent/R = pick(prick_chems)
		C.reagents.add_reagent(R, prick_chems[R])
		C.visible_message("<span class='danger'>[user] is pricked!</span>", \
								"<span class='userdanger'>You've been pricked by the [src]!</span>")
		log_combat(user, C, "pricked", src.name, "with [prick_chems[R]]u of [R]")
	return ..()


/obj/item/melee/greykingsword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 1 //Still not like your Japaniese animes though.
	return ..()

/obj/item/melee/greykingsword/suicide_act(mob/user)
	if (istype(user, /mob/living/carbon/human/))
		var/mob/living/carbon/human/H = user
		H.say("Master forgive me, but I will have to go all out... Just this once")
	user.visible_message("<span class='suicide'>[user] is cutting [user.p_them()]self on [user.p_their()] own edge!")
	return (BRUTELOSS) //appropriate

/obj/item/kitchen/knife/letter_opener
	name = "letter opener"
	icon = 'voidcrew/icons/obj/items_and_weapons.dmi'
	icon_state = "letter_opener"
	desc = "A military combat utility survival knife."
	embedding = list("pain_mult" = 4, "embed_chance" = 65, "fall_chance" = 10, "ignore_throwspeed_threshold" = TRUE)
	force = 15
	throwforce = 15
	unique_reskin = list("Traditional" = "letter_opener",
						"Boxcutter" = "letter_opener_b",
						"Corporate" = "letter_opener_a"
						)
