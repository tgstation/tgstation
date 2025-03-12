/proc/ui_hand_position(i) //values based on old hand ui positions (CENTER:-/+16,SOUTH:5)
	var/x_off = IS_LEFT_INDEX(i) ? 0 : -1
	var/y_off = round((i-1) / 2)
	return"CENTER+[x_off]:16,SOUTH+[y_off]:5"

/proc/ui_swaphand_position(mob/M, which = LEFT_HANDS) //values based on old swaphand ui positions (CENTER: +/-16,SOUTH+1:5)
	var/x_off = (which == LEFT_HANDS) ? -1 : null
	var/y_off = round((M.held_items.len-1) / 2)
	return "CENTER[x_off]:16,SOUTH+[y_off+1]:5"

/proc/ui_perk_position(perk_count)
	var/y_off = perk_count < 1 ? 0 : perk_count/2
	return "WEST+0.5:12,NORTH-2-[y_off]:20"
