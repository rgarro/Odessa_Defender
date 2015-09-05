/**
 * This class controls a movieclip's bounding box to detect collisions.
 *
 * @author Marco A. Alvarado
 * @version 1.0.0 2007-05-25
 */
import com.avVenta.view360.*;
 
class com.avVenta.view360.BoundingBoxMovieClip extends BoundingBox {
	private var mc:MovieClip;
	private var fixedWidth:Number;
	private var fixedHeight:Number;
	
	/**
	 *
	 */
	public function BoundingBoxMovieClip(mc:MovieClip) {
		this.mc = mc;
	}
	
	/**
	 *
	 */
	public function assignSize(width:Number, height:Number) {
		fixedWidth = width;
		fixedHeight = height;
	}
	
	/**
	 *
	 */
	public function isPointInside(x:Number, y:Number):Boolean {
		if ((fixedWidth != null) && (fixedHeight != null))
			return (mc != null) && (x >= 0) && (y >= 0) && (x <= fixedWidth) && (y <= fixedHeight); else
			return (mc != null) && (x >= 0) && (y >= 0) && (x <= mc._width) && (y <= mc._height);
	}
	
	/**
	 *
	 */
	public function isMouseInside():Boolean {
		return isPointInside(mc._xmouse, mc._ymouse);
//		return mc.hitTest(_root._xmouse, _root._ymouse);
	}
}