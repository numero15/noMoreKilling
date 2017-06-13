package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.util.FlxPath;

/**
 * ...
 * @author numero 15
 */
class Player extends FlxSprite 
{

	public var haveCrowd : Bool;
	public var leader : Rioter;
	private var currentPath : Array<FlxPoint>;
	private var currentNode : Int;
	public var startTick : Int;
	public var delayTicks : Int;
	public var isMoving :Bool;
	
	public function new(?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
	{
		super(X, Y, SimpleGraphic);
		
		this.loadGraphic("assets/images/crowd_yellow.png", true, 16, 16);
		updateHitbox();
		setSize(Reg.TILE_SIZE * 1.2, Reg.TILE_SIZE * 1.2);
		centerOffsets();
		
		haveCrowd = false;
		path = null;
		startTick = FlxG.game.ticks;
		delayTicks = 300;
		isMoving = false;
	}
	
	public function getCrowd(_r:Rioter):Void
	{
		leader = _r;
		leader.isPlayer = true;

		haveCrowd = true;
	}
	
	public function loseCrowd():Void
	{
		leader.isPlayer = false;
	}
	
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (FlxG.game.ticks >= startTick + delayTicks)
		{
			
			startTick = FlxG.game.ticks;
			
			if (haveCrowd)
				delayTicks = leader.delayTicks - leader.speed;
				
			else
				delayTicks = 300;
			if (currentPath != null)	
			move();
			if (haveCrowd)
			{
				
			}
		}
		
	/*	if(Std.is(path, FlxPath)){
			if (path.finished && isMoving)
			{
				isMoving = false;
				showBuildingsButtons();
			}
        }*/
		
		
		
	}
	
	private function move():Void
	{
		if (currentPath != null && currentNode == currentPath.length)
			currentPath = null;
			
		if (currentPath == null)
		{	isMoving = false;
			//open bouton selection building
			showBuildingsButtons();
			return;
		}
			
		this.x = currentPath[currentNode].x;
		this.y = currentPath[currentNode].y;
		
		if(haveCrowd)
			leader.updatePaths();
		
		currentNode++;
	}
	
	public function showBuildingsButtons():Void
	{		
		if (Reg.level.foregroundTiles.getTile(Std.int(x / Reg.TILE_SIZE), Std.int(y / Reg.TILE_SIZE) - 1) == 67)
			reviveButton(new FlxPoint(Std.int(x / Reg.TILE_SIZE), Std.int(y / Reg.TILE_SIZE) - 1));
		
		if (Reg.level.foregroundTiles.getTile(Std.int(x / Reg.TILE_SIZE), Std.int(y / Reg.TILE_SIZE)+1) == 67)
			reviveButton(new FlxPoint(Std.int(x / Reg.TILE_SIZE), Std.int(y / Reg.TILE_SIZE) + 1));
			
		if (Reg.level.foregroundTiles.getTile(Std.int(x / Reg.TILE_SIZE) - 1, Std.int(y / Reg.TILE_SIZE)) == 67)
			reviveButton(new FlxPoint(Std.int(x / Reg.TILE_SIZE) - 1, Std.int(y / Reg.TILE_SIZE)));
		
		if (Reg.level.foregroundTiles.getTile(Std.int(x / Reg.TILE_SIZE) + 1, Std.int(y / Reg.TILE_SIZE)) == 67)
			reviveButton(new FlxPoint(Std.int(x / Reg.TILE_SIZE) + 1, Std.int(y / Reg.TILE_SIZE)));
	}
	
	private function reviveButton(pos:FlxPoint) : Void
	{
		var _btn : FlxButton;
		
		if (pos != null)
		{
			_btn = Reg.level.buildingButtons.getFirstAvailable();
			if (_btn != null)
			{
				_btn.revive();
				_btn.setPosition(pos.x * Reg.TILE_SIZE, pos.y * Reg.TILE_SIZE);
				_btn.scrollFactor.set(1, 1);
			}
		}
	}
	
	public function findNewPath( _goal:FlxPoint ):Void
	{
		var pathPoints:Array<FlxPoint> = Reg.level.collidableTileLayers[0].findPath(
			FlxPoint.get((this.x/Reg.TILE_SIZE)*Reg.TILE_SIZE ,
			(this.y/Reg.TILE_SIZE)*Reg.TILE_SIZE  ),
			FlxPoint.get((_goal.x/Reg.TILE_SIZE)*Reg.TILE_SIZE ,
			(_goal.y/Reg.TILE_SIZE)*Reg.TILE_SIZE ),
			false,
			false,
			NONE
			 );
		
		if (pathPoints != null)
		{
			
			for (i in 0...pathPoints.length - 1)
			{
				pathPoints[i].x -= Reg.TILE_SIZE / 2;
				pathPoints[i].y -= Reg.TILE_SIZE / 2;
			}
			
			currentPath = pathPoints;
			currentNode = 1;
			startTick = FlxG.game.ticks-1000;
			
			
			
			// remove menu construction building
			Reg.level.buildingButtons.forEachAlive(function(_bt:FlxButton){_bt.kill(); });				
			Reg.level.UI.menuBuildings.kill();
				
			isMoving = true;
			
			
			/*this.path = new FlxPath(currentPath);
			this.path.start();*/
		}
	}
}