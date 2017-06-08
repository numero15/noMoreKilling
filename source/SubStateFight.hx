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
	
	public function setup(? _r1:Rioter, ?_r2:Rioter):Void
	{
		BG = new FlxSprite();
		BG.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		BG.alpha = .3;
		BG.cameras = [FlxG.cameras.list[1]];
		
		closeBtn = new FlxButton(FlxG.width * 0.5 - 40, FlxG.height * 0.5, "Close", closeThis);
		closeBtn.cameras = [FlxG.cameras.list[1]]; // la camera 1 est réservée à l'UI et au elements non affectés par le zoom
		
		crowds = new FlxTypedGroup<Fighter>(200);
		
		for (i in 0...200)
		{
			var _r = new Fighter(0, 0);
			_r.makeGraphic(Reg.TILE_SIZE, Reg.TILE_SIZE, FlxColor.RED);
			_r.kill();
			crowds.add(_r);
		}
		
		add(closeBtn);
		add(BG);
		add(crowds);
		
		//genère les foules	
		generateCrowd(0xff00ff00, -1);
		generateCrowd(0xff0000ff, 1);
		
		//défini une cible pour chaque fighter
		
	}
	
	private function generateCrowd(_color:UInt, direction: Int):Void
	{
		var _f : Fighter;
		var _x : Float;
		var _y : Float;
		_x =FlxG.width / 2  + FlxG.width / 4 * -direction  ;
		_y =  FlxG.random.float(0, Reg.TILE_SIZE / 2);
		
		for ( i in 0...30) // generation foule 1
		{
			_f  = crowds.getFirstAvailable();
			_f.revive();	
			
			_y += Reg.TILE_SIZE+ FlxG.random.float(0, Reg.TILE_SIZE);
			if (_y > FlxG.height - Reg.TILE_SIZE)
			{
				_y = FlxG.random.float(0, Reg.TILE_SIZE / 2);
				_x -= Reg.TILE_SIZE*2 * direction;
			}
			 
			_f.makeGraphic(Reg.TILE_SIZE, Reg.TILE_SIZE, _color);
			_f.x = _x + FlxG.random.float(-Reg.TILE_SIZE/2, Reg.TILE_SIZE/2);
			_f.y = _y;
			_f.velocity.x = 20 * direction + FlxG.random.int( -5, 5);	
			_f.faction = _color;
			_f.health = FlxG.random.int(10, 15);
		}
	}
	
	private function overlapCallback(_f1 : Fighter, _f2 : Fighter):Void
	{
		/*_f1.velocity.x = 0;
		_f1.velocity.y = 0;
		_f2.velocity.x = 0;
		_f2.velocity.y = 0;*/
		if (_f1.faction == _f2.faction)
		{
			if (_f1.velocity.x > 0 && _f2.velocity.x > 0)
			{
				if (_f1.x > _f2.x)
					_f1.moves = false;
				else
					_f2.moves = false;
			}
			
			else if (_f1.velocity.x < 0 && _f2.velocity.x < 0)
			{
				if (_f1.x < _f2.x)
					_f1.moves = false;
				else
					_f2.moves = false;
			}
		}
		else
		{
			_f1.moves = false;
			_f2.moves = false;
			_f1.health -= .1;
			_f2.health -= .1;
		}
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		crowds.forEachAlive(function(_f:Fighter){_f.moves = true;} );
		
		
		FlxG.overlap(crowds, overlapCallback);
		
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