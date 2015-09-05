/***
 * Array utility classs
 *
 * @author Tyler Ault [tault@digitas.com]
 ***/
class com.tylerault.utils.ArrayUtils
{

	function ArrayUtils(){}

	public static function getIndexOf( Needle:Object, Haystack:Array ) : Number 
	{
		for( var i:Number = 0; i < Haystack.length; i++ )
		{
			if( Needle == Haystack[ i ] )
			{
				return i;
			}
		}
		return -1;
	}

	public static function inArray( Needle:Object, Haystack:Array ) : Boolean
	{
		var Index:Number = ArrayUtils.getIndexOf( Needle, Haystack );
		var ReturnValue:Boolean = ( Index >= 0 ) ? true : false;
		return ReturnValue;
	}

	public static function shuffle( TheArray:Array ) : Array
	{
		var Temp;
		var r:Number;
		for ( var i:Number = 0; i < TheArray.length; i++ )
		{
			Temp = TheArray[ i ];
			r = Math.floor( Math.random() * TheArray.length );
			TheArray[ i ] = TheArray[ r ];
			TheArray[ r ] = Temp;
		}
		return TheArray;
	} 

	/***
	 * Warning: this could be a costly operation with 100+ unique entries!
	 ***/
	public static function removeDuplicates( TheArray:Array ) : Array
	{
		var Unique:Array = new Array(); // stores instances to compare against later indexes
		var i:Number = 0;
		while ( i < TheArray.length )
		{
			// check if an instance has already been found
			if( ArrayUtils.inArray( TheArray[ i ], Unique ) ) 
			{
				TheArray.splice( i, 1 );
			} else {
				Unique.push( TheArray[ i ] );
				i ++;
			}
		}
		return TheArray;
	}
}
