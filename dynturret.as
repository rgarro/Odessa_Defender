

class dynturret extends MovieClip{
	
	public var angle:Number;
	public var firingsparks_mc:MovieClip;
	public var misilenum:Number;
	public var misilebelt:Object;
	public var misilename:String;
	
	public function dynturret(){
		this.misilenum = 0;
		this.angle = 0;
		this.misilebelt = new Object();
		this._rotation = this.angle;
		}
		
	public function onEnterFrame() {
		if (Key.isDown(88)) {
			this.angle = this.angle + 10;
    		this._rotation = this.angle;
    	}else if (Key.isDown(90)) {
    		this.angle = this.angle - 10;
    		this._rotation = this.angle;
    	} 
   	}
	
	
	public function canonfire(){	
		this.misilename = "hellf" + this.misilenum +"_mc";
		this.firingsparks_mc.gotoAndPlay(1);
		this.misilebelt[misilenum] = hellfiremisile(_root.attachMovie("hellfire",this.misilename,_root.getNextHighestDepth()));
		this.misilebelt[misilenum].setPos(_parent._x,_parent._y,this.angle);
		//Misile shaddow
		_root[this.misilename].setShadow(this.misilenum); // add a blur with default settings.
		_root.misilesound.playmissile();
		this.misilenum++;
		}
}