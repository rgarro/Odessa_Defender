import com.avVenta.events.*;
import com.avVenta.debug.*;
import com.avVenta.view360.*;
import com.avVenta.watchdog.*;

import flash.geom.ColorTransform;

/**
 * This class controls and animates a 360 degrees viewer control.
 *
 * @author Marco A. Alvarado
 * @version 1.0.2 2007-04-24
 */
class com.avVenta.view360.Viewer360 implements IBroadcastable {
	
//==================================================
// Constants

	static private var DEBUG 							= true;
	static public var ROTATE_EVENT 				= "onRotate";
	static public var FADEIN_EVENT 				= "onFadeIn";
	static public var FADEOUT_EVENT 			= "onFadeOut";
	static public var LEFT_EVENT					= "onLeft";
	static public var RIGHT_EVENT					= "onRight";
	static public var SPIN_EVENT					= "onSpin";
	static public var GRAB_EVENT					= "onGrab";
	static public var TRACKING_EVENT			= "onTracking";
	
//==================================================
// Variables

	private var broadcaster:EventBroadcaster;
	private var debugger:DebugController;
	
	private var rotation:Number 					= 0;		// degrees
	private var rotationOffset:Number			= 0;		// degrees
	private var rotationVelocity:Number 	= 1;		// degrees/interval (>= 0)
	private var rotationDirection:Number 	= 1;		// sign: -1 or +1 only
	private var rotationStep:Number 			= 0;		// < 0: left, 0: stop, > 0: right
	private var invertedRotation:Boolean	= false;

	private var framePosition:Number 			= 0;		// zero based
	private var frameCount:Number 				= 0;		// >= 0
	
	private var turning:Boolean 					= false;
	private var turningTarget:Number			= 0;		// degrees

	private var grabbing:Boolean 						= false;
	private var grabbingRotation:Number 		= 0;
	private var grabbingStart:Number 				= 0;
	private var grabbingPosition:Number 		= 0;
	private var grabbingLast:Number 				= 0;
	private var grabbingWidth:Number 				= 0;
	private var grabbingFullTurns:Number 		= 1;
	private var grabbingEnabled:Boolean			= true;
	private var grabbingLockCount:Number		= 0;
	private var grabbingInactive:Number			= 0;	// milliseconds (<= 0 disable), disable grabbing after given time of inactivity
	private var grabbingInactiveTime:Number = 0;
	
	private var spinning:Boolean 					= false;
	private var spinningDelta:Number;
	private var spinningStart:Number;
	private var spinningTime:Number				= 1000;	// milliseconds
	
	private var interval:Number 					= 0;
	
	private var backgroundArea:MovieClip;
	private var arrowLeft:MovieClip;
	private var arrowRight:MovieClip;
	private var grabArea:MovieClip;
	private var spinWheel:MovieClip;
	private var labelLeft:MovieClip;
	private var labelCenter:MovieClip;
	private var labelRight:MovieClip;
	private var ringWrapper:MovieClip;
	private var grabCursor:MovieClip;
	private var arrowLeftColor:Number;
	private var arrowRightColor:Number;
	private var arrowLeftHighlight:Number;
	private var arrowRightHighlight:Number;
	private var spinWheelColor:Number;
	private var spinWheelHighlight:Number;
	private var spinWheelFade:Number 				= 10;
	private var spinWheelSlices:Number			= 0;	// >= 0
	private var spinWheelSlicePrefix:String	= "slice";
	
	private var labelLeftState:Boolean		= false;
	private var labelRightState:Boolean		= false;
	private var ringState:Boolean					= false;
	
	private var boundingBoxes:Array;
	
	public var name:String;
	
//==================================================
// Generic methods

	/**
	 * Constructor.
	 */
	public function Viewer360() {
		broadcaster = new EventBroadcaster();
		debugger = DebugController.getInstance();
		boundingBoxes = new Array();
		name = "Viewer360";
	}

//==================================================
// Setup and remove methods

