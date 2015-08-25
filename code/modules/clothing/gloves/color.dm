/obj/item/clothing/gloves/yellow
	desc = "These gloves will protect the wearer from electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	_color="yellow"
	species_fit = list("Vox")

/obj/item/clothing/gloves/yellow/power //fuck you don't relative path this
	var/next_shock = 0

/obj/item/clothing/gloves/yellow/power/Touch(var/atom/A, mob/living/user, prox)
	if(prox == 0 && user.a_intent == I_HURT)
		var/time = 100
		var/turf/T = get_turf(user)
		var/turf/U = get_turf(A)
		var/obj/structure/cable/cable = locate() in T
		if(!cable || !istype(cable))
			return
		if(world.time < next_shock)
			user << "<span class='warning'>[src] aren't ready to shock again!</span>"
			return
		user.visible_message("<span class='warning'>[user.name] fires an arc of electricity!</span>", \
			"<span class='warning'>You fire an arc of electricity!</span>", \
			"You hear the loud crackle of electricity!")
		var/datum/powernet/PN = cable.get_powernet()
		var/obj/item/projectile/beam/lightning/L = getFromPool(/obj/item/projectile/beam/lightning, T)
		if(PN)
			L.damage = PN.get_electrocute_damage()
			if(L.damage >= 200)
				user.apply_damage(15, BURN, (user.hand ? "l_hand" : "r_hand"))
				time = 200
				user << "<span class='warning'>[src] overload\s from the massive current, shocking you in the process!"
			else if(L.damage >= 100)
				user.apply_damage(5, BURN, (user.hand ? "l_hand" : "r_hand"))
				time = 150
				user << "<span class='warning'>[src] overload\s from the massive current, shocking you in the process!"
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, user)
			s.start()
		if(L.damage <= 0)
			returnToPool(L)
			//del(L)
		if(L)
			playsound(get_turf(src), 'sound/effects/eleczap.ogg', 75, 1)
			L.tang = adjustAngle(get_angle(U,T))
			L.icon = midicon
			L.icon_state = "[L.tang]"
			L.firer = user
			L.def_zone = user.get_organ_target()
			L.original = A
			L.current = U
			L.starting = U
			L.yo = U.y - T.y
			L.xo = U.x - T.x
			spawn L.process()
		user.delayNextAttack(12)
		next_shock = world.time + time
		return 1
	return


/obj/item/clothing/gloves/fyellow                             //Cheap Chinese Crap
	desc = "These gloves are cheap copies of the coveted gloves, no way this can end badly."
	name = "budget insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 1			//Set to a default of 1, gets overridden in New()
	permeability_coefficient = 0.05
	species_fit = list("Vox")

	_color="yellow"

/obj/item/clothing/gloves/fyellow/New()
	. = ..()
	siemens_coefficient = pick(0,0.5,0.5,0.5,0.5,0.75,1.5)

/obj/item/clothing/gloves/black
	desc = "These gloves are fire-resistant."
	name = "black gloves"
	icon_state = "black"
	item_state = "bgloves"
	_color="black"
	species_fit = list("Vox")

	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE


/obj/item/clothing/gloves/black/hos
	_color = "hosred"			//Exists for washing machines. Is not different from black gloves in any way.

/obj/item/clothing/gloves/black/ce
	_color = "chief"			//Exists for washing machines. Is not different from black gloves in any way.

/obj/item/clothing/gloves/black/rd
	_color = "director"			//Exists for washing machines. Is not different from black gloves in any way.

/obj/item/clothing/gloves/black/hop
	_color = "hop"				//Exists for washing machines. Is not different from black gloves in any way.

/obj/item/clothing/gloves/black/thief
	pickpocket = 1


/obj/item/clothing/gloves/orange
	name = "orange gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "orange"
	item_state = "orangegloves"
	_color="orange"
	species_fit = list("Vox")

/obj/item/clothing/gloves/red
	name = "red gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "red"
	item_state = "redgloves"
	_color = "red"
	species_fit = list("Vox")

/obj/item/clothing/gloves/red/redcoat
	_color = "redcoat"		//Exists for washing machines. Is not different from red gloves in any way.

/obj/item/clothing/gloves/rainbow
	name = "rainbow gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "rainbow"
	item_state = "rainbowgloves"
	_color = "rainbow"
	species_fit = list("Vox")

/obj/item/clothing/gloves/rainbow/clown
	_color = "clown"

/obj/item/clothing/gloves/blue
	name = "blue gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "blue"
	item_state = "bluegloves"
	_color="blue"
	species_fit = list("Vox")

/obj/item/clothing/gloves/purple
	name = "purple gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "purple"
	item_state = "purplegloves"
	_color="purple"
	species_fit = list("Vox")

/obj/item/clothing/gloves/green
	name = "green gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "green"
	item_state = "greengloves"
	_color="green"
	species_fit = list("Vox")

/obj/item/clothing/gloves/grey
	name = "grey gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "gray"
	item_state = "graygloves"
	_color="grey"
	species_fit = list("Vox")

/obj/item/clothing/gloves/light_brown
	name = "light brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "lightbrown"
	item_state = "lightbrowngloves"
	_color="light brown"
	species_fit = list("Vox")

/obj/item/clothing/gloves/brown
	name = "brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "brown"
	item_state = "browngloves"
	_color="brown"
	species_fit = list("Vox")

/obj/item/clothing/gloves/brown/cargo
	_color = "cargo" 		//Exists for washing machines. Is not different from brown gloves in any way.
