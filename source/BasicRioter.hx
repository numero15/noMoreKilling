package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.ui.FlxBar;
import flixel.util.FlxPath;
import flixel.FlxG;
import flixel.FlxObject;

class BasicRioter extends FlxSprite // un seul objet graphique
{
	public var faction : String;
	private var opponents : List<Rioter>;
	private var buildings : List<Building>;
	private var isMoving : Bool;
	private var enemy :String;
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
	public var goal : FlxPoint;
	
	public function new()
	{		
		super();
	}
	
	public function setup(X:Float, Y:Float, image_path:String /*source du .png*/, _faction : String):Void
	{
		this.revive();
		this.alpha = 0;
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
		isMoving = true;
		opponents = new List();
		buildings = new List();
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
		
		if (FlxG.game.ticks >= startTick + delayTicks-speed)
		{
			startTick = FlxG.game.ticks;
			if(isMoving)
				updatePaths();
		}
		if(bar!=null)
		{
			bar.x = this.x;
			bar.y = this.y;	
		}
	}
	
	
	//lancer quand le leader est arrivé à un point du path
	public function updatePaths(?_path:FlxPath):Void  // pour les leaders : définit un nouveau path vers la foule ennemie la plus proche
	{				
		
	}
	
	
	private function randomMovement():FlxPoint
	{
		var directions : Array<FlxPoint>;
				directions = new Array <FlxPoint>();
				var direction : FlxPoint = new FlxPoint();
				var coordTile : FlxPoint = new FlxPoint();
				coordTile.set(Math.round(this.x / Reg.TILE_SIZE), Math.round(this.y / Reg.TILE_SIZE));
				
				// trouve les case adjacentes libres
				if(freeTile(new FlxPoint(coordTile.x + 1, coordTile.y)))	
				//right					
					directions.push(new FlxPoint(coordTile.x * Reg.TILE_SIZE + Reg.TILE_SIZE / 2 + Reg.TILE_SIZE, coordTile.y * Reg.TILE_SIZE + Reg.TILE_SIZE / 2));
				
				//left	
				if(freeTile(new FlxPoint(coordTile.x - 1, coordTile.y)))	
					directions.push(new FlxPoint(coordTile.x * Reg.TILE_SIZE + Reg.TILE_SIZE / 2 - Reg.TILE_SIZE,  coordTile.y * Reg.TILE_SIZE + Reg.TILE_SIZE / 2));

				if(freeTile(new FlxPoint(coordTile.x, coordTile.y+1)))		
				//down					
					directions.push(new FlxPoint(coordTile.x * Reg.TILE_SIZE + Reg.TILE_SIZE / 2, coordTile.y * Reg.TILE_SIZE + Reg.TILE_SIZE / 2 + Reg.TILE_SIZE));

				if(freeTile(new FlxPoint(coordTile.x, coordTile.y-1)))		
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
			
				return  FlxPoint.get(direction.x, direction.y);
	}
	
	function freeTile(_p: FlxPoint) : Bool
	{
		if (Reg.level.foregroundTiles.getTileCollisions (Reg.level.foregroundTiles.getTile(Std.int(_p.x), Std.int(_p.y))) == FlxObject.ANY)
			return false;
		for (_sp in Reg.level.spawnTiles)
		{
			if (Std.int(_sp.x / Reg.TILE_SIZE) == _p.x && Std.int(_sp.y / Reg.TILE_SIZE) == _p.y)
				return false;
		}	
		
		return true;
	}
	
	private function collide(_p:FlxPoint):Bool
	{
			return false;
	}
	
	public function stopCrowd():Void
	{
		if (isMoving) //stop the crowd
			isMoving = false;				
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
			opponents.add(_opponent);
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
			else if (distInTile(this.getPosition(), op.getPosition() )< 2)
			{
				opponents.remove(op);
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
			// formule calcul des dommages SIMON
			addToDamage = Std.int((health / 10) * (1 + speed / 100));
			
			if (addToDamage < 50)
				addToDamage = 50;
				
			op.damage += addToDamage;
		}
		
		if (opponents.length == 0) // remettre la foule en marche si elle n'a pas de combat en cour
			this.isMoving = true;	
			
		// calculer les effets des batiments
		buildings.clear();
		
		// test si le leader est à portée d'un bâtiment
		overlapBuilding(this, buildings);
		
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
	
	public function hit():Void
	{
		if (damage > 0)	this.motivation--;
		
		if (motivation < 0) motivation = 0;
		
		this.health -= damage;
		
		if (this.health < 0) this.health = 0;			
	
		if (this.motivation <= 0 || this.health <= 0)// disperser la foule
		{			
			if(bar!=null)
				this.bar.kill();
			this.kill();
		}	
		
		damage = 0;
	}
	
	private function overlapBuilding(_r:BasicRioter, _buildings:List<Building>):Void
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

	
	override function kill():Void
	{			
		super.kill();
		if (opponents != null)
		{
			opponents.clear();
			opponents = null;
		}
		
		if(bar!=null)
		bar.kill();
	}
	
	override function destroy():Void
	{		
		super.destroy();
		if (opponents != null)
		{
			opponents.clear();
			opponents = null;
		}		
	}
}