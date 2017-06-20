package utils;
import flixel.tile.FlxTilemap;
import flixel.util.FlxArrayUtil;
import flixel.FlxObject;
import flixel.math.FlxPoint;

/**
 * ...
 * @author numero 15
 */
class CustomHeatmap 
{
	
	public static function computeDistances(TileMap: FlxTilemap):Array<Int> // lourd, ne pas exécuter à chaque génération de la heatmap
	{
		// Create a distance-based representation of the tilemap.
		// All walls are flagged as -2, all open areas as -1.
		
		var mapSize:Int = TileMap.widthInTiles * TileMap.heightInTiles;
		var distances:Array<Int> = new Array<Int>(/*mapSize*/);
		
		FlxArrayUtil.setLength(distances, mapSize);
		var i:Int = 0;
		while (i < mapSize)
		{
			if (TileMap.getTileCollisions(TileMap.getTileByIndex(i)) != FlxObject.NONE)
			{
				distances[i] = -2;
			}
			else
			{
				distances[i] = -1;
			}
			i++;
		}
		
		return(distances);
	}
	
	
	//return array de FlxPoint (index du tile à modifier, valeur du tile à modifier);
	public static function computePathDistance(TileMap: FlxTilemap, Distances:Array<Int>, StartIndex:Int, EndIndex:Int, StopOnEnd:Bool = false):Array<FlxPoint>
	{	
		var tileMap : FlxTilemap;
		var distances:Array<Int>;		
		var distance:Int = 1;
		var neighbors:Array<Int> = [StartIndex];
		var current:Array<Int>;
		var currentIndex:Int;
		var left:Bool;
		var right:Bool;
		var up:Bool;
		var down:Bool;
		var currentLength:Int;
		var foundEnd:Bool = false;
		var radius : Int = 15;
		var distancesReturn : Array<FlxPoint>;
		
		StopOnEnd = true;
		EndIndex = radius + StartIndex;
		
		tileMap = TileMap;
		distances = Distances.copy();
		distancesReturn = [];
		
		distances[StartIndex] = 0;
		
		var i:Int = 0;
		while (neighbors.length > 0)
		{
			current = neighbors;
			neighbors = new Array<Int>();
			
			i = 0;
			currentLength = current.length;
			while (i < currentLength)
			{	
				currentIndex = current[i++];				
				// Basic map bounds
				left = currentIndex % tileMap.widthInTiles > 0;
				right = currentIndex % tileMap.widthInTiles < tileMap.widthInTiles - 1;
				up = currentIndex / tileMap.widthInTiles > 0;
				down = currentIndex / tileMap.widthInTiles < tileMap.heightInTiles - 1;
				
				var index:Int;
				
				if(currentIndex % tileMap.widthInTiles < StartIndex % tileMap.widthInTiles - radius) foundEnd = true;
				if(currentIndex % tileMap.widthInTiles > StartIndex % tileMap.widthInTiles + radius) foundEnd = true;
				if(currentIndex / tileMap.widthInTiles < StartIndex / tileMap.widthInTiles - radius) foundEnd = true;
				if (currentIndex / tileMap.widthInTiles > StartIndex / tileMap.widthInTiles + radius) foundEnd = true;
				
				if (StopOnEnd  && foundEnd)
				{
					neighbors = [];
					break;
				}
				
				if (up)
				{
					index = currentIndex - tileMap.widthInTiles;
					
					if (distances[index] == -1)
					{
						if (distance < radius)
						{
							distances[index] = distance;
							distancesReturn.push(new FlxPoint(index, distance*30));
						}
						
						neighbors.push(index);
					}
				}
				if (right)
				{
					index = currentIndex + 1;
					
					if (distances[index] == -1)
					{
						if (distance < radius)
						{
							distances[index] = distance;
							distancesReturn.push(new FlxPoint(index, distance*30));
						}
						
						neighbors.push(index);
					}
				}
				if (down)
				{
					index = currentIndex + tileMap.widthInTiles;
					
					if (distances[index] == -1)
					{
						if (distance < radius)
						{
							distances[index] = distance;
							distancesReturn.push(new FlxPoint(index, distance*30));
						}
						
						neighbors.push(index);
					}
				}
				if (left)
				{
					index = currentIndex - 1;
					
					if (distances[index] == -1)
					{
						if (distance < radius)
						{
							distances[index] = distance;
							distancesReturn.push(new FlxPoint(index, distance*30));
						}
						
						neighbors.push(index);
					}
				}
			}
			distance++;
		}

		if (!foundEnd)
		{
			distances = null;
		}
		
		return distancesReturn;
		//return distances;
	}

	
}