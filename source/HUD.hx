package;

import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxG;
import openfl.display.BitmapData;
import flixel.math.FlxPoint;
/**
 * ...
 * @author ...
 */
class HUD extends FlxGroup
{
	
	public var buildings : FlxTypedGroup<BuildingDroppable>;
	public var BG : FlxSprite;
	private var miniMap : FlxSprite;
	
	public function new() 
	{
		super();
		BG = new FlxSprite();
		BG.makeGraphic(480, 64);
		BG.alpha = .5;
		BG.x = (FlxG.width - BG.width) / 2;
		BG.y = (FlxG.height - BG.height);
		BG.scrollFactor.set(0, 0);
		
		add(BG);
		
		buildings = new  FlxTypedGroup<BuildingDroppable>();
		for (i in 0...3)
		{
			buildings.add(new BuildingDroppable(BG.x + i * Reg.TILE_SIZE*2 + Reg.TILE_SIZE, BG.y + Reg.TILE_SIZE*3, i));
		}
		for (b in buildings)
		{
			b.scrollFactor.set(0, 0);
		}
		add(buildings);
		
		miniMap = getMiniMap();
		/*miniMap.scale.x = miniMap.scale.y = 2;
		miniMap.updateHitbox();*/
		miniMap.x = FlxG.width - miniMap.width;
		add(miniMap);
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
	
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		for (i in 0...Reg.level.foregroundTiles.totalTiles) {
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
		}
	}
	
}