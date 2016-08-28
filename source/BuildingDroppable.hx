package;

import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.FlxSprite;

/**
 * ...
 * @author ...
 */
class BuildingDroppable extends FlxSpriteGroup // les GFX du batiment sont dans les calques building top et base, cette classe gère uniquement leurs paramètres PAS L'IMAGE AFFICHEE
{
	
	public var type : Int;
	private var GFX : FlxSprite;
	
	public function new(?X:Float=0, ?Y:Float=0, _t:Int) 
	{
		super(X, Y);
		type = _t;
		set(_t);
		
	}
	
	public function set (_t:Int)
	{
		GFX  = new FlxSprite(-Reg.TILE_SIZE/2,-Reg.TILE_SIZE*2);
		GFX.loadGraphic("assets/images/tilemapBuilding.png", true, 16, 32);
		switch(_t)
		{
			case 0:
				GFX.animation.frameIndex = 21;
			case 1:
				GFX.animation.frameIndex = 21;
			case 2:
				GFX.animation.frameIndex = 21;
			case 3:
				GFX.animation.frameIndex = 21;
		}
		
		this.add(GFX);
		type = _t;
	}
	
}