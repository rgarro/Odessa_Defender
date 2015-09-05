import com.tylerault.utils.CallbackObject;
import com.tylerault.utils.Delay;
import com.tylerault.utils.FrameDispatcher;

/***
 * Manages delays.
 * Using callbacks and a MovieClip's onEnterFrame handler for evaluating
 * elapsed time, this class can delay methods by a given number of milliseconds.
 * This is greatly preferable to using Intervals, which are global and asynchronous
 * with the timeline.
 *
 * @author Tyler Ault [tault@digitas.com]
 ***/
class com.tylerault.utils.DelayManager
{
	private var delays:Array;
	private var dispatcher:FrameDispatcher;
	private var dispatch:String;
	private var coutner:Number;
	private var checking:Boolean;

	public static var idIndex:Number = 0;
	public static var delayIndex:Number = 1;
	
	/***
	 * dispatchObject can be a MovieClip or a FrameDispatcher (preferably the latter)
	 ***/
	function DelayManager( dispatchObject:Object )
	{
		this.dispatcher = FrameDispatcher.useOrCreate( dispatchObject );
		this.delays = new Array();
		this.coutner = 0;
		this.checking = false;
	}

	public function setDelay( callback:CallbackObject, milliseconds:Number,
		timesToCall:Number ) : String
	{
		if( timesToCall == undefined ){ timesToCall = 1; }
		var identifier:String = "i" + coutner++;
		var n:Number = this.delays.length;
		this.delays.push( new Array() );
		this.delays[ n ][ DelayManager.idIndex ] = identifier;
		this.delays[ n ][ DelayManager.delayIndex ] =
				new Delay( callback, milliseconds, timesToCall );

		startDelayCheck();
		return identifier;
	}

	public function clearDelay( delayID:String ) : Void
	{
		for( var i:Number = 0; i < delays.length; i++ )
		{
			if( this.delays[ i ][ DelayManager.idIndex ] == delayID )
			{
				delete this.delays[ i ][ DelayManager.delayIndex ];
				this.delays.splice( i, 1 );
			}
		}
	}

	public function clearAllDelays() : Void
	{
		for( var i:Number = 0; i < this.delays.length; i++ )
		{
			clearDelay( this.delays[ i ][ DelayManager.idIndex ] );
		}
	}

	public function checkDelays() : Void
	{
		var newGetTimer:Number = getTimer();
		for( var i:Number = 0; i < this.delays.length; i++ )
		{
			if( this.delays[ i ][ DelayManager.delayIndex ].checkDelay( newGetTimer ) )
			{
				clearDelay( this.delays[ i ][ DelayManager.idIndex ] );
			}
		}
		// if finished, stop checking 'til there's another
		if( this.delays.length == 0 )
		{
			this.dispatcher.clearDispatch( this.dispatch );
			this.dispatch = null;
			this.checking = false;
			this.coutner = 0;
		}
	}

	private function startDelayCheck()
	{
		if( this.checking != true )
		{
			this.dispatch = this.dispatcher.addDispatch( this, checkDelays );
			this.checking = true;
		}
	}
}
