import com.avVenta.events. *;
class com.avVenta.menutabs.MalibuMenuOptions
{
	// variables
	private var optionsMC : Array;
	public function MalibuMenuOptions ()
	{
		optionsMC = new Array ();
	}
	public function addOption (mc : MovieClip, title : String, image : Number, onSelectOption : Function)
	{
		trace ('MalibuMenuOptions: added ' + mc + ' title: ' + title + ' image: ' + image);
		optionsMC.push (mc);
		mc._menuoptions = this;
		mc._index = optionsMC.length - 1;
		mc._onSelectOption = onSelectOption;
		mc.button.onRelease = function ()
		{
			this._parent._menuoptions.selectOption (this._parent._index);
			this._parent._onSelectOption (this._parent._index);
		}
		mc.button.onRollOver = function ()
		{
			this._parent.highlight._visible = false;
		}
		mc.button.onRollOut = function ()
		{
			this._parent.highlight._visible = true;
		}
		mc.title.text = title;
		mc.image.gotoAndStop (image);
		mc._visible = false;
	}
	public function addDivider (mc : MovieClip)
	{
		trace ('MalibuMenuOptions: added ' + mc);
		optionsMC.push (mc);
		mc._visible = false;
	}
	public function placeOptions (x : Number, y : Number, spacing : Number)
	{
		for (var i : Number = 0; i < optionsMC.length; i ++)
		{
			optionsMC [i]._x = x;
			optionsMC [i]._y = y;
			x += optionsMC [i]._width + spacing;
		}
	}
	public function selectOption (index : Number)
	{
	}
	public function showOptions ()
	{
		for (var i : Number = 0; i < optionsMC.length; i ++)
		{
			optionsMC [i]._visible = true;
		}
	}
	public function hideOptions ()
	{
		for (var i : Number = 0; i < optionsMC.length; i ++)
		{
			optionsMC [i]._visible = false;
		}
	}
	public function removeOptions ()
	{
		for (var i : Number = 0; i < optionsMC.length; i ++)
		{
			optionsMC [i].removeMovieClip ();
		}
	}
}
