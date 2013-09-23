<?php
$sw_['start']=microtime(true);
define('PATH_ROOT', dirname(dirname(__FILE__)));
define('LIB_DIR', PATH_ROOT . '/lib');
define('CACHE_DIR', PATH_ROOT . "/cache");
define('FILE_DIR', PATH_ROOT . "/imgpool");
define('THUMB_DIR', PATH_ROOT . "/thumbpool");

// Libs
require_once ('Savant3.php');
require_once ('adodb/adodb.inc.php');

// Just loads all of the classes without screwing around with 50 includes.

require_once dirname(__FILE__) . '/funcs.php';
require_once dirname(__FILE__) . '/BaseHandler.class.php';
require_once dirname(__FILE__) . '/Admin.class.php';
require_once dirname(__FILE__) . '/QF.class.php';
require_once dirname(__FILE__) . '/Jobs.class.php';
require_once dirname(__FILE__) . '/Poll.class.php';
require_once dirname(__FILE__) . '/HTML/Form.class.php';

$ACT_HANDLERS = array();

require_once dirname(__FILE__) . '/handlers/web/web_home.class.php';
require_once dirname(__FILE__) . '/handlers/web/web_admins.class.php';
require_once dirname(__FILE__) . '/handlers/web/web_bans.class.php';
require_once dirname(__FILE__) . '/handlers/web/web_rapsheet.class.php';
require_once dirname(__FILE__) . '/handlers/web/web_poll.class.php';

require_once dirname(__FILE__) . '/handlers/api/api_chkban.class.php';
require_once dirname(__FILE__) . '/handlers/api/api_findcid.class.php';

////////////////////////////////
// Setup database
////////////////////////////////
if (!defined('DB_DSN'))
	die('You forgot to set up DB_DSN in config.php.  {$driver}://{$username}:{$password}@{$hostname}/{$schema}[?persist] (use rawurlencode on the password if needed.)');

$db = NewADOConnection(DB_DSN);
if (!$db) {
	// DB failed to connect
	die('SQL server connection failure');
}

$tpl = new Savant3();
$tpl->addPath('template', dirname(__FILE__) . '/../templates');
