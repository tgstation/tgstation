#define INJECTOR_TIMEOUT 300
#define REJUVENATORS_INJECT 15
#define REJUVENATORS_MAX 90
#define NUMBER_OF_BUFFERS 3

#define RADIATION_STRENGTH_MAX 15
#define RADIATION_STRENGTH_MULTIPLIER 1			//larger has a more range

#define RADIATION_DURATION_MAX 30
#define RADIATION_ACCURACY_MULTIPLIER 3			//larger is less accurate

#define RADIATION_IRRADIATION_MULTIPLIER 0.2	//multiplier for how much radiation a test subject recieves

#define BAD_MUTATION_DIFFICULTY 2
#define GOOD_MUTATION_DIFFICULTY 4
#define OP_MUTATION_DIFFICULTY 5
/////////////////////////// DNA DATUM
/datum/dna
	var/unique_enzymes
	var/struc_enzymes
	var/uni_identity
	var/blood_type
	var/datum/species/species = new /datum/species/human() //The type of mutant race the player is if applicable (i.e. potato-man)
	var/mutant_color = "FFF"		 // What color you are if you have certain speciess
	var/real_name //Stores the real name of the person who originally got this dna datum. Used primarely for changelings,
	var/list/mutations = list()   //All mutations are from now on here
	var/mob/living/carbon/holder

/datum/dna/New(mob/living/carbon/new_holder)
	if(new_holder && istype(new_holder))
		holder = new_holder

/datum/dna/proc/transfer_identity(mob/living/carbon/destination)
	if(check_dna_integrity(destination))
		destination.dna.unique_enzymes = unique_enzymes
		destination.dna.uni_identity = uni_identity
		destination.dna.blood_type = blood_type
		hardset_dna(destination, null, null, null, null, species)
		destination.dna.mutant_color = mutant_color
		destination.dna.real_name = real_name
		destination.dna.mutations = mutations

/datum/dna/proc/copy_dna(var/datum/dna/new_dna)
	new_dna.unique_enzymes = unique_enzymes
	new_dna.struc_enzymes = struc_enzymes
	new_dna.uni_identity = uni_identity
	new_dna.blood_type = blood_type
	new_dna.species = new species.type
	new_dna.mutant_color = mutant_color
	new_dna.real_name = real_name
	new_dna.mutations = mutations

/datum/dna/proc/add_mutation(mutation_name)
	var/datum/mutation/human/HM = mutations_list[mutation_name]
	HM.on_acquiring(holder)

/datum/dna/proc/remove_mutation(mutation_name)
	var/datum/mutation/human/HM = mutations_list[mutation_name]
	HM.on_losing(holder)

/datum/dna/proc/check_mutation(mutation_name)
	var/datum/mutation/human/HM = mutations_list[mutation_name]
	return mutations.Find(HM)

/datum/dna/proc/remove_all_mutations()
	remove_mutation_group(mutations)

/datum/dna/proc/remove_mutation_group(list/group)
	if(!group)	return
	for(var/datum/mutation/human/HM in group)
		HM.force_lose(holder)

