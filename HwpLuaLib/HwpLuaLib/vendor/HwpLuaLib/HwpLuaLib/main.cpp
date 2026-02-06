#include "pch.h"
#include <windows.h>
#include <ole2.h>
#include <string>
#include <iostream>

// Lua 헤더 (설치하신 경로에 맞게 설정 필요)
extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}
#include "luacom.h"

#pragma comment(lib, "ole32.lib")
#pragma comment(lib, "oleaut32.lib")

// --- 핵심 로직: 실행 중인 한글 객체 찾기 ---
static IDispatch* GetHwpObject() {
    IRunningObjectTable* pROT = NULL;
    IEnumMoniker* pEnum = NULL;
    IDispatch* pHwpApp = NULL;

    if (GetRunningObjectTable(0, &pROT) != S_OK) return NULL;

    pROT->EnumRunning(&pEnum);
    pEnum->Reset();

    IMoniker* pMoniker = NULL;
    ULONG fetched = 0;

    while (pEnum->Next(1, &pMoniker, &fetched) == S_OK) {
        IBindCtx* pBindCtx = NULL;
        CreateBindCtx(0, &pBindCtx);

        LPOLESTR pDisplayName = NULL;
        pMoniker->GetDisplayName(pBindCtx, NULL, &pDisplayName);
        std::wstring name(pDisplayName);

        if (name.find(L"!HwpObject") != std::wstring::npos) {
            IUnknown* pUnk = NULL;
            pROT->GetObjectW(pMoniker, &pUnk);
            pUnk->QueryInterface(IID_IDispatch, (void**)&pHwpApp);
            pUnk->Release();
        }

        CoTaskMemFree(pDisplayName);
        pBindCtx->Release();
        pMoniker->Release();
        if (pHwpApp) break;
    }

    pEnum->Release();
    pROT->Release();
    return pHwpApp;
}

// --- Lua 인터페이스: HwpInstance.GetActiveObject ---
static int l_GetActiveObject(lua_State* L) {
    IDispatch* pHwp = GetHwpObject();
    if (pHwp) {
        // 루아에서 이 객체를 다룰 수 있게 luacom 등을 쓰거나 
        // 포인터를 그대로 넘겨줄 수 있습니다. 
        // 여기서는 가장 범용적인 'lightuserdata'로 포인터를 넘깁니다.
        luacom_IDispatch2LuaCOM(L, (void*) pHwp);
        return 1;
    }
    lua_pushnil(L);
    return 1;
}

// --- DLL 등록부 (Lua가 require할 때 호출됨) ---
static const struct luaL_Reg hwp_funcs[] = {
    {"GetActiveObject", l_GetActiveObject},
    {NULL, NULL}
};

extern "C" __declspec(dllexport) int luaopen_HwpLuaLib(lua_State* L) {
    // 1. 전체 모듈 테이블 생성
    lua_newtable(L);

    // 2. HwpInstance 테이블 생성 및 함수 등록
    lua_newtable(L);
    // luaL_setfuncs 대신 luaL_register를 사용합니다. (두 번째 인자는 NULL)
    luaL_register(L, NULL, hwp_funcs);

    // 3. HwpInstance라는 이름으로 메인 테이블에 등록
    lua_setfield(L, -2, "HwpInstance");

    return 1;
}