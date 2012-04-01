// Most variables are initalized to a semi-random value on creation, in /mob/living/Life() (file code\modules\mob\living\living.dm)

#define ORGASM_PLEASURE 200


/mob

	var/datum/sexuality/sexuality = new // All mobs have this, others may or may not be defined.

/datum/penis
	var/num = 1 // Assuming all penies on a mob are of equal length and girth.
	var/length =1
	var/girth = 1
	var/volume = 1 // Calculated on creation to be PI*(girth/2)*length
	var/glans_sensitivity = 5
	var/orgasmtime = 30
	var/cumamount = 50
	var/erect = 0
	var/list/coating = list()
	var/list/contents = list()  // Not strictly contents (Although I suppose sounding would go under here too) but more chastity stuff. Maybe sounding.
	var/location = null
	var/hasKnot = 0
	var/hasBarbs = 0
	var/ballSize = 1
	var/isStrapon = 0
	var/isRibbed = 0

/datum/penis/proc/erect()
	erect = 1
	return










/datum/vagina
	var/depth = 1
	var/opening_width = 1
	var/cervix_width =1
	var/vaginal_elasticity = 0.5
	var/cervix_elasticity = 0.1
	var/list/womb_contents = list()		//Solid things not including a baby. Used mostly for cervix penetration.
	var/list/womb_fluid_contents = list()
	var/datum/pregnancy/pregnancy = null
	var/clit_sensitivity = 5
	var/lubricated = 0
	var/list/contents = list()  // I was going to go with isOccupied, but what about double penetration in one hole?
	var/list/fluid_contents = list()
	var/list/outercontents = list() // Clips,  pericings and chastity stuff.
	var/isVirgin = 1

/datum/vagina/proc/impregnate(var/datum/fluid/cum/C)
	var/datum/pregnancy/P = new

	if(prob(50))
		P.species = src.type
	else
		P.species = C.species

	pregnancy = P

/datum/pregnancy
	var/species = null
	var/time = 0














/datum/breasts
	var/num = 2
	var/size = 5
	var/milkcontent = 0
	var/milking = 0
	var/list/contents = list()  // Not strictly contents, pericings and clips and such on the nipples, moreso.
	var/nipplesensitivity = 5


/datum/ass
	var/depth = 1
	var/anal_width = 1
	var/anal_elasticity = 0.5
	var/hasProstate = 0
	var/contents = list()
	var/isVirgin = 1


/datum/mouth // And throat.  May also be used for muzzle.
	var/deepthroating = 0 // If they can't breathe.   Also bypasses spit/swallow!
	var/list/contents = list()
	var/length = 1
	var/gagreflex = 10  // Going to make it so you can train this out of a mob.

















/datum/underwear
	var/contents = list()























/datum/sexuality
	var/gender = null // None, Male, Female, or Herm.  What naughtybits they have.  Defined again inside sexuality so that neuter-nouned mobs like Aliens can have naughtybits, and to also support gender-swapping!  Wizard spell?
					  // A gender of null means their sexuality is yet to be lazy-intialized.
	var/bladder = 20
	var/pleasure = 50
	var/isHairPullable = 1
	var/aggressive = 0
	var/collar = null

	var/datum/penis/penis = null
	var/datum/vagina/vagina = null
	var/datum/breasts/breasts = null
	var/datum/ass/ass = null
	var/datum/mouth/mouth = null
	var/datum/underwear/underwear = new

	var/flatchest = 1
	var/multicocked = 0
	var/multibreasts = 0 // For Jarsh.
	var/hastail = 0
	var/hashardtail = 0 // If true, can be used for fucking
	var/hasfur = 0

	var/sexualact = null
	var/reachingin = 0
	var/mob/living/initiatior = null
	var/mob/living/initiated = null		// Sorry, no orgies here.  Maybe later.

	var/showERPverbs = 0


/datum/sexuality/proc/resist()						// TODO:  Provide a specific resist message for every action, make it harder to resist some actions than others.
	if(sexualact)
		if(!aggressive)
			initiatior 	<< "\blue [usr] pulls away!"
			initiated 	<< "\blue [usr] pulls away!"
			usr.canmove = 1
			sexualact = null
		else
			if(prob(10))
				initiatior 	<< "\blue [usr] thrashes away!"
				initiated 	<< "\blue [usr] thrashes away!"
				usr.canmove = 1
				initiatior.sexuality.sexualact = null
				initiated.sexuality.sexualact = null
				aggressive = 0
				initiatior.AdjustWeakened(3)
			else
				initiatior 	<< "\blue [usr] tries to struggle away!"
				initiated 	<< "\blue [usr] tries to struggle away!"
	return