	/**
	 *
	 */
	public function setFrameCount(frameCount:Number, spinWheelSlices:Number) {
		this.frameCount = frameCount;
		this.spinWheelSlices = spinWheelSlices;
		framePosition = calculateFramePosition((rotation+rotationOffset), frameCount);
	}
	
	/**
	 *
	 */
	public function setMovies(backgroundArea:MovieClip, arrowLeft:MovieClip, arrowRight:MovieClip, 
		grabArea:MovieClip, labelLeft:MovieClip, labelCenter:MovieClip, labelRight:MovieClip, spinWheel:MovieClip, 
		ringWrapper:MovieClip, grabCursor:MovieClip) {
		this.backgroundArea = backgroundArea;
		this.arrowLeft = arrowLeft;
		this.arrowRight = arrowRight;
		this.grabArea = grabArea;
		this.spinWheel = spinWheel;
		this.labelLeft = labelLeft;
		this.labelCenter = labelCenter;
		this.labelRight = labelRight;
		this.ringWrapper = ringWrapper;
		this.grabCursor = grabCursor;
		grabCursor._visible = false;
		grabCursor.gotoAndStop(1);
		arrowLeft._v360 = this;
		arrowRight._v360 = this;
		grabArea._v360 = this;
		spinWheel._v360 = this;
		grabCursor._v360 = this;
		arrowRight.active = true;
		arrowLeft.active = true;
		grabArea.active = true;
		spinWheel.active = true;
		Watchdog.watch(grabArea, function() {trace("Viewer360: RUFF!!! RUFF!!!"); Mouse.show();});

		arrowLeft.onRollOver = function() {
			this._v360.colorLeftArrow(true);
		}
		
		arrowLeft.onRollOut = function() {
			this._v360.colorLeftArrow(false);
		}
		
		arrowLeft.onPress = function() {
			this._v360.broadcastEvent(TRACKING_EVENT, this, null);
			this._v360.broadcastEvent(LEFT_EVENT, this, null);
			if (this.active) this._v360.spin(+1);
		}
		
		arrowRight.onRollOver = function() {
			this._v360.colorRightArrow(true);
		}
		
		arrowRight.onRollOut = function() {
			this._v360.colorRightArrow(false);
		}
		
		arrowRight.onPress = function() {
			this._v360.broadcastEvent(TRACKING_EVENT, this, null);
			this._v360.broadcastEvent(RIGHT_EVENT, this, null);
			if (this.active) this._v360.spin(-1);
		}
		
		arrowLeft.onRelease = arrowLeft.onReleaseOutside = function() {
			if (this.active) this._v360.spin(0);
		}

		arrowRight.onRelease = arrowRight.onReleaseOutside = function() {
			if (this.active) this._v360.spin(0);
		}
		
		grabArea.onPress = function() {
			this._v360.broadcastEvent(TRACKING_EVENT, this, null);
			this._v360.broadcastEvent(GRAB_EVENT, this, null);
			
			if (this.active && this._v360.canGrab())
			{
				this.lastX = this._xmouse;
				this._v360.grab(this._xmouse, grabArea._width*100/grabArea._xscale);
	
				this.onEnterFrame = function()
				{
					this.lastX = this._xmouse;
					this._v360.updateGrab(this._xmouse);
				}
			}
		}

		grabArea.onRelease = grabArea.onReleaseOutside = function() {

			if (this.active && this._v360.isGrabbing())
			{
				delete this.onEnterFrame;
				this._v360.cancelGrab();
				var speed:Number = this._xmouse-this.lastX;
				if (Math.abs(speed) > 0) this._v360.spinInertia(speed);
			}
		}

		spinWheel.onPress = function() {
			this._v360.broadcastEvent(TRACKING_EVENT, this, null);
			this._v360.broadcastEvent(SPIN_EVENT, this, null);
			
			if (this.active)
			{
				this._v360.cancelAll();
				var angle:Number = calculateAngle(this._xmouse-this._width/2, this._ymouse-this._height/2);
				
				if (angle != this.angle)
				{
					this.angle = angle;
					this._v360.turn(angle);
				}
	
				spinWheel.onEnterFrame = function() {
					var angle:Number = calculateAngle(this._xmouse-this._width/2, this._ymouse-this._height/2);
					
					if (angle != this.angle)
					{
						this.angle = angle;
						this._v360.turn(angle);
					}
				}
			}
		}
		
		spinWheel.onRelease = spinWheel.onReleaseOutside = function() {

			if (this.active)
			{
				delete this.onEnterFrame;
			}
		}
		
		grabCursor.onEnterFrame = function() {
			if (this._v360.canGrab() && this._v360.isGrabInactive() && this._visible) {
				this._visible = false;
				Mouse.show();
			}
		}

		_root._v360 = this;

		_root.onMouseMove = function() {
			this._v360.updateCursor();
		}
		
		broadcaster.broadcastEvent(FADEOUT_EVENT, this, {movie:labelRight});
		broadcaster.broadcastEvent(FADEOUT_EVENT, this, {movie:labelLeft});
		broadcaster.broadcastEvent(FADEOUT_EVENT, this, {movie:ringWrapper});
	}

