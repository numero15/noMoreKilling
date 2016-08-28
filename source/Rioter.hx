package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxPath;
import flixel.util.FlxTimer;
import flixel.FlxG;

class Rioter extends FlxSprite // un seul objet graphique
{
	public var faction : String;
	public var enemy : String;
	public var isLeader :Bool; // TODO potentiellement inutile, nettoyer le code pour enlever toutes ref à isLeader, remplacer par followNumber=0
	public var leaderId: Int;
	public var leader : Rioter;
	private var opponents : List<Rioter>; // only for leader
	public var followers : List<Rioter>; //only for leader
	public var followNumber : Int; // place du rioter dans la foule : 3->2->1->leader(0)
	private var timerSearchEnemy : FlxTimer;
	private var isMoving : Bool;
	// stat pour les combat
	public var speed : Int;
	public var motivation : Int;
	// + health (native de FlxSprite)
	public var damage : Int; // utiliser pour différer l'application des dommages
	
	public function new(X:Float, Y:Float, image_path:String /*source du .png*/, _faction : String, _followNumber: Int)
	{		
		super(X+Reg.TILE_SIZE * .1, Y+Reg.TILE_SIZE * .1, image_path);
		this.cameras = [FlxG.cameras.list[0]];
		
		alpha = .5;
		updateHitbox();
		setSize(Reg.TILE_SIZE * .8, Reg.TILE_SIZE * .8);
		centerOffsets();
		
		faction = _faction;
		followNumber = _followNumber;
		isMoving = true;
		opponents = new List();
		followers = new List();
		motivation = 10;
		damage = 0;
		
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
			case "yellow":
				enemy = "red";
				
			case "red":
				enemy = "yellow";
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
		/*if (path != null && !path.finished && followNumber == 2 && faction == "fouleJaune")
		{
			drawDebug();
		}*/
	}
	
