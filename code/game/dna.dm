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
	var/mutantrace = null  //The type of mutant race the player is if applicable (i.e. potato-man)
	var/real_name //Stores the real name of the person who originally got this dna datum. Used primarely for changelings,

/datum/dna/New()
	if(!blood_type)	blood_type = random_blood_type()

/datum/dna/proc/generate_uni_identity(mob/living/carbon/character)
	. = ""
	var/list/L = new /list(DNA_UNI_IDENTITY_BLOCKS)
	if(istype(character))
		L[DNA_GENDER_BLOCK] = construct_block((character.gender!=MALE)+1, 2)
		if(istype(character, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = character
			L[DNA_HAIR_STYLE_BLOCK] = construct_block(hair_styles_list.Find(H.hair_style), hair_styles_list.len)
			L[DNA_HAIR_COLOR_BLOCK] = sanitize_hexcolor(H.hair_color)
			L[DNA_FACIAL_HAIR_STYLE_BLOCK] = construct_block(hair_styles_list.Find(H.facial_hair_style), facial_hair_styles_list.len)
			L[DNA_FACIAL_HAIR_COLOR_BLOCK] = sanitize_hexcolor(H.facial_hair_color)
			L[DNA_SKIN_TONE_BLOCK] = construct_block(skin_tones.Find(H.skin_tone), skin_tones.len)
			L[DNA_EYE_COLOR_BLOCK] = sanitize_hexcolor(H.eye_color)

	for(var/i=1, i<=DNA_UNI_IDENTITY_BLOCKS, i++)
		if(L[i])	. += L[i]
		else		. += random_string(DNA_BLOCK_SIZE,hex_characters)
	return .

/datum/dna/proc/generate_struc_enzymes(mob/living/carbon/character)
	var/list/L = list("0","1","2","3","4","5","6")
	. = ""
	for(var/i=1, i<=DNA_STRUC_ENZYMES_BLOCKS, i++)
		if(i == RACEBLOCK)
			. += construct_block(istype(character,/mob/living/carbon/monkey)+1, 2)
		else
			. += random_string(DNA_BLOCK_SIZE, L)
	return .

/datum/dna/proc/generate_unique_enzymes(mob/living/carbon/character)
	. = ""
	if(istype(character))
		real_name = character.real_name
		. += md5(character.real_name)
		reg_dna[.] = real_name
	else
		. += repeat_string(DNA_UNIQUE_ENZYMES_LEN, "0")
	return .

/proc/hardset_dna(mob/living/carbon/owner, ui, se, real_name, mutantrace, blood_type)
	if(!istype(owner, /mob/living/carbon/monkey) && !istype(owner, /mob/living/carbon/human))
		return
	if(!owner.dna)
		owner.dna = new /datum/dna()

	if(real_name)
		owner.real_name = real_name
		owner.dna.generate_unique_enzymes(owner)

	if(blood_type)
		owner.dna.blood_type = blood_type

	if(ui)
		owner.dna.uni_identity = ui
		updateappearance(owner)

	var/update_mutantrace = (mutantrace != owner.dna.mutantrace)
	owner.dna.mutantrace = mutantrace
	if(update_mutantrace && istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner
		H.update_body()
		H.update_hair()

	if(se)
		owner.dna.struc_enzymes = se
		domutcheck(owner)

	check_dna_integrity(owner)
	return owner.dna

/proc/check_dna_integrity(mob/living/carbon/character)
	if(!(istype(character, /mob/living/carbon/human) || istype(character, /mob/living/carbon/monkey))) //Evict xenos from carbon 2012
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
		character.dna = new /datum/dna()
	if(blood_type)
		character.dna.blood_type = blood_type
		character.dna.real_name = character.real_name
	character.dna.uni_identity = character.dna.generate_uni_identity(character)
	character.dna.struc_enzymes = character.dna.generate_struc_enzymes(character)
	character.dna.unique_enzymes = character.dna.generate_unique_enzymes(character)
	return character.dna

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

/proc/randmutb(mob/living/carbon/M)
	if(!check_dna_integrity(M))	return
	var/num
	var/newdna
	num = pick(bad_se_blocks)
	newdna = setblock(M.dna.struc_enzymes, num, construct_block(2,2))
	M.dna.struc_enzymes = newdna
	return

/proc/randmutg(mob/living/carbon/M)
	if(!check_dna_integrity(M))	return
	var/num
	var/newdna
	num = pick(good_se_blocks | op_se_blocks)
	newdna = setblock(M.dna.struc_enzymes, num, construct_block(2,2))
	M.dna.struc_enzymes = newdna
	return

/proc/randmuti(mob/living/carbon/M)
	if(!check_dna_integrity(M))	return
	var/num
	var/newdna
	num = rand(1, DNA_STRUC_ENZYMES_BLOCKS)
	newdna = setblock(M.dna.uni_identity, num, random_string(DNA_BLOCK_SIZE, hex_characters))
	M.dna.uni_identity = newdna
	return

/proc/scramble_dna(mob/living/carbon/M, ui=FALSE, se=FALSE, probability)
	if(!check_dna_integrity(M))
		return 0
	if(se)
		for(var/i=1, i<=DNA_STRUC_ENZYMES_BLOCKS, i++)
			if(prob(probability))
				M.dna.struc_enzymes = setblock(M.dna.struc_enzymes, i, random_string(DNA_BLOCK_SIZE, hex_characters))
		domutcheck(M, null)
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

/proc/domutcheck(mob/living/carbon/M, connected, inj)
	if(!check_dna_integrity(M))
		return 0

	M.disabilities = 0
	M.sdisabilities = 0
	M.mutations.Cut()

	M.see_in_dark = initial(M.see_in_dark)
	M.see_invisible = initial(M.see_invisible)

	var/list/blocks = new /list(DNA_STRUC_ENZYMES_BLOCKS) //on-off status for each block
	for(var/i in bad_se_blocks)		//bad mutations
		blocks[i] = (deconstruct_block(getblock(M.dna.struc_enzymes, i), BAD_MUTATION_DIFFICULTY) == BAD_MUTATION_DIFFICULTY)
	blocks[RACEBLOCK] = (deconstruct_block(getblock(M.dna.struc_enzymes, RACEBLOCK), BAD_MUTATION_DIFFICULTY) == BAD_MUTATION_DIFFICULTY)
	for(var/i in good_se_blocks)	//good mutations
		blocks[i] = (deconstruct_block(getblock(M.dna.struc_enzymes, i), GOOD_MUTATION_DIFFICULTY) == GOOD_MUTATION_DIFFICULTY)
	for(var/i in op_se_blocks)		//Overpowered mutations...extra difficult to obtain
		blocks[i] = (deconstruct_block(getblock(M.dna.struc_enzymes, i), OP_MUTATION_DIFFICULTY) == OP_MUTATION_DIFFICULTY)

	if(blocks[NEARSIGHTEDBLOCK])
		M.disabilities |= NEARSIGHTED
		M << "\red Your eyes feel strange."
	if(blocks[EPILEPSYBLOCK])
		M.disabilities |= EPILEPSY
		M << "\red You get a headache."
	if(blocks[STRANGEBLOCK])
		M << "\red You feel strange."
		if(prob(95))
			if(prob(50))	randmutb(M)
			else			randmuti(M)
		else				randmutg(M)
	if(blocks[COUGHBLOCK])
		M.disabilities |= COUGHING
		M << "\red You start coughing."
	if(blocks[CLUMSYBLOCK])
		M << "\red You feel lightheaded."
		M.mutations |= CLUMSY
	if(blocks[TOURETTESBLOCK])
		M.disabilities |= TOURETTES
		M << "\red You twitch."
	if(blocks[NERVOUSBLOCK])
		M.disabilities |= NERVOUS
		M << "\red You feel nervous."
	if(blocks[DEAFBLOCK])
		M.sdisabilities |= DEAF
		M.ear_deaf = 1
		M << "\red You can't seem to hear anything..."
	if(blocks[BLINDBLOCK])
		M.sdisabilities |= BLIND
		M << "\red You can't seem to see anything."
	if(blocks[HULKBLOCK])
		if(inj || prob(10))
			M.mutations |= HULK
			M << "\blue Your muscles hurt."
	if(blocks[XRAYBLOCK])
		if(inj || prob(30))
			M.mutations |= XRAY
			M << "\blue The walls suddenly disappear."
			M.sight |= SEE_MOBS|SEE_OBJS|SEE_TURFS
			M.see_in_dark = 8
			M.see_invisible = SEE_INVISIBLE_LEVEL_TWO
	if(blocks[FIREBLOCK])
		if(inj || prob(30))
			M.mutations |= COLD_RESISTANCE
			M << "\blue Your body feels warm."
	if(blocks[TELEBLOCK])
		if(inj || prob(25))
			M.mutations |= TK
			M << "\blue You feel smarter."


	/* If you want the new mutations to work, UNCOMMENT THIS.
	if(istype(M, /mob/living/carbon))
		for (var/datum/mutations/mut in global_mutations)
			mut.check_mutation(M)
	*/

//////////////////////////////////////////////////////////// Monkey Block
	if(blocks[RACEBLOCK])
		if(istype(M, /mob/living/carbon/human))	// human > monkey
			var/mob/living/carbon/monkey/O = M.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPDAMAGE | TR_KEEPVIRUS)
			if(connected) //inside dna thing
				var/obj/machinery/dna_scannernew/C = connected
				O.loc = C
				C.occupant = O
				connected = null
			return 1
	else
		if(istype(M, /mob/living/carbon/monkey))	// monkey > human,
			var/mob/living/carbon/human/O = M.humanize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPDAMAGE | TR_KEEPVIRUS)
			if(O && connected) //inside dna thing
				var/obj/machinery/dna_scannernew/C = connected
				O.loc = C
				C.occupant = O
				connected = null
			return 1
//////////////////////////////////////////////////////////// Monkey Block
	if(M)
		M.update_icon = 1	//queue a full icon update at next life() call
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
	var/open = 0
	var/mob/occupant = null
	anchored = 1
	use_power = 1
	idle_power_usage = 50
	active_power_usage = 300

/obj/machinery/dna_scannernew/New()
	..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/clonescanner,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/cable_coil,
		/obj/item/weapon/cable_coil
		)
	RefreshParts()

