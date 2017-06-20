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

<<<<<<< HEAD
class Rectangle {
	public var x : Float;
	public var y : Float;
	public var width : Float;
	public var height : Float;

	public function new(_x: Float,_y: Float,_w: Float,_h: Float) {
		x = _x;
		y = _y;
		width = _w;
		height = _h;
	}
}

=======
>>>>>>> origin/master
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

	private var history : Array<FlxText>;

	private var qtePanel : Rectangle;
	private var historyPanel : Rectangle;
	private var answersPanel : Rectangle;
	private var feedbackPanel : Rectangle;

<<<<<<< HEAD
	// private var qteButtons : Array<FlxButton>;
=======
	private var qteButtons : Array<FlxButton>;
>>>>>>> origin/master
	
	public function setup(_p:Player, _r:Rioter):Void 
	{		
		// mise en place stats
		leader = _r;
		player = _p;
		xml = Xml.parse(sys.io.File.getContent("assets/data/dialogues.xml")).firstChild();
		
		historyPanel = new Rectangle(0, 50, FlxG.width*2/3, FlxG.height*3/4);
		qtePanel = new Rectangle(historyPanel.width, historyPanel.y, FlxG.width-historyPanel.width, FlxG.height/5);
		answersPanel = new Rectangle(0, historyPanel.height+historyPanel.y, historyPanel.width, FlxG.height-historyPanel.height);
		feedbackPanel = new Rectangle(historyPanel.width, qtePanel.height+qtePanel.y, FlxG.width-historyPanel.width, FlxG.height-qtePanel.height);
		
		if(history == null) history = new Array<FlxText>();

		//aide mémoire, accès aux stats des persos :
		/*trace('player stats :');
		trace('health : ' + player.health);
		
		trace('leader stats :');
		trace('faction : ' + leader.faction);
		trace('health : ' + leader.health);
		trace('speed : ' + leader.speed);
		trace('motivation : ' + leader.motivation);*/
		
		//BG		
		BG = new FlxSprite();
		BG.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		BG.alpha = .3;
		// BG.scrollFactor.set();
		BG.cameras = [FlxG.cameras.list[1]];

		//Close
		closeBtn = new FlxButton(FlxG.width * 0.5 - 40, FlxG.height * 0.5, "Close", closeThis);
		closeBtn.cameras = [FlxG.cameras.list[1]]; // la camera 1 est réservée à l'UI et au elements non affectés par le zoom
		
		//charge texte dialogue
		setupDialogue(0);

		//Question
		// questionText = new FlxText(historyPanel.x, historyPanel.height, historyPanel.width, questionString, 11);
		// questionText.y -= questionText.height;
		// questionText.color = 0xFFFFFFFF;
		// questionText.cameras = [FlxG.cameras.list[1]];
		// history.push(questionText);
		// add(questionText);

		createDialogItem(historyPanel.x, historyPanel.height, questionString);

		//Answers
		answerButtons = new Array<FlxButton>();

		for(i in 0...3) {
			answerButtons[i] = new FlxButton(answersPanel.x, answersPanel.y + 20*i, answers[i].text);
			answerButtons[i].onUp.callback = goToDialog.bind(answers[i]);
			answerButtons[i].cameras = [FlxG.cameras.list[1]];
			add(answerButtons[i]);
		}
		
		//QTE
		var qte1 = new FlxButton(qtePanel.x, qtePanel.y, "");
		qte1.loadGraphic("assets/images/btn_speed.png");
		qte1.cameras = [FlxG.cameras.list[1]];
		add(qte1);

		add(closeBtn);
		add(BG);
	}

	private function createDialogItem(x:Float, y:Float, s:String, isAnswer:Bool = false):FlxText {
		var text = new FlxText(x, y, historyPanel.width, s, 11);
		text.y -= text.height;
		text.color = 0xFFFFFFFF;
		if(isAnswer) text.alignment = FlxTextAlign.RIGHT;
		text.cameras = [FlxG.cameras.list[1]];
		history.push(text);
		add(text);

		updateHistory(text.height);

		return text;
	}

	private function updateHistory(offset:Float) {
		// var cursorHeight : Float;
		// cursorHeight = historyPanel.height;

		var i:Int;
		i = 0;
		while(i < history.length) {
			var text = history[history.length - i - 1];
			text.y -= offset;
			text.alpha = text.y/historyPanel.height;

			if(text.alpha <= 0) history.remove(text);
			else i++;
		}

		// var i:Int;
		// i = 0;
		// while(i < history.length) {
		// 	if(history[i].alpha <= 0) history.remove(history[i]);
		// 	else i++;
		// }
		trace(history.length);
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

		// var answerText = new FlxText(historyPanel.x, historyPanel.height, answer.text, 11);
		// answerText.y -= answerText.height;
		var answerText = createDialogItem(historyPanel.x, historyPanel.height, answer.text, true);
		// updateHistory(answerText.height);
		//Setup un nouveau dialogue
		setupDialogue(answer.id);
		// var questionText = new FlxText(historyPanel.x, historyPanel.height, answer.text, 11);
		// questionText.y -= questionText.height;
		// answerText.y -= questionText.height;
		var questionText = createDialogItem(historyPanel.x, historyPanel.height, questionString);
		// updateHistory(questionText.height);

		// history.push(answerText);
		// history.push(questionText);

		// add(answerText);
		// add(questionText);

		// updateHistory(answerText.height + questionText.height);

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