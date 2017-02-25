/obj/machinery/plantgenes
	name = "plant DNA manipulator"
	desc = "An advanced device designed to manipulate plant genetic makeup."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "dnamod"
	density = 1
	anchored = 1

	var/obj/item/seeds/seed
	var/obj/item/weapon/disk/plantgene/disk

	var/list/core_genes = list()
	var/list/reagent_genes = list()
	var/list/trait_genes = list()

	var/datum/plant_gene/target
	var/operation = ""
	var/rating = 0
	var/max_extract_pot = 50
	// The cap on potency gene extraction.
	// This number is for T1, each upgraded part adds 5% for a tech level above T1.
	// At T4, it reaches 95%.

/obj/machinery/plantgenes/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/plantgenes(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/plantgenes
	name = "Plant DNA Manipulator (Machine Board)"
	build_path = /obj/machinery/plantgenes
	origin_tech = "programming=3;biotech=3"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/weapon/stock_parts/scanning_module = 1)

/obj/machinery/plantgenes/RefreshParts()
	rating = 0
	for(var/I in component_parts)
		if(istype(I, /obj/item/weapon/stock_parts))
			var/obj/item/weapon/stock_parts/S = I
			rating += S.rating-1
		else if(istype(I, /obj/item/weapon/circuitboard/machine/plantgenes/vault))
			rating += 5 // Having original alien board is +25%
	max_extract_pot = initial(max_extract_pot) + rating*5

/obj/machinery/plantgenes/update_icon()
	..()
	cut_overlays()
	if((stat & (BROKEN|NOPOWER)))
		icon_state = "dnamod-off"
	else
		icon_state = "dnamod"
	if(seed)
		add_overlay("dnamod-dna")
	if(panel_open)
		add_overlay("dnamod-open")

