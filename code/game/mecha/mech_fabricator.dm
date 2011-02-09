/////////////////////////////
///// Part Fabricator ///////
/////////////////////////////


/obj/machinery/mecha_part_fabricator
	icon = 'mech_fab.dmi'
	icon_state = "fabricator"
	name = "Exosuit Fabricator"
	density = 1
	anchored = 1
	layer=2
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 5000
	var/list/resources = list(
										"metal"=20000,
										"glass"=20000,
										"gold"=0,
										"silver"=0,
										"diamond"=0,
										"plasma"=0
										)
	var/res_max_amount = 200000
	var/part_set
	var/obj/being_built
	var/list/part_sets = list( //set names must be unique
	"Ripley"=list(
						list("result"="/obj/mecha_chassis/ripley","time"=100,"metal"=20000),
						list("result"="/obj/item/mecha_parts/part/ripley_torso","time"=300,"metal"=40000,"glass"=15000),
						list("result"="/obj/item/mecha_parts/part/ripley_left_arm","time"=200,"metal"=25000),
						list("result"="/obj/item/mecha_parts/part/ripley_right_arm","time"=200,"metal"=25000),
						list("result"="/obj/item/mecha_parts/part/ripley_left_leg","time"=200,"metal"=30000),
						list("result"="/obj/item/mecha_parts/part/ripley_right_leg","time"=200,"metal"=30000)
						),
/*
	"Ripley-on-Fire"=list(
						list("result"="/obj/mecha_chassis/firefighter","time"=150,"metal"=20000),
						list("result"="/obj/item/mecha_parts/part/firefighter_torso","time"=300,"metal"=45000,"glass"=20000),
						list("result"="/obj/item/mecha_parts/part/firefighter_left_arm","time"=200,"metal"=25000),
						list("result"="/obj/item/mecha_parts/part/firefighter_right_arm","time"=200,"metal"=25000),
						list("result"="/obj/item/mecha_parts/part/firefighter_left_leg","time"=200,"metal"=30000),
						list("result"="/obj/item/mecha_parts/part/firefighter_right_leg","time"=200,"metal"=30000)
						),
*/

	"Gygax"=list(
						list("result"="/obj/mecha_chassis/gygax","time"=100,"metal"=25000),
						list("result"="/obj/item/mecha_parts/part/gygax_torso","time"=300,"metal"=50000,"glass"=20000),
						list("result"="/obj/item/mecha_parts/part/gygax_head","time"=200,"metal"=20000,"glass"=10000),
						list("result"="/obj/item/mecha_parts/part/gygax_left_arm","time"=200,"metal"=30000),
						list("result"="/obj/item/mecha_parts/part/gygax_right_arm","time"=200,"metal"=30000),
						list("result"="/obj/item/mecha_parts/part/gygax_left_leg","time"=200,"metal"=35000),
						list("result"="/obj/item/mecha_parts/part/gygax_right_leg","time"=200,"metal"=35000),
						list("result"="/obj/item/mecha_parts/part/gygax_armour","time"=600,"metal"=75000,"diamond"=10000)
						)
	)


	proc/add_part_set(set_name,parts=null)
		if(set_name in part_sets)//attempt to create duplicate set
			return 0
		if(isnull(parts))
			part_sets[set_name] = list()
		else
			part_sets[set_name] = parts
		return 1

	proc/add_part_to_set(set_name,part)
		src.add_part_set(set_name)//if no "set_name" set exists, create
		var/list/part_set = part_sets[set_name]
		part_set[++part_set.len] = part
		return

	proc/remove_part_set(set_name)
		for(var/i=1,i<=part_sets.len,i++)
			if(part_sets[i]==set_name)
				part_sets.Cut(i,++i)
		return

	proc/sanity_check()
		for(var/p in resources)
			var/index = resources.Find(p)
			index = resources.Find(p, index)
			if(index) //duplicate resource
				world << "Duplicate resource definition for [src](\ref[src])"
				return 0
		for(var/set_name in part_sets)
			var/index = part_sets.Find(set_name)
			index = part_sets.Find(set_name, index)
			if(index) //duplicate part set
				world << "Duplicate part set definition for [src](\ref[src])"
				return 0
		return 1
