import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

class SubStateFight extends FlxSubState
{
	private var BG : FlxSprite;	
	private var closeBtn:FlxButton;
	
	override public function create():Void 
	{
		super.create();
		
		BG = new FlxSprite();
		BG.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		BG.alpha = .3;
		BG.scrollFactor.set();
		
		closeBtn = new FlxButton(FlxG.width * 0.5 - 40, FlxG.height * 0.5, "Close", closeThis);
		closeBtn.cameras = [FlxG.cameras.list[1]]; // la camera 1 est réservée à l'UI et au elements non affectés par le zoom
		
		add(closeBtn);
		add(BG);
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
	
	private function closeThis():Void
	{
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