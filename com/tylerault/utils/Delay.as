import com.tylerault.utils.LogicUtils;
import com.tylerault.utils.CallbackObject;

/***
 * The Delay class is to be used strictly by
 * the DelayManager class.
 * All time in milliseconds.
 * @author Tyler Ault [tault@digitas.com]
 ***/
class com.tylerault.utils.Delay
{
	private var TheCallback:CallbackObject;
	private var TimeStarted:Number;
	private var TimeToDelay:Number;
	private var TimesToCall:Number;

	function Delay( NewCallback:CallbackObject,
			NewTimeToDelay:Number, NewTimesToCall:Number )
	{
		this.TimeStarted = getTimer();
		this.TheCallback = NewCallback;
		this.TimeToDelay = NewTimeToDelay;
		this.TimesToCall = ( LogicUtils.exists( NewTimesToCall ) ) ? 
				NewTimesToCall : 1;
	}

	/***
	 * Checks this delay; if the time has elapsed, it runs
	 * the callback
	 * @param NewGetTimer a getTimer value (passed in from Manager
	 *        so that the call is not made many times for many delays)
	 * @returns a boolean: true if this object should be destroyed, false if not.
	 ***/
	function checkDelay( NewGetTimer:Number ) : Boolean
	{
		if( NewGetTimer - this.TimeStarted >= this.TimeToDelay )
		{
			this.TheCallback.run();
			this.TimesToCall --;
			if( this.TimesToCall <= 0 )
			{
				return true;
			}
			this.TimeStarted = NewGetTimer;
		}
		return false;
	}
}
