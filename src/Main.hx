
import haxegon.*;
import haxe.ds.Vector;

using haxegon.MathExtensions;
using Lambda;

typedef Particle = {
    x: Float, 
    y: Float,
    dx: Float,
    dy: Float,
    age: Int,
};

typedef Enemy = {
    x: Float, 
    y: Float,
    dx: Float,
    dy: Float,
    width: Float,
    height: Float,
};

@:publicFields
class Main {
// force unindent

static inline var SCREEN_WIDTH = 800;
static inline var SCREEN_HEIGHT = 800;
static inline var ORIGIN_X = 100;
static inline var ORIGIN_Y = 400;
static inline var MANY_WORDS = 'words_alpha.txt';
static inline var SOME_WORDS = 'google-10000-english-no-swears.txt';

var particles = new Array<Particle>();
var enemies = new Array<Enemy>();

var words = new Map<String, Bool>();
var used_words = new Map<String, Int>();

var enemy_spawn_timer = 0;

var enemy_speed = 0.1;

function new() {
    Gfx.resizescreen(SCREEN_WIDTH, SCREEN_HEIGHT);

    Gfx.createimage('words_canvas', SCREEN_WIDTH, SCREEN_HEIGHT);
    Gfx.drawtoimage('words_canvas');
    Gfx.clearscreen(Col.GRAY);
    Gfx.drawtoscreen();

    var words_file = Data.loadtext(MANY_WORDS);
    for (w in words_file) {
        if (w.length >= 3) {
            words[w] = true;
        }
    }
}

// TODO: u/n could be doubles
var shooting_chars = [
'q', 'p', 'r', 't', 'd', 'f', 'h', 'k', 'l', 'b', 
];

function char_x_offset(char: String, text: String, i: Int): Float {
    return switch (char) {
        case 'q': Text.width(text.substring(0, i + 1)); 
        case 'p': Text.width(text.substring(0, i)) + 4; 
        case 'r': Text.width(text.substring(0, i)) + 4; 
        case 't': Text.width(text.substring(0, i)) + Text.width('t') / 2; 
        case 'd': Text.width(text.substring(0, i + 1)); 
        case 'f': Text.width(text.substring(0, i)) + Text.width('f') / 2; 
        case 'h': Text.width(text.substring(0, i)) + 4; 
        case 'k': Text.width(text.substring(0, i)) + 4; 
        case 'l': Text.width(text.substring(0, i)) + Text.width('l') / 2; 
        case 'b': Text.width(text.substring(0, i)) + 4; 
        default: 0;
    }
}

function char_y_offset(char: String): Float {
    return switch (char) {
        case 'q': Text.height(); 
        case 'p': Text.height(); 
        case 'r': Text.height(); 
        case 't': 10; 
        case 'd': 10; 
        case 'f': Text.height(); 
        case 'h': 10; 
        case 'k': 10; 
        case 'l': 0; 
        case 'b': 0; 
        default: 0;
    }
}

function char_dy(char: String): Int {
    return switch (char) {
        case 'q': 1; 
        case 'p': 1;
        case 'r': 1; 
        case 't': -1; 
        case 'd': -1; 
        case 'f': 1; 
        case 'h': -1; 
        case 'k': -1; 
        case 'l': 0; // special case, both ways
        case 'b': -1;
        default: 0;
    }
}

var input_text = '';
function html5_input(x: Float, y: Float, text: String, col1: Int, col2: Int) {
    Text.display(x, y, text + input_text, col1);
    Text.display(x + Text.width(text + input_text), y, '_', col1);

    if (Input.justpressed(Key.ENTER)) {
        return true;
    } else {
        if (Input.delaypressed(Key.BACKSPACE, 5)) {
            if (input_text.length > 0) {
                input_text = input_text.substring(0, input_text.length - 1);
            }
        } else if (Input.justpressed(Key.SPACE)) {
            input_text += ' ';
        } else if (Input.justpressed(Key.ZERO)) {
            input_text += '0';
        } else if (Input.justpressed(Key.ONE)) {
            input_text += '1';
        } else if (Input.justpressed(Key.TWO)) {
            input_text += '2';
        } else if (Input.justpressed(Key.THREE)) {
            input_text += '3';
        } else if (Input.justpressed(Key.FOUR)) {
            input_text += '4';
        } else if (Input.justpressed(Key.FIVE)) {
            input_text += '5';
        } else if (Input.justpressed(Key.SIX)) {
            input_text += '6';
        } else if (Input.justpressed(Key.SEVEN)) {
            input_text += '7';
        } else if (Input.justpressed(Key.EIGHT)) {
            input_text += '8';
        } else if (Input.justpressed(Key.NINE)) {
            input_text += '9';
        } else if (Input.justpressed(Key.PERIOD)) {
            input_text += '.';
        } else if (Input.justpressed(Key.Q)) {
            input_text += 'q';
        } else if (Input.justpressed(Key.W)) {
            input_text += 'w';
        } else if (Input.justpressed(Key.E)) {
            input_text += 'e';
        } else if (Input.justpressed(Key.R)) {
            input_text += 'r';
        } else if (Input.justpressed(Key.T)) {
            input_text += 't';
        } else if (Input.justpressed(Key.Y)) {
            input_text += 'y';
        } else if (Input.justpressed(Key.U)) {
            input_text += 'u';
        } else if (Input.justpressed(Key.I)) {
            input_text += 'i';
        } else if (Input.justpressed(Key.O)) {
            input_text += 'o';
        } else if (Input.justpressed(Key.P)) {
            input_text += 'p';
        } else if (Input.justpressed(Key.A)) {
            input_text += 'a';
        } else if (Input.justpressed(Key.S)) {
            input_text += 's';
        } else if (Input.justpressed(Key.D)) {
            input_text += 'd';
        } else if (Input.justpressed(Key.F)) {
            input_text += 'f';
        } else if (Input.justpressed(Key.G)) {
            input_text += 'g';
        } else if (Input.justpressed(Key.H)) {
            input_text += 'h';
        } else if (Input.justpressed(Key.J)) {
            input_text += 'j';
        } else if (Input.justpressed(Key.K)) {
            input_text += 'k';
        } else if (Input.justpressed(Key.L)) {
            input_text += 'l';
        } else if (Input.justpressed(Key.Z)) {
            input_text += 'z';
        } else if (Input.justpressed(Key.X)) {
            input_text += 'x';
        } else if (Input.justpressed(Key.C)) {
            input_text += 'c';
        } else if (Input.justpressed(Key.V)) {
            input_text += 'v';
        } else if (Input.justpressed(Key.B)) {
            input_text += 'b';
        } else if (Input.justpressed(Key.N)) {
            input_text += 'n';
        } else if (Input.justpressed(Key.M)) {
            input_text += 'm';
        }
    }

    return false;
}

var prev_input_text = '';
var good_word = false;

function update() {
    Gfx.clearscreen(Col.GRAY);
    Gfx.drawimage(0, 0, 'words_canvas');

    // Update text color when text changes
    if (input_text != prev_input_text) {
        if (words.exists(input_text) && !used_words.exists(input_text)) {
            good_word = true;
        } else {
            good_word = false;
        }
        prev_input_text = input_text;
    }

    if (html5_input(ORIGIN_X, ORIGIN_Y, '', if (good_word) Col.GREEN else Col.BLACK, Col.BLACK)) {
    }

    if (Input.justpressed(Key.ENTER) && good_word) {
        good_word = false;
        used_words[input_text] = Std.int(SCREEN_HEIGHT / Text.height());

        for (i in 0...input_text.length) {
            var char = input_text.charAt(i);
            if (shooting_chars.indexOf(char) != -1) {
                if (char == 'l') {
                    particles.push({
                        x: ORIGIN_X + char_x_offset(char, input_text, i),
                        y: ORIGIN_Y + 10,
                        dx: 0,
                        dy: -10,
                        age: 0,
                    });
                    particles.push({
                        x: ORIGIN_X + char_x_offset(char, input_text, i),
                        y: ORIGIN_Y + Text.height() - 5,
                        dx: 0,
                        dy: 10,
                        age: 0,
                    });
                } else {
                    particles.push({
                        x: ORIGIN_X + char_x_offset(char, input_text, i),
                        y: ORIGIN_Y + char_y_offset(char),
                        dx: 0,
                        dy: 10 * char_dy(char),
                        age: 0,
                    });
                }
            }
        }

        // Draw word on word canvas
        Gfx.drawtoimage('words_canvas');
        Gfx.drawimage(0, Text.height(), 'words_canvas');
        Gfx.fillbox(0, 0, SCREEN_WIDTH, Text.height(), Col.GRAY);
        Text.display(SCREEN_WIDTH / 2, 0,            input_text, Col.BLACK);
        Gfx.drawtoscreen();

        for (w in used_words.keys()) {
            used_words[w] = used_words[w] - 1;

            if (used_words[w] <= 0) {
                used_words.remove(w);
            }
        }

        input_text = '';
    }

    for (p in particles.copy()) {
        if (Math.abs(p.dy) > 5) {
            p.dy = Math.sign(p.dy) * (Math.abs(p.dy) - 0.1);
        }

        p.x += p.dx;
        p.y += p.dy;
        p.age++;

        if (p.y < 0 || p.y > SCREEN_HEIGHT) {
            particles.remove(p);
        }

        for (e in enemies.copy()) {
            if (Math.point_box_intersect(p.x, p.y, e.x, e.y, e.width, e.height)) {
                enemies.remove(e);
            }
        }
    }

    for (e in enemies.copy()) {
        e.x += e.dx;
        e.y += e.dy;

        // TODO: end game when enemy touches player
        if (e.y > ORIGIN_Y) {

        }
    }

    enemy_spawn_timer--;
    if (enemy_spawn_timer <= 0) {
        var from_top = Random.bool();

        enemy_spawn_timer = Random.int(2 * 60, 5 * 60);

        enemies.push({
            x: Random.int(ORIGIN_X - 5, Std.int(ORIGIN_X + Text.width('longwo'))),
            y: if (from_top) 0 else SCREEN_HEIGHT,
            dx: 0,
            dy: if (from_top) enemy_speed else -enemy_speed,
            width: Random.float(10, 30),
            height: Random.float(8, 12),
        });

        if (Random.chance(10)) {
            enemy_speed += 0.01;
        }
    }

    for (p in particles) {
        Gfx.fillcircle(p.x, p.y, 3, Col.RED);        
    }

    for (e in enemies) {
        Gfx.fillbox(e.x, e.y, e.width, e.height, Col.RED);        
    }
}

}