/datum/sexuality/proc/orgasm()
	while(sexualact)
		if(penis)
			if(penis.location)
				if(istype(penis.location, /datum/vagina))  								//TODO:  Add support for condoms.
					var/found = 0
					for(var/datum/fluid/cum/C in penis.location:womb_fluid_contents)
						if(C.creator == usr)
							C.amount += 5
							found = 1
							break
					if(!found)
						var/datum/fluid/cum/C = new
						C.amount = 5
						C.species = usr.type
						C.creator = usr
						if(istype(usr, /mob/living/carbon/))
							C.DNA = usr:dna
						penis.location:womb_fluid_contents += C
		if(prob(30))
			usr << "You finish orgasming."
			sexualact = null



		sleep(20)
	return

















/datum/fluid
	var/name = null
	var/desc = null
	var/viscosity = null
	var/colour = null
	var/texture = null
	var/taste = null
	var/warmpth = null
	var/amount = 0

/datum/fluid/urine
	name = "Urine"
	desc = "Golden yellow and musky."
	viscosity = 1
	colour = "Golden yellow."
	texture = "Water"
	taste = "Musky"
	warmpth = "Warm"
	amount = 5

/datum/fluid/cum
	name = "Semen"
	desc = "This really should be inside someone."
	viscosity = 1
	colour = "Milky white."
	texture = "Stringy"
	taste = "Pungent"
	warmpth = "Warm"
	amount = 5
	var/species = null
	var/creator = null
	var/datum/dna/DNA = null



/datum/fluid/proc/leak(var/amount = 1, )
	var/datum/fluid/newfluid = new src.type(src)
	var/transferamount = 0

	if((src) && (newfluid))
		for(var/V in src.vars)
			if(!(V in list("type","loc","locs","vars", "parent", "parent_type","verbs","ckey","key", "amount")))
				newfluid.vars[V] = src.vars[V]



	if(src.amount < 2)
		transferamount = src.amount
		src.amount = 0
	else
		transferamount = 2
		src.amount = src.amount - 2

	if(src in usr.sexuality.vagina.womb_contents)
		usr.sexuality.vagina.contents += newfluid

	else if(src in usr.sexuality.vagina.contents)

		if(prob(20))
			if(usr.underwear !=6)
				usr.sexuality.underwear.contents += newfluid
/*			else if(
				var/turf/T = get_turf(usr)		// Todo, make an overlay for the stuff dripping onto the floor or dampening the crotch of a jumpsuit.
				if(T)
					newfluid.loc = T
	*/
	newfluid.amount = transferamount






















/mob/living/verb/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()


	if(config.allow_ERP)

		usr << "[src]'s Metainfo:"
		if(src.storedpreferences)
			usr << "[src] [src.storedpreferences.allow_ERP ? "allows" : "does not allow"] ERP with them!"
			usr << "[src]'s ERP Notes:  [src.storedpreferences.ERP_Notes]"

		else
			usr << "[src] does not have any stored infomation!"

	else
		usr << "OOC Metadata is not supported by this server!"

	return

/mob/living/carbon/human/verb/toggleUnderwear()
	set name = "Toggle Underwear"
	set category = "IC"
	set desc = "Remove or put back on your underwear."


	if(!src.w_uniform && !src.wear_suit)

		if(underwear == 6)
			if(storedpreferences.underwear == 6)
				underwear = pick(1,2,3,4,5)
			else
				underwear = storedpreferences.underwear

			usr << "You pull your underwear out of hammerspace and put it on."

		else
			underwear = 6
			usr << "You pull your underwear off and stuff it into hammerspace."

	else
		usr << "You have to take your outer clothing off first!"

	update_body()












