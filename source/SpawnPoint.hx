package;

import flixel.FlxSprite;

class SpawnPoint extends FlxSprite // un seul objet graphique
{
	private var faction : String;
	private var count :Int;
	private var delayFirstSpawn : Int;
	private var delaySpawns :Int;
	private var crowdSize: Int;
	
	public function new(X:Float, Y:Float, image_path:String, _faction : String)
	{		
		super(X, Y, image_path);		
		
		faction = _faction;
	}
	
	public override function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	}
}