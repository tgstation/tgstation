<?php
/**
 * QuickForm
 * 
 * @author N3X15
 */

class Element
{
	public $name='';
	public $attributes=array();
	public $children=array();
	
	public function __construct($name,$attr=array(),$inner=array()) {
		$this->name=$name;
		$this->attributes=$attr;
		if(!is_array($inner))
			$this->children=array($inner);
		else
			$this->children=$inner;
	}
	
	private function fmtAttributes() {
		if(!is_array($this->attributes) || count($this->attributes)==0)
			return '';
		$o=array();
		//var_dump($this->attributes);
		foreach($this->attributes as $k=>$v)
		{
			$o[]="{$k}=\"".htmlentities($v,ENT_QUOTES,'ISO-8859-1',false)."\"";
			//$o[]="{$k}=\"".htmlentities($v)."\"";
		}
		//var_dump($o);
		return ' '.implode(' ',$o);
	}
	
	public function __toString() {
		$attr=$this->fmtAttributes();
		$buf = "{$this->name}{$attr}";
		if(count($this->children)==0)
			return '<'.$buf.' />';
		$buf="<{$buf}>";
		for($i=0;$i<count($this->children);$i++) {
			if(is_string($this->children[$i]))
				$buf.=$this->children[$i].'';
			else
				$buf.=$this->children[$i];
		}
		$buf.="</{$this->name}>";
		return $buf;
	}
	
	public function addChild($child) {
		$this->children[]=$child;
		return $this;
	}
	
	public function setAttribute($name,$value) {
		$this->attributes[$name]=$value;
		return $this;
	}
	
	public function setAttributes($a=array()) {
		foreach($a as $k=>$v) {
			$this->attributes[$k]=$v;
		}
		return $this;
	}
	public function addLabel($label,$for) {
		$this->addChild(new Element('label',array('for'=>$for),array($label)));
		return $this;
	}
	
	public function addPlus($formname,$for,$addval,$label,array $other=array()) {
		//<a href="#" onclick="document.banform.seconds.value='3600';return false;">1hr</a>
		$a = new Element('a');
		$a->setAttributes($other);
		$a->setAttribute('href', '#');
		$a->setAttribute('onclick', "document.{$formname}.{$for}.value=parseInt(document.{$formname}.{$for}.value) + {$addval};return false;");
		$a->addChild($label);
		$this->addChild('&nbsp;');
		$this->addChild($a);
		return $this;
	}
	
	public function addBookmarklet($label,$javascript,array $other=array()) {
		//<a href="#" onclick="document.banform.seconds.value='3600';return false;">1hr</a>
		$a = new Element('a');
		$a->setAttributes($other);
		$a->setAttribute('href', '#');
		$a->setAttribute('onclick', "{$javascript}return false;");
		$a->addChild($label);
		$this->addChild('&nbsp;');
		$this->addChild($a);
		return $this;
	}
	
	public function addBreak() {
		$this->addChild(new Element('br'));
		return $this;
	}
	
	public function addTextbox($name, $default='', $other=array())
	{
		 return $this->addInput('textbox',$name,$default,$other);
	}
	
	public function addPassword($name, $default='', $other=array())
	{
		 return $this->addInput('password',$name,$default,$other);
	}
	
	public function addEmail($name, $default='', $other=array())
	{
		 return $this->addInput('email',$name,$default,$other);
	}
	
	public function addButton($type, $name, $label, $value=null, $other=array())
	{
		if($value!=null)
			$other['value']=$value;
		$other['type']=$type;
		$other['name']=$name;

		$this->addChild(new Element('button',$other,$label));
		return $this;
	}
	
	public function addReset($name, $label='Reset', $value=null, $other=array())
	{
		return $this->addButton('reset',$name,$label,$value,$other);
	}
	
	public function addCheckbox($name, $value='1', $other=array())
	{
		return $this->addInput('checkbox',$name,$value,$other);
	}
	
	public function addSubmit($name, $label='Submit', $value=null, $other=array())
	{
		return $this->addButton('submit',$name,$label,$value,$other);
	}
	
	public function addInput($type, $name, $default='', array $other=array())
	{
		$other['name']=$name;
		$other['type']=$type;
		if($default!='')
			$other['value']=$default;
		$this->addChild(new Element('input',$other));
		return $this;
/*
		$otheratt=self::FormatAttributes($other);
		return <<<EOF
			<input type="$type" name="$name" value="$default"$otheratt/>
EOF;
*/
	}
	
	public function addTextarea($name, $default='', $other=array())
	{
		$other['name']=$name;
		$this->addChild(new Element('textarea',$other,$default));
		return $this;
/*
		$otheratt=self::FormatAttributes($other);
		return <<<EOF
			<input type="$type" name="$name" value="$default"$otheratt/>
EOF;
*/
	}
	
	public function addHidden($name, $value)
	{
		//var_dump($value);
		return $this->addInput('hidden', $name, $value);
	}
	
	/**
	 * Emit a selection input.
	 * 
	 * @param name
	 * @param label
	 * @param options
	 * @param default
	 * @param other
	 */
	public function addSelect($name, array $options, $default='', $other=array())
	{
		$other['name']=$name;
		$select = new Element('select',$other);
		foreach($options as $k=>$v){
			$opt = new Element('option');
			$opt->setAttribute('value',$k)->addChild($v);
			if($k==$default)
				$opt->setAttribute('selected','selected');
			$select->addChild($opt);
		}
		$this->addChild($select);
		return $this;
	}
}
class Form extends Element
{
	public function __construct($action, $method='get',$name='', $other=array()) {
		parent::__construct('form',array(
			'method'=>$method,
			'name'=>$name,
		));
		$this->attributes['name']=$name;
		$this->attributes['method']=$method;
		$this->setAttributes($other);
	}
} 
class TableRow extends Element {
	public function __construct($class='',$other=array()) {
		parent::__construct('tr');
		if($class!='')
			$this->attributes['class']=$class;
		$this->setAttributes($other);
	}	
	public function createCell($class='',array $other=array()) {
		if($class!='')
			$other['class']=$class;
		$td = new Element('td',$other);
		$this->addChild($td);
		return $td;
	}
	public function addHeader($children,array $other=array()) {
		if($class!='')
			$other['class']=$class;
		$th = new Element('th',$other);
		$this->addChild($th);
		return $th;
	}
			
}
class Table extends Element
{
	public function __construct($class='',$other=array()) {
		parent::__construct('table');
		if($class!='')
			$this->attributes['class']=$class;
		$this->setAttributes($other);
	}
	
	public function createRow($class='',array $other=array()) {
		$tr = new TableRow($class,$other);
		$this->addChild($tr);
		return $tr;
	}
	
	public function headingsRow(array $labels) {
		$tr = new Element('tr');
		foreach ($labels as $label) {
			$tr->addChild(new Element('th',array(),$label));
		}
		$this->addChild($tr);
		return $this;
	}
} 