/obj/machinery/dna_scannernew/proc/toggle_open()
	if(open)	return close()
	else		return open()

/obj/machinery/dna_scannernew/container_resist()
	var/mob/living/user = usr
	var/breakout_time = 2
	if(open || !locked)	//Open and unlocked, no need to escape
		open = 1
		return
	user.next_move = world.time + 100
	user.last_special = world.time + 100
	user << "<span class='notice'>You lean on the back of [src] and start pushing the door open. (this will take about [breakout_time] minutes.)</span>"
	for(var/mob/O in viewers(src))
		O << "<span class='warning'>You hear a metallic creaking from [src]!</span>"

	if(do_after(user,(breakout_time*60*10))) //minutes * 60seconds * 10deciseconds
		if(!user || user.stat != CONSCIOUS || user.loc != src || open || !locked)
			return

		locked = 0
		visible_message("<span class='danger'>[user] successfully broke out of [src]!</span>")
		user << "<span class='notice'>You successfully break out of [src]!</span>"

		open()

/obj/machinery/dna_scannernew/proc/close()
	if(open)
		open = 0
		density = 1
		for(var/mob/living/carbon/C in loc)
			if(C.buckled)	continue
			if(C.client)
				C.client.perspective = EYE_PERSPECTIVE
				C.client.eye = src
			occupant = C
			C.loc = src
			C.stop_pulling()
			break
		icon_state = initial(icon_state) + (occupant ? "_occupied" : "")

		// search for ghosts, if the corpse is empty and the scanner is connected to a cloner
		if(occupant)
			if(locate(/obj/machinery/computer/cloning, get_step(src, NORTH)) \
				|| locate(/obj/machinery/computer/cloning, get_step(src, SOUTH)) \
				|| locate(/obj/machinery/computer/cloning, get_step(src, EAST)) \
				|| locate(/obj/machinery/computer/cloning, get_step(src, WEST)))

				if(!occupant.key && occupant.mind)
					for(var/mob/dead/observer/ghost in player_list)
						if(ghost.mind == occupant.mind)
							if(ghost.can_reenter_corpse)
								ghost << "<b><font color = #330033><font size = 3>Your corpse has been placed into a cloning scanner. Return to your body if you want to be resurrected/cloned!</b> (Verbs -> Ghost -> Re-enter corpse)</font color>"
							break

		return 1

