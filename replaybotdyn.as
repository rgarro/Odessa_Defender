

class replaybotdyn extends MovieClip{
	public function replaybotdyn(){
			this._x = 518;
			this._y = 560;
			this._height = 24;
			this._width = 67;
		}
	
	public function onPress(){
		_root.te.changeWH(this, 77, 34);
	}
	
	public function onRelease(){
		_root.te.changeWH(this, 67, 24);
		_root.tank_mc.mylife = 100;
		_root.tank_mc._alpha = 100;
		_root.points = 0;
		}
	
	public function onRollOut(){
		_root.te.fadeTo(this,100);
		_root.te.changeWH(this, 67, 24);
		}
		
	public function onRollOver(){
		_root.te.fadeTo(this,50);
		_root.te.changeWH(this, 77, 34);
		}
}