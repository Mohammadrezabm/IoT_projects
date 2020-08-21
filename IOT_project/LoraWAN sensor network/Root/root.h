#ifndef ROOT_H
#define ROOT_H

enum {
	AM_ROOT = 6,

};

typedef nx_struct RootMsg {
	nx_uint16_t nodeidroot;
	nx_uint16_t tonoderoot;
	nx_uint16_t pktidroot;
	nx_uint16_t pktusage;
	nx_uint16_t pkttemp;

} RootMsg;

typedef nx_struct RootOutMsg {
	nx_uint16_t rootid;
	nx_uint16_t tonoderootout;
	nx_uint16_t pktidrootout;
	nx_uint16_t pktusageout;
	nx_uint16_t pkttempout;

} RootOutMsg;

#endif
