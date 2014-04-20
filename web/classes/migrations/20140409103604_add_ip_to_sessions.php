<?php

use Phinx\Migration\AbstractMigration;

class AddIpToSessions extends AbstractMigration
{
	/**
	 * Add the new IP field to admin_session.
	 */
    public function up()
    {
		$this->table('admin_sessions')
			->addColumn('IP', 'string', array('limit'=>255,'default' => null))
			->save();
    }
	public function down() {
		$sess = $this->table('admin_sessions');
		if ($sess->hasColumn('IP'))
			$sess->removeColumn('IP')->save();
	}
}