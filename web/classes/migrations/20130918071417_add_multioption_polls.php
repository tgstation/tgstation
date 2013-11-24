<?php

use Phinx\Migration\AbstractMigration;

class AddMultioptionPolls extends AbstractMigration {
	/**
	 * Update to latest /tg/ database structure.
	 */
	public function up() {
		//`multiplechoiceoptions` int(2) DEFAULT NULL,
		$this->table('erro_poll_question')
			->addColumn('multiplechoiceoptions', 'integer', array('limit' => 2, 'default' => null))
			->save();
	}

	public function down() {
		//`multiplechoiceoptions` int(2) DEFAULT NULL,
		$epq = $this->table('erro_poll_question');
		if ($epq->hasColumn('multiplechoiceoptions'))
			$epq->removeColumn('multiplechoiceoptions')->save();
	}

}
