package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flash.geom.Rectangle;
import flash.geom.ColorTransform;

/**
 * ...
 * @author numero 15
 */
class Fighter extends FlxSprite 
{
	public var faction : String;
	public var crowds : FlxTypedGroup<Fighter>;
	private var target:Fighter;
	public var speed : Int;	// modificateur de vitesse

	public function new(?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
	{
		super(X, Y, SimpleGraphic);		
	}
	
	public function setup(_c:FlxTypedGroup<Fighter>):Void
	{
		crowds = _c;
		
		loadGraphic("assets/images/run.png", true, 16, 16);
		switch(faction)
		{
			case 'red':
				this.setColorTransform(FlxG.random.float(.5, 1), FlxG.random.float(.5, 1), 1, 1, 0, 0, 0, 0);
			case 'yellow' :
				this.setColorTransform(FlxG.random.float(.7, 1),1, FlxG.random.float(.5, 1), 1, 0, 0, 0, 0);
		}
		animation.add('run', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],FlxG.random.int(10,14));
		animation.play('run');
		
		updateHitbox();
		setSize(Reg.TILE_SIZE * .5, Reg.TILE_SIZE * .5);
		centerOffsets();
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
			velocity.x =-(this.x- target.x) /  this.getPosition().distanceTo(target.getPosition())* (20 + speed*5) ;
			velocity.y =- ( this.y - target.y) / this.getPosition().distanceTo(target.getPosition()) * (20 + speed*5);
		}
	}
	
	override function destroy():Void
	{
		crowds = null;
	}
	
}