<?php
define('R_BUILDMODE',	 1);
define('R_ADMIN',        2);
define('R_BAN',          4);
define('R_FUN',          8);
define('R_SERVER',       16);
define('R_DEBUG',        32);
define('R_POSSESS',      64);
define('R_PERMISSIONS',  128);
define('R_STEALTH',      256);
define('R_REJUVINATE',   512);
define('R_VAREDIT',      1024);
define('R_SOUNDS',       2048);
define('R_SPAWN',        4096);

define('R_EVERYTHING',  R_BUILDMODE|R_ADMIN|R_BAN|R_FUN|R_SERVER|R_DEBUG|R_POSSESS|R_PERMISSIONS|R_STEALTH|R_REJUVINATE|R_VAREDIT|R_SOUNDS|R_SPAWN);
define('R_GAME_ADMIN',	R_ADMIN|R_SPAWN|R_REJUVINATE|R_VAREDIT|R_BAN|R_POSSESS|R_FUN|R_SOUNDS|R_SERVER|R_DEBUG|R_STEALTH|R_BUILDMODE);

$ADMIN_FLAGS=array(	
	R_BUILDMODE => 'BUILDMODE',
	R_ADMIN => 'ADMIN',
	R_BAN => 'BAN',
	R_FUN => 'FUN',
	R_SERVER => 'SERVER',
	R_DEBUG => 'DEBUG',
	R_POSSESS => 'POSSESS',
	R_PERMISSIONS => 'PERMISSIONS',
	R_STEALTH => 'STEALTH',
	R_REJUVINATE => 'REJUVINATE',
	R_VAREDIT => 'VAREDIT',
	R_SOUNDS => 'SOUNDS',
	R_SPAWN => 'SPAWN'
);

class AdminSession {
	public $ckey='';
	public $rank='';
	public $level=0;
	public $flags=0;
	public $id='';
	
	public static function FetchSessionFor($sessID) 
	{
		global $db;
		$query=<<<SQL
	SELECT 
		a.ckey,
		a.rank,
		a.level,
		a.flags,
		s.sessID
	FROM 
		erro_admin AS a 
	LEFT JOIN 
		admin_sessions AS s
	ON a.ckey = s.ckey
	WHERE s.sessID=?
SQL;
		$row=$db->GetRow($query, array($sessID));
		if(!$row)
			return false;
		$sess=new AdminSession();
		$sess->id=$row[4];
		$sess->ckey=$row[0];
		$sess->role=$row[1];
		$sess->rank=$row[2];
		$sess->flags=$row[3];
		return $sess;
	}
}