	public function updatePaths(?Timer:FlxTimer):Void  // pour les leaders : définit un nouveau path vers la foule ennemie la plus proche
	{
		var paths : Array<Array<FlxPoint>>;			
		//trace (followNumber);
		if (followNumber==0) // est le leader
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
			
			if (paths.length == 1 && isMoving) // si un seul chemin
			{
				path = new FlxPath();
				path.start(paths[0], 16);
				alpha = .5;
				//asign path to followers
				for (rioter in Reg.level.crowds)
				{
					if (rioter.followNumber > 0 && rioter.faction == this.faction)
					{
						rioter.asignPath(/*this*/paths[0]);
					}
				}
			}
			
			// TODO sinon si plusieurs chemins prendre le plus court
			else if (paths.length >= 1  && isMoving)
			{
				// trouve la destination la plus proche PAS TESTE
				var shorterPath : Int = paths[0].length;
				var shorterPathId : Int = 0;
				for (i in 1...paths.length)
				{
					if (paths[i].length < shorterPath)
					{
						shorterPathId = i;
						shorterPath = paths[i].length;
					}
				}
				
				path = new FlxPath();
				path.start(paths[shorterPathId],16);
				alpha = .5;
				//asign path to followers
			}
			
			else
			{
				path = null;
			}
			
			overlapBuilding();
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
						path.start(p, 16);
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
	
	public function asignPath(_path : Array<FlxPoint>/*_target : FlxSprite*/):Void // TODO pour les followers : récupération du path du leader
	{
		var newPath: Array<FlxPoint>;
		newPath =_path.copy();
		//récuperer path du leader		
		// enelever les derniers points du path (pour que le follower n'aille pas se superposer au leader en fin de parcours) : 1 point si followNumber = 1, 2 si followNumber = 2
		newPath.splice(newPath.length-1-followNumber,followNumber);
		
		
		//ajouter points de l'ancien path entre le follower et le leader (pour que le follower aille jusqu'à la position actuelle du leader) : 1 point si followNumber = 1, 2 si followNumber = 2
		//méthode dégeulasse, on peut faire sans céer de nouveau path
		var p : Array<FlxPoint>;
		p = Reg.level.collidableTileLayers[0].findPath(
			FlxPoint.get(this.x + this.width / 2, this.y + this.height / 2),
			//FlxPoint.get(_target.x + _target.width / 2, _target.y + _target.height / 2),
			FlxPoint.get(newPath[0].x, newPath[0].y),
			false,
			false,
			NONE
			 );
		newPath = p/*.concat(newPath)*/;
		
		//nouveau path : position du follower jusqu'à position du leader (depuis l'ancien path) + position du leader jusqu'à destination du leader - distance entre le follower et le leader
		
		
		path = new FlxPath();
		if (newPath.length > followNumber)
		{
			path.start(newPath, 16);
			//if (faction == "fouleJaune") trace( followNumber);
		}
		else
		{
			path.cancel();			
		}		
	}
	
	public function stopCrowd():Void
	{
		if (isMoving) //stop the crowd
		{
			for (r in Reg.level.crowds)
			{
				if (r.leaderId == this.leaderId)
				{
					r.isMoving = false;
					r.path.cancel();
				}
			}			
		}
	}
	
	public function addOpponent(_opponent:Rioter):Void // appeler uniquement sur les leaders
	{
		var newOpponent : Bool = true;
		
		//test si l'opposant existe déjà
		for (op in opponents)
		{
			if (op == _opponent)
			{
				newOpponent = false;
				break;
			}
		}
		//sinon l'ajouter
		if (newOpponent)		
		{
			opponents.add(_opponent);
		}
	}
	
	public function fight():Void // appeler uniquement sur les leaders
	{
		for (op in opponents)
		{
			// enlever l'opposant si il est mort

			if (!op.alive  || op == null)
			{
				opponents.remove(op);
			}
			
			//TODO enveler l'opposant si il n'est plus en contact
			
			else
			{
				if (op.leader != null)				
				{
					//op.leader.hit(Std.int(health/10));
					op.leader.damage += Std.int(health / 10);
				}
				
				else
				{
					//op.hit(Std.int(health/10));
					op.damage += Std.int(health / 10);
				}
			}
		}
		
		if (opponents.length == 0) // remettre la foule en marche si elle n'a pas de combat en cour
		{
			this.isMoving = true;			
		}
	}
	
	public function hit():Void // appeler uniquement sur les leaders
	{
		if (damage > 0)
		{
			this.motivation--;
		}
		if (motivation < 0) motivation = 0;
		
		if (Math.floor(this.health / 100) > Math.floor((this.health - damage) / 100) ) //enlever un follower
		{
			for (f in followers) // find last follower and remove it
			{				
				if (f.followNumber > Math.floor((this.health - damage) / 100) + 1)
				{
					followers.remove(f);
					f.kill();
					//f.destroy();
				}
				
				if (followers.length == 0)
				{
					this.kill();
					//this.destroy();
				}
			}
		}
		
		this.health -= damage;
		
		if (this.health < 0) this.health = 0;		
		
		if (this.motivation <= 0)// disperser la foule
		{
			for (f in followers)
			{
				followers.remove(f);
				f.kill();
				//f.destroy();				
			}
			this.kill();
			//this.destroy();
		}		
		damage = 0;
	}
	
	private function overlapBuilding():Void
	{
		var distInTile : Int;
		
		for (_b in Reg.level.buildings)
		{
			distInTile =Std.int( Math.abs (Std.int(this.x / Reg.TILE_SIZE) - Std.int(_b.x / Reg.TILE_SIZE))  /*distance en tile sur l'axe x*/
					   + Math.abs (Std.int(this.y / Reg.TILE_SIZE) - Std.int(_b.y / Reg.TILE_SIZE))); /*distance en tile sur l'axe y*/
					   
			//trace(distInTile);
			if (distInTile <= _b.radius)
			{
				//trace('overlap batiment' + _b.ID);
			}
		}
	}
	override function kill():Void
	{	
		
		//timerSearchEnemy.cancel();
		if (followNumber == 0)
		{
			timerSearchEnemy.cancel();
			//trace(timerSearchEnemy.active);
		}
		super.kill();
	}
	
	override function destroy():Void
	{		
		super.destroy();
		opponents.clear();
		opponents = null;
		leader = null;
		followers.clear();
		followers = null;
	}
}