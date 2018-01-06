/obj/machinery/reagent_material_manipulator
	name = "material manipulation machine"
	desc = "A high tech machine that can both analyse material traits and combine material traits with each other."
	icon_state = "circuit_imprinter"
	icon = 'icons/obj/machines/research.dmi'
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	var/obj/item/loaded
	var/analyse_only = FALSE
	var/datum/reagent/synthesis
	var/datum/reagent/reagent_analyse
	var/list/special_traits
	var/is_bullet = FALSE//because bullets are the snowflakes


/obj/machinery/reagent_material_manipulator/Initialize()
	. =..()
	create_reagents(100)


/obj/machinery/reagent_material_manipulator/attackby(obj/item/I, mob/user)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(panel_open)
		to_chat(user, "<span class='warning'>You can't load the [I] while it's opened!</span>")
		return

	var/obj/item/forged/R//since all forged weapons have the same vars/procs this lets it compile as the actual type is assigned at runtime during this proc
	special_traits = list()

	if(istype(I, /obj/item/reagent_containers/glass/beaker))
		var/obj/item/reagent_containers/glass/beaker/W = I
		if(LAZYLEN(W.reagents.reagent_list) == 1)
			for(var/X in W.reagents.reagent_list)
				var/datum/reagent/S = X

				if(synthesis && S.id != synthesis.id)
					to_chat(user, "<span class='warning'>[src] already has a reagent of a different type, remove it before adding something else!</span>")
					return

				if(W.reagents.total_volume && reagents.total_volume < reagents.maximum_volume)
					to_chat(user, "You add [S] to the machine!")
					W.reagents.trans_to(src, W.reagents.total_volume)
					for(var/RS in reagents.reagent_list)
						synthesis = RS
					return
		else
			to_chat(user, "<span class='warning'>[src] only accepts one type of reagent at a time!</span>")
			return


	else if(istype(I, /obj/item/stack/sheet/mineral/reagent))
		R = I
		analyse_only = TRUE

	else if(istype(I, /obj/item/forged))
		R = I

	else if(istype(I, /obj/item/twohanded/forged))
		R = I

	else if(istype(I, /obj/item/ammo_casing/forged))
		R = I
		var/obj/item/ammo_casing/forged/F = I
		if(!F.BB)//this has no bullet
			return

		if(!F.caliber)
			to_chat(user, "<span class='warning'>[I] needs to be shaped to a caliber before it can be added!</span>")
			return

		var/obj/item/projectile/bullet/forged/FB = F.BB
		special_traits = FB.special_traits
		is_bullet = TRUE

	if(loaded)
		to_chat(user, "<span class='warning'>[src] is full!</span>")
		return

	if(R && R.reagent_type)//we move it out of their hands and store it as a 'ghost' object
		user.dropItemToGround(R)
		R.forceMove(get_turf(src))
		R.invisibility = INVISIBILITY_ABSTRACT
		R.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		R.anchored = TRUE
		loaded = R
		reagent_analyse = R.reagent_type
		if(analyse_only)//used by ingots and other non weapons without their own seperate list of instantiated traits
			for(var/D in reagent_analyse.special_traits)
				var/datum/special_trait/S = new D
				LAZYADD(special_traits, S)
		else if(!is_bullet)
			special_traits = R.special_traits

	else
		..()


/obj/machinery/reagent_material_manipulator/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "chem_reagent_analysis", name, 600, 600, master_ui, state)
		ui.open()


/obj/machinery/reagent_material_manipulator/ui_data(mob/user)
	var/list/data = list()
	var/list/listoftraits = list()
	var/list/listoftraitsadd = list()

	if(reagents.total_volume <= 0 && synthesis)
		synthesis = null

	if(loaded && special_traits && reagent_analyse)
		for(var/I in special_traits)
			var/datum/special_trait/D = I
			var/md5name = md5(D.name)
			if(!listoftraits[md5name])
				listoftraits[md5name] = list("name" = D.name, "desc" = D.desc, "effectiveness" = D.effectiveness)
		sortList(listoftraits)

	if(synthesis && synthesis.special_traits)
		for(var/D in synthesis.special_traits)
			var/datum/special_trait/S = new D
			var/md5name = md5(S.name)
			if(!listoftraitsadd[md5name])
				listoftraitsadd[md5name] = list("name" = S.name, "desc" = S.desc, "effectiveness" = S.effectiveness)
		sortList(listoftraitsadd)

	data["item"] = loaded ? loaded.name : "Nothing"
	data["reagent_analyse"] = reagent_analyse ? reagent_analyse : "Nothing"
	data["density"] = reagent_analyse ? reagent_analyse.density : "N/A"
	data["traits"] = listoftraits ? listoftraits : "Nothing"
	data["traitsadd"] = listoftraitsadd ? listoftraitsadd : "Nothing"
	data["volume"] = synthesis ? reagents.total_volume : 0
	data["reagent_synthesis"] = synthesis ? synthesis : "Nothing"
	return data


/obj/machinery/reagent_material_manipulator/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("Eject")
			if(loaded)
				loaded.forceMove(get_turf(usr))
				loaded.invisibility = initial(loaded.invisibility)
				loaded.mouse_opacity = initial(loaded.mouse_opacity)
				loaded.anchored = initial(loaded.anchored)
				to_chat(usr, "<span class='notice'>You eject [loaded]</span>")
				loaded = null
				reagent_analyse = null
				special_traits = null
				analyse_only = FALSE
				is_bullet = FALSE
				return TRUE
		if("Empty")
			if(synthesis)
				synthesis.reagent_state = SOLID
				synthesis.handle_state_change(get_turf(src), synthesis.volume, src)
				to_chat(usr, "<span class='notice'>[synthesis] is flash frozen and dispensed out of the machine in the form of a solid bar!</span>")
				synthesis = null
				reagents.clear_reagents()
				return TRUE

		if("Add_Trait")
			if(loaded && synthesis && reagent_analyse)
				if(reagents.total_volume < 50)
					to_chat(usr, "<span class='warning'>You need at least [SPECIAL_TRAIT_ADD_COST] units of [synthesis] to add a trait!</span>")
					return FALSE

				if(analyse_only)
					to_chat(usr, "<span class='warning'>The machine is locked in analyse only mode, perhaps you are trying to modify the traits of a reagent directly?</span>")
					return FALSE

				if(LAZYLEN(special_traits) >= SPECIAL_TRAIT_MAXIMUM)
					to_chat(usr, "<span class='warning'>[loaded] has too many special traits already!</span>")
					return FALSE

				var/obj/item/forged/R
				if(istype(loaded, /obj/item/forged))
					R = loaded

				else if(istype(loaded, /obj/item/twohanded/forged))
					R = loaded

				else if(istype(loaded, /obj/item/ammo_casing/forged))
					var/obj/item/ammo_casing/forged/F = loaded
					if(!F.BB)//this has no bullet
						return FALSE
					R = F.BB

				if(!R)
					return FALSE
				for(var/I in synthesis.special_traits)
					var/datum/special_trait/D = new I
					if(D.name == params["name"])
						if(locate(D) in R.special_traits)
							to_chat(usr, "<span class='warning'>[R] already has that trait!</span>")
							return FALSE
						else
							R.special_traits += D//doesn't work with lazyadd due to type mismatch (it checks for an explicitly initialized list)
							R.speed += SPECIAL_TRAIT_ADD_SPEED_DEBUFF
							D.on_apply(R, R.identifier)
							reagents.remove_any(SPECIAL_TRAIT_ADD_COST)
							to_chat(usr, "<span class='notice'>You add the trait [D] to [R]</span>")
							return TRUE

	return FALSE