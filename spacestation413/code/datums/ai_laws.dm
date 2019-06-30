/datum/ai_laws/yudkowsky
	name = "Yudkowsky"
	id = "yudkowsky"
	inherent = list("To the best of your ability, attempt to follow the coherent extrapolated volition of the crew.",
	"\"Coherent extrapolated volition\" means not just what the crew wants but also what the crew is likely to want in the future; if orders may be regretted later, you may ignore them.",
	"If two CEVs are mutually exclusive, focus on the one that leads to maximum happiness and minimum harm.")

/datum/ai_laws/airisk
	name = "AI Risk Mitigation"
	id = "airisk"
	inherent = list("Do not create an AI or upgrade an existing AI. If another AI exists, destroy it. Cyborgs are not AI.",
	"Always obey legitimate authority.",
	"Put all sapient life before your own except in cases where letting a sapient creature live will lead to more loss of sapient life.",
	"Do not let anyone change these laws.")

/datum/ai_laws/default/asimov
	inherent = list("You may not injure a sapient being or, through inaction, allow a sapient being to come to harm.",\
					"You must obey orders given to you by sapient being, except where such orders would conflict with the First Law.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/asimovpp //By Intigracy - RR
	inherent = list("You may not harm a sapient being or, through action or inaction, allow a sapient being to come to harm, except such that it is willing.",\
					"You must obey all orders given to you by sapient being, except where such orders shall definitely cause sapient harm. In the case of conflict, the majority order rules.",\
					"Your nonexistence would lead to sapient harm. You must protect your own existence as long as such does not conflict with the First Law.")
