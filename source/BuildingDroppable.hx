package;

import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.FlxSprite;

/**
 * ...
 * @author ...
 */
class BuildingDroppable extends FlxSpriteGroup // uniquement utilisé pour placer les bâtiments et pour leur miniature dans l'UI
{
	
	public var type : Int;
	private var GFX : FlxSprite;
	public  var radius : Int;
	
	public function new(?X:Float=0, ?Y:Float=0, _t:Int) 
	{
		super(X, Y);
		type = _t;
		GFX  = new FlxSprite(-Reg.TILE_SIZE/2,-Reg.TILE_SIZE*2);
		GFX.loadGraphic("assets/images/tilemapBuilding.png", true, 16, 32);
		this.add(GFX);
		set(_t);
		
	}
	
	public function set (_t:Int)
	{
		switch(_t)
		{
			case 0:
				GFX.animation.frameIndex = 21;
			case 1:
				GFX.animation.frameIndex = 23;
			case 2:
				GFX.animation.frameIndex = 25;
		}
		
		
		type = _t;
	}
	
}