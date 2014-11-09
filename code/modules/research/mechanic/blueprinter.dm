//Makes blueprint items from device analyzers and PDAs with the device analyser setting
//Can be loaded with both paper and nanopaper

/obj/machinery/r_n_d/blueprinter
	name = "Blueprint Printer"
	icon = 'icons/obj/machines/mechanic.dmi'
	icon_state = "blueprinter"
	desc = "An old-fashioned roller printer, capable of producing highly-detailed design blueprints using the special properties of nano-paper, as well as the regular properties of normal paper."
	var/paper_loaded = 0
	var/nano_loaded = 0
	var/max_paper = 10
	var/max_nano = 10
	var/max_paperprint_uses = 1 //how many uses you get out of a paper blueprint

	research_flags = HASOUTPUT

/obj/machinery/r_n_d/blueprinter/New()
	..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/blueprinter,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/scanning_module
	)

	RefreshParts()

/obj/machinery/r_n_d/blueprinter/RefreshParts()
	var/list/bins = list()
	var/obj/item/weapon/stock_parts/manipulator/M
	if(!component_parts)
		return
	for(var/obj/item/weapon/stock_parts/matter_bin/MB in component_parts)
		if(istype(MB))
			bins  += MB.rating
	max_paper = 10 * bins[1]
	max_nano = 10 * bins[2]
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/manipulator))
			M = SP
			break
	if(M)
		max_paperprint_uses = 1 * M.rating
	else
		max_paperprint_uses = 1

/obj/machinery/r_n_d/blueprinter/attackby(var/atom/A, mob/user)
	if(..())
		return 1

	if(istype(A, /obj/item/weapon/paper))
		var/obj/item/weapon/paper/P = A
		if(istype(P, /obj/item/weapon/paper/nano))
			if(max_nano > nano_loaded)
				nano_loaded++
				qdel(P)
			else
				user <<"<span class='notice'>\The [src] is full.</span>"
		else
			if(max_paper > paper_loaded)
				paper_loaded++
				qdel(P)
			else
				user <<"<span class='notice'>\The [src] is full.</span>"
		return

	if(istype(A, /obj/item/weapon/paper_pack))
		var/obj/item/weapon/paper_pack/PP = A
		var/usingamount = 0
		if(!PP.amount)
			user <<"<span class='notice'>You have to have paper to load the [src]!</span>"
		else
			var/load_overlay = "[base_state][PP.pptype ? "nano" : "regular"]"
			if(PP.pptype == "nano")
				usingamount = min(max_nano - nano_loaded, PP.amount)
				nano_loaded += usingamount
			else
				usingamount = min(max_paper - paper_loaded, PP.amount)
				paper_loaded += usingamount
			overlays += load_overlay
			PP.usepaper(usingamount)
			user <<"<span class='notice'>You successfully load [usingamount] sheets into the [src].</span>"
			spawn(30)
				overlays -= load_overlay
		return

//Creates a blueprint of a given design datum
//use_nano controls if the design is printed using nanopaper or regular paper
//nanopaper designs are better, see blueprint.dm for the code details
/obj/machinery/r_n_d/blueprinter/proc/PrintDesign(var/datum/design/mechanic_design/design, var/use_nano = 0)
	if(!istype(design)) //sanity checks yay
		return
	if((use_nano && nano_loaded == 0) || (!use_nano && paper_loaded == 0)) //material checks
		visible_message("\icon [src]<span class='notice'> \The [src] beeps: 'Out of [use_nano ? "nanopaper" : "paper"]!'</span>")
		return

	busy = 1
	overlays += "[base_state]_ani"
	sleep(30)
	busy = 0
	if(use_nano)
		new/obj/item/research_blueprint/nano(output.loc, design)
		nano_loaded -= 1
	else
		new/obj/item/research_blueprint(output.loc, design, max_paperprint_uses)
		paper_loaded -= 1
	src.visible_message("\icon [src]<span class='notice'>\The [src] beeps: Successfully printed the [design.name] design.</span>")
	spawn(20)
		overlays -= "[base_state]_ani"
	return 1