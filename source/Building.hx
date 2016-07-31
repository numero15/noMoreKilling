package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

/**
 * ...
 * @author ...
 */
class Building extends FlxSprite
{
	
	public var type : Int;
	
	public function new(?X:Float=0, ?Y:Float=0, _t:Int) 
	{
		super(X, Y);
		type = _t;
		set(_t);
		
	}
	
	public function set (_t:Int)
	{
		switch(_t)
		{
			case 0:
				this.makeGraphic(128, 128, FlxColor.PURPLE);
			case 1:
				this.makeGraphic(128, 128, FlxColor.LIME);
			case 2:
				this.makeGraphic(128, 128, FlxColor.ORANGE);
			case 3:
				this.makeGraphic(128, 128, FlxColor.PINK);
		}
		
		type = _t;
	}
	
}