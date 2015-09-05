/**
 * This singleton class translates texts in different languages.
 *
 * Texts in each language must be registered with addText() method. 
 * Translations of the same text must share the same key. The
 * current language for localization is set with selectLanguage().
 */
class com.avVenta.language.LanguageController {
	
	// variables
	static private var instance:LanguageController;
	private var languages:Object;
	private var current:String;
	
	public var name:String;
	
	/**
	 * Constructor.
	 */
	public function LanguageController() {
		name = "LanguageController";
	}
	
	/**
	 * Gets the singleton instance.
	 */
	static public function getInstance():LanguageController {
		if (instance == null)
			instance = new LanguageController();
		return instance;
	}
	
	/**
	 * Assigns a localization text to a given language and key.
	 *
	 * @param  language  String  The language of the text.
	 * @param  key  String  The key to gather the text.
	 * @param  text  String  The text to be assigned.
	 */
	public function addText(language:String, key:String, text:String):Void {
		if (languages[language] == null)
			languages[language] = new Object();
		languages[language][key] = text;
	}
	
	/**
	 * Selects the language of lacalization.
	 *
	 * @param  language  String  The language to select.
	 */
	public function selectLanguage(language:String):Void {
		current = language;
	}
	
	/**
	 * Returns the text corresponding to the current language and the given key.
	 *
	 * @param  key  String  The key assigned to the text.
	 */
	public function localizeText(key:String):String {
		return languages[languages][key];
	}
}