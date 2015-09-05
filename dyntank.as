

class dyntank extends MovieClip{
	
	public var myturret:Object;
	public var fight:Boolean;
	public var angle:Number;
	public var mylistener:Object;
	public var keynum:Number;
	public var mylife:Number;
	
	public function dyntank(){
		this.mylistener = new Object();
		this.mylife = 100;
		/*this.mylistener.onKeyDown = function(){
			if (Key.getCode() == 32) {			
    			this.myturret.canonfire();
    		}
		}*/
		//Key.addListener(this.mylistener);
		this.myturret = dynturret(this.attachMovie("turret","turret_mc",this.getNextHighestDepth()));
		this.myturret.writeFilter('Bevel'); // add a blur with default settings.
		_root.tank_mc.DropShadow_distance = 15; // adds a dropshadow & set distance
		_root.tank_mc.DropShadow_alpha = .1; // filter alphas are 0-1 multipliers
		this.setInitPos();
		}
	
	private function setInitPos(){
			this.angle = 0;
			this._x = Stage.width / 2;
			this._y = Stage.height - 100;
			this._rotation = this.angle;
		}
	
	public function onLoad(){
			this.fight = false;
		}
	
	public function onEnterFrame() {
    	if (this.fight == false) {
    		if (Key.isDown(Key.LEFT) && this.fight != true) {
				this.angle = 270
    			this._x -= 5
    		}else if (Key.isDown(Key.RIGHT) && this.fight != true) {
    			this.angle = 90
    			this._x += 5
    		}
    		if (Key.isDown(Key.DOWN) && fight != true) {
    			this.angle = 180
    			this._y += 5
    		}else if (Key.isDown(Key.UP) && fight != true) {
    			this.angle = 0;
    			this._y -=5
    		}
    	}
    	if (Key.isDown(Key.LEFT) && Key.isDown(Key.DOWN)) {
    		this.angle = 225;
    	}
    	if (Key.isDown(Key.RIGHT) && Key.isDown(Key.UP)) {
         	this.angle = 45;
    	}
    	if (Key.isDown(Key.RIGHT) && Key.isDown(Key.DOWN)) {
    		this.angle = 135;
    	}
    	if (Key.isDown(Key.LEFT) && Key.isDown(Key.UP)) {
    		this.angle = 315;
    	}  
		if(Key.isDown(Key.SPACE)){
				if(this.mylife > 0){
					this.myturret.canonfire();
				}
			}
	
		this.myturret._rotation = this.myturret.angle - this.angle;
		this._rotation = this.angle;
    }				
	
	public function movements(){
			trace("aqui");
		}	
}    