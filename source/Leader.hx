package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.ui.FlxBar;
import flixel.util.FlxPath;
import flixel.FlxG;
import flixel.FlxObject;

class Leader extends BasicRioter // un seul objet graphique
{
	
	public function new()
	{		
		super();
	}
	
	//lancer quand le leader est arrivé à un point du path
	override function updatePaths(?_path:FlxPath):Void  // pour les leaders : définit un nouveau path vers la foule ennemie la plus proche
	{				
		// si voit un leader trouver un path
		if (motivation == motivationMax)
		{
			trace("follow");
		}
		else // si pas de cible déplacement aléatoire
		{				
			goal = randomMovement();
		}
		previousPos.set(x, y);
		setPosition(goal.x - this.width/2, goal.y - this.height/2);
	}
	
	override function collide(_p:FlxPoint):Bool // appeler uniquement sur les leaders
	{
		var _isColliding : Bool;
		
		_isColliding = false;
		
		for (_r in Reg.level.crowds)
		{
			if (_r.x == _p.x && _r.y == _p.y && _r.alive)
			{
				//fight
				if (_r.faction != faction)
				{					
					_r.stopCrowd();
					stopCrowd();
					
					
					_r.addOpponent(this);
					addOpponent(_r);			
					
					_isColliding =  true;
				}	
				
				else//collide
				{
					
				}
			}
		}
		
		return _isColliding;		
	}
		
	override function kill():Void
	{			
		super.kill();		
	}
	
	override function destroy():Void
	{		
		super.destroy();
	}
}