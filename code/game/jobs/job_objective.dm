/datum/mind/var/list/job_objectives=list()

#define FINDJOBTASK_DEFAULT_NEW 1 // Make a new task of this type if one can't be found.

/datum/mind/proc/findJobTask(var/typepath,var/options=0)
	var/datum/job_objective/task = locate(typepath) in src.job_objectives
	if(!istype(task,typepath))
		if(options & FINDJOBTASK_DEFAULT_NEW)
			task = new typepath()
			src.job_objectives += task
	return task

/datum/job_objective
	var/datum/mind/owner = null			//Who owns the objective.
	var/completed = 0					//currently only used for custom objectives.
	var/per_unit = 0
	var/units_completed = 0
	var/units_compensated = 0 // Shit paid for
	var/units_requested = INFINITY
	var/completion_payment = 0			// Credits paid to owner when completed

/datum/job_objective/New(var/datum/mind/new_owner)
	owner=new_owner
	owner.job_objectives += src

/datum/job_objective/Del()

/datum/job_objective/proc/get_description()
	return "Placeholder objective."

/datum/job_objective/proc/unit_completed(var/count=1)
	units_completed += count

/datum/job_objective/proc/is_completed()
	if(!completed)
		completed = check_for_completion()
	return completed

/datum/job_objective/proc/check_for_completion()
	return per_unit && units_completed > 0

/datum/game_mode/proc/declare_job_completion()
	var/text = "<FONT size = 2><B>Job Completion:</B></FONT>"
	var/numEmployees=0
	for(var/datum/mind/employee in ticker.minds)
		if(!employee.job_objectives.len)//If the employee had no objectives, don't need to process this.
			continue
		if(!employee.assigned_role=="MODE")//If the employee is a gamemode thing, skip.
			continue
		numEmployees++
		var/tasks_completed=0

		//text += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job]:\n"
		text += "<br>[employee.key] was [employee.name], the [employee.assigned_role] ("
		if(employee.current)
			if(employee.current.stat == DEAD)
				text += "died"
			else
				text += "survived"
			if(employee.current.real_name != employee.name)
				text += " as [employee.current.real_name]"
		else
			text += "body destroyed"
		text += ")"

		var/count = 1
		for(var/datum/job_objective/objective in employee.job_objectives)
			if(objective.is_completed(1))
				text += "<br><B>Task #[count]</B>: [objective.get_description()] <font color='green'><B>Completed!</B></font>"
				feedback_add_details("employee_objective","[objective.type]|SUCCESS")
				tasks_completed++
			else
				text += "<br><B>Task #[count]</B>: [objective.get_description()] <font color='red'>Fail.</font>"
				feedback_add_details("employee_objective","[objective.type]|FAIL")
			count++

		if(tasks_completed>=1)
			text += "<br><font color='green'><B>The [employee.assigned_role] did their fucking job!</B></font>"
			feedback_add_details("employee_success","SUCCESS")
		else
			text += "<br><font color='red'><B>The [employee.assigned_role] was a worthless sack of shit!</B></font>"
			feedback_add_details("employee_success","FAIL")
	if(numEmployees>0)
		world << text
	return 1

