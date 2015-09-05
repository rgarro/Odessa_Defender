class enemyfleet extends MovieClip{
	public var temobj:Object;
	public var temobjb:Object;
	public var fleet:Object;
	public var chopperqty:Number;
	
	public function enemyfleet(){ 
		this.chopperqty = 4;
		this.temobj = new Object();
		this.temobjb = new Object();
		this.loadFleet();
	}
	
	public function loadFleet(){
		var tmpname:String;
		var i:Number = 0;
		while(i < this.chopperqty){
			tmpname = "mi24"+ i + "_mc"; 
			this.temobj = mi24(_root.attachMovie("mi24",tmpname, _root.getNextHighestDepth()));
			this.temobj.setShadow(i);
			this.fleet[i] = this.temobj;
			i++;
			}
	}
	
	public function onEnterFrame(){
		var i:Number;
		var j:Number;
		var tmpname:String;
		var tmpnameb:String;
		for(i=0;i<this.chopperqty;i++){  
			tmpname = "mi24"+ i + "_mc"; 
			for(j=0;j<this.chopperqty;j++){
				tmpnameb = "mi24"+ j + "_mc"; 
				if (_root[tmpname].hitTest(_root[tmpnameb])) {
					//_root[tmpnameb].dirchanger();
					_root[tmpname].dirchanger();
					//this.fleet[i].dirchanger();
				}
			}
		}
	}
}