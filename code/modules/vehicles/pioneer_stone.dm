/obj/vehicle/ridden/pioneer_stone
	name = "pioneer stone"
	desc = "Pioneer's used to ride these babies for miles"
	icon_state = "pioneer_stone"
	max_integrity = 500
	armor = list("melee" = 75, "bullet" = 0, "laser" = 25, "energy" = 25, "bomb" = -75, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100) //it is a fucking stone, what do you expect
	are_legs_exposed = TRUE
	var/max_damage_force = 25
	fall_off_if_missing_arms = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/vehicle/ridden/pioneer_stone/Initialize()
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))
	D.vehicle_move_delay = 2

/obj/vehicle/ridden/pioneer_stone/Moved()
	. = ..()
	playsound(src, 'sound/effects/clang.ogg', 25, TRUE)

/obj/vehicle/ridden/pioneer_stone/Bump(atom/movable/A)
	. = ..()
	if(A.density && has_buckled_mobs())
		var/atom/throw_target = get_edge_target_turf(A, dir)
		if(ishuman(A))
			var/mob/living/carbon/human/H = A

			var/damage_force = rand(10,max_damage_force)
			H.apply_damage(damage_force, BRUTE)
			if(damage_force == max_damage_force)
				H.Paralyze(100)
				H.adjustStaminaLoss(60)
				H.throw_at(throw_target, 3, 2)
				visible_message("<span class='danger'>[src] slams with full force into [H]!</span>")
				playsound(src, 'sound/effects/bang.ogg', 100, TRUE)
			else
				H.Paralyze(50)
				H.adjustStaminaLoss(30)
				H.throw_at(throw_target, 2, 1)
				visible_message("<span class='danger'>[src] slams into [H]!</span>")
				playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
