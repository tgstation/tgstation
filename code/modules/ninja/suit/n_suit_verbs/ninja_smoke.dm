

//Smoke bomb
/obj/item/clothing/suit/space/space_ninja/proc/ninjasmoke()
	set name = "Smoke Bomb"
	set desc = "Blind your enemies momentarily with a well-placed smoke bomb."
	set category = "Ninja Ability"
	set popup_menu = 0//Will not see it when right clicking.

	if(!ninjacost(0,N_SMOKE_BOMB))
		var/mob/living/carbon/human/H = affecting
		var/datum/effect/effect/system/bad_smoke_spread/smoke = new /datum/effect/effect/system/bad_smoke_spread()
		smoke.set_up(10, 0, H.loc)
		smoke.start()
		playsound(H.loc, 'sound/effects/bamf.ogg', 50, 2)
		s_bombs--
		H << "<span class='notice'>There are <B>[s_bombs]</B> smoke bombs remaining.</span>"
		s_coold = 1
	return