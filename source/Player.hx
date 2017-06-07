package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author numero 15
 */
class Player extends FlxSprite 
{

	public var haveCrowd : Bool;
	
	public function new(?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
	{
		super(X, Y, SimpleGraphic);
		
		this.loadGraphic("assets/images/crowd_yellow.png", true, 16, 16);
		updateHitbox();
		setSize(Reg.TILE_SIZE * 1.2, Reg.TILE_SIZE * 1.2);
		centerOffsets();
		
		haveCrowd = false;
	}
	
}