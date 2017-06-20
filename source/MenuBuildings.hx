package;

import flixel.FlxBasic; 
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.ui.FlxButton;

/**
 * ...
 * @author ...
 */
class MenuBuildings extends FlxGroup
{
	public var buildingPreview:BuildingDroppable;
	private var btn_next: FlxButton;
	private var btn_prev : FlxButton;
	private var bnt_validate : FlxButton;
	private var btn_remove : FlxButton;
	private var btn_upgrade : FlxButton;
	private var btn_close : FlxButton;
	private var btn_validate : FlxButton;
	private var currentBuilding : Int;
	private var pos : FlxPoint;
	private var building : Building; //pointer vers le building si il existe
	private var parentButton : FlxButton;
	
	public function new(MaxSize:Int=0) 
	{
		super(MaxSize);	
		
		currentBuilding = 0;
		pos = new FlxPoint(0, 0);
		
		buildingPreview = new BuildingDroppable(0, 0, "garage");
		
		btn_prev = new FlxButton(32, 32, "", changeBuilding.bind( -1));
		btn_prev.active = false;
		btn_prev.loadGraphic ("assets/images/btnClose.png");
		btn_prev.x = -Reg.TILE_SIZE;
		btn_prev.scrollFactor.set(1, 1);
		
		btn_next = new FlxButton(32, 32, "", changeBuilding.bind( 1));	
		btn_next.active = false;
		btn_next.loadGraphic ("assets/images/btnClose.png");
		btn_next.x = Reg.TILE_SIZE;
		btn_next.scrollFactor.set(1, 1);
		
		btn_upgrade = new FlxButton(32, 32, "", changeBuilding.bind( 1));	
		btn_upgrade.active = false;
		btn_upgrade.loadGraphic ("assets/images/btnClose.png");
		btn_upgrade.x = Reg.TILE_SIZE;
		btn_upgrade.scrollFactor.set(1, 1);
		
		btn_close = new FlxButton(32, 32, "", kill);
		btn_close.active = false;
		btn_close.loadGraphic ("assets/images/btnClose.png");
		btn_close.x = Reg.TILE_SIZE;
		btn_close.scrollFactor.set(1, 1);
		
		btn_remove = new FlxButton(32, 32, "", removeBuilding);
		btn_remove.active = false;
		btn_remove.loadGraphic ("assets/images/btnClose.png");
		btn_remove.x = Reg.TILE_SIZE;
		btn_remove.scrollFactor.set(1, 1);
		
		btn_validate = new FlxButton(32, 32, "", addBuilding);
		btn_validate.active = false;
		btn_validate.loadGraphic ("assets/images/btnClose.png");
		btn_validate.x = Reg.TILE_SIZE;
		btn_validate.scrollFactor.set(1, 1);

		btn_close.kill();
		btn_next.kill();
		btn_prev.kill();
		btn_validate.kill();
		btn_remove.kill();
		btn_upgrade.kill();
		
		add(buildingPreview);
		add(btn_remove);
		add(btn_close);
		add(btn_validate);
		add(btn_next);
		add(btn_prev);
		add(btn_upgrade);
		
		buildingPreview.kill();
		
		forEach(function(_b:FlxBasic):Void
		{			
			_b.cameras = [FlxG.cameras.list[0]];
		});
		
		kill();
	}	
	
	private function changeBuilding(_sens : Int):Void
	{
		if (currentBuilding + _sens < 0)
			currentBuilding = Reg.buildingsAvailables.length - 1;

		else if (currentBuilding + _sens > Reg.buildingsAvailables.length - 1)
			currentBuilding = 0;
			
		else
			currentBuilding += _sens;
			
		buildingPreview.set(Reg.buildingsAvailables[currentBuilding]);
	}	
	
	private function addBuilding():Void
	{
		if (!buildingPreview.isAffordable)
			return;
		
		var _b : Building = new Building(Std.int(pos.x / Reg.TILE_SIZE) * Reg.TILE_SIZE, Std.int(pos.y / Reg.TILE_SIZE)* Reg.TILE_SIZE -1, Reg.buildingsAvailables[currentBuilding]);
		
		_b.cameras = [FlxG.cameras.list[0]];
		Reg.level.buildings.add(_b);
		
		kill();				
	}
	
