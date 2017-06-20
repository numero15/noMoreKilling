import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.FlxState;
import flash.geom.Rectangle;

class Answer
{
	public var text : String;
	public var id : Int;
	public var effect : Int;

	public function new(t:String, i:Int, e:Int) {
		text = t;
		id = i;
		effect = e;
	}
}

class SubStateDialogue extends FlxSubState
{
	private var BG : FlxSprite;	
	private var closeBtn:FlxButton;

	private var questionText : FlxText;
	private var answerButtons : Array<FlxButton>;

	private var player: Player;
	private var leader: Rioter;
	private var questionString : String;
	private var answers : Array<Answer>;
	private var xml : Xml;

	private var qtePanel : Rectangle;
	private var historyPanel : Rectangle;
	private var answersPanel : Rectangle;
	private var feedbackPanel : Rectangle;

	private var qteButtons : Array<FlxButton>;
	
	public function setup(_p:Player, _r:Rioter):Void 
	{		
		// mise en place stats
		leader = _r;
		player = _p;
		xml = Xml.parse(sys.io.File.getContent("assets/data/dialogues.xml")).firstChild();
		
		historyPanel = new Rectangle(0, 0, FlxG.width*2/3, FlxG.height*3/4);
		qtePanel = new Rectangle(historyPanel.width, 0, FlxG.width-historyPanel.width, FlxG.height/5);
		answersPanel = new Rectangle(0, historyPanel.height, historyPanel.width, FlxG.height-historyPanel.height);
		feedbackPanel = new Rectangle(historyPanel.width, qtePanel.height, FlxG.width-historyPanel.width, FlxG.height-qtePanel.height);
		
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
		// BG.scrollFactor.set();
		BG.cameras = [FlxG.cameras.list[1]];

		closeBtn = new FlxButton(FlxG.width * 0.5 - 40, FlxG.height * 0.5, "Close", closeThis);
		closeBtn.cameras = [FlxG.cameras.list[1]]; // la camera 1 est réservée à l'UI et au elements non affectés par le zoom
				
		//charge texte dialogue
		setupDialogue(0);

		answerButtons = new Array<FlxButton>();

		questionText = new FlxText(historyPanel.x, historyPanel.y, historyPanel.width, questionString, 11);
		for(i in 0...3) {
			answerButtons[i] = new FlxButton(answersPanel.x, answersPanel.y + 20*i, answers[i].text);
			answerButtons[i].onUp.callback = goToDialog.bind(answers[i]);
		}
		// answerButtons[0] = new FlxButton(FlxG.width/2, FlxG.height - 100, answers[0].text, goToDialog(answers[0]));
		// answerButtons[i].onUp.callback = goToDialog.bind(answers[0]);
		// answerButtons[1] = new FlxButton(FlxG.width/2, FlxG.height - 80, answers[1].text, goToDialog(answers[1]));
		// answerButtons[2] = new FlxButton(FlxG.width/2, FlxG.height - 60, answers[2].text, goToDialog(answers[2]));
		

		questionText.cameras = [FlxG.cameras.list[1]];
		answerButtons[0].cameras = [FlxG.cameras.list[1]];
		answerButtons[1].cameras = [FlxG.cameras.list[1]];
		answerButtons[2].cameras = [FlxG.cameras.list[1]];
		
		add(closeBtn);
		add(BG);
		add(questionText);
		for(i in 0...3) {
			add(answerButtons[i]);
		}
	}
	
	/**
	 *setup de la boite de dialogue
	 * 
	 * @param	id				id du dialogue recherché	
	 */
	private function setupDialogue(_id: Int):Void
	{		
		//reset strings
		if(answers != null)
		for( i in 0...answers.length)
		{
			answers[answers.length-i-1] = null;
		}
		answers = new Array<Answer>();
		
		//accès xml		
		for (_dialogueData in xml.elementsNamed("dialogue")) //itère dans les dialogues
		{		
			if (Std.parseInt(_dialogueData.get('id')) == _id)
			{
				for (_answer in _dialogueData.elementsNamed('answer'))
				{
					answers.push(new Answer(
						_answer.firstElement().firstChild().toString(),
						Std.parseInt(_answer.get('id')),
						Std.parseInt(_answer.get('effect'))));
				}				
				
				questionString = new String(_dialogueData.firstElement().firstChild().toString());					
			}
		}
	}

	private function goToDialog(answer:Answer) {
		//Appliquer l'effet
		//...

		if(answer.id == -1) Terminate();

		//Setup un nouveau dialogue
		setupDialogue(answer.id);

		questionText.text = questionString;
		for(i in 0...3) {
			answerButtons[i].text = answers[i].text;
			answerButtons[i].onUp.callback = goToDialog.bind(answers[i]);
		}
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
	
	private function closeThis():Void
	{
		//test en attendant que les condtions de victoire/défaite marchent
		player.getCrowd(leader);
		
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

	private function Terminate() : Void {
		questionText.destroy();
		for(i in 0...answers.length) {
			answerButtons[answers.length - i + 1].destroy();
			answers[answers.length - i + 1] = null;
		}
		
		this.closeThis();
	}
}