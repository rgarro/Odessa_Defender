import com.tylerault.media.SoundEntry;
import com.tylerault.utils.CallbackObject;
import com.tylerault.utils.DelayManager;
import com.tylerault.utils.LogicUtils;

/***
 * Manages sounds, using a unique MovieClip handler for
 * each sound instance.
 *
 * @author Tyler Ault [tault@digitas.com]
 ***/
class com.tylerault.media.SoundManager
{
	private var ClipHandler:MovieClip;
	private var MasterVolume:Number;
	private var TheDelayManager:DelayManager;

	/***
	 * The ActiveSounds Array is essentially a library
	 * of all sounds currently in use. It gives unique indexes to
	 * SoundEntry objects which store all necessary data for the sound.
	 * For more info, see the SoundEntry class.
	 ***/
	private var ActiveSounds:Array;
	private var Counter:Number;

	function SoundManager( NewHandler:MovieClip )
	{
		this.ClipHandler = NewHandler;
		this.ActiveSounds = new Array();
		this.MasterVolume = 100;
		this.Counter = 0;
	}

	public function playSound( LinkageName:String, Modifiers:Object,
		Callback:CallbackObject ) : String
	{
		var NewID:String = preloadSound( LinkageName, null, null, false );
		this.ActiveSounds[ NewID ].startSound( Modifiers, Callback );
		return NewID;
	}

	public function playExternalSound( FileName:String, Streaming:Boolean,
		Modifiers:Object, Callback:CallbackObject ) : String
	{
		var NewID:String = addSoundEntry( true );
		var NewEntry:SoundEntry = this.ActiveSounds[ NewID ];
		NewEntry.getSound().loadSound( FileName, Streaming );
		NewEntry.setLoadCallback( new CallbackObject( NewEntry,
				NewEntry.startSound, [ Modifiers, Callback ] ) );
		return NewID;
	}

	/***
	 * Preloads a sound for later use
	 ***/
	public function preloadSound( FileOrLinkageName:String, Streaming:Boolean,
		Callback:CallbackObject, External:Boolean ) : String
	{
		External = ( LogicUtils.exists( External ) ) ? External : true;
		var NewID:String = addSoundEntry();
		var NewEntry:SoundEntry = this.ActiveSounds[ NewID ];
		if( External != false )
		{
			NewEntry.getSound().loadSound( FileOrLinkageName, Streaming );
			NewEntry.setLoadCallback( Callback );
			NewEntry.getSound().stop();
		}
		else
		{
			NewEntry.getSound().attachSound( FileOrLinkageName );
			Callback.run();
		}
		return NewID;
	}

	/***
	 * Passes along the startSound call to a given sound
	 ***/
	public function startSound( SoundID:String, Modifiers:Object,
			FinishCallback:CallbackObject )
	{
		this.ActiveSounds[ SoundID ].startSound( Modifiers, FinishCallback );
	}

	/***
	 * Adds a sound to the library of ActiveSounds
	 * @param returns the string id of the new entry
	 ***/
	public function addSoundEntry( External:Boolean ) : String
	{
		var n = this.Counter ++;
		var ID:String = "s" + n;
		var SoundClip = this.ClipHandler.createEmptyMovieClip( ID, n + 1 );
		var NewEntry:SoundEntry = new SoundEntry( this, SoundClip, External );
		this.ActiveSounds[ ID ] = NewEntry;

		return ID;
	}

	public function deleteSound( SoundName:String, Callback:CallbackObject )
	{
		stopSound( SoundName );
		delete this.ActiveSounds[ SoundName ];
		if( LogicUtils.exists( Callback ) ) { Callback.run(); }
	}

	public function deleteAllSounds() : Void
	{
		 for( var i:String in this.ActiveSounds )
		 { deleteSound( i ); }
	}

	public function stopSound( SoundName:String, Callback:CallbackObject )
	{
		this.ActiveSounds[ SoundName ].stopSound();
		if( LogicUtils.exists( Callback ) ) { Callback.run(); }
	}

