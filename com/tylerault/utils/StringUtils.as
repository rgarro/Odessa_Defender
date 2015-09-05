/***
 * String Utility class
 *
 * @author Tyler Ault [tault@digitas.com]
 ***/
class com.tylerault.utils.StringUtils
{
	
	/***
	 * Truncates a string to a certain number of characters, replacing end
	 * characters with the End string (as many as End is long)
	 ***/
	public static function truncate( TheString:String, MaxLength:Number, End:String ) : String
	{
		if( End == undefined || End == null )
		{
			End = "...";
		}
		
		if( TheString.length > MaxLength )
		{
			TheString = TheString.slice( 0, ( MaxLength - End.length ) );
			TheString = TheString + End;
		}
		
		return TheString;
	}

	/***
	 * Replaces the string Pattern with the string Replace throughout the Body of text
	 * @ Pattern a string for which to search
	 * @ Replace the string with which to replace it
	 * @ Body the body of text to search through
	 * @ returns the new body of text
	 ***/
	public static function replace( Pattern:String, Replace:String, Body:String ) : String 
	{
		var SplitBody:Array = Body.split( Pattern );
		var NewBody:String;
		if( SplitBody.length > 1 )
		{
			NewBody = SplitBody.join( Replace );
		}
		else
		{
			NewBody = Body;
		}
		return NewBody;
	}
	
	/***
	 * Converts a string of the following values to a boolean:
	 * @param Value "true", "t", "false", "f" (case insensitive)
	 * @returns a boolean if found, null if not.
	 ***/
	public static function toBoolean( Value:String ) : Boolean
	{
		switch( Value.toLowerCase() )
		{
			case "true" : return true;
			case "t" : return true;
			case "false" : return false;
			case "f" : return false;
			default: return null;
		}
	}
}