	/**
	 *
	 */
	public function removeMovies() {
		delete arrowLeft.onPress;
		delete arrowRight.onPress;
		delete arrowLeft.onRelease;
		delete arrowRight.onRelease;
		delete grabArea.onPress;
		delete grabArea.onEnterFrame
		delete grabArea.onRelease;
		delete grabArea.onReleaseOutside;
		delete spinWheel.onPress;
		delete spinWheel.onEnterFrame;
		delete spinWheel.onRelease;
		delete spinWheel.onReleaseOutside;
		delete _root._v360;
		delete _root.onMouseMove;

		this.backgroundArea = null;
		this.arrowLeft = null;
		this.arrowRight = null;
		this.grabArea = null;
		this.spinWheel = null;
		this.labelLeft = null;
		this.labelCenter = null;
		this.labelRight = null;
		this.ringWrapper = null;
		this.grabCursor = null;
	}
	
	/**
	 *
	 */
	public function setMoviesColor(backgroundAreaColor:Number, arrowLeftColor:Number, arrowLeftHighlight:Number, 
		arrowRightColor:Number, arrowRightHighlight:Number, textColor:Number, spinWheelColor:Number, 
		spinWheelHighlight:Number, spinWheelFade:Number) {
		this.arrowLeftColor = arrowLeftColor; 
		this.arrowRightColor = arrowRightColor;
		this.arrowLeftHighlight = arrowLeftHighlight;
		this.arrowRightHighlight = arrowRightHighlight;
		this.spinWheelColor = spinWheelColor;
		this.spinWheelHighlight = spinWheelHighlight;
		this.spinWheelFade = spinWheelFade;
		colorMovie(backgroundArea, backgroundAreaColor); 
		colorLeftArrow(false);
		colorRightArrow(false);
		colorMovie(labelLeft, textColor);
		colorMovie(labelCenter, textColor);
		colorMovie(labelRight, textColor);
		for (var i: Number = 0; i < spinWheelSlices; i++) 
			colorMovie(spinWheel[spinWheelSlicePrefix+i], spinWheelColor);
	}
	
	/**
	 *
	 */
	public function setMoviesVisibility(arrowLeftVisible:Boolean, arrowRightVisible:Boolean, spinWheelVisible:Boolean) {
		arrowLeft._visible = arrowLeftVisible; 
		arrowRight._visible = arrowRightVisible; 
		spinWheel._visible = spinWheelVisible;
		labelLeft._visible = arrowLeftVisible; 
		labelRight._visible = arrowRightVisible; 
		labelCenter._visible = spinWheelVisible;
	}

