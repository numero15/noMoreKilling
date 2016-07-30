package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxTimer;

import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledTile;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.util.FlxColor;
import flixel.util.FlxPath;
import flixel.FlxCamera;
/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	public var prevMouseCoord : FlxPoint;
	private var timerFight : FlxTimer;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.debugger.visible = true;
		FlxG.log.redirectTraces = true;		
		
		super.create();
		bgColor = FlxColor.GRAY;
		
		Reg.level = new TiledLevel("assets/images/testbase.tmx", this);
		
		add(Reg.level.foregroundTiles);
		add(Reg.level.crowds);
		add(Reg.level.spawnTiles);		
		
		for (spawn in Reg.level.spawnTiles)
		{
			spawn.init();
		}
		
		FlxG.camera.zoom = .5;
		FlxG.camera.width = 960;
		FlxG.camera.height = 960;
		FlxG.camera.x = -240;
		FlxG.camera.y = -240;		
		prevMouseCoord = new FlxPoint(0, 0);
		
		timerFight = new FlxTimer();
		timerFight.start(1, updateFight, 0);
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void
	{
		FlxG.overlap(Reg.level.crowds, rioterCollide);
		
		if (FlxG.mouse.justPressed)
		{
			prevMouseCoord.x = FlxG.mouse.screenX;
			prevMouseCoord.y = FlxG.mouse.screenY;
		}
		
		if (FlxG.mouse.pressed)
		{
			FlxG.camera.scroll.x -= FlxG.mouse.screenX - prevMouseCoord.x;
			FlxG.camera.scroll.y -= FlxG.mouse.screenY - prevMouseCoord.y;
			prevMouseCoord.x = FlxG.mouse.screenX;
			prevMouseCoord.y = FlxG.mouse.screenY;
		}
		
		super.update(elapsed);
	}	
	
	private function rioterCollide(r1 : Rioter, r2 : Rioter):Void
	{
		
		//trace(r1);
		if (r1.faction != r2.faction)
		{
			r1.stopCrowd();
			r2.stopCrowd();
			
			r1.addOpponent(r2);
			r2.addOpponent(r1);
		}
	}
	
	private function updateFight(_t:FlxTimer):Void
	{
		
		
		
		for (r in Reg.level.crowds)
		{
			if (r.followNumber == 0  && r.alive) // agir seulement sur les leaders
			{
				r.fight(); // cacluler
			}
			
			if (!r.alive) 			
			{
				r.destroy();
				Reg.level.crowds.remove(r,true);				
			}
		}
		
		for (r in Reg.level.crowds)
		{
			
			if (r.followNumber == 0 && r.alive) // agir seulement sur les leaders
			{
				r.hit();// décompter les dégats
			}
		}
	}
}
