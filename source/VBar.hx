
import openfl.display.BitmapData;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import haxe.ds.Vector;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import openfl.geom.*;

class VBar extends FlxSpriteGroup {
    public var level:Float = 1;
    
    private var prev_level:Float = 1;

    var drawSprite: FlxSprite;
    var originalSprite: BitmapData;

    public function new(image:String) {
        super();
        var tmpSprite = new FlxSprite();
        tmpSprite.loadGraphic(image, false);
        originalSprite = tmpSprite.pixels;

        drawSprite = new FlxSprite();
        drawSprite.makeGraphic(originalSprite.width, originalSprite.height);
        updateGraphic(true);
        add(drawSprite);
    }

    function updateGraphic(force:Bool=false) {
        var prevH:Int = cast (prev_level * originalSprite.height);
        var newH:Int = cast(level * originalSprite.height);
        var h:Int = originalSprite.height;
        var w:Int = originalSprite.width;
        if (newH < 0) {
            newH = 0;
        } else if (newH > h) {
            newH = h;
        }
        if (newH == prevH && !force) {
            return;
        }
        var out:BitmapData = drawSprite.pixels;
        out.lock();
        for (i in 0...(h - newH)) {
            for (j in 0...(w)) {
                out.setPixel32(j, i, 0x00000000);
            }
        }
        out.copyPixels(originalSprite, new Rectangle(0, h-newH, w, newH), new Point(0, h-newH));
        out.unlock();
        drawSprite.dirty = true;
    }

    override public function update(diff:Float) {
        if (prev_level != level) {
            updateGraphic();
        }
        super.update(diff);
    }

}
