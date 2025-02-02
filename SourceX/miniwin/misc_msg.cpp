#include <deque>
#include <SDL.h>
#include <switch.h>
#include "devilution.h"
#include "stubs.h"

/** @file
 * *
 * Windows message handling and keyboard event conversion for SDL.
 */

  
namespace dvl {

bool conInv = false;
float leftStickX;
float leftStickY;
float rightStickX;
float rightStickY;
float leftTrigger;
float rightTrigger;
float deadzoneX;
float deadzoneY;
int doAttack 	= 0;
int doUse 		= 0;
int doChar 		= 0;

JoystickPosition pos_left, pos_right;

void PollSwitchStick();
static std::deque<MSG> message_queue;

static int translate_sdl_key(SDL_Keysym key)
{
	int sym = key.sym;
	switch (sym) {
	case SDLK_ESCAPE:
		return DVL_VK_ESCAPE;
	case SDLK_RETURN:
	case SDLK_KP_ENTER:
		return DVL_VK_RETURN;
	case SDLK_TAB:
		return DVL_VK_TAB;
	case SDLK_SPACE:
		return DVL_VK_SPACE;
	case SDLK_BACKSPACE:
		return DVL_VK_BACK;

	case SDLK_DOWN:
		return DVL_VK_DOWN;
	case SDLK_LEFT:
		return DVL_VK_LEFT;
	case SDLK_RIGHT:
		return DVL_VK_RIGHT;
	case SDLK_UP:
		return DVL_VK_UP;

	case SDLK_PAGEUP:
		return DVL_VK_PRIOR;
	case SDLK_PAGEDOWN:
		return DVL_VK_NEXT;

	case SDLK_PAUSE:
		return DVL_VK_PAUSE;

	case SDLK_SEMICOLON:
		return DVL_VK_OEM_1;
	case SDLK_QUESTION:
		return DVL_VK_OEM_2;
	case SDLK_BACKQUOTE:
		return DVL_VK_OEM_3;
	case SDLK_LEFTBRACKET:
		return DVL_VK_OEM_4;
	case SDLK_BACKSLASH:
		return DVL_VK_OEM_5;
	case SDLK_RIGHTBRACKET:
		return DVL_VK_OEM_6;
	case SDLK_QUOTE:
		return DVL_VK_OEM_7;
	case SDLK_MINUS:
		return DVL_VK_OEM_MINUS;
	case SDLK_PLUS:
		return DVL_VK_OEM_PLUS;
	case SDLK_PERIOD:
		return DVL_VK_OEM_PERIOD;
	case SDLK_COMMA:
		return DVL_VK_OEM_COMMA;
	case SDLK_LSHIFT:
	case SDLK_RSHIFT:
		return DVL_VK_SHIFT;
	case SDLK_PRINTSCREEN:
		return DVL_VK_SNAPSHOT;

	default:
		if (sym >= SDLK_a && sym <= SDLK_z) {
			return 'A' + (sym - SDLK_a);
		} else if (sym >= SDLK_0 && sym <= SDLK_9) {
			return '0' + (sym - SDLK_0);
		} else if (sym >= SDLK_F1 && sym <= SDLK_F12) {
			return DVL_VK_F1 + (sym - SDLK_F1);
		}
		DUMMY_PRINT("unknown key: name=%s sym=0x%X scan=%d mod=0x%X", SDL_GetKeyName(sym), sym, key.scancode, key.mod);
		return -1;
	}
}

static WPARAM keystate_for_mouse(WPARAM ret)
{
	const Uint8 *keystate = SDL_GetKeyboardState(NULL);
	ret |= keystate[SDL_SCANCODE_LSHIFT] ? DVL_MK_SHIFT : 0;
	ret |= keystate[SDL_SCANCODE_RSHIFT] ? DVL_MK_SHIFT : 0;
	// XXX: other DVL_MK_* codes not implemented
	return ret;
}

static WINBOOL false_avail()
{
	DUMMY_PRINT("return false although event avaliable", 1);
	return false;
}

WINBOOL PeekMessageA(LPMSG lpMsg, HWND hWnd, UINT wMsgFilterMin, UINT wMsgFilterMax, UINT wRemoveMsg)
{
	static signed short rstick_x;
	static signed short lstick_x;
	static signed short rstick_y;
	static signed short lstick_y;
	
	static short lastmouseX, lastmouseY;	
 
	if (wMsgFilterMin != 0)
		UNIMPLEMENTED();
	if (wMsgFilterMax != 0)
		UNIMPLEMENTED();
	if (hWnd != NULL)
		UNIMPLEMENTED();

	if (wRemoveMsg == DVL_PM_NOREMOVE) {
		// This does not actually fill out lpMsg, but this is ok
		// since the engine never uses it in this case
		return !message_queue.empty() || SDL_PollEvent(NULL);
	}
	if (wRemoveMsg != DVL_PM_REMOVE) {
		UNIMPLEMENTED();
	}

	if (!message_queue.empty()) {
		*lpMsg = message_queue.front();
		message_queue.pop_front();
		return true;
	}
 
	SDL_Event e;
	if (!SDL_PollEvent(&e)) {
		return false;
	}
 
	lpMsg->hwnd = hWnd;
	lpMsg->lParam = 0;
	lpMsg->wParam = 0;

	switch (e.type) { 
	case SDL_JOYAXISMOTION:
		PollSwitchStick();
		lpMsg->message = e.type == SDL_KEYUP;
		lpMsg->lParam = 0;
		break;
	case SDL_JOYBUTTONUP: 
		//doAttack = 0;
		//doUse = 0;	
		switch(e.jbutton.button)
		{
			case 8:
					lpMsg->message = DVL_WM_RBUTTONUP;
					lpMsg->lParam = (MouseY << 16) | (MouseX & 0xFFFF);
					lpMsg->wParam = keystate_for_mouse(0);
					break;
			case 9:
					lpMsg->message = DVL_WM_LBUTTONUP;
					lpMsg->lParam = (MouseY << 16) | (MouseX & 0xFFFF);	
					lpMsg->wParam = keystate_for_mouse(0);		
					break;
		}
		break;
	case SDL_JOYBUTTONDOWN:
		switch(e.jbutton.button)
		{
			case  0:	// A
				useBeltPotion(false);
				break;
			case  1:	// B
				doAttack = 1;				 
				break;
			case  2:	// X
				PressChar('i');
				break;
			case  3:	// Y
				doUse = 1;
				PressKey(VK_RETURN);
				break;
			case  6:	// L
				PressChar('h');
				break;
			case  7:	// R
				PressChar('c');
				break;
			case  8:	// ZL
				lpMsg->message = DVL_WM_RBUTTONDOWN;
				lpMsg->lParam = (MouseY << 16) | (MouseX & 0xFFFF);
				lpMsg->wParam = keystate_for_mouse(DVL_MK_RBUTTON);
				break;
			case  9:	// ZR
				//if (invflag || spselflag || chrflag)
				//{
					lpMsg->message = DVL_WM_LBUTTONDOWN;
					lpMsg->lParam = (MouseY << 16) | (MouseX & 0xFFFF);	
					lpMsg->wParam = keystate_for_mouse(DVL_MK_LBUTTON);
				//}
				//else
				//{
				//	useBeltPotion(true);
				//}
				break;
			case 10:
				break;						
			case 11:
				PressKey(VK_ESCAPE);
				break;								
			case 16:
				PressKey(VK_LEFT);
				break;
			case 17:
				PressKey(VK_UP);
				break;	
			case 18:
				PressKey(VK_RIGHT);
				break;	
			case 19:
				PressKey(VK_DOWN);
				break;					
		}
		break;
	case SDL_QUIT:
		lpMsg->message = DVL_WM_QUIT;
		break;
	case SDL_FINGERMOTION:
	case SDL_MOUSEMOTION:
		lpMsg->message = DVL_WM_MOUSEMOVE;
		lpMsg->lParam = (e.motion.y << 16) | (e.motion.x & 0xFFFF);
		lpMsg->wParam = keystate_for_mouse(0);
		break;
	case SDL_FINGERDOWN:
	case SDL_MOUSEBUTTONDOWN: {
		int button = e.button.button;
		if (button == SDL_BUTTON_LEFT) {
			lpMsg->message = DVL_WM_LBUTTONDOWN;
			lpMsg->lParam = (e.button.y << 16) | (e.button.x & 0xFFFF);
			lpMsg->wParam = keystate_for_mouse(DVL_MK_LBUTTON);
		} else if (button == SDL_BUTTON_RIGHT) {
			lpMsg->message = DVL_WM_RBUTTONDOWN;
			lpMsg->lParam = (e.button.y << 16) | (e.button.x & 0xFFFF);
			lpMsg->wParam = keystate_for_mouse(DVL_MK_RBUTTON);
		} else {
			return false_avail();
		}
	} break;
	case SDL_FINGERUP:
	case SDL_MOUSEBUTTONUP: {
		int button = e.button.button;
		if (button == SDL_BUTTON_LEFT) {
			lpMsg->message = DVL_WM_LBUTTONUP;
			lpMsg->lParam = (e.button.y << 16) | (e.button.x & 0xFFFF);
			lpMsg->wParam = keystate_for_mouse(0);
		} else if (button == SDL_BUTTON_RIGHT) {
			lpMsg->message = DVL_WM_RBUTTONUP;
			lpMsg->lParam = (e.button.y << 16) | (e.button.x & 0xFFFF);
			lpMsg->wParam = keystate_for_mouse(0);
		} else {
			return false_avail();
		}
	} break;
	case SDL_TEXTINPUT:
	case SDL_WINDOWEVENT:
		if (e.window.event == SDL_WINDOWEVENT_CLOSE) {
			lpMsg->message = DVL_WM_QUERYENDSESSION;
		} else {
			return false_avail();
		}
		break;
	default:
		DUMMY_PRINT("unknown SDL message 0x%X", e.type);
		return false_avail();
	}
	return true;
}

WINBOOL TranslateMessage(const MSG *lpMsg)
{
	assert(lpMsg->hwnd == 0);
	if (lpMsg->message == DVL_WM_KEYDOWN) {
		int key = lpMsg->wParam;
		unsigned mod = (DWORD)lpMsg->lParam >> 16;

		bool shift = (mod & KMOD_SHIFT) != 0;
		bool upper = shift != (mod & KMOD_CAPS);

		bool is_alpha = (key >= 'A' && key <= 'Z');
		bool is_numeric = (key >= '0' && key <= '9');
		bool is_control = key == DVL_VK_SPACE || key == DVL_VK_BACK || key == DVL_VK_ESCAPE || key == DVL_VK_TAB || key == DVL_VK_RETURN;
		bool is_oem = (key >= DVL_VK_OEM_1 && key <= DVL_VK_OEM_7);

		if (is_control || is_alpha || is_numeric || is_oem) {
			if (!upper && is_alpha) {
				key = tolower(key);
			} else if (shift && is_numeric) {
				key = key == '0' ? ')' : key - 0x10;
			} else if (is_oem) {
				// XXX: This probably only supports US keyboard layout
				switch (key) {
				case DVL_VK_OEM_1:
					key = shift ? ':' : ';';
					break;
				case DVL_VK_OEM_2:
					key = shift ? '?' : '/';
					break;
				case DVL_VK_OEM_3:
					key = shift ? '~' : '`';
					break;
				case DVL_VK_OEM_4:
					key = shift ? '{' : '[';
					break;
				case DVL_VK_OEM_5:
					key = shift ? '|' : '\\';
					break;
				case DVL_VK_OEM_6:
					key = shift ? '}' : ']';
					break;
				case DVL_VK_OEM_7:
					key = shift ? '"' : '\'';
					break;

				case DVL_VK_OEM_MINUS:
					key = shift ? '_' : '-';
					break;
				case DVL_VK_OEM_PLUS:
					key = shift ? '+' : '=';
					break;
				case DVL_VK_OEM_PERIOD:
					key = shift ? '>' : '.';
					break;
				case DVL_VK_OEM_COMMA:
					key = shift ? '<' : ',';
					break;

				default:
					UNIMPLEMENTED();
				}
			}

			if (key >= 32) {
				DUMMY_PRINT("char: %c", key);
			}

			// XXX: This does not add extended info to lParam
			PostMessageA(lpMsg->hwnd, DVL_WM_CHAR, key, 0);
		}
	}

	return true;
}

SHORT GetAsyncKeyState(int vKey)
{
	DUMMY_ONCE();
	// TODO: Not handled yet.
	return 0;
}

LRESULT DispatchMessageA(const MSG *lpMsg)
{
	DUMMY_ONCE();
	assert(lpMsg->hwnd == 0);
	assert(CurrentProc);
	// assert(CurrentProc == GM_Game);

	return CurrentProc(lpMsg->hwnd, lpMsg->message, lpMsg->wParam, lpMsg->lParam);
}

WINBOOL PostMessageA(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam)
{
	DUMMY();

	assert(hWnd == 0);

	MSG msg;
	msg.hwnd = hWnd;
	msg.message = Msg;
	msg.wParam = wParam;
	msg.lParam = lParam;

	message_queue.push_back(msg);

	return true;
}

void PollSwitchStick()
{
	int h,k = 0;
	hidScanInput();
	
	//Read the joysticks' position
	hidJoystickRead(&pos_left, CONTROLLER_P1_AUTO, JOYSTICK_LEFT);
	hidJoystickRead(&pos_right, CONTROLLER_P1_AUTO, JOYSTICK_RIGHT);
 
	float normLX = fmaxf(-1, (float)pos_left.dx / 4000);
	float normLY = fmaxf(-1, (float)pos_left.dy / 4000);

	leftStickX = (abs(normLX) < deadzoneX ? 0 : (abs(normLX) - deadzoneX) * (normLX / abs(normLX)));
	leftStickY = (abs(normLY) < deadzoneY ? 0 : (abs(normLY) - deadzoneY) * (normLY / abs(normLY)));

	if (deadzoneX > 0)
		leftStickX *= 1 / (1 - deadzoneX);
	if (deadzoneY > 0)
		leftStickY *= 1 / (1 - deadzoneY);
 
	float normRX = fmaxf(-1, (float)pos_right.dx / 32768);
	float normRY = fmaxf(-1, (float)pos_right.dy / 32768);

	rightStickX = (abs(normRX) < deadzoneX ? 0 : (abs(normRX) - deadzoneX) * (normRX / abs(normRX)));
	rightStickY = (abs(normRY) < deadzoneY ? 0 : (abs(normRY) - deadzoneY) * (normRY / abs(normRY)));

	if (deadzoneX > 0)
		rightStickX *= 1 / (1 - deadzoneX);
	if (deadzoneY > 0)
		rightStickY *= 1 / (1 - deadzoneY);
 

	// right joystick moves cursor
	if (rightStickX > 0.05 || rightStickY > 0.05 || rightStickX < -0.05 || rightStickY < -0.05) {

		if (pcurs == CURSOR_NONE)
			SetCursor_(CURSOR_HAND);		
		
		static int hiresDX = 0; // keep track of X sub-pixel per frame mouse motion
		static int hiresDY = 0; // keep track of Y sub-pixel per frame mouse motion
		const int slowdown = 128; // increase/decrease this to decrease/increase mouse speed

		int x = MouseX;
		int y = MouseY;
		if (rightStickX > 0.05 || rightStickX < 0.05)
			hiresDX += rightStickX * 256.0;
		if (rightStickY > 0.05 || rightStickY < 0.05)
			hiresDY += rightStickY * 256.0;

		x += hiresDX / slowdown;
		y += -(hiresDY) / slowdown;

		hiresDX %= slowdown; // keep track of dx remainder for sub-pixel per frame mouse motion
		hiresDY %= slowdown; // keep track of dy remainder for sub-pixel per frame mouse motion

		if (x < 0)
			x = 0;
		if (y < 0)
			y = 0;
		
		SetCursorPos(x, y);		
		MouseX = x;
		MouseY = y;
	} 
  
}
}
