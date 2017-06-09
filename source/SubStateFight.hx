import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileCircle;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.math.FlxRandom;

class SubStateFight extends FlxSubState
{
	private var BG : FlxSprite;	
	private var closeBtn:FlxButton;
	private var crowds : FlxTypedGroup<Fighter>;
	
	override public function create():Void 
	{
		super.create();
		
		
	}
	
	public function setup( _r1:Rioter, _r2:Rioter):Void
	{
		BG = new FlxSprite();
		BG.makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY);
		BG.alpha = 1;
		BG.cameras = [FlxG.cameras.list[1]];
		
		closeBtn = new FlxButton(FlxG.width * 0.5 - 40, FlxG.height * 0.5, "Close", closeThis);
		closeBtn.cameras = [FlxG.cameras.list[1]]; // la camera 1 est réservée à l'UI et au elements non affectés par le zoom
		
		crowds = new FlxTypedGroup<Fighter>(600);
		
		for (i in 0...600)
		{
			var _r = new Fighter(0, 0);
			_r.makeGraphic(Reg.TILE_SIZE, Reg.TILE_SIZE, FlxColor.RED);
			_r.kill();
			_r.cameras = [FlxG.cameras.list[1]];
			crowds.add(_r);
		}
		
		add(closeBtn);
		add(BG);
		add(crowds);
		//genère les foules	
		generateCrowd(_r1.faction, _r1.speed, _r1.health, -1);
		generateCrowd(_r2.faction, _r2.speed, _r2.health, 1);
		
		//défini une cible pour chaque fighter
		crowds.forEachAlive(function(_f:Fighter){_f.findTarget(); } );	
		
	}
	
	private function generateCrowd(_faction :String, _speed:Int, _health:Float, direction: Int):Void
	{
		var _f : Fighter;
		var _x : Float;
		var _y : Float;
		_x =FlxG.width / 2  + FlxG.width / 4 * -direction  ;
		_y =  FlxG.random.float(0, Reg.TILE_SIZE / 2) + FlxG.height/4;
		
		for ( i in 0...Std.int(_health/10)) // generation foule
		{
			_f  = crowds.getFirstAvailable();
			_f.revive();
			if (direction ==-1)
				_f.flipX = true;
			
			_f.faction = _faction;
			_f.setup(crowds);
			_f.speed = _speed;
			
			_y += Reg.TILE_SIZE / 2 + FlxG.random.float(0, Reg.TILE_SIZE / 2);
			
			
			if (_y > 3*FlxG.height/4 - Reg.TILE_SIZE)
			{
				_y = FlxG.random.float(0, Reg.TILE_SIZE / 2) + FlxG.height/4;
				_x -= Reg.TILE_SIZE*2 * direction;
			}
			_f.x = _x + FlxG.random.float(-Reg.TILE_SIZE/2, Reg.TILE_SIZE/2);
			_f.y = _y;
			//_f.velocity.x = 20 * direction + FlxG.random.int( -5, 5);	
			
			_f.health = FlxG.random.int(10, 15);
		}
	}
	
	private function overlapCallback(_f1 : Fighter, _f2 : Fighter):Void
	{
		//collision si les deux foule sont de la même faction
		
		/*
		if (_f1.faction == _f2.faction)
		{
			if (_f1.velocity.x > 0 && _f2.velocity.x > 0)
			{
				if (_f1.x < _f2.x)
				{
					_f1.moves = false;
				}
				else
				{
					_f2.moves = false;
				}
			}
			
			else if (_f1.velocity.x < 0 && _f2.velocity.x < 0)
			{
				if (_f1.x > _f2.x)
				{
					_f1.moves = false;
				}
				else
				{
					_f2.moves = false;
				}
			}
		}
		
		// collision si les foules sont ennemies
		else
		{
			_f1.moves = false;
			_f2.moves = false;
			_f1.health -= .5;
			_f2.health -= .5;
		}*/
		_f1.collide(_f2);
		_f2.collide(_f1);
	}
	
	private function processCallback(_f1 : Fighter, _f2 : Fighter):Bool
	{
		if (_f1.isOnScreen(FlxG.cameras.list[1]) && _f2.isOnScreen(FlxG.cameras.list[1]) && _f1.alive && _f2.alive )
			return true;
			
		else
			return false;
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);		
		//crowds.forEachAlive(function(_f:Fighter){_f.moves = true;} );			
		FlxG.overlap(crowds, overlapCallback, processCallback);
	}
	
	
	private function closeThis():Void
	{
		remove(BG);
		BG.destroy();
		BG = null;
		
		remove(closeBtn);
		closeBtn.destroy();
		closeBtn = null;
		
		FlxTimer.globalManager.active = true;
		FlxTween.globalManager.active = true;
		this.close();
	}
	
	// This function will be called by substate right after substate will be closed
	public static function onSubstateClose():Void
	{
		FlxTimer.globalManager.active = true;
		FlxTween.globalManager.active = true;
	}
}