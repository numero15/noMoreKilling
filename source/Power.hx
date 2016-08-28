package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

/**
 * ...
 * @author ...
 */
class Power extends FlxSprite
{

	public function new(?X:Float=0, ?Y:Float=0, type:Int) 
	{
		super(X, Y);
		switch(type)
		{
			case 0:
				this.makeGraphic(Reg.TILE_SIZE, Reg.TILE_SIZE, FlxColor.PURPLE);
			case 1:
				this.makeGraphic(Reg.TILE_SIZE, Reg.TILE_SIZE, FlxColor.LIME);
			case 2:
				this.makeGraphic(Reg.TILE_SIZE, Reg.TILE_SIZE, FlxColor.ORANGE);
			case 3:
				this.makeGraphic(Reg.TILE_SIZE, Reg.TILE_SIZE, FlxColor.PINK);
		}
	}
	
}