//might be a better place to put this, but it's fine here for now

#define MIN_CRAMP_TIME 600
#define MAX_CRAMP_TIME 3600
#define CRAMP_DAMAGE_MAX 10

/obj/item/clothing/suit/var/causes_cramps = 0
/obj/item/clothing/suit/var/interrupted_cramps = 0
/obj/item/clothing/suit/var/cramp_damage_caused = 0

/obj/item/clothing/suit/proc/cramp_up()
	if(!causes_cramps)
		return

	if(!interrupted_cramps)
		if(istype(src.loc, /mob/living/carbon/human) && !interrupted_cramps)
			var/mob/living/carbon/human/H = src.loc
			if(H.wear_suit == src)
				var/afforgan = pick("chest","l_foot","r_foot","l_arm","l_leg")
				var/datum/organ/external/affecting = H.get_organ(afforgan)
				if(affecting)
					if(prob(20) && cramp_damage_caused < CRAMP_DAMAGE_MAX)
						affecting.take_damage(3, 0, 0)
						cramp_damage_caused += 3
					H << "\red [pick("Your [affecting.display_name] goes to sleep.","Your [affecting.display_name] begins to twitch.","Your [affecting.display_name] begins to seize up.","You can feel cramps in your [affecting.display_name].","Your [affecting.display_name] begins to ache.","You can feel pins and needles in your [affecting.display_name].")]"

				spawn(rand(MIN_CRAMP_TIME, MAX_CRAMP_TIME))
					cramp_up()
			else
				interrupted_cramps = 1
		else
			interrupted_cramps = 1

	if(interrupted_cramps)
		cramp_damage_caused = 0

/obj/item/clothing/suit/bio_suit/causes_cramps = 1
/obj/item/clothing/suit/armor/riot/causes_cramps = 1
/obj/item/clothing/suit/fire/causes_cramps = 1
/obj/item/clothing/suit/bomb_suit/causes_cramps = 1
/obj/item/clothing/suit/radiation/causes_cramps = 1
/obj/item/clothing/suit/armor/captain/causes_cramps = 1
/obj/item/clothing/suit/space/causes_cramps = 1

//ergonomically designed space suits
/obj/item/clothing/suit/space/space_ninja/causes_cramps = 0
/obj/item/clothing/suit/space/pirate/causes_cramps = 0