/obj/item/clockwork/integration_cog
	name = "интеграционная шестерня"
	desc = "Маленькая шестеренка, которая, кажется, крутится сама по себе, когда ее оставляют в покое."
	icon_state = "integration_cog"
	clockwork_desc = "Острая шестерня, которой можно прорезать электрощиток и вставить в него её для извлечения питания из него."

/obj/item/clockwork/integration_cog/afterattack(atom/O, mob/living/user, proximity)
	if(!is_servant_of_ratvar(user))
		return
	if(!proximity)
		return
	if(!istype(O, /obj/machinery/power/apc))
		return
	var/obj/machinery/power/apc/A = O
	if(A.integration_cog)
		to_chat(user, span_brass("Здесь уже есть [src] в [A]."))
		return
	if(!A.panel_open)
		//Cut open the panel
		to_chat(user, span_notice("Начинаю разрезать [A]."))
		if(do_after(user, 50, target=A))
			to_chat(user, span_brass("Разрезаю [A] используя [src]."))
			A.set_panel_open(TRUE)
			A.update_icon()
			return
		return
	//Insert the cog
	to_chat(user, span_notice("Начинаю вставлять [src] в [A]."))
	if(do_after(user, 40, target=A))
		A.integration_cog = src
		forceMove(A)
		A.panel_open = FALSE
		A.update_icon()
		to_chat(user, span_notice("Вставляю [src] в [A]."))
		playsound(get_turf(user), 'sound/machines/clockcult/integration_cog_install.ogg', 20)
		if(!A.clock_cog_rewarded)
			GLOB.installed_integration_cogs ++
			A.clock_cog_rewarded = TRUE
			hierophant_message("<b>[user]</b> устанавливает шестерню в [A]", span="<span class='nzcrentr'>", use_sanitisation=FALSE)
			//Update the cog counts
			for(var/obj/item/clockwork/clockwork_slab/S in GLOB.clockwork_slabs)
				S.update_integration_cogs()
			if(GLOB.clockcult_eminence)
				var/mob/living/simple_animal/eminence/eminence = GLOB.clockcult_eminence
				eminence.cog_change()