	/**
	 *
	 */
	public function setMovieActivity(arrowLeftActive:Boolean, arrowRightActive:Boolean, grabAreaActive:Boolean, spinWheelActive:Boolean) {
		arrowLeft.active = arrowLeftActive; 
		arrowRight.active = arrowRightActive; 
		grabArea.active = grabAreaActive;
		spinWheel.active = spinWheelActive;
	}
	
	/**
	 *
	 */
	public function setLoaderFormat(font:String, size:Number) {
		var format:TextFormat = labelCenter.tf.getTextFormat();
		format.font = font;
		format.size = size;
		labelLeft.tf.setTextFormat(format);
		labelLeft.tf.autoSize = true;
		labelCenter.tf.setTextFormat(format);
		labelCenter.tf.autoSize = true;
		labelRight.tf.setTextFormat(format);
		labelRight.tf.autoSize = true;
	}
	
	/**
	 *
	 */
	public function positionBackgroundArea(X:Number, Y:Number, Width:Number, Height:Number) {
		backgroundArea._x = X;
		backgroundArea._y = Y;
		backgroundArea._width = Width;
		backgroundArea._height = Height;
	}
	
	/**
	 *
	 */
	public function positionGrabArea(X:Number, Y:Number, Width:Number, Height:Number) {
		grabArea._x = X;
		grabArea._y = Y;
		grabArea._width = Width;
		grabArea._height = Height;
	}
	
	/**
	 *
	 */
	public function setRotation(rotation:Number, rotationOffset:Number) {
		this.rotation = normalizeAngle(rotation, 360);
		if (rotationOffset != undefined) this.rotationOffset = rotationOffset;
		framePosition = calculateFramePosition((rotation+rotationOffset), frameCount);
	}
	
	/**
	 *
	 */
	public function setRotationMovement(rotationVelocity:Number, rotationDirection:Number) {
		this.rotationVelocity = rotationVelocity;
		this.rotationDirection = rotationDirection;
	}

	/**
	 *
	 */
	public function invertRotation() {
		invertedRotation = !invertedRotation;
	}
	
	/**
	 *
	 */
	public function setRotationGrabbing(grabbingFullTurns:Number) {
		this.grabbingFullTurns = grabbingFullTurns;
	}

	/**
	 *
	 */
	public function enableGrabbing(countLocks:Boolean):Void {
		
		if (countLocks == true) {
			grabbingLockCount--;
			
			if (grabbingLockCount <= 0) {
				grabbingLockCount = 0;
				grabbingEnabled = true;
			}
			
trace("View360: grabbingLockCount = "+grabbingLockCount);
		} else {
			grabbingEnabled = true; 
		}
		
		updateCursor();
	}

	/**
	 *
	 */
	public function disableGrabbing(countLocks:Boolean):Void {
		
		if (countLocks == true) {
			grabbingLockCount++;
trace("View360: grabbingLockCount = "+grabbingLockCount);
		}
		
		grabbingEnabled = false; 
		
		updateCursor();
	}
	
	/**
	 *
	 */
	public function addBoundingBox(bb:BoundingBox) {
		boundingBoxes.push(bb);
	}
	
	/**
	 *
	 */
	public function setGrabbingInactive(ms:Number) {
		grabbingInactive = ms;
	}
	
//==================================================
// Retriving methods

	/**
	 *
	 */
	public function getRotation():Number {
		return rotation;
	}
	
	/**
	 *
	 */
	public function getFramePosition():Number {
		if (!invertedRotation)
			return framePosition; else
			return frameCount-framePosition;
	}
	
	/**
	 *
	 */
	public function getFrameAngle(frame:Number):Number {
		return Math.floor(normalizeAngle((frame*360/frameCount)-rotationOffset, 360));
	}
	 
	/**
	 *
	 */
	public function isGrabbing():Boolean {
		return grabbing;
	}

//==================================================
// Grabbing logic control

