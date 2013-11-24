<?php
/**
 * Significantly older code, used to add inputs in arbitrary locations with proper formatting.
 * 
 * @author N3X15
 */
 
class PForm
{
	public static $buffer='';
	public static $hidden=array();
	public static function Start($action, $method='get',$other=array()) {
		$otheratt=self::FormatAttributes($other);
	 return <<<EOF
	 <form action="{$action}" method="{$method}"{$otheratt}>
EOF;
	}
	
	public static function FormatAttributes($attributes)
	{
		if(!is_array($attributes) || count($attributes)==0)
			return '';
		$o=array();
		foreach($attributes as $k=>$v)
		{
			$o[]="{$k}=\"".htmlentities($v,ENT_QUOTES,'ISO-8859-1',false)."\"";
		}
		return ' '.implode(' ',$o);
	}
	
	public static function End()
	{
		return <<<EOF
	</form>
EOF;
	}
	
	public static function Textbox($name, $default='', $other=array())
	{
		 return self::Input('textbox',$name,$default,$other);
	}
	
	public static function Password($name, $default='', $other=array())
	{
		 return self::Input('password',$name,$default,$other);
	}
	
	public static function Email($name, $default='', $other=array())
	{
		 return self::Input('email',$name,$default,$other);
	}
	
	public static function Button($type, $name, $label, $value=null, $other=array())
	{
		if($value!=null)
			$other['value']=$value;
		$otheratt=self::FormatAttributes($other);
		return <<<EOF
			<button type="{$type}" name="{$name}"$otheratt>
				$label
			</button>
EOF;
	}
	
	public static function Reset($name, $label='Reset', $value=null, $other=array())
	{
		return self::Button('reset',$name,$label,$value,$other);
	}
	
	public static function Checkbox($name, $value='1', $other=array())
	{
		$otheratt=self::FormatAttributes($other);
		return <<<EOF
			<input type="checkbox" name="$name" value="$default"{$otheratt}/>
EOF;
	}
	
	public static function Submit($name, $label='Submit', $value=null, $other=array())
	{
		return self::Button('submit',$name,$label,$value,$other);
	}
	
	public static function Input($type, $name, $default='', $other=array())
	{
		$otheratt=self::FormatAttributes($other);
		return <<<EOF
			<input type="$type" name="$name" value="$default"$otheratt/>
EOF;
	}
	
	public static function Hidden($name, $value)
	{
		return self::Input('hidden', $name,'',$value);
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
	public static function Select($name, array $options, $default='', $other=array())
	{
		$otheratt=self::FormatAttributes($other);
		$loopO='';
		foreach($options as $k=>$v){
			$loopO.="\n\t\t\t\t\t\t<option value=\"$k\"".(($k==$default)?' selected="selected"':'').">$v</option>";
		}
		return <<<EOF
			<select name="$name"$otheratt>
$loopO
			</select>
EOF;
	}
} 