import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

class SubStateDialogue extends FlxSubState
{
	private var BG : FlxSprite;	
	private var closeBtn:FlxButton;
	private var player: Player;
	private var leader: Rioter;
	private var question : String;
	private var answers : Array<Array<String>>;
	private var xml : Xml;
	
	public function setup(_p:Player, _r:Rioter):Void 
	{		
		// mise en place stats
		leader = _r;
		player = _p;
		xml = Xml.parse(sys.io.File.getContent("assets/data/dialogues.xml")).firstChild();
		
		//aide mémoire, accès aux stats des persos :
		/*trace('player stats :');
		trace('health : ' + player.health);
		
		trace('leader stats :');
		trace('faction : ' + leader.faction);
		trace('health : ' + leader.health);
		trace('speed : ' + leader.speed);
		trace('motivation : ' + leader.motivation);*/
		
		//mise en place graphismes		
		BG = new FlxSprite();
		BG.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		BG.alpha = .3;
		BG.scrollFactor.set();
		
		closeBtn = new FlxButton(FlxG.width * 0.5 - 40, FlxG.height * 0.5, "Close", closeThis);
		closeBtn.cameras = [FlxG.cameras.list[1]]; // la camera 1 est réservée à l'UI et au elements non affectés par le zoom
		
		add(closeBtn);
		add(BG);
		
		//charge texte dialogue
		setupDialogue(0);
	}
	
	/**
	 *setup de la boite de dialogue
	 * 
	 * @param	id				id du dialogue recherché	
	 */
	private function setupDialogue(_id: Int):Void
	{		
		//reset strings
		answers = new Array();
		
		//accès xml		
		for (_dialogueData in xml.elementsNamed("dialogue")) //itère dans les dialogues
		{		
			if (Std.parseInt(_dialogueData.get('id')) == _id)
			{
				var i : Int = 0;
				for ( _answer in _dialogueData.elementsNamed('answer'))
				{
					answers[i]= [
					_answer.firstElement().firstChild().toString(),
					_answer.get('id').toString(),
					_answer.get('effect').toString()
					];
					i++;
				}				
				
				question =new String( _dialogueData.firstElement().firstChild().toString());					
			}
		}
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