	/**
	 *
	 */
	public function isMouseColliding():Boolean {
		for (var i:Number = 0; i < boundingBoxes.length; i++)
			if (boundingBoxes[i].isMouseInside()) return true;
		return false;
	}
	
	/**
	 *
	 */
	public function isGrabInactive():Boolean {
		return (grabbingInactive > 0) && ((new Date()).getTime() >= grabbingInactiveTime);
	}
	
	/**
	 *
	 */
	public function canGrab():Boolean {
		return grabbingEnabled && !isMouseColliding();
	}

//==================================================
// Behavior control methods

	/**
	 *
	 */
	public function spin(rotationStep:Number) {
		cancelAll();
		this.rotationStep = rotationStep;
	}

	/**
	 *
	 */
	function turn(toAngle:Number) {
		turning = true;
		rotationStep = 1;
		turningTarget = toAngle;
	}
	 
	/**
	 *
	 */
	public function cancelTurn() {
		turning = false;
		rotationStep = 0;
	}
	
	/**
	 *
	 */
	public function grab(startPosition:Number, width:Number) {
		cancelAll();
		grabbing = true;
		grabbingRotation = rotation;
		grabbingStart = startPosition;
		grabbingPosition = startPosition;
		grabbingLast = startPosition;
		grabbingWidth = width;
		grabCursor.gotoAndStop(2);
	}

	/**
	 *
	 */
	public function updateGrab(position:Number) {
		grabbingPosition = position;
	}

	/**
	 *
	 */
	public function cancelGrab() {
		grabbing = false;
		grabCursor.gotoAndStop(1);
	}
	
	/**
	 *
	 */
	public function spinInertia(distance:Number) {
		cancelAll();
		spinning = true;
		spinningDelta = distance*(180*grabbingFullTurns)/grabbingWidth;
		spinningStart = getMillisecs();
	}

	/**
	 *
	 */
	public function cancelSpinInertia() {
		spinning = false;
	}

	/**
	 *
	 */
	public function cancelAll() {
		cancelTurn();
		cancelGrab();
		cancelSpinInertia();
	}
	
	/**
	 *
	 */
	public function updateCursor() 
	{
		if (grabbingInactive > 0) grabbingInactiveTime = (new Date()).getTime()+grabbingInactive;
		
		if (isMouseOver(grabArea) && canGrab())
		{
			if (!grabCursor._visible)
			{
				Mouse.hide();
				grabCursor._visible = true;
				broadcaster.broadcastEvent(FADEIN_EVENT, this, {movie:ringWrapper});
			}

			grabCursor._x = grabCursor._parent._xmouse;
			grabCursor._y = grabCursor._parent._ymouse;
		} else
		{
			if (grabCursor._visible)
			{
				Mouse.show();
				grabCursor._visible = false;
				broadcaster.broadcastEvent(FADEOUT_EVENT, this, {movie:ringWrapper});
			}
		}
	}
	
//==================================================
// Animation methods

