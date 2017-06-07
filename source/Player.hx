package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxG;

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
		delayTicks = 1000;
	}
	
	public function getCrowd(_r:Rioter):Void
	{
		leader = _r;
		leader.isPlayer = true;
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
			move();
		}
		
	}
	
	private function move():Void
	{
		if (currentPath != null && currentNode == currentPath.length)
			currentPath = null;
			
		if (currentPath == null)
			return;
			
		this.x = currentPath[currentNode].x - Reg.TILE_SIZE/2;
		this.y = currentPath[currentNode].y - Reg.TILE_SIZE/2;
		
		currentNode++;
	}
	
	public function findNewPath( _goal:FlxPoint ):Void
	{
		var pathPoints:Array<FlxPoint> = Reg.level.collidableTileLayers[0].findPath(
			FlxPoint.get((this.x/Reg.TILE_SIZE)*Reg.TILE_SIZE ,
			(this.y/Reg.TILE_SIZE)*Reg.TILE_SIZE),
			FlxPoint.get((_goal.x/Reg.TILE_SIZE)*Reg.TILE_SIZE,
			(_goal.y/Reg.TILE_SIZE)*Reg.TILE_SIZE),
			false,
			false,
			NONE
			 );
		
		if (pathPoints != null)
		{
			currentPath = pathPoints;
			currentNode = 1;
		}
		
		trace("findPath");
	}
}