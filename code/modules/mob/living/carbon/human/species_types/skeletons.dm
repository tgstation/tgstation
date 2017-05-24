/datum/species/skeleton
	// 2spooky
	name = "Spooky Scary Skeleton"
	id = "skeleton"
	say_mod = "rattles"
	blacklisted = 1
	sexes = 0
	armor = list("melee" = -30, "bullet" = -30, "laser" = -15, "energy" = 10, "bomb" = -30, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 0)
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton
	species_traits = list(NOBREATH,RESISTHOT,RESISTCOLD,RESISTPRESSURE,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE,NOHUNGER,EASYDISMEMBER,EASYLIMBATTACHMENT)
	mutant_organs = list(/obj/item/organ/tongue/bone)
	damage_overlay_type = ""//let's not show bloody wounds or burns over bones.

/datum/species/skeleton/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H))
		if(prob(25) && (P.flag == "bullet" || P.flag == "laser"))
			playsound(H, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, 1)
			H.visible_message("<span class='danger'>The [P.name] passes between [H]'s bones, missing [H.p_them()]!</span>", \
			"<span class='userdanger'>The [P.name] passes between [H]'s bones, missing [H.p_them()]!</span>")
			return 2
	return 0

/datum/species/skeleton/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "milk") //strong bones and calcium
		armor = list("melee" = 10, "bullet" = 10, "laser" = 0, "energy" = 10, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 0)
	..()

/datum/species/skeleton/delete_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "milk")
		armor = list("melee" = -40, "bullet" = -40, "laser" = -20, "energy" = 10, "bomb" = -40, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 0)
