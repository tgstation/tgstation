/obj/item/camera/spooky
	name = "camera obscura"
	desc = "A polaroid camera, some say it can see ghosts!"
	see_ghosts = CAMERA_SEE_GHOSTS_BASIC

/obj/item/camera/spooky/steal_souls(list/victims)
	for(var/mob/living/target in victims)
		if(!(target.mob_biotypes & MOB_SPIRIT))
			continue

		// time to steal your soul
		if(istype(target, /mob/living/simple_animal/revenant))
			var/mob/living/simple_animal/revenant/peek_a_boo = target
			peek_a_boo.reveal(2 SECONDS) // no hiding
			if(!peek_a_boo.unstun_time)
				peek_a_boo.stun(2 SECONDS)
		target.visible_message(span_warning("[target] violently flinches!"), \
			span_revendanger("You feel your essence draining away from having your picture taken!"))
		target.apply_damage(rand(10, 15))

/obj/item/camera/spooky/badmin
	desc = "A polaroid camera, some say it can see ghosts! It seems to have an extra magnifier on the end."
	see_ghosts = CAMERA_SEE_GHOSTS_ORBIT

/obj/item/camera/detective
	name = "Detective's camera"
	desc = "A polaroid camera with extra capacity for crime investigations."
	pictures_max = 30
	pictures_left = 30