/mob/living/proc/makeMale()
	src.sexuality.gender = MALE

	src.sexuality.penis = new

	src.sexuality.penis.length = rand(1,4)
	src.sexuality.penis.girth = rand(1,3)
	src.sexuality.penis.volume = PI*(src.sexuality.penis.girth/2)*src.sexuality.penis.length
	src.sexuality.penis.glans_sensitivity = rand(2,6)

	src.sexuality.breasts = new

	src.sexuality.breasts.size = rand(0,1)
	src.sexuality.breasts.nipplesensitivity = rand(1,4)

	src.sexuality.ass = new

	src.sexuality.ass.depth = rand(2,5)
	src.sexuality.ass.anal_width = rand(1,3)
	src.sexuality.ass.anal_elasticity = rand(1,4)/4
	src.sexuality.ass.hasProstate = 1

	src.sexuality.mouth = new

	src.sexuality.mouth.length = rand(1,2)

	return

/mob/living/proc/makeFemale()
	src.sexuality.gender = FEMALE
	src.sexuality.flatchest = 0

	src.sexuality.vagina = new

	src.sexuality.vagina.depth = rand(3,6)
	src.sexuality.vagina.opening_width = rand(1,2)
	src.sexuality.vagina.cervix_width =rand(1,2)/3
	src.sexuality.vagina.vaginal_elasticity = rand(1,2)/2
	src.sexuality.vagina.cervix_elasticity = rand(1,10)/20
	src.sexuality.vagina.clit_sensitivity = rand(4,8)

	src.sexuality.breasts = new

	src.sexuality.breasts.size = rand(3,7)
	src.sexuality.breasts.nipplesensitivity = rand(4,8)
	src.sexuality.breasts.milkcontent = rand(10,20)

	src.sexuality.ass = new

	src.sexuality.ass.depth = rand(2,5)
	src.sexuality.ass.anal_width = rand(1,3)
	src.sexuality.ass.anal_elasticity = rand(1,4)/4

	src.sexuality.mouth = new

	src.sexuality.mouth.length = rand(1,2)
	return

/mob/living/proc/makeHerm()
	src.sexuality.gender = "Herm"
	src.sexuality.flatchest = 0


	src.sexuality.penis = new

	src.sexuality.penis.length = rand(1,4)
	src.sexuality.penis.girth = rand(1,3)
	src.sexuality.penis.volume = PI*(src.sexuality.penis.girth/2)*src.sexuality.penis.length
	src.sexuality.penis.glans_sensitivity = rand(2,6)

	src.sexuality.vagina = new

	src.sexuality.vagina.depth = rand(3,6)
	src.sexuality.vagina.opening_width = rand(1,2)
	src.sexuality.vagina.cervix_width =rand(1,2)/3
	src.sexuality.vagina.vaginal_elasticity = rand(1,2)/2
	src.sexuality.vagina.cervix_elasticity = rand(1,10)/20
	src.sexuality.vagina.clit_sensitivity = rand(4,8)

	src.sexuality.breasts = new

	src.sexuality.breasts.size = rand(3,7)
	src.sexuality.breasts.nipplesensitivity = rand(4,8)
	src.sexuality.breasts.milkcontent = rand(10,20)

	src.sexuality.ass = new

	src.sexuality.ass.depth = rand(2,5)
	src.sexuality.ass.anal_width = rand(1,3)
	src.sexuality.ass.anal_elasticity = rand(1,4)/4

	src.sexuality.mouth = new

	src.sexuality.mouth.length = rand(1,2)
	return






















/mob/living/proc/handlePregnancy()
	sexuality.vagina.pregnancy.time++
	if(prob(25))
		sexuality.breasts.milkcontent = max(100, sexuality.breasts.milkcontent+10)
		sexuality.breasts.milking = 1
	if(prob(1))
		usr << "You feel nausous."

	if(sexuality.vagina.pregnancy.time > 250 && istype(usr, /mob/living/carbon/human))
		mutations |= FAT
		usr:update_body()
	return


/mob/living/proc/handleWombContents()
	for(var/datum/fluid/cum/C in src.sexuality.vagina.womb_fluid_contents)
		if(!sexuality.vagina.pregnancy)
			if(prob(10))
				sexuality.vagina.impregnate(C)
	if(sexuality.vagina.womb_fluid_contents.len && !sexuality.vagina.womb_contents.len)
		for(var/datum/fluid/F in src.sexuality.vagina.womb_fluid_contents)
			F.leak()



	return

