import com.tylerault.gui.CustomButton;
import com.tylerault.utils.CallbackObject;

/***
 * Creates a binary toggle button that will
 * toggle between states as it is released
 * @see CustomButton
 *
 * @author Tyler Ault [tault@digitas.com]
 ***/
class com.tylerault.gui.ToggleButton extends com.tylerault.gui.CustomButton
{
	private var state:Number;

	private var baseDownFrame:String;
	private var baseOverFrame:String;
	private var baseUpFrame:String;

	function ToggleButton( newButtonClip_mc:MovieClip,
		thisObject:Object,
		releaseMethod:Function,
		releaseParameters:Array,
		startState:Number )
	{
		super( newButtonClip_mc, thisObject,
			releaseMethod, releaseParameters );

		this.baseDownFrame = this.downFrame;
		this.baseOverFrame = this.overFrame;
		this.baseUpFrame = this.upFrame;

		startState = ( startState == undefined ) ? 0 : startState;
		this.setState( startState );
	}

	/***
	 * Overrides the superclass function to toggle state
	 * don't call super here; goToAndPlays will conflict
	 ***/
	public function doRelease() : Void
	{
		toggleState();
		this.releaseCallback.run();
	}

	private function toggleState()
	{
		var newState:Number = ( this.state == 0 ) ? 1 : 0;
		setState( newState );
	}

	/////////////////////
	// GETTERS / SETTERS
	public function setState( value:Number ) : Void
	{
		if( this.state != value )
		{
			this.state = value;
			this.downFrame = this.baseDownFrame + this.state.toString();
			this.overFrame = this.baseOverFrame + this.state.toString();
			this.upFrame = this.baseUpFrame + this.state.toString();
			 
			// test for mouse location; display up or over
			if( this.buttonClip_mc.hitTest( _root._xmouse, _root._ymouse, true ) )
			{
				this.buttonClip_mc.gotoAndPlay( this.overFrame );
			}
			else
			{
				this.buttonClip_mc.gotoAndPlay( this.upFrame );
			}
		}
	}

	public function getState() : Number
	{ return this.state; }
}