	/**
	 *
	 */
	public function animate() {
// show labels:
		var state:Boolean = isMouseOver(spinWheel) || isMouseOver(arrowRight);
		
		if (labelRightState != state) 
		{
			labelRightState = state;
			if (state)
				broadcaster.broadcastEvent(FADEIN_EVENT, this, {movie:labelRight}); else
				broadcaster.broadcastEvent(FADEOUT_EVENT, this, {movie:labelRight});
		}
		
		var state:Boolean = isMouseOver(spinWheel) || isMouseOver(arrowLeft);
		
		if (labelLeftState != state) 
		{
			labelLeftState = state;
			if (state)
				broadcaster.broadcastEvent(FADEIN_EVENT, this, {movie:labelLeft}); else
				broadcaster.broadcastEvent(FADEOUT_EVENT, this, {movie:labelLeft});
		}

		var state:Boolean = labelRightState || labelLeftState;
		
		if (ringState != state) 
		{
			ringState = state;
			if (state)
				broadcaster.broadcastEvent(FADEIN_EVENT, this, {movie:ringWrapper}); else
				broadcaster.broadcastEvent(FADEOUT_EVENT, this, {movie:ringWrapper});
		}
		
// color spinwheel:
		for (var i: Number = 0; i < spinWheelSlices; i++) {
			var spin:MovieClip = spinWheel[spinWheelSlicePrefix+i];
			
			if (spin.intensity > 0) {
				spin.intensity -= spinWheelFade;
				colorMovie(spin, blendColor(spinWheelColor, spinWheelHighlight, spin.intensity));
			}
		}
		
// do rotation:
		var delta:Number = 0;
		var step:Number = rotationStep;

		if (grabbing)
		{
// manual rotation:
			if (grabbingLast <> grabbingPosition)
			{
				delta = (grabbingStart-grabbingPosition)*(360*grabbingFullTurns)/grabbingWidth;
				rotation = normalizeAngle(grabbingRotation+delta, 360);
				grabbingLast = grabbingPosition;
			}
		} else
		if (spinning)
		{				
				if (spinningStart+spinningTime <= getMillisecs())
				{
						spinningDelta /= 1.2;
						if (Math.abs(spinningDelta) < 1) cancelSpinInertia();
				}
				
				delta = spinningDelta;
				rotation = normalizeAngle(rotation-delta, 360);
		} else
		if (turning)
		{
// automatic rotation:
			delta = rotationVelocity*rotationStep;

			rotation = followAngle(rotation, turningTarget, Math.abs(delta));

			if (rotation == turningTarget)
			{
				turning = false;
				turningTarget = 0;
				rotationStep = 0;
			}
		} else
		{
			delta = rotationVelocity*rotationStep;
			rotation = normalizeAngle(rotation+delta);
		}
		
// solve current frame:
		framePosition = calculateFramePosition((rotation+rotationOffset), frameCount);

// highlight visited position in the spinwheel:
		if (delta != 0)
		{
			var spin:MovieClip = spinWheel[spinWheelSlicePrefix+calculateFramePosition(rotation, spinWheelSlices)];
			spin.intensity = 100;

// trigger the event:
			broadcaster.broadcastEvent(ROTATE_EVENT, this, {frame: getFramePosition()});
		}
	}
	
	/**
	 *
	 */
	public function startAnimation(framesPerSecond:Number) {
		if (interval == 0) interval = setInterval(this, "animate", Math.floor(1000/framesPerSecond));
	}

	/**
	 *
	 */
	public function stopAnimation() {
		if (interval != 0) clearInterval(interval);
		interval = 0;
	}

	/**
	 *
	 */
	public function colorLeftArrow(highlight:Boolean) {
		if (highlight)
			colorMovie(arrowLeft, arrowLeftHighlight); else 
			colorMovie(arrowLeft, arrowLeftColor); 
	}

	/**
	 *
	 */
	public function colorRightArrow(highlight:Boolean) {
		if (highlight)
			colorMovie(arrowRight, arrowRightHighlight); else 
			colorMovie(arrowRight, arrowRightColor); 
	}
	
//==================================================
// Event methods

	/**
	 *
	 */
	public function addEventListener(eventName:String, listener:Object, methodName:String):Void {
		broadcaster.addEventListener(eventName,listener,methodName);
	}

	/**
	 *
	 */
	public function broadcastEvent(eventName:String, data:Object):Void {
		broadcaster.broadcastEvent(eventName,this,data);
	}

	/**
	 *
	 */
	public function removeEventListener(eventName:String, listener:Object, methodName:String):Void {
		broadcaster.removeEventListener(eventName,listener,methodName);
	}

//==================================================
// Static utility methods

