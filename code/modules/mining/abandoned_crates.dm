//Originally coded by ISaidNo, later modified by Kelenius. Ported from Baystation12.

/obj/structure/closet/crate/secure/loot
	name = "abandoned crate"
	desc = "What could be inside?"
	icon_state = "securecrate"
	integrity_failure = 0 //no breaking open the crate
	var/code = null
	var/lastattempt = null
	var/attempts = 10
	var/codelen = 4
	tamperproof = 90

/obj/structure/closet/crate/secure/loot/Initialize()
	. = ..()
	var/list/digits = list("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	code = ""
	for(var/i = 0, i < codelen, i++)
		var/dig = pick(digits)
		code += dig
		digits -= dig  //there are never matching digits in the answer
/*
HOW TO DO PROBABILITY WITH PICK: pick(P;Val) where P is the weight (think of is as if there are "P" identical entries, where P is a number
Note: default internal P is 100. So if you don't bother adding a P to every argument then to get something twice as much you need to use 200.
1: you can also embed pick() in itself (with or with out numbers) to create a secondary pool of items as a result
2: use list() for multiple items bundled together as a possible result
3: alternatively use list() with an associated value to generate multiple copies. example: list(/obj/=10) = 10 copies.of /obj
*/
	var/loot = pick(
	5;list(/obj/item/reagent_containers/food/drinks/bottle/rum,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/deus,
		/obj/item/reagent_containers/food/drinks/bottle/whiskey,
		/obj/item/lighter),
	5;list(/obj/item/bedsheet,
		/obj/item/kitchen/knife,
		/obj/item/wirecutters,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/hatchet,
		/obj/item/crowbar),
	5;/obj/item/reagent_containers/glass/beaker/bluespace,
	5;list(/obj/item/stack/ore/diamond=10),
	5;list(/obj/item/poster/random_contraband=5),
	5;list(/obj/item/reagent_containers/glass/beaker/noreact=3),
	5;/obj/item/seeds/firelemon,
	5;/obj/item/melee/baton,
	5;list(/obj/item/clothing/under/shorts/red,
		/obj/item/clothing/under/shorts/blue),
	5;list(/obj/item/clothing/under/chameleon,
		/obj/item/clothing/neck/tie/horrible=7),
	2;/obj/item/melee/classic_baton,
	2;/obj/item/toy/balloon,
	2;pick(subtypesof(/obj/item/toy/prize)),
	2;/obj/item/toy/syndicateballoon,
	2;list(/obj/item/borg/upgrade/modkit/aoe/mobs,
		/obj/item/clothing/suit/space,
		/obj/item/clothing/head/helmet/space),
	2;list(/obj/item/clothing/head/kitty=5,
		/obj/item/clothing/neck/petcollar=5),
	//use list to store an associated value to create multiple & embed pick inside to choose from a selection
	2;list(pick(//2% chance to get coins
		3;/obj/item/coin/silver,//30%
		3;/obj/item/coin/iron,//30%
		1;/obj/item/coin/gold,//10%
		1;/obj/item/coin/diamond,//10%
		1;/obj/item/coin/plasma,//10%
		1;/obj/item/coin/uranium//10%
		)=rand(4,7)),//make 4 to 7 of them
	2;list(/obj/item/clothing/suit/ianshirt,
		/obj/item/clothing/suit/hooded/ian_costume),
	2;list(pick((subtypesof(/obj/item/stock_parts) - /obj/item/stock_parts/subspace))=rand(4,7)),
	2;list(/obj/item/stack/ore/bluespace_crystal=5),
	2;/obj/item/pickaxe/drill,
	2;/obj/item/pickaxe/drill/jackhammer,
	2;/obj/item/pickaxe/diamond,
	2;/obj/item/pickaxe/drill/diamonddrill,
	2;list(/obj/item/cane,
		/obj/item/clothing/head/collectable/tophat),
	2;/obj/item/gun/energy/plasmacutter,
	2;/obj/item/toy/katana,
	2;/obj/item/defibrillator/compact,
	1;/obj/item/weed_extract,
	1;/obj/item/organ/brain,
	1;/obj/item/organ/brain/alien,
	1;/obj/item/organ/heart,
	1;/obj/item/device/soulstone/anybody,
	1;/obj/item/katana,
	1;/obj/item/dnainjector/xraymut,
	1;list(/obj/item/storage/backpack/clown,
		/obj/item/clothing/under/rank/clown,
		/obj/item/clothing/shoes/clown_shoes,
		/obj/item/device/pda/clown,
		/obj/item/clothing/mask/gas/clown_hat,
		/obj/item/bikehorn,
		/obj/item/toy/crayon/rainbow,
		/obj/item/reagent_containers/spray/waterflower),
	1;list(/obj/item/clothing/under/rank/mime,
		/obj/item/clothing/shoes/sneakers/black,
		/obj/item/device/pda/mime,
		/obj/item/clothing/gloves/color/white,
		/obj/item/clothing/mask/gas/mime,
		/obj/item/clothing/head/beret,
		/obj/item/clothing/suit/suspenders,
		/obj/item/toy/crayon/mime,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing),
	1;/obj/item/hand_tele,
	1;list(/obj/item/clothing/mask/balaclava,
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/ammo_box/magazine/m10mm),
	1;/obj/item/katana/cursed,
	1;list(/obj/item/storage/belt/champion,
		/obj/item/clothing/mask/luchador),
	1;/obj/item/clothing/head/bearpelt)

	pathorlist_to_loot(loot)

/obj/structure/closet/crate/secure/loot/attack_hand(mob/user)
	if(locked)
		to_chat(user, "<span class='notice'>The crate is locked with a Deca-code lock.</span>")
		var/input = input(usr, "Enter [codelen] digits. All digits must be unique.", "Deca-Code Lock", "") as text
		if(user.canUseTopic(src, 1))
			var/list/sanitised = list()
			var/sanitycheck = 1
			for(var/i=1,i<=length(input),i++) //put the guess into a list
				sanitised += text2num(copytext(input,i,i+1))
			for(var/i=1,i<=(length(input)-1),i++) //compare each digit in the guess to all those following it
				for(var/j=(i+1),j<=length(input),j++)
					if(sanitised[i] == sanitised[j])
						sanitycheck = null //if a digit is repeated, reject the input
			if (input == code)
				to_chat(user, "<span class='notice'>The crate unlocks!</span>")
				locked = FALSE
				cut_overlays()
				add_overlay("securecrateg")
			else if (input == null || sanitycheck == null || length(input) != codelen)
				to_chat(user, "<span class='notice'>You leave the crate alone.</span>")
			else
				to_chat(user, "<span class='warning'>A red light flashes.</span>")
				lastattempt = input
				attempts--
				if(attempts == 0)
					boom(user)
	else
		return ..()

/obj/structure/closet/crate/secure/loot/AltClick(mob/living/user)
	if(!user.canUseTopic(src))
		return
	attack_hand(user) //this helps you not blow up so easily by overriding unlocking which results in an immediate boom.

/obj/structure/closet/crate/secure/loot/attackby(obj/item/W, mob/user)
	if(locked)
		if(istype(W, /obj/item/card/emag))
			boom(user)
			return
		else if(istype(W, /obj/item/device/multitool))
			to_chat(user, "<span class='notice'>DECA-CODE LOCK REPORT:</span>")
			if(attempts == 1)
				to_chat(user, "<span class='warning'>* Anti-Tamper Bomb will activate on next failed access attempt.</span>")
			else
				to_chat(user, "<span class='notice'>* Anti-Tamper Bomb will activate after [src.attempts] failed access attempts.</span>")
			if(lastattempt != null)
				var/list/guess = list()
				var/list/answer = list()
				var/bulls = 0
				var/cows = 0
				for(var/i=1,i<=length(lastattempt),i++)
					guess += text2num(copytext(lastattempt,i,i+1))
				for(var/i=1,i<=length(lastattempt),i++)
					answer += text2num(copytext(code,i,i+1))
				for(var/i = 1, i < codelen + 1, i++) // Go through list and count matches
					if( answer.Find(guess[i],1,codelen+1))
						++cows
					if( answer[i] == guess[i])
						++bulls
						--cows

				to_chat(user, "<span class='notice'>Last code attempt, [lastattempt], had [bulls] correct digits at correct positions and [cows] correct digits at incorrect positions.</span>")
			return
	return ..()

/obj/structure/closet/crate/secure/loot/togglelock(mob/user)
	if(locked)
		boom(user)
	else
		..()

/obj/structure/closet/crate/secure/loot/deconstruct(disassembled = TRUE)
	boom()
