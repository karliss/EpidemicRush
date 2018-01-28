package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import openfl.Assets;
import openfl.display.BitmapData;
import flixel.system.FlxAssets;
import haxe.Json;
import nape.phys.*;
import nape.shape.*;
import nape.geom.Vec2;

class Thing extends FlxNapeSprite
{
    //var image: FlxSprite;
    
	public function new (asset: FlxGraphicAsset, width: Int = 32, height: Int = 32)
	{
		super(0, 0);
        if (Std.is(asset, FlxSprite)) {
            var reference: FlxSprite = cast asset;
            loadGraphicFromSprite(reference);
            createCircularBody(this.width/2);
        } else if (Std.is(asset, BitmapData)) {
            var reference: BitmapData = cast asset;
            loadGraphic(reference, false, width, height);
            createCircularBody(this.width/2);
        } else {
            var path: String = cast asset;
            if (!StringTools.endsWith(path, ".json")) {
                loadGraphic(path, false, width, height);
                createCircularBody(this.width/2);
            } else {
                var jsondata = Json.parse(openfl.Assets.getText(path));
                var width = Std.parseInt(jsondata.width);
		        var height = Std.parseInt(jsondata.height);
                loadGraphic(jsondata.image, true, width, height);
                centerOffsets();

                for (anim in Reflect.fields(jsondata.animation)) {
                    var d = Reflect.field(jsondata.animation, anim);
                    var speed:Int = Std.parseInt(d.speed);
                    var looped = d.looped == "true";
                    animation.add(anim, d.f, speed, looped);
		        }
                var bodyDesc = Reflect.field(jsondata, "body");
                if (bodyDesc != null) {
                     var bodyDec = jsondata.body;
                    var newBody:Body = new Body();
                    if (body != null) {
                        destroyPhysObjects();
                    }
                    setBody(newBody);
                    var parts:Array<Dynamic> = bodyDec.parts;
                    for (part in parts) {
                        switch (part.type) {
                            case "circle": {
                                newBody.shapes.add(new Circle(part.r, new Vec2(part.x, part.y)));
                            }
                            default: {}
                        }
                    }
                } else {
                    createCircularBody(this.width/2);
                }
              
            }
        }
		body.allowRotation = false;
		setDrag(0.98, 1);
        body.userData.sprite = this;
	}
}
