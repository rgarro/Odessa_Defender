import com.tylerault.utils.CallbackObject;

/***
 * Creates a basic but customizeable button out of a MovieClip;
 *
 * @author Tyler Ault [tault@digitas.com]
 ***/
class com.tylerault.gui.CustomButton
{
	private var buttonClip_mc:MovieClip;

	// callbacks for states
	private var pressCallback:CallbackObject;
	private var releaseCallback:CallbackObject;
	private var rollOverCallback:CallbackObject;
	private var rollOutCallback:CallbackObject;

	// the following is so that subclasses can easeily
	// make more complex buttons:
	private var downFrame:String;
	private var overFrame:String;
	private var upFrame:String;

	/***
	 * Constructor: creates an object that controls the MovieClip as a button
	 * @param newButtonClip_mc the MovieClip to funciton as a button
	 * @param thisObject the object-scope in which the method should run
	 *        ( will be 'this' within the method )
	 * @param releaseMethod the method to run on release (see below for other onEvents)
	 * @param releaseParameters an array of parameters to pass when releaseMethod is called
	 ***/
	function CustomButton( newButtonClip_mc:MovieClip,
		thisObject:Object,
		releaseMethod:Function,
		releaseParameters:Array )
	{
		setButtonClip( newButtonClip_mc );

		if( releaseMethod != undefined )
		{
			this.releaseCallback = new CallbackObject(
				thisObject, releaseMethod, releaseParameters );
		}

		this.downFrame = "down";
		this.overFrame = "over";
		this.upFrame = "up";
	}

	public function doRollOver() : Void
	{
		this.buttonClip_mc.gotoAndPlay( this.overFrame );
		this.rollOverCallback.run();
	}

	public function doRollOut() : Void
	{
		this.buttonClip_mc.gotoAndPlay( this.upFrame );
		this.rollOutCallback.run();
	}

	public function doPress() : Void
	{
		this.buttonClip_mc.gotoAndPlay( this.downFrame );
		this.pressCallback.run();
	}

	public function doRelease() : Void
	{
		this.buttonClip_mc.gotoAndPlay( this.overFrame );
		this.releaseCallback.run();
	}

	/***
	 * Enable / Disable the button
	 ***/
	public function enable() : Void
	{
		this.buttonClip_mc.gotoAndPlay( this.upFrame );
		this.buttonClip_mc.enabled = true;
	}

	public function disable() : Void
	{
		this.buttonClip_mc.gotoAndPlay( "disabled" );
		this.buttonClip_mc.enabled = false;
	}


	/////////////////////
	// GETTERS / SETTERS
	public function setButtonClip( newClip_mc:MovieClip ) : Void
	{
		this.buttonClip_mc = newClip_mc;

		var cb:CustomButton = this;
		newClip_mc.onRollOver = function() { cb.doRollOver.apply( cb ); }
		newClip_mc.onRollOut = function() { cb.doRollOut.apply( cb ); }
		newClip_mc.onPress = function() { cb.doPress.apply( cb ); }
		newClip_mc.onRelease = function() { cb.doRelease.apply( cb ); }
	}

	public function setPressCallback( newCallback:CallbackObject ) : Void
	{
		this.pressCallback = newCallback;
	}

	public function setReleaseCallback( newCallback:CallbackObject ) : Void
	{
		this.releaseCallback = newCallback;
	}
	
	public function setRollOverCallback( newCallback:CallbackObject ) : Void
	{
		this.rollOverCallback = newCallback;
	}
	
	public function setRollOutCallback( newCallback:CallbackObject ) : Void
	{
		this.rollOutCallback = newCallback;
	}
	
}

