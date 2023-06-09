/obj/projectile/neurotoxin
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 5
	damage_type = TOX
	paralyze = 10 SECONDS
	armor_flag = BIO
	impact_effect_type = /obj/effect/temp_visual/impact_effect/neurotoxin

/obj/projectile/neurotoxin/on_hit(atom/target, blocked = FALSE)
	if(isalien(target))
		paralyze = 0 SECONDS
		damage = 0
	if(ishuman(target)) //monkestation edit
		var/mob/living/carbon/human/h_mob = target //monkestation edit
		if(h_mob.can_inject()) //monkestation edit
			h_mob.stamina.adjust(-40) //monkestation edit
	return ..()


/obj/projectile/neurotoxin/damaging //for ai controlled aliums
	damage = 30
	paralyze = 0 SECONDS
