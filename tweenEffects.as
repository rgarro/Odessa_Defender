class tweenEffects {
	private var time:Number;
	private var easeType;
	private var secOrFrame;
	private var functionToCall;
	private var param;
	private var type;
	private var temp;
	private var current_mc;
	//-----------------------------------
	public function tweenEffects(){
		//default values
		this.time=.5;
		this.easeType=mx.transitions.easing.Regular.easeOut;
		this.secOrFrame=true;
	}
	//--------function used to all effects-------------
	private function tween(_mc, easeType, type, begin, end, time, bool, mcf, functionToCall, param) {
		var myTween;
		myTween = new mx.transitions.Tween(_mc, type, easeType, begin, end, time, bool);
		myTween.functionToCall = functionToCall;
		myTween.param = param;
		myTween.mcf = mcf;
		myTween.onMotionFinished = function() {
			this.mcf[functionToCall](this.param);
		};
	}
	//----------------------------------------
	function fadeIn(_mc:MovieClip,currentAlpha:Boolean,mcf:MovieClip,functionName:String,functionParam:Object){
		var iAlpha=(currentAlpha)?_mc._alpha:0;
		tween(_mc,this.easeType,"_alpha",iAlpha,100,this.time,this.secOrFrame,mcf,functionName,functionParam);
	}
	//----------------------------------------
	function fadeOut(_mc:MovieClip,currentAlpha:Boolean,mcf:MovieClip,functionName:String,functionParam:Object){
		var iAlpha=(currentAlpha)?_mc._alpha:100;
		tween(_mc,this.easeType,"_alpha",iAlpha,0,this.time,this.secOrFrame,mcf,functionName,functionParam);
	}
	//----------------------------------------
	function fadeTo(_mc:MovieClip,alpha:Number,mcf:MovieClip,functionName:String,functionParam:Object){
		var iAlpha=_mc._alpha;
		tween(_mc,this.easeType,"_alpha",iAlpha,alpha,this.time,this.secOrFrame,mcf,functionName,functionParam);
	}
	//----------------------------------------
	function gotoX(_mc:MovieClip,xf:Number,mcf:MovieClip,functionName:String,functionParam:Object){
		tween(_mc,this.easeType,"_x",_mc._x,xf,this.time,this.secOrFrame,mcf,functionName,functionParam);
	}
	//----------------------------------------
	function gotoY(_mc:MovieClip,yf:Number,mcf:MovieClip,functionName:String,functionParam:Object){
		tween(_mc,this.easeType,"_y",_mc._y,yf,this.time,this.secOrFrame,mcf,functionName,functionParam);
	}
	//----------------------------------------
	function gotoXY(_mc:MovieClip,xf,yf:Number,mcf:MovieClip,functionName:String,functionParam:Object){
		tween(_mc,this.easeType,"_x",_mc._x,xf,this.time,this.secOrFrame);
		tween(_mc,this.easeType,"_y",_mc._y,yf,this.time,this.secOrFrame,mcf,functionName,functionParam);
	}
	//----------------------------------------
	function changeWidth(_mc:MovieClip,w:Number,mcf:MovieClip,functionName:String,functionParam:Object){
		tween(_mc,this.easeType,"_width",_mc._width,w,this.time,this.secOrFrame,mcf,functionName,functionParam);
	}
	//----------------------------------------
	function changeHeight(_mc:MovieClip,h:Number,mcf:MovieClip,functionName:String,functionParam:Object){
		tween(_mc,this.easeType,"_height",_mc._height,h,this.time,this.secOrFrame,mcf,functionName,functionParam);
	}
	//----------------------------------------
	function changeWH(_mc:MovieClip,w:Number,h:Number,mcf:MovieClip,functionName:String,functionParam:Object){
		tween(_mc,this.easeType,"_width",_mc._width,w,this.time,this.secOrFrame);
		tween(_mc,this.easeType,"_height",_mc._height,h,this.time,this.secOrFrame,mcf,functionName,functionParam);
	}
	//----------------------------------------
	function changeXscale(_mc:MovieClip,xs:Number,mcf:MovieClip,functionName:String,functionParam:Object){
		tween(_mc,this.easeType,"_xscale",_mc._xscale,xs,this.time,this.secOrFrame,mcf,functionName,functionParam);
	}
	//----------------------------------------
	function changeYscale(_mc:MovieClip,ys:Number,mcf:MovieClip,functionName:String,functionParam:Object){
		tween(_mc,this.easeType,"_yscale",_mc._yscale,ys,this.time,this.secOrFrame,mcf,functionName,functionParam);
	}
	//----------------------------------------
	function changeXYscale(_mc:MovieClip,xs:Number,ys:Number,mcf:MovieClip,functionName:String,functionParam:Object){
		tween(_mc,this.easeType,"_xscale",_mc._xscale,xs,this.time,this.secOrFrame);
		tween(_mc,this.easeType,"_yscale",_mc._yscale,ys,this.time,this.secOrFrame,mcf,functionName,functionParam);
	}
	//----------------------------------------
	function changeRotation(_mc:MovieClip,rot:Number,mcf:MovieClip,functionName:String,functionParam:Object){
		tween(_mc,this.easeType,"_rotation",_mc._rotation,rot,this.time,this.secOrFrame,mcf,functionName,functionParam);
	}
	//----------------------------------------
	function setTimex(val){
		this.time=val;
	}
	function setEaseType(value){
		/*
			value can be one of this (usually used)
			mx.transitions.easing.Regular.easeOut|easeIn|easeInOut
			mx.transitions.easing.Strong.easeOut|easeIn|easeInOut
			mx.transitions.easing.Elastic.easeOut|easeIn|easeInOut
			mx.transitions.easing.Bounce.easeOut|easeIn|easeInOut
			please refer to 
			
			for more information
		*/
		this.easeType=value;
	}
	function getTime(){
		return this.time;
	}
	function getEaseType(){
		return this.easeType;
	}
}