/mob/living/proc/handleVaginaContents()
	if(sexuality.vagina.contents.len)
		for(var/datum/fluid/F in src.sexuality.vagina.fluid_contents)
			if(prob(20))
				F.leak()

	return






































/mob/living/verb/addERPVerbs()
	set name = "Show ERP Verbs"
	set category = "OOC"
	set desc = "Show ERP Verbs"

	if(!config.allow_ERP)
		src << "This station's policies strictly prohibit that sort of thing!"
		return

	if(!src.storedpreferences || !src.storedpreferences.allow_ERP)
		src << "You don't feel that kind of thing is very professional at work."
		return

	if(src.sexuality)
		src.sexuality.showERPverbs = 1

		for(var/Verb in ERPVerbs)
			if(!(Verb in src.verbs))
				src.verbs += Verb


/mob/living/verb/removeERPVerbs()
	set name = "Hide ERP Verbs"
	set category = "OOC"
	set desc = "Hide ERP Verbs"
	for(var/Verb in src.verbs)
		if((Verb in ERPVerbs))
			src.verbs -= Verb
	if(src.sexuality)
		src.sexuality.showERPverbs = 0

var/list/ERPVerbs = typesof(/client/ERP/command/proc/)




/*
/client/ERP/command/proc/ERP_Masturbate()
	set name = "Masturbate"
	set desc = "Pleasure yourself."
	set category = "ERP"
	usr.sexuality.pleasure += 1

/client/ERP/command/proc/ERP_Watersports()
	set name = "Watersports"
	set desc = "Absolutely humuilating!"
	set category = "ERP"
	usr.sexuality.pleasure = 5
	usr.sexuality.bladder -=5
*/






/client/ERP/command/proc/ERP_Fuck()
	set name = "Intercourse"
	set desc = "The fun part."
	set category = "ERP"

	var/list/partners = list()
	for(var/mob/living/carbon/C in oview(1))
		partners += C
	var/mob/T = input(usr, "Who do you wish to fuck?") as null | anything in partners



	if(T && T in oview(1))
		if(!T.sexuality)
			return

		if(!T.storedpreferences || !T.storedpreferences.allow_ERP)
			usr << pick("You don't feel comfortable doing that.","That wouldn't be very professional.","That could strain your working relationship.")
			return

		var/list/holes = list()

		if(T.sexuality.vagina)
			holes += "Vagina"

/*
		if(T.sexuality.mouth)
			holes += "Mouth"
		if(T.sexuality.ass)
			holes += "Ass"

		if(T.sexuality.penis)
			holes += "Penis (Mount)"
*/

		if(!holes.len)
			usr << "Sorry, only girls can be fucked!  (Right now)"
			return

		var/answer = input(usr, "Where do you wish to fuck them?") as null | anything in holes

		switch(answer)

			if("Mouth")
				call(/client/ERP/proc/ERP_Mouthfuck)(T)
			if("Ass")
				call(/client/ERP/proc/ERP_Assfuck)(T)

			if("Vagina")
				call(/client/ERP/proc/ERP_Vaginafuck)(T)

			if("Penis (Mount)")
				call(/client/ERP/proc/ERP_Mount)(T)


		usr.verbs -= /client/ERP/command/proc/ERP_Fuck

		spawn(5)
			usr.verbs += /client/ERP/command/proc/ERP_Fuck


		return

/client/ERP/proc/ERP_Mouthfuck(var/mob/partner)

	return

/client/ERP/proc/ERP_Assfuck(var/mob/partner)

	return

