/obj/item/ammo_casing/caseless/arrow
	name = "arrow"
	desc = "Stabby Stabman!"
	icon = ''
	icon_state = ""
	flags_1 = NONE
	throwforce = 1			//Pokey poke!
	fire_sound = ''
	projectile_type = /obj/item/projectile/bullet/reusable/arrow
	firing_effect_type = null
	caliber = "arrow"
	heavy_metal = FALSE

	//Arrow stats
	var/arrow_draw_weight_min = 30		//Minimum draw. Any less than this and it will just fall down.
	var/arrow_draw_weight_max = 100		//Maximum draw. Full strength!
	var/damage_min = 10					//Damage at minimum draw.
	var/damage_max = 25					//Damage at maximum draw.
	var/speed_min = 1					//Speed at minimum draw.
	var/speed_max = 0.75				//Speed at maximum draw.

/obj/item/ammo_casing/caseless/arrow/proc/calculate_draw_percentage(arrow_draw_weight)
	var/draw_percentage = 0.80
	if(arrow_draw_weight < arrow_draw_weight_min)
		draw_percentage = 0.00
		return draw_percentage
	else if(arrow_draw_weight_min == arrow_draw_weight_max)		//No dividing by zero this time.
		draw_percentage = 1.00
		return draw_percentage
	draw_percentage = arrow_draw_weight / (arrow_draw_weight_max - arrow_draw_weight_min)
	return draw_percentage

/obj/item/ammo_casing/caseless/arrow/proc/ready_arrow(obj/item/projectile/bullet/reusable/arrow/A)
	if(!istype(A))
		return
	var/percent_scaling = calculate_draw_percentage()


/obj/item/ammo_casing/caseless/arrow/throw_proj(atom/target, turf/targloc, mob/living/user, params, spread)
	if(!BB)
		return ..()
	ready_arrow(BB)
	return ..()
