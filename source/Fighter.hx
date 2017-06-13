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
	public var state : String;
	private var isColliding:Bool;
	private var hasHitted:Bool;
	public var side:String;
	public var healthMax : Float;
	public var healingSpeed:Float;
	private var targetPos : FlxPoint;
	
	public function new(?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
	{
		super(X, Y, SimpleGraphic);	
		healingSpeed = 0.01;
		targetPos  = new FlxPoint();
	}
	
	public function setup(_c:FlxTypedGroup<Fighter>):Void
	{
		crowds = _c;
		state = "init";
		isColliding = false;
		health = healthMax;	
		
		
		loadGraphic("assets/images/run.png", true, 16, 16);
		switch(faction)
		{
			case 'red':
				this.setColorTransform(FlxG.random.float(.5, 1), FlxG.random.float(.5, 1), 1, 1, 0, 0, 0, 0);
			case 'yellow' :
				this.setColorTransform(FlxG.random.float(.7, 1),1, FlxG.random.float(.5, 1), 1, 0, 0, 0, 0);
		}
		animation.add('run', [ 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], 12);
		animation.add('idle', [ 7,8], 12);
		animation.add('fight', [ 0,1,2,3,4], 12);
		
		
		updateHitbox();
		setSize(Reg.TILE_SIZE * .5, Reg.TILE_SIZE * .5);
		centerOffsets();
		
		changeState('run');
	}
	
	override function update(elapsed: Float):Void
	{
		super.update(elapsed);
		
		if (health < 0) kill();		
		
		
		if(target!=null && state=="run" /*&& state=="fight"*/)
		{
			if (!target.alive)
				findTarget();
				
			else if (velocity.x >= 0 && target.x < this.x)// si à croisé sa cible en trouve une autre
				findTarget();
			else if (velocity.x <= 0 && target.x > this.x)// si à croisé sa cible en trouve une autre
				findTarget();
		}
		
		if (state == "back")
		{
			switch(side)
			{
				case'right':
					if (x > FlxG.width- 64 + FlxG.random.int( -16, 16))
						changeState('heal');
				case 'left':
					if (x < 64 + FlxG.random.int( -16, 16))
						changeState('heal');
			}
		}
		
		
		if (state == "idle" || state =="fight")
		{
			if(!isColliding && target!=null)
					changeState("run");
		}
		
		if (state == "heal")
		{
			health += healingSpeed;
			if (health >= healthMax)
			{
				health = healthMax;
				findTarget();
			}
		}
		
		
			
		isColliding = false;
		hasHitted = false;
	}	
	
	public function collide(_f:Fighter):Void
	{		
		
		if (faction == _f.faction)
		{
			if (state == "back" || _f.state == "back")
			return;
			
			if (velocity.x > 0 && _f.velocity.x > 0)
			{
				if (x < _f.x)
				{
					changeState("idle");
					isColliding = true;
				}
			}
			
			else if (velocity.x < 0 && _f.velocity.x < 0)
			{
				if (x > _f.x)
				{
					changeState("idle");
					isColliding = true;
				}
			}
		}
		
		// collision si les foules sont ennemies
		else
		{
			if(!_f.hasHitted)
			{
				health -= .1;
				_f.hasHitted;
			}
			
			if (health < 1 && FlxG.random.int(0,8) ==1) //fuit
			{
				velocity.x = 50;//20 + speed * 5 ;
				if (side == "left")
					velocity.x = -velocity.x;
				velocity.y = 0;
				changeState("back");
				isColliding = false;
			}
			
			else
			{
				changeState("fight");
				isColliding = true;
			}
		}
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
					//if ( this.getPosition().distanceTo(target.getPosition()) >  this.getPosition().distanceTo(_f.getPosition()))
					if (Math.abs( target.y-y) > Math.abs( _f.y-y))
						target = _f;
				}
			}
		}
		
		if (!haveTarget)
		{
			target = null;
			velocity.x = 0;
			velocity.y = 0;
			changeState("idle");
		}
		
		//calcul la vitesse
		else
		{			
			targetPos  = target.getPosition();
			velocity.x =-(this.x- target.x) /  this.getPosition().distanceTo(target.getPosition())* (20 + speed*5) ;
			velocity.y =- ( this.y - target.y) / this.getPosition().distanceTo(target.getPosition()) * (20 + speed * 5);
			changeState("run");
		}
	}
	
	private function changeState(_s:String):Void
	{
		/*if (_s == state)
			return;*/
			
		state = _s;
		switch (state)
		{
			case "run", "back":
				animation.play('run', true, false, -1);
				
				if (velocity.x > 0)
					flipX = false;
				else
					flipX = true;
				
				moves = true;
				
			case "idle", "heal":
				animation.play('idle');
				moves = false;
				
			case "fight":
				animation.play('fight');
				moves = false;
				
		}
	}
	
	override function destroy():Void
	{
		crowds = null;
	}
	
}