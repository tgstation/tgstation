/obj/vehicle/ridden/pioneer_stone
	name = "pioneer stone"
	desc = "Pioneer's used to ride these babies for miles"
	icon_state = "pioneer_stone"
	max_integrity = 500
	armor = list("melee" = 100, "bullet" = -20, "laser" = 50, "energy" = 50, "bomb" = -100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100) //it is a fucking stone, what do you expect
	are_legs_exposed = TRUE
	fall_off_if_missing_arms = TRUE
	resistance_flags = FIRE_PROOF

/obj/vehicle/ridden/pioneer_stone/Initialize()
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))
	D.vehicle_move_delay = 2

/obj/vehicle/ridden/pioneer_stone/Moved()
	. = ..()
	playsound(src, 'sound/effects/clang.ogg', 50, TRUE)
	if(has_buckled_mobs())
		for(var/atom/A in range(0, src))
			if(!(A in buckled_mobs))
				Bump(A)

/obj/vehicle/ridden/pioneer_stone/Bump(atom/movable/A)
	. = ..()
	if(A.density && has_buckled_mobs())
		var/atom/throw_target = get_edge_target_turf(A, dir)
		if(ishuman(A))
			var/mob/living/carbon/human/H = A
			H.Paralyze(100)
			H.adjustStaminaLoss(30)
			H.apply_damage(rand(10,25), BRUTE)
			H.throw_at(throw_target, 2, 1)
			visible_message("<span class='danger'>[src] crashes into [H]!</span>")
			playsound(src, 'sound/effects/bang.ogg', 50, TRUE)