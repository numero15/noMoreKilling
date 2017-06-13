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
	public var building:BuildingDroppable;
	private var btn_next: FlxButton;
	private var btn_prev : FlxButton;
	private var bnt_validate : FlxButton;
	private var btn_close : FlxButton;
	private var btn_validate : FlxButton;
	private var currentBuilding : Int;
	
	public function new(MaxSize:Int=0) 
	{
		super(MaxSize);	
		
		currentBuilding = 1;
		
		building = new BuildingDroppable(0, 0, "garage");
		
		btn_prev = new FlxButton(32, 32, "",changeBuilding.bind( -1));
		btn_prev.loadGraphic ("assets/images/btnClose.png");
		btn_prev.x = -Reg.TILE_SIZE;
		btn_prev.scrollFactor.set(1, 1);
		
		btn_next = new FlxButton(32, 32, "",changeBuilding.bind( -1));	
		btn_next.loadGraphic ("assets/images/btnClose.png");
		btn_next.x = Reg.TILE_SIZE;
		btn_next.scrollFactor.set(1, 1);
		
		btn_close = new FlxButton(32, 32, "", kill);
		btn_close.loadGraphic ("assets/images/btnClose.png");
		btn_close.x = Reg.TILE_SIZE;
		btn_close.scrollFactor.set(1, 1);
		
		btn_validate = new FlxButton(32, 32, "", kill);
		btn_validate.active = false;
		btn_validate.loadGraphic ("assets/images/btnClose.png");
		btn_validate.x = Reg.TILE_SIZE;
		btn_validate.scrollFactor.set(1, 1);

		
		add(building);
		add(btn_close);
		add(btn_validate);
		add(btn_next);
		add(btn_prev);
		
		forEach(function(_b:FlxBasic):Void
		{			
			_b.cameras = [FlxG.cameras.list[0]];
		});
	}	
	
	private function changeBuilding(_sens : Int):Void
	{
		if (currentBuilding + _sens < 0)
			currentBuilding = Reg.buildingsAvailables.length - 1;

		else if (currentBuilding + _sens > Reg.buildingsAvailables.length - 1)
			currentBuilding = 0;
			
		else
			currentBuilding += _sens;
			
		building.set(Reg.buildingsAvailables[currentBuilding]);
	}	
	
	public function customRevive(_pos : FlxPoint):Void
	{
		super.revive();
		
		building.set(Reg.buildingsAvailables[currentBuilding]);
		//trace(Reg.buildingsAvailables[currentBuilding]);
		building.setPosition(_pos.x, _pos.y);	
		btn_prev.x = _pos.x-Reg.TILE_SIZE*1.5;
		btn_next.x = _pos.x+Reg.TILE_SIZE*.5 ;
		btn_prev.y = btn_next.y = _pos.y - Reg.TILE_SIZE;
		
		btn_close.y = _pos.y - Reg.TILE_SIZE * 2;
		btn_close.x = _pos.x  - Reg.TILE_SIZE * .5;
		
		btn_validate.y = _pos.y - Reg.TILE_SIZE;
		btn_validate.x = _pos.x  - Reg.TILE_SIZE * .5;
	}
}