package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxPath;
import flixel.util.FlxTimer;

class Rioter extends FlxSprite // un seul objet graphique
{
	public var faction : String;
	public var enemy : String;
	public var isLeader :Bool; // TODO potentiellement inutile, nettoyer le code pour enlever toutes ref à isLeader, remplacer par followNumber=0
	public var leaderId: Int;
	public var followNumber : Int; // place du rioter dans la foule : 3->2->1->leader(0)
	private var timerSearchEnemy : FlxTimer;
	
	public function new(X:Float, Y:Float, image_path:String /*source du .png*/, _faction : String, _followNumber: Int)
	{
		
		super(X, Y, image_path);
		alpha = .5;
		
		faction = _faction;
		followNumber = _followNumber;
		
		if (followNumber == 0)
		{
			isLeader = true;
			timerSearchEnemy = new FlxTimer();
			timerSearchEnemy.start(1, updatePaths, 0);
		}
		else
		{
						
		}
		
		switch(faction)
		{
			case "fouleJaune":
				enemy = "fouleRouge";
				
			case "fouleRouge":
				enemy = "fouleJaune";
		}
	}
	
	public override function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	}	
	
	override public function draw():Void
	{
		super.draw();
		
		// To draw path
		if (path != null && !path.finished && followNumber == 2 && faction == "fouleJaune")
		{
			drawDebug();
		}
	}
	
	public function updatePaths(?Timer:FlxTimer):Void  // pour les leaders : définit un nouveau path vers la foule ennemie la plus proche
	{
		var paths : Array<Array<FlxPoint>>;			
		
		if (followNumber==0)
		{
			paths  = new Array<Array<FlxPoint>>();
			
			for (rioterEnemy in Reg.level.crowds)
			{
				if (rioterEnemy.followNumber==0 && rioterEnemy.faction == enemy)
				{
					var p : Array<FlxPoint>;
					p = findNewPath(this, rioterEnemy);
					
					if (p != null) paths.push (p);						
				}
			}
			
			if (paths.length == 1) // si un seul chemin
			{
				path = new FlxPath();
				path.start(paths[0],128);
				alpha = .5;
				//asign path to followers
				for (rioter in Reg.level.crowds)
				{
					if (rioter.followNumber > 0 && rioter.faction == this.faction)
					{
						rioter.asignPath(this);
					}
				}
			}
			
			// TODO sinon si plusieurs chemins prendre le plus court
			else if (paths.length >= 1)
			{
				path = new FlxPath();
				path.start(paths[0],128);
				alpha = .5;
				//asign path to followers
			}
			
			else
			{
				path = null;
			}
		}	
		
		else
		{
			var p : Array<FlxPoint>;
			for (rioter in Reg.level.crowds)
			{
				if (rioter.followNumber == 0 && rioter.faction == this.faction)
				{
					p = Reg.level.collidableTileLayers[0].findPath(
					FlxPoint.get(this.x + this.width / 2, this.y + this.height / 2),
					FlxPoint.get(rioter.x + rioter.width / 2, rioter.y + rioter.height / 2),
					false,
					false,
					NONE
					 );
					path = new FlxPath();
					//path.start(p, 128);
					
					if (p.length > followNumber)
					{
						path.start(p, 128);
						//if (faction == "fouleJaune") trace( followNumber);
					}
					
					else
					{
						path.cancel();
					}
				}
			}
		}
	}
	
	private function findNewPath(_unit:FlxSprite, _goal:FlxSprite ):Array<FlxPoint>
	{
		var pathPoints:Array<FlxPoint> = Reg.level.collidableTileLayers[0].findPath(
			FlxPoint.get(_unit.x + _unit.width / 2, _unit.y + _unit.height / 2),
			FlxPoint.get(_goal.x + _goal.width / 2, _goal.y + _goal.height / 2),
			false,
			false,
			NONE
			 );
		return pathPoints;
	}
	
	public function asignPath(/*_path : Array<FlxPoint>*/_target : FlxSprite):Void // TODO pour les followers : récupération du path du leader
	{
		/*var newPath: Array<FlxPoint>;
		newPath =_path.copy();
		//récuperer path du leader		
		// enelever les derniers points du path (pour que le follower n'aille pas se superposer au leader en fin de parcours) : 1 point si followNumber = 1, 2 si followNumber = 2
		newPath = newPath.splice(newPath.length-1-followNumber,followNumber);*/
		
		
		//ajouter points de l'ancien path entre le follower et le leader (pour que le follower aille jusqu'à la position actuelle du leader) : 1 point si followNumber = 1, 2 si followNumber = 2
		//méthode dégeulasse, on peut faire sans céer de nouveau path
		var p : Array<FlxPoint>;
		p = Reg.level.collidableTileLayers[0].findPath(
			FlxPoint.get(this.x + this.width / 2, this.y + this.height / 2),
			FlxPoint.get(_target .x + _target .width / 2, _target .y + _target .height / 2),
			false,
			false,
			NONE
			 );
		//newPath = p/*.concat(newPath)*/;
		
		//nouveau path : position du follower jusqu'à position du leader (depuis l'ancien path) + position du leader jusqu'à destination du leader - distance entre le follower et le leader
		
		
		path = new FlxPath();
		if (p.length > followNumber)
		{
			path.start(p, 128);
			//if (faction == "fouleJaune") trace( followNumber);
		}
		else
		{
			path.cancel();
			if (faction == "fouleJaune") trace( followNumber);			
		}
		
	}
}