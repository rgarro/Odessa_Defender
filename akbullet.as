

class akbullet extends MovieClip{
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
	public var myname:String;
	
	public function akbullet(){
		this.cannonLength = 10;
		this.maxtime = 25;
		this.timer = 0;
		this.speed = 25;
		this.tim = 0;
		this.k = 1;
		}
		
	public function setPos(xp:Number,yp:Number){	
			var a:Number;
			var b:Number
			var anguloRadianes:Number;
			var angleb:Number;
			var xcomponent:Number;
			var ycomponent:Number;
			_x = xp;
			_y = yp;
			a =  _root.tank_mc._y - this._y;
			b =  _root.tank_mc._x - this._x;
			anguloRadianes = Math.atan2(b,a);
			angleb = (Math.round(anguloRadianes * 180 / Math.PI)*-1);	
			this._rotation = angleb;
			this.myangle = (angleb/360)*2*Math.PI;
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
			//var temobj:Object;
			//temobj = new Object();
			_x -= this.xmove;
			_y -= this.ymove;
			
				if (this.hitTest(_root.tank_mc)) {
					_root.tank_mc.mylife = _root.tank_mc.mylife - 10;
					if(_root.tank_mc.mylife > 10){
						_root.tank_mc._alpha = _root.tank_mc.mylife;
					}
					if(_root.tank_mc.mylife == 0){
						_root.explosound.playBlast();
						this.createExplosion(_x,_y,500,1);
						_root.tank_mc._alpha = 0;
						//_root.tank_mc.removeMovieClip();
					}
					this.createExplosion(_x,_y,2,1);
					this.removeMovieClip();
				}
			

			if (this.timer>this.maxtime) {
				this.removeMovieClip();
			}
			this.timer++;
		}
		
		public function setMyName(bulletname:String){
			this.myname = bulletname;
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
	}