	private function removeBuilding():Void
	{		
		if (building != null)
			building.removeBuilding();
		kill();				
	}
	
	private function upgradeBuilding():Void
	{
		kill();				
	}
	
	public function customRevive(_pos : FlxPoint, _b: FlxButton):Void
	{
		super.revive();
		pos = _pos;
		parentButton = _b;
		
		if(Reg.level.buildingBase.getTile(Std.int(pos.x / Reg.TILE_SIZE), Std.int(pos.y / Reg.TILE_SIZE)-1) == 0) //menu ajout
		{
			btn_close.revive();
			btn_next.revive();
			btn_prev.revive();
			btn_validate.revive();			
		
			btn_remove.kill();
			btn_upgrade.kill();		
			
			btn_close.active = true;		
			btn_next.active = true;
			btn_prev.active = true;
			btn_validate.active = true;
			
			btn_remove.active = false;
			btn_upgrade.active = false;
			
			buildingPreview.revive();
			
			buildingPreview.set(Reg.buildingsAvailables[currentBuilding]);
			buildingPreview.setPosition(_pos.x, _pos.y);	
			
			btn_prev.x = _pos.x-Reg.TILE_SIZE*1.5;
			btn_next.x = _pos.x+Reg.TILE_SIZE*.5 ;
			btn_prev.y = btn_next.y = _pos.y - Reg.TILE_SIZE;
			
			btn_close.y = _pos.y - Reg.TILE_SIZE * 2;
			btn_close.x = _pos.x  - Reg.TILE_SIZE * .5;
			
			btn_validate.y = _pos.y;
			btn_validate.x = _pos.x  - Reg.TILE_SIZE * .5;
		}
		
		else//menu modification
		{			
			// trouve le building
			for (_b in Reg.level.buildings)
			{
				if (_b.getPosition().distanceTo(pos)<Reg.TILE_SIZE)
				{
					trace("get building");
					building = _b;
					break;
				}
			}
			
			building.isSelected = true;	
			building.radiusGFX.alpha = 0;
			
			btn_close.revive();
			btn_remove.revive();
			btn_upgrade.kill();
			
			btn_prev.kill();
			btn_next.kill();
			btn_validate.kill();
			
			buildingPreview.kill();
			
			btn_close.active = true;		
			btn_remove.active = true;
			btn_upgrade.active = true;			
			btn_next.active = false;
			btn_prev.active = false;
			btn_validate.active = false;
			
			btn_close.y = _pos.y - Reg.TILE_SIZE * 2;
			btn_close.x = _pos.x  - Reg.TILE_SIZE * .5;
			
			btn_remove.y = _pos.y;
			btn_remove.x = _pos.x  - Reg.TILE_SIZE * .5;
		}		
	}
	
	override function kill()
	{
		super.kill();
		
		btn_close.active = false;
		btn_next.active = false;
		btn_prev.active = false;
		btn_validate.active = false;
		btn_remove.active = false;
		btn_upgrade.active = false;
		
		btn_close.kill();
		btn_next.kill();
		btn_prev.kill();
		btn_validate.kill();
		btn_remove.kill();
		btn_upgrade.kill();
		
		buildingPreview.kill();
		
		if (building != null)
			building.isSelected = false;
		
		building = null;
		
		if(parentButton!=null)
		{
			parentButton.revive();
			parentButton.active = true;
		}
		parentButton = null;
	}
	
	override function destroy()
	{
		btn_close.destroy();
		btn_close = null;
		btn_next.destroy();
		btn_next = null;
		btn_prev.destroy();
		btn_prev = null;
		btn_validate.destroy();
		btn_validate = null;
		btn_remove.destroy();
		btn_remove = null;
		btn_upgrade.destroy();
		btn_upgrade = null;
		buildingPreview.destroy();
		buildingPreview = null;
		super.destroy();
	}
}