package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.input.mouse.FlxMouseEventManager;
/**
 * ...
 * @author ...
 */
class Building extends FlxSpriteGroup // les GFX du batiment sont dans les calques building top et base, cette classe gère uniquement leurs paramètres PAS L'IMAGE AFFICHEE
{
	public var type : String;
	private var animStartIndex : Int;
	private var timerAnimate : FlxTimer;
	public  var radius : Int;
	private var radiusGFX : FlxSprite;
	private var buildingHitbox : FlxSprite;
	public var effectMotivation : Int;
	public var effectHealth : Int;
	public var effectSpeed : Int;
	public var effectResource : Int;
	//private var stats:Xml;
	
	public function new(?X:Float=0, ?Y:Float=0, _t:String) 
	{
		super(X, Y);
		type = _t;
		//stats = Xml.parse(sys.io.File.getContent(AssetPaths.data__xml)).firstChild();
		 
		set(type);
	}
	
	public function set (_t:String)
	{
		ID = Reg.level.buildings.length;		
		
		for (_buildingStats in Reg.stats.elementsNamed("building"))
		{		
			if (_buildingStats.get('type') == type)
			{
				for ( _stat in _buildingStats.elements())
				{
					switch _stat.nodeName {
						case "motivation" :
							effectMotivation = Std.parseInt( _stat.get("value"));
						case "health" :
							effectHealth = Std.parseInt(_stat.get("value"));
						case "speed" :
							effectSpeed = Std.parseInt(_stat.get("value"));
						case "gold" :
							effectResource = Std.parseInt(_stat.get("value"));
					}
				}
			}			
		}
		
		buildingHitbox = new FlxSprite();
		buildingHitbox.makeGraphic(Reg.TILE_SIZE, Reg.TILE_SIZE * 2,0x00ffffff);
		buildingHitbox.y =-Reg.TILE_SIZE;
		
		
		radius = 2;
		
		radiusGFX = new FlxSprite();
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
		add(buildingHitbox);
		
		
		timerAnimate = new FlxTimer();
		timerAnimate.start(1, animate, 1);		
		type = _t;
		
		switch type
		{
			case "bar":
				animStartIndex = 0;
			case "garage":
				animStartIndex = 1;
			case "coffeeShop":
				animStartIndex = 2;
		}		
		
		Reg.level.buildingBase.setTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE), 47 + 3/*first GID*/ + animStartIndex*2);
		Reg.level.buildingTop.setTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE) - 1, 21 + 3/*first GID*/ + animStartIndex * 2);
		
		
		FlxMouseEventManager.add(buildingHitbox, onDown, onUp, onOver, onOut,false,true,false);
	}
	
	private function animate(Timer:FlxTimer):Void //change tile image
	{		
		if (Reg.level.buildingBase.getTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE)) % 2 == 1)
		{
			Reg.level.buildingBase.setTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE), 47 + 3 + animStartIndex*2/*first GID*/);
			Reg.level.buildingTop.setTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE)-1, 21 + 3 + animStartIndex*2/*first GID*/);
		}
		
		else
		{
			Reg.level.buildingBase.setTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE), 47 + 3 + animStartIndex*2 - 1/*first GID*/);
			Reg.level.buildingTop.setTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE)-1, 21 + 3 + animStartIndex*2 - 1/*first GID*/);
		}	
		timerAnimate.reset(FlxG.random.float(.25, 1));
	}	
	
	
	private function onDown(Sprite:FlxSprite)
	{
		radiusGFX.alpha = .15;
	}
	
	private function onOver(Sprite:FlxSprite) 
	{
		
	}
	
	private function onOut(Sprite:FlxSprite)
	{
		radiusGFX.alpha = 0;
	}
	
	private function onUp(Sprite:FlxSprite)
	{
		radiusGFX.alpha = 0;
	}
	
}