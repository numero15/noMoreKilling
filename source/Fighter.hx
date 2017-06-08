package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author numero 15
 */
class Fighter extends FlxSprite 
{
	public var faction : UInt;

	public function new(?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
	{
		super(X, Y, SimpleGraphic);		
	}
	
	public function setup():Void
	{
		
	}
	
	override function update(elapsed: Float):Void
	{
		if (health < 0) kill();
		super.update(elapsed);
	}
	
}