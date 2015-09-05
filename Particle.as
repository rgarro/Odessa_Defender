class Particle extends MovieClip{
	public var vx,vy;
	public var timeToLast,startTimer;
	public var myColor,rgbValue;
	
	public function onLoad(){
		var angle = Math.random()*360;
		vx = Math.cos(angle)*Math.random()*20+5;
		vy = Math.sin(angle)*Math.random()*20+5;
		timeToLast = Math.random()*500 + 1000;
		startTimer = getTimer();
		myColor = new Color(this);
		myColor.setRGB(rgbValue);
	}
	
	public function onEnterFrame(){
		this._x += vx;
		this._y += vy;
		this._alpha -=2;
		if(getTimer() - startTimer >= timeToLast || this._alpha == 0){
			removeMovieClip(this);
		}
	}
}