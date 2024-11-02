#define TG_SPEED 1.5
#define RP_SPEED CONFIG_GET(number/movedelay/run_delay)

/proc/modified_move_delay(move_delay)
	if(move_delay == 0)
		return round(max(RP_SPEED - TG_SPEED, 0) * TG_SPEED, 0.01)
	return round(RP_SPEED / TG_SPEED * move_delay, 0.01)

#undef TG_SPEED
#undef RP_SPEED
