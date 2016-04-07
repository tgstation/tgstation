/obj/mecha/proc/get_armour_facing(srcdir,adir)
	var/facing_hit = armour_facings["[srcdir]"]["[adir]"]
	var/damage_modifier = facing_modifiers[facing_hit]
	return damage_modifier

/obj/mecha/proc/take_damage(amount, type="brute", adir = 0, booster_deflection_modifier = 1, booster_damage_modifier = 1)
	var/facing_modifier = 1

	if(adir)
		facing_modifier = get_armour_facing(src.dir,adir)

	if(prob(deflect_chance * booster_deflection_modifier * facing_modifier))
		visible_message("<span class='danger'>[src]'s armour deflects the attack!</span>")
		src.log_append_to_last("Armor saved.")
		return
	if(amount)
		var/damage = absorbDamage(amount,type)
		damage = (damage/facing_modifier) * booster_damage_modifier
		health -= damage
		update_health()
		occupant_message("<span class='userdanger'>Taking damage!</span>")
		log_append_to_last("Took [damage] points of damage. Damage type: \"[type]\".",1)

/obj/mecha/proc/absorbDamage(damage,damage_type)
	var/coeff = 1
	if(damage_absorption[damage_type])
		coeff = damage_absorption[damage_type]
	return damage*coeff


/obj/mecha/proc/update_health()
	if(src.health > 0)
		src.spark_system.start()
	else
		qdel(src)

/obj/mecha/attack_hulk(mob/living/carbon/human/user)
	..(user, 1)
	take_damage(15, "brute", user.dir)
	check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
	user.visible_message("<span class='danger'>[user] hits [src.name]. The metal creaks and bends.</span>")

/obj/mecha/attack_hand(mob/living/user as mob)
	user.changeNext_move(CLICK_CD_MELEE) // Ugh. Ideally we shouldn't be setting cooldowns outside of click code.
	user.do_attack_animation(src)
	src.log_message("Attack by hand/paw. Attacker - [user].",1)
	user.visible_message("<span class='danger'>[user] hits [src.name]. Nothing happens</span>","<span class='danger'>You hit [src.name] with no visible effect.</span>")
	src.log_append_to_last("Armor saved.")
	return

/obj/mecha/attack_paw(mob/user as mob)
	return src.attack_hand(user)


/obj/mecha/attack_alien(mob/living/user as mob)
	src.log_message("Attack by alien. Attacker - [user].",1)
	user.changeNext_move(CLICK_CD_MELEE) //Now stompy alien killer mechs are actually scary to aliens!
	user.do_attack_animation(src)
	take_damage(15, "brute", user.dir)
	check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
	playsound(src.loc, 'sound/weapons/slash.ogg', 50, 1, -1)
	visible_message("<span class='danger'>The [user] slashes at [src.name]'s armor!</span>")

/obj/mecha/attack_animal(mob/living/simple_animal/user as mob)
	src.log_message("Attack by simple animal. Attacker - [user].",1)
	user.changeNext_move(CLICK_CD_MELEE)
	if(user.melee_damage_upper == 0)
		user.emote("[user.friendly] [src]")
	else
		user.do_attack_animation(src)
		var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
		take_damage(damage, "brute", user.dir)
		check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
		visible_message("<span class='danger'>[user] [user.attacktext] [src]!</span>")
		add_logs(user, src, "attacked")

/obj/mecha/attack_tk()
	return

/obj/mecha/hitby(atom/movable/A as mob|obj) //wrapper
	log_message("Hit by [A].",1)
	var/deflection = 1
	var/dam_coeff = 1
	var/counter_tracking = 0
	for(var/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/B in equipment)
		if(B.projectile_react())
			deflection = B.deflect_coeff
			dam_coeff = B.damage_coeff
			counter_tracking = 1
			break
	if(istype(A, /obj/item/mecha_parts/mecha_tracking))
		if(!counter_tracking)
			A.forceMove(src)
			visible_message("The [A] fastens firmly to [src].")
			return
		else
			deflection = 100 //will bounce off

	if(istype(A, /obj))
		var/obj/O = A
		if(O.throwforce)
			visible_message("<span class='danger'>[src.name] is hit by [A].</span>")
			take_damage(O.throwforce, "brute", 0, deflection, dam_coeff)
			check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
	return


