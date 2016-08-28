package;

import flixel.FlxBasic;
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
	private var UI : HUD;
	private var cameraUI : FlxCamera;
	private var draggedBuilding : BuildingDroppable; // objet temporaire quand on drag drop un batiment
	private var draggedPower : Power; // objet temporaire quand on drag drop ou pouvoir
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.debugger.visible = true;
		FlxG.log.redirectTraces = true;		
		
		super.create();
		bgColor = FlxColor.GRAY;
		
		draggedBuilding = new BuildingDroppable(0, 0, 0);
		draggedBuilding.kill();
		
		draggedPower = new Power(0, 0, 0);
		draggedPower.kill();		
		
		Reg.level = new TiledLevel("assets/images/template.tmx", this);
		
		FlxG.camera.zoom = 1;
		FlxG.camera.width = 480;
		FlxG.camera.height = 480;
		FlxG.camera.x = 0;
		FlxG.camera.y = 0;	
		cameraUI = new FlxCamera(0, 0, Std.int(FlxG.width), Std.int(FlxG.height));
		cameraUI.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(cameraUI);		
		
		
		var activeCam : Array <FlxCamera>;		
		activeCam = new Array();
		activeCam.push(FlxG.cameras.list[1]);		
		
		Reg.level.foregroundTiles.cameras = [FlxG.cameras.list[0]];
		Reg.level.buildingBase.cameras = [FlxG.cameras.list[0]];
		Reg.level.buildingTop.cameras = [FlxG.cameras.list[0]];
		
		UI = new HUD();	
		
		add(Reg.level.foregroundTiles);
		add(Reg.level.buildings);
		add(Reg.level.buildingBase);
		add(Reg.level.crowds);
		add(Reg.level.spawnTiles);	
		add(Reg.level.buildingTop);
		add(UI);
		add(draggedBuilding);
		add(draggedPower);
		
		
		UI.cameras = activeCam;
		UI.forEach(function(_b:FlxBasic):Void
		{			
			_b.cameras = activeCam;
		});
		
		for (_b in UI.buildings)
		{
			_b.cameras = activeCam;
		}
		
		
		draggedBuilding.cameras = activeCam;
		
		
		
		
		for (spawn in Reg.level.spawnTiles)
		{
			spawn.init();
		}
		
			
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
			
			for (b in UI.buildings)
			{
				if ( b.overlapsPoint(FlxG.mouse.getScreenPosition(cameraUI)))
				{
					draggedBuilding.revive();
					draggedBuilding.set(b.type);
					draggedBuilding.x = FlxG.mouse.screenX;
					draggedBuilding.y = FlxG.mouse.screenY;
					draggedBuilding.scale.x = draggedBuilding.scale.y = FlxG.camera.zoom;
					draggedBuilding.updateHitbox();
					break;
				}
			}			
		}
		
		if (FlxG.mouse.pressed)
		{
			if (!UI.BG.overlapsPoint(FlxG.mouse.getScreenPosition()) && !draggedBuilding.alive  && !draggedPower.alive) // scroll map seulement si on n'est pas sur l'UI et que l'on ne drag pas de building/power
			{
				if( Std.int(Math.abs(FlxG.mouse.screenX - prevMouseCoord.x))/Reg.TILE_SIZE>1)
				{
					FlxG.camera.scroll.x -= Std.int((FlxG.mouse.screenX - prevMouseCoord.x)/Reg.TILE_SIZE) * Reg.TILE_SIZE;
					prevMouseCoord.x = FlxG.mouse.screenX;
				}
				if( Std.int(Math.abs(FlxG.mouse.screenY - prevMouseCoord.y))/Reg.TILE_SIZE>1)
				{
					FlxG.camera.scroll.y -= Std.int((FlxG.mouse.screenY - prevMouseCoord.y)/Reg.TILE_SIZE) * Reg.TILE_SIZE;		
					prevMouseCoord.y = FlxG.mouse.screenY;
				}
			}
			
			if (draggedBuilding.alive)
				{
					
					draggedBuilding.x = Std.int((FlxG.mouse.getScreenPosition(cameraUI).x )/ (Reg.TILE_SIZE * FlxG.camera.zoom)) * (Reg.TILE_SIZE * FlxG.camera.zoom);
					
					//draggedBuilding.x = Std.int(FlxG.mouse.getScreenPosition(cameraUI).x / (Reg.TILE_SIZE * FlxG.camera.zoom)) * (Reg.TILE_SIZE * FlxG.camera.zoom) - FlxG.camera.scroll.x % Reg.TILE_SIZE * FlxG.camera.zoom ;

					draggedBuilding.y = Std.int(FlxG.mouse.getScreenPosition(cameraUI).y / (Reg.TILE_SIZE * FlxG.camera.zoom)) * (Reg.TILE_SIZE * FlxG.camera.zoom)/* - FlxG.camera.scroll.y % Reg.TILE_SIZE * FlxG.camera.zoom*/;
					
					//trace(Reg.level.foregroundTiles.getTile(Std.int(FlxG.mouse.x / Reg.TILE_SIZE), Std.int(FlxG.mouse.y / Reg.TILE_SIZE)));
					
					if (Reg.level.foregroundTiles.getTile(Std.int(FlxG.mouse.x / Reg.TILE_SIZE), Std.int(FlxG.mouse.y / Reg.TILE_SIZE)) == 68 
					&& Reg.level.buildingBase.getTile(Std.int(FlxG.mouse.x / Reg.TILE_SIZE), Std.int(FlxG.mouse.y / Reg.TILE_SIZE)) == 0 )
					{
						draggedBuilding.alpha = 1;
					}
					else
					{
						draggedBuilding.alpha = .5;
					}
				}
			
			
		}
		
		if (FlxG.mouse.justReleased)
		{
			if (draggedBuilding.alive)
			{
				if (Reg.level.foregroundTiles.getTile(Std.int(FlxG.mouse.x / Reg.TILE_SIZE), Std.int(FlxG.mouse.y / Reg.TILE_SIZE)) == 68 
					&& Reg.level.buildingBase.getTile(Std.int(FlxG.mouse.x / Reg.TILE_SIZE), Std.int(FlxG.mouse.y / Reg.TILE_SIZE)) == 0 )
				{
					var _b : Building = new Building(Std.int(FlxG.mouse.x / Reg.TILE_SIZE) * Reg.TILE_SIZE, Std.int(FlxG.mouse.y / Reg.TILE_SIZE)* Reg.TILE_SIZE, draggedBuilding.type);
					
					_b.cameras = [FlxG.cameras.list[0]];
					Reg.level.buildings.add(_b);
				}
				draggedBuilding.kill();
			}
			
			if (draggedPower.alive)
			{
				draggedPower.kill();
			}
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