/*
	New()
		..()
		src.add_part_to_set("Test",list("result"="/obj/item/mecha_parts/part/gygax_armour","time"=600,"metal"=75000,"diamond"=10000))
		src.add_part_to_set("Test",list("result"="/obj/item/mecha_parts/part/ripley_left_arm","time"=200,"metal"=25000))
		src.remove_part_set("Gygax")
		return
*/

	proc/output_parts_list(set_name)
		var/output = ""
		if(set_name in part_sets)
			var/list/part_set = part_sets[set_name]
			for(var/part in part_set)
				var/resources_available = check_resources(part)
				output += "[resources_available?"<a href='?src=\ref[src];part=\ref[part]'>":"<span class='red'>"][output_part_info(part)][resources_available?"</a>":"</span>"]<br>"
		return output

	proc/output_part_info(part)
		var/path = part["result"]
		var/obj/O = new path(src)
		var/cost = "Cost: "
		var/i = 0
		for(var/p in part)
			if(p in resources)
				cost += "[i?" | ":null][part[p]] [p]"
				i++
		var/output = "[O.name] ([cost]) [part["time"]/10]sec"
		del O
		return output

	proc/output_available_resources()
		var/output
		for(var/resource in resources)
			output += "<span class=\"res_name\">[resource]: </span>[min(res_max_amount, resources[resource])] cm<sup>3</sup><br>"
		return output

	proc/remove_resources(part)
		for(var/p in part)
			if(p in resources)
				src.resources[p] -= part[p]
		return

	proc/check_resources(part)
		for(var/p in part)
			if(p in resources)
				if(src.resources[p] < part[p])
					return 0
		return 1

	attack_hand(mob/user as mob)
		var/dat
		if (..())
			return
		user.machine = src
		if (src.being_built)
			dat = {"<TT>Building [src.being_built.name].<BR>
						Please wait until completion...</TT><BR>
						<BR>
					"}
		else
			dat = output_available_resources()
			dat += "<hr>"
			if(!part_set)
				for(var/part_set in part_sets)
					dat += "<a href='?src=\ref[src];part_set=[part_set]'>[part_set]<BR>"
			else
				dat += output_parts_list(part_set)
				dat += "<hr><a href='?src=\ref[src];part_set=clear'>Return</a>"

		user << browse({"
<html>
<head>
<title>[src.name]</title>
<style>
.res_name {font-weight: bold; text-transform: capitalize;}
.red {color: #f00;}
</style>
</head>
<body>[dat]</body>
</html>
							"}, "window=mecha_fabricator")
		onclose(user, "mecha_fabricator")
		return


	Topic(href, href_list)
		..()
		if(href_list["part_set"])
			if(href_list["part_set"]=="clear")
				src.part_set = null
			else
				src.part_set = href_list["part_set"]
		if(href_list["part"])
			var/list/part = locate(href_list["part"])
			if(!part) return
			var/path = part["result"]
			var/time = part["time"]
			src.being_built = new path(src)
			src.remove_resources(part)
			src.icon_state = "fabricator_ani"
			src.use_power = 2
			spawn(time)
				src.use_power = 1
				src.being_built.Move(get_step(src,EAST))
				src.icon_state = initial(src.icon_state)
				src.visible_message("[src] beeps, \"The [src.being_built] is complete\".")
				src.being_built = null
				src.updateUsrDialog()
		src.updateUsrDialog()
		return

	process()
		if (stat & (NOPOWER|BROKEN))
			return

	attackby(obj/item/stack/sheet/W as obj, mob/user as mob)
		var/material
		var/amnt
		if(istype(W, /obj/item/stack/sheet/gold))
			material = "gold"
			amnt = "g_amt"
		else if(istype(W, /obj/item/stack/sheet/silver))
			material = "silver"
			amnt = "g_amt"
		else if(istype(W, /obj/item/stack/sheet/diamond))
			material = "diamond"
			amnt = "g_amt"
		else if(istype(W, /obj/item/stack/sheet/plasma))
			material = "plasma"
			amnt = "g_amt"
		else if(istype(W, /obj/item/stack/sheet/metal))
			material = "metal"
			amnt = "m_amt"
		else if(istype(W, /obj/item/stack/sheet/glass))
			material = "glass"
			amnt = "g_amt"
		else
			return ..()

		if(src.being_built)
			user << "The fabricator is currently processing. Please wait until completion."
			return

		var/name = "[W.name]"
		if(src.resources[material] < res_max_amount)
			var/count = 0
			spawn(10)
				if(W && W.amount)
					while(src.resources[material] < res_max_amount && W)
						src.resources[material] += W.vars[amnt]
						W.use(1)
						count++

					user << "You insert [count] [name] into the fabricator."
					src.updateUsrDialog()
		else
			user << "The fabricator cannot hold more [name]."
		return
