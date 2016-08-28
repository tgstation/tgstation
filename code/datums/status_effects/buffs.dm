//Largely beneficial effects go here, even if they have drawbacks. An example is provided in Shadow Mend.

/datum/status_effect/shadow_mend
	name = "Shadow Mend"
	desc = "Shadowy energies wrap around your wounds, sealing them at a price. After healing, you will slowly lose health every three seconds for thirty seconds."
	id = "shadow_mend"
	icon_state = "shadow_mend"
	duration = 3

/datum/status_effect/shadow_mend/on_apply()
	owner.visible_message("<span class='notice'>Violet light wraps around [owner]'s body!</span>", "<span class='notice'>Violet light wraps around your body!</span>")
	playsound(owner, 'sound/magic/Teleport_app.ogg', 50, 1)

/datum/status_effect/shadow_mend/tick()
	owner.adjustBruteLoss(-15)
	owner.adjustFireLoss(-15)

/datum/status_effect/shadow_mend/on_remove()
	owner.visible_message("<span class='warning'>The violet light around [owner] glows black!</span>", "<span class='warning'>The tendrils around you cinch tightly and reap their toll...</span>")
	playsound(owner, 'sound/magic/Teleport_diss.ogg', 50, 1)
	owner.apply_status_effect(STATUS_EFFECT_VOID_PRICE)

/datum/status_effect/void_price
	name = "Void Price"
	desc = "Black tendrils cinch tightly against you, digging wicked barbs into your flesh."
	id = "void_price"
	icon_state = "shadow_mend"
	duration = 30
	tick_interval = 3

/datum/status_effect/void_price/tick()
	owner << sound('sound/magic/Summon_Karp.ogg', volume = 25)
	owner.adjustBruteLoss(3)



/datum/status_effect/inathneqs_endowment
	name = "Inath-neq's Endowment"
	desc = "Adrenaline courses through you as the Cogwheel's energy shields you from all harm!"
	id = "inathneqs_endowment"
	icon_state = "inathneqs_endowment"
	duration = 15

/datum/status_effect/inathneqs_endowment/on_apply()
	owner.visible_message("<span class='warning'>[owner] shines with azure light!</span>", "<span class='notice'>You feel Inath-neq's power flow through you! You're invincible!</span>")
	owner.color = "#1E8CE1"
	owner.fully_heal()
	owner.add_stun_absorption("inathneq", 150, 1, "'s flickering blue aura momentarily intensifies!", "Inath-neq's power absorbs the stun!", " is surrounded by blue light!")
	owner.status_flags |= GODMODE
	animate(owner, color = initial(owner.color), time = 150, easing = EASE_IN)
	playsound(owner, 'sound/magic/Ethereal_Enter.ogg', 50, 1)

/datum/status_effect/inathneqs_endowment/on_remove()
	owner.visible_message("<span class='warning'>The light around [owner] flickers and dissipates!</span>", "<span class='boldwarning'>Inath-neq's shield wavers and fails!</span>")
	owner.status_flags &= ~GODMODE
	playsound(owner, 'sound/magic/Ethereal_Exit.ogg', 50, 1)
