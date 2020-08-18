#ifndef ROOT_H
#define ROOT_H

enum {
	AM_ROOT = 6,

};

typedef nx_struct RootMsg {
	nx_uint16_t nodeidroot;
	nx_uint16_t tonoderoot;
	nx_uint16_t pktidroot;
	nx_uint16_t pktdata;

} RootMsg;

typedef nx_struct RootOutMsg {
	nx_uint16_t rootid;
	nx_uint16_t tonoderootout;
	nx_uint16_t pktidrootout;
	nx_uint16_t pktdataout;

} RootOutMsg;

#endif
