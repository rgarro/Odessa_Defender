﻿import com.avVenta.hotspot.*;import mx.utils.Delegate;class com.avVenta.hotspot.SaturnHotspotAnimation extends HotspotAnimationBase{		private var mcLabel:MovieClip;	private var mcPlus:MovieClip;	private var mcArrows:MovieClip;	private var mcBracketLeft:MovieClip;	private var mcBracketRight:MovieClip;	private var mcBackground:MovieClip;		private var mcContent:HotspotContentBase;		private var initLeftX:Number;	private var initRightX:Number;		private var animTime = 0.5;		public function SaturnHotspotAnimation(){		this.mcLabel.tf.autoSize = "right";				this.setContractedStates();		this.initLeftX = this.mcBracketLeft._x;		this.initRightX = this.mcBracketRight._x;				addEventListener("onContentClosed", this);	}		public function setContractedStates(){		this.mcLabel._visible = false;		this.mcLabel._alpha = 0;				this.mcLabel._x = 0;		this.mcLabel.tf.text = "";				this.mcArrows._visible = false;		this.mcArrows._alpha = 0;			this.mcArrows._x = 0;				this.mcBackground._visible = false;		this.mcBackground._alpha = 0;			this.mcBackground._width = 2;		this.mcBackground._x = 0;	}		public function showRollOver(){		trace("show rollOver **********************************");		super.showRollOver();				this.mcLabel._visible = true;		this.mcArrows._visible = true;		this.mcBackground._visible = true;				this.mcLabel.tf.text = this._parent.getLabel();		var newWidth = mcLabel._width + 20 + this.mcArrows._width;		this.mcBracketLeft.slideTo((initLeftX - (newWidth/2)), mcBracketLeft._y, animTime)		this.mcBracketRight.slideTo((initRightX + (newWidth/2)) - 8, mcBracketRight._y, animTime)				this.mcBackground.tween(["_x", "_width", "_alpha"], [(initLeftX - (newWidth/2)), newWidth + 6, 100], animTime);				this.mcPlus.alphaTo(0, animTime * 0.8);		var bounds = this.mcLabel.getBounds();		var middle = bounds.xMin + (newWidth/2);		this.mcLabel._x = -1 * middle;				this.mcArrows.tween(["_x", "_alpha"], [this.mcLabel._x + 14, 100], animTime);				this.mcLabel.alphaTo(100, animTime,  "linear", 0, Delegate.create(this, showRollOverEnd));			}	public function hideRollOver(){		super.hideRollOver();		mcBracketLeft.slideTo(initLeftX, mcBracketLeft._y, animTime);		mcBracketRight.slideTo(initRightX, mcBracketRight._y, animTime);				mcBackground.tween(["_width","_alpha", "_x"], [2, 0, 0], animTime);				mcArrows.tween(["_alpha", "_x"], [0, 0], animTime * 0.8);				mcPlus._visible = true;		mcPlus.alphaTo(100, animTime, "linear", 0, Delegate.create(this, hideRollOverEnd));			mcLabel.alphaTo(0, animTime * 0.4);				}		private function hideRollOverEnd(){		trace("hiding rollOver");				this.setContractedStates();				broadcastEvent(BracketHotspotAnimation.HIDEROLLOVEREND);	}	private function showRollOverEnd(){		this.mcPlus._visible = false;		broadcastEvent(BracketHotspotAnimation.SHOWROLLOVEREND);	}		public function showContent(){		super.showContent();				this.mcBracketLeft._visible = false;		this.mcBracketRight._visible = false;		this.setContractedStates();						mcContent = HotspotContentBase(this.attachMovie("HotspotContent_mc", "mcContent", 0, {_xscale: 1, _yscale: 1}));				var x:Number = this._parent._x >= (this._parent.getParent().getWidth() / 2) ? this._parent._x  - mcContent.width : this._parent._x;		var y:Number = this._parent._y >= (this._parent.getParent().getHeight() / 2) ? this._parent._y  - mcContent.height : this._parent._y;				var left:Number = x;		var right:Number = x + mcContent.width;		var top:Number = y;		var bottom:Number = y + mcContent.height;				var newX:Number =  left < 0 ? (x + Math.abs(left) - this._parent._x) : 							(right > this._parent.getParent().getWidth() ? x - (right - this._parent.getParent().getWidth()) - this._parent._x : x - this._parent._x ) ;		var newY:Number =  top < 0 ? (y + Math.abs(top) - this._parent._y) : 							(bottom > this._parent.getParent().getHeight() ? y - (bottom - this._parent.getParent().getHeight()) - this._parent._y : y - this._parent._y ) ;		mcContent.tween(["_xscale","_yscale", "_x", "_y"], [100, 100, newX, newY], animTime, "easeOutExpo", 0, Delegate.create(this, showContentEnd));				mcBracketLeft.slideTo(initLeftX, mcBracketLeft._y, animTime);		mcBracketRight.slideTo(initRightX, mcBracketRight._y, animTime);		}	public function hideContent(){		super.hideContent();		mcContent.tween(["_xscale","_yscale", "_x", "_y"], [1, 1, 0, 0], animTime * 0.6, "easeInExpo", 0, Delegate.create(this, hideContentEnd));						mcPlus.alphaTo(100, animTime, "linear")	}			private function hideContentEnd(){		setContractedStates();				mcBracketLeft._visible = true;		mcBracketRight._visible = true;		mcPlus._visible = true;		//mcLabel._visible = true;				mcContent.removeMovieClip();				broadcastEvent(BracketHotspotAnimation.HIDECONTENTEND);	}	private function showContentEnd(){				broadcastEvent(BracketHotspotAnimation.SHOWCONTENTEND);			}		private function onContentClosed(){		trace("ContentClosed");		hideContent();	}	}