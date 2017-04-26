//protector ability
/datum/guardian_abilities/protector
	id = "protector"
	name = "Impenetrable Defense"
	value = 4

/datum/guardian_abilities/protector/handle_stats()
	. = ..()
	guardian.has_mode = TRUE
	guardian.melee_damage_lower = 7
	guardian.melee_damage_upper = 7
	guardian.range = 7 //worse for it due to how it leashes
	for(var/i in guardian.damage_coeff)
		guardian.damage_coeff[i] -= 0.3
	guardian.toggle_button_type = /obj/screen/guardian/ToggleMode

/datum/guardian_abilities/protector/boom_act(severity)
	if(severity == 1)
		guardian.adjustBruteLoss(400) //if in protector mode, will do 20 damage and not actually necessarily kill the user
	else
		. = guardian.ex_act(severity)
	if(toggle)
		guardian.visible_message("<span class='danger'>The explosion glances off [guardian]'s energy shielding!</span>")

/datum/guardian_abilities/protector/adjusthealth_act(amount, updating_health = TRUE, forced = FALSE)
	. = guardian.adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(. > 0 && toggle)
		var/image/I = new('icons/effects/effects.dmi', guardian, "shield-flash", MOB_LAYER+0.01, dir = pick(GLOB.cardinal))
		if(guardian.namedatum)
			I.color = guardian.namedatum.colour
		flick_overlay_view(I, guardian, 5)

/datum/guardian_abilities/protector/handle_mode()
	if(cooldown > world.time)
		return FALSE
	cooldown = world.time + 10
	if(toggle)
		guardian.cut_overlays()
		guardian.melee_damage_lower = initial(guardian.melee_damage_lower)
		guardian.melee_damage_upper = initial(guardian.melee_damage_upper)
		guardian.speed = initial(guardian.speed)
		guardian.damage_coeff = initial_coeff
		to_chat(guardian,"<span class='danger'><B>You switch to combat mode.</span></B>")
		toggle = FALSE
	else
		var/mutable_appearance/shield_overlay = mutable_appearance('icons/effects/effects.dmi', "shield-grey")
		if(guardian.namedatum)
			shield_overlay.color = guardian.namedatum.colour
		guardian.add_overlay(shield_overlay)
		guardian.melee_damage_lower = 2
		guardian.melee_damage_upper = 2
		guardian.speed = 1
		guardian.damage_coeff = list(BRUTE = 0.05, BURN = 0.05, TOX = 0.05, CLONE = 0.05, STAMINA = 0, OXY = 0.05) //damage? what's damage?
		to_chat(guardian,"<span class='danger'><B>You switch to protection mode.</span></B>")
		toggle = TRUE

/datum/guardian_abilities/protector/snapback_act() //snap to what? snap to the guardian!
	if(user)
		if(get_dist(get_turf(user),get_turf(guardian)) <= guardian.range)
			return
		else
			if(istype(user.loc, /obj/effect))
				to_chat(guardian,"<span class='holoparasite'>You moved out of range, and were pulled back! You can only move [guardian.range] meters from [user.real_name]!</span>")
				guardian.visible_message("<span class='danger'>\The [guardian] jumps back to its user.</span>")
				guardian.Recall(TRUE)
			else
				to_chat(user,"<span class='holoparasite'>You moved out of range, and were pulled back! You can only move [guardian.range] meters from <font color=\"[guardian.namedatum.colour]\"><b>[guardian.real_name]</b></font>!</span>")
				user.visible_message("<span class='danger'>\The [user] jumps back to [user.p_their()] protector.</span>")
				new /obj/effect/overlay/temp/guardian/phase/out(get_turf(user))
				user.forceMove(get_turf(guardian))
				new /obj/effect/overlay/temp/guardian/phase(get_turf(user))
