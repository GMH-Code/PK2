//#########################
//Pekka Kana 2
//Copyright (c) 2003 Janne Kivilahti
//#########################
#pragma once

#include "engine/types.hpp"
#include "engine/PFile.hpp"

enum SCREEN {
	SCREEN_NOT_SET,
	SCREEN_FIRST_START,
	SCREEN_INTRO,
	SCREEN_MENU,
	SCREEN_MAP,
	SCREEN_GAME,
	SCREEN_SCORING,
	SCREEN_END,

#ifndef __EMSCRIPTEN__
	SCREEN_LUA
#endif
};

extern int current_screen;
extern int next_screen;

extern uint menu_valittu_id;
extern uint menu_valinta_id;

extern PFile::Path lua_script_path;

void Fade_Quit();

int Screen_Intro_Init();
int Screen_Menu_Init();
int Screen_Map_Init();
int Screen_InGame_Init();
int Screen_ScoreCount_Init();
int Screen_Ending_Init();
#ifndef __EMSCRIPTEN__
int Screen_Lua_Init();
#endif

int Screen_Intro();
int Screen_Menu();
int Screen_Map();
int Screen_InGame();
int Screen_ScoreCount();
int Screen_Ending();
#ifndef __EMSCRIPTEN__
int Screen_Lua();
#endif

int Screen_First_Start();
int Screen_Loop();