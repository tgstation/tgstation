<?php

class Jobs {
	/**
	 * Add or remove jobs, depending on your distro of SS13.
	 * 
	 * Used in jobbans.
	 */
	public static $KnownJobs=array(
		'Assistant', 
		'Atmospheric Technician',
		'Bartender',
		'Botanist',
		'Captain', 
		'Cargo Technician',
		'Chaplain',
		'Chef',
		'Chemist',
		'Chief Engineer',
		'Chief Medical Officer',
		'Clown',
		'Detective',
		'Geneticist',
		'Head of Personnel',
		'Head of Security',
		'Janitor',
		'Lawyer',
		'Librarian',
		'Medical Doctor',
		'Mime',
		'Paramedic',
		'Quartermaster',
		'Reporter',
		'Research Director',
		'Roboticist',
		'Scientist',
		'Security Officer',
		'Shaft Miner',
		'Station Engineer',
		'Virologist',
		'Warden'
	);
	
	/**
	 * Job categories/regions.
	 * 
	 * Used to group jobs for jobbans.
	 */
	public static $Categories=array(
		'Command'=>array( 
			'Captain',
			'Head of Personnel',
			'Head of Security',
			'Chief Engineer',
			'Research Director',
			'Chief Medical Officer'
		), 
		'Security'=>array( 
			'Head of Security',
			'Warden',
			'Detective',
			'Security Officer'
		),
		'Engineering'=>array( 
			'Chief Engineer',
			'Station Engineer',
			'Atmospheric Technician',
			'Roboticist'
		),
		'Medical'=>array( 
			'Chief Medical Officer',
			'Medical Doctor',
			'Geneticist',
			'Virologist',
			'Chemist',
			'Paramedic'
		),
		'Science'=>array(
			'Research Director',
			'Scientist',
			'Geneticist',
			'Roboticist'
		),
		'Civilian'=>array(
			'Head of Personnel',
			'Bartender',
			'Botanist',
			'Chef',
			'Janitor',
			'Librarian',
			'Quartermaster',
			'Cargo Technician',
			'Shaft Miner',
			'Lawyer',
			'Reporter',
			'Chaplain',
			'Clown',
			'Mime',
			'Assistant'
		),
		'Silicon'=>array( 
			'AI',
			'Cyborg',
			'Mobile MMI',
			'pAI'
		), 
		'Antagonist'=>array( 
			'Traitor',
			'Changeling',
			'Nuke Operative',
			'Revolutionary',
			'Cultist',
			'Wizard'
		) 

	);
}
