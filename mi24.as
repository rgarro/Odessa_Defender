
class mi24 extends MovieClip{
	
	public var mypads:MovieClip;
	public var dir:Number;
	public var speed:Number;
	public var mynum:Number;
	public var attackFreq:Number;
	public var attackInterval:Number;
	public var mitime:Number;
	public var rest:Number;
	public var bulletname:String;
	public var bulletnum:Number;
	public var bulletbelt:Object;
	
	public function mi24(){		
		this._width = 141;
		this._height = 121;
		this.speed = 1 + Math.round(Math.random()*8);
		this.setRandomPos();
		this.dir = Math.round(Math.random(2));
		this.setAttackFreq();
		this.mitime = 0;
		this.rest = 0;
		this.bulletnum = 0;
		this.bulletbelt = new Object();
//setInterval(this.attack(),this.attackFreq);
		}
	
	public function setAttackFreq(){
		 var freq:Array = Array(24,32,40,48,56);
		 var i:Number = Math.round(Math.random(5));
			this.attackFreq = freq[i];
		}
		
	public function onEnterFrame(){
			/*using this until set interval issue fixed*/
			if(this.mitime > this.attackFreq){
					this.rest = this.mitime % this.attackFreq;
					if(this.rest == 0){
							this.attack()
						}
				}
			/**/
			if (this.dir == 0) {
				vertical();
			} else {
				hortical();
			}
			this.mitime ++;
		}	
	
	public function setRandomPos(){
			this._x = random(Stage.width);
			this._y = -50 //random(Stage.height - 200);  
		}
	
	public function vertical() {
		if (this.dir == 0) {
			if ((this._y < Stage.height)) {
				_y += this.speed;
			} else {
				 _y = -50;
			}
		} else {
			if ((this._y >0)) {
				_y -= this.speed;
			} else {
				_y = 250;
			}
		}
	}

	public function hortical(){
		if (this.dir == 0) {
			if (this._x < Stage.width) {
				_x += speed;
			} else {
				_x = -50;
			}
		} else {
			if (this._x > 0) {
				_x -= speed;
			} else {
				_x = Stage.width;
			}
		}
	}
	
	public function dirchanger(){
		if(this.dir == 0){
			this.dir = 1;
		}else{
			this.dir = 0;
		}
		this.speed = 1 + Math.round(Math.random()*8);
	}
	
	public function setShadow(i:Number){		
		var tmpname:String;
		tmpname = "mi24"+ i + "_mc"; 
		this.mynum = i;
		_root[tmpname].writeFilter('Bevel'); // add a blur with default settings.
		_root[tmpname].DropShadow_distance = 15; // adds a dropshadow & set distance
		_root[tmpname].DropShadow_alpha = .1; // filter alphas are 0-1 multipliers
		}
		
	public function attack(){
		this.bulletname = "bull" + this.mynum + this.bulletnum +"_mc";
		this.bulletbelt[bulletnum] = akbullet(_root.attachMovie("akbullet",this.bulletname,_root.getNextHighestDepth()));
		this.bulletbelt[bulletnum].setMyName(this.bulletname);
		this.bulletbelt[bulletnum].setPos(this._x,this._y);
		_root.aksound.playbang();
		this.bulletnum++;
		}
}