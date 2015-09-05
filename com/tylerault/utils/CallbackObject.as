/***
 * The most useful class I've ever created:
 * A simple callback wrapper that ensures a method gets called on the specified object
 * Also, allows for parameters to be specified when the callback is created.
 *
 * Just create the callback, pass it to the object / MovieClip you want to wait for,
 * then in that object / MovieClip, call CallbackName.run().
 *
 * @author Tyler Ault [tault@digitas.com]
 ***/
class com.tylerault.utils.CallbackObject
{
    // object to which function shall be applied
    private var ThisObject:Object;

    // function to be called
    private var ThisMethod:Function;
    
    // parameters to pass
    private var TheseParams:Array;

    /***
     * Constructor
	 * @param NewThis the object to which the method should be applied: the 'this'
	 * @param NewMethod the method to be run
	 * @param NewParams optional array of parameters to pass when the method is called
     ***/
    function CallbackObject( NewThis:Object, NewMethod:Function, NewParams:Array )
    {
        this.ThisObject = NewThis;
        this.ThisMethod = NewMethod;
        setParams( NewParams );
    }

    /***
     * Runs the callback
	 * optional: pass parameters to be used by the method
     ***/
    function run()
    {
        // if we're passing in arguments, use those instead of TheseParams
        if( arguments.length > 0 )
        {
        	setParams( arguments );
        }
        
        // apply ThisMethod to ThisObject with TheseParams
        return ThisMethod.apply( ThisObject, TheseParams );
    }

	/***
     * For adding a parameter to the end of TheseParams
     ***/
	function addParam( NewObject:Object )
	{
		this.TheseParams.push( NewObject );
	}

	/***
	 * For assigning an onEnterFrame to call on a particular object
	 ***/
	public function eachFrame( NewClip:MovieClip, Params:Array )
	{
		if( Params != undefined ){ setParams( Params ); }
		var TheCallback:CallbackObject = this;
		NewClip.onEnterFrame = function()
		{
			TheCallback.run.apply( TheCallback );
		}
	}

    /***
     * Getters/Setters
     ***/
	function getParams():Array
	{
		return this.TheseParams;
	}
	
	function setParams( NewParams:Array )
	{
		if( NewParams.length > 0 )
		{
			this.TheseParams = NewParams.concat();
		}
		else
		{
			this.TheseParams = new Array();
		}
	}
	
	public function getMethod():Function
	{ return this.ThisMethod; }

}
