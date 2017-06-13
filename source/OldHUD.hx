package;

import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import openfl.display.BitmapData;
import flixel.math.FlxPoint;
/**
 * ...
 * @author ...
 */
class OldHUD extends FlxGroup
{
	
	public var buildings : FlxTypedGroup<BuildingDroppable>;
	public var BG : FlxSprite;
	private var miniMap : FlxSprite;
	private var buildingsStats: Xml;
	private var moneyText : FlxText;
	private var prevMoney : Int;
	private var btn_pause : FlxButton;
	private var parentState : PlayState;
	
	public function new(_ps :PlayState) 
	{
		super();
		
		parentState = _ps;
		
		buildingsStats = Xml.parse(sys.io.File.getContent("assets/data/data.xml")).firstChild();		
		
		BG = new FlxSprite();
		BG.makeGraphic(480, 64);
		BG.alpha = .5;
		BG.x = (FlxG.width - BG.width) / 2;
		BG.y = (FlxG.height - BG.height);
		BG.scrollFactor.set(0, 0);
		
		moneyText = new FlxText(0, 0, "0",13);
		moneyText.wordWrap = false;
		moneyText.autoSize = true;
		moneyText.x = FlxG.width / 2;
		moneyText.y = 16;
		
		btn_pause = new FlxButton(32, 32, "", _ps.pause);	
		btn_pause.loadGraphic ("assets/images/btn_pause.png");
		
		buildings = new  FlxTypedGroup<BuildingDroppable>();
		
		var i : Int = 0;
		var _b : BuildingDroppable;
		for (_buildingStats in buildingsStats.elementsNamed("building")) {
			i++;
			_b = new BuildingDroppable(BG.x + i * Reg.TILE_SIZE * 2 + Reg.TILE_SIZE, BG.y + Reg.TILE_SIZE * 3, _buildingStats.get("type"));
			_b.scrollFactor.set(0, 0);
			
			for ( _stat in _buildingStats.elements())
			{
				switch _stat.nodeName {
					case "motivation" :
						_b.effectMotivation = Std.parseInt( _stat.get("value"));
					case "health" :
						_b.effectHealth = Std.parseInt(_stat.get("value"));
					case "speed" :
						_b.effectSpeed = Std.parseInt(_stat.get("value"));
					case "resource" :
						_b.effectResource = Std.parseInt(_stat.get("value"));
					case "cost" :
						_b.cost = Std.parseInt(_stat.get("value"));
				}
			}	
			
			_b.remove(_b.radiusGFX);
			buildings.add(_b);
		}
		
		miniMap = getMiniMap();
		/*miniMap.scale.x = miniMap.scale.y = 2;
		miniMap.updateHitbox();*/
		miniMap.x = FlxG.width - miniMap.width;
		
		add(BG);
		add(moneyText);
		add(buildings);
		add(miniMap);
		add(btn_pause);
	}
	
	public function getMiniMap(?wallColor:Int = 0x00000000, ?openColor:Int = 0xFF909090):FlxSprite
	{
		//Create Minimap
		var minimap:FlxSprite = new FlxSprite();
		minimap.makeGraphic(Reg.level.foregroundTiles.widthInTiles, Reg.level.foregroundTiles.heightInTiles, 0xFFFF0000);
		
		//Set bitmap data
		var bData:BitmapData = new BitmapData(Reg.level.foregroundTiles.widthInTiles, Reg.level.foregroundTiles.heightInTiles);
		for (i in 0...Reg.level.foregroundTiles.totalTiles) {
			if (!Reg.level.foregroundTiles.overlapsPoint(FlxPoint.get(i % Reg.level.foregroundTiles.widthInTiles * 16, i / Reg.level.foregroundTiles.widthInTiles * 16))) bData.setPixel32(i % Reg.level.foregroundTiles.widthInTiles, Math.floor(i / Reg.level.foregroundTiles.widthInTiles), openColor);
			else bData.setPixel32(i % Reg.level.foregroundTiles.widthInTiles, Math.floor(i / Reg.level.foregroundTiles.widthInTiles), wallColor);
		}
		
		//Set Minimap bitmap data
		minimap.pixels = bData;
		return minimap;
	}
	
	private function setAffordables():Void
	{
		for (_b in buildings)
		{
			_b.setAffordable();
		}
	}
	
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		moneyText.text = Std.string(Reg.money +" §");
		moneyText.x = (FlxG.width - moneyText.width) / 2;
		
		if (prevMoney != Reg.money)
		setAffordables();
		
		/*for (i in 0...Reg.level.foregroundTiles.totalTiles) {
			if (!Reg.level.foregroundTiles.overlapsPoint(FlxPoint.get(i % Reg.level.foregroundTiles.widthInTiles * 16, i / Reg.level.foregroundTiles.widthInTiles * 16))) miniMap.pixels.setPixel(i % Reg.level.foregroundTiles.widthInTiles, Math.floor(i / Reg.level.foregroundTiles.widthInTiles), 0xFF909090);
		}
		
		for (_r in Reg.level.crowds)
		{
			if (_r.alive)
			{
				switch(_r.faction)			
				{
					case "red":
						miniMap.pixels.setPixel(Std.int(_r.x / Reg.TILE_SIZE), Std.int(_r.y / Reg.TILE_SIZE), 0xFF0000);
						
					case "yellow":
						miniMap.pixels.setPixel(Std.int(_r.x/Reg.TILE_SIZE),Std.int(_r.y/Reg.TILE_SIZE), 0xFFFF00);
				}	
			}
		}*/
	}
	
}