/obj/mecha/bullet_act(var/obj/item/projectile/Proj) //wrapper
	log_message("Hit by projectile. Type: [Proj.name]([Proj.flag]).",1)
	var/deflection = 1
	var/dam_coeff = 1
	for(var/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/B in equipment)
		if(B.projectile_react())
			deflection = B.deflect_coeff
			dam_coeff = B.damage_coeff
			break

	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		take_damage(Proj.damage*dam_coeff,Proj.flag, Proj.dir, deflection, dam_coeff)
		visible_message("<span class='danger'>[src.name] is hit by [Proj].</span>")
		check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT))
	Proj.on_hit(src)

/obj/mecha/ex_act(severity, target)
	src.log_message("Affected by explosion of severity: [severity].",1)
	if(prob(src.deflect_chance))
		severity++
		log_append_to_last("Armor saved, changing severity to [severity].")
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if (prob(30))
				qdel(src)
			else
				take_damage(initial(src.health)/2)
				check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
		if(3)
			if (prob(5))
				qdel(src)
			else
				take_damage(initial(src.health)/5)
				check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
	return

/obj/mecha/blob_act()
	take_damage(30, "brute")
	return

/obj/mecha/emp_act(severity)
	if(get_charge())
		use_power((cell.charge/3)/(severity*2))
		take_damage(30 / severity,"energy")
	src.log_message("EMP detected",1)
	check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
	return

/obj/mecha/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature>src.max_temperature)
		log_message("Exposed to dangerous temperature.",1)
		take_damage(5,"fire")
		check_for_internal_damage(list(MECHA_INT_FIRE, MECHA_INT_TEMP_CONTROL))
	return