/client/ERP/proc/ERP_Vaginafuck(var/mob/partner)



	var/list/ways = list()
	if(usr.sexuality.penis)
		ways += "Penis"

	ways += "Fingers"

	for(var/obj/item/toy/sextoy/S in usr.contents)
		ways += S

	if(usr.sexuality.hashardtail)
		ways += "Tail"

	var/answer = input(usr, "How do you wish to fuck them?") as null | anything in ways
	switch(answer)
		if("Penis")
			if(istype(partner, /mob/living/carbon/human))
				if(partner:w_uniform || partner:wear_suit) // TODO:  Make a flag that allows clothing that exposes the crotch.
					usr << "[partner] has clothing covering them!"
					return
				if(partner:underwear != 6)
					if(usr.sexuality.reachingin)
						usr << "You pull [partner]'s underwear to the side..."
					else
						usr << "You can't really fuck them through their underwear."
						return

			usr.sexuality.sexualact = "Vagina-Penis"
			usr.sexuality.initiatior = usr
			usr.sexuality.initiated = partner
			partner.sexuality.sexualact = "Vagnia-Penis"
			partner.sexuality.initiatior = usr
			partner.sexuality.initiated = partner

			if(usr.sexuality.aggressive)											//TODO:  Actually use the width calcuations and stuff!
				usr << "You insert your penis roughly into [partner]"
				partner << "[usr] shoves themself into your folds!"

			else
				usr << "You slowly insert yourself into [partner]"
				partner << "[usr] slowly pushes himself into your folds."

			usr.sexuality.penis.location = partner.sexuality.vagina
			partner.sexuality.vagina.isVirgin = 0

			while(usr.sexuality.sexualact && partner.sexuality.sexualact)
				if(usr.sexuality.aggressive)
					usr.sexuality.pleasure += 6
					partner.sexuality.pleasure += 3

				else
					usr.sexuality.pleasure += 4
					partner.sexuality.pleasure += 2

				if(prob(5))
					var/found = 0
					for(var/datum/fluid/cum/C in usr.sexuality.penis.location:fluid_contents)
						if(C.creator == usr)
							C.amount += 1
							found = 1
							break
					if(!found)
						var/datum/fluid/cum/C = new
						C.amount = 1
						C.species = usr.type
						C.creator = usr
						if(istype(usr, /mob/living/carbon/))
							C.DNA = usr:dna
						partner.sexuality.vagina.fluid_contents += C

				if(partner.sexuality.pleasure > ORGASM_PLEASURE)
					partner.sexuality.pleasure = 20
					usr << "You feel [partner] convulse around your shaft!"
					partner << "You orgasm!"
					partner.sexuality.orgasm()


				if(usr.sexuality.pleasure > ORGASM_PLEASURE)
					usr.sexuality.pleasure = 20
					partner << "You feel [usr]'s heat shooting inside of you!"
					usr << "You begin to climax inside of [partner]!"
					usr.sexuality.orgasm()

				sleep(15)





	return

/client/ERP/proc/ERP_Mount(var/mob/partner)

	return




/*																TODO:  Finish these.
/client/ERP/command/proc/ERP_Kiss()
	set name = "Kiss"
	set desc = "The loving part."
	set category = "ERP"

/client/ERP/command/proc/ERP_Oral()
	set name = "Give Oral"
	set desc = "Another fun part."
	set category = "ERP"

/client/ERP/command/proc/ERP_Pull()
	set name = "Pull/Pinch"
	set desc = "The painful part.  Causes agressive sex."
	set category = "ERP"

*/

/client/ERP/command/proc/ERP_Underunderwear()
	set name = "Reach into underwear"
	set desc = "Reach into someone else's underwear"
	set category = "ERP"


	var/list/partners = list()
	for(var/mob/living/carbon/C in oview(1))
		partners += C
	var/mob/T = input(usr, "Whose underwear do you want to reach into?") as null | anything in partners



	if(T && T in view(1))
		if(!T.sexuality)
			return

		if(!T.storedpreferences || !T.storedpreferences.allow_ERP)
			usr << pick("You don't feel comfortable doing that.","That wouldn't be very professional.","That could strain your working relationship.")
			return

		if(T.underwear == 6)
			usr << "It's hard to reach into underwear they're not wearing!"
			return

		usr << "You start to stick your hands into [T]'s underwear..."
		T << "[usr] starts to stick their hands into your underwear!"
		usr.sexuality.sexualact = "Underwear"
		usr.sexuality.initiatior = usr
		usr.sexuality.initiated = T
		T.sexuality.sexualact = "Underwear"
		T.sexuality.initiatior = usr
		T.sexuality.initiated = T

		if(do_mob(usr, T))
			if(T.sexuality.sexualact)
				usr.sexuality.reachingin = 1

		usr.verbs -= /client/ERP/command/proc/ERP_Underunderwear

		spawn(5)
			usr.verbs += /client/ERP/command/proc/ERP_Underunderwear


		return



/obj/item/toy/sextoy/
	name = "A sex toy!"
	icon = 'ERP.dmi'
	icon_state = "dragon_dildo"

/obj/item/toy/sextoy/New()
	if(!config.allow_ERP)
		del(src)















