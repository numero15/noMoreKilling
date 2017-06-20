package;

import flixel.FlxSprite;
import flixel.ui.FlxBar;
import flixel.util.FlxTimer;
import flixel.FlxG;

class SpawnPoint extends FlxSprite // un seul objet graphique
{
	private var faction : String;
	public var count :Int = 0;
	private var currCount : Int = 0;
	public var delayFirstSpawn : Int = 0;
	public var delaySpawns :Int = 0;
	public var crowdSize: Int = 0;
	
	private var currentLeader : Rioter;
	
	public var startTick : Int;
	public var delayTicks : Int;
	var pourCentTimer : Float;
	
	public var bar : FlxBar;
	
	
	private var timerSpawn : FlxTimer; // délai entre le spawn de chaque vague de rioters
	
	public function new(X:Float, Y:Float, image_path:String, _faction : String)
	{		
		super(X, Y, image_path);		
		
		faction = _faction;
		this.cameras = [FlxG.cameras.list[0]];
	}
	
	public function init():Void
	{
		startTick = FlxG.game.ticks;
		if (delayFirstSpawn == 0) spawnCrowd();
		
		else
		{
			startTick = FlxG.game.ticks;
			delayTicks = delayFirstSpawn;
		}
		pourCentTimer = 0;
		bar = Reg.level.UIBars.getFirstAvailable();
		bar.revive();
		bar.parent = this;
		bar.parentVariable = "pourCentTimer";
		bar.setRange(0, 1);
		bar.x = this.x;
		bar.y = this.y;
		
		currCount = 0;
	}
	
	public override function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		pourCentTimer = (FlxG.game.ticks - startTick) / delayTicks;
		
		if (FlxG.game.ticks >= startTick + delayTicks)
		{
			spawnCrowd();
		}
	}
	
	public function spawnCrowd (?_t:FlxTimer):Void
	{
		
		if (currCount < count)
		{
			for (i in 0...crowdSize)
			{
				spawnRioter(i);
			}			
			currCount ++;
			Reg.currentLeaderID++;
			
			
			startTick = FlxG.game.ticks;
			delayTicks = delaySpawns;
		}
	}
	
	public function spawnRioter (_num:Int):Void
	{
		var rioter : Rioter;
		// spawn leader
		rioter = Reg.level.crowds.getFirstAvailable();
		rioter.setup(this.x, this.y, "assets/images/crowd_" + faction + ".png", faction);	
		rioter.health = 10;
			
		/*rioter.bar = Reg.level.UIBars.getFirstAvailable();
		rioter.bar.revive();
		rioter.bar.parent = rioter;
		rioter.bar.parentVariable = "health";
		rioter.bar.setRange(0, 400);
		rioter.bar.x = rioter.x;
		rioter.bar.y = rioter.y;	*/			
		
		for (_rioterStats in Reg.stats.elementsNamed("crowd"))
		{		
			if (_rioterStats.get('type') == faction)
			{
				for ( _stat in _rioterStats.elements())
				{
					switch _stat.nodeName
					{
						case "speed" :
							rioter.speed = Std.parseInt( _stat.get("value"));
						case "speedMax" :
							rioter.speedMax = Std.parseInt(_stat.get("value"));							
						case "motivation" :
							rioter.motivation = Std.parseInt( _stat.get("value"));
						case "motivationMax" :
							rioter.motivationMax = Std.parseInt(_stat.get("value"));
					}
				}
			}			
		}
		rioter = null;
	}
}