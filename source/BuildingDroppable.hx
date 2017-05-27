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
	public  var radius : Int = 3;
	public var effectMotivation : Int;
	public var effectHealth : Int;
	public var effectSpeed : Int;
	public var effectResource : Int;
	public var cost : Int = 0;
	public var isAffordable:Bool;
	public var radiusGFX :FlxSprite;
	
	public function new(?X:Float=0, ?Y:Float=0, _t:String) 
	{
		super(X, Y);
		type = _t;
		GFX  = new FlxSprite(-Reg.TILE_SIZE/2,-Reg.TILE_SIZE*2);
		GFX.loadGraphic("assets/images/tilemapBuilding.png", true, 16, 32);
		radiusGFX = new FlxSprite();
		add(radiusGFX);
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
		
		radiusGFX.makeGraphic((radius * 2 + 1) * Reg.TILE_SIZE, (radius * 2 + 1) * Reg.TILE_SIZE, FlxColor.TRANSPARENT);
		radiusGFX.x = radiusGFX.y = -radius * Reg.TILE_SIZE;
		
		var _brush : FlxSprite;
		_brush = new FlxSprite();
		_brush.makeGraphic(16, 16, FlxColor.RED);
		
		for (distX in 0...radius*2+1)
		{			
			
			if (distX <= radius)
			{
				for (distY in radius - distX...radius - distX + (distX * 2) + 1)
				{
					radiusGFX.stamp(_brush, distX * Reg.TILE_SIZE, distY * Reg.TILE_SIZE);
					
				}
			}
			else
			{
				for (distY in distX - radius...radius * 2 + 1 - (distX-radius))
				{
					radiusGFX.stamp(_brush, distX * Reg.TILE_SIZE, distY * Reg.TILE_SIZE);
					
				}
			}
		}
		radiusGFX.updateHitbox();
		radiusGFX.alpha = .15;
		radiusGFX.x = x - radiusGFX.width / 2;
		radiusGFX.y = y - radiusGFX.height / 2 - Reg.TILE_SIZE / 2;
		
		
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