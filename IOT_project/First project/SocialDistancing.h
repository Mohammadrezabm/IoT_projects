#ifndef SOCIALDISTANCING_H
#define SOCIALDISTANCING_H

enum {
	AM_SOCIALDISTANCING = 6,
	TIMER_VALUE = 500
};

typedef nx_struct SocialDistancingMsg {
	nx_uint16_t nodeid;
	nx_uint16_t counter;

} SocialDistancingMsg;

#endif