/obj/mecha/attackby(obj/item/W as obj, mob/user as mob, params)

	if(istype(W, /obj/item/device/mmi))
		if(mmi_move_inside(W,user))
			user << "[src]-[W] interface initialized successfuly"
		else
			user << "[src]-[W] interface initialization failed."
		return

	if(istype(W, /obj/item/mecha_parts/mecha_equipment))
		var/obj/item/mecha_parts/mecha_equipment/E = W
		spawn()
			if(E.can_attach(src))
				if(!user.drop_item())
					return
				E.attach(src)
				user.visible_message("[user] attaches [W] to [src].", "<span class='notice'>You attach [W] to [src].</span>")
			else
				user << "<span class='warning'>You were unable to attach [W] to [src]!</span>"
		return
	if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(add_req_access || maint_access)
			if(internals_access_allowed(user))
				var/obj/item/weapon/card/id/id_card
				if(istype(W, /obj/item/weapon/card/id))
					id_card = W
				else
					var/obj/item/device/pda/pda = W
					id_card = pda.id
				output_maintenance_dialog(id_card, user)
				return
			else
				user << "<span class='warning'>Invalid ID: Access denied.</span>"
		else
			user << "<span class='warning'>Maintenance protocols disabled by operator.</span>"
	else if(istype(W, /obj/item/weapon/wrench))
		if(state==1)
			state = 2
			user << "<span class='notice'>You undo the securing bolts.</span>"
		else if(state==2)
			state = 1
			user << "<span class='notice'>You tighten the securing bolts.</span>"
		return
	else if(istype(W, /obj/item/weapon/crowbar))
		if(state==2)
			state = 3
			user << "<span class='notice'>You open the hatch to the power unit.</span>"
		else if(state==3)
			state=2
			user << "<span class='notice'>You close the hatch to the power unit.</span>"
		return
	else if(istype(W, /obj/item/stack/cable_coil))
		if(state == 3 && (internal_damage & MECHA_INT_SHORT_CIRCUIT))
			var/obj/item/stack/cable_coil/CC = W
			if(CC.use(2))
				clearInternalDamage(MECHA_INT_SHORT_CIRCUIT)
				user << "<span class='notice'>You replace the fused wires.</span>"
			else
				user << "<span class='warning'>You need two lengths of cable to fix this mech!</span>"
		return
	else if(istype(W, /obj/item/weapon/screwdriver))
		if(internal_damage & MECHA_INT_TEMP_CONTROL)
			clearInternalDamage(MECHA_INT_TEMP_CONTROL)
			user << "<span class='notice'>You repair the damaged temperature controller.</span>"
		else if(state==3 && src.cell)
			src.cell.forceMove(src.loc)
			src.cell = null
			state = 4
			user << "<span class='notice'>You unscrew and pry out the powercell.</span>"
			src.log_message("Powercell removed")
		else if(state==4 && src.cell)
			state=3
			user << "<span class='notice'>You screw the cell in place.</span>"
		return

	else if(istype(W, /obj/item/weapon/stock_parts/cell))
		if(state==4)
			if(!src.cell)
				if(!user.drop_item())
					return
				var/obj/item/weapon/stock_parts/cell/C = W
				user << "<span class='notice'>You install the powercell.</span>"
				C.forceMove(src)
				C.use(C.charge * 0.8)
				src.cell = C
				src.log_message("Powercell installed")
			else
				user << "<span class='notice'>There's already a powercell installed.</span>"
		return

	else if(istype(W, /obj/item/weapon/weldingtool) && user.a_intent != "harm")
		user.changeNext_move(CLICK_CD_MELEE)
		var/obj/item/weapon/weldingtool/WT = W
		if(src.health<initial(src.health))
			if (WT.remove_fuel(0,user))
				if (internal_damage & MECHA_INT_TANK_BREACH)
					clearInternalDamage(MECHA_INT_TANK_BREACH)
					user << "<span class='notice'>You repair the damaged gas tank.</span>"
				else
					user.visible_message("<span class='notice'>[user] repairs some damage to [src.name].</span>")
					src.health += min(10, initial(src.health)-src.health)
			else
				user << "<span class='warning'>The welder must be on for this task!</span>"
				return 1
		else
			user << "<span class='warning'>The [src.name] is at full integrity!</span>"
		return 1

	else if(istype(W, /obj/item/mecha_parts/mecha_tracking))
		if(!user.unEquip(W))
			user << "<span class='warning'>\the [W] is stuck to your hand, you cannot put it in \the [src]!</span>"
			return
		W.forceMove(src)
		user.visible_message("[user] attaches [W] to [src].", "<span class='notice'>You attach [W] to [src].</span>")
		return

	else if(!(W.flags&NOBLUDGEON))
		user.changeNext_move(CLICK_CD_MELEE) // Ugh. Ideally we shouldn't be setting cooldowns outside of click code.
		user.do_attack_animation(src)
		log_message("Attacked by [W]. Attacker - [user]")
		var/deflection = 1
		var/dam_coeff = 1
		for(var/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/B in equipment)
			if(B.attack_react(user))
				deflection *= B.deflect_coeff
				dam_coeff *= B.damage_coeff
				break
		user.visible_message("<span class='danger'>[user] hits [src] with [W].</span>", "<span class='danger'>You hit [src] with [W].</span>")
		take_damage(round(W.force*dam_coeff),W.damtype, user.dir, deflection, dam_coeff)
		check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
		return 1


/obj/mecha/proc/mech_toxin_damage(mob/living/target)
	playsound(src, 'sound/effects/spray2.ogg', 50, 1)
	if(target.reagents)
		if(target.reagents.get_reagent_amount("cryptobiolin") + force < force*2)
			target.reagents.add_reagent("cryptobiolin", force/2)
		if(target.reagents.get_reagent_amount("toxin") + force < force*2)
			target.reagents.add_reagent("toxin", force/2.5)


/atom/proc/mech_melee_attack(obj/mecha/M)
	return

/obj/mecha/mech_melee_attack(obj/mecha/M)
	if(M.damtype =="brute")
		playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
	else if(M.damtype == "fire")
		playsound(src, 'sound/items/Welder.ogg', 50, 1)
	else
		return
	visible_message("<span class='danger'>[M.name] has hit [src].</span>")
	take_damage(M.force, damtype, M.dir)
	add_logs(M.occupant, src, "attacked", M, "(INTENT: [uppertext(M.occupant.a_intent)]) (DAMTYPE: [uppertext(M.damtype)])")
	return