<?php
/**
 * QuickForm
 * 
 * @author N3X15
 */
 
class QF
{
	public static $buffer='';
	public static $hidden=array();
	public static function Start($action, $method='get',$other=array()) {
		$otheratt=self::FormatAttributes($other);
	 self::$buffer=<<<EOF
	 <form action="{$action}" method="{$method}"{$otheratt}>
		<table class="quickform">
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
		foreach(self::$hidden as $k=>$v){
			$attr=array(
				'type'=>'hidden',
				'name'=>$k,
				'value'=>$v
			);
			self::$buffer.='<input'.self::FormatAttributes($attr).' />';
		}
		self::$buffer.=<<<EOF
		</table>
	</form>
EOF;
		return self::$buffer;
	}
	
	public static function Textbox($name, $label, $default='', $other=array())
	{
		 self::Input('textbox',$name,$label,$default,$other);
	}
	
	public static function Password($name, $label, $default='', $other=array())
	{
		 self::Input('password',$name,$label,$default,$other);
	}
	
	public static function Email($name, $label, $default='', $other=array())
	{
		 self::Input('email',$name,$label,$default,$other);
	}
	
	public static function Button($type, $name, $label, $value=null, $other=array())
	{
		if($value!=null)
			$other['value']=$value;
		$otheratt=self::FormatAttributes($other);
		self::$buffer.=<<<EOF
			<tr>
				<td colspan="2">
					<button type="{$type}" name="{$name}"$otheratt>
						$label
					</button>
				</td>
			</tr>
EOF;
	}
	
	public static function Reset($name, $label, $default='', $other=array())
	{
		 self::Input('reset',$name,$label,$default,$other);
	}
	
	public static function Checkbox($name, $label, $value='', $other=array())
	{
		$otheratt=self::FormatAttributes($other);
		self::$buffer.=<<<EOF
			<tr>
				<td colspan="2">
					<input type="checkbox" name="$name" value="$default"{$otheratt}/> <label for="$name">$label</label>
				</td>
			</tr>
EOF;
	}
	
	public static function Submit($name, $label='Submit',$value=null, $other=array())
	{
		self::Button('submit',$name,$label,$value,$other);
	}
	
	public static function Input($type, $name, $label, $default='', $other=array())
	{
		$otheratt=self::FormatAttributes($other);
		self::$buffer.=<<<EOF
			<tr>
				<td>
					<label for="{$name}">{$label}</label>
				</td>
				<td>
					<input type="$type" name="$name" value="$default"$otheratt/>
				</td>
			</tr>
EOF;
	}
	
	public static function Hidden($name, $value)
	{
		$otheratt=self::FormatAttributes($other);
		self::$hidden[$name]=$value;
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
	public static function Select($name, $label, array $options, $default='', $other=array())
	{
		$otheratt=self::FormatAttributes($other);
		$loopO='';
		foreach($options as $k=>$v){
			$loopO.="\n\t\t\t\t\t\t<option value=\"$k\"".(($k==$default)?' selected="selected"':'').">$v</option>";
		}
		self::$buffer.=<<<EOF
			<tr>
				<td>
					<label for="$name">$label</label>
				</td>
				<td>
					<select name="$name"$otheratt>
$loopO
					</select>
				</td>
			</tr>
EOF;
	}
} 