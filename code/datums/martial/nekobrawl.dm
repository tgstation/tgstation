//NekoBrawl is a superhero-only advanced version of CQC that allows you to deflect bullets.
/datum/martial_art/cqc/nekobrawl
	name = "NekoBrawl"
	id = MARTIALART_NEKOBRAWL

/datum/martial_art/cqc/nekobrawl/teach(mob/living/H, make_temporary = FALSE)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(H, TRAIT_NOGUNS, CLOTHING_TRAIT)
	ADD_TRAIT(H, TRAIT_HARDLY_WOUNDED, CLOTHING_TRAIT)
	ADD_TRAIT(H, TRAIT_NODISMEMBER, CLOTHING_TRAIT)

/datum/martial_art/cqc/nekobrawl/on_remove(mob/living/H)
	. = ..()
	REMOVE_TRAIT(H, TRAIT_NOGUNS, CLOTHING_TRAIT)
	REMOVE_TRAIT(H, TRAIT_HARDLY_WOUNDED, CLOTHING_TRAIT)
	REMOVE_TRAIT(H, TRAIT_NODISMEMBER, CLOTHING_TRAIT)

/datum/martial_art/cqc/nekobrawl/on_projectile_hit(mob/living/A, obj/projectile/P, def_zone)
	. = ..()
	if(A.incapacitated(FALSE, TRUE)) //NO STUN
		return BULLET_ACT_HIT
	if(!(A.mobility_flags & MOBILITY_USE)) //NO UNABLE TO USE
		return BULLET_ACT_HIT
	var/datum/dna/dna = A.has_dna()
	if(dna?.check_mutation(HULK)) //NO HULK
		return BULLET_ACT_HIT
	if(!isturf(A.loc)) //NO MOTHERFLIPPIN MECHS!
		return BULLET_ACT_HIT
	if(A.throw_mode)
		A.visible_message("<span class='danger'>[A] effortlessly swats the projectile aside! They can block bullets with their bare hands!</span>", "<span class='userdanger'>You deflect the projectile!</span>")
		playsound(get_turf(A), pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, TRUE)
		P.firer = A
		P.set_angle(rand(0, 360))//SHING
		return BULLET_ACT_FORCE_PIERCE
	return BULLET_ACT_HIT
