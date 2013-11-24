<?php

use Phinx\Migration\AbstractMigration;

class CreateSessionTable extends AbstractMigration
{
    public function change()
    {
    	$sessions = $this->table('admin_sessions',array('id' => false,'primary_key'=>array('sessID')));
		$sessions->addColumn('sessID','string',array('limit'=>36))
				 ->addColumn('ckey','string')
				 ->addColumn('expires','datetime')
				 ->save();
    }
}