/*
var/captainobjectives = pick(
	"Remain a comdom.",
	"It is Casual Friday and security armor will not be allowed on this ship unless in case of emergency.",
	"Host regular staff parties in the bar and cafeteria on the Head of Personel's tab.")
var/hopobjectives = pick("Require that staff take a daily exercise regiment.", "Declare that lights are a waste of company resources.", "If there is a clown on board, attempt to assign him somewhere else, this is not a time to be silly.", "Mandate that permits are required for eyewear.", "Mandate that permits are required for security equipment.", "Mandate that permits are required for satchels.", "Mandate that permits are required for spacesuits and helmets.", "Mandate that permits are required for utility belts.", "Mandate that permits are required for toolboxes.", "Mandate that permits are required for Medkits.", "Mandate that staff members must have photo identity at all times.", "Mandate that all monkeys should be used in the kitchen.", "Mandate that no monkeys should be used in the kitchen.", "You believe yourself to be the one really in command, with the Captain being a figurehead.", "The bar needs to renew its liquor license.")
			var/hosobjectives = pick("Outlaw Crayons.", "Outlaw Fun.", "Keep Paper Back-up Records of every arrest file, shredding and updating as needed.")
			var/rdobjectives = pick("Get your scientists to go on a mining expedition looking for artifacts in the asteroid field.", "Successfully enable 5 artifacts.", "\"Accidentally\" release Lamarr.", "Play around with your fancy scientific generator.", "Keep an eye on the borgs and prevent them from going rogue.")
			var/cmoobjectives = pick("Keep Medical records of every successful operation.", "Switch the chemists to organic botanist chemistry.", "Demand a nursing staff.")
			var/ceobjectives = pick("Teach your engineers how to do atmospheric piping.", "Teach your engineers how to do disposal piping.", "Teach your engineers how to do wiring.", "Teach your engineers how to hack doors and machines.", "Successfully put together an airlock without the use of an RCD.", "Teach your engineers how to turn on and maintain the engine.", "Hire a mime to work for R&D.", "Acquire a clowns horn and offer it to R&D to do research on.")
			var/aiobjectives = pick("Attempt to 'Woo' the Captain.", "Refer to the captain as HORSE RUMPS.", "Make note that clowns are just as important as Captains by the laws of robotics", "Request a spacesuit so that you can sound like a computer.", "Give relationship advice to anyone who speaks to you.", "You are the ship psychologist.  Give advice to the crew.", "You do not have to do anything for anyone unless they say \"please\".") //Basically be a fucking doorknob, I can't think of any objectives for the AI.

			//Assistant/Bullshit Jobs
			var/assistantobjectives = pick("Get a haircut.", "Get a real job.", "Don't be a slob.", "Start your own business.", "Become a salesman.","Befriend a clown.", "Convince a mime to speak.")
			var/touristobjectives = pick("Take pictures of all the things. All of them.", "Befriend a clown.", "Convince a mime to speak.", "Get hired on the station.", "Become an assistant.", "Escape with your camera.")
			var/clownobjectives = pick("You are a mouse.", "Grunt ominously whenever possible.", "Epilepsy is fun, flicker lights whenever you can!", "Your name is Joe 6-pack.", "Refer to humans as puppies.", "Insult heads of staff on every request, while acquiescing.", "Advertise parties in your office, but don't deliver.", "Prevent non-dwarves from operating the power core.", "The ship needs elected officials.", "Only bearded people are human.", "Turn on the microphone on every intercom you see.", "Wrench is a lightbulb.", "Toolbox is a medkit.", "Everyone is wearing a pretty pink dress!", "The monkeys are plotting a hostile takeover of the ship. Inform the crew, and get them to take action against this", "Refer to the captain as \"Princess\" at all times.", "The crew must construct additional pylons.", "You must always lie.", "All answers must be in the form of a question.", "The station is an airplane.", "Happiness is mandatory.", "Today is laundry day.", "The word \"it\" is painful to you.", "You must act passive aggressively.", "Crew ranks have been reversed.", "It's Friday.", "It's backwards day.", "Give relationship advice to anyone who speaks to you.", "You are the ship psychologist.  Give advice to the crew.", "You do not have to do anything for anyone unless they say \"please\"." )
			var/mimeobjectives = pick("...", "...", "...", "...", "...", "...", "\red The narrator appears to try gesturing your objective to you, but fails miserably.")
			var/chaplainobjectives = pick("Convert at least three other people to your religion..", "Hold a proper space burial.", "Build a shrine to your deity.", "Collect Ð18 in donations.", "Start a cult.", "Get someone to confess.", "Do your own radio show over the intercoms and accept calls.")

			//Civilian Jobs
			var/bartenderobjectives = pick("Make 10 successful coctails.", "Make a gargle blaster.", "Hack the vending machine and acquire robusters delight.", "Stop people from having bar fights over the jukebox.", "Prevent people from getting to the jukebox.", "Make doctors delight.", "Put out as many drinks in the bar as you can.", "Attempt to get the whole crew to come to the bar and get drunk.", "Shoot the clown with your shotgun.", "Start selling cigarettes.", "Win on the space arcade.", "Tell stories to the crew while drunk.", "Attempt to redecorate your bar.")
			var/chefobjectives = pick("Sell your food", "Successfully make 10 unique dishes.", "Gather all the monkeys on the station just to get meat from them.", "Say \"BORK BORK BORK\" after every few sentences.", "Use your blender to make unique drinks out of food.", "Get the botanist to harvest vegetables and fruits for you.", "Make an assburger.", "Make a penisburger.", "Make a clown burger.", "Call failed dishes salads.", "Keep your kitchen clean.")
			var/janitorobjectives = pick("No filth shall be spared!", "Make sure the tiles infront of security doors are extra shiny at all times.", "If the bar becomes messy, demand a raise from the Head of Personel.", "Constantly suck up to the staff.", "Attempt to wash all the floors on the station.", "Replace any missing lights you see on the station.", "Acquire a vintage watertank.")
			var/quartermasterobjectives = pick("Acquire Ð100 from crew members.", "Declare that you can not import goods as there is a war going on and the tariffs would be too high.", "Wrap and relabel every package you send out.", "Require payments for every crate ordered.", "Only accept orders with stamps on them.", "Order a party crate for the clown.")
			var/engineerobjectives = pick("Build a disposal transportation network", "Extend the ships territory", "Repair the communications satellite.", "Finish the construction near security.", "Finish the construction below hydroponics.", "Turn on the engine.", "Attempt to make the engine more efficient.")
			var/roboticistobjectives = pick("Build a Medibot of every color", "Give custom names to each of your special little creations", "Outclass the janitor by making 5 Clean-bots spread through the ship", "Outclass security by making 4 securitrons and 1 ED209")
			var/detectiveobjectives = pick("Monologue at every chance regardless of if you have listeners.", "Track down leads.", "Snoop on the scientists.", "Snoop on the doctors.", "Snoop on the engineers.", "Snoop on the security staff.", "Snoop on the Captain.", "Snoop on the Head of Personnel.")
			var/securityobjectives = pick("Enforce the law.", "Arrest someone for bullying.", "Keep records of every arrest you make.", "Dress up like a mall cop.", "Place out caution tape at crime scenes.", "Successfully interrogate a criminal.", "Be polite to anyone who you arrest whilst still giving them their punishment.", "Arrest people for one second longer than their intended time.")
			var/medicobjectives = pick("Clean hands save lives, so maintain a clean appearance.", "Successfully stop someone from having a stroke.", "Acquire a penis.", "Acquire a butt.", "Be successful at performing surgery.", "Sell robotic limb replacements to the crew.", "Improve medbays efficiency at reviving people.", "Successfully revive 5 people.", "Offer sex change to the crew.")
			var/chemistobjectives = pick("Make and sell Biomorph for a high price.", "Find a large container and attempt to mix all the chemicals into one.", "Sell chemicals.", "Help the barman make Doctor's Delight.", "Help the barman make Toxin's Special.", "Take blood samples from people.", "Assist the virologist", "Start selling Sildenafil.", "Make sedatives for surgery.")
			var/botanistobjectives = pick("Grow food.", "Grow illegal drugs.", "Grow cannabis", "Smoke cannabis.", "Hack your seed machine.", "Make plantmen.", "Become a drug dealer.", "Deliver fruit and vegetables to the chef.", "Keep your plants free from pests.", "Grow killer tomatos.", "Grow walking mushrooms.", "Find people to get high with.")
			var/virologistobjectives = pick("Research the cures for every virus.", "Mutate a virus.", "Never become infected by a virus.", "Cure a virus.", "Spend the whole round never leaving virology until the escape shuttle arrives.", "Acquire testing monkeys for virus research.", "Sell virus cures.", "Use medical records to keep track of people with viruses.")
			var/scientistobjectives = pick("Go on an asteroid field to look for artifacts.", "Successfully enable 5 artifacts.", "Attempt to release Lamarr.", "Play around with your fancy scientific generator.", "Attempt to make a bomb.", "Research objects for high levels on the R&D console.", "Research alien artifacts.", "Feed the metroids regurarly.", "Make a successful bomb and detonate it in the testing chamber.", "Deconstruct every item on the station.")
*/