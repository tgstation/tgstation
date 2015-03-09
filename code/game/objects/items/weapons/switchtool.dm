/obj/item/weapon/switchtool
	name = "switchtool"
	icon = 'icons/obj/switchtool.dmi'
	icon_state = "switchtool"
	desc = "A multi-deployable, multi-instrument, finely crafted multi-purpose tool. The envy of engineers everywhere."
	flags = FPRINT
	siemens_coefficient = 1
	force = 3
	w_class = 2.0
	throwforce = 6.0
	throw_speed = 3
	throw_range = 6
	m_amt = 15000
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	origin_tech = "materials=9;bluespace=5"

	//the colon separates the typepath from the name
	var/list/obj/item/stored_modules = list("/obj/item/weapon/screwdriver:screwdriver" = null,
											"/obj/item/weapon/wrench:wrench" = null,
											"/obj/item/weapon/wirecutters:wirecutters" = null,
											"/obj/item/weapon/crowbar:crowbar" = null,
											"/obj/item/weapon/chisel:chisel" = null,
											"/obj/item/device/multitool:multitool" = null)
	var/obj/item/deployed //what's currently in use
	var/removing_item = /obj/item/weapon/screwdriver //the type of item that lets you take tools out

/obj/item/weapon/switchtool/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(istype(target, /obj/item/weapon/storage)) //we place automatically
		return
	if(deployed)
		target.attackby(deployed, user)
		deployed.afterattack(target, user, proximity_flag, click_parameters)
		if(deployed.loc != src)
			for(var/module in stored_modules)
				if(stored_modules[module] == deployed)
					stored_modules[module] = null
			undeploy()
		return 1

/obj/item/weapon/switchtool/New()
	..()
	for(var/module in stored_modules) //making the modules
		var/new_type = text2path(get_module_type(module))
		stored_modules[module] = new new_type(src)

/obj/item/weapon/switchtool/examine()
	..()
	usr << "This one is capable of holding [get_formatted_modules()]."

/obj/item/weapon/switchtool/attack_self(mob/user)
	if(!user)
		return

	if(deployed)
		user << "You store \the [deployed]."
		undeploy()
	else
		choose_deploy(user)

/obj/item/weapon/switchtool/attackby(var/obj/item/used_item, mob/user)
	if(istype(used_item, removing_item) && deployed) //if it's the thing that lets us remove tools and we have something to remove
		return remove_module(user)
	if(add_module(used_item, user))
		return 1
	else
		return ..()

/obj/item/weapon/switchtool/proc/get_module_type(var/module)
	return copytext(module, 1, findtext(module, ":"))

/obj/item/weapon/switchtool/proc/get_module_name(var/module)
	return copytext(module, findtext(module, ":") + 1)

//makes the string list of modules ie "a screwdriver, a knife, and a clown horn"
//does not end with a full stop, but does contain commas
/obj/item/weapon/switchtool/proc/get_formatted_modules()
	var/counter = 0
	var/module_string = ""
	for(var/module in stored_modules)
		counter++
		if(counter == stored_modules.len)
			module_string += "and \a [get_module_name(module)]"
		else
			module_string += "\a [get_module_name(module)], "
	return module_string

/obj/item/weapon/switchtool/proc/add_module(var/obj/item/used_item, mob/user)
	if(!used_item || !user)
		return

	for(var/module in stored_modules)
		var/type_path = text2path(get_module_type(module))
		if(istype(used_item, type_path))
			if(stored_modules[module])
				user << "\The [src] already has a [get_module_name(module)]."
				return
			else
				stored_modules[module] = used_item
				user.drop_item(src)
				user << "You successfully load \the [used_item] into \the [src]'s [get_module_name(module)] slot."
				return 1

/obj/item/weapon/switchtool/proc/remove_module(mob/user)
	deployed.loc = get_turf(user)
	for(var/module in stored_modules)
		if(stored_modules[module] == deployed)
			stored_modules[module] = null
			break
	user << "You successfully remove \the [deployed] from \the [src]."
	playsound(get_turf(src), "sound/items/screwdriver.ogg", 10, 1)
	undeploy()
	return 1

/obj/item/weapon/switchtool/proc/undeploy()
	playsound(get_turf(src), "sound/weapons/switchblade.ogg", 10, 1)
	deployed = null
	overlays.len = 0
	w_class = initial(w_class)

/obj/item/weapon/switchtool/proc/deploy(var/module)
	if(!(module in stored_modules))
		return

	if(!stored_modules[module])
		return

	playsound(get_turf(src), "sound/weapons/switchblade.ogg", 10, 1)
	deployed = stored_modules[module]
	overlays += get_module_name(module)
	w_class = max(w_class, deployed.w_class)

/obj/item/weapon/switchtool/proc/choose_deploy(mob/user)
	var/list/potential_modules = list()
	for(var/module in stored_modules)
		if(stored_modules[module])
			potential_modules += get_module_name(module)

	if(!potential_modules.len)
		user << "No modules to deploy."
		return

	else if(potential_modules.len == 1)
		deploy(potential_modules[1])
		user << "You deploy \the [potential_modules[1]]"
		return 1

	else
		var/chosen_module = input(user,"What do you want to deploy?", "[src]", "Cancel") as anything in potential_modules
		if(chosen_module != "Cancel")
			var/true_module = ""
			for(var/checkmodule in stored_modules)
				if(get_module_name(checkmodule) == chosen_module)
					true_module = checkmodule
					break
			deploy(true_module)
			user << "You deploy \the [deployed]."
			return 1
		return

/obj/item/weapon/switchtool/surgery
	name = "surgeon's switchtool"

	icon_state = "surg_switchtool"
	desc = "A switchtool containing most of the necessary items for impromptu surgery. For the surgeon on the go."

	w_class = 3.0
	origin_tech = "materials=9;bluespace=5;biotech=5"
	stored_modules = list("/obj/item/weapon/scalpel:scalpel" = null,
						"/obj/item/weapon/circular_saw:circular saw" = null,
						"/obj/item/weapon/surgicaldrill:surgical drill" = null,
						"/obj/item/weapon/cautery:cautery" = null,
						"/obj/item/weapon/hemostat:hemostat" = null,
						"/obj/item/weapon/retractor:retractor" = null,
						"/obj/item/weapon/bonesetter:bonesetter" = null)

/obj/item/weapon/switchtool/swiss_army_knife
	name = "swiss army knife"

	icon_state = "s_a_k"
	desc = "Crafted by the Space Swiss for everyday use in military campaigns. Nonpareil."

	stored_modules = list("/obj/item/weapon/screwdriver:screwdriver" = null,
						"/obj/item/weapon/wrench:wrench" = null,
						"/obj/item/weapon/wirecutters:wirecutters" = null,
						"/obj/item/weapon/crowbar:crowbar" = null,
						"/obj/item/weapon/kitchen/utensil/knife/large:knife" = null,
						"/obj/item/weapon/kitchen/utensil/fork:fork" = null,
						"/obj/item/weapon/hatchet:hatchet" = null,
						"/obj/item/weapon/lighter/zippo:zippo lighter" = null,
						"/obj/item/weapon/match/strike_anywhere:match" = null,
						"/obj/item/weapon/pen:pen" = null)

/obj/item/weapon/switchtool/swiss_army_knife/undeploy()
	if(istype(deployed, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/lighter = deployed
		lighter.lit = 0
	..()

/obj/item/weapon/switchtool/swiss_army_knife/deploy(var/module)
	..()
	if(istype(deployed, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/lighter = deployed
		lighter.lit = 1