package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.ui.FlxBar;
import flixel.util.FlxPath;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxObject;

class Rioter extends FlxSprite // un seul objet graphique
{
	public var faction : String;
	public var enemy : String;
	public var leaderId: Int;
	public var leader : Rioter;
	private var opponents : List<Rioter>; // only for leader
	private var buildings : List<Building>; // only for leader
	public var followers : List<Rioter>; //only for leader
	public var followNumber : Int; // place du rioter dans la foule : 3->2->1->leader(0)
	private var isMoving : Bool;
	// stat pour les combat
	public var speed : Int;
	public var speedMax : Int = 10;
	public var motivation : Int;
	public var motivationMax : Int = 200;
	// + health (native de FlxSprite)
	public var damage : Int; // utiliser pour différer l'application des dommages
	public var bar : FlxBar;
	public var startTick : Int;
	public var delayTicks : Int;
	public var previousPos : FlxPoint;
	
	public function new()
	{		
		super();
	}
	
	public function setup(X:Float, Y:Float, image_path:String /*source du .png*/, _faction : String, _followNumber: Int):Void
	{
		this.revive();
		this.setPosition(X + Reg.TILE_SIZE * .1, Y + Reg.TILE_SIZE * .1);
		this.loadGraphic(image_path, true, 16, 16);
		this.animation.frameIndex = 3;
		this.cameras = [FlxG.cameras.list[0]];
		
		previousPos = new FlxPoint(X, Y);
		
		alpha = 1;
		updateHitbox();
		setSize(Reg.TILE_SIZE * .8, Reg.TILE_SIZE * .8);
		centerOffsets();
		
		faction = _faction;
		followNumber = _followNumber;
		isMoving = true;
		opponents = new List();
		buildings = new List();
		followers = new List();
		motivation = 10;
		damage = 0;
		speed = 0;
		startTick = FlxG.game.ticks;
		delayTicks = 1000;
		
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
		if (followNumber == 0)
		{
			//bar.parentVariable = "health";
			/*trace ("FACTION = " + faction);
			trace ("motivation = " + motivation);
			trace("speed = " + speed);
			trace("health = " + health);
			trace("damage = " + damage);*/
			
			if (FlxG.game.ticks >= startTick + delayTicks-speed)
			{
				startTick = FlxG.game.ticks;
				if(isMoving)
					updatePaths();
			}
			
			bar.x = this.x;
			bar.y = this.y;		
		}
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
	
	//lancer quand le leader est arrivé à un point du path
	public function updatePaths(?_path:FlxPath):Void  // pour les leaders : définit un nouveau path vers la foule ennemie la plus proche
	{
		var paths : Array<Array<FlxPoint>> = new Array<Array<FlxPoint>>();			
		var p : Array<FlxPoint> = new Array <FlxPoint> ();
		
		if (followNumber==0 && isMoving) // est le leader, par sécurité
		{		
			// si motivation maximum trouver un path
			if (motivation == motivationMax)
			{
				for (rioterEnemy in Reg.level.crowds)
				{
					if (rioterEnemy.followNumber==0 && rioterEnemy.faction == enemy && rioterEnemy.alive)
					{					
						p = findNewPath(this, rioterEnemy);					
						if (p != null)
							paths.push (p);						
					}
				}
			//}
			
				if (paths.length == 1) // si un seul chemin
					p = paths[0];				
				
				// sinon si plusieurs chemins prendre le plus court
				else if (paths.length >= 1)
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
					p = paths[shorterPathId];				
				}
			}
			else // si pas de cible déplacement aléatoire
			{				
				var directions : Array<FlxPoint>;
				directions = new Array <FlxPoint>();
				var direction : FlxPoint = new FlxPoint();
				var coordTile : FlxPoint = new FlxPoint();
				coordTile.set(Math.round(this.x / Reg.TILE_SIZE), Math.round(this.y / Reg.TILE_SIZE));
				
				// trouve les case adjacentes libres
				if (Reg.level.foregroundTiles.getTileCollisions (Reg.level.foregroundTiles.getTile(Std.int(coordTile.x + 1), Std.int(coordTile.y)))!= FlxObject.ANY)
					//right					
					directions.push(new FlxPoint(coordTile.x * Reg.TILE_SIZE + Reg.TILE_SIZE / 2 + Reg.TILE_SIZE, coordTile.y * Reg.TILE_SIZE + Reg.TILE_SIZE / 2));

				if (Reg.level.foregroundTiles.getTileCollisions (Reg.level.foregroundTiles.getTile(Std.int(coordTile.x - 1), Std.int(coordTile.y)))!= FlxObject.ANY)
					//left					
					directions.push(new FlxPoint(coordTile.x * Reg.TILE_SIZE + Reg.TILE_SIZE / 2 - Reg.TILE_SIZE,  coordTile.y * Reg.TILE_SIZE + Reg.TILE_SIZE / 2));

				if (Reg.level.foregroundTiles.getTileCollisions (Reg.level.foregroundTiles.getTile(Std.int(coordTile.x), Std.int(coordTile.y) + 1))!= FlxObject.ANY)
					//down					
					directions.push(new FlxPoint(coordTile.x * Reg.TILE_SIZE + Reg.TILE_SIZE / 2, coordTile.y * Reg.TILE_SIZE + Reg.TILE_SIZE / 2 + Reg.TILE_SIZE));

				if (Reg.level.foregroundTiles.getTileCollisions (Reg.level.foregroundTiles.getTile(Std.int(coordTile.x), Std.int(coordTile.y) - 1))!= FlxObject.ANY)
					//up
					directions.push(new FlxPoint(coordTile.x * Reg.TILE_SIZE + Reg.TILE_SIZE / 2, coordTile.y * Reg.TILE_SIZE + Reg.TILE_SIZE / 2 - Reg.TILE_SIZE));
				
				// choisi une direction parmi les possibles
			
					if (directions.length == 1)
					{
						direction = directions[0];
					}	
					
					else if (directions.length > 1)
					{
						var Uturn : Int = -1;
						
						
						for ( i in 0...directions.length)
						{						
							if (Std.int(directions[i].x / Reg.TILE_SIZE) * Reg.TILE_SIZE == Std.int(previousPos.x / Reg.TILE_SIZE) * Reg.TILE_SIZE
							&&
							Std.int(directions[i].y / Reg.TILE_SIZE) * Reg.TILE_SIZE == Std.int(previousPos.y / Reg.TILE_SIZE) * Reg.TILE_SIZE) // enlève le demi tour
								Uturn = i;
														
						}						
						direction = directions[FlxG.random.int(0,directions.length-1, [Uturn])];
					}
			
				p = Reg.level.collidableTileLayers[0].findPath(
					FlxPoint.get(this.x + this.width / 2, this.y + this.height / 2),
					FlxPoint.get(direction.x, direction.y),
					false,
					false,
					NONE
					 );
			}
			
			if (!collide(new FlxPoint(p[1].x - this.width / 2, p[1].y - this.height / 2)))
			{
				// move leader
				previousPos.x = x;
				previousPos.y = y;
				this.x = p[1].x - this.width / 2;
				this.y = p[1].y - this.height / 2;
				
				//move followers
				
				
				//update followers in order
				var i : Int;
				i = 0;
				while (i < followers.length)
				{
					for (_f in followers)
					{					
						if (_f.followNumber == i + 1)
						{
							i++;
							
							_f.previousPos.x = _f.x;
							_f.previousPos.y = _f.y;
							
							
							if (_f.followNumber == 1)
							{						
								_f.x = previousPos.x;
								_f.y = previousPos.y;
							}
							
							else
							{
								for (_pf in followers)
								{
									if (_pf.followNumber == _f.followNumber-1)
									{
										_f.x = _pf.previousPos.x;
										_f.y = _pf.previousPos.y;
									}
								}
							}
						}
					}
				}
			}
			
		}	
	}
	
