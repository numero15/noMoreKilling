package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * ...
 * @author numero 15
 */
class Fighter extends FlxSprite 
{
	public var faction : UInt;
	public var crowds : FlxTypedGroup<Fighter>;
	private var target:Fighter;

	public function new(?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
	{
		super(X, Y, SimpleGraphic);		
	}
	
	public function setup(_c:FlxTypedGroup<Fighter>):Void
	{
		crowds = _c;
	}
	
	override function update(elapsed: Float):Void
	{
		if (health < 0) kill();
		
		if(target!=null)
		{
			if (!target.alive)
				findTarget();
			else if (velocity.x >= 0 && target.x < this.x)
				findTarget();
			else if (velocity.x <= 0 && target.x > this.x)
				findTarget();
		}
		
		super.update(elapsed);
	}
	
	
	public function findTarget():Void
	{
		
		var _f: Fighter;
		var haveTarget :Bool;		
		haveTarget = false;
		
		for (i in 0...crowds.members.length)
		{
			_f = crowds.members[i];
			if (_f.alive && _f.faction!= this.faction)
			{			 
				if (!haveTarget)
				{
					target = _f;
					haveTarget = true;
				}
				
				else
				{
					if ( this.getPosition().distanceTo(target.getPosition()) >  this.getPosition().distanceTo(_f.getPosition()))
						target = _f;
				}
			}
		}
		
		if (!haveTarget)
			target = null;
		
		//calcul la vitesse
		else
		{			
			velocity.x =-(this.x- target.x) /  this.getPosition().distanceTo(target.getPosition())*30 ;
			velocity.y =- ( this.y-target.y) / this.getPosition().distanceTo(target.getPosition())*30;
		}
	}
	
	override function destroy():Void
	{
		crowds = null;
	}
	
}