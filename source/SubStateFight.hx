import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileCircle;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.ui.FlxBar;
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
	private var btn_close:FlxButton;
	private var crowds : FlxTypedGroup<Fighter>;
	private var power : Int;
	private var powerMax : Int;
	private var regenPowerDelay:Int;
	private var regenPowerStart: Int;
	private var bar_power : FlxBar;
	private var btn_attack : FlxButton;
	private var btn_health : FlxButton;
	
	override public function create():Void 
	{
		super.create();	
		//FlxG.debugger.visible = false;
	}
	
	public function setup( _r1:Rioter, _r2:Rioter):Void
	{
		power = 50;
		powerMax = 100;
		regenPowerDelay = 100;
		
		BG = new FlxSprite();
		BG.makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY);
		BG.alpha = 1;
		BG.cameras = [FlxG.cameras.list[1]];
		
		btn_close = new FlxButton(FlxG.width * 0.5 - 40, FlxG.height * 0.5, "Close", closeThis);
		btn_close.cameras = [FlxG.cameras.list[1]]; // la camera 1 est réservée à l'UI et au elements non affectés par le zoom
		
		btn_attack = new FlxButton(FlxG.width * 0.5 - 40, FlxG.height * 0.5, "");
		btn_attack.loadGraphic ("assets/images/btn_attack.png");
		btn_attack.onDown.callback = applyEffect.bind('attack');
		btn_attack.cameras = [FlxG.cameras.list[1]];
		btn_attack.y = 8;
		btn_attack.x = FlxG.width / 2 - 16-8;
		
		btn_health = new FlxButton(FlxG.width * 0.5 - 40, FlxG.height * 0.5, "", applyEffect.bind('power'));
		btn_health.cameras = [FlxG.cameras.list[1]];
		btn_health.loadGraphic ("assets/images/btn_health.png");
		btn_health.onDown.callback = applyEffect.bind('health');
		btn_health.cameras = [FlxG.cameras.list[1]];
		btn_health.y = 8;
		btn_health.x = FlxG.width / 2+16-8;
		
		bar_power = new FlxBar(0, 0, FlxBarFillDirection.LEFT_TO_RIGHT, 100, 4, this, "power", 0, powerMax);
		bar_power.y = 32;
		bar_power.x =  (FlxG.width - bar_power.width) / 2 ;
		
		crowds = new FlxTypedGroup<Fighter>(600);		
		for (i in 0...600)
		{
			var _r = new Fighter(0, 0);
			_r.makeGraphic(Reg.TILE_SIZE, Reg.TILE_SIZE, FlxColor.RED);
			_r.kill();
			_r.cameras = [FlxG.cameras.list[1]];
			crowds.add(_r);
		}
		
		add(btn_close);
		add(BG);
		add(crowds);
		add(bar_power);
		add(btn_attack);
		add(btn_health);
		
		//genère les foules	
		generateCrowd(_r1.faction, _r1.speed, _r1.health, "left");
		generateCrowd(_r2.faction, _r2.speed, _r2.health, "right");
		
		//défini une cible pour chaque fighter
		crowds.forEachAlive(function(_f:Fighter){_f.findTarget(); } );		
	}
	
	private function generateCrowd(_faction :String, _speed:Int, _health:Float, _side: String):Void
	{
		var _f : Fighter;
		var _x : Float;
		var _y : Float;
		var direction :Int;
		
		direction = 0;
		switch(_side)
		{
			case "right":
				direction = -1;
			case"left":
				direction = 1;
		}
		
		_x =FlxG.width / 2  + FlxG.width / 4 * -direction  ;
		_y =  FlxG.random.float(0, Reg.TILE_SIZE / 2) + FlxG.height/4;
		
		for ( i in 0...Std.int(_health/10)) // generation foule
		{
			_f  = crowds.getFirstAvailable();
			_f.revive();			
			_f.side = _side;
			_f.faction = _faction;
			_f.healthMax = 5;
			_f.setup(crowds);
			_f.speed = _speed + FlxG.random.int(-1,1);
			
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
	
	
	private function applyEffect(_effect:String):Void
	{
		crowds.forEachAlive(
		function(_f:Fighter){
			
			//if (_f.faction != Reg.level.player.leader.faction)return;
			if (_f.faction == "red") return;
			
				switch(_effect)
				{
					case'attack':
						
					case"health" :
						_f.health += 3;
				}		
			
		}
		);	
	}
	
	private function closeThis():Void
	{
		remove(BG);
		BG.destroy();
		BG = null;
		
		remove(btn_close);
		btn_close.destroy();
		btn_close = null;
		
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