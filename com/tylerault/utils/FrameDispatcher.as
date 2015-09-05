import com.tylerault.utils.CallbackObject;

/***
 * Somewhat similar to mx.events.EventDispatcher, this class uses a single MovieClip's
 * onEnterFrame handler to execute any number of methods each frame.  The purpose of this
 * is to use one onEnterFrame handler and to keep execution as efficient and tidy as possible.
 *
 * @author Tyler Ault [tault@digitas.com]
 ***/
class com.tylerault.utils.FrameDispatcher
{
	// used for its onEnterFrame handler 
	private var control_mc:MovieClip; 

	// Hashed Array of dispatch callbacks 
	private var dispatches:Array; 

	// keeps track of the highest id used (for creating unique IDs)
	private var dispatchCount:Number = 0;

	// keeps track of the total active dispatches
	private var dispatchTotal:Number = 0;

	public function FrameDispatcher( controlClip:MovieClip )
	{
		this.control_mc = controlClip;
		this.dispatches = new Array();
	}

	/***
	 * Adds a dispatch to the queue by creating a CallbackObject from pased parameters
	 * @see CallbackObject
	 * @returns the string identifier of the newly created dispatch
	 ***/
	public function addDispatch( thisObject:Object, method:Function, params:Array ) : String
	{
		var callback = new CallbackObject( thisObject, method, params );
		return addCallback( callback );
	}

	/***
	 * Adds a dispatch to the queue using a CallbackObject 
	 * @returns the string identifier of the newly created dispatch
	 ***/
	public function addCallback( callback:CallbackObject ) : String
	{
		var id:String = "d_" + dispatchCount;
		this.dispatches[ id ] = callback;
		dispatchCount ++;
		this.dispatchTotal ++; 
		evaluateDispatches(); 
		return id;
	}

	/***
	 * Clears (removes and destroys) a dispatch based on an id String
	 * @returns a boolean denoting success
	 ***/
	public function clearDispatch( id:String ) : Boolean
	{
		if( this.dispatches[ id ] != undefined )
		{
			delete this.dispatches[ id ];
			this.dispatchTotal --; 
			evaluateDispatches(); 
			return true;
		}
		else { return false; }
	}


	/***
	 * Clears (removes and destroys) a dispatch based on an id String
	 * @returns a boolean denoting success
	 ***/
	public function clearCallback( callback:CallbackObject ) : Boolean
	{
		for( var i:String in this.dispatches )
		{
			if( dispatches[ i ] == callback )
			{
				delete dispatches[ i ];
				this.dispatchTotal --; 
				evaluateDispatches(); 
				return true;
			}
		}
		return false;
	}

	/***
	 * Starts or stops the onEnterFrame based on the number of extant dispatches
	 ***/
	private function evaluateDispatches() : Void
	{
		if( this.dispatchTotal > 0 )
		{
			if( this.control_mc.onEnterFrame == null || this.control_mc.onEnterFrame == undefined )
			{
				var dispatcher:FrameDispatcher = this;
				this.control_mc.onEnterFrame = function()
				{
					dispatcher.runDispatches.apply( dispatcher );
				}
				// run dispatches immediately?
			}
		} else {
			this.control_mc.onEnterFrame = null;
		}
	}

	/***
	 * Runs all extant dispatches -- called onEnterFrame if dispatches exist
	 ***/
	public function runDispatches() : Void
	{
		for( var i:String in this.dispatches )
		{
			this.dispatches[ i ].run();
		}
	}

	/***
	 * Returns whether or not a particular method is already dispatching
	 ***/
	public function isDispatching( method:Function ) : Boolean
	{
		for( var i:String in this.dispatches )
		{
			if( this.dispatches[ i ].getMethod() == method )
			{ return true; }
		}
		return false;
	}

	/***
	 * Static function used to determine whether the provided object is a
	 * MovieClip or already a FrameDispatcher.
	 * If a MovieClip, a new Dispatcher is created using that clip.
	 * If already a FrameDispatcher, the object is returned.
	 * If neither, this funciton returns null.
	 ***/
	public static function useOrCreate( dispatchObject:Object ) : FrameDispatcher
	{
		if( dispatchObject instanceof MovieClip )
		{
			return new FrameDispatcher( MovieClip( dispatchObject ) );
		}
		else if( dispatchObject instanceof FrameDispatcher )
		{
			return FrameDispatcher( dispatchObject );
		}
		else { return null; }
	}
}