/obj/machinery/dna_scannernew/proc/open()
	if(!open)
		if(locked)
			usr << "<span class='notice'>The bolts are locked down, securing the door shut.</span>"
			return
		var/turf/T = get_turf(src)
		if(T)
			open = 1
			density = 0
			T.contents += contents
			if(occupant)
				if(occupant.client)
					occupant.client.eye = occupant
					occupant.client.perspective = MOB_PERSPECTIVE
				occupant = null
			icon_state = "[initial(icon_state)]_open"
		return 1

/obj/machinery/dna_scannernew/relaymove(mob/user as mob)
	if(user.stat)
		return
	open()
	return

/obj/machinery/dna_scannernew/attackby(obj/item/weapon/grab/G, mob/user)
	if(!istype(G, /obj/item/weapon/grab) || !ismob(G.affecting))
		return
	if(!open)
		user << "<span class='notice'>Open the scanner first.</span>"
		return
	var/mob/M = G.affecting
	M.loc = loc
	user.stop_pulling()
	del(G)

/obj/machinery/dna_scannernew/attack_hand(mob/user)
	if(..())	return
	toggle_open()
	add_fingerprint(user)



/obj/machinery/dna_scannernew/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A in src)
				A.loc = loc
				A.ex_act(severity)
			del(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/A in src)
					A.loc = loc
					A.ex_act(severity)
				del(src)
				return
		if(3.0)
			if(prob(25))
				for(var/atom/movable/A in src)
					A.loc = loc
					A.ex_act(severity)
				del(src)
				return
		else
	return