/datum/dna/proc/generate_uni_identity(mob/living/carbon/character)
	. = ""
	var/list/L = new /list(DNA_UNI_IDENTITY_BLOCKS)
	if(istype(character))
		L[DNA_GENDER_BLOCK] = construct_block((character.gender!=MALE)+1, 2)
		if(istype(character, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = character
			if(!H.dna.species)
				hardset_dna(H, null, null, null, null, /datum/species/human)
			if(!hair_styles_list.len)
				init_sprite_accessory_subtypes(/datum/sprite_accessory/hair, hair_styles_list, hair_styles_male_list, hair_styles_female_list)
			L[DNA_HAIR_STYLE_BLOCK] = construct_block(hair_styles_list.Find(H.hair_style), hair_styles_list.len)
			L[DNA_HAIR_COLOR_BLOCK] = sanitize_hexcolor(H.hair_color)
			if(!facial_hair_styles_list.len)
				init_sprite_accessory_subtypes(/datum/sprite_accessory/facial_hair, facial_hair_styles_list, facial_hair_styles_male_list, facial_hair_styles_female_list)
			L[DNA_FACIAL_HAIR_STYLE_BLOCK] = construct_block(facial_hair_styles_list.Find(H.facial_hair_style), facial_hair_styles_list.len)
			L[DNA_FACIAL_HAIR_COLOR_BLOCK] = sanitize_hexcolor(H.facial_hair_color)
			L[DNA_SKIN_TONE_BLOCK] = construct_block(skin_tones.Find(H.skin_tone), skin_tones.len)
			L[DNA_EYE_COLOR_BLOCK] = sanitize_hexcolor(H.eye_color)

	for(var/i=1, i<=DNA_UNI_IDENTITY_BLOCKS, i++)
		if(L[i])	. += L[i]
		else		. += random_string(DNA_BLOCK_SIZE,hex_characters)
	return .

/datum/dna/proc/generate_struc_enzymes(mob/living/carbon/character)
	var/list/L = list("0","1","2","3","4","5","6")
	var/list/sorting = new /list(DNA_STRUC_ENZYMES_BLOCKS)
	var/result = ""
	for(var/datum/mutation/human/A in good_mutations + bad_mutations + not_good_mutations)
		if(A.name == RACEMUT && istype(character,/mob/living/carbon/monkey))
			sorting[A.dna_block] = num2hex(A.lowest_value + rand(0, 256 * 6), DNA_BLOCK_SIZE)
			character.dna.mutations.Add(A)
		else
			sorting[A.dna_block] = random_string(DNA_BLOCK_SIZE, L)

	for(var/B in sorting)
		result += B
	return result

/datum/dna/proc/generate_unique_enzymes(mob/living/carbon/character)
	. = ""
	if(istype(character))
		real_name = character.real_name
		. += md5(character.real_name)
	else
		. += repeat_string(DNA_UNIQUE_ENZYMES_LEN, "0")
	return .

/datum/dna/proc/mutations_say_mods(var/message)
	if(message)
		for(var/datum/mutation/human/M in mutations)
			message = M.say_mod(message)
		return message

/datum/dna/proc/mutations_get_spans()
	var/list/spans = list()
	for(var/datum/mutation/human/M in mutations)
		spans |= M.get_spans()
	return spans

/proc/hardset_dna(mob/living/carbon/owner, ui, se, real_name, blood_type, datum/species/mrace, mcolor)
	if(!istype(owner, /mob/living/carbon/monkey) && !istype(owner, /mob/living/carbon/human))
		return
	if(!owner.dna)
		create_dna(owner, mrace)

	if(mrace)
		if(owner.dna.species.exotic_blood)
			var/datum/reagent/exotic_blood = owner.dna.species.exotic_blood
			owner.reagents.del_reagent(exotic_blood.id)
		owner.dna.species = new mrace()

	if(mcolor)
		owner.dna.mutant_color = mcolor

	if(real_name)
		owner.real_name = real_name
		owner.dna.generate_unique_enzymes(owner)

	if(blood_type)
		owner.dna.blood_type = blood_type

	if(ui)
		owner.dna.uni_identity = ui
		updateappearance(owner)

	if(se)
		owner.dna.struc_enzymes = se
		domutcheck(owner)

	check_dna_integrity(owner)

	owner.regenerate_icons()
	return

/proc/check_dna_integrity(mob/living/carbon/character)
	if(!character || !(istype(character, /mob/living/carbon/human) || istype(character, /mob/living/carbon/monkey))) //Evict xenos from carbon 2012
		return
	if(!character.dna)
		if(ready_dna(character))
			return character.dna
		return

	if(length(character.dna.uni_identity) != DNA_UNI_IDENTITY_BLOCKS*DNA_BLOCK_SIZE)
		character.dna.uni_identity = character.dna.generate_uni_identity(character)
	if(length(character.dna.struc_enzymes)!= DNA_STRUC_ENZYMES_BLOCKS*DNA_BLOCK_SIZE)
		character.dna.struc_enzymes = character.dna.generate_struc_enzymes()
	if(!character.dna.real_name || length(character.dna.unique_enzymes) != DNA_UNIQUE_ENZYMES_LEN)
		character.dna.unique_enzymes = character.dna.generate_unique_enzymes(character)
	return character.dna

/proc/ready_dna(mob/living/carbon/character, blood_type)
	if(!istype(character, /mob/living/carbon/monkey) && !istype(character, /mob/living/carbon/human))
		return
	if(!character.dna)
		create_dna(character)
	if(blood_type)
		character.dna.blood_type = blood_type
		character.dna.real_name = character.real_name
	character.dna.uni_identity = character.dna.generate_uni_identity(character)
	character.dna.struc_enzymes = character.dna.generate_struc_enzymes(character)
	character.dna.unique_enzymes = character.dna.generate_unique_enzymes(character)
	return character.dna

/proc/create_dna(mob/living/carbon/C, datum/species/S) //don't use this unless you're about to use hardset_dna or ready_dna
	C.dna = new /datum/dna(C)
	C.dna.holder = C
	if(S)	C.dna.species = new S()	// do not remove; this is here to prevent runtimes

/////////////////////////// DNA DATUM

/////////////////////////// DNA HELPER-PROCS
/proc/getleftblocks(input,blocknumber,blocksize)
	if(blocknumber > 1)
		return copytext(input,1,((blocksize*blocknumber)-(blocksize-1)))

/proc/getrightblocks(input,blocknumber,blocksize)
	if(blocknumber < (length(input)/blocksize))
		return copytext(input,blocksize*blocknumber+1,length(input)+1)

/proc/getblock(input, blocknumber, blocksize=DNA_BLOCK_SIZE)
	return copytext(input, blocksize*(blocknumber-1)+1, (blocksize*blocknumber)+1)

/proc/setblock(istring, blocknumber, replacement, blocksize=DNA_BLOCK_SIZE)
	if(!istring || !blocknumber || !replacement || !blocksize)	return 0
	return getleftblocks(istring, blocknumber, blocksize) + replacement + getrightblocks(istring, blocknumber, blocksize)

/proc/scramble(input,rs,rd)
	var/length = length(input)
	var/ran = gaussian(0, rs*RADIATION_STRENGTH_MULTIPLIER)
	if(ran == 0)		ran = pick(-1,1)	//hacky, statistically should almost never happen. 0-change makes people mad though
	else if(ran < 0)	ran = round(ran)	//negative, so floor it
	else				ran = -round(-ran)	//positive, so ceiling it
	return num2hex(Wrap(hex2num(input)+ran, 0, 16**length), length)

/proc/randomize_radiation_accuracy(position_we_were_supposed_to_hit, radduration, number_of_blocks)
	return Wrap(round(position_we_were_supposed_to_hit + gaussian(0, RADIATION_ACCURACY_MULTIPLIER/radduration), 1), 1, number_of_blocks+1)

/proc/randmut(mob/living/carbon/M, list/candidates, difficulty = 2)
	if(!check_dna_integrity(M))
		return
	var/datum/mutation/human/num = pick(candidates)
	. = num.force_give(M)
	return

/proc/randmutb(mob/living/carbon/M)
	if(!check_dna_integrity(M))
		return
	var/datum/mutation/human/HM = pick((bad_mutations | not_good_mutations) - mutations_list[RACEMUT])
	. = HM.force_give(M)

/proc/randmutg(mob/living/carbon/M)
	if(!check_dna_integrity(M))
		return
	var/datum/mutation/human/HM = pick(good_mutations)
	. = HM.force_give(M)

/proc/randmuti(mob/living/carbon/M)
	if(!check_dna_integrity(M))	return
	var/num = rand(1, DNA_STRUC_ENZYMES_BLOCKS)
	var/newdna = setblock(M.dna.uni_identity, num, random_string(DNA_BLOCK_SIZE, hex_characters))
	M.dna.uni_identity = newdna
	return

/proc/clean_dna(mob/living/carbon/M)
	if(!check_dna_integrity(M))
		return
	M.dna.remove_all_mutations()

/proc/clean_randmut(mob/living/carbon/M, list/candidates, difficulty = 2)
	clean_dna(M)
	randmut(M, candidates, difficulty)

/proc/scramble_dna(mob/living/carbon/M, ui=FALSE, se=FALSE, probability)
	if(!check_dna_integrity(M))
		return 0
	if(se)
		for(var/i=1, i<=DNA_STRUC_ENZYMES_BLOCKS, i++)
			if(prob(probability))
				M.dna.struc_enzymes = setblock(M.dna.struc_enzymes, i, random_string(DNA_BLOCK_SIZE, hex_characters))
		domutcheck(M)
	if(ui)
		for(var/i=1, i<=DNA_UNI_IDENTITY_BLOCKS, i++)
			if(prob(probability))
				M.dna.uni_identity = setblock(M.dna.uni_identity, i, random_string(DNA_BLOCK_SIZE, hex_characters))
		updateappearance(M)
	return 1

/////////////////////////// DNA HELPER-PROCS

/////////////////////////// DNA MISC-PROCS
/proc/updateappearance(mob/living/carbon/C)
	if(!check_dna_integrity(C))
		return 0

	var/structure = C.dna.uni_identity
	C.gender = (deconstruct_block(getblock(structure, DNA_GENDER_BLOCK), 2)-1) ? FEMALE : MALE
	if(istype(C, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = C
		H.hair_color = sanitize_hexcolor(getblock(structure, DNA_HAIR_COLOR_BLOCK))
		H.facial_hair_color = sanitize_hexcolor(getblock(structure, DNA_FACIAL_HAIR_COLOR_BLOCK))
		H.skin_tone = skin_tones[deconstruct_block(getblock(structure, DNA_SKIN_TONE_BLOCK), skin_tones.len)]
		H.eye_color = sanitize_hexcolor(getblock(structure, DNA_EYE_COLOR_BLOCK))
		H.facial_hair_style = facial_hair_styles_list[deconstruct_block(getblock(structure, DNA_FACIAL_HAIR_STYLE_BLOCK), facial_hair_styles_list.len)]
		H.hair_style = hair_styles_list[deconstruct_block(getblock(structure, DNA_HAIR_STYLE_BLOCK), hair_styles_list.len)]

		H.update_body()
		H.update_hair()
	return 1

/proc/domutcheck(mob/living/carbon/M)
	if(!check_dna_integrity(M))
		return 0

	var/mob/living/carbon/C = M
	var/mob/living/carbon/temp

	for(var/datum/mutation/human/A in good_mutations | bad_mutations | not_good_mutations)
		temp = A.check_block(C)
		if(ismob(temp))
			C = temp

//////////////////////////////////////////////////////////// Monkey Block
	if(M)
		M.regenerate_icons()
	return 1
/////////////////////////// DNA MISC-PROCS


/////////////////////////// DNA MACHINES
/obj/machinery/dna_scannernew
	name = "\improper DNA scanner"
	desc = "It scans DNA structures."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "scanner"
	density = 1
	var/locked = 0
	anchored = 1
	use_power = 1
	idle_power_usage = 50
	active_power_usage = 300
	var/damage_coeff
	var/scan_level
	var/precision_coeff

/obj/machinery/dna_scannernew/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/clonescanner(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()


/obj/machinery/dna_scannernew/RefreshParts()
	scan_level = 0
	damage_coeff = 0
	precision_coeff = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/P in component_parts)
		scan_level += P.rating
	for(var/obj/item/weapon/stock_parts/manipulator/P in component_parts)
		precision_coeff = P.rating
	for(var/obj/item/weapon/stock_parts/micro_laser/P in component_parts)
		damage_coeff = P.rating

/obj/machinery/dna_scannernew/update_icon()

	//no power or maintenance
	if(stat & (NOPOWER|BROKEN))
		icon_state = initial(icon_state)+ (state_open ? "_open" : "") + "_unpowered"
		return

	if((stat & MAINT) || panel_open)
		icon_state = initial(icon_state)+ (state_open ? "_open" : "") + "_maintenance"
		return

	//running and someone in there
	if(occupant)
		icon_state = initial(icon_state)+ "_occupied"
		return

	//running
	icon_state = initial(icon_state)+ (state_open ? "_open" : "")

/obj/machinery/dna_scannernew/power_change()
	..()
	update_icon()

/obj/machinery/dna_scannernew/proc/toggle_open(var/mob/user)
	if(panel_open)
		user << "<span class='notice'>Close the maintenance panel first.</span>"
		return

	if(state_open)
		close_machine()
		return

	else if(locked)
		user << "<span class='notice'>The bolts are locked down, securing the door shut.</span>"
		return

	open_machine()

/obj/machinery/dna_scannernew/container_resist()
	var/mob/living/user = usr
	var/breakout_time = 2
	if(state_open || !locked)	//Open and unlocked, no need to escape
		state_open = 1
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user << "<span class='notice'>You lean on the back of [src] and start pushing the door open... (this will take about [breakout_time] minutes.)</span>"
	user.visible_message("<span class='italics'>You hear a metallic creaking from [src]!</span>")

	if(do_after(user,(breakout_time*60*10))) //minutes * 60seconds * 10deciseconds
		if(!user || user.stat != CONSCIOUS || user.loc != src || state_open || !locked)
			return

		locked = 0
		visible_message("<span class='warning'>[user] successfully broke out of [src]!</span>")
		user << "<span class='notice'>You successfully break out of [src]!</span>"

		open_machine()

/obj/machinery/dna_scannernew/close_machine()
	if(!state_open)
		return 0

	..()

	// search for ghosts, if the corpse is empty and the scanner is connected to a cloner
	if(occupant)
		if(locate(/obj/machinery/computer/cloning, get_step(src, NORTH)) \
			|| locate(/obj/machinery/computer/cloning, get_step(src, SOUTH)) \
			|| locate(/obj/machinery/computer/cloning, get_step(src, EAST)) \
			|| locate(/obj/machinery/computer/cloning, get_step(src, WEST)))

			var/mob/dead/observer/ghost = occupant.get_ghost()
			if(ghost)
				ghost << "<span class='ghostalert'>Your corpse has been placed into a cloning scanner. Return to your body if you want to be cloned!</span> (Verbs -> Ghost -> Re-enter corpse)"
				ghost << sound('sound/effects/genetics.ogg')
	return 1

/obj/machinery/dna_scannernew/open_machine()
	if(state_open)
		return 0

	..()

	return 1

/obj/machinery/dna_scannernew/relaymove(mob/user as mob)
	if(user.stat || locked)
		return

	open_machine()
	return

/obj/machinery/dna_scannernew/attackby(var/obj/item/I, mob/user, params)

	if(!occupant && default_deconstruction_screwdriver(user, icon_state, icon_state, I))//sent icon_state is irrelevant...
		update_icon()//..since we're updating the icon here, since the scanner can be unpowered when opened/closed
		return

	if(exchange_parts(user, I))
		return

	if(default_pry_open(I))
		return

	if(default_deconstruction_crowbar(I))
		return

	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		if(!ismob(G.affecting))
			return

		if(!state_open)
			user << "<span class='notice'>Open the scanner first.</span>"
			return

		var/mob/M = G.affecting
		M.loc = loc
		user.stop_pulling()
		qdel(G)

/obj/machinery/dna_scannernew/attack_hand(mob/user)
	if(..(user,1,0)) //don't set the machine, since there's no dialog
		return

	toggle_open(user)

/obj/machinery/dna_scannernew/blob_act()
	if(prob(75))
		qdel(src)


//DNA COMPUTER
/obj/machinery/computer/scan_consolenew
	name = "\improper DNA scanner access console"
	desc = "Scan DNA."
	icon = 'icons/obj/computer.dmi'
	icon_state = "scanner"
	density = 1
	circuit = /obj/item/weapon/circuitboard/scan_consolenew
	var/radduration = 2
	var/radstrength = 1

	var/list/buffer[NUMBER_OF_BUFFERS]

	var/injectorready = 0	//Quick fix for issue 286 (screwdriver the screen twice to restore injector)	-Pete
	var/current_screen = "mainmenu"
	var/obj/machinery/dna_scannernew/connected = null
	var/obj/item/weapon/disk/data/diskette = null
	anchored = 1.0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 400

/obj/machinery/computer/scan_consolenew/attackby(obj/item/I as obj, mob/user as mob, params)
	if (istype(I, /obj/item/weapon/disk/data)) //INSERT SOME DISKETTES
		if (!src.diskette)
			user.drop_item()
			I.loc = src
			src.diskette = I
			user << "<span class='notice'>You insert [I].</span>"
			src.updateUsrDialog()
			return
	else
		..()
	return

/obj/machinery/computer/scan_consolenew/New()
	..()

	spawn(5)
		for(dir in list(NORTH,EAST,SOUTH,WEST))
			connected = locate(/obj/machinery/dna_scannernew, get_step(src, dir))
			if(!isnull(connected))
				break
		spawn(250)
			injectorready = 1
		return
	return

/obj/machinery/computer/scan_consolenew/attack_hand(mob/user)
	if(..())
		return
	ShowInterface(user)

/obj/machinery/computer/scan_consolenew/proc/ShowInterface(mob/user, last_change)
	if(!user) return
	var/datum/browser/popup = new(user, "scannernew", "DNA Modifier Console", 880, 600) // Set up the popup browser window
	if(!( in_range(src, user) || istype(user, /mob/living/silicon) ))
		popup.close()
		return
	popup.add_stylesheet("scannernew", 'html/browser/scannernew.css')

	var/mob/living/carbon/viable_occupant
	var/occupant_status = "<div class='line'><div class='statusLabel'>Subject Status:</div><div class='statusValue'>"
	var/scanner_status
	var/temp_html
	if(connected && connected.is_operational())
		if(connected.occupant)	//set occupant_status message
			viable_occupant = connected.occupant
			if(check_dna_integrity(viable_occupant) && (!(NOCLONE in viable_occupant.mutations) || (connected.scan_level == 3)))	//occupent is viable for dna modification
				occupant_status += "[viable_occupant.name] => "
				switch(viable_occupant.stat)
					if(CONSCIOUS)	occupant_status += "<span class='good'>Conscious</span>"
					if(UNCONSCIOUS)	occupant_status += "<span class='average'>Unconscious</span>"
					else			occupant_status += "<span class='bad'>DEAD - Cannot Operate</span>"
				occupant_status += "</div></div>"
				occupant_status += "<div class='line'><div class='statusLabel'>Health:</div><div class='progressBar'><div style='width: [viable_occupant.health]%;' class='progressFill good'></div></div><div class='statusValue'>[viable_occupant.health]%</div></div>"
				occupant_status += "<div class='line'><div class='statusLabel'>Radiation Level:</div><div class='progressBar'><div style='width: [viable_occupant.radiation]%;' class='progressFill bad'></div></div><div class='statusValue'>[viable_occupant.radiation]%</div></div>"
				var/rejuvenators = viable_occupant.reagents.get_reagent_amount("epinephrine")
				occupant_status += "<div class='line'><div class='statusLabel'>Rejuvenators:</div><div class='progressBar'><div style='width: [round((rejuvenators / REJUVENATORS_MAX) * 100)]%;' class='progressFill highlight'></div></div><div class='statusValue'>[rejuvenators] units</div></div>"
				occupant_status += "<div class='line'><div class='statusLabel'>Unique Enzymes :</div><div class='statusValue'><span class='highlight'>[viable_occupant.dna.unique_enzymes]</span></div></div>"
				occupant_status += "<div class='line'><div class='statusLabel'>Last Operation:</div><div class='statusValue'>[last_change ? last_change : "----"]</div></div>"
			else
				viable_occupant = null
				occupant_status += "<span class='bad'>Invalid DNA structure</span></div></div>"
			if (viable_occupant && viable_occupant.stat == DEAD)
				viable_occupant = null // No editing the dead.
		else
			occupant_status += "<span class='bad'>No subject detected</span></div></div>"

		if(connected.state_open)
			scanner_status = "Open"
		else
			scanner_status = "Closed"
			if(connected.locked)
				scanner_status += " <span class='bad'>(Locked)</span>"
			else
				scanner_status += " <span class='good'>(Unlocked)</span>"


	else
		occupant_status += "<span class='bad'>----</span></div></div>"
		scanner_status += "<span class='bad'>Error: No scanner detected</span>"

	var/status = "<div class='statusDisplay'>"
	status += "<div class='line'><div class='statusLabel'>Scanner:</div><div class='statusValue'>[scanner_status]</div></div>"
	status += "[occupant_status]"


	status += "<h3>Radiation Emitter Status</h3>"
	var/stddev = radstrength*RADIATION_STRENGTH_MULTIPLIER
	status += "<div class='line'><div class='statusLabel'>Output Level:</div><div class='statusValue'>[radstrength]</div></div>"
	status += "<div class='line'><div class='statusLabel'>&nbsp;&nbsp;\> Mutation:</div><div class='statusValue'>(-[stddev] to +[stddev] = 68%) (-[2*stddev] to +[2*stddev] = 95%)</div></div>"
	if(connected)
		stddev = RADIATION_ACCURACY_MULTIPLIER/(radduration + (connected.precision_coeff ** 2))
	else
		stddev = RADIATION_ACCURACY_MULTIPLIER/radduration
	var/chance_to_hit
	switch(stddev)	//hardcoded values from a z-table for a normal distribution
		if(0 to 0.25)			chance_to_hit = ">95%"
		if(0.25 to 0.5)			chance_to_hit = "68-95%"
		if(0.5 to 0.75)			chance_to_hit = "55-68%"
		else					chance_to_hit = "<38%"
	status += "<div class='line'><div class='statusLabel'>Pulse Duration:</div><div class='statusValue'>[radduration]</div></div>"
	status += "<div class='line'><div class='statusLabel'>&nbsp;&nbsp;\> Accuracy:</div><div class='statusValue'>[chance_to_hit]</div></div>"
	status += "</div>" // Close statusDisplay div
	var/buttons = "<a href='?src=\ref[src];'>Scan</a> "
	if(connected)
		buttons += " <a href='?src=\ref[src];task=toggleopen;'>[connected.state_open ? "Close" : "Open"] Scanner</a> "
		if (connected.state_open)
			buttons += "<span class='linkOff'>[connected.locked ? "Unlock" : "Lock"] Scanner</span> "
		else
			buttons += "<a href='?src=\ref[src];task=togglelock;'>[connected.locked ? "Unlock" : "Lock"] Scanner</a> "
	else				buttons += "<span class='linkOff'>Open Scanner</span> <span class='linkOff'>Lock Scanner</span> "
	if(viable_occupant)	buttons += "<a href='?src=\ref[src];task=rejuv'>Inject Rejuvenators</a> "
	else				buttons += "<span class='linkOff'>Inject Rejuvenators</span> "
	if(diskette)		buttons += "<a href='?src=\ref[src];task=ejectdisk'>Eject Disk</a> "
	else				buttons += "<span class='linkOff'>Eject Disk</span> "
	if(current_screen == "buffer")	buttons += "<a href='?src=\ref[src];task=screen;text=mainmenu;'>Radiation Emitter Menu</a> "
	else							buttons += "<a href='?src=\ref[src];task=screen;text=buffer;'>Buffer Menu</a> "

	switch(current_screen)
		if("working")
			temp_html += status
			temp_html += "<h1>System Busy</h1>"
			temp_html += "Working ... Please wait ([radduration] Seconds)"
		if("buffer")
			temp_html += status
			temp_html += buttons
			temp_html += "<h1>Buffer Menu</h1>"

			if(istype(buffer))
				for(var/i=1, i<=buffer.len, i++)
					temp_html += "<br>Slot [i]: "
					var/list/buffer_slot = buffer[i]
					if( !buffer_slot || !buffer_slot.len || !buffer_slot["name"] || !((buffer_slot["UI"] && buffer_slot["UE"]) || buffer_slot["SE"]) )
						temp_html += "<br>\tNo Data"
						if(viable_occupant)	temp_html += "<br><a href='?src=\ref[src];task=setbuffer;num=[i];'>Save to Buffer</a> "
						else				temp_html += "<br><span class='linkOff'>Save to Buffer</span> "
						temp_html += "<span class='linkOff'>Clear Buffer</span> "
						if(diskette)		temp_html += "<a href='?src=\ref[src];task=loaddisk;num=[i];'>Load from Disk</a> "
						else				temp_html += "<span class='linkOff'>Load from Disk</span> "
						temp_html += "<span class='linkOff'>Save to Disk</span> "
					else
						var/ui = buffer_slot["UI"]
						var/se = buffer_slot["SE"]
						var/ue = buffer_slot["UE"]
						var/name = buffer_slot["name"]
						var/label = buffer_slot["label"]
						var/blood_type = buffer_slot["blood_type"]
						temp_html += "<br>\t<a href='?src=\ref[src];task=setbufferlabel;num=[i];'>Label</a>: [label ? label : name]"
						temp_html += "<br>\tSubject: [name]"
						if(ue && name && blood_type)
							temp_html += "<br>\tBlood Type: [blood_type]"
							temp_html += "<br>\tUE: [ue] "
							if(viable_occupant)	temp_html += "<a href='?src=\ref[src];task=transferbuffer;num=[i];text=ue'>Occupant</a> "
							else				temp_html += "<span class='linkOff'>Occupant</span>"
							if(injectorready)	temp_html += "<a href='?src=\ref[src];task=injector;num=[i];text=ue'>Injector</a>"
							else				temp_html += "<span class='linkOff'>Injector</span>"
						else
							temp_html += "<br>\tBlood Type: No Data"
							temp_html += "<br>\tUE: No Data"
						if(ui)
							temp_html += "<br>\tUI: [ui] "
							if(viable_occupant)	temp_html += "<a href='?src=\ref[src];task=transferbuffer;num=[i];text=ui'>Occupant</a> "
							else				temp_html += "<span class='linkOff'>Occupant</span>"
							if(injectorready)	temp_html += "<a href='?src=\ref[src];task=injector;num=[i];text=ui'>Injector</a>"
							else				temp_html += "<span class='linkOff'>Injector</span>"
						else
							temp_html += "<br>\tUI: No Data"
						if(se)
							temp_html += "<br>\tSE: [se] "
							if(viable_occupant)	temp_html += "<a href='?src=\ref[src];task=transferbuffer;num=[i];text=se'>Occupant</a> "
							else				temp_html += "<span class='linkOff'>Occupant</span> "
							if(injectorready)	temp_html += "<a href='?src=\ref[src];task=injector;num=[i];text=se'>Injector</a>"
							else				temp_html += "<span class='linkOff'>Injector</span>"
						else
							temp_html += "<br>\tSE: No Data"
						if(viable_occupant)	temp_html += "<br><a href='?src=\ref[src];task=setbuffer;num=[i];'>Save to Buffer</a> "
						else				temp_html += "<br><span class='linkOff'>Save to Buffer</span> "
						temp_html += "<a href='?src=\ref[src];task=clearbuffer;num=[i];'>Clear Buffer</a> "
						if(diskette)		temp_html += "<a href='?src=\ref[src];task=loaddisk;num=[i];'>Load from Disk</a> "
						else				temp_html += "<span class='linkOff'>Load from Disk</span> "
						if(diskette && !diskette.read_only)	temp_html += "<a href='?src=\ref[src];task=savedisk;num=[i];'>Save to Disk</a> "
						else								temp_html += "<span class='linkOff'>Save to Disk</span> "
		else
			temp_html += status
			temp_html += buttons
			temp_html += "<h1>Radiation Emitter Menu</h1>"

			temp_html += "<a href='?src=\ref[src];task=setstrength;num=[radstrength-1];'>--</a> <a href='?src=\ref[src];task=setstrength;'>Output Level</a> <a href='?src=\ref[src];task=setstrength;num=[radstrength+1];'>++</a>"
			temp_html += "<br><a href='?src=\ref[src];task=setduration;num=[radduration-1];'>--</a> <a href='?src=\ref[src];task=setduration;'>Pulse Duration</a> <a href='?src=\ref[src];task=setduration;num=[radduration+1];'>++</a>"

			temp_html += "<h3>Irradiate Subject</h3>"
			temp_html += "<div class='line'><div class='statusLabel'>Unique Identifier:</div><div class='statusValue'><div class='clearBoth'>"

			var/max_line_len = 7*DNA_BLOCK_SIZE
			if(viable_occupant)
				temp_html += "<div class='dnaBlockNumber'>1</div>"
				var/len = length(viable_occupant.dna.uni_identity)
				for(var/i=1, i<=len, i++)
					temp_html += "<a class='dnaBlock' href='?src=\ref[src];task=pulseui;num=[i];'>[copytext(viable_occupant.dna.uni_identity,i,i+1)]</a>"
					if ((i % max_line_len) == 0)
						temp_html += "</div><div class='clearBoth'>"
					if((i % DNA_BLOCK_SIZE) == 0 && i < len)
						temp_html += "<div class='dnaBlockNumber'>[(i / DNA_BLOCK_SIZE) + 1]</div>"
			else
				temp_html += "----"
			temp_html += "</div></div></div><br>"

			temp_html += "<div class='line'><div class='statusLabel'>Structural Enzymes:</div><div class='statusValue'><div class='clearBoth'>"
			if(viable_occupant)
				temp_html += "<div class='dnaBlockNumber'>1</div>"
				var/len = length(viable_occupant.dna.struc_enzymes)
				for(var/i=1, i<=len, i++)
					temp_html += "<a class='dnaBlock' href='?src=\ref[src];task=pulsese;num=[i];'>[copytext(viable_occupant.dna.struc_enzymes,i,i+1)]</a>"
					if ((i % max_line_len) == 0)
						temp_html += "</div><div class='clearBoth'>"
					if((i % DNA_BLOCK_SIZE) == 0 && i < len)
						temp_html += "<div class='dnaBlockNumber'>[(i / DNA_BLOCK_SIZE) + 1]</div>"
			else
				temp_html += "----"
			temp_html += "</div></div></div>"

	popup.set_content(temp_html)
	popup.open()


/obj/machinery/computer/scan_consolenew/Topic(href, href_list)
	if(..())
		return
	if(!isturf(usr.loc))
		return
	if(!( (isturf(loc) && in_range(src, usr)) || istype(usr, /mob/living/silicon) ))
		return
	if(current_screen == "working")
		return

	add_fingerprint(usr)
	usr.set_machine(src)

	var/mob/living/carbon/viable_occupant
	if(connected)
		viable_occupant = connected.occupant
		if(!istype(viable_occupant) || !viable_occupant.dna || (NOCLONE in viable_occupant.mutations))
			viable_occupant = null

	//Basic Tasks///////////////////////////////////////////
	var/num = round(text2num(href_list["num"]))
	var/last_change
	switch(href_list["task"])
		if("togglelock")
			if(connected)	connected.locked = !connected.locked
		if("toggleopen")
			if(connected)	connected.toggle_open(usr)
		if("setduration")
			if(!num)
				num = round(input(usr, "Choose pulse duration:", "Input an Integer", null) as num|null)
			if(num)
				radduration = Wrap(num, 1, RADIATION_DURATION_MAX+1)
		if("setstrength")
			if(!num)
				num = round(input(usr, "Choose pulse strength:", "Input an Integer", null) as num|null)
			if(num)
				radstrength = Wrap(num, 1, RADIATION_STRENGTH_MAX+1)
		if("screen")
			current_screen = href_list["text"]
		if("rejuv")
			if(viable_occupant && viable_occupant.reagents)
				var/epinephrine_amount = viable_occupant.reagents.get_reagent_amount("epinephrine")
				var/can_add = max(min(REJUVENATORS_MAX - epinephrine_amount, REJUVENATORS_INJECT), 0)
				viable_occupant.reagents.add_reagent("epinephrine", can_add)
		if("setbufferlabel")
			var/text = sanitize(input(usr, "Input a new label:", "Input an Text", null) as text|null)
			if(num && text)
				num = Clamp(num, 1, NUMBER_OF_BUFFERS)
				var/list/buffer_slot = buffer[num]
				if(istype(buffer_slot))
					buffer_slot["label"] = text
		if("setbuffer")
			if(num && viable_occupant)
				num = Clamp(num, 1, NUMBER_OF_BUFFERS)
				buffer[num] = list(
					"label"="Buffer[num]:[viable_occupant.real_name]",
					"UI"=viable_occupant.dna.uni_identity,
					"SE"=viable_occupant.dna.struc_enzymes,
					"UE"=viable_occupant.dna.unique_enzymes,
					"name"=viable_occupant.real_name,
					"blood_type"=viable_occupant.dna.blood_type
					)
		if("clearbuffer")
			if(num)
				num = Clamp(num, 1, NUMBER_OF_BUFFERS)
				var/list/buffer_slot = buffer[num]
				if(istype(buffer_slot))
					buffer_slot.Cut()
		if("transferbuffer")
			if(num && viable_occupant)
				num = Clamp(num, 1, NUMBER_OF_BUFFERS)
				var/list/buffer_slot = buffer[num]
				if(istype(buffer_slot))                                                                                  //15 and 40 are just magic numbers that were here before so i didnt touch them, they are initial boundaries of damage
					viable_occupant.radiation += rand(15/(connected.damage_coeff ** 2),40/(connected.damage_coeff ** 2)) //Each laser level reduces damage by lvl^2, so no effect on 1 lvl, 4 times less damage on 2 and 9 times less damage on 3
					switch(href_list["text"])                                                                            //Numbers are this high because other way upgrading laser is just not worth the hassle, and i cant think of anything better to inmrove
						if("se")
							if(buffer_slot["SE"])
								viable_occupant.dna.struc_enzymes = buffer_slot["SE"]
								domutcheck(viable_occupant)
						if("ui")
							if(buffer_slot["UI"])
								viable_occupant.dna.uni_identity = buffer_slot["UI"]
								updateappearance(viable_occupant)
						else
							if(buffer_slot["name"] && buffer_slot["UE"] && buffer_slot["blood_type"])
								viable_occupant.real_name = buffer_slot["name"]
								viable_occupant.name = buffer_slot["name"]
								viable_occupant.dna.unique_enzymes = buffer_slot["UE"]
								viable_occupant.dna.blood_type = buffer_slot["blood_type"]
								updateappearance(viable_occupant)
		if("injector")
			if(num && injectorready)
				num = Clamp(num, 1, NUMBER_OF_BUFFERS)
				var/list/buffer_slot = buffer[num]
				if(istype(buffer_slot))
					var/obj/item/weapon/dnainjector/I
					switch(href_list["text"])
						if("se")
							if(buffer_slot["SE"])
								I = new /obj/item/weapon/dnainjector(loc)
								for(var/datum/mutation/human/HM in good_mutations + bad_mutations + not_good_mutations)
									if(HM.check_block_string(buffer_slot["SE"]))
										if(prob(HM.get_chance))
											I.add_mutations.Add(HM)
									else
										I.remove_mutations.Add(HM)
								I.damage_coeff  = connected.damage_coeff
						if("ui")
							if(buffer_slot["UI"])
								I = new /obj/item/weapon/dnainjector(loc)
								I.fields = list("UI"=buffer_slot["UI"])
								I.damage_coeff = connected.damage_coeff
						else
							if(buffer_slot["name"] && buffer_slot["UE"] && buffer_slot["blood_type"])
								I = new /obj/item/weapon/dnainjector(loc)
								I.fields = list("name"=buffer_slot["name"], "UE"=buffer_slot["UE"], "blood_type"=buffer_slot["blood_type"])
								I.damage_coeff  = connected.damage_coeff
					if(I)
						injectorready = 0
						spawn(INJECTOR_TIMEOUT)
							injectorready = 1
		if("loaddisk")
			if(num && diskette && diskette.fields)
				num = Clamp(num, 1, NUMBER_OF_BUFFERS)
				buffer[num] = diskette.fields.Copy()
		if("savedisk")
			if(num && diskette && !diskette.read_only)
				num = Clamp(num, 1, NUMBER_OF_BUFFERS)
				var/list/buffer_slot = buffer[num]
				if(istype(buffer_slot))
					diskette.name = "data disk \[[buffer_slot["label"]]\]"
					diskette.fields = buffer_slot.Copy()
		if("ejectdisk")
			if(diskette)
				diskette.loc = get_turf(src)
				diskette = null
		if("pulseui","pulsese")
			if(num && viable_occupant && connected && viable_occupant.stat != DEAD)
				radduration = Wrap(radduration, 1, RADIATION_DURATION_MAX+1)
				radstrength = Wrap(radstrength, 1, RADIATION_STRENGTH_MAX+1)

				var/locked_state = connected.locked
				connected.locked = 1

				current_screen = "working"
				ShowInterface(usr)

				sleep(radduration*10)
				current_screen = "mainmenu"

				if(viable_occupant && connected && connected.occupant==viable_occupant)
					viable_occupant.radiation += (RADIATION_IRRADIATION_MULTIPLIER*radduration*radstrength)/(connected.damage_coeff ** 2) //Read comment in "transferbuffer" section above for explanation
					switch(href_list["task"])                                                                                             //Same thing as there but values are even lower, on best part they are about 0.0*, effectively no damage
						if("pulseui")
							var/len = length(viable_occupant.dna.uni_identity)
							num = Wrap(num, 1, len+1)
							num = randomize_radiation_accuracy(num, radduration + (connected.precision_coeff ** 2), len) //Each manipulator level above 1 makes randomization as accurate as selected time + manipulator lvl^2
                                                                                                                         //Value is this high for the same reason as with laser - not worth the hassle of upgrading if the bonus is low
							var/block = round((num-1)/DNA_BLOCK_SIZE)+1
							var/subblock = num - block*DNA_BLOCK_SIZE
							last_change = "UI #[block]-[subblock]; "

							var/hex = copytext(viable_occupant.dna.uni_identity, num, num+1)
							last_change += "[hex]"
							hex = scramble(hex, radstrength, radduration)
							last_change += "->[hex]"

							viable_occupant.dna.uni_identity = copytext(viable_occupant.dna.uni_identity, 1, num) + hex + copytext(viable_occupant.dna.uni_identity, num+1, 0)
							updateappearance(viable_occupant)
						if("pulsese")
							var/len = length(viable_occupant.dna.struc_enzymes)
							num = Wrap(num, 1, len+1)
							num = randomize_radiation_accuracy(num, radduration + (connected.precision_coeff ** 2), len)

							var/block = round((num-1)/DNA_BLOCK_SIZE)+1
							var/subblock = num - block*DNA_BLOCK_SIZE
							last_change = "SE #[block]-[subblock]; "

							var/hex = copytext(viable_occupant.dna.struc_enzymes, num, num+1)
							last_change += "[hex]"
							hex = scramble(hex, radstrength, radduration)
							last_change += "->[hex]"

							viable_occupant.dna.struc_enzymes = copytext(viable_occupant.dna.struc_enzymes, 1, num) + hex + copytext(viable_occupant.dna.struc_enzymes, num+1, 0)
							domutcheck(viable_occupant)
				else
					current_screen = "mainmenu"

				if(connected)
					connected.locked = locked_state

	ShowInterface(usr,last_change)


/////////////////////////// DNA MACHINES
#undef INJECTOR_TIMEOUT
#undef REJUVENATORS_INJECT
#undef REJUVENATORS_MAX
#undef NUMBER_OF_BUFFERS

#undef RADIATION_STRENGTH_MAX
#undef RADIATION_STRENGTH_MULTIPLIER

#undef RADIATION_DURATION_MAX
#undef RADIATION_ACCURACY_MULTIPLIER

#undef RADIATION_IRRADIATION_MULTIPLIER

//#undef BAD_MUTATION_DIFFICULTY
//#undef GOOD_MUTATION_DIFFICULTY
//#undef OP_MUTATION_DIFFICULTY

//value in range 1 to values. values must be greater than 0
//all arguments assumed to be positive integers
proc/construct_block(value, values, blocksize=DNA_BLOCK_SIZE)
	var/width = round((16**blocksize)/values)
	if(value < 1)
		value = 1
	value = (value * width) - rand(1,width)
	return num2hex(value, blocksize)

//value is hex
proc/deconstruct_block(value, values, blocksize=DNA_BLOCK_SIZE)
	var/width = round((16**blocksize)/values)
	value = round(hex2num(value) / width) + 1
	if(value > values)
		value = values
	return value


/datum/dna/proc/is_same_as(var/datum/dna/D)
	if(uni_identity == D.uni_identity && struc_enzymes == D.struc_enzymes && real_name == D.real_name)
		if(species == D.species && mutant_color == D.mutant_color && blood_type == D.blood_type)
			return 1
	return 0

