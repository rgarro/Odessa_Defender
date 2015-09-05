import com.tylerault.media.SoundManager;
import com.tylerault.utils.CallbackObject;
import com.tylerault.utils.LogicUtils;

/***
 * The SoundEntry class is used by the SoundManager class 
 * to keep track of and manipulate sounds in an application.
 * @see SoundManager
 *
 * @author Tyler Ault [tault@digitas.com]
 ***/
class com.tylerault.media.SoundEntry
{
	// TODO: should these be private with getters?
	private var SoundObject:Sound; // the native Sound object
	private var SoundClip:MovieClip; // the MovieClip handler
	private var External:Boolean;
	private var Manager:SoundManager;

	private var CompletionCallback:CallbackObject;
	private var LoadCallback:CallbackObject;
	private var TimeStarted:Number;
	private var SoundPosition:Number;
	private var Loops:Number;

	// the relative volume of the sound (to the master volume)
	private var RelativeVolume:Number;

	/***
	 * Constructor.
	 * @param NewManager a SoundManager for getting the master volume
	 * @param NewClipHandler a MovieClip for controlling this sound
	 * @param NewExternal a boolean denoting if this sound is externally-loaded
	 ***/
	function SoundEntry( NewManager:SoundManager, NewClipHandler:MovieClip,
			NewExternal:Boolean)
	{
		this.SoundClip = NewClipHandler;
		this.SoundObject = new Sound( this.SoundClip );
		this.Manager = NewManager;
		this.External = NewExternal;
		this.SoundPosition = 0;
		this.Loops = 1;
	}

	public function startSound( Modifiers:Object, Callback:CallbackObject ) : Void
	{
		processModifiers( Modifiers );
		this.TimeStarted = getTimer();
		this.SoundObject.start( this.SoundPosition / 1000, this.Loops );
		if( LogicUtils.exists( Callback ) )
		{
			// TODO: will this fire off every time a loop is complete?
			// if so, we'll need a wrapper callback.
			this.CompletionCallback = Callback;
			var TheSoundEntry:SoundEntry = this;
			this.SoundObject.onSoundComplete = function()
			{ TheSoundEntry.CompletionCallback.run(); }
		}
	}

	public function stopSound() : Void
	{
		this.SoundPosition = 0; // this.SoundObject.position; <-- pause!
		this.SoundObject.stop();
	}

	/***
	 * Implements the modifiers passed in the Modifiers Object: 
	 * ( Volume, Pan, Transform, FadeOut )
	 ***/
	public function processModifiers( Modifiers:Object ) : Void
	{
		if( LogicUtils.exists( Modifiers ) )
		{
			if( LogicUtils.exists( Modifiers.Loops ) )
			{ this.Loops = Modifiers.Loops }

			if( LogicUtils.exists( Modifiers.Position ) )
			{ this.SoundPosition = Modifiers.Position; }

			if( LogicUtils.exists( Modifiers.Pan ) )
			{ this.SoundObject.setPan( Modifiers.Pan ); }

			if( LogicUtils.exists( Modifiers.Transform ) )
			{ this.SoundObject.setTransform( Modifiers.Transform ); }
		}

		// if Modifiers.Volume doesn't exist, the default will be used.
		setRelativeVolume( Modifiers.Volume );
	}


	/***
	 * Starts fading
	 * @param StartVolume optional relative start volume (if null will use existing volume)
	 * @param StopVolume volume to which we are fading
	 * @param Duration number of millieseconds over which the fade should occur
	 * @param Callback to call once the fade has completed
	 ***/
	public function fade( StartVolume:Number, StopVolume:Number,
			Duration:Number, Callback:CallbackObject ) : Void
	{
		StartVolume = LogicUtils.exists( StartVolume ) ? StartVolume : this.RelativeVolume;
		var FadeStart:Number = getTimer();
		var FadeDifference:Number = StopVolume - StartVolume;
		this.SoundClip.FadeFrameHandler = new CallbackObject( this,
				processFade, [ FadeStart, FadeDifference, StartVolume, Duration,
				Callback ] );
		this.SoundClip.FadeFrameHandler.eachFrame( this.SoundClip );
		this.SoundClip.FadeFrameHandler.run(); // start immediately.
	}

	/***
	 * Processes the fade incrementally each frame
	 ***/
	public function processFade( FadeStart:Number, FadeDifference:Number,
			StartVolume:Number, Duration:Number, Callback:CallbackObject ) : Void
	{
		var PercentDone:Number = ( getTimer() - FadeStart ) / Duration;
		PercentDone = ( PercentDone > 1 ) ? 1 : PercentDone;
		var NewVolume:Number = Math.round( StartVolume + ( PercentDone * FadeDifference ) );
		setRelativeVolume( NewVolume );
		if( PercentDone >= 1 )
		{
			this.SoundClip.onEnterFrame = null;
			Callback.run();
		}
	}
	

	/////////////////////
	// Getters / Setters

	public function getSound() : Sound
	{
		return this.SoundObject;
	}

	public function setLoadCallback( NewCallback:CallbackObject ) : Void
	{
		this.LoadCallback = NewCallback;
		var TheSoundEntry:SoundEntry = this;
		this.SoundObject.onLoad = function ()
		{
			TheSoundEntry.LoadCallback.run();
		}
	}

	/***
	 * Has two uses:
	 * 1) RelativeVolume passed
	 *    both stores and applies the new relative volume
	 * 2) Nothing passed
	 *    applies existing relative volume, setting to 100 if none exists
	 * @returns the actual volume that was set
	 ***/

	public function setRelativeVolume( RelativeVolume:Number ) : Number
	{
		// if we're passing RelativeVolume, store it
		if( LogicUtils.exists( RelativeVolume ) )
		{
			this.RelativeVolume = RelativeVolume;
		}
		else
		{
			// otherwise, if the entry doesn't yet have a RelativeVolume, set it to max
			if( !LogicUtils.exists( this.RelativeVolume ) )
			{
				this.RelativeVolume = 100;
			}
		}

		var ActualVolume:Number = Math.round( this.Manager.getMasterVolume() *
				( this.RelativeVolume / 100 ) );

		// trace( "setting Volume: " + ActualVolume );
		this.SoundObject.setVolume( ActualVolume );
		return ActualVolume;
	}

	public function getRelativeVolume() : Number
	{
		return this.RelativeVolume;
	}

	public function getSoundClip() : MovieClip
	{
		return this.SoundClip;
	}
}

