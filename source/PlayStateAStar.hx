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
import flixel.ui.FlxButton;
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
	var cameraUI : FlxCamera;
	var cameraDroppable : FlxCamera;
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
		Reg.buildingsAvailables = ["bar","garage","coffeeShop"];
		
		super.create();
		bgColor = FlxColor.GRAY;	
	
		
		Reg.level = new TiledLevel("assets/images/template.tmx", this);
		
		FlxG.camera.zoom = 1;
		FlxG.camera.width = 854;
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
		Reg.level.buildingButtons.cameras = [FlxG.cameras.list[0]];
		
		draggedPower = new Power(0, 0, 0);
		draggedPower.kill();
		draggedPower.cameras = [FlxG.cameras.list[2]];
		
		Reg.level.UI = new HUD(this);	
		
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
		add(Reg.level.buildingButtons);
		add(Reg.level.UI);
		
		Reg.level.UI.cameras = activeCam;
		Reg.level.UI.forEach(function(_b:FlxBasic):Void
		{			
			_b.cameras = activeCam;
		});
		
		for (_b in Reg.level.UI.buildings)
		{
			_b.cameras = activeCam;
		}
		
		for (spawn in Reg.level.spawnTiles)
		{
			spawn.init();
		}
		
		
		for (_b in Reg.level.buildingButtons)
		{
			_b.onUp.callback = Reg.level.UI.openBuildingMenu.bind(_b);
		}
		
		prevMouseCoord = new FlxPoint(0, 0);
		
		//timerFight = new FlxTimer();
		//timerFight.start(1, updateFight, 0);
		fightStartTick = FlxG.game.ticks;
		fightDelayTicks = 1000;
		
		//pause();
		//openSubStateFight();
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
		}
		
		if (FlxG.mouse.pressed)
		{
			//if (!Reg.level.UI.BG.overlapsPoint(FlxG.mouse.getScreenPosition())) // scroll map seulement si on n'est pas sur l'UI et que l'on ne drag pas de building/power
			if(FlxG.mouse.getScreenPosition()!=prevMouseCoord) // si la souris a bougée
			{
				FlxG.camera.scroll.x -= Std.int((FlxG.mouse.screenX - prevMouseCoord.x));
				prevMouseCoord.x = FlxG.mouse.screenX;
				FlxG.camera.scroll.y -= Std.int((FlxG.mouse.screenY - prevMouseCoord.y));
				prevMouseCoord.y = FlxG.mouse.screenY;
				
				/*cameraDroppable.scroll.x = FlxG.camera.scroll.x;
				cameraDroppable.scroll.y = FlxG.camera.scroll.y;*/
				
			}
		}
		
		if (FlxG.mouse.justReleased)
		{
			//move player
			//else
			//{
				Reg.level.player.findNewPath(new FlxPoint(Std.int(FlxG.mouse.x / Reg.TILE_SIZE) * Reg.TILE_SIZE, Std.int(FlxG.mouse.y / Reg.TILE_SIZE) * Reg.TILE_SIZE));				
			//}
			
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
		if(_r.followNumber==0)
			state.setup(_p, _r);
		else
			state.setup(_p, _r.leader);
		openSubState(state);
	}
	
	public function openSubStateFight():Void
	{	
		FlxTimer.globalManager.active = false;
		//FlxTween.globalManager.active = false;
		var state:SubStateFight = new SubStateFight();	
		var r1 : Rioter = new Rioter();
		r1.speed = 5;
		r1.faction = "red";
		r1.health =  1000;
		var r2 : Rioter = new Rioter();
		r2.speed = 1;
		r2.faction = "yellow";
		r2.health =  1000;
		state.setup(r1,r2);
		openSubState(state);
	}
	
	public function pause():Void
	{/*
		// This is temp substate, it will be destroyed after closing
		FlxTimer.globalManager.active = false;
		//FlxTween.globalManager.active = false;
		var state:SubStateFight = new SubStateFight();
		openSubState(state);*/
	}
}
