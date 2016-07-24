package;

import flixel.FlxSprite;

class Rioter extends FlxSprite // un seul objet graphique
{
	public var faction : String;
	public var enemy : String;
	public var isLeader :Bool;
	public var leaderId: Int;
	
	public function new(X:Float, Y:Float, image_path:String /*source du .png*/, _faction : String)
	{
		
		super(X, Y, image_path);
		
		
		faction = _faction;
		
		switch(faction)
		{
			case "fouleJaune":
				enemy = "fouleRouge";
				
			case "fouleRouge":
				enemy = "fouleJaune";
		}
		/*
		setSize(12, 12);
		offset.set(2, 2);
		setPosition(2, 2);*/
	}
	
	public override function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	}
}