	/**
	 *
	 */
	static public function normalizeAngle(angle:Number, totalDegrees:Number)
	{
		if (totalDegrees == undefined) totalDegrees = 360;
		return angle >= 0 ? angle%totalDegrees : totalDegrees+angle%totalDegrees;
	}
	
	/**
	 *
	 */
	static public function calculateAngle(x:Number, y:Number):Number {
		var angle:Number = Math.atan(y/x)/(Math.PI/180);
    if (x < 0) {
        angle += 180;
    }
    if (x >= 0 && y < 0) {
        angle += 360;
    }
		return normalizeAngle(angle+90);
	}
		
	/**
	 *
	 */
	static public function calculateFramePosition(angle:Number, frameCount:Number):Number {
		return Math.floor(normalizeAngle(angle*frameCount/360, frameCount));
	}
	
	/**
	 *
	 */
	static public function calculateAngleFromFrame(frame:Number, frameCount:Number):Number {
		return Math.floor(normalizeAngle(frame*360/frameCount, frameCount));
	}
	
	/**
	 *
	 */
	static public function calculateSlices(angle:Number, totalSlices:Number, totalDegrees:Number)
	{
		if (totalDegrees == undefined) totalDegrees = 360;
		return angle*totalSlices/totalDegrees;
	}
	
	/**
	 *
	 */
	static public function substractAngles(angle1:Number, angle2:Number):Array {
		angle1 = 360+normalizeAngle(angle1);
		angle2 = 360+normalizeAngle(angle2);
		return [normalizeAngle(angle1-angle2), normalizeAngle(angle2-angle1)];
	}
	
	/**
	 *
	 */
	static public function followAngle(
		angle1: Number,		// origin
		angle2: Number,   // target
		delta: Number			// > 0
		): Number
	{
		var deltas: Array = substractAngles(angle1, angle2);
	
		if (deltas[0] < deltas[1])
		{
			if (deltas[0] > delta)
				angle1 -= delta; else
				angle1 = angle2;
		} else
		{
			if (deltas[1] > delta)
				angle1 += delta; else
				angle1 = angle2;
		}
		
		return angle1;
	}
	
	/**
	 *
	 */
	static public function getHTMLColor(color:String):Number {
		return Number("0x"+substring(color, 2, 7));
	}
	
	/**
	 *
	 */
	static public function colorMovie(mc:MovieClip, color:Number) {
		var trans: ColorTransform = new ColorTransform();
		
		trans.redMultiplier = 0;
		trans.greenMultiplier = 0;
		trans.blueMultiplier = 0;
		trans.redOffset = (color & 0xFF0000) >> 16;
		trans.greenOffset = (color & 0x00FF00) >> 8;
		trans.blueOffset = (color & 0x0000FF);
		mc.transform.colorTransform = trans;
	}
	
	/**
	 *
	 */
	static public function blendColor(colorA:Number, colorB:Number, percent:Number):Number {
		var rA:Number = (colorA & 0xFF0000) >> 16;
		var gA:Number = (colorA & 0x00FF00) >> 8;
		var bA:Number = (colorA & 0x0000FF);
		var rB:Number = (colorB & 0xFF0000) >> 16;
		var gB:Number = (colorB & 0x00FF00) >> 8;
		var bB:Number = (colorB & 0x0000FF);
		var rI:Number = rA+Math.floor((rB-rA)*percent/100);
		var gI:Number = gA+Math.floor((gB-gA)*percent/100);
		var bI:Number = bA+Math.floor((bB-bA)*percent/100);
		return (rI << 16) | (gI << 8) | bI;
	}

	/**
	 *
	 */
	static public function isMouseOver(mc:MovieClip):Boolean {
		return (
			(mc._xmouse >= 0) && 
			(mc._ymouse >= 0) && 
			(mc._xmouse < mc._width*100/mc._xscale) && 
			(mc._ymouse < mc._height*100/mc._yscale));
	}
	
	/**
	 *
	 */
	static public function getMillisecs():Number {
		return (new Date()).getTime();
	}
}