package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.tiled.TiledImageLayer;
import flixel.addons.editors.tiled.TiledImageTile;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxBar;
import haxe.io.Path;

/**
 * @author Samuel Batista
 */
class TiledLevel extends TiledMap
{
	// For each "Tile Layer" in the map, you must define a "tileset" property which contains the name of a tile sheet image 
	// used to draw tiles in that layer (without file extension). The image file must be located in the directory specified bellow.
	private inline static var c_PATH_LEVEL_TILESHEETS = "assets/images/";
	
	public var spawnTiles:FlxTypedGroup<SpawnPoint>;
	public var foregroundTiles:FlxTilemap;
	public var buildingBase:FlxTilemap;
	public var buildingTop:FlxTilemap;
	public var fog01:FlxTilemap;
	public var fog02:FlxTilemap;
	public var objectsLayer:FlxGroup;
	public var backgroundLayer:FlxGroup;
	public var collidableTileLayers:Array<FlxTilemap>;	
	public var crowds : FlxTypedGroup<Rioter>;
	public var buildings : FlxTypedGroup<Building>;
	public var crowdsUI : FlxTypedGroup<FlxBar>;
	
	// Sprites of images layers
	public var imagesLayer:FlxGroup;
	
	public function new(tiledLevel:Dynamic, state:PlayState)
	{
		super(tiledLevel);
		
		imagesLayer = new FlxGroup();
		foregroundTiles = new FlxTilemap();
		buildingTop = new FlxTilemap();
		buildingBase = new FlxTilemap();
		fog01 = new FlxTilemap();
		fog02 = new FlxTilemap();
		objectsLayer = new FlxGroup();
		backgroundLayer = new FlxGroup();
		spawnTiles = new FlxTypedGroup<SpawnPoint>();
		crowds = new FlxTypedGroup<Rioter>(100);
		buildings = new FlxTypedGroup<Building>();
		crowdsUI = new FlxTypedGroup<FlxBar>(25);
		
		FlxG.camera.setScrollBoundsRect(0, 0, fullWidth, fullHeight, true);
		
		
		for (i in 0...100)
		{
			var _r = new Rioter();
			_r.kill();
			crowds.add(_r);
		}
		
		for (i in 0...25)
		{
			var _b = new FlxBar();
			_b.kill();
			crowdsUI.add(_b);
		}


		//loadImages();
		loadObjects(state);
		
		// Load Tile Maps
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.TILE) continue;
			var tileLayer:TiledTileLayer = cast layer;
			
			var tileSheetName:String = tileLayer.properties.get("tileset");
			
			if (tileSheetName == null)
				throw "'tileset' property not defined for the '" + tileLayer.name + "' layer. Please add the property to the layer.";
				
			var tileSet:TiledTileSet = null;
			for (ts in tilesets)
			{
				if (ts.name == tileSheetName)
				{
					tileSet = ts;
					break;
				}
			}
			
			if (tileSet == null)
				throw "Tileset '" + tileSheetName + " not found. Did you misspell the 'tilesheet' property in " + tileLayer.name + "' layer?";
				
			var imagePath 		= new Path(tileSet.imageSource);
			var processedPath 	= c_PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;
			
			var tilemap:FlxTilemap = new FlxTilemap();
			tilemap.loadMapFromArray(tileLayer.tileArray, width, height, processedPath,
				tileSet.tileWidth, tileSet.tileHeight, OFF, tileSet.firstGID, tileSet.firstGID, tileSet.firstGID+12); //tileSet.firstGID => numero du premier tile de la feuille (sur l'ensemble des tiles du niveau)
				
			if (tileLayer.name == "ground")
			{
				foregroundTiles = tilemap;
				if (collidableTileLayers == null)
					collidableTileLayers = new Array<FlxTilemap>();
				collidableTileLayers.push(tilemap);
			}
			
			if (tileLayer.name == "buildingBG")
			{
				buildingBase = tilemap;
			}
			
			if (tileLayer.name == "buildingFG")
			{
				buildingTop = tilemap;
				//trace(tileSet.firstGID);
			}
		}
	}
	
	public function loadObjects(state:PlayState)
	{
		var layer:TiledObjectLayer;
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.OBJECT)
				continue;
			var objectLayer:TiledObjectLayer = cast layer;
			
			//objects layer
			if (layer.name == "spawn")
			{
				for (o in objectLayer.objects)
				{
					loadSpawn(state, o, objectLayer, objectsLayer);
				}
			}
		}
	}
	
	private function loadSpawn(state:PlayState, o:TiledObject, g:TiledObjectLayer, group:FlxGroup)
	{
		var x:Int = o.x;
		var y:Int = o.y;
		
		// objects in tiled are aligned bottom-left (top-left in flixel)
		if (o.gid != -1)
			y -= g.map.getGidOwner(o.gid).tileHeight;
		
		var tileset = g.map.getGidOwner(o.gid);
		var faction : String = new String("");
		switch(tileset.name)
		{
			case "spawnRouge":
				faction = new String("red");
				
			case "spawnJaune":
				faction = new String("yellow");
		}
		
		var spawnPoint = new SpawnPoint(x, y, c_PATH_LEVEL_TILESHEETS + tileset.imageSource, faction);
		spawnPoint.count = Std.parseInt(o.properties.get("count"));
		spawnPoint.delayFirstSpawn = Std.parseInt(o.properties.get("delayFirstSpawn"));
		spawnPoint.delaySpawns = Std.parseInt(o.properties.get("delaySpawns"));
		spawnPoint.crowdSize = Std.parseInt(o.properties.get("crowdSize"));
		//trace(spawnPoint.crowdSize);
		
		spawnTiles.add(spawnPoint);
	}


	public function collideWithLevel(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool
	{
		if (collidableTileLayers == null)
			return false;

		for (map in collidableTileLayers)
		{
			// IMPORTANT: Always collide the map with objects, not the other way around. 
			//			  This prevents odd collision errors (collision separation code off by 1 px).
			if (FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate))
			{
				return true;
			}
		}
		return false;
	}
}