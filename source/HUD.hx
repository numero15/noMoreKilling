package;

import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxG;
/**
 * ...
 * @author ...
 */
class HUD extends FlxGroup
{
	
	public var buildings : FlxTypedGroup<Building>;
	public var BG : FlxSprite;
	
	public function new() 
	{
		super();
		BG = new FlxSprite();
		BG.makeGraphic(512, 128);
		BG.alpha = .5;
		BG.x = (FlxG.width - BG.width) / 2;
		BG.y = (FlxG.height - BG.height);
		BG.scrollFactor.set(0, 0);
		
		add(BG);
		
		buildings = new  FlxTypedGroup<Building>();
		for (i in 0...4)
		{
			buildings.add(new Building(BG.x + i * 128, BG.y, i));
		}
		for (b in buildings)
		{
			b.scrollFactor.set(0, 0);
		}
		add(buildings);
	}
	
}