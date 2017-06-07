package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.system.scaleModes.BaseScaleMode;
import flixel.system.scaleModes.FillScaleMode;
import flixel.system.scaleModes.FixedScaleMode;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.system.scaleModes.RelativeScaleMode;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.system.scaleModes.PixelPerfectScaleMode;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxTimer;
//import flixel.util.FlxTimer;
import flixel.input.mouse.FlxMouseEventManager;

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
	//var timerFight : FlxTimer;
	var UI : HUD;
	var cameraUI : FlxCamera;
	var cameraDroppable : FlxCamera;
	var draggedBuilding : BuildingDroppable; // objet temporaire quand on drag drop un batiment
	var draggedPower : Power; // objet temporaire quand on drag drop ou pouvoir
	
	var oriCameraZoom:Float;
    var oriCameraWidth:Int;
    var oriCameraHeight:Int;
	
	public var fightStartTick : Int;
	public var fightDelayTicks : Int;
	
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.debugger.visible = true;
		FlxG.log.redirectTraces = false;	
		//FlxG.scaleMode = new PixelPerfectScaleMode();
		FlxG.plugins.add(new FlxMouseEventManager());
		
		Reg.money = 100;
		Reg.stats = Xml.parse(sys.io.File.getContent("assets/data/data.xml")).firstChild();
		Reg.currentLeaderID = 0;
		
		super.create();
		bgColor = FlxColor.GRAY;	
		
		Reg.level = new TiledLevel("assets/images/template.tmx", this);
		
		FlxG.camera.zoom = 1;
		FlxG.camera.width = 480;
		FlxG.camera.height = 480;
		FlxG.camera.x = 0;
		FlxG.camera.y = 0;
		cameraUI = new FlxCamera(0, 0, Std.int(FlxG.width), Std.int(FlxG.height));
		cameraUI.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(cameraUI);			
		cameraDroppable = new FlxCamera(0, 0, Std.int(FlxG.width), Std.int(FlxG.height));
		cameraDroppable.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(cameraDroppable);	
		
		oriCameraZoom = FlxG.camera.zoom;
        oriCameraWidth = FlxG.camera.width;
        oriCameraHeight = FlxG.camera.height;
		
		
		var activeCam : Array <FlxCamera>;		
		activeCam = new Array();
		activeCam.push(FlxG.cameras.list[1]);
		
		Reg.level.foregroundTiles.cameras = [FlxG.cameras.list[0]];
		Reg.level.buildingBase.cameras = [FlxG.cameras.list[0]];
		Reg.level.fog01.cameras = [FlxG.cameras.list[0]];
		Reg.level.buildingTop.cameras = [FlxG.cameras.list[0]];
		Reg.level.fog02.cameras = [FlxG.cameras.list[0]];
		Reg.level.player.cameras = [FlxG.cameras.list[0]];
		
		draggedBuilding = new BuildingDroppable(0, 0, "bar");
		draggedBuilding.kill();
		draggedBuilding.cameras = [FlxG.cameras.list[2]];
		
		draggedPower = new Power(0, 0, 0);
		draggedPower.kill();
		draggedPower.cameras = [FlxG.cameras.list[2]];
		
		UI = new HUD(this);	
		
		add(Reg.level.foregroundTiles);
		add(Reg.level.buildings);
		add(Reg.level.buildingBase);
		add(Reg.level.crowds);
		add(Reg.level.player);
		//add(Reg.level.fog01);
		//add(Reg.level.fog02);
		add(Reg.level.spawnTiles);
		add(Reg.level.UIBars);
		add(Reg.level.buildingTop);			
		add(Reg.level.UIBtnsClose);
		add(UI);
		add(draggedBuilding);
		//add(draggedPower);
		
		UI.cameras = activeCam;
		UI.forEach(function(_b:FlxBasic):Void
		{			
			_b.cameras = activeCam;
		});
		
		for (_b in UI.buildings)
		{
			_b.cameras = activeCam;
		}
		
		for (spawn in Reg.level.spawnTiles)
		{
			spawn.init();
		}
		
		prevMouseCoord = new FlxPoint(0, 0);
		
		//timerFight = new FlxTimer();
		//timerFight.start(1, updateFight, 0);
		fightStartTick = FlxG.game.ticks;
		fightDelayTicks = 1000;
		
		pause();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void
	{		
		Reg.level.moveFog();
		
		FlxG.overlap(Reg.level.player, Reg.level.crowds, openSubStateDialogue);
		
		if (FlxG.game.ticks >= fightStartTick + fightDelayTicks)
		{
			updateFight();
			fightStartTick = FlxG.game.ticks;
		}
		
		if (FlxG.mouse.justPressed)
		{
			prevMouseCoord.x = FlxG.mouse.screenX;
			prevMouseCoord.y = FlxG.mouse.screenY;
			
			for (b in UI.buildings)
			{
				if ( b.overlapsPoint(FlxG.mouse.getScreenPosition(cameraUI)) && b.isAffordable)
				{
					draggedBuilding.revive();
					draggedBuilding.set(b.type);
					draggedBuilding.x = FlxG.mouse.screenX;
					draggedBuilding.y = FlxG.mouse.screenY;
					draggedBuilding.updateHitbox();
					break;
				}
			}			
		}
		
		if (FlxG.mouse.pressed)
		{
			if (!UI.BG.overlapsPoint(FlxG.mouse.getScreenPosition()) && !draggedBuilding.alive  && !draggedPower.alive) // scroll map seulement si on n'est pas sur l'UI et que l'on ne drag pas de building/power
			{
				FlxG.camera.scroll.x -= Std.int((FlxG.mouse.screenX - prevMouseCoord.x)/*/Reg.TILE_SIZE*/) /** Reg.TILE_SIZE*/;
				prevMouseCoord.x = FlxG.mouse.screenX;
				FlxG.camera.scroll.y -= Std.int((FlxG.mouse.screenY - prevMouseCoord.y)/*/Reg.TILE_SIZE*/) /** Reg.TILE_SIZE*/;
				prevMouseCoord.y = FlxG.mouse.screenY;
				
				cameraDroppable.scroll.x = FlxG.camera.scroll.x;
				cameraDroppable.scroll.y = FlxG.camera.scroll.y;
			}
			
			if (draggedBuilding.alive)
			{
				
				/*draggedBuilding.x = Std.int((FlxG.mouse.getScreenPosition(cameraUI).x )/ (Reg.TILE_SIZE * FlxG.camera.zoom)) * (Reg.TILE_SIZE * FlxG.camera.zoom)// + (Reg.TILE_SIZE - FlxG.camera.scroll.x % Reg.TILE_SIZE - Reg.TILE_SIZE);  TODO ajuster au zoom, utiliser des var
				if (FlxG.camera.scroll.x % Reg.TILE_SIZE != 0)
					{
						draggedBuilding.x += Reg.TILE_SIZE - (FlxG.camera.scroll.x % Reg.TILE_SIZE);
					}
				draggedBuilding.y = Std.int(FlxG.mouse.getScreenPosition(cameraUI).y / (Reg.TILE_SIZE * FlxG.camera.zoom)) * (Reg.TILE_SIZE * FlxG.camera.zoom)// + ( Reg.TILE_SIZE - FlxG.camera.scroll.y % Reg.TILE_SIZE - Reg.TILE_SIZE);
				if (FlxG.camera.scroll.y % Reg.TILE_SIZE != 0)
					{
						draggedBuilding.y += Reg.TILE_SIZE - (FlxG.camera.scroll.y % Reg.TILE_SIZE);
						trace(FlxG.camera.scroll.y % Reg.TILE_SIZE);
					}
				*/
				if (Reg.level.foregroundTiles.getTile(Std.int(FlxG.mouse.x / Reg.TILE_SIZE), Std.int(FlxG.mouse.y / Reg.TILE_SIZE)) == 67 
				&& Reg.level.buildingBase.getTile(Std.int(FlxG.mouse.x / Reg.TILE_SIZE), Std.int(FlxG.mouse.y / Reg.TILE_SIZE)) == 0 )
					draggedBuilding.alpha = 1;
				
				else
					draggedBuilding.alpha = .35;					
			}
			
			if (draggedBuilding.alive)
			{
				draggedBuilding.x = Std.int(FlxG.mouse.x / Reg.TILE_SIZE) * Reg.TILE_SIZE - draggedBuilding.width/2 + Reg.TILE_SIZE / 2; //formule de merde
				draggedBuilding.y = Std.int(FlxG.mouse.y / Reg.TILE_SIZE) * Reg.TILE_SIZE - draggedBuilding.height/2 + Reg.TILE_SIZE;//formule de merde
			}
		}
		
		if (FlxG.mouse.justReleased)
		{
			if (draggedBuilding.alive)
			{
				if (Reg.level.foregroundTiles.getTile(Std.int(FlxG.mouse.x / Reg.TILE_SIZE), Std.int(FlxG.mouse.y / Reg.TILE_SIZE)) == 67
					&& Reg.level.buildingBase.getTile(Std.int(FlxG.mouse.x / Reg.TILE_SIZE), Std.int(FlxG.mouse.y / Reg.TILE_SIZE)) == 0 )
				{
					var _b : Building = new Building(Std.int(FlxG.mouse.x / Reg.TILE_SIZE) * Reg.TILE_SIZE, Std.int(FlxG.mouse.y / Reg.TILE_SIZE)* Reg.TILE_SIZE, draggedBuilding.type);
					
					_b.cameras = [FlxG.cameras.list[0]];
					Reg.level.buildings.add(_b);
				}
				draggedBuilding.kill();
			}
			
			if (draggedPower.alive)
				draggedPower.kill();
		}
		
		if (FlxG.mouse.wheel != 0)
			ZoomCamera(FlxG.mouse.wheel / 10);
		
		super.update(elapsed);
	}	
	
	 function ZoomCamera(val:Float):Void
    {
       var prevCenterCoord : FlxPoint = FlxG.mouse.getWorldPosition(FlxG.camera);
		
		
        FlxG.camera.zoom += val;
		if ( FlxG.camera.zoom < 1)		
			FlxG.camera.zoom = 1;
			
		if ( FlxG.camera.zoom > 3)		
			FlxG.camera.zoom = 3;
		
		
		cameraDroppable.zoom = FlxG.camera.zoom;
		
        var newWidth:Float = oriCameraZoom / FlxG.camera.zoom * oriCameraWidth;
        var newHeight:Float = oriCameraZoom / FlxG.camera.zoom * oriCameraHeight;
        var newX:Float = (FlxG.width-FlxG.camera.width);
        var newY:Float = (FlxG.height - FlxG.camera.height);
       
        if ( FlxG.camera.zoom <= 1)
		{
			FlxG.camera.setSize(Std.int(newWidth), Std.int(newHeight));
			cameraDroppable.setSize(Std.int(newWidth), Std.int(newHeight));
		}
		
        FlxG.camera.setPosition( - FlxG.camera.width / 2 + oriCameraWidth / 2, - FlxG.camera.height / 2 + oriCameraHeight / 2);
		cameraDroppable.setPosition( - FlxG.camera.width / 2 + oriCameraWidth / 2, - FlxG.camera.height / 2 + oriCameraHeight / 2);
       
        Reg.level.foregroundTiles.updateBuffers();
		Reg.level.buildingBase.updateBuffers();
		Reg.level.buildingTop.updateBuffers();
		
		var centerCoord : FlxPoint = FlxG.mouse.getWorldPosition(FlxG.camera);
		
		FlxG.camera.scroll.x += (prevCenterCoord.x - centerCoord.x);		
		FlxG.camera.scroll.y += (prevCenterCoord.y - centerCoord.y);
		
		cameraDroppable.scroll.x = FlxG.camera.scroll.x;
		cameraDroppable.scroll.y = FlxG.camera.scroll.y;
    }

	private function updateFight(/*_t:FlxTimer*/):Void
	{		
		for (r in Reg.level.crowds)
		{
			if (r.followNumber == 0  && r.alive) // agir seulement sur les leaders
			{
				r.fight(); // cacluler
			}
			
			if (!r.alive) 			
			{
				//r.destroy();
				//Reg.level.crowds.remove(r,true);
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
	
	public function openSubStateDialogue(_p:Player, _r:Rioter):Void
	{
		if (_p.haveCrowd)
			return;
		
		_p.x = _r.x;
		_p.y = _r.y;
		// This is temp substate, it will be destroyed after closing
		FlxTimer.globalManager.active = false;
		//FlxTween.globalManager.active = false;
		var state:SubStateDialogue = new SubStateDialogue();
		state.setup(_p,_r);
		openSubState(state);
	}
	
	public function pause():Void
	{
		// This is temp substate, it will be destroyed after closing
		FlxTimer.globalManager.active = false;
		//FlxTween.globalManager.active = false;
		var state:SubStateFight = new SubStateFight();
		openSubState(state);
	}
}
