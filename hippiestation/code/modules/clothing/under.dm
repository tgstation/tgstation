/obj/item/clothing/under/hippie/cluwne
	name = "clown suit"
	desc = "<i>'HONK!'</i>"
	alternate_screams = list('hippiestation/sound/voice/cluwnelaugh1.ogg','hippiestation/sound/voice/cluwnelaugh2.ogg','hippiestation/sound/voice/cluwnelaugh3.ogg')
	icon_state = "cluwne"
	item_state = "cluwne"
	item_color = "cluwne"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_1 = NODROP_1 | DROPDEL_1
	can_adjust = 0

/obj/item/clothing/under/hippie/cluwne/equipped(mob/living/carbon/user, slot)
	if(!ishuman(user))
		return
	if(slot == slot_w_uniform)
		var/mob/living/carbon/human/H = user
		H.dna.add_mutation(CLUWNEMUT)
	return ..()

/obj/item/clothing/under/hippie/cosby
	name = "sweater"
	desc = "Zip zap zoobity bap"
	icon_state = "cosby"
	item_state = "r_suit" //bleh
	item_color = "cosby"
	can_adjust = 0
	force = 0.001 	//TG doesn't have the forcehitsound that Hippie has at the moment, so this is just a hacky solution until or unless we figure something out -DerptheStewpidGoat
	alternate_screams = list('hippiestation/sound/voice/cosby1.ogg','hippiestation/sound/voice/cosby2.ogg','hippiestation/sound/voice/cosby3.ogg','hippiestation/sound/voice/cosby4.ogg','hippiestation/sound/voice/cosby5.ogg')
