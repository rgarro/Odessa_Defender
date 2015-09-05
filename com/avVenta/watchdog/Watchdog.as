/**
 * This class executes a function if a registered movie is not present.
 *
 * @author Marco A. Alvarado
 * @version 1.0.0 2007-06-26
 */
class com.avVenta.watchdog.Watchdog {
	static private var TOKEN_SET:Number = 0;
	static private var TOKEN_REQUEST:Number = 1;
	
	/**
	 *
	 */
	static private function install() {
		if (!_root.watchdog.installed) {
			_root.watchdog = new Object();
			_root.watchdog.installed = true;
			_root.watchdog.tokens = new Array();
			_root.watchdog.movie = _root.createEmptyMovieClip("watchdogMovie", _root.getNextHighestDepth());
			
			_root.watchdog.movie.onEnterFrame = function() {
				for (var i:Number = 0; i < _root.watchdog.tokens.length; i++) {
					var token:Object = _root.watchdog.tokens[i];
					if (token != null) {
						if (token.state == TOKEN_SET) {
							token.state = TOKEN_REQUEST;
						} else {
							token.onTrigger(i);
							delete _root.watchdog.tokens[i];
						}
					}
				}
			}			
		}
	}

	/**
	 *
	 */
	static public function watch(movie:MovieClip, onTrigger:Function) {
		install();
		var indicator = movie.createEmptyMovieClip("watchdogIndicator", movie.getNextHighestDepth());
		indicator.tokenIndex = _root.watchdog.tokens.push({state:TOKEN_SET, onTrigger:onTrigger})-1;
		
		indicator.onEnterFrame = function() {
			Watchdog.reset(this.tokenIndex);
		}
	}

	/**
	 *
	 */
	static public function reset(tokenIndex:Number) {
		install();
		var token:Object = _root.watchdog.tokens[tokenIndex];
		if (token != null) token.state = TOKEN_SET;
	}
}
