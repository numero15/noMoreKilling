package;

import flixel.FlxSprite;
import flixel.ui.FlxBar;
import flixel.util.FlxTimer;
import flixel.FlxG;

class SpawnPoint extends FlxSprite // un seul objet graphique
{
	private var faction : String;
	public var count :Int = 0;
	public var delayFirstSpawn : Int = 0;
	public var delaySpawns :Int = 0;
	public var crowdSize: Int = 0;
	
	private var currentLeader : Rioter;
	
	private var currentCrowd: Int = 0;
	
	private var timerFirstSpawn : FlxTimer; // délai avant le spawn da la première vague
	private var timerSpawns : FlxTimer; // délai entre le spawn de chaque vague de rioters
	
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
	
	/*public override function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	}*/
	
	public function spawnCrowd (?Timer:FlxTimer):Void
	{
		currentCrowd++;
		for (i in 0...crowdSize)
		{
			spawnRioter(i);
		}
	}
	
	public function spawnRioter (_num:Int):Void
	{
		var rioter : Rioter;
		// spawn leader
		rioter = Reg.level.crowds.getFirstAvailable();
		rioter.setup(this.x, this.y,"assets/images/crowd_"+faction+".png", faction,_num);
		rioter.updatePaths();
		
		if (_num == 0) // leader
		{
			currentLeader = rioter;
			rioter.health = crowdSize * 100;
			
			
			rioter.bar = Reg.level.crowdsUI.getFirstAvailable();
			rioter.bar.revive();
			
		}
		else //followers
		{
			rioter.leader = currentLeader;
			currentLeader.followers.add(rioter);
		}
		
		if (_num == crowdSize-1)
		{
			currentLeader = null;
		}
		rioter = null;
	}
}