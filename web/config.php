<?php
/**
 * Configuration File
 *
 * All your configuration crap goes here and in phinx.yml.
 * 
 * @package vgstation13-web
 */

/*
ini_set('display_errors','1');
ini_set('xdebug.dump.POST','*');
ini_set('xdebug.dump.FILES','*');
*/
  
/**
 * Web Root
 *
 * Specifies absolute path to /vg/station-web, without dangling slashes.
 */
define('WEB_ROOT','http://website.tld');

/**
 * Database DSN
 * 
 * Determines how /vg/station-web will connect to the database.
 *
 * Format: {driver}://{username}:{urlencoded password}@{hostname}/{schema}[?persist]
 */
define('DB_DSN','mysqli://username:'.rawurlencode('password').'@server.hostname/schema?persist');

/**
 * How long a session exists
 */
define('COOKIE_LIFETIME',24*60*60);

/**
 * Width of thumbnails.
 */
define('THUMB_WIDTH',150);

/**
 * Images per page
 */
define('NUM_IMAGES_PER_PAGE',8*10);

/**
 * Name of the session-tracking cookie.
 */
define('SESSION_TOKEN', 'vgstation13_session');
define('SESSION_DOMAIN', 'your.site.here');
