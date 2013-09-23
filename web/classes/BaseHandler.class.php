<?php

class BaseHandler {
	public $title="";
	public $image="";
	public $sess=false;
	public $adminOnly=false;
	
	public function handle($pi) {
		global $tpl;

		if(array_key_exists('s', $_REQUEST))
			$this->sess=AdminSession::FetchSessionFor($_REQUEST['s']); // Cleaned.
		
		$this->path = $pi;
		if($this->adminOnly && !$this->sess)
		{
			header('HTTP/1.1 403 Forbidden');
			die('Access Denied');
			return;
		}
		if ($this->IsAJAX())
			echo $this->OnBody();
		else {
			$tpl->assign('title', $this->title);
			$tpl->assign('session', $this->sess);
			$tpl->assign('links', $this->OnLinks());
			$tpl->assign('body', $this->OnBody());
			$tpl->assign('head', $this->OnHeader());

			$tpl->display('wrapper.tpl.php');
		}
	}

	public function IsAjax() {
		return false;
	}

	public function OnLinks() {
		global $ACT_HANDLERS;
		$links = array();
		foreach ($ACT_HANDLERS as $key => $handler) {
			if ($handler->parent == '/') {
				$name = substr($key, 4);
				$url=fmtURL($name);
				if(get_class($handler)=='ExternalLinkHandler')
					$url=$handler->url;
				$links[$name] = array(
					'image'=>$handler->image,
					'desc'=>$handler->description,
					'url'=>$url
				);
			}
		}
		return $links;
	}

	/**
	 * Override to specify page content.
	 */
	public function OnBody() {
		return '';
	}

	/**
	 * Output is appended to the end of the <head> tag.
	 * 
	 * @return html
	 */
	public function OnHeader() {
		return '';
	}

}

/**
 * Used to add external links to the navigation bar.
 */
class ExternalLinkHandler extends BaseHandler {
	public $parent = '/';
	public $url='';
	public function ExternalLinkHandler($label,$img,$uri) {
		$this->description=$label;
		$this->image=$img;
		$this->url=$uri;
	}
}
