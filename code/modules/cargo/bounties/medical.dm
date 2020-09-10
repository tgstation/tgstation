/datum/bounty/item/medical/heart
	name = "Heart"
	description = "Commander Johnson is in critical condition after suffering yet another heart attack. Doctors say he needs a new heart fast. Ship one, pronto! We'll take a better cybernetic one, if need be."
	reward = 3000
	wanted_types = list(/obj/item/organ/heart, /obj/item/organ/heart/cybernetic/tier2, /obj/item/organ/heart/cybernetic/tier3)
	exclude_types = list(/obj/item/organ/heart/cybernetic)//Excluding tier 1s, no cheesing.

/datum/bounty/item/medical/lung
	name = "Lungs"
	description = "A recent explosion at Central Command has left multiple staff with punctured lungs. Ship spare lungs to be rewarded.  We'll take a better cybernetic one, if need be."
	reward = 10000
	required_count = 3
	wanted_types = list(/obj/item/organ/lungs, /obj/item/organ/lungs/cybernetic/tier2, /obj/item/organ/lungs/cybernetic/tier3)
	exclude_types = list(/obj/item/organ/lungs/cybernetic)//As above, for all printable organs.

/datum/bounty/item/medical/appendix
	name = "Appendix"
	description = "Chef Gibb of Central Command wants to prepare a meal using a very special delicacy: an appendix. If you ship one, he'll pay.  We'll take a better cybernetic one, if need be."
	reward = 5000 //there are no synthetic appendixes
	wanted_types = list(/obj/item/organ/appendix)

/datum/bounty/item/medical/ears
	name = "Ears"
	description = "Multiple staff at Station 12 have been left deaf due to unauthorized clowning. Ship them new ears. "
	reward = 10000
	required_count = 3
	wanted_types = list(/obj/item/organ/ears, /obj/item/organ/ears/cybernetic/upgraded)
	exclude_types = list(/obj/item/organ/ears/cybernetic)

/datum/bounty/item/medical/liver
	name = "Livers"
	description = "Multiple high-ranking CentCom diplomats have been hospitalized with liver failure after a recent meeting with Third Soviet Union ambassadors. Help us out, will you?"
	reward = 10000
	required_count = 3
	wanted_types = list(/obj/item/organ/liver, /obj/item/organ/liver/cybernetic/tier2, /obj/item/organ/liver/cybernetic/tier3)
	exclude_types = list(/obj/item/organ/liver/cybernetic)

/datum/bounty/item/medical/eye
	name = "Organic Eyes"
	description = "Station 5's Research Director Willem is requesting a few pairs of non-robotic eyes. Don't ask questions, just ship them."
	reward = 10000
	required_count = 3
	wanted_types = list(/obj/item/organ/eyes)
	exclude_types = list(/obj/item/organ/eyes/robotic)

/datum/bounty/item/medical/tongue
	name = "Tongues"
	description = "A recent attack by Mime extremists has left staff at Station 23 speechless. Ship some spare tongues."
	reward = 10000
	required_count = 3
	wanted_types = list(/obj/item/organ/tongue)

/datum/bounty/item/medical/lizard_tail
	name = "Lizard Tail"
	description = "The Wizard Federation has made off with Nanotrasen's supply of lizard tails. While CentCom is dealing with the wizards, can the station spare a tail of their own?"
	reward = 3000
	wanted_types = list(/obj/item/organ/tail/lizard)

/datum/bounty/item/medical/cat_tail
	name = "Cat Tail"
	description = "Central Command has run out of heavy duty pipe cleaners. Can you ship over a cat tail to help us out?"
	reward = 3000
	wanted_types = list(/obj/item/organ/tail/cat)

/datum/bounty/item/medical/chainsaw
	name = "Chainsaw"
	description = "A CMO at CentCom is having trouble operating on golems. She requests one chainsaw, please."
	reward = 2500
	wanted_types = list(/obj/item/chainsaw)

/datum/bounty/item/medical/tail_whip //Like the cat tail bounties, with more processing.
	name = "Nine Tails whip"
	description = "Commander Jackson is looking for a fine addition to her exotic weapons collection. She will reward you handsomely for either a Cat or Liz o' Nine Tails."
	reward = 4000
	wanted_types = list(/obj/item/melee/chainofcommand/tailwhip)

/datum/bounty/item/medical/surgerycomp
	name = "Surgery Computer"
	description = "After another freak bombing incident at our annual cheesefest at centcom, we have a massive stack of injured crew on our end. Please send us a fresh surgery computer, if at all possible."
	reward = 6000
	wanted_types = list(/obj/machinery/computer/operating)

/datum/bounty/item/medical/surgerytable
	name = "Operating Table"
	description = "After a recent influx of infected crew members recently, we've seen that masks just aren't cutting it alone. Silver Operating tables might just do the trick though, send us one to use."
	reward = 3000
	wanted_types = list(/obj/structure/table/optable)
