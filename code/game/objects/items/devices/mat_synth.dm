#define MAX_MATSYNTH_MATTER 60
#define MAT_SYNTH_ROBO 100

#define MAT_COST_COMMON		1
#define MAT_COST_MEDIUM		5
#define MAT_COST_RARE		15

/obj/item/device/material_synth
	name = "material synthesizer"
	desc = "A device capable of producing very little material with a great deal of investment. Use wisely."
	icon = 'icons/obj/device.dmi'
	icon_state = "mat_synthoff"

	flags = FPRINT | TABLEPASS | CONDUCT
	w_class = 3.0
	origin_tech = "engineering=4;materials=5;power=3"

	var/mode = 0	//0 is material selection, 1 is material production
	var/emagged = 0

	var/obj/item/stack/sheet/active_material = /obj/item/stack/sheet/metal
	var/list/materials_scanned = list(	"metal" = /obj/item/stack/sheet/metal,
										"glass" = /obj/item/stack/sheet/glass,
										"reinforced glass" = /obj/item/stack/sheet/rglass,
										"plasteel" = /obj/item/stack/sheet/plasteel)
	var/matter = 0

/obj/item/device/material_synth/update_icon()
	icon_state = "mat_synth[mode ? "on" : "off"]"

/obj/item/device/material_synth/afterattack(var/obj/target, mob/user)
	//message_admins("This fired with [target.type]")
	if(istype(target, /obj/item/stack/sheet))
		//message_admins("Yes it is")
		for(var/matID in materials_scanned)
			if(materials_scanned[matID] == target.type)
				//message_admins("WE'RE GETTING KICKED OUT")
				user <<"<span class='rose'>You've already scanned \the [target].</span>"
				return
		materials_scanned["[initial(target.name)]"] = target.type
		user <<"<span class='notice'>You successfully scan \the [target] into \the [src]'s material banks.</span>"
		return 1
	return ..()

/obj/item/device/material_synth/attackby(var/obj/O, mob/user)
	if(istype(O, /obj/item/weapon/rcd_ammo))
		var/obj/item/weapon/rcd_ammo/RA = O
		if(matter + 10 > MAX_MATSYNTH_MATTER)
			user <<"\The [src] can't take any more material right now."
			return
		else
			matter += 10
			qdel(RA)
	if(istype(O, /obj/item/weapon/card/emag))
		if(!emagged)
			emagged = 1
			var/matter_rng = rand(5, 25)
			if(matter >= matter_rng)
				var/obj/item/device/spawn_item = pick(typesof(/obj/item/device) - /obj/item/device) //we make any kind of device. It's a surprise!
				user.visible_message("<span class='rose'>\The [src] in [user]'s hands appears to be trying to synthesize... \a [initial(spawn_item.name)]?</span>",
									 "You hear a loud popping noise.")
				user <<"<span class='warning'>\The [src] pops and fizzles in your hands, before creating... \a [initial(spawn_item.name)]?</span>"
				sleep(10)
				new spawn_item(get_turf(src))
				matter -= matter_rng
				return 1
			else
				user<<"<span class='danger'>The lack of matter in \the [src] shorts out the device!</span>"
				explosion(src.loc, 0,0,1,2) //traitors - fuck them, am I right?
				qdel(src)
		else
			user<<"You don't think you can do that again..."
			return
	return ..()

/obj/item/device/material_synth/attack_self(mob/user)
	switch(mode)
		if(0)
			if(materials_scanned.len)
				var/selection = materials_scanned[input("Select the material you'd like to synthesize", "Change Material Type") in materials_scanned]
				if(selection)
					active_material = selection
					user << "<span class='notice'>You switch \the [src] to synthesize [initial(active_material.name)]</span>"
		if(1)
			var/mat_name = initial(active_material.name)
			if(isrobot(user))
				var/mob/living/silicon/robot/r_user = user
				if(active_material && r_user.cell.charge)
					var/modifier = MAT_COST_COMMON
					if(initial(active_material.perunit) < 3750)
						modifier = MAT_COST_MEDIUM
					if(initial(active_material.perunit) < 2000)
						modifier = MAT_COST_RARE
					var/tospawn = max(0, round(input("How many sheets of [mat_name] do you want to synthesize?") as num))
					if(tospawn)
						if(TakeCost(tospawn, modifier, r_user))
							var/obj/item/stack/sheet/spawned_sheet = new active_material(get_turf(src))
							spawned_sheet.amount = tospawn
						else
							r_user <<"<span class='warning'>You can't make that much [mat_name] without shutting down!</span>"
							return
				else if(r_user.cell.charge)
					user <<"You must select a sheet type first!"
					return
			else
				if(active_material && matter)
					var/modifier = MAT_COST_COMMON
					if(initial(active_material.perunit) < 3750) //synthesizing is EXPENSIVE
						modifier = MAT_COST_MEDIUM
					if(initial(active_material.perunit) < 2000)
						modifier = MAT_COST_RARE
					var/tospawn = Clamp(round(input("How many sheets of [mat_name] do you want to synthesize? (0 - [matter / modifier])") as num), 0, round(matter / modifier))
					if(tospawn)
						var/obj/item/stack/sheet/spawned_sheet = new active_material(get_turf(src))
						spawned_sheet.amount = tospawn
						TakeCost(tospawn, modifier, user)
				else if(matter)
					user <<"You must select a sheet type first!"
					return
				else
					user <<"\The [src] is empty!"

/obj/item/device/material_synth/proc/TakeCost(var/spawned, var/modifier, mob/user)
	if(spawned)
		matter -= round(spawned * modifier)

/obj/item/device/material_synth/verb/togglemode()
	set category = "Object"
	set name = "Toggle Mode"
	mode = !mode
	usr <<"<span class='notice'>You successfully toggle \the [src]'s state to [mode ? "synthesis" : "scanning"].</span>"
	update_icon()
	return 1

/obj/item/device/material_synth/cyborg/TakeCost(var/spawned, var/modifier, mob/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		return R.cell.use(spawned*modifier*MAT_SYNTH_ROBO)
	return