	/***
	 * Fades from one sound to the other
	 * @param SoundA string ID of the sound that will fade out (to 0)
	 * @param SoundB string ID of the sound that will fade in
	 * @param Duration number of milliseconds over which to fade 
	 * @param Modifiers optional modifiers for SoundB
	 * @param Callback optional callback to run once fade is complete
	 * @param DeleteFlag optional boolean denoting whether SoundA should be deleted
	 *        ( defaults to false )
	 ***/
	public function crossFade( SoundA:String, SoundB:String, Duration:Number,
			Modifiers:Object, FinishedCallback:CallbackObject, DeleteFlag:Boolean )
	{
		if( !LogicUtils.exists( Modifiers ) )
		{
			Modifiers = new Object( { Volume:100 } );
		}
		var	FinalVolume:Number = LogicUtils.exists( Modifiers.Volume ) ?
				Modifiers.Volume : 100;

		var SoundACallback:CallbackObject;
		if( DeleteFlag == true )
		{
			SoundACallback = new CallbackObject( this, deleteSound, [ SoundA ] );
		}
		else
		{
			SoundACallback = new CallbackObject( this, stopSound, [ SoundA ] );
		}

		// start playing SoundB
		Modifiers.Volume = 0;
		this.ActiveSounds[ SoundB ].startSound( Modifiers );

		// start the fades
		this.ActiveSounds[ SoundA ].fade( null, 0, Duration, SoundACallback );
		this.ActiveSounds[ SoundB ].fade( 0, FinalVolume, Duration, FinishedCallback );
	}


	public function fadeSound( SoundID:String, StartVolume:Number, StopVolume:Number,
			Duration:Number, Callback:CallbackObject ) : Void
	{
		this.ActiveSounds[ SoundID ].fade( StartVolume, StopVolume, Duration, Callback );
	}

	/***
	 * Simplified function for fading a sound in
	 ***/
	public function fadeIn( SoundID:String, Duration:Number )
	{
		var Modifiers:Object = new Object( { Volume:0 } );
		this.ActiveSounds[ SoundID ].startSound( Modifiers );
		this.ActiveSounds[ SoundID ].fade( 0, 100, Duration );
	}

	/***
	 * Simplified function for fading a sound out
	 ***/
	public function fadeOut( SoundID:String, Duration:Number )
	{
		var Callback:CallbackObject = new CallbackObject( this, stopSound, [ SoundID ] );
		this.ActiveSounds[ SoundID ].fade( 100, 0, Duration, Callback );
	}

	/***
	 * Sets a given entry's actual volume based on the MasterVolume
	 * @param EntryIndex the index of the entry in ActiveSounds
	 * @param RelativeVolume optional: if given, the sound's volume will be
	 *        set to this value. (see SoundEntry class)
	 ***/
	public function setSoundVolume( EntryID:String, RelativeVolume:Number ) : Void
	{
		var Entry:SoundEntry = this.ActiveSounds[ EntryID ];
		Entry.setRelativeVolume( RelativeVolume );
	}

	/***
	 * Sets the MASTER volume for all sounds in the SoundManager,
	 * reapplying each sound's actual volume based on the entry's relative volume.
	 * @param NewValue a number between 0 and 100
	 * @returns a boolean denoting the success of the operation
	 ***/
	public function setMasterVolume( NewValue:Number ) : Boolean
	{
		if( NewValue >= 0 && NewValue <= 100 )
		{
			this.MasterVolume = Math.round( NewValue );
			for( var i:String in this.ActiveSounds )
			{
				setSoundVolume( i );
			}
			return true;
		}
		return false;
	}

	public function getMasterVolume() : Number
	{
		return this.MasterVolume;
	}

	public function getSound( SoundID:String ) : Sound
	{
		return this.ActiveSounds[ SoundID ].getSound();
	}

	public function getSoundClip( SoundID:String ) : MovieClip
	{
		return this.ActiveSounds[ SoundID ].getSoundClip();
	}

	/***
	 * The following functions are for using a preloader to indicate
	 * the state of all currently loaded sounds
	 ***/
	public function getBytesLoaded() : Number
	{
		var TotalLoaded:Number = 0;
		for( var i:String in this.ActiveSounds )
		{
			TotalLoaded += this.ActiveSounds[ i ].getSound().getBytesLoaded();
		}
		return TotalLoaded;
	}

	public function getBytesTotal() : Number
	{
		var TotalBytes:Number = 0;
		for( var i:String in this.ActiveSounds )
		{
			TotalBytes += this.ActiveSounds[ i ].getSound().getBytesTotal();
		}
		return TotalBytes;
	}

}
