package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;

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
		
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
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
	}
	// move this inside the rioter class
	/*private function updatePaths():Void
	{
		var paths : Array<Array<FlxPoint>>;	
		
		for (rioter in crowds)
		{
			if (rioter.isLeader)
			{
				paths  = new Array<Array<FlxPoint>>();
				
				for (rioterEnemy in crowds)
				{
					if (rioterEnemy.isLeader && rioterEnemy.faction == rioter.enemy)
					{
						var path : Array<FlxPoint>;
						path = findPath(rioter, rioterEnemy);
						
						if (path != null) paths.push (path);						
					}
				}
				
				if (paths.length == 1) // si un seul chemin
				{
					rioter.path = new FlxPath();
					rioter.path.start(paths[0]);
					rioter.alpha = .5;
				}
				// sinon si plusieurs chemins prendre le plus court
			}
		}
	}
	
	private function findPath(_unit:FlxSprite, _goal:FlxSprite ):Array<FlxPoint>
	{
		var pathPoints:Array<FlxPoint> = Reg.level.collidableTileLayers[0].findPath(
			FlxPoint.get(_unit.x + _unit.width / 2, _unit.y + _unit.height / 2),
			FlxPoint.get(_goal.x + _goal.width / 2, _goal.y + _goal.height / 2));
		return pathPoints;
	}	*/
}
