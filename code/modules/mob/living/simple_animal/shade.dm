/mob/living/simple_animal/shade
	name = "Shade"
	real_name = "Shade"
	desc = "A bound spirit"
	icon = 'icons/mob/mob.dmi'
	icon_state = "shade"
	icon_living = "shade"
	maxHealth = 50
	health = 50
	healable = 0
	speak_emote = list("hisses")
	emote_hear = list("wails.","screeches.")
	response_help  = "puts their hand through"
	response_disarm = "flails at"
	response_harm   = "punches"
	speak_chance = 1
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "drains the life from"
	minbodytemp = 0
	maxbodytemp = 4000
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	speed = -1
	stop_automated_movement = 1
	status_flags = 0
	faction = list("cult")
	status_flags = CANPUSH
	flying = 1


/mob/living/simple_animal/shade/death()
	..(1)
	new /obj/item/weapon/ectoplasm (src.loc)
	visible_message("<span class='warning'>[src] lets out a contented sigh as their form unwinds.</span>")
	ghostize()
	qdel(src)
	return


/mob/living/simple_animal/shade/attackby(obj/item/O, mob/user, params)  //Marker -Agouri
	if(istype(O, /obj/item/device/soulstone))
		var/obj/item/device/soulstone/SS = O
		SS.transfer_soul("SHADE", src, user)
	else
		..()
	return
