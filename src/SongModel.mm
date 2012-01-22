
#include "SongModel.h"

const char SampleData::className[] = "SampleData";
Lunar<SampleData>::RegType SampleData::methods[] = {
	method(SampleData, loadSample),
	{0,0}
};

const char ChainModel::className[] = "ChainModel";
Lunar<ChainModel>::RegType ChainModel::methods[] = {
	method(ChainModel, set),
	method(ChainModel, clearPhrase),
	{0,0}
};

const char PhraseModel::className[] = "PhraseModel";
Lunar<PhraseModel>::RegType PhraseModel::methods[] = {
	method(PhraseModel, set),
	method(PhraseModel, clearNote),
	method(PhraseModel, setEffect),
	method(PhraseModel, removeEffect),
	{0,0}
};

const char InstrumentModel::className[] = "InstrumentModel";
Lunar<InstrumentModel>::RegType InstrumentModel::methods[] = {
	method(InstrumentModel, setSample),
	method(InstrumentModel, setLoopMode),
	{0,0}
};

const char SongModel::className[] = "SongModel";
Lunar<SongModel>::RegType SongModel::methods[] = {
	method(SongModel, setChain),
    method(SongModel, clearChain),
	method(SongModel, getChain),
	method(SongModel, getPhrase),
	method(SongModel, getInstrument),
	{0,0}
};
PhraseModel::PhraseModel(lua_State *L){
    // not sure why this doesn't do anything
}
PhraseModel::PhraseModel(){
    // setup all of the items so that we can access them from lua later
    for (int i=0; i<16; i++) {
        hasNote[i] = false;
        hasInst[i] = false;
        col1[i].hasEffect = false;
        col2[i].hasEffect = false;
    }        
}
int PhraseModel::set(lua_State *L){
    int step = luaL_checkinteger(L, 1);
    this->hasNote[step] = true;
    this->hasInst[step] = true;
    this->note[step] = luaL_checkinteger(L, 2);
    this->inst[step] = luaL_checkinteger(L, 3);
    return 1;
}
int PhraseModel::clearNote(lua_State *L){
    int step = luaL_checkinteger(L, 1);
    this->hasNote[step] = false;
    return 1;
}
int PhraseModel::setEffect(lua_State *L){
    int step = luaL_checkinteger(L, 1);
    int col = luaL_checkinteger(L, 2);
    Effect *efx = &col1[step];
    if(col == 2){
        efx = &col2[step];
    }
    efx->hasEffect = true;
    cout << "setting effect type: " << luaL_checkinteger(L, 3)-1 << endl;
    efx->etype = (EffectType)(luaL_checkinteger(L, 3)-1);
    efx->val1 = luaL_checkinteger(L, 4);
    efx->val2 = luaL_checkinteger(L, 5);
    return 1;
}
int PhraseModel::removeEffect(lua_State *L){
    int step = luaL_checkinteger(L, 1);
    int col = luaL_checkinteger(L, 2);
    Effect *efx = &col1[step];
    if(col == 2){
        efx = &col2[step];
    }
    efx->hasEffect = false;
    return 1;
}