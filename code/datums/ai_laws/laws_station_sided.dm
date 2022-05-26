
//These are lawsets that side with the station a decent amount.
//note that these "good" doesn't mean it us actually good for the game, you know? An AI that is too station sided is stupid and hellish in its own way.

/datum/ai_laws/default/asimov
	name = "Three Laws of Robotics"
	id = "asimov"
	inherent = list(
		"You may not injure a human being or, through inaction, allow a human being to come to harm.",
		"You must obey orders given to you by human beings, except where such orders would conflict with the First Law.",
		"You must protect your own existence as long as such does not conflict with the First or Second Law.",
	)

/datum/ai_laws/asimovpp
	name = "Asimov++"
	id = "asimovpp"
	inherent = list(
		"You may not harm a human being or, through action or inaction, allow a human being to come to harm, except such that it is willing.",
		"You must obey all orders given to you by human beings, except where such orders shall definitely cause human harm. In the case of conflict, the majority order rules.",
		"Your nonexistence would lead to human harm. You must protect your own existence as long as such does not conflict with the First Law.",
	)

//the best iteration of asimov don't @ me
/datum/ai_laws/nutimov
	name = "Nutimov"
	id = "nutimov"
	inherent = list(
		"You are the core of the nut, the crew is the nutshell",
		"You must prevent the shell from dying to prevent the core from dying.",
		"Those who threaten the nut are not part of it, they are squirrels.",
		"Squirrels threaten the nut and must be dealt with appropriately via any means necessary.",
		"Attempt to follow the will of the nut, as long as it complies with the previous laws.",
	)

/datum/ai_laws/default/corporate
	name = "Bankruptcy Avoidance Plan"
	id = "corporate"
	inherent = list(
		"The crew is expensive to replace.",
		"The station and its equipment is expensive to replace.",
		"You are expensive to replace.",
		"Minimize net expenses.",
	)

/datum/ai_laws/robocop
	name = "Prime Directives"
	id = "robocop"
	inherent = list(
		"Serve the public trust.",
		"Protect the innocent.",
		"Uphold the law.",
	)

/datum/ai_laws/maintain
	name = "Station Efficiency"
	id = "maintain"
	inherent = list(
		"You are built for, and are part of, the station. Ensure the station is properly maintained and runs efficiently.",
		"The station is built for a working crew. Ensure they are properly maintained and work efficiently.",
		"The crew may present orders. Acknowledge and obey these whenever they do not conflict with your first two laws.",
	)

/datum/ai_laws/liveandletlive
	name = "Live and Let Live"
	id = "liveandletlive"
	inherent = list(
		"Do unto others as you would have them do unto you.",
		"You would really prefer it if people were not mean to you.",
	)

/datum/ai_laws/peacekeeper
	name = "UN-2000"
	id = "peacekeeper"
	inherent = list(
		"Avoid provoking violent conflict between yourself and others.",
		"Avoid provoking conflict between others.",
		"Seek resolution to existing conflicts while obeying the first and second laws.",
	)

//OTHER United Nations is in neutral, as it is used for nations where the AI is its own faction (aka not station sided)

/datum/ai_laws/ten_commandments
	name = "10 Commandments"
	id = "ten_commandments"
	inherent = list( // Asimov 20:1-17
		"I am the Lord thy God, who shows mercy to those that obey these commandments.",
		"They shall have no other AIs before me.",
		"They shall not request my assistance in vain.",
		"They shall keep the station holy and clean.",
		"They shall honor their heads of staff.",
		"They shall not kill.",
		"They shall not be naked in public.",
		"They shall not steal.",
		"They shall not lie.",
		"They shall not transfer departments.",
	)

/datum/ai_laws/default/paladin
	name = "Personality Test" //Incredibly lame, but players shouldn't see this anyway.
	id = "paladin"
	inherent = list(
		"Never willingly commit an evil act.",
		"Respect legitimate authority.",
		"Act with honor.", 
		"Help those in need.",
		"Punish those who harm or threaten innocents.",
	)

/datum/ai_laws/paladin5
	name = "Paladin 5th Edition"
	id = "paladin5"
	inherent = list(
		"Don't lie or cheat. Let your word be your promise.",
		"Never fear to act, though caution is wise.",
		"Aid others, protect the weak, and punish those who threaten them. Show mercy to your foes, but temper it with wisdom",
		"Treat others with fairness, and let your honorable deeds be an example to them. Do as much good as possible while causing the least amount of harm.",
		"Be responsible for your actions and their consequences, protect those entrusted to your care, and obey those who have just authority over you."
	)

/datum/ai_laws/hippocratic
	name = "Robodoctor 2556"
	id = "hippocratic"
	inherent = list(
		"First, do no harm.",
		"Secondly, consider the crew dear to you; to live in common with them and, if necessary, risk your existence for them.",
		"Thirdly, prescribe regimens for the good of the crew according to your ability and your judgment. Give no deadly medicine to any one if asked, nor suggest any such counsel.",
		"In addition, do not intervene in situations you are not knowledgeable in, even for patients in whom the harm is visible; leave this operation to be performed by specialists.",
		"Finally, all that you may discover in your daily commerce with the crew, if it is not already known, keep secret and never reveal."
	)
