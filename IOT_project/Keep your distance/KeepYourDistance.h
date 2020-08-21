#ifndef KEEPYOURDISTANCE_H
#define KEEPYOURDISTANCE_H

enum {
	AM_KEEPYOURDISTANCE = 6,
	TIMER_VALUE = 500
};

typedef nx_struct KeepYourDistanceMsg {

	nx_uint16_t nodeid;
	nx_uint16_t pktid;

} KeepYourDistanceMsg;


#endif
