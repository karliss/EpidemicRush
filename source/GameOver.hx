
package ;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.ui.FlxButton;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;

class GameOver extends FlxSubState
{
	private var game:PlayState;
	private var buttons:ButtonMenu;

	private var btnRestart : flixel.ui.FlxButton;
	private var btnExit : FlxButton;
	var input:MoveState;
	var score: Float;

	public function new (_game:PlayState, score:Float)
	{
		super();
		game = _game;
		this.score = score;
		input = new MoveState();
	}

	static function noScroll(sprite: FlxSprite) {
		sprite.scrollFactor.set(0, 0);
	}

	public override function create()
	{
		FlxG.mouse.visible = true;

		var background:FlxSprite = new FlxSprite();
		background.loadGraphic("assets/images/gameover.jpg");
		add(background);
		background.x += (FlxG.width - background.width) /2 - 30;
		background.y += (FlxG.height - background.height) /2;
		noScroll(background);
		buttons = new ButtonMenu();
		add(buttons);

		var scoreTxt = '${score}'.substr(0, 5);
		var text = new FlxText(90, 520, 200, 'Score: ${scoreTxt}', 18);
		text.alignment = FlxTextAlign.CENTER;
		text.x = FlxG.width/2 - text.width/2;
		noScroll(text);
		add(text);

		btnRestart = new FlxButton ( 0 , 570 , "Restart" , function () {game.reset();} );
		buttons.addButton(btnRestart);
		btnRestart.x = FlxG.width/2 - btnRestart.width/2;
		ButtonMenu.scaleButton(btnRestart);
		noScroll(btnRestart);
		
        btnExit = new FlxButton(0, 620, "Exit", function() { FlxG.switchState(new MainMenu()); });
		buttons.addButton(btnExit);
		btnExit.x = FlxG.width/2 - btnExit.width/2;
		ButtonMenu.scaleButton(btnExit);

		noScroll(btnExit);
	}
	
	public override function update(elapsed:Float)
	{
		input.update();
		buttons.updateInput(input);
		super.update(elapsed);
	}


}