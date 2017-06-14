package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
//import flixel.util.FlxTimer;
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
	//private var timerAnimate : FlxTimer;
	public  var radius : Int;
	public var radiusGFX : FlxSprite;
	private var buildingHitbox : FlxSprite;
	public var effectMotivation : Int;
	public var effectHealth : Int;
	public var effectSpeed : Int;
	public var effectResource : Int;
	
	public var animateStartTick : Int;
	public var animateDelayTicks : Int;
	
	public var isSelected : Bool; // empèche les controles quand le building est modifié dans le menu pop up
	
	public function new(?X:Float=0, ?Y:Float=0, _t:String) 
	{
		super(X, Y);
		type = _t;		 
		set(type);
	}
	
	public function set (_t:String)
	{
		animateStartTick = FlxG.game.ticks;
		animateDelayTicks = 1000;
		ID = Reg.level.buildings.length;
		
		isSelected = false;
		
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
						case "cost" :
							Reg.money -=  Std.parseInt(_stat.get("value"));
						case "radius" :
							radius =  Std.parseInt(_stat.get("value"));
					}
				}
			}			
		}
		buildingHitbox = new FlxSprite();
		buildingHitbox.makeGraphic(Reg.TILE_SIZE, Reg.TILE_SIZE * 2,0x00ffffff);
		buildingHitbox.y =-Reg.TILE_SIZE;		
		
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
		//radiusGFX.updateHitbox();
		radiusGFX.alpha = 0;
		radiusGFX.y -= Reg.TILE_SIZE;
		
		add(radiusGFX);
		add(buildingHitbox);
		
		/*timerAnimate = new FlxTimer();
		timerAnimate.start(1, animate, 1);	*/	
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
		
		Reg.level.buildingBase.setTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE), 47/* + 3 first GID*/ + animStartIndex*2);
		Reg.level.buildingTop.setTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE) - 1, 21 /*+ 3 first GID*/ + animStartIndex * 2);
		
		
		FlxMouseEventManager.add(buildingHitbox, null, onUp, null, null,false,true,false);
	}
	
	public override function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (FlxG.game.ticks >= animateStartTick + animateDelayTicks)
		{
			animate();
			animateStartTick = FlxG.game.ticks;
		}
	}
	
	private function animate(/*Timer:FlxTimer*/):Void //change tile image
	{		
		if (Reg.level.buildingBase.getTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE)) % 2 == 0)
		{
			Reg.level.buildingBase.setTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE), 47 /*+ 3*/ + animStartIndex*2/*first GID*/);
			Reg.level.buildingTop.setTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE)-1, 21/* + 3 */+ animStartIndex*2/*first GID*/);
		}
		
		else
		{
			Reg.level.buildingBase.setTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE), 47/* + 3*/ + animStartIndex*2 - 1/*first GID*/);
			Reg.level.buildingTop.setTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE)-1, 21/* + 3*/ + animStartIndex*2 - 1/*first GID*/);
		}	
		//timerAnimate.reset(FlxG.random.float(.25, 1));
	}	
	
	
	private function onUp(Sprite:FlxSprite)
	{
		if (isSelected)
			return;
		
		if (radiusGFX.alpha == 0)
		{
			radiusGFX.alpha = .15;
		}
		
		else if (radiusGFX.alpha >0)
		{
			radiusGFX.alpha = 0;
		}
	}
	
	public function removeBuilding(/*?Sprite:FlxSprite*/)
	{
		trace("removeBuilding");
		Reg.level.buildings.remove(this);
		FlxMouseEventManager.add(buildingHitbox, null, onUp, null, null, false, true, false);
		//timerAnimate.cancel();
		//timerAnimate.destroy();
		radiusGFX.destroy();
		radiusGFX = null;
		buildingHitbox.destroy();
		buildingHitbox = null;
		Reg.level.buildingBase.setTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE), 0);
		Reg.level.buildingTop.setTile(Std.int(this.x / Reg.TILE_SIZE), Std.int(this.y / Reg.TILE_SIZE) - 1, 0);
		kill();
		destroy();		
	}
	
}