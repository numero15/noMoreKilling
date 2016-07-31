package;

import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.FlxG;

class SpawnPoint extends FlxSprite // un seul objet graphique
{
	private var faction : String;
	private var count :Int = 0;
	private var delayFirstSpawn : Int = 0;
	private var delaySpawns :Int = 0;
	private var crowdSize: Int = 0;
	
	private var currentLeader : Rioter;
	
	private var currentCrowd: Int = 0;
	
	private var timerFirstSpawn : FlxTimer; // délai avant le spawn da la première vague
	private var timerSpawns : FlxTimer; // délai entre le spawn de chaque vague de rioters
	private var timerRioterSpawn:FlxTimer; // délai entre le spawn de chaque rioter
	
	public function new(X:Float, Y:Float, image_path:String, _faction : String)
	{		
		super(X, Y, image_path);		
		
		faction = _faction;
		this.cameras = [FlxG.cameras.list[0]];
	}
	
	public function init():Void
	{
		if (delayFirstSpawn == 0) spawnCrowd();
		
		else
		{
			timerFirstSpawn = new FlxTimer();
			timerFirstSpawn.start(delayFirstSpawn, spawnCrowd, 1);
		}
	}
	
	public override function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	}
	
	public function spawnCrowd (?Timer:FlxTimer):Void
	{
		currentCrowd++;
		timerRioterSpawn = new FlxTimer();
		timerRioterSpawn.start(1, spawnRioter, 5);
	}
	
	public function spawnRioter (_timer:FlxTimer):Void
	{
		var rioter : Rioter;
		// spwan leader
		rioter = new Rioter(this.x, this.y,"assets/images/"+faction+".png", faction,_timer.elapsedLoops-1);
		rioter.updatePaths();
		Reg.level.crowds.add(rioter);
		if (_timer.elapsedLoops == 1)
		{
			currentLeader = rioter;
			rioter.health = 500;
		}
		else
		{
			rioter.leader = currentLeader;
			currentLeader.followers.add(rioter);
		}
		
		if (_timer.loopsLeft == 0)
		{
			currentLeader = null;
		}
		rioter = null;
	}
}