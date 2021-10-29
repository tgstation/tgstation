/datum/martial_art/cqc/plus
	name = "CQC+"
	id = MARTIALART_CQC_PLUS
	block_chance = 85

/datum/martial_art/cqc/plus/on_projectile_hit(mob/living/A, obj/projectile/P, def_zone)
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

/obj/item/book/granter/martial/cqc/plus
	martial = /datum/martial_art/cqc/plus
	name = "old but gold manual"
	martialname = "close quarters combat plus"
	desc = "A small, black manual. There are drawn instructions of tactical hand-to-hand combat. This includes how to deflect projectiles too."
	greet = "<span class='boldannounce'>You've mastered the basics of CQC+.</span>"