/obj/machinery/dna_scannernew/blob_act()
	if(prob(75))
		for(var/atom/movable/A in contents)
			A.loc = loc
		del(src)


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

/obj/machinery/computer/scan_consolenew/attackby(obj/item/I as obj, mob/user as mob)
	if (istype(I, /obj/item/weapon/disk/data)) //INSERT SOME DISKETTES
		if (!src.diskette)
			user.drop_item()
			I.loc = src
			src.diskette = I
			user << "You insert [I]."
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
	if(connected)
		if(connected.occupant)	//set occupant_status message
			viable_occupant = connected.occupant
			if(check_dna_integrity(viable_occupant) && !(NOCLONE in viable_occupant.mutations))	//occupent is viable for dna modification
				occupant_status += "[viable_occupant.name] => "
				switch(viable_occupant.stat)
					if(CONSCIOUS)	occupant_status += "<span class='good'>Conscious</span>"
					if(UNCONSCIOUS)	occupant_status += "<span class='average'>Unconscious</span>"
					else			occupant_status += "<span class='bad'>DEAD - Cannot Operate</span>"
				occupant_status += "</div></div>"
				occupant_status += "<div class='line'><div class='statusLabel'>Health:</div><div class='progressBar'><div style='width: [viable_occupant.health]%;' class='progressFill good'></div></div><div class='statusValue'>[viable_occupant.health]%</div></div>"
				occupant_status += "<div class='line'><div class='statusLabel'>Radiation Level:</div><div class='progressBar'><div style='width: [viable_occupant.radiation]%;' class='progressFill bad'></div></div><div class='statusValue'>[viable_occupant.radiation]%</div></div>"
				var/rejuvenators = viable_occupant.reagents.get_reagent_amount("inaprovaline")
				occupant_status += "<div class='line'><div class='statusLabel'>Rejuvenators:</div><div class='progressBar'><div style='width: [round((rejuvenators / REJUVENATORS_MAX) * 100)]%;' class='progressFill highlight'></div></div><div class='statusValue'>[rejuvenators] units</div></div>"
				occupant_status += "<div class='line'><div class='statusLabel'>Unique Enzymes :</div><div class='statusValue'><span class='highlight'>[viable_occupant.dna.unique_enzymes]</span></div></div>"
				occupant_status += "<div class='line'><div class='statusLabel'>Last Operation:</div><div class='statusValue'>[last_change ? last_change : "----"]</div></div>"
			else
				viable_occupant = null
				occupant_status += "<span class='bad'>Invalid DNA structure</span></div></div>"
		else
			occupant_status += "<span class='bad'>No subject detected</span></div></div>"

		if(connected.open)
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
		buttons += " <a href='?src=\ref[src];task=toggleopen;'>[connected.open ? "Close" : "Open"] Scanner</a> "
		if (connected.open)
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
			if(connected)	connected.toggle_open()
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
				var/inaprovaline_amount = viable_occupant.reagents.get_reagent_amount("inaprovaline")
				var/can_add = max(min(REJUVENATORS_MAX - inaprovaline_amount, REJUVENATORS_INJECT), 0)
				viable_occupant.reagents.add_reagent("inaprovaline", can_add)
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
				if(istype(buffer_slot))
					viable_occupant.radiation += rand(15,40)
					switch(href_list["text"])
						if("se")
							if(buffer_slot["SE"])
								viable_occupant.dna.struc_enzymes = buffer_slot["SE"]
								domutcheck(viable_occupant, connected)
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
								I.fields = list("SE"=buffer_slot["SE"])
						if("ui")
							if(buffer_slot["UI"])
								I = new /obj/item/weapon/dnainjector(loc)
								I.fields = list("UI"=buffer_slot["UI"])
						else
							if(buffer_slot["name"] && buffer_slot["UE"] && buffer_slot["blood_type"])
								I = new /obj/item/weapon/dnainjector(loc)
								I.fields = list("name"=buffer_slot["name"], "UE"=buffer_slot["UE"], "blood_type"=buffer_slot["blood_type"])
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
					viable_occupant.radiation += RADIATION_IRRADIATION_MULTIPLIER*radduration*radstrength
					switch(href_list["task"])
						if("pulseui")
							var/len = length(viable_occupant.dna.uni_identity)
							num = Wrap(num, 1, len+1)
							num = randomize_radiation_accuracy(num, radduration, len)

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
							num = randomize_radiation_accuracy(num, radduration, len)

							var/block = round((num-1)/DNA_BLOCK_SIZE)+1
							var/subblock = num - block*DNA_BLOCK_SIZE
							last_change = "SE #[block]-[subblock]; "

							var/hex = copytext(viable_occupant.dna.struc_enzymes, num, num+1)
							last_change += "[hex]"
							hex = scramble(hex, radstrength, radduration)
							last_change += "->[hex]"

							viable_occupant.dna.struc_enzymes = copytext(viable_occupant.dna.struc_enzymes, 1, num) + hex + copytext(viable_occupant.dna.struc_enzymes, num+1, 0)
							domutcheck(viable_occupant, connected)
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