	private function collide(_p:FlxPoint):Bool // appeler uniquement sur les leaders
	{
		for (_r in Reg.level.crowds)
		{
			if (_r.x == _p.x && _r.y == _p.y && _r.alive)
			{
				//fight
				if (_r.faction != faction)
				{					
					_r.stopCrowd();
					stopCrowd();
					
					if (_r.followNumber == 0)
					{
						_r.addOpponent(this);
						addOpponent(_r);
					}
						
					else
					{
						_r.leader.addOpponent(this);
						addOpponent(_r.leader);
					}				
					
					
					return true;
				}
				
				//joint
				else if(_r.faction == faction && _r.leaderId != leaderId) // meme faction mais foule differente
				{					
					if (_r.followNumber != 0)
						jointOtherCrowd(_r.leader, _r.followNumber);
						
					else							
						jointOtherCrowd(_r, _r.followNumber);	
					
					return true;
				}
				
			}
		}
		return false;		
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
	
	public function stopCrowd():Void
	{
		if (isMoving) //stop the crowd
		{
			for (r in Reg.level.crowds)
			{
				if (r.leaderId == this.leaderId && r.isMoving)				
					r.isMoving = false;	
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
	
	public function cleanOpponents():Void
	{
		var removeBool : Bool = false;
		
		for (op in opponents)
		{
			// enlever l'opposant si il est mort
			if (!op.alive || op == null)
			{
				opponents.remove(op);
			}
			
			//enveler l'opposant si il n'est plus en contact
			// si le le leader ou un follower est en contact avec le leader ou un follower			
			else
			{
				removeBool = true;	
				
				if (distInTile(this.getPosition(), op.getPosition() )< 2)
				{
					removeBool = false;
				}
					
				for (op_f in op.followers)
				{					
					if (distInTile(this.getPosition(), op_f.getPosition()) < 2)
					{
						removeBool = false;
						break;
					}
				}
				
				for (f in followers)
				{
					if (distInTile(f.getPosition(), op.getPosition() )< 2)
					{
						removeBool = false;
					}
						
					for (op_f in op.followers)
					{					
						if (distInTile(f.getPosition(), op_f.getPosition()) < 2)
						{
							removeBool = false;
							break;
						}
					}
				}				
				
				if (removeBool)
				{
					opponents.remove(op);
				}
			}
		}
		
		
			
	}
	
	private function distInTile(_p1 : FlxPoint, _p2 : FlxPoint):Int
	{
		return Std.int( Math.abs (Std.int(_p1.x / Reg.TILE_SIZE) - Std.int(_p2.x / Reg.TILE_SIZE))  /*distance en tile sur l'axe x*/
					   + Math.abs (Std.int(_p1.y / Reg.TILE_SIZE) - Std.int(_p2.y / Reg.TILE_SIZE))); /*distance en tile sur l'axe y*/
	}
	
	public function fight():Void // appeler uniquement sur les leaders
	{
		cleanOpponents();
		
		var addToDamage : Int;
		for (op in opponents)
		{		
			// dommage minimum
			addToDamage = Std.int(health / 10);
			
			if (Std.int(health / 10) < 50)
				addToDamage = 50;
			
			if (op.leader != null)				
				op.leader.damage += addToDamage;
			
			else
				op.damage += addToDamage;
		}
		
		if (opponents.length == 0) // remettre la foule en marche si elle n'a pas de combat en cour
			this.isMoving = true;	

		// calculer les effets des batiments
		buildings.clear();
		
		// test si le leader est à portée d'un bâtiment
		overlapBuilding(this, buildings);
		
		// test si les followers sont à portée d'un bâtiment
		for (_f in followers)
		{
			overlapBuilding(_f, _f.leader.buildings);
		}
		
		for (_b in buildings)
		{
			damage -= _b.effectHealth;
			Reg.money += _b.effectResource;
			speed += _b.effectSpeed;
			if (speed > speedMax )
				speed = speedMax;
			if (speed < 0)
				speed = 0;
			
			motivation += _b.effectMotivation;
		}
	}
	
	public function hit():Void // appeler uniquement sur les leaders
	{
		if (damage > 0)	this.motivation--;
		
		if (motivation < 0) motivation = 0;
		
		if (Math.floor(this.health / 100) > Math.floor((this.health - damage) / 100) ) //enlever un follower
		{
			for (f in followers) // find last follower and remove it
			{				
				if (f.followNumber > Math.floor((this.health - damage) / 100))
				{
					followers.remove(f);
					f.kill();
				}
				
				/*if (followers.length == 0)
				{
					this.kill();
				}*/
			}
		}
		
		this.health -= damage;
		
		if (this.health < 0) this.health = 0;			
	
		if (this.motivation <= 0 || this.health <= 0)// disperser la foule
		{			
			for (f in followers)
			{
				followers.remove(f);
				f.kill();		
			}
			this.bar.kill();
			this.kill();
		}	
		
		for (rioter in Reg.level.crowds)
		{
			if (rioter.followNumber > 0 && rioter.faction == this.faction)
				rioter.updateGFX();
		}
		
		damage = 0;
	}
	
	private function overlapBuilding(_r:Rioter, _buildings:List<Building>):Void
	{
		var distInTile : Int;
		var isAdded : Bool;
		
		//enlever les batiments trop loin
		
		for (_b in Reg.level.buildings)
		{
			//calcul la distance en tile
			distInTile =Std.int( Math.abs (Std.int(_r.x / Reg.TILE_SIZE) - Std.int(_b.x / Reg.TILE_SIZE))  /*distance en tile sur l'axe x*/
					   + Math.abs (Std.int(_r.y / Reg.TILE_SIZE) - Std.int(_b.y / Reg.TILE_SIZE))); /*distance en tile sur l'axe y*/
					   
			
			isAdded = false;
				
			if (distInTile <= _b.radius) //si dans le rayon
			{				
				for (_activeBuilding in  _buildings) //si pas déjà présent
				{
					if (_b == _activeBuilding)
						isAdded = true;
				}
				if(!isAdded)
					_buildings.add(_b);
			}
		}
	}
	
	public function jointOtherCrowd(_otherLeader : Rioter, _followNumber:Int):Void // for leaders
	{
		if (followNumber == 0)
		{
			followNumber =  _followNumber + 1;
			leaderId = _otherLeader.leaderId;
			leader = _otherLeader;
			bar.kill();
			
			for ( _f in followers) // change les parametres des followers
			{
				_f.followNumber =  _followNumber + 1 + _f.followNumber;
				_f.leaderId = _otherLeader.leaderId;
				leader = _otherLeader;
			}
			
			for ( _f in _otherLeader.followers) // change les parametre des followers de l'autre foule
			{
				if (_f.followNumber > _followNumber)
				{
					_f.followNumber += this.followers.length + 1;
				}				
			}
			// ajoute les followers à l'autre foule
			for ( _f in followers)
			{
				_otherLeader.followers.push(_f);
			}
			
			_otherLeader.followers.push(this);
			
			for ( _f in _otherLeader.followers)
			{
				_f.alpha = 1 - (_f.followNumber + 1) / 10;
			}
			_otherLeader.alpha = 1;
			
			followers.clear();		
		}		
	}
	
	public function setAlpha():Void
	{
		if (followNumber > 0)
		{
			alpha = 1 - followNumber / (leader.health/100);
		}
	}
	
	private function updateGFX():Void
	{	
		//if (this.followNumber > 0)// n'est pas leader
		//	this.animation.frameIndex = 3-(Math.floor( this.followNumber / this.leader.followers.length * 3));
	}	
	
	override function kill():Void
	{			
		super.kill();
	}
	
	override function destroy():Void
	{		
		super.destroy();
		if (opponents != null)
		{
			opponents.clear();
			opponents = null;
		}
		leader = null;
		if (followers != null)
		{
			followers.clear();
			followers = null;
			//bar.kill();
		}
	}
}