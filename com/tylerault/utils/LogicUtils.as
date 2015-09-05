/***
 * Primarily static class for logical functions
 *
 * @author Tyler Ault [tault@digitas.com]
 ***/
class com.tylerault.utils.LogicUtils
{
	function LogicUtils()
	{
		// Empty constructor.
	}

	public static function exists( Subject:Object ) : Boolean
	{
		if( Subject != undefined && Subject != null )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	/***
     * Transposes the coordinates of ClipConcerned from ClipConcerned's parent coordinate system
     * to the NewCoordinateSystem
     *
     * @returns a generic Object with x and y properties (access using Object.x, Object.y)
     ***/
	public static function transposeCoordinates( ClipConcerned:MovieClip, NewCoordinateSystem:MovieClip ):Object
    {
		var point:Object = { x:ClipConcerned._x, y:ClipConcerned._y }
		ClipConcerned._parent.localToGlobal( point );
		NewCoordinateSystem.globalToLocal( point );
		return point;
    }

	/***
	 * @returns a string describing an object
	 ***/
	public static function describeObject( Obj:Object, Indent:Number ) : String
	{
		var Description:String = "";
		var IndentString:String = "  ";
		var Prefix:String = "";
		for( var i:Number = 0; i < Indent; i++ ){ Prefix += IndentString; }

		for( var i:String in Obj )
		{
			var ObjType:String = typeof( Obj[ i ] );
			if( ObjType == "object" )
			{
				Description += ( Prefix + i + " (object):\r" );
				Description += describeObject( Obj[ i ], Indent + 1 ); 
			}
			else
			{
				Description += ( Prefix + i + " (" + ObjType + "): " + Obj[ i ] + "\r" );
			}
		}
		return Description;
	}
	 
}
