
#include "SongModel.h"

const char SampleData::className[] = "SampleData";
Lunar<SampleData>::RegType SampleData::methods[] = {
	method(SampleData, loadSample),
	{0,0}
};

const char ChainModel::className[] = "ChainModel";
Lunar<ChainModel>::RegType ChainModel::methods[] = {
	method(ChainModel, set),
	{0,0}
};

const char PhraseModel::className[] = "PhraseModel";
Lunar<PhraseModel>::RegType PhraseModel::methods[] = {
	method(PhraseModel, set),
	{0,0}
};

const char InstrumentModel::className[] = "InstrumentModel";
Lunar<InstrumentModel>::RegType InstrumentModel::methods[] = {
	method(InstrumentModel, setSample),
	{0,0}
};

const char SongModel::className[] = "SongModel";
Lunar<SongModel>::RegType SongModel::methods[] = {
	method(SongModel, setChain),
	method(SongModel, getChain),
	method(SongModel, getPhrase),
	method(SongModel, getInstrument),
	{0,0}
};