
/*
		WELCOME TO THE FULPSTATION CODE Z-LEVEL!


	Any time we want to outright overwrite a variable that is already given a value in a previously defined atom or datum, we
	can overwrite it here!

		WHY DO THIS?
*/





 	//antag disallowing//

 /datum/game_mode/revolution
	protected_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Deputy")

 /datum/game_mode/traitor/changeling
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Deputy")

 /datum/game_mode/clockwork_cult
	protected_jobs = list("AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Deputy")

 /datum/game_mode/cult
	protected_jobs = list("Chaplain","AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Deputy")

 /datum/game_mode/devil
	protected_jobs = list("Lawyer", "Curator", "Chaplain", "Head of Security", "Captain", "AI", "Security Officer", "Deputy")

 /datum/game_mode/traitor
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Deputy")
