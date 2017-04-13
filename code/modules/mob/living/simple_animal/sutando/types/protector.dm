//protector ability
/datum/sutando_abilities/protector
	id = "protector"
	name = "Impenetrable Defense"
	value = 4

/datum/sutando_abilities/protector/handle_stats()
	. = ..()
	stand.has_mode = TRUE
	stand.melee_damage_lower = 7
	stand.melee_damage_upper = 7
	stand.range = 7 //worse for it due to how it leashes
	for(var/i in stand.damage_coeff)
		stand.damage_coeff[i] -= 0.3
	stand.toggle_button_type = /obj/screen/sutando/ToggleMode

/datum/sutando_abilities/protector/boom_act(severity)
	if(severity == 1)
		stand.adjustBruteLoss(400) //if in protector mode, will do 20 damage and not actually necessarily kill the user
	else
		. = stand.ex_act(severity)
	if(toggle)
		stand.visible_message("<span class='danger'>The explosion glances off [stand]'s energy shielding!</span>")

/datum/sutando_abilities/protector/adjusthealth_act(amount, updating_health = TRUE, forced = FALSE)
	. = stand.adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(. > 0 && toggle)
		var/image/I = new('icons/effects/effects.dmi', stand, "shield-flash", MOB_LAYER+0.01, dir = pick(GLOB.cardinal))
		if(stand.namedatum)
			I.color = stand.namedatum.colour
		flick_overlay_view(I, stand, 5)

/datum/sutando_abilities/protector/handle_mode()
	if(cooldown > world.time)
		return FALSE
	cooldown = world.time + 10
	if(toggle)
		stand.cut_overlays()
		stand.melee_damage_lower = initial(stand.melee_damage_lower)
		stand.melee_damage_upper = initial(stand.melee_damage_upper)
		stand.speed = initial(stand.speed)
		stand.damage_coeff = initial_coeff
		to_chat(stand,"<span class='danger'><B>You switch to combat mode.</span></B>")
		toggle = FALSE
	else
		var/image/I = new('icons/effects/effects.dmi', "shield-grey")
		if(stand.namedatum)
			I.color = stand.namedatum.colour
		stand.add_overlay(I)
		stand.melee_damage_lower = 2
		stand.melee_damage_upper = 2
		stand.speed = 1
		stand.damage_coeff = list(BRUTE = 0.05, BURN = 0.05, TOX = 0.05, CLONE = 0.05, STAMINA = 0, OXY = 0.05) //damage? what's damage?
		to_chat(stand,"<span class='danger'><B>You switch to protection mode.</span></B>")
		toggle = TRUE

/datum/sutando_abilities/protector/snapback_act() //snap to what? snap to the stand!
	if(user)
		if(get_dist(get_turf(user),get_turf(stand)) <= stand.range)
			return
		else
			if(istype(user.loc, /obj/effect))
				to_chat(stand,"<span class='holoparasite'>You moved out of range, and were pulled back! You can only move [stand.range] meters from [user.real_name]!</span>")
				stand.visible_message("<span class='danger'>\The [stand] jumps back to its user.</span>")
				stand.Recall(TRUE)
			else
				to_chat(user,"<span class='holoparasite'>You moved out of range, and were pulled back! You can only move [stand.range] meters from <font color=\"[stand.namedatum.colour]\"><b>[stand.real_name]</b></font>!</span>")
				user.visible_message("<span class='danger'>\The [user] jumps back to [user.p_their()] protector.</span>")
				new /obj/effect/overlay/temp/sutando/phase/out(get_turf(user))
				user.forceMove(get_turf(stand))
				new /obj/effect/overlay/temp/sutando/phase(get_turf(user))
