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
	
	public var type : String;
	private var GFX : FlxSprite;
	public  var radius : Int;
	public var effectMotivation : Int;
	public var effectHealth : Int;
	public var effectSpeed : Int;
	public var effectResource : Int;
	public var cost : Int = 0;
	public var isAffordable:Bool;
	
	public function new(?X:Float=0, ?Y:Float=0, _t:String) 
	{
		super(X, Y);
		type = _t;
		GFX  = new FlxSprite(-Reg.TILE_SIZE/2,-Reg.TILE_SIZE*2);
		GFX.loadGraphic("assets/images/tilemapBuilding.png", true, 16, 32);
		this.add(GFX);
		set(_t);
		effectHealth = effectMotivation = effectResource = effectSpeed = 0;		
	}
	
	public function set (_t:String)
	{
		switch(_t)
		{
			case "bar":
				GFX.animation.frameIndex = 21;
			case "garage":
				GFX.animation.frameIndex = 23;
			case "coffeeShop":
				GFX.animation.frameIndex = 25;
		}
		
		type = _t;
	}
	
	public function setAffordable() :Void
	{
		if (Reg.money - cost >= 0)
		{
			isAffordable = true;
			this.alpha = 1;
		}
		else
		{
			isAffordable = false;
			this.alpha = .5;
		}
	}
	
}