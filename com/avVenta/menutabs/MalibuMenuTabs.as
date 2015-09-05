import com.avVenta.events. *;
import com.avVenta.menutabs. *;
class com.avVenta.menutabs.MalibuMenuTabs
{
	// variables
	private var tabsMC : Array;
	private var options : Array;
	private var selectedTab : Number;
	private var x : Number;
	private var y : Number;
	private var spacing : Number;
	public function MalibuMenuTabs ()
	{
		tabsMC = new Array ();
		options = new Array ();
		selectedTab = 0;
	}
	public function addTab (mc : MovieClip, ops : MalibuMenuOptions, onSelectTab : Function)
	{
		trace ('MalibuMenuTabs: added ' + mc + ' function ' + onSelectTab);
		tabsMC.push (mc);
		options.push (ops);
		mc._menutabs = this;
		mc._index = tabsMC.length - 1;
		mc._onSelectTab = onSelectTab;
		mc._active = true;
		mc.button.onRelease = function ()
		{
			this._parent._menutabs.selectTab (this._parent._index);
			this._parent._onSelectTab (this._parent._index);
		}
		if (selectedTab == tabsMC.length - 1)
		{
			tabsMC [selectedTab].expand.gotoAndStop (2);
			options [selectedTab].showOptions ();
			onSelectTab (selectedTab);
		}
	}
	public function placeTabs (x : Number, y : Number, spacing : Number)
	{
		this.x = x;
		this.y = y;
		this.spacing = spacing;
		for (var i : Number = 0; i < tabsMC.length; i ++)
		{
			if (tabsMC [i]._active)
			{
				tabsMC [i]._x = x;
				tabsMC [i]._y = y;
				x += tabsMC [i]._width + spacing;
			}
		}
	}
	public function selectTab (index : Number)
	{
		tabsMC [selectedTab].expand.gotoAndStop (1);
		options [selectedTab].hideOptions ();
		selectedTab = index;
		tabsMC [selectedTab].expand.gotoAndStop (2);
		options [selectedTab].showOptions ();
	}
	public function enableTab (index : Number)
	{
		tabsMC [index]._active = true;
		placeTabs (x, y, spacing);
	}
	public function disableTab (index : Number)
	{
		tabsMC [index]._active = false;
		placeTabs (x, y, spacing);
	}
	public function removeTabs ()
	{
		for (var i : Number = 0; i < tabsMC.length; i ++)
		{
			tabsMC [i].removeMovieClip ()
			options [i].removeOptions ();
		}
		//***
	}
}
