#define TG_SPEED 1.5
#define RP_SPEED CONFIG_GET(number/movedelay/run_delay)

/datum/component/riding/Initialize(mob/living/riding_mob, force, buckle_mob_flags, potion_boost)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return
	if(vehicle_move_delay == 0)
		vehicle_move_delay = round(max(RP_SPEED - TG_SPEED, 0) * TG_SPEED, 0.01)
		return
	vehicle_move_delay = round(RP_SPEED / TG_SPEED * vehicle_move_delay, 0.01)

#undef TG_SPEED
#undef RP_SPEED
