package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxG;
/**
 * ...
 * @author ...
 */
class Building extends FlxSpriteGroup // les GFX du batiment sont dans les calques building top et base, cette classe gère uniquement leurs paramètres PAS L'IMAGE AFFICHEE
{
	public var type : Int;
	private var timerFlash : FlxTimer;
	public  var radius : Int;
	private var base : FlxSprite;
	private var radiusGFX : FlxSprite;
	
	public function new(?X:Float=0, ?Y:Float=0, _t:Int) 
	{
		super(X, Y);
		type = _t;
		set(_t);
	}
	
	public function set (_t:Int)
	{
		ID = Reg.level.buildings.length;	
		
		radius = 2;
		
		radiusGFX = new FlxSprite();
		//radiusGFX.width = radiusGFX.height = (radius * 2 + 1) * Reg.TILE_SIZE;
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
		radiusGFX.alpha = .15;
		add(radiusGFX);
		
		
		timerFlash = new FlxTimer();
		timerFlash.start(1, flash, 1);
			
			
		Reg.level.buildingBase.setTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE), 47 + 3/*first GID*/ + type*2);
		Reg.level.buildingTop.setTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE)-1, 21 + 3/*first GID*/ + type*2);
		/*switch(_t)
		{
			case 0:
				this.makeGraphic(Reg.TILE_SIZE, Reg.TILE_SIZE, FlxColor.PURPLE);
			case 1:
				this.makeGraphic(Reg.TILE_SIZE, Reg.TILE_SIZE, FlxColor.LIME);
			case 2:
				this.makeGraphic(Reg.TILE_SIZE, Reg.TILE_SIZE, FlxColor.ORANGE);
			case 3:
				this.makeGraphic(Reg.TILE_SIZE, Reg.TILE_SIZE, FlxColor.PINK);
		}*/
		
		type = _t;
	}
	
	private function flash(Timer:FlxTimer):Void
	{		
		if (Reg.level.buildingBase.getTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE)) % 2 == 1)
		{
			Reg.level.buildingBase.setTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE), 47 + 3 + type*2/*first GID*/);
			Reg.level.buildingTop.setTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE)-1, 21 + 3 + type*2/*first GID*/);
		}
		
		else
		{
			Reg.level.buildingBase.setTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE), 47 + 3 + type*2 - 1/*first GID*/);
			Reg.level.buildingTop.setTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE)-1, 21 + 3 + type*2 - 1/*first GID*/);
		}	
		timerFlash.reset(FlxG.random.float(.25, 1));
	}	
}