/obj/machinery/plantgenes/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "dnamod", "dnamod", I))
		update_icon()
		return
	if(exchange_parts(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	if(iscyborg(user))
		return

	if(istype(I, /obj/item/seeds))
		if(seed)
			user << "<span class='warning'>A sample is already loaded into the machine!</span>"
		else
			if(!user.drop_item())
				return
			insert_seed(I)
			user << "<span class='notice'>You add [I] to the machine.</span>"
			interact(user)
		return
	else if(istype(I, /obj/item/weapon/disk/plantgene))
		if(disk)
			user << "<span class='warning'>A data disk is already loaded into the machine!</span>"
		else
			if(!user.drop_item())
				return
			disk = I
			disk.loc = src
			user << "<span class='notice'>You add [I] to the machine.</span>"
			interact(user)
	else
		..()


/obj/machinery/plantgenes/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/plantgenes/interact(mob/user)
	user.set_machine(src)
	if(!user)
		return

	var/datum/browser/popup = new(user, "plantdna", "Plant DNA Manipulator", 450, 600)
	if(!(in_range(src, user) || issilicon(user)))
		popup.close()
		return

	var/dat = ""

	if(operation)
		if(!seed || (!target && operation != "insert"))
			operation = ""
			target = null
			interact(user)
			return
		if((operation == "replace" || operation == "insert") && (!disk || !disk.gene))
			operation = ""
			target = null
			interact(user)
			return

		dat += "<div class='line'><h3>Confirm Operation</h3></div>"
		dat += "<div class='statusDisplay'>Are you sure you want to [operation] "
		switch(operation)
			if("remove")
				dat += "<span class='highlight'>[target.get_name()]</span> gene from \the <span class='highlight'>[seed]</span>?<br>"
			if("extract")
				dat += "<span class='highlight'>[target.get_name()]</span> gene from \the <span class='highlight'>[seed]</span>?<br>"
				dat += "<span class='bad'>The sample will be destroyed in process!</span>"
				if(istype(target, /datum/plant_gene/core/potency))
					var/datum/plant_gene/core/gene = target
					if(gene.value > max_extract_pot)
						dat += "<br><br>This device's extraction capabilities are currently limited to [max_extract_pot] potency. "
						dat += "Target gene will be degraded to [max_extract_pot] potency on extraction."
			if("replace")
				dat += "<span class='highlight'>[target.get_name()]</span> gene with <span class='highlight'>[disk.gene.get_name()]</span>?<br>"
			if("insert")
				dat += "<span class='highlight'>[disk.gene.get_name()]</span> gene into \the <span class='highlight'>[seed]</span>?<br>"
		dat += "</div><div class='line'><a href='?src=\ref[src];gene=\ref[target];op=[operation]'>Confirm</a> "
		dat += "<a href='?src=\ref[src];abort=1'>Abort</a></div>"
		popup.set_content(dat)
		popup.open()
		return

	dat+= "<div class='statusDisplay'>"

	dat += "<div class='line'><div class='statusLabel'>Plant Sample:</div><div class='statusValue'><a href='?src=\ref[src];eject_seed=1'>"
	dat += seed ? seed.name : "None"
	dat += "</a></div></div>"

	dat += "<div class='line'><div class='statusLabel'>Data Disk:</div><div class='statusValue'><a href='?src=\ref[src];eject_disk=1'>"
	if(!disk)
		dat += "None"
	else if(!disk.gene)
		dat += "Empty Disk"
	else
		dat += disk.gene.get_name()
	if(disk && disk.read_only)
		dat += " (RO)"
	dat += "</a></div></div>"

	dat += "<br></div>"

	if(seed)
		var/can_insert = disk && disk.gene && disk.gene.can_add(seed)
		var/can_extract = disk && !disk.read_only

		dat += "<div class='line'><h3>Core Genes</h3></div><div class='statusDisplay'><table>"
		for(var/a in core_genes)
			var/datum/plant_gene/G = a
			if(!G)
				continue
			dat += "<tr><td width='260px'>[G.get_name()]</td><td>"
			if(can_extract)
				dat += "<a href='?src=\ref[src];gene=\ref[G];op=extract'>Extract</a>"
			if(can_insert && istype(disk.gene, G.type))
				dat += "<a href='?src=\ref[src];gene=\ref[G];op=replace'>Replace</a>"
			dat += "</td></tr>"
		dat += "</table></div>"

		if(seed.yield != -1)
			dat += "<div class='line'><h3>Content Genes</h3></div><div class='statusDisplay'>"
			if(reagent_genes.len)
				dat += "<table>"
				for(var/a in reagent_genes)
					var/datum/plant_gene/G = a
					dat += "<tr><td width='260px'>[G.get_name()]</td><td>"
					if(can_extract)
						dat += "<a href='?src=\ref[src];gene=\ref[G];op=extract'>Extract</a>"
					dat += "<a href='?src=\ref[src];gene=\ref[G];op=remove'>Remove</a>"
					dat += "</td></tr>"
				dat += "</table>"
			else
				dat += "No content-related genes detected in sample.<br>"
			dat += "</div>"
			if(can_insert && istype(disk.gene, /datum/plant_gene/reagent))
				dat += "<a href='?src=\ref[src];op=insert'>Insert: [disk.gene.get_name()]</a>"

			dat += "<div class='line'><h3>Trait Genes</h3></div><div class='statusDisplay'>"
			if(trait_genes.len)
				dat += "<table>"
				for(var/a in trait_genes)
					var/datum/plant_gene/G = a
					dat += "<tr><td width='260px'>[G.get_name()]</td><td>"
					if(can_extract)
						dat += "<a href='?src=\ref[src];gene=\ref[G];op=extract'>Extract</a>"
					dat += "<a href='?src=\ref[src];gene=\ref[G];op=remove'>Remove</a>"
					dat += "</td></tr>"
				dat += "</table>"
			else
				dat += "No trait-related genes detected in sample.<br>"
			if(can_insert && istype(disk.gene, /datum/plant_gene/trait))
				dat += "<a href='?src=\ref[src];op=insert'>Insert: [disk.gene.get_name()]</a>"
			dat += "</div>"
	else
		dat += "<br>No sample found.<br><span class='highlight'>Please, insert a plant sample to use this device.</span>"
	popup.set_content(dat)
	popup.open()


/obj/machinery/plantgenes/Topic(var/href, var/list/href_list)
	if(..())
		return
	usr.set_machine(src)

	if(href_list["eject_seed"] && !operation)
		if (seed)
			seed.loc = src.loc
			seed.verb_pickup()
			seed = null
			update_genes()
			update_icon()
		else
			var/obj/item/I = usr.get_active_held_item()
			if (istype(I, /obj/item/seeds))
				if(!usr.drop_item())
					return
				insert_seed(I)
				usr << "<span class='notice'>You add [I] to the machine.</span>"
		update_icon()
	else if(href_list["eject_disk"] && !operation)
		if (disk)
			disk.loc = src.loc
			disk.verb_pickup()
			disk = null
			update_genes()
		else
			var/obj/item/I = usr.get_active_held_item()
			if(istype(I, /obj/item/weapon/disk/plantgene))
				if(!usr.drop_item())
					return
				disk = I
				disk.loc = src
				usr << "<span class='notice'>You add [I] to the machine.</span>"
	else if(href_list["op"] == "insert" && disk && disk.gene && seed)
		if(!operation) // Wait for confirmation
			operation = "insert"
		else
			if(!istype(disk.gene, /datum/plant_gene/core) && disk.gene.can_add(seed))
				seed.genes += disk.gene.Copy()
				if(istype(disk.gene, /datum/plant_gene/reagent))
					seed.reagents_from_genes()
			update_genes()
			repaint_seed()
			operation = ""
			target = null

	else if(href_list["gene"] && seed)
		var/datum/plant_gene/G = seed.get_gene(href_list["gene"])
		if(!G || !href_list["op"] || !(href_list["op"] in list("remove", "extract", "replace")))
			interact(usr)
			return

		if(!operation || target != G) // Wait for confirmation
			target = G
			operation = href_list["op"]

		else if(operation == href_list["op"] && target == G)
			switch(href_list["op"])
				if("remove")
					if(!istype(G, /datum/plant_gene/core))
						seed.genes -= G
						if(istype(G, /datum/plant_gene/reagent))
							seed.reagents_from_genes()
					repaint_seed()
				if("extract")
					if(disk && !disk.read_only)
						disk.gene = G
						if(istype(G, /datum/plant_gene/core/potency))
							var/datum/plant_gene/core/gene = G
							gene.value = min(gene.value, max_extract_pot)
						disk.update_name()
						qdel(seed)
						seed = null
						update_icon()
				if("replace")
					if(disk && disk.gene && istype(disk.gene, G.type) && istype(G, /datum/plant_gene/core))
						seed.genes -= G
						var/datum/plant_gene/core/C = disk.gene.Copy()
						seed.genes += C
						C.apply_stat(seed)
						repaint_seed()
				if("insert")
					if(disk && disk.gene && !istype(disk.gene, /datum/plant_gene/core) && disk.gene.can_add(seed))
						seed.genes += disk.gene.Copy()
						if(istype(disk.gene, /datum/plant_gene/reagent))
							seed.reagents_from_genes()
						repaint_seed()

			update_genes()
			operation = ""
			target = null
	else if(href_list["abort"])
		operation = ""
		target = null

	interact(usr)

/obj/machinery/plantgenes/proc/insert_seed(obj/item/seeds/S)
	if(!istype(S) || seed)
		return
	S.loc = src
	seed = S
	update_genes()
	update_icon()

/obj/machinery/plantgenes/proc/update_genes()
	core_genes = list()
	reagent_genes = list()
	trait_genes = list()

	if(seed)
		var/gene_paths = list(
			/datum/plant_gene/core/potency,
			/datum/plant_gene/core/yield,
			/datum/plant_gene/core/production,
			/datum/plant_gene/core/endurance,
			/datum/plant_gene/core/lifespan,
			/datum/plant_gene/core/weed_rate,
			/datum/plant_gene/core/weed_chance
			)
		for(var/a in gene_paths)
			core_genes += seed.get_gene(a)

		for(var/datum/plant_gene/reagent/G in seed.genes)
			reagent_genes += G
		for(var/datum/plant_gene/trait/G in seed.genes)
			trait_genes += G

/obj/machinery/plantgenes/proc/repaint_seed()
	if(!seed)
		return
	if(copytext(seed.name, 1, 13) == "experimental")
		return // Already modded name and icon
	seed.name = "experimental " + seed.name
	seed.icon_state = "seed-x"



// Gene modder for seed vault ship, built with high tech alien parts.
/obj/machinery/plantgenes/seedvault/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/plantgenes/vault(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/plantgenes/vault
	name = "alien board (Plant DNA Manipulator)"
	icon_state = "abductor_mod"
	origin_tech = "programming=5;biotech=5"
	// It wasn't made by actual abductors race, so no abductor tech here.
	def_components = list(
		/obj/item/weapon/stock_parts/manipulator = /obj/item/weapon/stock_parts/manipulator/femto,
		/obj/item/weapon/stock_parts/micro_laser = /obj/item/weapon/stock_parts/micro_laser/quadultra,
		/obj/item/weapon/stock_parts/scanning_module = /obj/item/weapon/stock_parts/scanning_module/triphasic)

/*
 *  Plant DNA disk
 */

/obj/item/weapon/disk/plantgene
	name = "plant data disk"
	desc = "A disk for storing plant genetic data."
	icon_state = "datadisk2"
	materials = list(MAT_METAL=30, MAT_GLASS=10)
	var/datum/plant_gene/gene
	var/read_only = 0 //Well, it's still a floppy disk

/obj/item/weapon/disk/plantgene/New()
	..()
	add_overlay("datadisk_gene")
	src.pixel_x = rand(-5, 5)
	src.pixel_y = rand(-5, 5)

/obj/item/weapon/disk/plantgene/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if(istype(W, /obj/item/weapon/pen))
		var/t = stripped_input(user, "What would you like the label to be?", name, null)
		if(user.get_active_held_item() != W)
			return
		if(!in_range(src, user) && loc != user)
			return
		if(t)
			name = "plant data disk - '[t]'"
		else
			name = "plant data disk"

/obj/item/weapon/disk/plantgene/proc/update_name()
	if(gene)
		name = "plant data disk - '[gene.get_name()]'"
	else
		name = "plant data disk"

/obj/item/weapon/disk/plantgene/attack_self(mob/user)
	read_only = !read_only
	user << "<span class='notice'>You flip the write-protect tab to [src.read_only ? "protected" : "unprotected"].</span>"

/obj/item/weapon/disk/plantgene/examine(mob/user)
	..()
	user << "The write-protect tab is set to [src.read_only ? "protected" : "unprotected"]."


/*
 *  Plant DNA Disks Box
 */
/obj/item/weapon/storage/box/disks_plantgene
	name = "plant data disks box"
	icon_state = "disk_kit"

/obj/item/weapon/storage/box/disks_plantgene/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/weapon/disk/plantgene(src)
