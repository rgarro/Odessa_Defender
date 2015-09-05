
import com.mosesSupposes.fuse.*;

class hellfiremisile extends MovieClip{
	public var xmove:Number;
	public var ymove:Number;
	public var myangle:Number;
	public var cannonLength:Number;
	public var timer:Number;
	public var tim:Number;
	public var maxtime:Number;
	public var tmpname:String;
	public var speed:Number;
	public var k:Number;
		
	
	public function hellfiremisile(){
		this.cannonLength = 100;
		this.maxtime = 10;
		this.timer = 0;
		this.speed = 25;
		this.tim = 0;
		this.k = 1;
		}
	
	public function setPos(xp:Number,yp:Number,angle:Number){	
			var angleb:Number;
			var xcomponent:Number;
			var ycomponent:Number;
			this._rotation = angle;
			this.myangle = (angle/360)*2*Math.PI;
			xcomponent = this.cannonLength*Math.sin(this.myangle);
			ycomponent = -this.cannonLength*Math.cos(this.myangle);
			_x = xcomponent+xp;
			_y = ycomponent+yp;
			this.xmove = (xcomponent/this.cannonLength)*this.speed;
			this.ymove = (ycomponent/this.cannonLength)*this.speed ;
		}
	
	
 	public function onEnterFrame() {
		var i:Number;
		//var tmpname:String;
		var temobj:Object;
		temobj = new Object();
		_x += this.xmove;
		_y += this.ymove;
		for (i=0; i<_root.totalchoppers; i++) {
			if(this.k ==1){
				this.tmpname = "mi24"+ i + "_mc";
			}
			if (this.hitTest(_root[this.tmpname]) && this.k ==1) {
				this.k = 2;				
				_root.explosound.playBlast();
				this.createExplosion(_x,_y,500,1);
				_root.points += 100;			
				_root[this.tmpname].removeMovieClip();
				temobj = mi24(_root.attachMovie("mi24",this.tmpname, _root.getNextHighestDepth()));
				temobj.setShadow(i);
				_root.eventtank.enemychoppers.fleet[i] = temobj;
				this.removeMovieClip();
			}
		}
		this.timer++;
		if (this.timer>this.maxtime) {
			this.createExplosion(_x,_y,3,1);
			this.removeMovieClip();
		}
	}
	
	public function createExplosion(x,y,max,sameColor){
		var currentParticle = 0;
		var colors = new Array("0xFF0000","0xFFFF00");
        var c;
        if(sameColor){
			c = colors[int(Math.random()*colors.length)];
		}
		for(var i=0; i < max; i++){
			if(!sameColor){
				c = colors[int(Math.random()*colors.length)];
			}
			_root.attachMovie("Particle","P"+currentParticle,_root.getNextHighestDepth(),{_x:x,_y:y,rgbValue:c});
			currentParticle++;
		}
	}
	
	public function setShadow(i:Number){		
		var tmpname:String;
		tmpname = "hellf" + i +"_mc"; 
		_root[tmpname].writeFilter('Bevel'); // add a blur with default settings.
		_root[tmpname].DropShadow_distance = 15; // adds a dropshadow & set distance
		_root[tmpname].DropShadow_alpha = .1; // filter alphas are 0-1 multipliers
		}
}